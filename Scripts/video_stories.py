#!/usr/bin/env python3
"""Turn ``book.fountain`` + ``Scripts/book.video.yaml`` into the ten video stories.

Stage "video" of the pipeline — the same contract as the page pipeline: one
authored source per concern, everything downstream derived and checkable.

    Scripts/book.fountain        story, caption, cast tags   (authored)
    Scripts/book.video.yaml      beat, motion, camera, time  (authored)
        |
        v  Scripts/video_stories.py
    Photoshop/<book>/video/stories.yaml      the ten stories, prompts resolved
    Photoshop/<book>/video/plan.json         assembly plan (order, timing, master)
    Photoshop/<book>/video/requests/<id>.json  ready-to-POST batch-video bodies
    Photoshop/<book>/video/frames/<id>.png   16:9 reference frame for i2v

Why the reference frame is rebuilt instead of cropped
----------------------------------------------------
The page is 3:2 (1920x1280); every installed video model declares 16:9 and
Guaardvark reshapes a request to the nearest declared ratio inside a 6%
tolerance, so a 3:2 request comes back 16:9 whether or not you asked for it. Rather
than crop the approved art (which cuts the caption plate and the figures' feet),
the frame is re-composed **on the page's own bleed plate** — 2776x1440, which is
1.928 and therefore genuinely 16:9 — with each layer at its authored PSD
coordinate shifted by the plate offset (+428, +80). The result is the page as the
device sees it, cropped to 2560x1440 and scaled to the 1280x720 render canvas.

Usage
-----
    python3 Scripts/video_stories.py             # write the derived tree
    python3 Scripts/video_stories.py --check     # exit 1 if anything is stale
    python3 Scripts/video_stories.py --frames    # (re)render the reference frames
    python3 Scripts/video_stories.py --chroma    # include the chroma-key shots
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import tempfile
from typing import Any

import numpy as np
import yaml
from PIL import Image

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from book_config import BOOK
from paths import ASSETS_DIR, PAGES_DIR
VIDEO_REL = os.path.relpath(os.path.join(PAGES_DIR, "video"), REPO_ROOT)
SCRIPTS = os.path.join(REPO_ROOT, "Scripts")
sys.path.insert(0, SCRIPTS)

from create_layered_psd import chroma_key, dominant_border_color  # noqa: E402
from fountain2pages import ART_DIRECTION, CAST, parse_fountain  # noqa: E402
from paths import PAGES_DIR, SPRITE_DIR  # noqa: E402

FOUNTAIN = os.path.join(SCRIPTS, "book.fountain")
DIRECTION = os.path.join(SCRIPTS, "book.video.yaml")
VIDEO_DIR = os.path.join(PAGES_DIR, "video")
FRAME_DIR = os.path.join(VIDEO_DIR, "frames")
REQUEST_DIR = os.path.join(VIDEO_DIR, "requests")

# The Solar2D "video book" app: a standalone project that plays the ten clips as
# page turns. Its data module and its assets are derived from the story plan, so
# the app can never disagree with it.
APP_DIR = os.path.join(REPO_ROOT, "Solar2D", "App")

# The bleed plate the pages are cropped from (page.model.md / HANDOFF §2.1).
PLATE_W, PLATE_H = 2776, 1440
PAGE_W, PAGE_H = 1920, 1280
PLATE_DX = (PLATE_W - PAGE_W) // 2   # +428
PLATE_DY = (PLATE_H - PAGE_H) // 2   # +80


# ---------------------------------------------------------------------------
# prompt assembly
# ---------------------------------------------------------------------------

def _cast_block(tags: list[str]) -> str:
    cast = [CAST[t] for t in sorted(tags) if t in CAST]
    chars = "\n".join(f"- {c['name']}: {c['description']}" for c in cast if c["kind"] == "character")
    envs = "\n".join(f"- {c['name']}: {c['description']}" for c in cast if c["kind"] == "environment")
    parts = []
    if chars:
        parts.append("Characters (keep every detail identical):\n" + chars)
    if envs:
        parts.append("Setting:\n" + envs)
    return "\n\n".join(parts)


def _action_text(action: str, aliases: dict[str, str] | None = None) -> str:
    """@tag -> display name, as fountain2pages does for the stills.

    ``aliases`` is the one deliberate divergence: a video prompt is prose read by
    a motion model, so ``@farmhouse`` becomes "the farmhouse" rather than its
    Cast display name "Farmhouse Meadow" ("before Farmhouse Meadow" describes
    hillside, not the cottage). Authored in book.video.yaml, never inferred.
    """
    aliases = aliases or {}
    out = action
    for tag, meta in CAST.items():
        out = out.replace(f"@{tag}", aliases.get(tag, meta["name"]))
    return out.strip()


def motion_prompt(story: dict[str, Any], fmt: dict[str, Any],
                  aliases: dict[str, str] | None = None) -> str:
    """The i2v prompt: motion and camera only — the frame supplies the look."""
    return "\n\n".join(
        [
            ART_DIRECTION.strip(),
            f"Animate the supplied illustration of this scene:\n{_action_text(story['action'], aliases)}",
            "Motion: " + " ".join(story["motion"].split()),
            "Camera: " + " ".join(story["camera"].split()),
            (
                "Keep the reference frame exactly: same characters, same faces, same "
                "palette, same brushwork, same layout. Nothing enters or leaves the frame "
                "that the motion does not describe. No text, no lettering, no new objects. "
                f"{story['duration_s']:g} s at {fmt['render_fps']} fps, seamless loop-safe "
                "start and end."
            ),
        ]
    )


def chroma_prompt(shot: dict[str, Any], fmt: dict[str, Any]) -> str:
    meta = CAST[shot["subject"]]
    return "\n\n".join(
        [
            ART_DIRECTION.strip(),
            f"Character (keep every detail identical):\n- {meta['name']}: {meta['description']}",
            "Scene: " + " ".join(shot["motion"].split()),
            "Camera: " + " ".join(shot["camera"].split()),
            (
                "Full body, head to toe, completely inside the frame, nothing cropped. "
                "The background is one perfectly flat, uniform, unshaded chroma-key green "
                "(#00B140) covering the whole frame: no gradient, no vignette, no floor "
                "plane, no scenery, no props the character does not need, no cast shadow, "
                "no rim light. No green anywhere on the character, in the costume or the "
                f"hair. {shot['duration_s']:g} s at {fmt['render_fps']} fps."
            ),
        ]
    )


def frame_count(duration_s: float, fps: int, model_max: int = 121) -> int:
    """Wan 2.2 wants 4n+1 frames; clamp to the model's ceiling."""
    n = max(5, round(duration_s * fps))
    n = 1 + 4 * round((n - 1) / 4)
    return min(n, model_max)


# ---------------------------------------------------------------------------
# reference frames
# ---------------------------------------------------------------------------

