#!/usr/bin/env python3
"""Render the layered-page inputs: character-free plates + one sprite per character.

For the ``layered`` pages (§H), ``Photoshop/<book>/<page>/art/bg.png`` must be the scene
**without** characters, and each character is a separate sprite with a flat,
keyable backdrop that ``transparent_color: auto`` removes at assembly. One
sprite per character is reused across pages, so identity is pinned by a single
image rather than by whatever each render happens to invent.

The plate prompt is derived from the page's own generated prompt (its
``## Prompt`` block) by dropping the cast section — the Fountain stays the only
source of truth.  Sprites are rendered once per character with that character's
Cast ``subject_ids``; no LoRA is trained.

Usage
-----
    python3 Scripts/render_layered.py --plates p1 p2 p3
    python3 Scripts/render_layered.py --sprites hero friend
    python3 Scripts/render_layered.py --all
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import Any

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import render_pages as rp  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))
from paths import PAGES_DIR  # noqa: E402  — single source of truth for the page tree
from paths import SPRITE_DIR  # noqa: E402
SAFE_W, SAFE_H = 1920, 1280

SPRITE_ART = (
    "Hand-painted children's picture-book character illustration in gouache and "
    "coloured pencil on textured paper: muted earthy palette of mustard, terracotta, "
    "sage and cream, flat shapes with visible brush edges, gentle paper grain, soft "
    "warm light from the upper left. Not a 3D render, not photorealistic, no glossy "
    "mascot look. The character is cut out on a perfectly flat, uniform pure white "
    "background with no shadow, no floor, no scenery, no props the character does not "
    "own, no text, no lettering, no watermark, no frame."
)

from book_config import BOOK, CAST as _CAST  # noqa: E402

DEFAULT_POSE = (
    "Full body, standing, facing the viewer, arms a little away from the body so "
    "the silhouette is clear, entire figure inside the frame with headroom"
)

# Identity and pose are separate on purpose: only the pose clause changes between
# stills of the same character, which is what keeps the face and clothes stable
# across a pose set. Both come from the book's cast table (Scripts/book.yaml):
#   description   the identity text
#   sprite_pose   the default stance (optional)
#   poses:        {pose name: pose clause} — one still per pose, per character
CHARS: dict[str, dict[str, Any]] = {
    tag: {
        "id": entry.get("subject_id"),
        "identity": entry.get("sprite_identity") or entry.get("description", ""),
        "pose": entry.get("sprite_pose") or DEFAULT_POSE,
    }
    for tag, entry in _CAST.items()
    if entry.get("kind", "character") == "character" and entry.get("subject_id")
}

#: character -> pose name -> pose clause. Pose sets are book data: a page names
#: the still it wants (``image: _sprites/<character>/<pose>.png``), and nothing
#: here should invent a pose no page asks for.
POSES: dict[str, dict[str, str]] = {
    tag: dict(entry.get("poses") or {})
    for tag, entry in _CAST.items()
    if entry.get("kind", "character") == "character"
}

# Plates must differ per scene, but the generated prompt's "Scene:" line is the
# cast action and is stripped — so the location focus comes from the Fountain's
# scene heading plus this per-page note.
PLATE_NOTE: dict[str, str] = {
    # No word about figures here: a note like "where a child would stand" is
    # rendered literally, and the plate must stay empty.
    "p1": (
        "Location: the wildflower meadow below the cottage, the chalk path winding "
        "back toward the gate. Wide open grass in the middle ground."
    ),
    "p2": (
        "Location: the farmhouse porch and its stone step, the sage-green door closed, "
        "the low stone wall and the leaning gate beyond. Clear empty flagstones across "
        "the lower half of the frame."
    ),
    "p3": (
        "Location: the farmhouse doorway, the sage-green door standing open, a wide "
        "flagstone step in front, clear empty ground across the middle of the frame."
    ),
}

NEGATIVE = (
    "text, lettering, watermark, signature, logo, words, people, person, human "
    "figure, child, girl, boy, man, woman, farmer, dog, puppy, animal, bird, "
    "silhouette of a person, multiple characters, extra limbs, deformed hands"
)


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def plate_prompt(page: str) -> str:
    model = os.path.join(PAGES_DIR, page, "page.model.md")
    if not os.path.exists(model):
        die(f"{page}: no {model}")
    text = open(model, encoding="utf-8").read()
    match = re.search(r"## Prompt\n\n```text\n(.*?)\n```", text, re.S)
    if not match:
        die(f"{page}: no prompt block")
    prompt = match.group(1)

    # Drop the cast section: the plate is the scene with no characters in it.
    prompt = re.sub(
        r"\n\nCharacters \(keep every detail identical\):\n(?:- .*\n?)+?(?=\n\n)",
        "\n",
        prompt,
    )
    # Drop the cast action line and the "figures centred" composition note: the
    # plate is the setting alone, with room where the sprites will stand.
    prompt = re.sub(r"\n\nScene: .*?(?=\n\n|$)", "", prompt, flags=re.S)
    prompt = re.sub(r"\n\nComposition: .*?(?=\n\n|$)", "", prompt, flags=re.S)
    note = PLATE_NOTE.get(page, "")
    return (
        prompt.strip()
        + "\n\n"
        + (note + "\n\n" if note else "")
        + "Empty scene plate: no people, no animals, no figures at all — the setting "
        "alone, same light and weather, with clear ground where figures would stand."
    )


def render_one(prompt: str, subject_ids: list[int], width: int, height: int,
               server: str, timeout: float, label: str) -> str:
    payload = {
        "prompts": [prompt],
        "model": "zimage-turbo",
        "style": "artistic",
        "width": width,
        "height": height,
        "auto_enhance": False,
        "negative_prompt": NEGATIVE,
        "subject_ids": subject_ids,
        "display_name": f"{BOOK} {label}",
    }
    response = rp.http_json(server + "/api/batch-image/generate/prompts", payload, timeout=120)
    batch = (response.get("data") or {}).get("batch_id")
    if not batch:
        die(f"{label}: no batch id: {response}")
    print(f"  {label}: batch {batch} {width}x{height} subject_ids={subject_ids}")
    data = rp.poll(batch, server, timeout)
    if data.get("status") != "completed":
        die(f"{label}: {data.get('status')}: {data.get('error')}")
    return rp.first_image(data, server, batch)


def sprite_prompt(character: str, pose: str | None = None) -> str:
    """Art direction + identity + one pose clause."""
    entry = CHARS[character]
    clause = POSES[character][pose] if pose else entry["pose"]
    return f"{SPRITE_ART}\n\nCharacter: {entry['identity']}.\n\nPose: {clause}."


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--plates", nargs="*", default=[], help="page ids, e.g. p1 p2 p3")
    parser.add_argument("--sprites", nargs="*", default=[], help="characters, e.g. hero friend")
    parser.add_argument(
        "--poses", nargs="*", default=[],
        help="character:pose stills, e.g. hero:running friend:sitting "
             "(poses: " + ", ".join(f"{c}:{p}" for c in POSES for p in POSES[c]) + ")",
    )
    parser.add_argument("--all", action="store_true", help="p1 p2 p3 + all sprites")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--server", default=rp.DEFAULT_SERVER)
    parser.add_argument("--timeout", type=float, default=900.0)
    args = parser.parse_args(argv)

    plates = args.plates or (["p1", "p2", "p3"] if args.all else [])
    sprites = args.sprites or (list(CHARS) if args.all else [])
    poses = args.poses or []
    if not plates and not sprites and not poses:
        die("nothing to do: pass --plates, --sprites, --poses or --all")

    for spec in poses:
        if ":" not in spec:
            die(f"--poses wants character:pose, got {spec!r}")
        character, pose = spec.split(":", 1)
        if pose not in POSES.get(character, {}):
            die(
                f"{spec}: no such pose; known: "
                + (", ".join(f"{c}:{p}" for c in POSES for p in POSES[c]) or "none")
            )
        dst = os.path.join(SPRITE_DIR, character, f"{pose}.png")
        if os.path.exists(dst) and not args.force:
            print(f"  pose {spec}: exists ({os.path.relpath(dst, REPO_ROOT)}), --force to re-render")
            continue
        src = render_one(
            sprite_prompt(character, pose), [CHARS[character]["id"]],
            768, 1024, args.server, args.timeout, f"pose {spec}",
        )
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        with Image.open(src) as im:
            im.convert("RGB").save(dst)
        print(f"    -> {os.path.relpath(dst, REPO_ROOT)}")

    for character in sprites:
        dst = os.path.join(SPRITE_DIR, f"{character}.png")
        if os.path.exists(dst) and not args.force:
            print(f"  sprite {character}: exists, --force to re-render")
            continue
        src = render_one(
            sprite_prompt(character),
            [CHARS[character]["id"]],
            768, 1024, args.server, args.timeout, f"sprite {character}",
        )
        os.makedirs(SPRITE_DIR, exist_ok=True)
        with Image.open(src) as im:
            im.convert("RGB").save(dst)
        print(f"    -> {os.path.relpath(dst, REPO_ROOT)}")

    for page in plates:
        dst = os.path.join(PAGES_DIR, page, "art", "bg.png")
        if os.path.exists(dst) and not args.force:
            print(f"  plate {page}: exists, --force to re-render")
            continue
        src = render_one(
            plate_prompt(page), [], 1536, 1024, args.server, args.timeout, f"plate {page}",
        )
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        with Image.open(src) as im:
            im.convert("RGB").resize((SAFE_W, SAFE_H), Image.LANCZOS).save(dst)
        print(f"    -> {os.path.relpath(dst, REPO_ROOT)} ({SAFE_W}x{SAFE_H})")

    print("done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
