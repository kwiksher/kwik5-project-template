#!/usr/bin/env python3
"""Build a layered PSD plus one PNG per layer from a ``page.layers.yaml``.

This is the PSD half of the page pipeline described in
``docs/PAGE-GENERATION-PLAN.md`` (§B, §D2.5, §F, §G).  The same YAML is read by
``Scripts/layers2lua.py`` to emit the Solar2D layer files, so the Photoshop
track and the Simulator track can never drift.

Geometry contract (§C)
-----------------------
* ``x`` / ``y`` are the layer **centre** in PSD pixels, not the top-left.
* PSD pixels are 4x the plugin's 480x320 design space (``scale: 0.25``).
* A page canvas is 1920x1280 (safe area).  A ``bg`` layer is 2776x1440
  overscan, i.e. 428 px wider and 80 px taller on each side — negative PSD
  bounds are normal and are never clamped.
* No ``xScale`` / ``yScale`` is ever written; ``layerProps`` are PSD pixels
  verbatim (see ``layers2lua.py``).

Layer kinds
-----------
``image:``  an existing PNG/JPG, fitted into the layer box with
            ``fit: cover | contain | stretch`` (default ``cover``).
``color:``  a flat fill.
``text:``   text rasterised into the layer box (captions are image layers in
            the running book — never live text).

Optional keys on any kind: ``opacity`` (0..1), ``blend``/``blendMode``.

Image-only keys::

    transparent_color: auto | "#ff00ff"      # chroma key
    transparent_tolerance: 40                # 0..255, soft ramp
    fit: cover | contain | stretch
    fit_to: layer | canvas                   # canvas = fit the page safe area, then
    extend: edge | mirror | transparent      #   extend the bleed (§H)

Usage
-----
    python3 Scripts/create_layered_psd.py Photoshop/<book>/p1/page.layers.yaml
    python3 Scripts/create_layered_psd.py Photoshop/<book>/p1/page.layers.yaml --check
    python3 Scripts/create_layered_psd.py cast/<character>.layers.yaml --dataset
    python3 Scripts/create_layered_psd.py cast/<character>.layers.yaml --check --dataset

``--check``   validate only: every ``image:`` exists, every layer rect sits
              inside the canvas unless it is allowed to bleed.
``--dataset`` export ``datasets/<trigger>/<layer>.png`` + ``<layer>.txt`` and a
              ``dataset.yaml`` recording the view order, per §D2.5.

Exit codes: 0 ok, 1 check failed, 2 usage/config error.
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any

import yaml
from PIL import Image, ImageColor, ImageDraw, ImageFont
from psd_tools import PSDImage
from psd_tools.api.layers import PixelLayer

DEFAULT_CANVAS = {"width": 1920, "height": 1280, "scale": 0.25}

# Layers that are allowed to extend past the canvas.  A background bleeds by
# design (§C); the flag can also be set explicitly with ``bleed: true``.
BLEED_NAMES = {"bg", "background"}

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Georgia.ttf",
    "/System/Library/Fonts/Supplemental/Baskerville.ttc",
    "/System/Library/Fonts/Helvetica.ttc",
]


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def resolve(path: str, base: str) -> str:
    """Resolve a YAML path: absolute, relative to the YAML, then repo root."""
    if os.path.isabs(path):
        return path
    for root in (base, REPO_ROOT):
        candidate = os.path.normpath(os.path.join(root, path))
        if os.path.exists(candidate):
            return candidate
    return os.path.normpath(os.path.join(REPO_ROOT, path))


def load_spec(yaml_path: str) -> dict[str, Any]:
    with open(yaml_path, "r", encoding="utf-8") as fh:
        spec = yaml.safe_load(fh)
    if not spec:
        die(f"{yaml_path}: empty or invalid YAML")
    if isinstance(spec, list):  # legacy flat list form
        spec = {"layers": spec}
    if "layers" not in spec or not isinstance(spec["layers"], list):
        die(f"{yaml_path}: missing 'layers:' list")
    canvas = dict(DEFAULT_CANVAS)
    canvas.update(spec.get("canvas") or {})
    spec["canvas"] = canvas
    return spec


def as_rgba(img: Image.Image) -> Image.Image:
    return img.convert("RGBA")


def fit_into(img: Image.Image, w: int, h: int, fit: str) -> Image.Image:
    """Fit ``img`` into exactly ``w x h`` (cover/contain centre-crop, or stretch)."""
    img = as_rgba(img)
    fit = (fit or "cover").lower()
    sw, sh = img.size
    if fit == "stretch":
        return img.resize((w, h), Image.LANCZOS)
    if fit == "contain":
        ratio = min(w / sw, h / sh)
    elif fit == "cover":
        ratio = max(w / sw, h / sh)
    else:
        die(f"unknown fit: {fit!r} (expected cover|contain|stretch)")
    nw, nh = max(1, round(sw * ratio)), max(1, round(sh * ratio))
    resized = img.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((w - nw) // 2, (h - nh) // 2))
    return canvas


def fit_image(
    img: Image.Image,
    w: int,
    h: int,
    fit: str = "cover",
    *,
    canvas: tuple[int, int] | None = None,
    fit_to: str = "layer",
    extend: str = "edge",
) -> Image.Image:
    """Return an RGBA image of exactly ``w x h``.

    ``fit_to: canvas`` fits the art into the **page safe area** and then
    extends the border pixels out to the layer box.  That is how a background
    gets its overscan without re-rendering: the composition stays 1:1 inside
    the 1920x1280 frame and only the bleed is invented (§H).  ``fit_to: layer``
    (the default) is a plain fit into the layer box.
    """
    if fit_to not in ("layer", "canvas"):
        die(f"unknown fit_to: {fit_to!r} (expected layer|canvas)")
    if fit_to == "canvas" and canvas:
        base_w, base_h = canvas
    else:
        base_w, base_h = w, h

    fitted = fit_into(img, base_w, base_h, fit)
    if (base_w, base_h) == (w, h):
        return fitted

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    left = (w - base_w) // 2
    top = (h - base_h) // 2
    out.alpha_composite(fitted, (left, top))

    extend = (extend or "edge").lower()
    if extend == "transparent":
        return out
    if extend not in ("edge", "mirror"):
        die(f"unknown extend: {extend!r} (expected edge|mirror|transparent)")

    if extend == "edge":
        if left > 0:
            out.paste(fitted.crop((0, 0, 1, base_h)).resize((left, base_h), Image.NEAREST), (0, top))
            right = left + base_w
            out.paste(
                fitted.crop((base_w - 1, 0, base_w, base_h)).resize((w - right, base_h), Image.NEAREST),
                (right, top),
            )
        if top > 0:
            out.paste(out.crop((0, top, w, top + 1)).resize((w, top), Image.NEAREST), (0, 0))
            bottom = top + base_h
            out.paste(
                out.crop((0, bottom - 1, w, bottom)).resize((w, h - bottom), Image.NEAREST),
                (0, bottom),
            )
    else:  # mirror — reflect the *adjacent* edge, never the opposite one
        from PIL import ImageOps

        if left > 0 or top > 0:
            vert_bleed = max(top, h - (top + base_h))
            if max(left, w - (left + base_w)) > base_w or vert_bleed > base_h:
                die(
                    "extend: mirror can only reflect an adjacent band no wider "
                    f"than the art ({base_w}x{base_h}); got bleed {left}/{top}. "
                    "Render a wider plate or use extend: edge."
                )
        if left > 0:
            # continuity: the band pixel nearest the frame is the frame's own edge
            # pixel, so the join has no step and no distant landmark repeats.
            out.paste(ImageOps.mirror(fitted.crop((0, 0, left, base_h))), (0, top))
            right = left + base_w
            out.paste(
                ImageOps.mirror(fitted.crop((base_w - (w - right), 0, base_w, base_h))),
                (right, top),
            )
        if top > 0:
            out.paste(ImageOps.flip(out.crop((0, top, w, top + top))), (0, 0))
            bottom = top + base_h
            out.paste(ImageOps.flip(out.crop((0, bottom - (h - bottom), w, bottom))), (0, bottom))

    return out


def parse_color(value: str) -> tuple[int, int, int, int]:
    value = str(value).strip()
    rgba = ImageColor.getrgb(value)
    if len(rgba) == 3:
        rgba = (*rgba, 255)
    return rgba  # type: ignore[return-value]


def dominant_border_color(img: Image.Image) -> tuple[int, int, int]:
    """Most common quantised opaque colour along the borders (chroma-key auto).

    Fully transparent pixels are ignored: a sprite fitted with ``contain`` gets
    transparent padding on every border, and sampling that would read as black.
    If the border itself is entirely transparent, every opaque pixel is sampled
    instead — the backdrop of a cut-out sprite is its dominant colour.
    """
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    step = max(1, min(w, h) // 64)

    def collect(points):
        counts: dict[tuple[int, int, int], int] = {}
        for x, y in points:
            r, g, b, a = px[x, y]
            if a <= 8:
                continue
            q = (r // 8 * 8, g // 8 * 8, b // 8 * 8)
            counts[q] = counts.get(q, 0) + 1
        return counts

    border = [(x, 0) for x in range(0, w, step)] + [(x, h - 1) for x in range(0, w, step)]
    border += [(0, y) for y in range(0, h, step)] + [(w - 1, y) for y in range(0, h, step)]
    counts = collect(border)
    if not counts:
        counts = collect((x, y) for y in range(0, h, step) for x in range(0, w, step))
    if not counts:
        return (255, 0, 255)  # fully transparent: nothing to key
    return max(counts.items(), key=lambda kv: kv[1])[0]


def chroma_key(
    img: Image.Image, key: str, tolerance: int
) -> Image.Image:
    """Knock ``key`` out of ``img`` with a linear alpha ramp at the edge."""
    if key in (None, "", "none", "None"):
        return img
    if str(key).lower() == "auto":
        key_rgb = dominant_border_color(img)
    else:
        key_rgb = parse_color(key)[:3]

    tol = max(1, int(tolerance))
    out = img.convert("RGBA").copy()
    px = out.load()
    w, h = out.size
    kr, kg, kb = key_rgb
    # distance at which alpha reaches 0; below (tol/2) fully transparent
    full = max(1.0, tol / 2.0)
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            d = ((r - kr) ** 2 + (g - kg) ** 2 + (b - kb) ** 2) ** 0.5
            if d <= full:
                px[x, y] = (r, g, b, 0)
            elif d < tol:
                px[x, y] = (r, g, b, int(a * (d - full) / max(1e-6, tol - full)))
    return out


def wrap_text(draw, text: str, font, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = f"{current} {word}".strip()
        if draw.textlength(trial, font=font) <= max_width or not current:
            current = trial
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def load_font(layer: dict, size: int | None = None) -> ImageFont.FreeTypeFont:
    size = int(size if size is not None else layer.get("font_size", 56))
    path = layer.get("font")
    candidates = [path] if path else FONT_CANDIDATES
    for candidate in candidates:
        if not candidate:
            continue
        candidate = os.path.expanduser(str(candidate))
        if os.path.exists(candidate):
            try:
                return ImageFont.truetype(candidate, size)
            except OSError:
                continue
    return ImageFont.load_default()  # type: ignore[return-value]


def render_text_layer(layer: dict, w: int, h: int) -> Image.Image:
    """Rasterise a text layer, shrinking the font until the block fits.

    A caption that is taller than its plate is silently clipped — ascenders on
    the first line, descenders on the last. Rather than hand-tuning a font size
    per page, the plate is filled by wrapping the text and reducing the size
    until the whole block fits the declared box. The same box is what the Lua
    layer and the PSD layer use, so both tracks agree.
    """
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    text = str(layer.get("text", ""))
    if not text:
        return img

    bg = layer.get("color")
    if bg:
        draw.rectangle([0, 0, w, h], fill=parse_color(bg))

    colour = parse_color(layer.get("text_color", "#FFF8EC"))
    pad_x = int(layer.get("padding_x", 30))
    pad_y = int(layer.get("padding_y", 14))
    line_factor = float(layer.get("line_height", 1.25))
    requested = int(layer.get("font_size", 56))

    size = requested
    lines: list[str] = []
    line_h = 0
    font = load_font(layer, size)
    while True:
        font = load_font(layer, size)
        lines = wrap_text(draw, text, font, max(1, w - 2 * pad_x))
        ascent, descent = font.getmetrics()
        line_h = max(1, int((ascent + descent) * line_factor))
        if len(lines) * line_h <= h - 2 * pad_y or size <= 10:
            break
        size -= 2

    if size != requested:
        print(
            f"  note: text layer {layer.get('name')!r} fitted at {size}px "
            f"(requested {requested}px, {len(lines)} line(s) in {h}px)"
        )

    block_h = line_h * len(lines)
    align = str(layer.get("align", "center")).lower()
    y = pad_y + max(0, (h - 2 * pad_y - block_h) // 2)
    for line in lines:
        if align == "left":
            draw.text((pad_x, y), line, font=font, fill=colour)
        else:
            draw.text((w // 2, y), line, font=font, fill=colour, anchor="ma")
        y += line_h
    return img


def apply_crop(img: Image.Image, crop: dict | None) -> Image.Image:
    """Trim source pixels before fitting (``crop: {top, right, bottom, left}``).

    Values are fractions of the source when < 1, else pixels.  Used to take a
    dead strip off a render (e.g. the cover's sky band carrying unwanted
    lettering) without touching the art in an image editor — the crop lives in
    the YAML, so it stays reproducible.
    """
    if not crop:
        return img
    sw, sh = img.size

    def px(value, size):
        value = float(value)
        return round(value * size) if value < 1 else round(value)

    left = px(crop.get("left", 0), sw)
    top = px(crop.get("top", 0), sh)
    right = px(crop.get("right", 0), sw)
    bottom = px(crop.get("bottom", 0), sh)
    box = (left, top, max(left + 1, sw - right), max(top + 1, sh - bottom))
    return img.crop(box)


def render_color_layer(layer: dict, w: int, h: int) -> Image.Image:
    """Flat fill, or a vertical alpha ramp when ``gradient: vertical`` is set.

    A gradient scrim keeps a caption legible over a busy illustration without
    drawing a hard-edged band across the art: alpha goes from 0 at the top edge
    to ``opacity`` at the bottom.
    """
    rgba = parse_color(layer.get("color", "#000000"))
    opacity = float(layer.get("opacity", 1))
    if str(layer.get("gradient", "")).lower() != "vertical":
        return Image.new("RGBA", (w, h), (rgba[0], rgba[1], rgba[2], round(255 * opacity)))

    # The ramp goes from fully transparent at the top edge to fully opaque at
    # the bottom; the layer's `opacity` is applied once, afterwards, by
    # render_layer.  Baking it here as well would square it.
    # Opaque across the caption area, with a soft fade over the top ~28 % so the
    # band never shows a hard edge against the art.
    fade = max(1.0, h * 0.28)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        alpha = round(255 * min(1.0, y / fade))
        for x in range(w):
            px[x, y] = (rgba[0], rgba[1], rgba[2], alpha)
    return img


def render_layer(layer: dict, base: str, canvas: dict | None = None) -> Image.Image:
    """Rasterise one YAML layer into an RGBA image of its declared size."""
    w, h = int(layer["width"]), int(layer["height"])
    if "image" in layer and layer["image"]:
        src = resolve(str(layer["image"]), base)
        if not os.path.exists(src):
            die(f"layer {layer.get('name')!r}: image not found: {src}")
        canvas_size = (
            (int(canvas["width"]), int(canvas["height"])) if canvas else None
        )
        with Image.open(src) as im:
            img = apply_crop(im, layer.get("crop")).convert("RGBA")
        # Key the flat backdrop BEFORE resampling: fitting first would blend the
        # figure's edge pixels with the backdrop and leave a halo.
        if layer.get("transparent_color"):
            img = chroma_key(
                img,
                layer["transparent_color"],
                int(layer.get("transparent_tolerance", 40)),
            )
        img = fit_image(
            img,
            w,
            h,
            layer.get("fit", "cover"),
            canvas=canvas_size,
            fit_to=str(layer.get("fit_to", "layer")),
            extend=str(layer.get("extend", "edge")),
        )
    elif "text" in layer and layer["text"] is not None:
        img = render_text_layer(layer, w, h)
    elif "color" in layer:
        img = render_color_layer(layer, w, h)
    else:
        die(
            f"layer {layer.get('name')!r}: needs one of image:, text:, color:"
        )

    opacity = layer.get("opacity")
    if opacity is not None and float(opacity) < 1.0:
        alpha = img.getchannel("A").point(lambda v: int(v * float(opacity)))
        img.putalpha(alpha)
    return img


def layer_bounds(layer: dict) -> tuple[int, int, int, int]:
    """(left, top, right, bottom) from centre-based x/y."""
    w, h = int(layer["width"]), int(layer["height"])
    x, y = float(layer["x"]), float(layer["y"])
    left = round(x - w / 2)
    top = round(y - h / 2)
    return left, top, left + w, top + h


def may_bleed(layer: dict) -> bool:
    return bool(layer.get("bleed")) or str(layer.get("name", "")) in BLEED_NAMES


# --------------------------------------------------------------------------- #
# validation
# --------------------------------------------------------------------------- #
def check_spec(spec: dict, base: str) -> list[str]:
    canvas = spec["canvas"]
    cw, ch = int(canvas["width"]), int(canvas["height"])
    problems: list[str] = []
    seen: set[str] = set()

    for layer in spec["layers"]:
        name = layer.get("name")
        if not name:
            problems.append("a layer has no name")
            continue
        if name in seen:
            problems.append(f"duplicate layer name: {name}")
        seen.add(name)

        for banned in ("xScale", "yScale"):
            if banned in layer:
                problems.append(
                    f"{name}: {banned} is forbidden — layerProps are PSD pixels (§C.3)"
                )

        for req in ("x", "y", "width", "height"):
            if req not in layer:
                problems.append(f"{name}: missing required key '{req}'")
        if any(k not in layer for k in ("x", "y", "width", "height")):
            continue

        w, h = int(layer["width"]), int(layer["height"])
        if w <= 0 or h <= 0:
            problems.append(f"{name}: width/height must be positive")
        if w % 2 or h % 2:
            problems.append(f"{name}: odd size {w}x{h} (bilinear needs even dimensions)")

        left, top, right, bottom = layer_bounds(layer)
        if not may_bleed(layer):
            if left < 0 or top < 0 or right > cw or bottom > ch:
                problems.append(
                    f"{name}: rect ({left},{top})-({right},{bottom}) leaves the "
                    f"{cw}x{ch} canvas; safe-area art must sit inside it"
                )

        if layer.get("image"):
            src = resolve(str(layer["image"]), base)
            if not os.path.exists(src):
                problems.append(f"{name}: image not found: {src}")
            else:
                with Image.open(src) as im:
                    if im.size[0] % 2 or im.size[1] % 2:
                        problems.append(
                            f"{name}: source image {im.size[0]}x{im.size[1]} has an odd dimension"
                        )

        if "fit" in layer and str(layer["fit"]).lower() not in (
            "cover",
            "contain",
            "stretch",
        ):
            problems.append(f"{name}: unknown fit {layer['fit']!r}")
        if str(layer.get("fit_to", "layer")).lower() not in ("layer", "canvas"):
            problems.append(f"{name}: unknown fit_to {layer['fit_to']!r}")
        if str(layer.get("extend", "edge")).lower() not in (
            "edge",
            "mirror",
            "transparent",
        ):
            problems.append(f"{name}: unknown extend {layer['extend']!r}")

        if not any(k in layer for k in ("image", "text", "color")):
            problems.append(f"{name}: needs one of image:, text:, color:")

    return problems


# --------------------------------------------------------------------------- #
# build
# --------------------------------------------------------------------------- #
def build_psd(spec: dict, yaml_path: str, out_psd: str) -> tuple[str, str]:
    base = os.path.dirname(os.path.abspath(yaml_path))
    canvas = spec["canvas"]
    cw, ch = int(canvas["width"]), int(canvas["height"])
    png_dir = os.path.join(os.path.dirname(out_psd), "png")
    os.makedirs(png_dir, exist_ok=True)

    psd = PSDImage.new("RGBA", (cw, ch))
    layers = spec["layers"]

    for index, layer in enumerate(layers):
        name = str(layer["name"])
        img = render_layer(layer, base, canvas)
        png_path = os.path.join(png_dir, f"{name}.png")
        img.save(png_path)

        left, top, _, _ = layer_bounds(layer)
        weight = len(layers) - 1 - index  # 0 = front, matches $weight
        pixel = PixelLayer.frompil(img, psd, name, top, left)
        # $weight is not part of the PSD spec; layers2lua writes it into Lua.
        print(
            f"  [{weight}] {name:<16} {img.size[0]}x{img.size[1]} "
            f"@ ({left},{top})  -> png/{name}.png"
        )

    psd.save(out_psd)
    print(f"wrote {out_psd}  ({cw}x{ch}, {len(layers)} layers)")
    return out_psd, png_dir


def export_dataset(spec: dict, yaml_path: str) -> str:
    """Export datasets/<trigger>/ as PNG + caption pairs (§D2.5)."""
    base = os.path.dirname(os.path.abspath(yaml_path))
    trigger = spec.get("trigger") or (
        f"{spec.get('character')}_v1" if spec.get("character") else None
    )
    if not trigger:
        die(f"{yaml_path}: --dataset needs 'trigger:' or 'character:' at the top level")

    descriptors = str(spec.get("descriptors", "")).strip().rstrip(",")
    template = str(
        spec.get(
            "caption_template",
            "{trigger}, {descriptors}, {view}, plain background",
        )
    )

    out_dir = os.path.join(REPO_ROOT, "datasets", str(trigger))
    os.makedirs(out_dir, exist_ok=True)

    written = []
    for index, layer in enumerate(spec["layers"]):
        name = str(layer["name"])
        view = str(layer.get("view", name))
        img = render_layer(layer, base, spec["canvas"])
        img.save(os.path.join(out_dir, f"{name}.png"))

        caption = str(layer.get("caption") or "").strip()
        if not caption:
            caption = template.format(
                trigger=trigger,
                descriptors=descriptors,
                view=view,
                character=spec.get("character", ""),
                subject_id=spec.get("subject_id", ""),
            )
            caption = caption.replace(" ,", ",").replace(",,", ",").strip()
            if caption.startswith(","):
                caption = caption[1:].strip()
        with open(os.path.join(out_dir, f"{name}.txt"), "w", encoding="utf-8") as fh:
            fh.write(caption + "\n")

        written.append(
            {
                "order": index + 1,
                "name": name,
                "view": view,
                "png": f"{name}.png",
                "caption": f"{name}.txt",
                "width": int(layer["width"]),
                "height": int(layer["height"]),
            }
        )
        print(f"  dataset {index + 1:>2}. {name:<18} {caption}")

    manifest = {
        "dataset": str(trigger),
        "character": spec.get("character"),
        "subject_id": spec.get("subject_id"),
        "trigger": trigger,
        "canvas": spec["canvas"],
        "caption_template": template,
        "descriptors": descriptors,
        "source": os.path.relpath(os.path.abspath(yaml_path), REPO_ROOT),
        "views": written,
    }
    with open(os.path.join(out_dir, "dataset.yaml"), "w", encoding="utf-8") as fh:
        yaml.safe_dump(manifest, fh, sort_keys=False, allow_unicode=True)
    print(f"wrote {out_dir}/ ({len(written)} views)")
    return out_dir


# --------------------------------------------------------------------------- #
# cli
# --------------------------------------------------------------------------- #
def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Build a layered PSD (+ PNGs) from a page.layers.yaml",
        epilog="See docs/PAGE-GENERATION-PLAN.md §F/§G.",
    )
    parser.add_argument("yaml_file", help="Photoshop/<book>/<page>/page.layers.yaml")
    parser.add_argument(
        "output",
        nargs="?",
        help="output PSD path (default: <yaml dir>/page.psd for page.layers.yaml, "
        "else <yaml stem>.psd next to the YAML)",
    )
    parser.add_argument(
        "--check", action="store_true", help="validate only, write nothing"
    )
    parser.add_argument(
        "--dataset",
        action="store_true",
        help="also export datasets/<trigger>/ PNG + caption pairs",
    )
    args = parser.parse_args(argv)

    yaml_path = args.yaml_file
    if not os.path.exists(yaml_path):
        die(f"{yaml_path}: no such file")
    spec = load_spec(yaml_path)
    base = os.path.dirname(os.path.abspath(yaml_path))

    problems = check_spec(spec, base)
    canvas = spec["canvas"]
    n_img = sum(1 for l in spec["layers"] if l.get("image"))
    n_txt = sum(1 for l in spec["layers"] if l.get("text"))
    print(
        f"{yaml_path}: {len(spec['layers'])} layers "
        f"({n_img} image, {n_txt} text) on "
        f"{canvas['width']}x{canvas['height']}"
    )
    if problems:
        for problem in problems:
            print(f"  check: {problem}", file=sys.stderr)
        print(f"check FAILED ({len(problems)} problem(s))", file=sys.stderr)
        return 1
    print("  check: ok")

    if args.check and not args.dataset:
        return 0

    if args.dataset:
        export_dataset(spec, yaml_path)
        if args.check:
            return 0

    if args.output:
        out_psd = args.output
    elif os.path.basename(yaml_path) == "page.layers.yaml":
        out_psd = os.path.join(base, "page.psd")
    else:
        out_psd = os.path.splitext(yaml_path)[0] + ".psd"

    build_psd(spec, yaml_path, out_psd)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