def build_frame(page: str, out: str, fmt: dict[str, Any]) -> str:
    """Re-compose the page on its 16:9 bleed plate and write the render canvas."""
    spec_path = os.path.join(PAGES_DIR, page, "page.layers.yaml")
    if not os.path.exists(spec_path):
        raise SystemExit(f"{page}: missing {spec_path} — run fountain2pages.py first")
    with open(spec_path, "r", encoding="utf-8") as fh:
        spec = yaml.safe_load(fh)

    png_dir = os.path.join(PAGES_DIR, page, "png")
    canvas = Image.new("RGBA", (PLATE_W, PLATE_H), (255, 255, 255, 255))
    for layer in spec["layers"]:
        name = str(layer.get("name"))
        # Typeset text never enters a reference frame: it is a subtitle/title
        # track (ASS) so it can be re-timed, translated or removed without a
        # re-render. Caught the hard way — the first cover render came back with
        # a re-synthesised title burned into the art because only
        # `caption` was skipped and the cover's layer is called `title`.
        if name in ("caption", "caption_scrim") or "text" in layer:
            continue
        png = os.path.join(png_dir, f"{name}.png")
        if not os.path.exists(png):
            raise SystemExit(f"{page}/{name}: missing {png} — run create_layered_psd.py first")
        with Image.open(png) as im:
            lay = im.convert("RGBA")
        w, h = int(layer["width"]), int(layer["height"])
        if lay.size != (w, h):
            lay = lay.resize((w, h), Image.LANCZOS)
        if name == "bg":
            left, top = 0, 0  # the bg IS the plate
        else:
            left = round(float(layer["x"]) + PLATE_DX - w / 2)
            top = round(float(layer["y"]) + PLATE_DY - h / 2)
        x0, y0 = max(0, left), max(0, top)
        x1, y1 = min(PLATE_W, left + w), min(PLATE_H, top + h)
        if x1 <= x0 or y1 <= y0:
            continue
        canvas.alpha_composite(lay.crop((x0 - left, y0 - top, x1 - left, y1 - top)), (x0, y0))

    target_w = int(fmt["render_width"])
    target_h = int(fmt["render_height"])
    ratio = target_w / target_h
    crop_w = min(PLATE_W, int(round(PLATE_H * ratio)))
    crop_h = min(PLATE_H, int(round(crop_w / ratio)))
    x0 = (PLATE_W - crop_w) // 2
    y0 = (PLATE_H - crop_h) // 2
    out_img = canvas.crop((x0, y0, x0 + crop_w, y0 + crop_h)).resize(
        (target_w, target_h), Image.LANCZOS
    )
    os.makedirs(os.path.dirname(out), exist_ok=True)
    out_img.convert("RGB").save(out, optimize=True)
    return out


def _hex_rgb(value: str) -> tuple[int, int, int]:
    v = str(value).lstrip("#")
    return int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16)


def build_chroma_frame(shot: dict[str, Any], out: str, fmt: dict[str, Any],
                       key_color: str) -> str:
    """Compose the shot's cast sprites onto one flat chroma field.

    The approved sprite is already the character the book ships, so a green plate
    built from it pins identity for free — no LoRA keyframe, no re-invention. The
    placement values are fractions of the render canvas, authored in
    book.video.yaml, never inferred.
    """
    w, h = int(fmt["render_width"]), int(fmt["render_height"])
    canvas = Image.new("RGB", (w, h), _hex_rgb(key_color))
    for spec in shot.get("sprites") or []:
        src = os.path.join(SPRITE_DIR, f"{spec['subject']}.png")
        if not os.path.exists(src):
            raise SystemExit(f"{shot['id']}: missing sprite {src}")
        with Image.open(src) as im:
            sprite = chroma_key(im.convert("RGBA"), "auto", 40) or im.convert("RGBA")
        target_h = max(8, round(h * float(spec.get("h", 0.8))))
        target_w = max(8, round(target_h * sprite.width / sprite.height))
        sprite = sprite.resize((target_w, target_h), Image.LANCZOS)
        left = round(w * float(spec.get("x", 0.5)) - target_w / 2)
        top = round(h * float(spec.get("y", 0.5)) - target_h / 2)
        canvas.paste(sprite, (left, top), sprite)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    canvas.save(out, optimize=True)
    return out


# ---------------------------------------------------------------------------
# build + emit
# ---------------------------------------------------------------------------

def build() -> dict[str, Any]:
    with open(DIRECTION, "r", encoding="utf-8") as fh:
        direction = yaml.safe_load(fh)
    fmt = direction["format"]
    scenes = {s["meta"]["page"]: s for s in parse_fountain(FOUNTAIN)}

    order = [s["id"] for s in direction["stories"]]
    missing = [p for p in order if p not in scenes]
    if missing:
        raise SystemExit(
            f"book.video.yaml names pages absent from book.fountain: {', '.join(missing)}"
        )
    extra = [p for p in scenes if p not in order]
    if extra:
        raise SystemExit(f"book.fountain has pages with no video direction: {', '.join(extra)}")

    aliases = direction.get("tag_aliases") or {}
    stories: list[dict[str, Any]] = []
    t = 0.0
    for raw in direction["stories"]:
        page = raw["id"]
        scene = scenes[page]
        caption = scene["meta"].get("caption", "")
        # A clip is frames/fps, not the other way round: wan22-5b tops out at 121
        # frames per render, so a 6 s wish becomes a 5.04 s clip whether or not we
        # say so. Record the clamp instead of pretending.
        frames = frame_count(float(raw["duration_s"]), int(fmt["render_fps"]))
        real_s = round(frames / float(fmt["render_fps"]), 3)
        name = raw.get("name") or page
        story = {
            "id": page,
            "name": name,
            "label": raw["label"],
            "heading": scene["heading"],
            "page": page,
            "spread": scene["meta"].get("spread", ""),
            "title": scene["meta"].get("title", ""),
            "tags": scene["tags"],
            "subject_ids": [CAST[t_]["subject_id"] for t_ in scene["tags"] if t_ in CAST],
            "action": scene["action"],
            "caption": caption,
            "duration_s": real_s,
            "authored_duration_s": float(raw["duration_s"]),
            "clamped_to_model_max": abs(real_s - float(raw["duration_s"])) > 1e-6,
            "start_s": round(t, 3),
            "camera": raw["camera"],
            "motion": raw["motion"],
            "keying": raw.get("keying", "none"),
            "model": fmt["model"],
            "canvas": [int(fmt["render_width"]), int(fmt["render_height"])],
            "duration_frames": frames,
            "reference_frame": f"{VIDEO_REL}/frames/{name}.png",
            "prompt": motion_prompt({**raw, "action": scene["action"]}, fmt, aliases),
            "audio": {
                "narration": f"narration_{page}.wav" if caption else None,
                "sfx": scene["sfx"],
                "music": scene["music"],
            },
        }
        t += real_s
        stories.append(story)

    shots: list[dict[str, Any]] = []
    for raw in direction.get("chroma_shots", []):
        frames = frame_count(float(raw["duration_s"]), int(fmt["render_fps"]))
        shots.append(
            {
                "id": raw["id"],
                "for_story": raw["for_story"],
                # A split take is its own deliverable: it renders into its own
                # out/<slug>/ so it cannot overwrite the page take it came from.
                "out_slug": raw.get("out_slug"),
                "subject": raw["subject"],
                "subject_id": CAST[raw["subject"]]["subject_id"],
                "duration_s": round(frames / float(fmt["render_fps"]), 3),
                "duration_frames": frames,
                "canvas": [int(fmt["render_width"]), int(fmt["render_height"])],
                "keying": direction["chroma"],
                "sprites": raw.get("sprites") or [],
                # Optional crop on the render canvas; the page layer's geometry
                # is derived from it (see kwik_files), and render_local.py
                # encodes clip.ogv down to this box.
                "crop": raw.get("crop"),
                "reference_frame": (
                    f"{VIDEO_REL}/frames/{raw['id']}.png"
                    if raw.get("sprites") else None
                ),
                "prompt": chroma_prompt(raw, fmt),
            }
        )

    master = {
        "width": int(fmt["width"]),
        "height": int(fmt["height"]),
        "fps": int(fmt["fps"]),
        "duration_s": round(t, 3),
        "model": fmt["model"],
        "render_canvas": [int(fmt["render_width"]), int(fmt["render_height"])],
        "render_fps": int(fmt["render_fps"]),
        "interpolation_multiplier": int(fmt["interpolation_multiplier"]),
        "upscale": fmt.get("upscale_to_master", "lanczos"),
        "negative_prompt": " ".join(str(direction["negative_prompt"]).split()),
        "has_alpha": False,
        "alpha_note": "Guaardvark writes H.264/H.265 yuv420p only; see docs/VIDEO-PRODUCTION.md",
    }
    return {"master": master, "stories": stories, "chroma_shots": shots, "fmt": fmt,
            "chroma": direction["chroma"], "negative": master["negative_prompt"],
            "keyed": direction.get("keyed_clips") or {},
            "test_pages": direction.get("test_pages") or [],
            "cropped_book": direction.get("cropped_book") or {}}


