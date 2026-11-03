#!/usr/bin/env python3
"""Cast reference sheets -> Kwik spritesheets, in the three formats the plugin reads.

One packer, one PNG, three metadata contracts. The point of the book's `sprite`,
`sprite_texturepacker` and `sprite_animate` pages is that the same image arrives through
three different loaders; this script makes that image and all three sidecars from one
frame table, so any difference on screen is a difference in the loader, not the art.

    .venv/bin/python Scripts/design_sheets.py --pack --install-cast
    .venv/bin/python Scripts/design_sheets.py --check
    .venv/bin/python Scripts/design_sheets.py --preview

Input:  Photoshop/<book>/cast/<character>/png/<view>.png      (1024x1536 RGBA, opaque cream bg)
Output: Solar2D/App/<book>_design/assets/sprites/<name>.{png,lua,json,uniform.yaml,png.md5}
        Solar2D/App/<book>_design/assets/images/image/<character>.png   (--install-cast)
        Photoshop/<book>_design/sheets.yaml         authored source of truth
        Photoshop/<book>_design/sheets.md           frame manifest (review + gate)

Why the background is keyed out: the cast renders have an opaque cream backdrop. Leaving it
in would put a cream rectangle behind every frame of the sprite (the pages key it too — see
`transparent_color: auto` / `transparent_tolerance: 40` in `Photoshop/<book>/p1/page.layers.yaml`).
The key is done at full resolution and the resize happens in **premultiplied** alpha, so the
outer edge does not keep a cream fringe.

Padding is 0 on purpose: with 4 x 320 = 1280 exactly, a frame rect equals its source rect, so
none of the three loaders has to scale a frame. A 2 px gutter would have forced a 316 x 476
packed rect inside a 320 x 480 cell and re-introduced resampling.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys

try:
    import numpy as np
    import yaml
    from PIL import Image
except ImportError:  # pragma: no cover
    sys.exit("numpy/PyYAML/Pillow are required: run with .venv/bin/python")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from book_config import DESIGN_BOOK, CHARACTERS
BOOK = DESIGN_BOOK
SOURCE = os.path.join(REPO, "Photoshop", BOOK)
CAST = os.path.join(SOURCE, "cast")
SOURCE_REL = os.path.relpath(SOURCE, REPO)
ASSETS = os.path.join(REPO, "Solar2D", "App", BOOK, "assets")
SPRITES = os.path.join(ASSETS, "sprites")
IMAGES = os.path.join(ASSETS, "images", "image")

CONFIG = os.path.join(SOURCE, "sheets.yaml")
MANIFEST = os.path.join(SOURCE, "sheets.md")

VIEWS = [
    "face_forward",
    "body_front",
    "face_threequarter",
    "body_threequarter",
    "face_profile",
    "body_side",
    "body_back",
    "detail_outfit",
]

FRAME_W, FRAME_H = 320, 480
COLUMNS, ROWS = 4, 2
PADDING = 0
TOLERANCE = 40
SHEETS = [{"name": f"{tag}_views", "character": tag} for tag in CHARACTERS]

DEFAULT_CONFIG = {
    "frame": {"width": FRAME_W, "height": FRAME_H},
    "layout": {"columns": COLUMNS, "rows": ROWS, "padding": PADDING},
    "background": {"mode": "key", "tolerance": TOLERANCE},
    "views": VIEWS,
    "sheets": SHEETS,
    "source": "Photoshop/<book>/cast",
    "out": "Solar2D/App/<book>_design/assets/sprites",
}


def rel(path: str) -> str:
    return os.path.relpath(path, REPO)


def load_config() -> dict:
    if not os.path.exists(CONFIG):
        return DEFAULT_CONFIG
    with open(CONFIG, encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def write_config() -> None:
    os.makedirs(SOURCE, exist_ok=True)
    header = (
        "# Cast reference sheets -> spritesheet. Authored source of truth for\n"
        "# Scripts/design_sheets.py. Edit here, then: --pack\n"
        "# padding is 0 so a frame rect equals its source rect (4x320 = 1280); see the script docstring.\n"
    )
    with open(CONFIG, "w", encoding="utf-8") as fh:
        fh.write(header)
        yaml.safe_dump(DEFAULT_CONFIG, fh, sort_keys=False, allow_unicode=True)


# ---- keying + resize -------------------------------------------------------


def keyed(path: str, tolerance: int) -> Image.Image:
    """Load a cast render and drop its opaque backdrop, in premultiplied space."""
    with Image.open(path) as raw:
        im = raw.convert("RGBA")
    arr = np.asarray(im, dtype=np.float32)
    h, w, _ = arr.shape

    corners = np.array(
        [arr[0, 0, :3], arr[0, w - 1, :3], arr[h - 1, 0, :3], arr[h - 1, w - 1, :3]],
        dtype=np.float32,
    )
    bg = np.median(corners, axis=0)
    dist = np.max(np.abs(arr[:, :, :3] - bg[None, None, :]), axis=2)
    background = dist <= tolerance

    alpha = np.where(background, 0.0, 255.0).astype(np.float32)
    rgb = arr[:, :, :3] * (alpha[:, :, None] / 255.0)
    return rgb, alpha


def resize_premultiplied(rgb: np.ndarray, alpha: np.ndarray, size: tuple[int, int]) -> Image.Image:
    w, h = size
    alpha_im = Image.fromarray(alpha.astype(np.uint8), "L").resize((w, h), Image.LANCZOS)
    a = np.asarray(alpha_im, dtype=np.float32)

    channels = []
    for c in range(3):
        channel = Image.fromarray(rgb[:, :, c].astype(np.float32), "F").resize((w, h), Image.LANCZOS)
        channels.append(np.asarray(channel, dtype=np.float32))
    premul = np.stack(channels, axis=2)

    # unpremultiply after resampling, so the edge fades instead of going cream
    scale = np.where(a > 0.5, 255.0 / np.maximum(a, 1.0), 0.0)
    straight = np.clip(premul * scale[:, :, None], 0, 255)

    out = np.dstack([straight, a]).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


# ---- packing ---------------------------------------------------------------


def pack_sheet(sheet: dict, cfg: dict) -> tuple[Image.Image, list[dict]]:
    fw = int(cfg["frame"]["width"])
    fh = int(cfg["frame"]["height"])
    cols = int(cfg["layout"]["columns"])
    rows = int(cfg["layout"]["rows"])
    pad = int(cfg["layout"].get("padding", 0))
    tol = int(cfg["background"].get("tolerance", TOLERANCE))
    character = sheet["character"]

    canvas = Image.new("RGBA", (cols * fw + pad * 2, rows * fh + pad * 2), (0, 0, 0, 0))
    frames: list[dict] = []

    for index, view in enumerate(cfg["views"]):
        src = os.path.join(CAST, character, "png", view + ".png")
        if not os.path.exists(src):
            sys.exit(f"missing cast view: {rel(src)}")
        rgb, alpha = keyed(src, tol)
        frame = resize_premultiplied(rgb, alpha, (fw, fh))

        col = index % cols
        row = index // cols
        x = pad + col * fw
        y = pad + row * fh
        canvas.paste(frame, (x, y), frame)
        frames.append(
            {
                "index": index + 1,
                "view": view,
                "x": x,
                "y": y,
                "width": fw,
                "height": fh,
            }
        )
    return canvas, frames


def lua_sheet(frames: list[dict]) -> str:
    lines = [
        "-- generated by Scripts/design_sheets.py — do not edit; re-run --pack.",
        "-- TexturePacker-compatible sheetInfo module (what layer_sprite.lua requires).",
        "",
        "local sheetData = {}",
        "",
        "sheetData.frames = {",
    ]
    for f in frames:
        lines.append("\t{")
        lines.append(f"\t\tx = {f['x']},")
        lines.append(f"\t\ty = {f['y']},")
        lines.append(f"\t\twidth = {f['width']},")
        lines.append(f"\t\theight = {f['height']},")
        lines.append("\t\tsourceX = 0,")
        lines.append("\t\tsourceY = 0,")
        lines.append(f"\t\tsourceWidth = {f['width']},")
        lines.append(f"\t\tsourceHeight = {f['height']},")
        lines.append("\t},")
    lines += ["}", "", "return sheetData", ""]
    return "\n".join(lines)


def json_sheet(name: str, frames: list[dict], size: tuple[int, int]) -> str:
    doc = {
        "frames": [
            {
                "filename": f"{name}_{f['index']:02d}_{f['view']}",
                "frame": {"x": f["x"], "y": f["y"], "w": f["width"], "h": f["height"]},
                "spriteSourceSize": {"x": 0, "y": 0, "w": f["width"], "h": f["height"]},
            }
            for f in frames
        ],
        "meta": {
            "app": "Scripts/design_sheets.py",
            "image": name + ".png",
            "format": "RGBA8888",
            "size": {"w": size[0], "h": size[1]},
            "scale": "1",
        },
    }
    return json.dumps(doc, indent=2) + "\n"


def uniform_sheet(cfg: dict, frames: list[dict]) -> str:
    doc = {
        "numFrames": len(frames),
        "width": int(cfg["frame"]["width"]),
        "height": int(cfg["frame"]["height"]),
        "sheetContentWidth": int(cfg["layout"]["columns"]) * int(cfg["frame"]["width"]),
        "sheetContentHeight": int(cfg["layout"]["rows"]) * int(cfg["frame"]["height"]),
    }
    return "\n".join(f"{k}: {v}" for k, v in doc.items()) + "\n"


def md5(path: str) -> str:
    with open(path, "rb") as fh:
        return hashlib.md5(fh.read()).hexdigest()


def pack_all(cfg: dict, install_cast: bool) -> list[dict]:
    os.makedirs(SPRITES, exist_ok=True)
    os.makedirs(SOURCE, exist_ok=True)
    report = []

    for sheet in cfg["sheets"]:
        name = sheet["name"]
        canvas, frames = pack_sheet(sheet, cfg)
        png = os.path.join(SPRITES, name + ".png")
        canvas.save(png, "PNG", optimize=True)

        with open(os.path.join(SPRITES, name + ".lua"), "w", encoding="utf-8") as fh:
            fh.write(lua_sheet(frames))
        with open(os.path.join(SPRITES, name + ".json"), "w", encoding="utf-8") as fh:
            fh.write(json_sheet(name, frames, canvas.size))
        with open(os.path.join(SPRITES, name + ".uniform.yaml"), "w", encoding="utf-8") as fh:
            fh.write(uniform_sheet(cfg, frames))
        with open(os.path.join(SPRITES, name + ".png.md5"), "w", encoding="utf-8") as fh:
            fh.write(f"{md5(png)}  {name}.png\n")

        report.append({"name": name, "character": sheet["character"], "frames": frames, "md5": md5(png), "size": canvas.size})
        print(f"  ok sprites/{name}.png {canvas.size[0]}x{canvas.size[1]} · {len(frames)} frames · {md5(png)[:8]}")

    if install_cast:
        os.makedirs(IMAGES, exist_ok=True)
        for sheet in cfg["sheets"]:
            character = sheet["character"]
            src = os.path.join(CAST, character, "png", "body_front.png")
            dst = os.path.join(IMAGES, character + ".png")
            with open(src, "rb") as fh_in, open(dst, "wb") as fh_out:
                fh_out.write(fh_in.read())
            print(f"  ok images/image/{character}.png (copy of cast body_front)")

    write_manifest(report, cfg)
    return report


def write_manifest(report: list[dict], cfg: dict) -> None:
    lines = [
        "# Cast spritesheet manifest",
        "",
        f"Generated by `Scripts/design_sheets.py` from `{cfg.get('source', SOURCE_REL)}`.",
        "Source of truth: `Photoshop/<book>_design/sheets.yaml`. Do not edit by hand.",
        "",
        f"Frame {cfg['frame']['width']}x{cfg['frame']['height']} · grid "
        f"{cfg['layout']['columns']}x{cfg['layout']['rows']} · padding {cfg['layout'].get('padding', 0)} · "
        f"background key tolerance {cfg['background'].get('tolerance', TOLERANCE)}",
        "",
        "| sheet | # | character | view | packed rect | sheet md5 |",
        "|---|---|---|---|---|---|",
    ]
    seen: set[str] = set()
    for sheet in report:
        name = sheet["name"]
        for f in sheet["frames"]:
            digest = sheet["md5"] if name not in seen else ""
            seen.add(name)
            lines.append(
                f"| `{name}` | {f['index']} | {sheet['character']} | `{f['view']}` | "
                f"{f['x']},{f['y']} {f['width']}x{f['height']} | {digest} |"
            )
    lines.append("")
    with open(MANIFEST, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))


# ---- check -----------------------------------------------------------------


def check(cfg: dict) -> int:
    problems: list[str] = []
    cols = int(cfg["layout"]["columns"])
    rows = int(cfg["layout"]["rows"])
    frw = int(cfg["frame"]["width"])
    frh = int(cfg["frame"]["height"])
    expect_size = (cols * frw, rows * frh)

    if not os.path.exists(MANIFEST):
        problems.append("missing Photoshop/<book>_design/sheets.md")
    if not os.path.exists(CONFIG):
        problems.append("missing Photoshop/<book>_design/sheets.yaml")

    for sheet in cfg["sheets"]:
        name = sheet["name"]
        png = os.path.join(SPRITES, name + ".png")
        if not os.path.exists(png):
            problems.append(f"missing sprites/{name}.png")
            continue
        with Image.open(png) as im:
            if im.size != expect_size:
                problems.append(f"{name}.png: {im.size} != {expect_size}")
            if im.mode != "RGBA":
                problems.append(f"{name}.png: mode {im.mode} != RGBA")

        recorded = None
        md5_path = os.path.join(SPRITES, name + ".png.md5")
        if not os.path.exists(md5_path):
            problems.append(f"missing sprites/{name}.png.md5")
        else:
            with open(md5_path, encoding="utf-8") as fh:
                recorded = fh.read().split()[0]
            if recorded != md5(png):
                problems.append(f"{name}.png md5 drift")

        lua = os.path.join(SPRITES, name + ".lua")
        if not os.path.exists(lua):
            problems.append(f"missing sprites/{name}.lua")
        else:
            with open(lua, encoding="utf-8") as fh:
                text = fh.read()
            if text.count("sourceWidth") != len(cfg["views"]):
                problems.append(f"{name}.lua: {text.count('sourceWidth')} frames != {len(cfg['views'])}")
            if "return sheetData" not in text:
                problems.append(f"{name}.lua: no `return sheetData`")
            for f_expected in range(len(cfg["views"])):
                x = (f_expected % cols) * frw
                y = (f_expected // cols) * frh
                if f"x = {x}," not in text or f"y = {y}," not in text:
                    problems.append(f"{name}.lua: frame {f_expected + 1} rect {x},{y} missing")

        js = os.path.join(SPRITES, name + ".json")
        if not os.path.exists(js):
            problems.append(f"missing sprites/{name}.json")
        else:
            with open(js, encoding="utf-8") as fh:
                doc = json.load(fh)
            if len(doc.get("frames", [])) != len(cfg["views"]):
                problems.append(f"{name}.json: {len(doc.get('frames', []))} frames")
            if doc.get("meta", {}).get("size") != {"w": expect_size[0], "h": expect_size[1]}:
                problems.append(f"{name}.json: meta.size wrong")
            first = doc["frames"][0]
            for key in ("frame", "spriteSourceSize"):
                if key not in first:
                    problems.append(f"{name}.json: frame entry missing {key}")

        uni = os.path.join(SPRITES, name + ".uniform.yaml")
        if not os.path.exists(uni):
            problems.append(f"missing sprites/{name}.uniform.yaml")
        else:
            with open(uni, encoding="utf-8") as fh:
                doc = yaml.safe_load(fh)
            want = {
                "numFrames": len(cfg["views"]),
                "width": frw,
                "height": frh,
                "sheetContentWidth": expect_size[0],
                "sheetContentHeight": expect_size[1],
            }
            if doc != want:
                problems.append(f"{name}.uniform.yaml: {doc} != {want}")

        cast_png = os.path.join(IMAGES, sheet["character"] + ".png")
        if not os.path.exists(cast_png):
            problems.append(f"missing images/image/{sheet['character']}.png (run --install-cast)")

    for p in problems:
        print(f"FAIL {p}")
    if problems:
        return 3
    print(f"ok sheets: {len(cfg['sheets'])} sheets x {len(cfg['views'])} frames, {expect_size[0]}x{expect_size[1]}")
    return 0


# ---- preview ---------------------------------------------------------------


def preview(cfg: dict) -> int:
    report = []
    for sheet in cfg["sheets"]:
        png = os.path.join(SPRITES, sheet["name"] + ".png")
        if not os.path.exists(png):
            sys.exit(f"missing {rel(png)} — run --pack first")
        with Image.open(png) as im:
            report.append((sheet["name"], im.convert("RGB")))
    width = max(im.width for _, im in report)
    height = sum(im.height for _, im in report) + 40 * len(report)
    contact = Image.new("RGB", (width, height), (242, 232, 216))
    y = 0
    for _, im in report:
        contact.paste(im, (0, y))
        y += im.height + 40
    path = os.path.join(SOURCE, "preview_contact_sheet.png")
    contact.save(path, "PNG", optimize=True)
    print(f"ok {rel(path)} {contact.size[0]}x{contact.size[1]}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--pack", action="store_true", help="build all three sheets")
    ap.add_argument("--install-cast", action="store_true", help="copy body_front.png per character")
    ap.add_argument("--check", action="store_true", help="verify sheets, sidecars and md5s")
    ap.add_argument("--preview", action="store_true", help="write a 1:1 contact sheet")
    ap.add_argument("--write-config", action="store_true", help="(re)write sheets.yaml defaults")
    args = ap.parse_args()

    if args.write_config or not os.path.exists(CONFIG):
        write_config()
        print(f"ok {rel(CONFIG)}")

    cfg = load_config()
    if args.check:
        return check(cfg)
    if args.preview:
        return preview(cfg)
    if args.pack:
        pack_all(cfg, install_cast=args.install_cast)
        return 0
    ap.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
