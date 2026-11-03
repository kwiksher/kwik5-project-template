#!/usr/bin/env python3
"""The workaround for "Guaardvark cannot write a transparent video": key it out.

Guaardvark's video pipeline encodes H.264/H.265 ``yuv420p`` only — there is no
alpha channel in anything it writes and no option that adds one
(``docs/VIDEO-PRODUCTION.md`` §1). Stills are different: the image side can
return RGBA PNGs, and the page pipeline already keys character sprites.

So a moving character that must sit over a moving plate is rendered on a flat
chroma field and keyed here, once, with the *same* contract the stills use:

    probe   measure the key field a clip actually produced (gate)
    key     chroma -> alpha, with despill, to a format that carries alpha

Two rules this tool exists to enforce:

1. **Probe before you key.** A clip whose "flat green" is really a gradient, a
   lit cyclorama or half-covered by shadow will key badly no matter the
   parameters. ``probe`` reports the fraction of the border band that sits
   within tolerance of the named key colour; below ``--min-purity`` the clip is
   rejected rather than half-keyed.
2. **Despill before you scale.** Green fringes on hair and fur survive a resize
   and then read as a halo against the plate.

Usage
-----
    # gate: did the render actually produce a keyable field?
    python3 Scripts/chroma_key.py probe clip.mp4 --color '#00B140'

    # key to an alpha-carrying intermediate for compositing
    python3 Scripts/chroma_key.py key clip.mp4 -o clip.mov --format prores

    # key to a web/engine asset (VP9 + alpha, plays in Solar2D/Kwik, Chrome)
    python3 Scripts/chroma_key.py key clip.mp4 -o clip.webm --format webm

    # key to a PNG sequence (alpha, lossless, for Nuke/AE/ffmpeg overlays)
    python3 Scripts/chroma_key.py key clip.mp4 -o frames/clip_%04d.png --format pngseq

Exit codes: 0 ok, 1 probe below threshold, 2 bad input, 3 ffmpeg failed.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import shutil
import subprocess
import sys
import tempfile
from typing import Any

import numpy as np
from PIL import Image

DEFAULT_COLOR = "#00B140"


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def ffmpeg_bin() -> str:
    exe = shutil.which("ffmpeg")
    if not exe:
        raise SystemExit("ffmpeg not found on PATH")
    return exe


def ffprobe_bin() -> str:
    return shutil.which("ffprobe") or "ffprobe"


def parse_color(value: str) -> tuple[int, int, int]:
    v = str(value).strip().lstrip("#")
    if v.lower().startswith("0x"):
        v = v[2:]
    if len(v) != 6:
        raise SystemExit(f"--color wants #RRGGBB, got {value!r}")
    return int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16)


def hex_color(rgb: tuple[int, int, int]) -> str:
    return "0x%02X%02X%02X" % rgb


def probe_info(path: str) -> dict[str, Any]:
    out = subprocess.run(
        [ffprobe_bin(), "-v", "error", "-select_streams", "v:0", "-show_entries",
         "stream=width,height,r_frame_rate,nb_frames,pix_fmt,codec_name",
         "-show_entries", "format=duration", "-of", "json", path],
        capture_output=True, text=True,
    )
    if out.returncode != 0:
        raise SystemExit(f"not a readable video: {path}\n{out.stderr.strip()}")
    data = json.loads(out.stdout)
    stream = (data.get("streams") or [{}])[0]
    return {
        "width": int(stream.get("width") or 0),
        "height": int(stream.get("height") or 0),
        "pix_fmt": stream.get("pix_fmt"),
        "codec": stream.get("codec_name"),
        "fps": stream.get("r_frame_rate"),
        "duration": float((data.get("format") or {}).get("duration") or 0.0),
    }


def extract_frames(path: str, count: int, width: int | None = None) -> list[np.ndarray]:
    """Decode ``count`` evenly spaced frames to RGB arrays, never touching disk."""
    info = probe_info(path)
    dur = max(0.001, info["duration"])
    frames: list[np.ndarray] = []
    with tempfile.TemporaryDirectory() as tmp:
        for i in range(count):
            t = dur * (i + 0.5) / count
            png = os.path.join(tmp, f"f{i:03d}.png")
            subprocess.run(
                [ffmpeg_bin(), "-v", "error", "-ss", f"{t:.4f}", "-i", path,
                 "-frames:v", "1", "-y", png],
                capture_output=True,
            )
            if os.path.exists(png):
                with Image.open(png) as im:
                    frames.append(np.asarray(im.convert("RGB"), dtype=np.int16))
    if not frames:
        raise SystemExit(f"could not decode any frame from {path}")
    return frames


# ---------------------------------------------------------------------------
# probe
# ---------------------------------------------------------------------------

def border_band(img: np.ndarray, margin: int) -> np.ndarray:
    h, w, _ = img.shape
    m = max(1, min(margin, min(h, w) // 4))
    parts = [img[:m, :, :], img[-m:, :, :], img[:, :m, :], img[:, -m:, :]]
    return np.concatenate([p.reshape(-1, 3) for p in parts], axis=0)


def measure(frames: list[np.ndarray], key: tuple[int, int, int], tol: float, margin: int) -> list[dict[str, Any]]:
    k = np.array(key, dtype=np.int16)
    rows: list[dict[str, Any]] = []
    for idx, img in enumerate(frames):
        band = border_band(img, margin)
        d = np.sqrt(((band - k) ** 2).sum(axis=1))
        purity = float((d <= tol).mean())
        # spread of the field itself: a flat key has a small IQR per channel
        med = np.median(band, axis=0)
        q1, q3 = np.percentile(band, [25, 75], axis=0)
        rows.append(
            {
                "frame": idx,
                "key_purity": round(purity, 4),
                "median_rgb": [int(v) for v in med],
                "iqr": [round(float(v), 1) for v in (q3 - q1)],
                "distance_median": round(float(np.median(d)), 1),
                "distance_p95": round(float(np.percentile(d, 95)), 1),
            }
        )
    return rows


def cmd_probe(args: argparse.Namespace) -> int:
    key = parse_color(args.color)
    frames = extract_frames(args.input, args.samples)
    rows = measure(frames, key, args.similarity * 442.0, args.margin)
    worst = min(r["key_purity"] for r in rows)
    median = sorted(r["key_purity"] for r in rows)[len(rows) // 2]
    verdict = "ok" if worst >= args.min_purity else "reject"

    payload = {
        "input": os.path.abspath(args.input),
        "color": "#%02X%02X%02X" % key,
        "tolerance": round(args.similarity * 442.0, 1),
        "margin_px": args.margin,
        "samples": len(rows),
        "purity_median": round(median, 4),
        "purity_min": round(worst, 4),
        "threshold": args.min_purity,
        "verdict": verdict,
        "frames": rows,
    }
    print(json.dumps(payload, indent=2))

    if verdict == "reject":
        print(
            f"\nREJECT: the flattest border sample is {worst:.1%} within tolerance of "
            f"#{payload['color']} (need {args.min_purity:.0%}).\n"
            "This clip is not keyable as rendered. Re-render with the chroma contract "
            "(Scripts/book.video.yaml `chroma:` + a `chroma_shots` prompt), or use the "
            "i2v-over-the-composite route instead of a cut-out.",
            file=sys.stderr,
        )
        return 1
    return 0


# ---------------------------------------------------------------------------
# key
# ---------------------------------------------------------------------------

def filter_chain(args: argparse.Namespace) -> str:
    key = hex_color(parse_color(args.color))
    chain = [
        "format=yuv444p",
        f"chromakey={key}:{args.similarity:g}:{args.blend:g}",
    ]
    # ffmpeg's despill has one screen type per instance (Nuke's `mixed` does not
    # exist here), so `mixed` is the two passes in sequence.
    spills = {"none": [], "green": ["green"], "blue": ["blue"],
              "mixed": ["green", "blue"]}[args.despill]
    for spill in spills:
        chain.append(f"despill=type={spill}:mix={args.despill_mix:g}")
    chain.append("format=rgba")
    if args.erode:
        # A one-pixel alpha erosion kills the fringe that survives despill on fur.
        # Erosion is a per-plane threshold operation: thresholdN=0 leaves only the
        # fully-opaque neighbourhood, which is exactly a 1px alpha erode.
        chain.append(f"erosion=coordinates={args.erode}:threshold0=0:threshold1=0:threshold2=0:threshold3=0")
    if args.scale_to:
        w, h = args.scale_to
        chain.append(f"scale={w}:{h}:flags=lanczos")
    return ",".join(chain)


def encoder_args(fmt: str, args: argparse.Namespace) -> list[str]:
    if fmt == "prores":
        return ["-c:v", "prores_ks", "-profile:v", "4444", "-pix_fmt", "yuva444p10le",
                "-vendor", "apl0", "-qscale:v", "9"]
    if fmt == "webm":
        return ["-c:v", "libvpx-vp9", "-pix_fmt", "yuva420p", "-b:v", "0",
                "-crf", str(args.crf), "-auto-alt-ref", "0", "-row-mt", "1",
                "-tile-columns", "2", "-g", "240"]
    if fmt == "pngseq":
        return ["-pix_fmt", "rgba"]
    if fmt == "qt":
        return ["-c:v", "qtrle", "-pix_fmt", "argb"]
    raise SystemExit(f"unknown --format {fmt}")


def alpha_fractions(path: str) -> dict[str, Any]:
    """Decode one frame and report how much of it is actually transparent.

    VP9 stores alpha in a side plane that ffmpeg's *native* decoder silently
    drops; only libvpx applies it. A keyed file that decodes to "0% transparent"
    is the classic false success here, so the decoder is chosen per container.
    """
    ext = os.path.splitext(path)[1].lower()
    argv = [ffmpeg_bin(), "-v", "error"]
    if ext == ".webm":
        argv += ["-c:v", "libvpx-vp9"]
    with tempfile.TemporaryDirectory() as tmp:
        png = os.path.join(tmp, "probe.png")
        argv += ["-i", path, "-frames:v", "1", "-update", "1", "-y", png]
        subprocess.run(argv, capture_output=True)
        if not os.path.exists(png):
            return {"error": "could not decode a frame"}
        with Image.open(png) as im:
            arr = np.asarray(im.convert("RGBA"))
    alpha = arr[:, :, 3]
    return {
        "mode": im.mode,
        "transparent_fraction": round(float((alpha < 8).mean()), 4),
        "opaque_fraction": round(float((alpha > 247).mean()), 4),
        "alpha_range": [int(alpha.min()), int(alpha.max())],
    }


def cmd_verify(args: argparse.Namespace) -> int:
    res = alpha_fractions(args.input)
    real = (
        "error" not in res
        and res["transparent_fraction"] > args.min_transparent
        and res["opaque_fraction"] > 0
    )
    print(json.dumps({**res, "input": os.path.abspath(args.input),
                      "carries_alpha": bool(real)}, indent=2))
    if not real:
        print(
            "\nFAIL: this file decodes without usable alpha. Either the key removed "
            "everything (wrong --color/--similarity) or the container/decoder dropped "
            "the alpha plane (browsers and Solar2D need WebM VP9 read by libvpx).",
            file=sys.stderr,
        )
        return 1
    return 0


def cmd_key(args: argparse.Namespace) -> int:
    if not os.path.exists(args.input):
        print(f"no such file: {args.input}", file=sys.stderr)
        return 2
    info = probe_info(args.input)
    chain = filter_chain(args)
    argv = [ffmpeg_bin(), "-v", "error", "-stats", "-i", args.input,
            "-vf", chain, "-an"] + encoder_args(args.format, args)
    if args.format == "prores":
        argv += ["-movflags", "+faststart"]
    if args.format == "webm":
        argv += ["-deadline", "good", "-cpu-used", "2"]
    argv += ["-y", args.output]

    os.makedirs(os.path.dirname(os.path.abspath(args.output)) or ".", exist_ok=True)
    res = subprocess.run(argv)
    if res.returncode != 0:
        print("ffmpeg failed", file=sys.stderr)
        return 3

    summary = {
        "input": os.path.abspath(args.input),
        "output": os.path.abspath(args.output),
        "format": args.format,
        "input_pix_fmt": info["pix_fmt"],
        "filter": chain,
        "carries_alpha": True,
    }
    if not args.no_verify:
        summary["verified"] = alpha_fractions(args.output)
    print(json.dumps(summary, indent=2))
    print(
        f"\nkeyed {info['width']}x{info['height']} {info['duration']:.2f}s -> {args.output}\n"
        "alpha is now real; composite it (ffmpeg overlay, Solar2D, or the page pipeline) — "
        "never re-encode through yuv420p, which flattens alpha to black.",
        file=sys.stderr,
    )
    return 0


# ---------------------------------------------------------------------------
# cli
# ---------------------------------------------------------------------------

def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("probe", help="measure whether a clip actually produced a flat key field")
    p.add_argument("input")
    p.add_argument("--color", default=DEFAULT_COLOR)
    p.add_argument("--similarity", type=float, default=0.14,
                   help="0..1 of full chroma distance (ffmpeg units), default 0.14")
    p.add_argument("--margin", type=int, default=8, help="border band width in px")
    p.add_argument("--samples", type=int, default=9)
    p.add_argument("--min-purity", type=float, default=0.90)
    p.set_defaults(func=cmd_probe)

    k = sub.add_parser("key", help="chroma-key a clip to a format that carries alpha")
    k.add_argument("input")
    k.add_argument("-o", "--output", required=True)
    k.add_argument("--color", default=DEFAULT_COLOR)
    k.add_argument("--similarity", type=float, default=0.14)
    k.add_argument("--blend", type=float, default=0.06)
    k.add_argument("--despill", default="mixed", choices=["none", "green", "blue", "mixed"])
    k.add_argument("--despill-mix", type=float, default=0.55)
    k.add_argument("--erode", default="", help="erosion coordinates 0-255, e.g. '0-1' (1px alpha erode)")
    k.add_argument("--scale-to", nargs=2, type=int, metavar=("W", "H"), default=None)
    k.add_argument("--format", default="prores", choices=["prores", "webm", "pngseq", "qt"])
    k.add_argument("--crf", type=int, default=22)
    k.add_argument("--no-verify", action="store_true", help="skip the post-encode alpha check")
    k.set_defaults(func=cmd_key)

    v = sub.add_parser("verify", help="decode a keyed file and prove the alpha survived")
    v.add_argument("input")
    v.add_argument("--min-transparent", type=float, default=0.05)
    v.set_defaults(func=cmd_verify)

    args = ap.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