def request_for(story: dict[str, Any], built: dict[str, Any]) -> dict[str, Any]:
    fmt = built["fmt"]
    body = {
        "image_paths": [os.path.join(REPO_ROOT, story["reference_frame"])],
        "prompt": story["prompt"],
        "model": fmt["model"],
        "width": story["canvas"][0],
        "height": story["canvas"][1],
        "fps": int(fmt["render_fps"]),
        "duration_frames": story["duration_frames"],
        "num_inference_steps": int(fmt["steps"]),
        "interpolation_multiplier": int(fmt["interpolation_multiplier"]),
        "prompt_style": "hand_drawn",
        "enhance_prompt": False,
        "negative_prompt": built["negative"],
        "seed": int(hashlib.sha256(story["id"].encode()).hexdigest()[:8], 16) % 2**31,
        "metadata": {"upscale": False, "high_consistency": True},
    }
    return {
        "story": story["id"],
        "endpoint": "POST /api/batch-video/generate/image",
        "body": body,
        "expect": {
            "frames": story["duration_frames"],
            "seconds": round(story["duration_frames"] / int(fmt["render_fps"]), 3),
            "assembly_start_s": story["start_s"],
            "assembly_end_s": round(story["start_s"] + story["duration_s"], 3),
            "master": f"{built['master']['width']}x{built['master']['height']}",
        },
    }


def chroma_request(shot: dict[str, Any], built: dict[str, Any]) -> dict[str, Any]:
    fmt = built["fmt"]
    body: dict[str, Any] = {
            "model": fmt["model"],
            "width": shot["canvas"][0],
            "height": shot["canvas"][1],
            "fps": int(fmt["render_fps"]),
            "duration_frames": shot["duration_frames"],
            "num_inference_steps": int(fmt["steps"]),
            "interpolation_multiplier": int(fmt["interpolation_multiplier"]),
            "prompt_style": "hand_drawn",
            "enhance_prompt": False,
            "negative_prompt": built["negative"],
    }
    if shot.get("reference_frame"):
        body["image_paths"] = [os.path.join(REPO_ROOT, shot["reference_frame"])]
        body["prompt"] = shot["prompt"]
        endpoint = "POST /api/batch-video/generate/image"
    else:
        body["prompts"] = [shot["prompt"]]
        body["subject_ids"] = [shot["subject_id"]]
        endpoint = "POST /api/batch-video/generate/text"
    return {
        "shot": shot["id"],
        "for_story": shot["for_story"],
        "endpoint": endpoint,
        "body": body,
        "expect": {
            "keying": shot["keying"],
            "post": f"python3 Scripts/chroma_key.py probe <clip.mp4> --color {shot['keying']['color']}",
        },
    }


def emit(built: dict[str, Any], frames: bool) -> dict[str, str]:
    os.makedirs(VIDEO_DIR, exist_ok=True)
    os.makedirs(REQUEST_DIR, exist_ok=True)
    written: dict[str, str] = {}

    doc = {
        "generated_by": "Scripts/video_stories.py from Scripts/book.fountain + Scripts/book.video.yaml",
        "master": built["master"],
        "stories": built["stories"],
    }
    if built["chroma_shots"]:
        doc["chroma_shots"] = built["chroma_shots"]

    stories_path = os.path.join(VIDEO_DIR, "stories.yaml")
    with open(stories_path, "w", encoding="utf-8") as fh:
        fh.write("# generated by Scripts/video_stories.py — do not edit by hand\n")
        yaml.safe_dump(doc, fh, sort_keys=False, allow_unicode=True, width=100)
    written[stories_path] = "stories.yaml"

    plan_path = os.path.join(VIDEO_DIR, "plan.json")
    plan = {
        "master": built["master"],
        "run_order": [
            {"index": i + 1, "id": s["name"], "page": s["id"], "start_s": s["start_s"],
             "duration_s": s["duration_s"], "request": f"requests/{s['name']}.json"}
            for i, s in enumerate(built["stories"])
        ],
        "assembly": {
            "concat": "ffmpeg -f concat -safe 0 -i order.txt -c copy silent.mp4",
            "subtitle_track": "narration_<page>.wav per clip; captions as ASS, never baked",
            "master_encode": (
                "ffmpeg -i silent.mp4 -vf scale=1920:1080:flags=lanczos+accurate_rnd,"
                "unsharp=5:5:0.35:5:5:0.0 -c:v libx264 -crf 16 -preset slow "
                "-pix_fmt yuv420p -movflags +faststart master.mp4"
            ),
        },
    }
    with open(plan_path, "w", encoding="utf-8") as fh:
        json.dump(plan, fh, indent=2)
        fh.write("\n")
    written[plan_path] = "plan.json"

    for story in built["stories"]:
        path = os.path.join(REQUEST_DIR, f"{story['name']}.json")
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(request_for(story, built), fh, indent=2)
            fh.write("\n")
        written[path] = f"requests/{story['id']}.json"

    for shot in built["chroma_shots"]:
        path = os.path.join(REQUEST_DIR, f"{shot['id']}.json")
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(chroma_request(shot, built), fh, indent=2)
            fh.write("\n")
        written[path] = f"requests/{shot['id']}.json"

    if frames:
        for story in built["stories"]:
            out = os.path.join(FRAME_DIR, f"{story['name']}.png")
            build_frame(story["page"], out, built["fmt"])
            written[out] = f"frames/{story['name']}.png"
        for shot in built["chroma_shots"]:
            if not shot.get("sprites"):
                continue
            out = os.path.join(FRAME_DIR, f"{shot['id']}.png")
            build_chroma_frame(shot, out, built["fmt"], built["chroma"]["color"])
            written[out] = f"frames/{shot['id']}.png"

    return written


def _lua(value, indent: int = 0) -> str:
    """Serialise plain data as a Lua literal (the app loads it with require)."""
    pad = "  " * indent
    if isinstance(value, dict):
        if not value:
            return "{}"
        body = "".join(f"{pad}  {k} = {_lua(v, indent + 1)},\n" for k, v in value.items())
        return "{\n" + body + pad + "}"
    if isinstance(value, (list, tuple)):
        if not value:
            return "{}"
        body = "".join(f"{pad}  {_lua(v, indent + 1)},\n" for v in value)
        return "{\n" + body + pad + "}"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if value is None:
        return "nil"
    return json.dumps(str(value), ensure_ascii=False)


#: The Kwik book this project builds. A Kwik "book" is a folder under Solar2D/App/
#: with index.lua (scene order), one <page>.lua scene model per page, and
#: components/<page>/layers/ holding the layer + class files. There is no
#: config.lua / main.lua / build.settings inside it — those belong to the
#: enclosing Solar2D project, which is what makes it a book and not an app.
BOOK_NAME = f"{BOOK}-video"

#: Layer name per page. One video layer per page, named after the page so the
#: still image lands at assets/images/<page>/<layer>.png (Kwik's convention).

#: Where a page's encoded clip lives. The render tree is out/<slug>/clip.ogv; the
#: flat out/<slug>.ogv is the pre-restructure layout, still accepted so a
#: half-migrated tree keeps working.
def _clip_path(slug: str) -> str | None:
    for cand in (os.path.join(REPO_ROOT, "out", slug, "clip.ogv"),
                 os.path.join(REPO_ROOT, "out", f"{slug}.ogv")):
        if os.path.exists(cand):
            return cand
    return None


def _layer_name(name: str) -> str:
    return f"{name}_video"


