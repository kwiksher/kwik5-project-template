#!/usr/bin/env python3
"""Render one page (or every pending page) of the video book on this machine.

This is the **local MPS profile**, not the delivery profile. The emitted
``requests/<slug>.json`` bodies are the delivery plan (wan22-5b, 1280x720,
97 frames, 30 steps) and they are wrong for this box: wan22-5b produces black or
noise under MPS (docs/VIDEO-PRODUCTION.md §4b). What works here is the 14B i2v
model with the Lightning LoRAs at 512x288 / 25 frames / 4 steps, ~100 s per clip.

Pipeline this script drives, in this order — the order matters:

    render  -> out/<slug>/raw/<stamp>.mp4    (verbatim download)
            -> out/<slug>/clip.mp4           (the chosen take)
    encode  -> out/<slug>/clip.ogv + clip_b.ogv     (Scripts/to_ogv.py logic)
    emit    -> Solar2D/App/<book>-video/...        (Scripts/video_stories.py --app)

`video_stories.py --app` refuses to run when clip.ogv is older than clip.mp4, so
skipping the encode step fails loudly instead of shipping a stale clip.

Usage
-----
    python3 Scripts/render_local.py --list
    python3 Scripts/render_local.py --page p1
    python3 Scripts/render_local.py --all-pending
    python3 Scripts/render_local.py --page p1 --chroma      # flat #00B140 take

    # afterwards
    python3 Scripts/video_stories.py --app
    open -a "Corona Simulator" Solar2D      # or launch as in docs/VIDEO-PRODUCTION.md

Requires a running Guaardvark (default http://localhost:5055) with
wan22-14b-i2v + its Lightning LoRAs installed and `comfyui` running.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from paths import PAGES_DIR, VIDEO_DIR
PHOTOSHOP_DIR = os.path.dirname(PAGES_DIR)
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))

OUT = os.path.join(REPO_ROOT, "out")
STORE = os.path.join(PHOTOSHOP_DIR, "video")

#: Known-good on this MPS box. See docs/VIDEO-PRODUCTION.md §4b for the numbers.
PROFILE = {
    "model": "wan22-14b-i2v",
    "width": 512,
    "height": 288,
    "fps": 16,
    "duration_frames": 25,
    "num_inference_steps": 4,
    "speed_profile": "lightx2v-4",
    "interpolation_multiplier": 1,
    "prompt_style": "hand_drawn",
}

CHROMA_SUFFIX = (
    "\n\nRender the character(s) alone, full body head to toe, nothing cropped, "
    "against one perfectly flat, unshaded chroma-key green (#00B140) covering the "
    "whole frame: no gradient, no vignette, no floor, no scenery, no cast shadow, "
    "no green on the character. No text."
)

SERVER = os.environ.get("GUAARDVARK_URL", "http://localhost:5055")
GUAARDVARK_UPLOADS = os.environ.get(
    "GUAARDVARK_VIDEO_DIR", "/Users/ymmtny/GitHub/guaardvark/data/uploads/Videos"
)


def api(path: str, body: dict | None = None, timeout: int = 120):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(SERVER + path, data,
                                 {"Content-Type": "application/json"} if data else {})
    with urllib.request.urlopen(req, timeout=timeout) as fh:
        return json.load(fh)


def stories() -> list[dict]:
    path = os.path.join(STORE, "stories.yaml")
    if not os.path.exists(path):
        raise SystemExit(f"missing {path} — run Scripts/video_stories.py first")
    import yaml
    with open(path, encoding="utf-8") as fh:
        return yaml.safe_load(fh)["stories"]


def pending(all_stories: list[dict]) -> list[dict]:
    out = []
    for st in all_stories:
        if not os.path.exists(os.path.join(OUT, st["name"], "clip.ogv")):
            out.append(st)
    return out


def render(story: dict, chroma: bool, timeout_s: int) -> str:
    """Queue one clip, wait, copy the result into out/<slug>/raw/."""
    req_path = os.path.join(STORE, "requests", f"{story['name']}.json")
    body = json.load(open(req_path, encoding="utf-8"))["body"]
    body.update(PROFILE)
    if chroma:
        body["prompt"] = body["prompt"] + CHROMA_SUFFIX

    slug = story["name"]
    page_dir = os.path.join(OUT, slug)
    raw_dir = os.path.join(page_dir, "raw")
    os.makedirs(raw_dir, exist_ok=True)

    started = time.time()
    resp = api("/api/batch-video/generate/image", body)
    batch = resp["data"]["batch_id"]
    print(f"[{slug}] queued {batch} "
          f"({PROFILE['width']}x{PROFILE['height']}, {PROFILE['duration_frames']}f, "
          f"{PROFILE['num_inference_steps']} steps, {PROFILE['model']})")

    status = None
    while time.time() - started < timeout_s:
        time.sleep(10)
        status = api(f"/api/batch-video/status/{batch}").get("data", {})
        state = str(status.get("status", "")).lower()
        if state in ("completed", "error", "failed", "cancelled"):
            break
        print(f"  {int(time.time() - started):4d}s  {status.get('status')}/"
              f"{status.get('stage')}  {status.get('progress_pct')}%", flush=True)

    if not status or str(status.get("status")).lower() != "completed":
        raise SystemExit(f"[{slug}] render did not complete: "
                         f"{json.dumps(status, default=str)[:600]}")

    # the finished file lives in Guaardvark's uploads tree
    results = status.get("results") or []
    rel = (results[0].get("frame_paths") or [None])[0] if results else None
    if not rel:
        raise SystemExit(f"[{slug}] completed but no file path in status")
    src = os.path.join(status.get("output_dir") or
                       os.path.join(GUAARDVARK_UPLOADS, batch), rel)
    if not os.path.exists(src):
        raise SystemExit(f"[{slug}] cannot find {src}")

    stamp = time.strftime("%Y-%m-%d_%H%M%S")
    take = os.path.join(raw_dir, f"{stamp}{'_chroma' if chroma else ''}.mp4")
    shutil.copy2(src, take)
    shutil.copy2(take, os.path.join(page_dir, "clip.mp4"))

    meta_path = os.path.join(page_dir, "meta.json")
    meta = json.load(open(meta_path, encoding="utf-8")) if os.path.exists(meta_path) else {}
    takes = meta.get("takes") or []
    takes.append(os.path.relpath(take, page_dir))
    meta.update({
        "page": story["id"], "name": slug,
        "chosen": os.path.relpath(take, page_dir),
        "takes": takes,
        "batch_id": batch,
        "render": {k: PROFILE[k] for k in
                   ("model", "width", "height", "fps", "duration_frames",
                    "num_inference_steps", "speed_profile")},
        "keyed": "#00B140" if chroma else None,
        "rendered_at": time.strftime("%Y-%m-%dT%H:%M:%S"),
        "seconds": round(time.time() - started, 1),
    })
    json.dump(meta, open(meta_path, "w", encoding="utf-8"), indent=2)
    print(f"[{slug}] {meta['seconds']}s -> {os.path.relpath(take, REPO_ROOT)}")
    return take


def chroma_shots() -> list[dict]:
    path = os.path.join(STORE, "stories.yaml")
    import yaml
    with open(path, encoding="utf-8") as fh:
        return yaml.safe_load(fh).get("chroma_shots") or []


def render_shot(shot_id: str, timeout_s: int, promote: bool,
                autocrop: bool = False) -> str:
    """Render one chroma_shots entry (a sprite composite on a flat field).

    These are *not* page i2v: the reference frame is the approved sprite already
    keyed onto #00B140, which is the only way to get a flat field out of this
    model. The take lands in out/<slug>/raw/ and is *not* promoted to clip.mp4
    until chroma_key.py probe clears the purity gate.
    """
    shots = chroma_shots()
    shot = next((s for s in shots if s["id"] == shot_id), None)
    if shot is None:
        raise SystemExit(f"unknown chroma shot {shot_id!r}; have "
                         + ", ".join(s["id"] for s in shots))
    if not shot.get("reference_frame"):
        raise SystemExit(f"{shot_id} has no sprites/reference frame")

    stories_by_id = {s["id"]: s for s in stories()}
    story = stories_by_id[shot["for_story"]]
    # A shot with `out_slug` is a deliverable in its own right (a page split into
    # per-character layers), so it renders into out/<out_slug>/ and never touches
    # the page take's clip.mp4/chroma.json. Without it, the shot *is* that page.
    slug = shot.get("out_slug") or story["name"]

    req_path = os.path.join(STORE, "requests", f"{shot_id}.json")
    body = json.load(open(req_path, encoding="utf-8"))["body"]
    body.update(PROFILE)

    page_dir = os.path.join(OUT, slug)
    raw_dir = os.path.join(page_dir, "raw")
    os.makedirs(raw_dir, exist_ok=True)

    started = time.time()
    resp = api("/api/batch-video/generate/image", body)
    batch = resp["data"]["batch_id"]
    print(f"[{slug}] chromatic shot {shot_id} -> {batch} "
          f"({PROFILE['width']}x{PROFILE['height']}, {PROFILE['duration_frames']}f)")

    status = None
    while time.time() - started < timeout_s:
        time.sleep(10)
        status = api(f"/api/batch-video/status/{batch}").get("data", {})
        state = str(status.get("status", "")).lower()
        if state in ("completed", "error", "failed", "cancelled"):
            break
        print(f"  {int(time.time() - started):4d}s  {status.get('status')}/"
              f"{status.get('stage')}  {status.get('progress_pct')}%", flush=True)

    if not status or str(status.get("status")).lower() != "completed":
        raise SystemExit(f"[{slug}] {shot_id} did not complete: "
                         f"{json.dumps(status, default=str)[:600]}")

    results = status.get("results") or []
    rel = (results[0].get("frame_paths") or [None])[0] if results else None
    if not rel:
        raise SystemExit(f"[{slug}] completed but no file path in status")
    src = os.path.join(status.get("output_dir") or
                       os.path.join(GUAARDVARK_UPLOADS, batch), rel)
    if not os.path.exists(src):
        raise SystemExit(f"[{slug}] cannot find {src}")

    stamp = time.strftime("%Y-%m-%d_%H%M%S")
    take = os.path.join(raw_dir, f"{stamp}_{shot_id}.mp4")
    shutil.copy2(src, take)
    print(f"[{slug}] {round(time.time() - started, 1)}s -> "
          f"{os.path.relpath(take, REPO_ROOT)}")

    shot_meta_path = os.path.join(page_dir, "chroma.json")
    shot_meta = (json.load(open(shot_meta_path, encoding="utf-8"))
                 if os.path.exists(shot_meta_path) else {})
    shot_meta.update({
        "shot": shot_id, "page": story["id"], "name": slug,
        "take": os.path.relpath(take, page_dir), "batch_id": batch,
        "reference_frame": shot["reference_frame"],
        "render": {k: PROFILE[k] for k in
                   ("model", "width", "height", "fps", "duration_frames",
                    "num_inference_steps", "speed_profile")},
        "keying": shot.get("keying"),
        "rendered_at": time.strftime("%Y-%m-%dT%H:%M:%S"),
        "seconds": round(time.time() - started, 1),
    })
    json.dump(shot_meta, open(shot_meta_path, "w", encoding="utf-8"), indent=2)

    crop = shot.get("crop")
    if autocrop and not crop:
        crop = measure_crop(take, (shot.get("keying") or {}).get("color", "#00B140"))
        print(f"[{slug}] autocrop -> {crop}")
        shot_meta["crop"] = crop
        json.dump(shot_meta, open(shot_meta_path, "w", encoding="utf-8"), indent=2)

    if promote:
        shutil.copy2(take, os.path.join(page_dir, "clip.mp4"))
        encode(slug, crop)
        print(f"[{slug}] promoted to clip.mp4 + clip.ogv")
    else:
        print(f"  next: python3 Scripts/chroma_key.py probe {os.path.relpath(take, REPO_ROOT)}"
              f" --color {shot['keying']['color']}")
    return take


def measure_crop(mp4: str, key_color: str = "#00B140", margin: int = 10,
                 tol: int = 60) -> dict:
    """The motion-safe box of the character on a chroma take.

    Union of every frame's non-key pixels, grown by `margin` (the probe samples
    an 8 px border band, so a box flush with the character would fail purity),
    then aligned to even origin/size for 4:2:0. Measured, never guessed: the
    character moves, and a hand-authored box goes stale the moment a take is
    re-rendered.
    """
    import numpy as np
    probe = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0",
         "-show_entries", "stream=width,height", "-of", "csv=p=0:s=x", mp4],
        capture_output=True, text=True).stdout.strip()
    w, h = (int(n) for n in probe.split("x")[:2])
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", mp4, "-f", "rawvideo",
                          "-pix_fmt", "rgb24", "-"], capture_output=True).stdout
    fsz = w * h * 3
    key = np.array([int(key_color[1:3], 16), int(key_color[3:5], 16),
                    int(key_color[5:7], 16)], dtype=int)
    x0 = y0 = 10 ** 9
    x1 = y1 = -1
    for i in range(len(raw) // fsz):
        f = np.frombuffer(raw[i * fsz:(i + 1) * fsz], np.uint8).reshape(h, w, 3)
        mask = np.abs(f.astype(int) - key).sum(2) > tol
        if not mask.any():
            continue
        ys, xs = np.where(mask)
        x0, y0 = min(x0, int(xs.min())), min(y0, int(ys.min()))
        x1, y1 = max(x1, int(xs.max())), max(y1, int(ys.max()))
    if x1 < 0:
        raise SystemExit(f"{mp4}: no non-key pixels found")
    x0 = max(0, x0 - margin); y0 = max(0, y0 - margin)
    x1 = min(w - 1, x1 + margin); y1 = min(h - 1, y1 + margin)
    x0 -= x0 % 2; y0 -= y0 % 2
    cw = x1 - x0 + 1; ch = y1 - y0 + 1
    cw -= cw % 2; ch -= ch % 2
    return {"x": x0, "y": y0, "w": cw, "h": ch}


def encode(slug: str, crop: dict | None = None) -> None:
    """clip.mp4 -> clip.ogv (+ the replay duplicate). Reuses Scripts/to_ogv.py.

    `crop` = {x, y, w, h} on the render canvas. A split take is encoded down to
    its character's box so the layer ships (and uploads) only the pixels that
    survive the key; clip.mp4 stays full canvas, so re-cropping never needs a
    re-render.
    """
    page_dir = os.path.join(OUT, slug)
    argv = [sys.executable, os.path.join(REPO_ROOT, "Scripts", "to_ogv.py"),
            "encode", os.path.join(page_dir, "clip.mp4"),
            "-o", os.path.join(page_dir, "clip.ogv")]
    if crop:
        argv += ["--crop", f"{int(crop['x'])}:{int(crop['y'])}:{int(crop['w'])}:{int(crop['h'])}"]
    subprocess.run(argv, check=True)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--page", help="page id, e.g. p1")
    ap.add_argument("--shot", help="chroma_shots id, e.g. chroma_bath_splash")
    ap.add_argument("--promote", action="store_true",
                    help="with --shot: copy the take to clip.mp4 and encode it")
    ap.add_argument("--autocrop", action="store_true",
                    help="with --shot: measure the character's box on the take and "
                         "encode the .ogv down to it (stored in chroma.json)")
    ap.add_argument("--reencode", action="store_true",
                    help="with --shot: skip the render, just re-encode clip.mp4 "
                         "with the shot's crop into clip.ogv")
    ap.add_argument("--all-pending", action="store_true")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--chroma", action="store_true",
                    help="render on flat #00B140 (then add the page to keyed_clips)")
    ap.add_argument("--timeout", type=int, default=1800)
    args = ap.parse_args(argv)

    if args.shot:
        if args.reencode:
            shots = {s["id"]: s for s in chroma_shots()}
            shot = shots.get(args.shot)
            if shot is None:
                raise SystemExit(f"unknown chroma shot {args.shot!r}")
            stories_by_id = {s["id"]: s for s in stories()}
            slug = shot.get("out_slug") or stories_by_id[shot["for_story"]]["name"]
            crop = shot.get("crop")
            if autocrop and not crop:
                crop = measure_crop(os.path.join(OUT, slug, "clip.mp4"),
                                    (shot.get("keying") or {}).get("color", "#00B140"))
                cj = os.path.join(OUT, slug, "chroma.json")
                meta = json.load(open(cj, encoding="utf-8")) if os.path.exists(cj) else {}
                meta["crop"] = crop
                json.dump(meta, open(cj, "w", encoding="utf-8"), indent=2)
                print(f"[{slug}] autocrop -> {crop}")
            encode(slug, crop)
            print(f"[{slug}] re-encoded clip.ogv (crop={crop})")
            return 0
        render_shot(args.shot, args.timeout, args.promote, args.autocrop)
        return 0

    all_stories = stories()
    if args.list:
        for st in all_stories:
            done = os.path.exists(os.path.join(OUT, st["name"], "clip.ogv"))
            print(f"{'done ' if done else '     '} {st['name']:26} id={st['id']}")
        return 0

    if args.all_pending:
        targets = pending(all_stories)
        if not targets:
            print("nothing pending")
            return 0
    elif args.page:
        targets = [st for st in all_stories if st["name"] == args.page]
        if not targets:
            raise SystemExit(f"unknown page {args.page!r}; try --list")
    else:
        ap.error("give --page <slug>, --all-pending or --list")

    for st in targets:
        render(st, args.chroma, args.timeout)
        encode(st["name"])

    print("\nnext:")
    print("  python3 Scripts/video_stories.py --app")
    print("  (then relaunch the Simulator; see docs/VIDEO-PRODUCTION.md)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
