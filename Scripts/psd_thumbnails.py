#!/usr/bin/env python3
"""Write a small preview PNG for every page, for the exporter panel's file list.

The Photoshop panel shows a thumbnail per `.psd` in "Photoshop Files". Its first
source is the preview Photoshop embeds in the PSD itself, but a PSD written by
`create_layered_psd.py` (psd-tools) carries only an ICC profile — no thumbnail
resource — so every row in a generated book would be a placeholder. The panel
therefore falls back to a preview file *next to* the page, and this script is what
produces it:

    Photoshop/<book>/<page>/thumbnail.jpg      384 px wide, alpha flattened

Composited here, layer by layer, from `png/<layer>.png` — the same inputs and the
same arithmetic as `frame_proof.py`'s `composite_page()` — rather than with
`PSDImage.composite()`, which drops the per-layer transparency (see that file's
note) and would put every sprite in a white box. Building from the layer PNGs also
means the PSD never has to be parsed at all, so this is cheap enough to run on
every build.

Usage
-----
    Scripts/psd_thumbnails.py            # every page that has page.layers.yaml
    Scripts/psd_thumbnails.py p1 p3      # just these
    Scripts/psd_thumbnails.py --width 512
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any

import yaml
from PIL import Image

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))
from paths import PAGES_DIR  # noqa: E402  — single source of truth for the page tree

DEFAULT_WIDTH = 384
# JPEG, not PNG: the plates are photographic, and the same preview is 170 KB as
# PNG versus ~25 KB at quality 82 — it is a 56x38 px row in the panel, so the
# difference buys nothing and costs a file read.
JPEG_QUALITY = 82
BACKGROUND = (255, 255, 255, 255)


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def load_page(page: str) -> dict[str, Any]:
    path = os.path.join(PAGES_DIR, page, "page.layers.yaml")
    if not os.path.exists(path):
        die(f"no {path}")
    with open(path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def composite(page: str, spec: dict[str, Any]) -> Image.Image:
    """The page frame at native PSD size, alpha flattened onto white."""
    canvas = spec["canvas"]
    cw, ch = int(canvas["width"]), int(canvas["height"])
    png_dir = os.path.join(PAGES_DIR, page, "png")
    image = Image.new("RGBA", (cw, ch), BACKGROUND)

    for layer in spec["layers"]:
        name = str(layer["name"])
        png = os.path.join(png_dir, f"{name}.png")
        if not os.path.exists(png):
            die(f"{page}/{name}: missing {png} — run create_layered_psd.py first")
        w, h = int(layer["width"]), int(layer["height"])
        left = round(float(layer["x"]) - w / 2)
        top = round(float(layer["y"]) - h / 2)
        with Image.open(png) as im:
            lay = im.convert("RGBA")
        if lay.size != (w, h):
            lay = lay.resize((w, h), Image.LANCZOS)
        # Paste only the visible intersection, so negative offsets work.
        x0, y0 = max(0, left), max(0, top)
        x1, y1 = min(cw, left + w), min(ch, top + h)
        if x1 <= x0 or y1 <= y0:
            continue
        image.alpha_composite(lay.crop((x0 - left, y0 - top, x1 - left, y1 - top)), (x0, y0))

    return image


def write_thumbnail(page: str, width: int, quality: int = JPEG_QUALITY) -> tuple[str, int]:
    spec = load_page(page)
    image = composite(page, spec)

    scale = width / float(image.width)
    size = (width, max(1, round(image.height * scale)))
    thumb = image.convert("RGB").resize(size, Image.LANCZOS)

    out = os.path.join(PAGES_DIR, page, "thumbnail.jpg")
    thumb.save(out, format="JPEG", quality=quality, optimize=True)
    return out, os.path.getsize(out)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("pages", nargs="*", help="page names (default: every page)")
    parser.add_argument("--width", type=int, default=DEFAULT_WIDTH, help="thumbnail width in pixels")
    parser.add_argument("--quality", type=int, default=JPEG_QUALITY, help="JPEG quality (1-100)")
    args = parser.parse_args(argv)

    if args.width < 64 or args.width > 2048:
        die("--width must be between 64 and 2048")

    pages = args.pages
    if not pages:
        pages = sorted(
            d for d in os.listdir(PAGES_DIR)
            if os.path.exists(os.path.join(PAGES_DIR, d, "page.layers.yaml"))
        )
    if not pages:
        die(f"no pages under {PAGES_DIR}")

    total = 0
    for page in pages:
        out, size = write_thumbnail(page, args.width, args.quality)
        total += size
        print(f"  {page}: {os.path.relpath(out, REPO_ROOT)} ({size / 1024:.1f} KB)")

    print(f"ok: {len(pages)} thumbnail(s), {total / 1024:.1f} KB total, {args.width}px wide")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