def _scene_lua(page: str, label: str) -> str:
    layer = _layer_name(page)
    return f'''-- generated by Scripts/video_stories.py -- do not edit by hand
-- {label}
local sceneName = ...
--
local model = {{
  components = {{
    -- layer names are slugs, so they must be quoted: a bare hyphenated key
    -- parses as a subtraction, which made require() fail and sent Kwik down its
    -- legacy "components.<page>.index" path.
    layers = {{
      {{ ["{page}_bg"] = {{ }} }},
      {{ ["{layer}"] = {{ class = {{ "ogv" }} }} }},
    }},
    audios = {{ }},
    groups = {{ }},
    timers = {{ }},
    variables = {{ }},
    joints = {{ }},
    page = {{ }},
  }},
  commands = {{ }},
  onInit = function(scene) end,
}}
--
return require('controller.scene').new(sceneName, model)
'''


def _layer_lua(page: str, name: str, image: str, comment: str,
               size: tuple[float, float] | None = None,
               pos: tuple[float, float] | None = None,
               book: str | None = None) -> str:
    """A layer that owns its own image loading.

    Deliberately not using components.kwik.layer_image's createImage(): that path
    goes through UI.props.imgDir (set only by the editor) and scales layerProps by
    kwikGlobal.scale (a 480x320 design space), so a 1280x720 book page came out
    either missing or a quarter size. This layer fills the content width at 16:9
    and resolves its own asset path, the same way custom.components.ogv does.

    Written as a plain template, not an f-string: the body is Lua and its braces
    are not worth escaping.
    """
    override = ""
    if size:
        override = ("w, h = %g, %g   -- cropped layer: its own box, not 16:9 of the page\n"
                    "  " % (size[0], size[1]))
        if pos:
            # The ogv class takes its geometry from this poster object, so the
            # position has to be here too — centre would stack every cropped
            # layer on top of the others. Offsets are from the stage centre
            # because the page frame is centred there.
            override += ("px = display.contentCenterX + (%g)\n"
                         "  py = display.contentCenterY + (%g)" % (pos[0], pos[1]))
    return (LAYER_TEMPLATE
            .replace("__OVERRIDE__", override)
            .replace("__COMMENT__", comment)
            .replace("__NAME__", name)
            .replace("__BOOK__", book or BOOK_NAME)
            .replace("__IMAGE__", image)
            .replace("__IS_VIDEO__", "true" if "video" in name else "false")
            .replace("__PAGE_W__", "1920")
            .replace("__PAGE_H__", "1280"))


LAYER_TEMPLATE = """-- generated by Scripts/video_stories.py -- do not edit by hand
-- __COMMENT__
local M = {}

M.properties = {
  name = "__NAME__",
  book = "__BOOK__",
  image = "__IMAGE__",
}

local function resolve(path, book)
  if not path or path == "" then return nil end
  local candidates = { path, "App/" .. book .. "/" .. path }
  for i = 1, #candidates do
    if system.pathForFile(candidates[i], system.ResourceDirectory) then
      return candidates[i]
    end
  end
  return nil
end

function M:init(UI)
end

function M:create(UI)
  local p = self.properties or {}
  local file = resolve(p.image, p.book)
  if not file then
    print("[__NAME__] image not found: " .. tostring(p.image))
    return
  end
  -- Kwik's convention: layerProps are PSD pixels and the runtime scales them by
  -- 0.25 (components.kwik.layer_image clamps kwikGlobal.scale to 0.25 when it is
  -- >= 1). The page frame is 1920x1280, so it lands at 480x320 content units —
  -- the book's design space. Don't size from display.contentWidth: that is 960 in
  -- production and 480 in the editor, so the page would change size with the mode.
  local SCALE = 0.25
  local w, h = __PAGE_W__ * SCALE, __PAGE_H__ * SCALE
  if __IS_VIDEO__ then
    h = w * 9 / 16            -- the clip is 16:9, inside the 3:2 page
  end
  local px, py = display.contentCenterX, display.contentCenterY
  __OVERRIDE__
  local ok, obj = pcall(display.newImageRect, UI.sceneGroup, file,
                        system.ResourceDirectory, w, h)
  if not ok or not obj then
    print("[__NAME__] could not load " .. file .. ": " .. tostring(obj))
    return
  end
  obj.name = p.name
  obj.anchorX, obj.anchorY = 0.5, 0.5
  obj.x, obj.y = px, py
  UI.sceneGroup[p.name] = obj
  self.obj = obj
end

function M:didShow(UI) end
function M:didHide(UI) end

function M:destroy(UI)
  if self.obj then
    pcall(function() self.obj:removeSelf() end)
    self.obj = nil
  end
end

return M
"""


def _class_lua(page: str, story: dict, has_video: bool, narration: str | None,
               key_color: str | None = None,
               geom: tuple[float, float, float, float] | None = None,
               controls: bool = True,
               book: str | None = None,
               sync: bool = False,
               controls_offset: float = 0.0) -> str:
    """The ogv class instance for one layer.

    `geom` = (x, y, w, h) overrides the default full-page placement. A split
    take is encoded cropped to its character's box, so the layer must be placed
    and sized to that box; the class otherwise assumes one full-frame clip per
    page.
    """
    layer = _layer_name(page)
    w, h = story["frame_size"]
    lines = [
        "-- generated by Scripts/video_stories.py -- do not edit by hand",
        f'-- page {page}: video class instance (plugin.movie, Ogg Theora)',
        "local parent, root, M = newModule(...)",
        "",
        'M.class = "ogv"',
        "",
        "M.properties = {",
        f'  name     = "{layer}",',
        f'  book     = "{book or BOOK_NAME}",   -- folder under App/ (Simulator/editor layout)',
    ]
    if has_video:
        lines.append(f'  video    = "assets/videos/{page}.ogv",')
    else:
        lines.append("  -- video: no clip rendered for this page yet; the still is shown")
    if geom is None:
        gx, gy, gw, gh = w // 2, h // 2, w, h
    else:
        gx, gy, gw, gh = geom
        gx, gy, gw, gh = (round(gx, 2), round(gy, 2), round(gw, 2), round(gh, 2))
        gx = int(gx) if gx == int(gx) else gx
        gy = int(gy) if gy == int(gy) else gy
        gw = int(gw) if gw == int(gw) else gw
        gh = int(gh) if gh == int(gh) else gh
        # The class fits the clip to its box at the clip's own aspect; a cropped
        # take is not 16:9, so it must not be stretched back to it.
        aspect_line = f"  aspect   = {round(gw / gh, 4)},   -- encoded crop is not 16:9\n"
    lines += [
        f'  still    = "assets/images/{page}/{layer}.png",',
        f"  width    = {gw},",
        f"  height   = {gh},",
        f"  x        = {gx},",
        f"  y        = {gy},",
        "  autoplay = true,",
        "  loop     = false,",
        "  channel  = 3,",
        "  volume   = 1,",
    ]
    if not controls:
        # `controls: per_page` — the page's first layer carries the only bar.
        lines.append("  controls = false,   -- this page's single transport lives on its first layer")
    elif not sync:
        # one bar per character: hug the buttons so plates cannot cover each other
        lines.append("  compactControls = true,   -- the plate is the buttons, not the layer")
    elif sync:
        lines.append("  stackSync = true,   -- this bar drives every layer on the page")
    if controls and controls_offset:
        lines.append(f"  controlsOffset = {round(controls_offset, 2)},   -- keep stacked bars apart")
    lines += [
        "  fps      = 16,   -- clip frame rate: paces the decoder's update()",
    ]
    if narration:
        lines.append(f'  narration = "assets/audios/{os.path.basename(narration)}",')
    if geom is not None:
        lines.append(aspect_line.rstrip("\n"))
    if key_color:
        lines.append('  -- Theora has no alpha: key the flat field at runtime so the page')
        lines.append('  -- backdrop shows through.')
        lines.append('  chromaEffect = "custom.chromaKey",   -- effect defined by the ogv class')
        lines.append(f'  chromaColor = "{key_color}",')
        lines.append('  chromaTolerance = 0.42,')
    lines += [
        "  -- Theora has no alpha. To composite this clip over page art, set",
        '  -- chromaEffect = "filter.chromaKey" (the runtime ships',
        "  -- kernel_filter_chromaKey_gl) and bind the key colour per that filter.",
        "}",
        "",
        'return require("custom.components.ogv").set(M)',
        "",
    ]
    return "\n".join(lines)


