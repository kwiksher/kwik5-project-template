#!/usr/bin/env python3
"""Identity check for a per-character take: is this the character it claims to be?

The split takes are i2v from a sprite composited onto #00B140, so the model is free
to re-invent the cast — and it does: a per-character take draws duplicates of
its own character, or paints an extra figure into the frame. The chroma gate
cannot see that: the field is clean, the *content* is wrong.

Each take is compared with the reference plate it was rendered from
(`chroma.json` → reference_frame, i.e. the approved sprite at its placement), over
a handful of decoded frames:

  cast    connected non-key components at least 15% of the largest one. The
          character is one component; a second, comparable one is an extra
          character. Small detached bits (a scarf, a paw, antialiased specks) are
          ignored, and the threshold is relative so a small take is judged the same
          way as a large one.
  shape   the largest component's aspect (w/h) and fill (area / bbox) against the
          reference plate's. A puppy and a standing man differ on both.
  colour  coarse RGB histogram against the reference plate's.

Verdicts: ok · extra-cast · shape-drift · colour-drift · empty · no-clip.

Usage
    python3 Scripts/identity_check.py            # every take under out/
    python3 Scripts/identity_check.py --json
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from collections import deque

import numpy as np
from PIL import Image

from book_config import CHARACTERS

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO_ROOT, "out")
KEY = np.array([12, 196, 64])      # what the decoder actually writes for #00B140
TOL = 60
SAMPLES = 9
BINS = 4
EXTRA = 0.15        # a second blob this big, relative to the largest, is candidate cast
FAR = 0.30          # ... and its centre this far away (fraction of width) makes it so
CLOSE = 0.10        # a neighbour this big is a second character, adjacent or not.
                    # Measured on a reference book: invented companions ran 0.11-0.53
                    # of the body (0.22, 0.20, 0.11 for three of them), while nothing
                    # legitimate in those takes exceeded 0.04.
SHAPE_TOL = 0.90       # fill-ratio drift against the reference plate
COLOUR_TOL = 0.90      # L1 distance between coarse histograms


def canvas(mp4: str) -> tuple[int, int]:
    probe = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0",
         "-show_entries", "stream=width,height", "-of", "csv=p=0:s=x", mp4],
        capture_output=True, text=True).stdout.strip()
    w, h = (int(v) for v in probe.split("x")[:2])
    return w, h


def frames(mp4: str, n: int = SAMPLES) -> list[np.ndarray]:
    w, h = canvas(mp4)
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", mp4, "-f", "rawvideo",
                          "-pix_fmt", "rgb24", "-"], capture_output=True).stdout
    size = w * h * 3
    total = len(raw) // size
    if total == 0:
        return []
    picks = sorted({int(i * (total - 1) / max(1, n - 1)) for i in range(n)})
    return [np.frombuffer(raw[i * size:(i + 1) * size], np.uint8)
            .reshape(h, w, 3).astype(np.int16) for i in picks]


def components(mask: np.ndarray) -> list[tuple[int, int, int, int, int]]:
    """(area, x0, y0, x1, y1) per 4-connected component (no scipy in this venv)."""
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    out = []
    for y in range(h):
        for x in range(w):
            if not mask[y, x] or seen[y, x]:
                continue
            q = deque([(y, x)])
            seen[y, x] = True
            area = 0
            x0 = x1 = x
            y0 = y1 = y
            while q:
                cy, cx = q.popleft()
                area += 1
                x0, x1 = min(x0, cx), max(x1, cx)
                y0, y1 = min(y0, cy), max(y1, cy)
                for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                    if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
            out.append((area, x0, y0, x1, y1))
    out.sort(reverse=True)
    return out


def signature(pixels: np.ndarray) -> np.ndarray:
    q = np.clip(pixels // (256 // BINS), 0, BINS - 1).astype(int)
    idx = q[:, 0] * BINS * BINS + q[:, 1] * BINS + q[:, 2]
    hist = np.bincount(idx, minlength=BINS ** 3).astype(float)
    total = hist.sum()
    return hist / total if total else hist


def describe(mask: np.ndarray, rgb: np.ndarray) -> dict | None:
    comps = components(mask)
    if not comps:
        return None
    area, x0, y0, x1, y1 = comps[0]
    bw, bh = max(1, x1 - x0 + 1), max(1, y1 - y0 + 1)
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    kept = np.zeros_like(mask)
    # keep only the largest component so stray pixels cannot skew the signature
    kept[y0:y1 + 1, x0:x1 + 1] = mask[y0:y1 + 1, x0:x1 + 1]

    w = mask.shape[1]
    second = 0.0        # biggest other blob, character-sized
    second_far = 0.0    # ... of those, the biggest one that sits away from the main body
    for c_area, cx0, cy0, cx1, cy1 in comps[1:]:
        ratio = c_area / area if area else 0.0
        second = max(second, ratio)
        # a detached hand or boot hugs the body; another character stands apart
        dx = abs((cx0 + cx1) / 2 - cx) / w
        dy = abs((cy0 + cy1) / 2 - cy) / w
        if ratio >= EXTRA and max(dx, dy) > FAR:
            second_far = max(second_far, ratio)
    return {"area": area, "aspect": bw / bh, "fill": area / (bw * bh),
            "second": second, "second_far": second_far,
            "sig": signature(rgb[kept])}


def reference(take_dir: str, meta: dict) -> dict | None:
    ref = meta.get("reference_frame")
    if not ref:
        return None
    path = os.path.join(REPO_ROOT, ref)
    if not os.path.exists(path):
        return None
    with Image.open(path) as im:
        arr = np.asarray(im.convert("RGB")).astype(np.int16)
    mask = np.abs(arr - KEY).sum(axis=2) > TOL
    return describe(mask, arr)


def check(take_dir: str) -> dict:
    slug = os.path.basename(take_dir.rstrip("/"))
    claimed = next((s for s in CHARACTERS if slug.endswith(s)), None)
    meta_path = os.path.join(take_dir, "chroma.json")
    meta = json.load(open(meta_path, encoding="utf-8")) if os.path.exists(meta_path) else {}

    clip = None
    for name in ("clip.mp4", "clip.ogv"):
        p = os.path.join(take_dir, name)
        if os.path.exists(p):
            clip = p
            break
    if not clip:
        return {"slug": slug, "claimed": claimed, "verdict": "no-clip"}

    ref = reference(take_dir, meta)
    if ref is None:
        return {"slug": slug, "claimed": claimed, "verdict": "no-reference"}

    per = []
    for f in frames(clip):
        mask = np.abs(f - KEY).sum(axis=2) > TOL
        d = describe(mask, f)
        if d:
            per.append(d)
    if not per:
        return {"slug": slug, "claimed": claimed, "verdict": "empty"}

    worst_extra = max(d["second"] for d in per)
    far_extra = max(d["second_far"] for d in per)
    # fill ratio survives posing; the bounding-box aspect does not (a puppy raising
    # its tail changes it by 40%), so only fill and colour are scored
    shape_err = max(abs(d["fill"] / ref["fill"] - 1) for d in per)
    colour_err = float(np.median([np.abs(d["sig"] - ref["sig"]).sum() for d in per]))

    verdict = "ok"
    if far_extra > EXTRA or worst_extra >= CLOSE:
        verdict = "extra-cast"
    elif shape_err > SHAPE_TOL:
        verdict = "shape-drift"
    elif colour_err > COLOUR_TOL:
        verdict = "colour-drift"
    return {"slug": slug, "claimed": claimed, "verdict": verdict,
            "second_blob": round(worst_extra, 3),
            "second_far": round(far_extra, 3),
            "shape_err": round(shape_err, 3),
            "colour_err": round(colour_err, 3)}


def discover() -> list[str]:
    if not os.path.isdir(OUT):
        print(
            f"identity_check: no {os.path.relpath(OUT, REPO_ROOT)}/ yet — render "
            "the per-character takes first, or name the directories to check.",
            file=sys.stderr,
        )
        return []
    dirs = []
    for name in sorted(os.listdir(OUT)):
        p = os.path.join(OUT, name)
        if os.path.isdir(p) and any(tag in name for tag in CHARACTERS):
            dirs.append(p)
    return dirs


def main(argv: list[str]) -> int:
    as_json = "--json" in argv
    args = [a for a in argv if not a.startswith("--")]
    dirs = [os.path.abspath(a) for a in args] if args else discover()
    rows = [check(d) for d in dirs]
    bad = [r["slug"] for r in rows if r["verdict"] != "ok"]
    if as_json:
        print(json.dumps({"takes": rows, "bad": bad}, indent=2))
    else:
        print(f"{'take':42} {'cast':8} {'2nd':>6} {'far':>6} {'shape':>6} {'colour':>7}  verdict")
        for r in rows:
            if r["verdict"] in ("no-clip", "no-reference", "empty"):
                print(f"{r['slug']:42} {str(r['claimed']):8} {'-':>6} {'-':>6} {'-':>6} {'-':>7}  {r['verdict']}")
                continue
            print(f"{r['slug']:42} {str(r['claimed']):8} {r['second_blob']:6.2f} "
                  f"{r['second_far']:6.2f} {r['shape_err']:6.2f} "
                  f"{r['colour_err']:7.3f}  {r['verdict']}")
        print(f"\n{len(rows)} takes, {len(bad)} rejected")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
