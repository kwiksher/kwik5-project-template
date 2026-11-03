#!/usr/bin/env python3
"""Cast reference sheets (§D2): one PSD per character whose layers are views.

Three stages, each rerunnable:

``--render``    one batch per character: one prompt per view, the character's
                own Cast ``subject_ids`` (no retraining, triggers applied by the
                backend), 1024x1536 → ``cast/<character>/png/<view>.png``.
``--assemble``  write ``cast/<character>.layers.yaml`` — canvas 1280x1920, every
                view a full-canvas layer at (640, 960) and identical figure
                scale — then build ``cast/<character>.psd``.
``--dataset``   export ``datasets/<trigger>/<view>.png`` + ``<view>.txt`` (caption
                carries the registered trigger) and ``dataset.yaml``.

Views and order are fixed by §D2.2:

    face_forward, body_front, face_threequarter, body_threequarter,
    face_profile, body_side, body_back, detail_outfit

Invariants (§D2.3) are encoded in the prompt tail: one outfit, one hairstyle,
one palette, one light direction, one medium, a flat neutral backdrop, no text,
no props the character does not own.

Usage
-----
    python3 Scripts/cast_sheets.py --render            # 8 renders per character
    python3 Scripts/cast_sheets.py --assemble --dataset
    python3 Scripts/cast_sheets.py --render hero      # one character
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any

import yaml
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import render_pages as rp  # noqa: E402  (shared backend helpers)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAST_DIR = os.path.join(REPO_ROOT, "cast")
CANVAS = {"width": 1280, "height": 1920, "scale": 0.25}
LAYER_X, LAYER_Y = 640, 960
RENDER_W, RENDER_H = 1024, 1536

ART = (
    "Hand-painted children's picture-book character reference sheet, gouache and "
    "coloured pencil on textured paper: muted earthy palette of mustard, terracotta, "
    "sage and cream, flat shapes with visible brush edges, gentle paper grain, soft "
    "warm light from the upper left. Not a 3D render, not photorealistic, no glossy "
    "mascot look. Plain flat off-white paper background, no scenery, no props the "
    "character does not own, no text, no lettering, no watermark, no frame."
)

# Order matters: it is the PSD layer order and the dataset order (§D2.2).
# Face views are close-ups that fill the frame (head and shoulders only); body
# views are full figures. Both families share the same figure scale so the
# views are pixel-comparable (§D2.1), and neither may add a background.
VIEWS: list[tuple[str, str]] = [
    ("face_forward",
     "extreme close-up head-and-shoulders portrait that fills the whole frame: the "
     "top of the head near the top edge, the chin about three-quarters of the way "
     "down, head-on, neutral expression, both eyes visible, no tilt"),
    ("body_front",
     "full body from head to feet, facing the camera, relaxed A-pose, arms clear of "
     "the torso silhouette, the whole figure inside the frame"),
    ("face_threequarter",
     "close-up head-and-shoulders portrait filling the whole frame, three-quarter "
     "view turned slightly to the left, same light, same neutral expression"),
    ("body_threequarter",
     "full body from head to feet in a three-quarter view, outfit fully readable, "
     "the whole figure inside the frame"),
    ("face_profile",
     "close-up head-and-shoulders portrait filling the whole frame, true side "
     "profile facing left, the nose line silhouetted, same light"),
    ("body_side",
     "full-body side profile facing left, standing on both feet, head to feet inside "
     "the frame"),
    ("body_back",
     "full body from head to feet seen from behind, hair mass and the back of the "
     "outfit, no face visible"),
    ("detail_outfit",
     "close crop of the head, shoulders and signature accessories, filling the "
     "frame, the outfit fabric clearly readable"),
]

# The cast is the book's, not this script's: identity comes from
# Scripts/book.yaml (see book_config.py), so one edit pins a character.
from book_config import CAST as CHARACTERS  # noqa: E402


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def view_prompt(character: str, view: str, instruction: str) -> str:
    entry = CHARACTERS[character]
    return (
        f"{ART}\n\n"
        f"Character (identical in every view): {entry['descriptors']}.\n\n"
        f"View: {instruction}. One single figure, centred, standing on a shared "
        f"baseline, the whole figure inside a 2:3 portrait frame with a little headroom."
    )


def png_dir(character: str) -> str:
    return os.path.join(CAST_DIR, character, "png")


# --------------------------------------------------------------------------- #
# render
# --------------------------------------------------------------------------- #
def render_view(character: str, view: str, instruction: str, server: str,
                timeout: float) -> str:
    """One render per view: separate batches give incremental progress and keep
    a failed view from discarding the whole sheet."""
    entry = CHARACTERS[character]
    payload = {
        "prompts": [view_prompt(character, view, instruction)],
        "model": "zimage-turbo",
        "style": "artistic",
        "width": RENDER_W,
        "height": RENDER_H,
        "auto_enhance": False,
        "negative_prompt": (
            "text, lettering, watermark, signature, logo, words, scene, landscape, "
            "multiple characters, duplicate figure, extra limbs, deformed hands"
        ),
        "subject_ids": [entry["subject_id"]],
        "display_name": f"cast {character} {view}",
    }
    response = rp.http_json(server + "/api/batch-image/generate/prompts", payload, timeout=120)
    batch = (response.get("data") or {}).get("batch_id")
    if not batch:
        die(f"{character}/{view}: no batch id in {response}")
    data = rp.poll(batch, server, timeout)
    if data.get("status") != "completed":
        die(f"{character}/{view}: {data.get('status')}: {data.get('error')}")
    return rp.first_image(data, server, batch)


def render_character(character: str, server: str, timeout: float, force: bool = False,
                     only: list[str] | None = None) -> None:
    out = png_dir(character)
    os.makedirs(out, exist_ok=True)
    for name, instruction in VIEWS:
        if only and name not in only:
            continue
        dst = os.path.join(out, f"{name}.png")
        if os.path.exists(dst) and not force:
            print(f"    {character}/{name}.png exists")
            continue
        src = render_view(character, name, instruction, server, timeout)
        with Image.open(src) as im:
            im.convert("RGB").save(dst)
        print(f"    {character}/{name}.png")


# --------------------------------------------------------------------------- #
# assemble
# --------------------------------------------------------------------------- #
def sheet_yaml(character: str) -> dict[str, Any]:
    entry = CHARACTERS[character]
    layers = []
    for name, instruction in VIEWS:
        layers.append(
            {
                "name": name,
                # the caption names the view; the instruction stays in VIEWS
                "view": name,
                "image": f"cast/{character}/png/{name}.png",
                "x": LAYER_X,
                "y": LAYER_Y,
                "width": CANVAS["width"],
                "height": CANVAS["height"],
                "fit": "contain",
            }
        )
    return {
        "canvas": dict(CANVAS),
        "character": character,
        "subject_id": entry["subject_id"],
        "trigger": entry["trigger"],
        "descriptors": entry["descriptors"],
        "caption_template": "{trigger}, {descriptors}, {view}, plain background",
        "layers": layers,
    }


def assemble(character: str) -> str:
    missing = [n for n, _ in VIEWS if not os.path.exists(os.path.join(png_dir(character), f"{n}.png"))]
    if missing:
        die(f"{character}: missing views {missing} — run --render {character} first")
    path = os.path.join(CAST_DIR, f"{character}.layers.yaml")
    with open(path, "w", encoding="utf-8") as fh:
        yaml.safe_dump(sheet_yaml(character), fh, sort_keys=False, allow_unicode=True, width=100)
    print(f"  wrote {os.path.relpath(path, REPO_ROOT)}")
    return path


# --------------------------------------------------------------------------- #
# cli
# --------------------------------------------------------------------------- #
def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("characters", nargs="*", help="hero friend (default: all)")
    parser.add_argument("--render", action="store_true", help="generate the 8 view renders")
    parser.add_argument("--assemble", action="store_true", help="write cast/<char>.layers.yaml")
    parser.add_argument("--dataset", action="store_true", help="also export datasets/<trigger>/")
    parser.add_argument("--server", default=rp.DEFAULT_SERVER)
    parser.add_argument("--timeout", type=float, default=1800.0)
    parser.add_argument("--force", action="store_true", help="re-render existing views")
    parser.add_argument(
        "--views",
        default=None,
        help="comma-separated view names to render (default: all eight)",
    )
    args = parser.parse_args(argv)

    characters = args.characters or list(CHARACTERS)
    unknown = [c for c in characters if c not in CHARACTERS]
    if unknown:
        die(f"unknown character(s): {', '.join(unknown)}")
    if not (args.render or args.assemble or args.dataset):
        parser.error("pass --render, --assemble and/or --dataset")

    if args.render:
        for character in characters:
            only = [v.strip() for v in args.views.split(",")] if args.views else None
            render_character(character, args.server, args.timeout, args.force, only)

    if args.assemble or args.dataset:
        from create_layered_psd import main as psd_main

        for character in characters:
            path = assemble(character)
            psd_args = [os.path.relpath(path, REPO_ROOT)]
            psd_args.append(os.path.join(CAST_DIR, f"{character}.psd"))
            if args.dataset:
                psd_args.append("--dataset")
            if psd_main(psd_args) != 0:
                die(f"{character}: PSD build failed")

    print("done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
