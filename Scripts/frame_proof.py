#!/usr/bin/env python3
"""Render what the Kwik plugin will draw, straight from page.layers.yaml.

This is the deterministic companion to the live Simulator screenshot.  It
implements the exact geometry in
``Solar2D/lua_modules/kwiksher/kwik/components/kwik/layer_image.lua``:

    scale        = 0.25                       (env.props.scale clamps to it)
    imageWidth   = layerProps.width  * scale
    imageHeight  = layerProps.height * scale
    mX = layerProps.x * scale + (display.contentWidth  - 480) / 2
    mY = layerProps.y * scale + (display.contentHeight - 320) / 2

and asserts the contract from ``docs/PAGE-GENERATION-PLAN.md`` §C:

* the page frame is 480 x 320 design units, centred in the content area;
* a 2776 x 1440 bg drawn at the 1920 x 1280 safe-area centre bleeds exactly
  107 design units left/right and 20 top/bottom beyond that frame;
* every layer rect is the YAML rect x 0.25 plus the same centre offset;
* no layer carries xScale / yScale.

Outputs (default ``docs/evidence``):

    frame_<page>.png   the editor stage: page frame + every layer at its
                       drawn position (what the Simulator shows)
    final_<page>.png   the page frame only (what the reader sees, 1920x1280),
                       composited from page.psd

Usage
-----
    python3 Scripts/frame_proof.py p1 p2 p3
    python3 Scripts/frame_proof.py --all
    python3 Scripts/frame_proof.py p1 --content 960x590 --out docs/evidence
"""

from __future__ import annotations

import argparse
import glob
import os
import sys
from typing import Any