def _canvas_size(built) -> tuple[int, int]:
    """Width of the canvas the `crop` boxes are written in.

    Not `fmt.render_width`: that is the *delivery* plan (1280x720) and the
    reference frames are built at it, while this machine renders 512x288
    (render_local.PROFILE) — and `crop` is applied to the shipped clip, so it is
    in the clip's pixels. Read it off a rendered clip; fall back to the frame.
    """
    for shot in built.get("chroma_shots") or []:
        if not shot.get("crop"):
            continue
        slug = shot.get("out_slug")
        if not slug:
            story = next((st for st in built["stories"]
                          if st["id"] == shot["for_story"]), None)
            slug = (story or {}).get("name")
        clip = os.path.join(REPO_ROOT, "out", slug or "", "clip.mp4")
        if not os.path.exists(clip):
            continue
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-select_streams", "v:0",
             "-show_entries", "stream=width,height", "-of", "csv=p=0:s=x", clip],
            capture_output=True, text=True).stdout.strip()
        if "x" in out:
            cw, ch = out.split("x")[:2]
            if cw.isdigit() and ch.isdigit():
                return int(cw), int(ch)
    return (int(built["fmt"]["render_width"]), int(built["fmt"]["render_height"]))


def _crop_geometry(built, crop) -> tuple[float, float, float, float] | None:
    """(x, y, w, h) in page units for a layer encoded down to `crop`.

    The full render canvas maps to the page's 1280x720 video frame, so a box on
    the canvas maps by the same factor. Kept in one place: the class file and the
    poster must agree, or the still is squashed inside the movie's rect.
    """
    if not crop:
        return None
    # Content units, offset from the content centre — the same space the poster
    # layer places itself in. (The old form returned page pixels, 4x too large,
    # so a layer whose poster failed to resolve filled the stage.)
    w, h, dx, dy = _display_box(built, crop)
    return (dx, dy, w, h)


#: Content width of a page's video frame: the 1280-wide authored frame x Kwik's
#: 0.25 scale, which is also the book's 480-unit design width.
PAGE_CONTENT_W = 480.0


def _display_box(built, crop):
    """(w, h, dx, dy) in content units for a layer cropped to `crop`.

    The clip's canvas maps to the page's 480x270 video frame, centred on the
    stage, so a crop box maps by 480/canvas_w and its offset is measured from
    the canvas centre. Sizes and position must both come from here: the ogv
    class takes its geometry from this poster object.
    """
    if not crop:
        return None
    cw, ch = _canvas_size(built)
    k = PAGE_CONTENT_W / float(cw)
    w, h = crop["w"] * k, crop["h"] * k
    dx = (crop["x"] + crop["w"] / 2 - cw / 2) * k
    dy = (crop["y"] + crop["h"] / 2 - ch / 2) * k
    return (round(w, 2), round(h, 2), round(dx, 2), round(dy, 2))


def _test_scene_lua(page: str, label: str, bg_page: str,
                    layers: list[dict]) -> str:
    """Scene model for a page that stacks several keyed video layers.

    The ordinary page model has exactly one video layer (`_scene_lua`); a split
    page has one per character, and their order here is the draw order — later
    layers paint over earlier ones, so the cast is listed back to front.
    """
    lines = [
        "-- generated by Scripts/video_stories.py -- do not edit by hand",
        f"-- {label}",
        "local sceneName = ...",
        "--",
        "local model = {",
        "  components = {",
        "    -- layer names are slugs, so they must be quoted: a bare hyphenated key",
        "    -- parses as a subtraction, which made require() fail and sent Kwik down its",
        '    -- legacy "components.<page>.index" path.',
        "    layers = {",
        f'      {{ ["{page}_bg"] = {{ }} }},',
    ]
    for lay in layers:
        lines.append(f'      {{ ["{lay["slug"]}_video"] = {{ class = {{ "ogv" }} }} }},')
    lines += [
        "    },",
        "    audios = { },",
        "    groups = { },",
        "    timers = { },",
        "    variables = { },",
        "    joints = { },",
        "    page = { },",
        "  },",
        "  commands = { },",
        "  onInit = function(scene) end,",
        "}",
        "--",
        "return require('controller.scene').new(sceneName, model)",
        "",
    ]
    return "\n".join(lines)


def _index_lua(pages: list[str]) -> str:
    body = "".join(f'  "{p}",\n' for p in pages)
    return ("-- generated by Scripts/video_stories.py -- do not edit by hand\n"
            "-- one scene per page turn\n"
            f"local scenes = {{\n{body}}}\n"
            "return scenes\n")


def kwik_files(built) -> dict[str, str]:
    """Every generated text file of the Kwik book, path -> content."""
    book = os.path.join(APP_DIR, BOOK_NAME)
    files: dict[str, str] = {}
    pages = [st["name"] for st in built["stories"]]

    for story in built["stories"]:
        page = story["id"]
        name = story.get("name") or page
        still = os.path.join(FRAME_DIR, f"{name}.png")
        size = [1280, 720]
        if os.path.exists(still):
            with Image.open(still) as im:
                size = [im.size[0], im.size[1]]
        story = {**story, "frame_size": size}
        has_video = _clip_path(name) is not None
        narration = None
        if story["audio"]["narration"]:
            src = os.path.join(ASSETS_DIR,
                               "audios", story["audio"]["narration"])
            if os.path.exists(src):
                narration = story["audio"]["narration"]

        files[os.path.join(book, f"{name}.lua")] = _scene_lua(name, story["label"])
        layers = os.path.join(book, "components", name, "layers")
        files[os.path.join(layers, f"{name}_bg.lua")] = _layer_lua(
            name, f"{name}_bg", f"assets/images/{name}/{name}_bg.png",
            f"background plate for {name}")
        files[os.path.join(layers, f"{_layer_name(name)}.lua")] = _layer_lua(
            name, _layer_name(name), f"assets/images/{name}/{_layer_name(name)}.png",
            f"poster still for the {name} video layer")
        keyed = ((built.get("keyed") or {}).get(name)
                    or (built.get("keyed") or {}).get(page))
        files[os.path.join(layers, f"{_layer_name(name)}_ogv.lua")] = _class_lua(
            name, story, has_video, narration, keyed)

    # Test pages: one page stacking N keyed takes (a page cut by character).
    # A layer whose shot authored a `crop` is encoded down to that box, so the
    # layer is placed and sized to the box instead of the full page — that is
    # what keeps the composition identical while the texture shrinks.
    key_color = built["chroma"]["color"]
    shots_by_id = {sh["id"]: sh for sh in built.get("chroma_shots") or []}
    canvas_w = int(built["fmt"]["render_width"])
    page_w = 1280          # the ogv layer's authored frame, from the existing pages
    for tp in built.get("test_pages") or []:
        page = tp["id"]
        label = tp.get("label") or page
        src = next((s for s in built["stories"] if s["id"] == tp["from_story"]), None)
        if src is None:
            raise SystemExit(f"test page {page}: unknown from_story {tp['from_story']!r}")
        bg_page = src.get("name") or tp["from_story"]
        layers = tp.get("layers") or []
        if not layers:
            raise SystemExit(f"test page {page}: no layers")
        pages.append(page)
        files[os.path.join(book, f"{page}.lua")] = _test_scene_lua(
            page, label, bg_page, layers)
        comp = os.path.join(book, "components", page, "layers")
        files[os.path.join(comp, f"{page}_bg.lua")] = _layer_lua(
            page, f"{page}_bg", f"assets/images/{bg_page}/{bg_page}_bg.png",
            f"background plate for {page} (borrowed from {bg_page})")
        for lay in layers:
            slug = lay["slug"]
            crop = (shots_by_id.get(lay.get("shot")) or {}).get("crop")
            box = _display_box(built, crop)
            files[os.path.join(comp, f"{slug}_video.lua")] = _layer_lua(
                page, f"{slug}_video", f"assets/images/{slug}/{slug}_video.png",
                f"poster still for the {slug} video layer",
                size=(box[0], box[1]) if box else None,
                pos=(box[2], box[3]) if box else None)
            geom = _crop_geometry(built, crop)
            files[os.path.join(comp, f"{slug}_video_ogv.lua")] = _class_lua(
                slug, {"frame_size": [page_w, 720], "id": page},
                _clip_path(slug) is not None, None, key_color, geom)
    files[os.path.join(book, "index.lua")] = _index_lua(pages)
    return files


