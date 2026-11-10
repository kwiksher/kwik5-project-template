#!/usr/bin/env python3
"""Convert ``Scripts/book.fountain`` into the per-page technical model + YAMLs.

Stage 2 of the pipeline in ``docs/PAGE-GENERATION-PLAN.md`` (§B, §D, §E, §F):

    book.fountain  ->  Photoshop/<book>/<page>/page.model.md
                       Photoshop/<book>/<page>/page.layers.yaml
                       Photoshop/<book>/<page>/page.audios.yaml

Rules (§D):
* one Fountain scene = one page turn = one spread;
* ``@tag`` is the only place identity is expressed — tags map to Cast subject
  ids and LoRA triggers, which are never typed into prompts by hand;
* the HTML comment carries ``page:``, ``spread:``, ``caption:`` (and optional
  ``title:``); the printed page text is typeset as its own PSD text layer;
* ``SFX:`` / ``MUSIC:`` lines become ``page.audios.yaml`` entries.

Art provenance: a page's background is whichever of these exists first —
``Photoshop/<book>/<page>/art/bg.png`` (a new render) or the frozen V1 art under
``archive/V1``.  Phase 0 re-fits the V1 art; later phases render into
``Photoshop/<book>/<page>/art/bg.png`` and re-running this script is a no-op diff.

Usage
-----
    python3 Scripts/fountain2pages.py            # write Photoshop/<book>/
    python3 Scripts/fountain2pages.py --check    # exit 1 if Photoshop/<book>/ is stale
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import sys
from typing import Any

import yaml

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOUNTAIN = os.path.join(REPO_ROOT, "Scripts", "book.fountain")
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))
from paths import COMPONENTS_DIR, AUDIOS_DIR, ASSETS_DIR, PAGES_DIR, SPRITE_DIR as _SPRITE_DIR  # noqa: E402  — single source of truth for the page tree
# repo-relative, because page.layers.yaml records paths relative to the checkout
SPRITE_DIR = os.path.relpath(_SPRITE_DIR, REPO_ROOT)
PAGES_REL = os.path.relpath(PAGES_DIR, REPO_ROOT)

# --------------------------------------------------------------------------- #
# The book's own data lives in Scripts/book.yaml, not here: cast, art direction,
# canvas/bg contract, placement map, crops and the archive fallback all come
# from book_config, so a second book is a YAML file and not a five-file edit.
from book_config import (  # noqa: E402
    ARCHIVE_IMAGES,
    ART_DIRECTION,
    BG,
    CANVAS,
    CAST,
    CROPS,
    PLACEMENT,
)



NEGATIVE_PROMPT = (
    "text, lettering, watermark, signature, logo, title, words, letters, "
    "duplicate characters, extra limbs, deformed hands"
)

RENDER = {
    "model": "zimage-turbo",
    "style": "artistic",
    "auto_enhance": False,
    "size": "1536x1024",
    "upscale": "1920x1280",
}

TAG_RE = re.compile(r"@([a-z][a-z0-9_]*)")
SCENE_RE = re.compile(r"^(INT|EXT|EST)\.\s*(.+)$")
COMMENT_RE = re.compile(r"<!--(.*?)-->", re.S)


# --------------------------------------------------------------------------- #
# parsing
# --------------------------------------------------------------------------- #
def strip_block_comments(text: str) -> str:
    return re.sub(r"/\*.*?\*/", "", text, flags=re.S)


def parse_meta(body: str) -> dict[str, str]:
    meta: dict[str, str] = {}
    for part in body.split("|"):
        part = part.strip()
        if not part or ":" not in part:
            continue
        key, value = part.split(":", 1)
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("\"", "'"):
            value = value[1:-1]
        meta[key.strip().lower()] = value
    return meta


def parse_fountain(path: str) -> list[dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as fh:
        raw = fh.read()
    text = strip_block_comments(raw)

    scenes: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    action: list[str] = []

    def flush():
        nonlocal current, action
        if current is None:
            return
        current["action"] = " ".join(a for a in action if a).strip()
        current["tags"] = sorted(set(TAG_RE.findall(current["action"])))
        scenes.append(current)
        current, action = None, []

    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue

        # A page metadata comment may precede or follow its scene heading.
        comment = COMMENT_RE.search(stripped)
        if comment:
            meta = parse_meta(comment.group(1))
            if "page" in meta:
                if current is None:
                    current = {"meta": {}, "heading": "", "sfx": [], "music": []}
                current["meta"] = meta
            continue

        scene = SCENE_RE.match(stripped)
        if scene:
            flush()
            current = {
                "meta": {},
                "heading": f"{scene.group(1)}. {scene.group(2)}",
                "sfx": [],
                "music": [],
            }
            continue

        if current is None:
            continue  # title block / notes

        if stripped.upper().startswith("SFX:"):
            current["sfx"].append(stripped[4:].strip())
            continue
        if stripped.upper().startswith("MUSIC:"):
            current["music"].append(stripped[6:].strip())
            continue
        if stripped in ("FADE OUT.", "FADE IN:"):
            continue
        if stripped.startswith("#") or stripped.startswith("="):
            continue
        action.append(stripped)

    flush()
    return [s for s in scenes if s["meta"].get("page")]


# --------------------------------------------------------------------------- #
# art provenance
# --------------------------------------------------------------------------- #
def art_for(page: str) -> tuple[str, str]:
    """(repo-relative image path, provenance note)."""
    new_art = os.path.join(PAGES_DIR, page, "art", "bg.png")
    if os.path.exists(new_art):
        return (
            os.path.relpath(new_art, REPO_ROOT),
            f"rendered art {RENDER['model']} -> {RENDER['size']} -> upscale "
            f"{RENDER['upscale']}",
        )
    for candidate in ("bg@2x.png", "bg.png") if ARCHIVE_IMAGES else ():
        v1 = os.path.join(ARCHIVE_IMAGES, page, candidate)
        if os.path.exists(v1):
            return (
                os.path.relpath(v1, REPO_ROOT),
                "frozen V1 art, re-fitted (phase 0: no re-render)",
            )
    return (
        os.path.relpath(new_art, REPO_ROOT),
        "PENDING: render into " + os.path.relpath(new_art, REPO_ROOT),
    )


# --------------------------------------------------------------------------- #
# emitters
# --------------------------------------------------------------------------- #
def overscan_label(bg: dict[str, Any], source_size: tuple[int, int] | None = None) -> str:
    """One phrase naming how the bleed was made — the part that can be got wrong."""
    canvas_w, canvas_h = CANVAS["width"], CANVAS["height"]
    w, h = int(bg["width"]), int(bg["height"])
    side = (w - canvas_w) // 2
    vert = (h - canvas_h) // 2
    extend = str(bg.get("extend", "")).lower()
    if bg.get("crop") and source_size:
        sw, sh = source_size
        return (
            f"crop-from-larger-source (source {sw}x{sh}, page {canvas_w}x{canvas_h} "
            f"centre, bleed {w}x{h} centre, no reflection)"
        )
    if bg.get("crop"):
        return "crop (source cropped, no synthesis)"
    if w == canvas_w and h == canvas_h:
        return "none (bg is exactly the canvas, no bleed)"
    if extend == "mirror":
        return (
            f"edge-mirror (adjacent reflection, {side} px each side / "
            f"{vert} px top+bottom; the band nearest the frame repeats the "
            "frame's own edge, so the join is continuous)"
        )
    if extend == "edge":
        return f"edge-smear ({side}/{vert} px, outermost row/column stretched)"
    if extend == "transparent":
        return "transparent (bleed left transparent)"
    return f"{extend or 'layer fit'} ({w}x{h})"


def bg_provenance(page: str, bg: dict[str, Any] | None = None) -> list[str]:
    """The bg chain in one block, with sizes and md5s a reviewer can re-check.

    Provenance is worth nothing if it cannot be re-derived, so every number here
    is measured from the file on disk, not asserted from the constants above:
    art/bg.png is the 1920x1280 render, png/bg.png is the 2776x1440 overscan the
    PSD and bg.lua both use, and Scripts/asset_gate.py closes the loop by
    hashing the PSD's bg layer and the installed PNG against it.
    """
    from PIL import Image

    art = os.path.join(PAGES_DIR, page, "art", "bg.png")
    large = os.path.join(PAGES_DIR, page, "art", "bg-large.png")
    plate = os.path.join(PAGES_DIR, page, "png", "bg.png")

    def describe(path: str) -> str:
        if not os.path.exists(path):
            return "not built yet"
        with open(path, "rb") as fh:
            digest = hashlib.md5(fh.read()).hexdigest()
        with Image.open(path) as im:
            size = f"{im.width}x{im.height}"
        return f"{size}, {os.path.getsize(path)} bytes, md5 {digest}"

    large_size = None
    if os.path.exists(large):
        with Image.open(large) as im:
            large_size = (im.width, im.height)

    return [
        "- bg provenance (one larger source, two concentric crops):",
        f"  - `{PAGES_REL}/{page}/art/bg.png` — {describe(art)}",
        f"  - `{PAGES_REL}/{page}/art/bg-large.png` — {describe(large)}",
        "    — the approved 1920x1280 plate enlarged once (near-lossless, "
        "`Scripts/upscale_plates.py`); every pixel of the plate below is a real "
        "pixel of the approved art, nothing is repeated or reflected;",
        f"  - `{PAGES_REL}/{page}/png/bg.png` — {describe(plate)}",
        "    — the centre " + f"{BG['width']}x{BG['height']} crop of bg-large.png "
        f"(crop: {bg.get('crop') if bg else None}); its own centre {CANVAS['width']}x"
        f"{CANVAS['height']} is the page plate, pixel-for-pixel concentric;",
        f"    overscan: {overscan_label(bg, large_size) if bg else 'crop-from-larger-source'};",
        f"    this is the plate both the PSD `bg` layer and `bg.lua` carry "
        f"(the `{os.path.relpath(ASSETS_DIR, REPO_ROOT)}/{page}/bg.png` the Simulator loads).",
        "  - `Scripts/asset_gate.py` proves the chain: the PSD bg layer and the "
        "installed PNG must both hash to png/bg.png.",
    ]


def slug(text: str) -> str:
    words = re.findall(r"[a-z0-9]+", text.lower())
    return "_".join(words[:6]) or "audio"


def caption_layers(page: str, caption: str, title: str) -> list[dict[str, Any]]:
    layers: list[dict[str, Any]] = []
    if title:
        layers.append(
            {
                "name": "title",
                "x": CANVAS["width"] // 2,
                "y": 380,
                "width": 1600,
                "height": 320,
                "text": title,
                "font_size": 132,
                "font": "/System/Library/Fonts/Supplemental/Baskerville.ttc",
                "text_color": "#FFF8EC",
                "line_height": 1.1,
                "align": "center",
            }
        )

    if caption:
        # The caption plate is 240 px tall in a 1920x1280 page (bottom 18.75%),
        # with a wider, darker scrim: three lines of Georgia over busy grass need
        # the contrast, and the plate has to fit a full spread caption. The text
        # renderer shrinks the font if a caption still overflows its box.
        layers.append(
            {
                "name": "caption_scrim",
                "x": CANVAS["width"] // 2,
                "y": CANVAS["height"] - 140,
                "width": CANVAS["width"],
                "height": 280,
                "color": "#140E07",
                "opacity": 0.86,
                "gradient": "vertical",
            }
        )
        layers.append(
            {
                "name": "caption",
                "x": CANVAS["width"] // 2,
                "y": CANVAS["height"] - 130,
                "width": 1600,
                "height": 240,
                "text": caption,
                "font_size": 48,
                "font": "/System/Library/Fonts/Supplemental/Georgia.ttf",
                "text_color": "#FFF8EC",
                "line_height": 1.28,
                "padding_y": 16,
                "align": "center",
            }
        )
    return layers


def bg_layer(page: str) -> dict[str, Any]:
    """The one bg layer dict — 2776x1440 plate over a 1920x1280 canvas.

    Declared once so the emitted model and the emitted YAML cannot describe
    different bleed methods (they did: the model said "extend: mirror" while the
    plate was a far-side mirror tiling, which is what broke the join).
    """
    large = os.path.join(PAGES_DIR, page, "art", "bg-large.png")
    if not os.path.exists(large):
        raise SystemExit(
            f"error: {os.path.relpath(large, REPO_ROOT)} is missing — the bleed is a "
            "crop of a larger source, so it has to exist before the YAML can be "
            "emitted. Run: Scripts/upscale_plates.py --all"
        )
    from PIL import Image

    with Image.open(large) as im:
        large_w, large_h = im.size
    top = (large_h - BG["height"]) // 2
    bg: dict[str, Any] = {
        "name": "bg",
        "image": os.path.relpath(large, REPO_ROOT),
        "x": CANVAS["width"] // 2,
        "y": CANVAS["height"] // 2,
        "width": BG["width"],
        "height": BG["height"],
        # One crop out of the larger source. The per-page CROPS entry is already
        # baked into bg-large.png by upscale_plates.py, so applying it again here
        # would crop twice.
        "crop": {"top": top, "bottom": large_h - BG["height"] - top},
    }
    return bg


def placement_for(page: str) -> list[dict[str, Any]]:
    """Where the cast sits on a page, in PSD px — read from the page's own YAML.

    ``page.layers.yaml`` is where a page's geometry already lives: the PSD build
    (``create_layered_psd.py``) and the Lua emitter (``layers2lua.py``) both read
    it, so it is the source of truth for placement too. A layer whose name is a
    cast character and whose image is under ``_sprites/`` makes the page
    *layered*; a page with no such layer is *baked* (the cast is painted into the
    plate by the image model).

    The authored image path and ``flip`` are carried through rather than assumed:
    a page may name a pose still (``_sprites/<name>/<pose>.png``) and mirror it,
    and rewriting the path here would silently undo both.

    ``book.yaml``'s ``placement`` is only the bootstrap for a page whose YAML does
    not exist yet or lists no sprites.
    """
    yaml_path = os.path.join(PAGES_DIR, page, "page.layers.yaml")
    if os.path.exists(yaml_path):
        try:
            with open(yaml_path, encoding="utf-8") as fh:
                data = yaml.safe_load(fh) or {}
        except (yaml.YAMLError, OSError):
            data = {}
        found: list[dict[str, Any]] = []
        for layer in data.get("layers") or []:
            name = str(layer.get("name") or "")
            image = str(layer.get("image") or "")
            if (CAST.get(name) or {}).get("kind") != "character":
                continue
            if "_sprites" not in image and "transparent_color" not in layer:
                continue
            try:
                placed: dict[str, Any] = {
                    "name": name,
                    "image": image if "_sprites" in image else f"{SPRITE_DIR}/{name}.png",
                    "x": int(layer["x"]),
                    "y": int(layer["y"]),
                    "width": int(layer["width"]),
                    "height": int(layer["height"]),
                }
            except (KeyError, TypeError, ValueError):
                continue
            if layer.get("flip"):
                placed["flip"] = str(layer["flip"])
            found.append(placed)
        if found:
            return found
    return [
        {
            "name": entry[0],
            "image": f"{SPRITE_DIR}/{entry[0]}.png",
            "x": entry[1],
            "y": entry[2],
            "width": entry[3],
            "height": entry[4],
        }
        for entry in PLACEMENT.get(page, [])
    ]


def build_layers(page: str, caption: str, title: str) -> dict[str, Any]:
    _image, provenance = art_for(page)
    bg = bg_layer(page)
    layers: list[dict[str, Any]] = [bg]
    for placed in placement_for(page):
        layer: dict[str, Any] = {
            "name": placed["name"],
            "image": placed["image"],
            "x": placed["x"],
            "y": placed["y"],
            "width": placed["width"],
            "height": placed["height"],
            "fit": "contain",
            "transparent_color": "auto",
            "transparent_tolerance": 40,
        }
        if placed.get("flip"):
            layer["flip"] = placed["flip"]
        layers.append(layer)
    layers += caption_layers(page, caption, title)
    return {
        "canvas": dict(CANVAS),
        "provenance": provenance,
        "layers": layers,
    }


def build_audios(page: str, scene: dict[str, Any]) -> list[dict[str, str]]:
    caption = scene["meta"].get("caption", "")
    audios: list[dict[str, str]] = []
    if caption:
        audios.append(
            {"name": f"narration_{page}.wav", "description": caption}
        )
    for index, line in enumerate(scene["sfx"], 1):
        audios.append(
            {"name": f"sfx_{page}_{slug(line)}.wav", "description": line}
        )
    for index, line in enumerate(scene["music"], 1):
        audios.append(
            {"name": f"music_{page}_{index}.wav", "description": line}
        )
    return audios


def build_prompt(scene: dict[str, Any]) -> str:
    """The illustration prompt (§H): art direction + @tag descriptions + action line.

    Identity enters only through the tags, which the model step already mapped to
    Cast subject ids; triggers are applied by the backend, never typed here.
    """
    tags = scene["tags"]
    cast = [CAST[t] for t in tags if t in CAST]
    characters = "\n".join(
        f"- {c['name']}: {c['description']}" for c in cast if c["kind"] == "character"
    )
    environments = "\n".join(
        f"- {c['name']}: {c['description']}" for c in cast if c["kind"] == "environment"
    )
    parts = [ART_DIRECTION.strip()]
    if characters:
        parts.append("Characters (keep every detail identical):\n" + characters)
    if environments:
        parts.append("Setting:\n" + environments)
    def name_tag(match):
        tag = match.group(1)
        return CAST[tag]["name"] if tag in CAST else tag

    action = TAG_RE.sub(name_tag, scene["action"].strip())
    parts.append("Scene: " + action)
    parts.append(
        "Composition: the whole scene inside a 3:2 landscape frame, figures centred, "
        "nothing essential near the edges."
    )
    return "\n\n".join(parts)


def build_model(page: str, scene: dict[str, Any]) -> str:
    meta = scene["meta"]
    caption = meta.get("caption", "")
    title = meta.get("title", "")
    image, provenance = art_for(page)
    tags = scene["tags"]
    characters = [t for t in tags if CAST.get(t, {}).get("kind") == "character"]
    environments = [t for t in tags if CAST.get(t, {}).get("kind") == "environment"]
    subject_ids = sorted(
        CAST[t]["subject_id"] for t in tags if CAST.get(t, {}).get("subject_id")
    )
    spread = meta.get("spread", page)

    out: list[str] = []
    out.append(f"# {page} — {meta.get('title') or spread} — Technical Model")
    out.append("")
    out.append(
        "<!-- generated by Scripts/fountain2pages.py from Scripts/book.fountain "
        "— do not edit by hand; edit the Fountain scene and re-generate -->"
    )
    out.append("")
    out.append("## Scene Information")
    out.append(
        f"- Page: {page} · Spread: {spread} · Source: book.fountain \"{scene['heading']}\""
    )
    out.append(f"- Action: {scene['action']}")
    out.append(f"- Tags: {' '.join('@' + t for t in tags) or '(none)'}")
    out.append("")
    out.append("## Backgrounds")
    out.append("### bg")
    if environments:
        for tag in environments:
            out.append(f"- Subject: @{tag} ({CAST[tag]['subject_id']}) — {CAST[tag]['description']}")
    else:
        out.append("- Subject: none tagged; scenery carries the scene")
    out.append(f"- Source: `{image}` ({provenance})")
    out.append(
        f"- Size: {BG['width']}x{BG['height']} (overscan) · Safe composition: "
        f"{CANVAS['width']}x{CANVAS['height']} · Aspect: 1.928 / 1.5"
    )
    out.append(
        "- Plate: both sizes are centre crops of `art/bg-large.png` — the page at "
        "1920x1280, the bleed at 2776x1440 — so the outer 428 px / 80 px are real "
        "pixels of the approved art, not a reflection. Nothing essential lives there."
    )
    out.append("")
    out.append("## Characters")
    placement = {p["name"]: p for p in placement_for(page)}
    if characters:
        for tag in characters:
            entry = CAST[tag]
            out.append(f"### {tag}")
            mode = "layered" if tag in placement else "baked"
            out.append(
                f"- Cast: {entry.get('subject_id', '—')} · Trigger: {entry.get('trigger', '—')} · Mode: {mode}"
            )
            out.append(f"- Description: {entry['description']}")
            out.append("- State: as briefed in the action line")
            if tag in placement:
                p = placement[tag]
                mirror = f" · flip {p['flip']}" if p.get("flip") else ""
                out.append(
                    f"- Sprite: `{p['image']}` · Placement: centre ({p['x']}, {p['y']}), "
                    f"{p['width']}x{p['height']} PSD px · chroma-key auto{mirror}"
                )
            else:
                out.append("- Placement: baked into the bg plate")
            out.append("")
    else:
        out.append("- none (environment only)")
        out.append("")
    out.append("## Assets")
    out.append(
        f"- {PAGES_REL}/{page}/art/bg.png (rendered source: background plate"
        + (", characters removed" if placement else "")
        + ")"
    )
    out.extend(bg_provenance(page, bg_layer(page)))
    for p in placement.values():
        out.append(f"- {p['image']} (character sprite, flat backdrop keyed out)")
    out.append(f"- {PAGES_REL}/{page}/png/*.png (per-layer, from page.layers.yaml)")
    out.append(f"- {PAGES_REL}/{page}/page.psd")
    out.append(
        f"- {os.path.relpath(COMPONENTS_DIR, REPO_ROOT)}/{page}/layers/*.lua (emitted)"
    )
    out.append("")
    out.append("## Page Text")
    if caption:
        out.append(f'- Caption: "{caption}"')
        out.append(
            "- Layer: `caption` (image layer, bottom 12%, cream on 42% scrim)"
        )
    else:
        out.append("- Caption: none (cover / back cover)")
    if title:
        out.append(f'- Title lockup: "{title}" (layer `title`, upper third)')
    out.append("")
    out.append("## Audio")
    audios = build_audios(page, scene)
    if audios:
        audio_dir = AUDIOS_DIR
        for audio in audios:
            name = audio["name"]
            kind = name.split("_", 1)[0]
            if kind == "narration":
                if os.path.exists(os.path.join(audio_dir, name)):
                    status = f"generated — `assets/audios/{name}`"
                else:
                    status = "**not generated** (placeholder; run Scripts/render_audio.py)"
            else:
                status = (
                    "**not generated** (placeholder: the SFX/music backend is "
                    "CUDA-only on this machine; declared for phase 3)"
                )
            out.append(f"- `{name}`: {audio['description']} — {status}")
    else:
        out.append("- none (no caption, so no narration)")
    out.append("")
    out.append("## Prompt")
    out.append("")
    out.append("```text")
    out.append(build_prompt(scene))
    out.append("```")
    out.append("")
    out.append("## Generation")
    out.append(
        f"- Art direction: {ART_DIRECTION}"
    )
    out.append(
        f"- model: {RENDER['model']} · style: {RENDER['style']} · "
        f"auto_enhance: {str(RENDER['auto_enhance']).lower()}"
    )
    out.append(f"- negative: {NEGATIVE_PROMPT}")
    out.append(
        f"- subject_ids: {subject_ids} · size: {RENDER['size']} → upscale "
        f"{RENDER['upscale']} → bg {BG['width']}x{BG['height']} via extend"
    )
    triggers = ", ".join(
        f"{CAST[t]['trigger']}" for t in tags if t in CAST
    )
    out.append(f"- triggers applied by the backend, never typed by hand: {triggers}")
    out.append("")
    return "\n".join(out)


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def render_all() -> dict[str, dict[str, str]]:
    """page id -> {relative path: content}."""
    scenes = parse_fountain(FOUNTAIN)
    if not scenes:
        die(f"{FOUNTAIN}: no scenes with a '<!-- page: ... -->' comment found")

    files: dict[str, dict[str, str]] = {}
    for scene in scenes:
        meta = scene["meta"]
        page = meta["page"]
        caption = meta.get("caption", "")
        title = meta.get("title", "")

        layers = build_layers(page, caption, title)
        audios = build_audios(page, scene)

        files[page] = {
            "page.model.md": build_model(page, scene),
            "page.layers.yaml": yaml.safe_dump(
                layers, sort_keys=False, allow_unicode=True, width=100
            ),
            "page.audios.yaml": yaml.safe_dump(
                audios, sort_keys=False, allow_unicode=True, width=100
            ),
        }
    return files


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Fountain -> Photoshop/<book>/<page>/{page.model.md,page.layers.yaml,page.audios.yaml}"
    )
    parser.add_argument(
        "--check", action="store_true", help="write nothing; exit 1 if stale"
    )
    args = parser.parse_args(argv)

    files = render_all()
    stale: list[str] = []
    written = 0
    for page, page_files in files.items():
        for name, content in page_files.items():
            path = os.path.join(PAGES_DIR, page, name)
            current = None
            if os.path.exists(path):
                with open(path, "r", encoding="utf-8") as fh:
                    current = fh.read()
            if current == content:
                continue
            if args.check:
                stale.append(os.path.relpath(path, REPO_ROOT))
                continue
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(content)
            written += 1
            print(f"  wrote {os.path.relpath(path, REPO_ROOT)}")

    pages = ", ".join(files)
    if args.check:
        if stale:
            for path in stale:
                print(f"  FAIL stale: {path}", file=sys.stderr)
            return 1
        print(f"ok: {len(files)} pages up to date ({pages})")
        return 0

    print(f"ok: {len(files)} pages ({pages}), {written} file(s) written")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