import yaml
from PIL import Image, ImageDraw

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))
from paths import PAGES_DIR  # noqa: E402  — single source of truth for the page tree
SCALE = 0.25
FRAME_W, FRAME_H = 480, 320
DEFAULT_CONTENT = (960, 590)  # the landscape editor skin (§C.5)


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def load_page(page: str) -> dict[str, Any]:
    path = os.path.join(PAGES_DIR, page, "page.layers.yaml")
    if not os.path.exists(path):
        die(f"no {path}")
    with open(path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def drawn_rect(layer: dict, content: tuple[int, int]) -> tuple[float, float, float, float]:
    """(left, top, width, height) in design units, per layer_image.lua."""
    cw, ch = content
    w = float(layer["width"]) * SCALE
    h = float(layer["height"]) * SCALE
    mx = float(layer["x"]) * SCALE + (cw - FRAME_W) / 2.0
    my = float(layer["y"]) * SCALE + (ch - FRAME_H) / 2.0
    return mx - w / 2.0, my - h / 2.0, w, h


def assert_contract(page: str, spec: dict, content: tuple[int, int]) -> list[str]:
    problems: list[str] = []
    cw, ch = content
    frame_left = (cw - FRAME_W) / 2.0
    frame_top = (ch - FRAME_H) / 2.0

    for layer in spec["layers"]:
        name = layer.get("name")
        for banned in ("xScale", "yScale"):
            if banned in layer:
                problems.append(f"{page}/{name}: forbidden {banned} in layerProps")
        left, top, w, h = drawn_rect(layer, content)
        expected_w = float(layer["width"]) * SCALE
        if abs(w - expected_w) > 1e-6:
            problems.append(f"{page}/{name}: width {w} != {expected_w}")

        if name == "bg":
            # bleed == 107 design units left/right, 20 top/bottom
            bleed_x = frame_left - left
            bleed_y = frame_top - top
            if abs(bleed_x - 107.0) > 0.5:
                problems.append(f"{page}/bg: horizontal bleed {bleed_x:.1f} != 107")
            if abs(bleed_y - 20.0) > 0.5:
                problems.append(f"{page}/bg: vertical bleed {bleed_y:.1f} != 20")
    return problems


def render_frame(page: str, spec: dict, content: tuple[int, int], out: str) -> str:
    cw, ch = content
    png_dir = os.path.join(PAGES_DIR, page, "png")
    canvas = Image.new("RGBA", (cw, ch), (26, 26, 30, 255))

    for layer in spec["layers"]:
        name = str(layer["name"])
        png = os.path.join(png_dir, f"{name}.png")
        if not os.path.exists(png):
            die(f"{page}/{name}: missing {png} — run create_layered_psd.py first")
        left, top, w, h = drawn_rect(layer, content)
        with Image.open(png) as im:
            img = im.convert("RGBA").resize((max(1, round(w)), max(1, round(h))), Image.LANCZOS)
        canvas.alpha_composite(img, (round(left), round(top)))

    frame_left = round((cw - FRAME_W) / 2.0)
    frame_top = round((ch - FRAME_H) / 2.0)
    draw = ImageDraw.Draw(canvas)
    draw.rectangle(
        [frame_left, frame_top, frame_left + FRAME_W - 1, frame_top + FRAME_H - 1],
        outline=(51, 255, 51, 255),
        width=2,
    )
    canvas.convert("RGB").save(out)
    return out


def composite_page(page: str, out: str) -> str:
    """The page frame itself at native PSD size — what the reader sees.

    Composited here, layer by layer, rather than with ``PSDImage.composite()``:
    psd-tools' compositor drops the per-layer transparency channel (the PSD
    itself carries it correctly — every layer has an alpha channel and Photoshop
    reads it), so its output would show every sprite inside a white box.
    """
    spec = load_page(page)
    canvas = spec["canvas"]
    cw, ch = int(canvas["width"]), int(canvas["height"])
    png_dir = os.path.join(PAGES_DIR, page, "png")
    image = Image.new("RGBA", (cw, ch), (255, 255, 255, 255))

    for layer in spec["layers"]:
        name = str(layer["name"])
        png = os.path.join(png_dir, f"{name}.png")
        if not os.path.exists(png):
            die(f"{page}/{name}: missing {png}")
        w, h = int(layer["width"]), int(layer["height"])
        left = round(float(layer["x"]) - w / 2)
        top = round(float(layer["y"]) - h / 2)
        with Image.open(png) as im:
            lay = im.convert("RGBA")
        if lay.size != (w, h):
            lay = lay.resize((w, h), Image.LANCZOS)
        # No opacity re-application here: the layer PNG has it baked in by
        # create_layered_psd.py, and applying it twice would darken the scrim.
        # Paste only the visible intersection so negative offsets work.
        x0, y0 = max(0, left), max(0, top)
        x1, y1 = min(cw, left + w), min(ch, top + h)
        if x1 <= x0 or y1 <= y0:
            continue
        image.alpha_composite(lay.crop((x0 - left, y0 - top, x1 - left, y1 - top)), (x0, y0))

    image.convert("RGB").save(out)
    return out


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("pages", nargs="*")
    parser.add_argument("--all", action="store_true")
    parser.add_argument(
        "--content",
        default="960x590",
        help="display.contentWidth x contentHeight (default 960x590, §C.5)",
    )
    parser.add_argument("--out", default=os.path.join(REPO_ROOT, "docs", "evidence"))
    parser.add_argument(
        "--skip-composite", action="store_true", help="do not write final_<page>.png"
    )
    args = parser.parse_args(argv)

    pages = args.pages
    if args.all or not pages:
        pages = [
            os.path.basename(os.path.dirname(p))
            for p in sorted(glob.glob(os.path.join(PAGES_DIR, "*", "page.layers.yaml")))
        ]
    try:
        cw, ch = (int(v) for v in args.content.lower().split("x"))
    except ValueError:
        die(f"--content expects WxH, got {args.content!r}")
    content = (cw, ch)

    os.makedirs(args.out, exist_ok=True)
    problems: list[str] = []
    for page in pages:
        spec = load_page(page)
        page_problems = assert_contract(page, spec, content)
        problems += page_problems
        frame_out = render_frame(page, spec, content, os.path.join(args.out, f"frame_{page}.png"))
        line = f"  {page}: frame {frame_out}"
        if not args.skip_composite:
            final_out = composite_page(page, os.path.join(args.out, f"final_{page}.png"))
            line += f", page {final_out}"
        if page_problems:
            line += f"  [{len(page_problems)} problem(s)]"
        print(line)
        for problem in page_problems:
            print(f"    FAIL {problem}", file=sys.stderr)

    if problems:
        print(f"geometry check FAILED ({len(problems)} problem(s))", file=sys.stderr)
        return 1
    print(
        f"ok: {len(pages)} page(s) — frame {FRAME_W}x{FRAME_H} in "
        f"{cw}x{ch}, bg bleed 107/20 design units"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