PAPER = (255, 248, 236)   # book cream, same as the caption colour
BG_MASTER = (1920, 1280)  # page frame, authored at @4x



def _key_frame(rgb: "np.ndarray", key_color: str, tolerance: float) -> "np.ndarray":
    """Key the flat field out of one RGB frame, exactly as the runtime shader does.

    Same maths as custom/components/ogv.lua's ogvChromaKey kernel so the poster and
    the playing clip are indistinguishable: soft edge between tol*0.35 and tol, and
    the key's dominant channel clamped to the other two (despill).
    """
    v = str(key_color).lstrip("#")
    key = np.array([int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16)], dtype=np.float32) / 255.0
    rgb_f = rgb.astype(np.float32) / 255.0
    d = np.sqrt(((rgb_f - key) ** 2).sum(axis=2))
    lo, hi = tolerance * 0.35, tolerance
    keep = np.clip((d - lo) / max(1e-6, hi - lo), 0.0, 1.0)   # smoothstep-ish ramp
    keep = keep * keep * (3.0 - 2.0 * keep)                   # smoothstep

    # despill: clamp the dominant channel of the key
    dom = int(np.argmax(key))
    others = [i for i in range(3) if i != dom]
    limit = np.maximum(rgb_f[:, :, others[0]], rgb_f[:, :, others[1]]) + 0.04
    rgb_f[:, :, dom] = np.minimum(rgb_f[:, :, dom], limit)

    out = np.zeros((rgb.shape[0], rgb.shape[1], 4), dtype=np.uint8)
    out[:, :, :3] = np.clip(rgb_f * 255.0, 0, 255).astype(np.uint8)
    out[:, :, 3] = np.clip(keep * 255.0, 0, 255).astype(np.uint8)
    return out


def _write_poster(slug: str, page_dir: str, key_color: str | None,
                  tolerance: float, size: tuple[int, int]) -> str | None:
    """Poster still for a page.

    With a keyed clip the poster must be the clip's own first frame with the flat
    field removed — otherwise the still (the composited page art) and the video
    (characters on the page backdrop) look like two different pictures, which is
    exactly what happens when the poster is copied from frames/<page>.png.
    """
    out = os.path.join(page_dir, f"{slug}_video.png")
    clip = os.path.join(REPO_ROOT, "out", slug, "clip.ogv")
    if not os.path.exists(clip):
        clip = os.path.join(REPO_ROOT, "out", f"{slug}.ogv")
    if key_color and os.path.exists(clip):
        with tempfile.TemporaryDirectory() as tmp:
            frame = os.path.join(tmp, "f.png")
            subprocess.run(
                ["ffmpeg", "-v", "error", "-ss", "0.04", "-i", clip, "-frames:v", "1",
                 "-update", "1", "-y", frame],
                capture_output=True,
            )
            if os.path.exists(frame):
                with Image.open(frame) as im:
                    rgba = _key_frame(np.asarray(im.convert("RGB")), key_color, tolerance)
                Image.fromarray(rgba, "RGBA").resize(size, Image.LANCZOS).save(out, optimize=True)
                return out
    # no keyed clip: the composited frame *is* what the page shows
    src = os.path.join(FRAME_DIR, f"{slug}.png")
    if not os.path.exists(src):
        return None
    with Image.open(src) as im:
        im.convert("RGB").resize(size, Image.LANCZOS).save(out, optimize=True)
    return out


def _write_bg_plate(page: str, page_dir: str, canvas: tuple[int, int],
                    has_video: bool = False) -> list[str]:
    """The page backdrop, emitted as a Solar2D image-suffix ladder.

    `config.lua` declares imageSuffix @2x/@4x, so a layer asks for
    "<page>_bg.png" and the runtime substitutes the right file. The master is the
    page frame 1920x1280 (= 480x320 design units at @4x), not the 1280x720 render
    canvas the video uses.

    Source order matters. The backdrop must not be the clip's own background: for
    pages that were built layered there is a character-free plate; for the others
    (cover, p4-p8, back) the only render *is* the composited frame, and using it
    would just double the cast behind the video. Those pages get paper instead.
    """
    os.makedirs(page_dir, exist_ok=True)
    written: list[str] = []
    master = os.path.join(page_dir, f"{page}_bg@4x.png")

    plate = os.path.join(PAGES_DIR, page, "art", "bg.png")          # 1920x1280
    bleed = os.path.join(PAGES_DIR, page, "png", "bg.png")          # 2776x1440
    layered = os.path.exists(os.path.join(PAGES_DIR, page, "page.layers.yaml")) and any(
        "Mode: layered" in open(os.path.join(PAGES_DIR, page, "page.model.md"), encoding="utf-8").read()
        for _ in [0]
    ) if os.path.exists(os.path.join(PAGES_DIR, page, "page.model.md")) else False

    frame = os.path.join(FRAME_DIR, f"{page}.png")
    src = None
    if layered and os.path.exists(bleed):
        src = bleed            # character-free bleed crop
    elif layered and os.path.exists(plate):
        src = plate
    elif not has_video and os.path.exists(frame):
        # No clip on this page: the composited frame *is* the page, and there is
        # nothing for it to double behind.
        src = frame

    with Image.new("RGB", BG_MASTER, PAPER) as img:
        if src:
            with Image.open(src) as im:
                art = im.convert("RGB")
            ratio = BG_MASTER[0] / BG_MASTER[1]
            w, h = art.size
            if w / h > ratio:
                cw = int(round(h * ratio)); box = ((w - cw) // 2, 0, (w - cw) // 2 + cw, h)
            else:
                ch = int(round(w / ratio)); box = (0, (h - ch) // 2, w, (h - ch) // 2 + ch)
            img.paste(art.crop(box).resize(BG_MASTER, Image.LANCZOS), (0, 0))
        img.save(master, optimize=True)
        written.append(master)
        for suffix, div in (("@2x", 2), ("", 4)):
            out = os.path.join(page_dir, f"{page}_bg{suffix}.png")
            img.resize((BG_MASTER[0] // div, BG_MASTER[1] // div), Image.LANCZOS).save(out, optimize=True)
            written.append(out)
    return written



def _stale_clips(built) -> list[str]:
    """Pages whose clip.ogv is older than clip.mp4 (or missing a poster source).

    This is the ordering trap that has bitten twice: re-encode the take, forget to
    re-run to_ogv, and the book silently ships yesterday's clip. Fail loudly.
    """
    stale = []
    for story in built["stories"]:
        slug = story["name"]
        page_dir = os.path.join(REPO_ROOT, "out", slug)
        mp4 = os.path.join(page_dir, "clip.mp4")
        ogv = os.path.join(page_dir, "clip.ogv")
        if os.path.exists(mp4) and os.path.exists(ogv):
            if os.path.getmtime(ogv) < os.path.getmtime(mp4):
                stale.append(f"{slug}: clip.ogv is older than clip.mp4 — run Scripts/to_ogv.py")
    return stale



# --- the cropped book -------------------------------------------------------
# A second Kwik book, same ten pages, but each page is a stack of per-character
# layers encoded down to their character's box. `<book>-video` stays the
# full-canvas single-take build, so the two can be compared on the same source.


def _shot_crop(built, shot_id: str, slug: str):
    """The crop box for a take.

    `crop:` is authored on some splits, but the autocropped splits get
    their box measured at render time and stored in out/<slug>/chroma.json. Read
    it from there as well, so the layer geometry matches the encoded pixels.
    """
    shots = {sh["id"]: sh for sh in built.get("chroma_shots") or []}
    crop = (shots.get(shot_id) or {}).get("crop")
    if crop is None and slug:
        meta = os.path.join(REPO_ROOT, "out", slug, "chroma.json")
        if os.path.exists(meta):
            with open(meta, encoding="utf-8") as fh:
                crop = json.load(fh).get("crop")
    return crop


def _bar_layout(geoms):
    """Per-layer vertical offsets that keep each transport bar clear of the others.

    Mirrors buildControls: a button row of 4 x max(26, round(w*0.075)) with 0.35
    gaps (restart, play/pause, stop, visibility); in compact mode the plate is that
    row + 10, and the bar sits at dy + h/2 + barH*0.75. Several layers can share a ground line (their crops span
    the page), so bars are placed in layer order and any collision is pushed down
    one bar height at a time.
    """
    placed = []
    offsets = []
    for dx, dy, w, h in geoms:
        btn = max(26, round(w * 0.075))
        gap = btn * 0.35
        total = btn * 4 + gap * 3
        bar_h = btn
        if total > w:
            bar_h = max(16, math.floor((w / 5.05) * 10) / 10)
            gap = bar_h * 0.35
            total = bar_h * 4 + gap * 3
        plate_w = total + 10
        y = dy + h * 0.5 + bar_h * 0.75
        off = 0.0
        for _ in range(len(geoms) + 1):
            x0, x1 = dx - plate_w / 2, dx + plate_w / 2
            y0, y1 = y + off - bar_h / 2, y + off + bar_h / 2
            clash = any(x0 < r[1] and r[0] < x1 and y0 < r[3] and r[2] < y1
                        for r in placed)
            if not clash:
                break
            off += bar_h + 4
        x0, x1 = dx - plate_w / 2, dx + plate_w / 2
        placed.append((x0, x1, y + off - bar_h / 2, y + off + bar_h / 2))
        offsets.append(off)
    return offsets

def cropped_book(built) -> dict:
    spec = built.get("cropped_book") or {}
    if not spec or not spec.get("pages"):
        return {}
    return spec


def _cropped_book_files(built) -> dict[str, str]:
    spec = cropped_book(built)
    if not spec:
        return {}
    book = os.path.join(APP_DIR, spec["id"])
    files: dict[str, str] = {}
    key_color = built["chroma"]["color"]
    shots = {sh["id"]: sh for sh in built.get("chroma_shots") or []}
    # `enabled: false` drops a layer: identity_check.py rejects the takes where the
    # model invented cast beside the character, and a rejected take must not ship.
    for pg in spec["pages"]:
        pg["layers"] = [l for l in pg.get("layers", []) if l.get("enabled", True)]
    pages = [p["page"] for p in spec["pages"] if p.get("layers")]
    spec["pages"] = [p for p in spec["pages"] if p.get("layers")]
    files[os.path.join(book, "index.lua")] = _index_lua(pages)

    # `controls: per_layer` puts a transport under every character (each drives
    # only its own clip); `per_page` puts one on the first layer and syncs it.
    per_layer = str(spec.get("controls", "per_layer")).lower() != "per_page"
    stories = {st["name"]: st for st in built["stories"]}
    for pg in spec["pages"]:
        page, layers = pg["page"], pg["layers"]
        story = stories.get(page) or {}
        narration = ((story.get("audio") or {}).get("narration") or None)
        if narration:
            src = os.path.join(ASSETS_DIR,
                               "audios", narration)
            if not os.path.exists(src):
                narration = None
        files[os.path.join(book, f"{page}.lua")] = _test_scene_lua(
            page, pg.get("label") or page, page, layers)
        comp = os.path.join(book, "components", page, "layers")
        files[os.path.join(comp, f"{page}_bg.lua")] = _layer_lua(
            page, f"{page}_bg", f"assets/images/{page}/{page}_bg.png",
            f"background plate for {page} (shared with <book>-video)",
            book=spec["id"])
        geoms = [_crop_geometry(built, _shot_crop(built, l.get("shot"), l["slug"]))
                 for l in layers]
        offsets = _bar_layout([g for g in geoms if g] or []) if per_layer else [0.0] * len(layers)
        for i, lay in enumerate(layers):
            slug = lay["slug"]
            crop = _shot_crop(built, lay.get("shot"), slug)
            box = _display_box(built, crop)
            geom = _crop_geometry(built, crop)
            files[os.path.join(comp, f"{slug}_video.lua")] = _layer_lua(
                page, f"{slug}_video", f"assets/images/{slug}/{slug}_video.png",
                f"poster still for the {slug} layer of {page}",
                size=(box[0], box[1]) if box else None,
                pos=(box[2], box[3]) if box else None,
                book=spec["id"])
            files[os.path.join(comp, f"{slug}_video_ogv.lua")] = _class_lua(
                slug, {"frame_size": [1280, 720], "id": page},
                _clip_path(slug) is not None,
                # the page narrates once, from its first layer
                narration if i == 0 else None,
                key_color, geom, book=spec["id"],
                controls=(per_layer or i == 0),
                sync=(not per_layer and i == 0),
                controls_offset=(offsets[i] if i < len(offsets) else 0.0))
    return files


def emit_cropped_book(built, copy_assets: bool = True) -> list[str]:
    spec = cropped_book(built)
    if not spec:
        return []
    book = os.path.join(APP_DIR, spec["id"])
    written: list[str] = []
    for path, text in _cropped_book_files(built).items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        written.append(path)
    if not copy_assets:
        return written

    img_root = os.path.join(book, "assets", "images")
    vid_root = os.path.join(book, "assets", "videos")
    os.makedirs(img_root, exist_ok=True)
    os.makedirs(vid_root, exist_ok=True)
    tol = float(built["chroma"].get("similarity", 0.14)) * 3.0
    keyed = built["chroma"]["color"]
    for pg in spec["pages"]:
        page = pg["page"]
        # the page backdrop ladder is the same art as the full-canvas book
        src_dir = os.path.join(APP_DIR, BOOK_NAME, "assets", "images", page)
        dst_dir = os.path.join(img_root, page)
        os.makedirs(dst_dir, exist_ok=True)
        for f in os.listdir(src_dir) if os.path.isdir(src_dir) else []:
            if f.startswith(f"{page}_bg"):
                shutil.copy2(os.path.join(src_dir, f), os.path.join(dst_dir, f))
                written.append(os.path.join(dst_dir, f))
        story = {st["name"]: st for st in built["stories"]}.get(page) or {}
        narration = ((story.get("audio") or {}).get("narration") or None)
        if narration:
            src = os.path.join(ASSETS_DIR,
                               "audios", narration)
            if os.path.exists(src):
                aud_dir = os.path.join(book, "assets", "audios")
                os.makedirs(aud_dir, exist_ok=True)
                shutil.copy2(src, os.path.join(aud_dir, narration))
                written.append(os.path.join(aud_dir, narration))
        for i, lay in enumerate(pg["layers"]):
            slug = lay["slug"]
            clip = _clip_path(slug)
            if not clip:
                raise SystemExit(
                    f"cropped book: no clip for {slug} — render it with "
                    f"Scripts/render_local.py --shot <id> --promote --autocrop")
            lay_dir = os.path.join(img_root, slug)
            os.makedirs(lay_dir, exist_ok=True)
            crop = _shot_crop(built, lay.get("shot"), slug)
            geom = _crop_geometry(built, crop)
            psize = (round(geom[2] * 0.75), round(geom[3] * 0.75)) if geom else (960, 540)
            poster = _write_poster(slug, lay_dir, keyed, tol, psize)
            if poster:
                written.append(poster)
            dst = os.path.join(vid_root, f"{slug}.ogv")
            shutil.copy2(clip, dst)
            written.append(dst)

    # Drop what this run no longer emits: a layer switched off with `enabled: false`
    # (identity_check rejected its take) must not leave its scene, component, video
    # or poster behind — the tree has to say what the book is.
    keep = {os.path.abspath(p) for p in written}
    for root, dirs, files in os.walk(book, topdown=False):
        for f in files:
            path = os.path.abspath(os.path.join(root, f))
            if path not in keep:
                os.remove(path)
        if not os.listdir(root):
            os.rmdir(root) if root != book else None
    return written


def emit_app(built, copy_assets: bool = True) -> list[str]:
    """Write the Kwik book (+ its assets) from the story plan."""
    written: list[str] = []
    book = os.path.join(APP_DIR, BOOK_NAME)

    for path, text in kwik_files(built).items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        written.append(path)

    # Superseded by the per-scene files: each scene carries its own data now.
    legacy = os.path.join(book, "data")
    if os.path.exists(os.path.join(legacy, "pages.lua")):
        os.remove(os.path.join(legacy, "pages.lua"))
    if os.path.isdir(legacy) and not os.listdir(legacy):
        os.rmdir(legacy)

    if not copy_assets:
        return written

    stale = _stale_clips(built)
    if stale:
        raise SystemExit("stale encodes:\n  " + "\n  ".join(stale))

    img_root = os.path.join(book, "assets", "images")
    vid_root = os.path.join(book, "assets", "videos")
    aud_root = os.path.join(book, "assets", "audios")
    for d in (img_root, vid_root, aud_root):
        os.makedirs(d, exist_ok=True)

    canvas = (int(built["fmt"]["render_width"]), int(built["fmt"]["render_height"]))
    for story in built["stories"]:
        page = story["id"]
        name = story.get("name") or page
        still = os.path.join(FRAME_DIR, f"{name}.png")
        page_dir = os.path.join(img_root, name)
        os.makedirs(page_dir, exist_ok=True)
        has_video = _clip_path(name) is not None
        keyed = ((built.get("keyed") or {}).get(name)
                    or (built.get("keyed") or {}).get(page))
        tol = float(built["chroma"].get("similarity", 0.14)) * 3.0   # 0.14 -> ~0.42
        poster = _write_poster(name, page_dir, keyed, tol, (960, 540))
        if poster:
            written.append(poster)
        written.extend(_write_bg_plate(name, page_dir, canvas, has_video=has_video))
        clip = _clip_path(name)
        if clip:
            shutil.copy2(clip, os.path.join(vid_root, f"{name}.ogv"))
            written.append(os.path.join(vid_root, f"{name}.ogv"))
        if story["audio"]["narration"]:
            src = os.path.join(ASSETS_DIR,
                               "audios", story["audio"]["narration"])
            if os.path.exists(src):
                shutil.copy2(src, os.path.join(aud_root, story["audio"]["narration"]))
                written.append(os.path.join(aud_root, story["audio"]["narration"]))

    # Test pages stack keyed takes that are not pages of their own.
    shots_by_id = {sh["id"]: sh for sh in built.get("chroma_shots") or []}
    for tp in built.get("test_pages") or []:
        page = tp["id"]
        keyed = built["chroma"]["color"]
        for lay in tp.get("layers") or []:
            slug = lay["slug"]
            clip = _clip_path(slug)
            if not clip:
                raise SystemExit(
                    f"test page {page}: no clip for layer {slug} — render it with "
                    f"Scripts/render_local.py --shot <shot id> --promote")
            page_dir = os.path.join(img_root, slug)
            os.makedirs(page_dir, exist_ok=True)
            crop = (shots_by_id.get(lay.get("shot")) or {}).get("crop")
            geom = _crop_geometry(built, crop)
            # A full-page layer is 1280x720 page units and ships a 960x540 poster
            # (0.75x), so a cropped layer keeps the same ratio for its still.
            psize = (round(geom[2] * 0.75), round(geom[3] * 0.75)) if geom else (960, 540)
            poster = _write_poster(slug, page_dir, keyed, tol, psize)
            if poster:
                written.append(poster)
            dst = os.path.join(vid_root, f"{slug}.ogv")
            shutil.copy2(clip, dst)
            written.append(dst)
    return written


def check() -> int:
    """Every derived file must already say exactly what a fresh build says."""
    built = build()
    stale: list[str] = []
    expected = emit(built, frames=False)
    for path in expected:
        if not os.path.exists(path):
            stale.append(f"missing: {os.path.relpath(path, REPO_ROOT)}")
    stories = os.path.join(VIDEO_DIR, "stories.yaml")
    if os.path.exists(stories):
        with open(stories, "r", encoding="utf-8") as fh:
            have = yaml.safe_load(fh)
        if have != {
            "generated_by": "Scripts/video_stories.py from Scripts/book.fountain + Scripts/book.video.yaml",
            "master": built["master"],
            "stories": built["stories"],
            "chroma_shots": built["chroma_shots"],
        }:
            stale.append("stories.yaml content differs from a fresh build")
    for path, text in kwik_files(built).items():
        rel = os.path.relpath(path, REPO_ROOT)
        if not os.path.exists(path):
            stale.append(f"missing: {rel}")
            continue
        with open(path, "r", encoding="utf-8") as fh:
            if fh.read() != text:
                stale.append(f"{rel} differs from a fresh build")
    if stale:
        for s in stale:
            print(f"STALE {s}")
        return 1
    print(f"ok: {len(expected)} derived video files match the sources")
    return 0


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true", help="verify, do not write")
    ap.add_argument("--frames", action="store_true", help="(re)render reference frames")
    ap.add_argument("--app", action="store_true",
                    help="also emit the Solar2D video-book data module + assets")
    args = ap.parse_args(argv)

    if args.check:
        return check()

    built = build()
    written = emit(built, frames=args.frames)
    total = built["master"]["duration_s"]
    print(f"{len(built['stories'])} stories · {total:g}s master "
          f"{built['master']['width']}x{built['master']['height']}@{built['master']['fps']}fps")
    for s in built["stories"]:
        print(f"  {s['id']:>5}  {s['start_s']:6.2f}s  {s['duration_s']:g}s  "
              f"{s['duration_frames']:3d}f  {s['label']}")
    if built["chroma_shots"]:
        print(f"{len(built['chroma_shots'])} chroma shots on {built['chroma']['color']}")
    print(f"wrote {len(written)} files under {os.path.relpath(VIDEO_DIR, REPO_ROOT)}/")
    if args.app:
        app_files = emit_app(built)
        cropped = emit_cropped_book(built)
        if cropped:
            print(f"wrote {len(cropped)} files under {os.path.relpath(APP_DIR, REPO_ROOT)}/"
                  f"{cropped_book(built)['id']}/")
        ready = sum(1 for st in built["stories"] if _clip_path(st["name"]))
        print(f"wrote {len(app_files)} files under {os.path.relpath(APP_DIR, REPO_ROOT)}/{BOOK_NAME}/ "
              f"({ready}/{len(built['stories'])} pages have an .ogv; the rest show their still)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
