#!/usr/bin/env python3
"""Encode clips to the only format `plugin.movie` can decode: Ogg Theora.

`plugin_movie` (https://github.com/ANSH3LL/plugin_movie) renders a video into a
`CoronaExternalTexture`, which is what makes video usable as a *display object*
in Solar2D — `ImageRect`, `Shape`, etc. — with play/pause/seek/loop and audio on
a normal channel. It decodes **Ogg Theora** and nothing else, through theoraplay,
which supports exactly one pixel format: `TH_PF_420`.

So every constraint here comes from the decoder, not from taste:

| constraint | why |
|---|---|
| `yuv420p` | theoraplay maps only `TH_PF_420`; anything else fails to load |
| video only, no alpha | Theora has no alpha plane — see "transparency" below |
| ≤ 2 audio channels | the plugin mixes into one Solar2D audio channel (mono/stereo only) |
| fps well under `config.lua`'s `fps` | playback is advanced from `enterFrame`; one decoded frame per tick |
| even dimensions | 4:2:0 chroma subsampling; odd sizes are rejected or mis-decoded |

**Transparency.** Theora cannot carry alpha, so a "transparent video" in Solar2D
is a green-screen clip plus a runtime key: `obj.fill.effect = "filter.chromaKey"`
on the `ImageRect` that holds the MovieTexture (the runtime ships
`kernel_filter_chromaKey_gl`; Kwiksher's filter reference lists it as
`filter.chroma-key`). Render with `Scripts/video_stories.py`'s chroma contract,
encode the *green* clip here, key in the engine. Do not key it to a `.webm` first —
Solar2D cannot play that.

Encoding needs an ffmpeg built with libtheora + libvorbis. The stock Homebrew
`ffmpeg` formula no longer ships libtheora; `ffmpeg-full` does. This script finds
one automatically (`$FFMPEG_THEORA`, then any `ffmpeg-full` in the Cellar, then
`ffmpeg` on PATH) and refuses to pretend.

Usage
-----
    python3 Scripts/to_ogv.py encode out/chroma_cover_green.mp4 -o out/chroma_cover_green.ogv
    python3 Scripts/to_ogv.py encode clip.mp4 -o clip.ogv --install      # also into the Solar2D app
    python3 Scripts/to_ogv.py verify out/chroma_cover_green.ogv
    python3 Scripts/to_ogv.py all                                        # every clip in out/
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import shutil
import subprocess
import sys
from typing import Any

import numpy as np
from PIL import Image

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from paths import VIDEOS_DIR
APP_VIDEO_DIR = VIDEOS_DIR
OUT_DIR = os.path.join(REPO_ROOT, "out")

#: The recipe from plugin_movie's README, unchanged. q:v 7 / q:a 5 is the
#: plugin author's own recommendation and the only combination ever tested
#: against theoraplay.
DEFAULT_VIDEO_Q = 7
DEFAULT_AUDIO_Q = 5
MAX_AUDIO_CHANNELS = 2


# ---------------------------------------------------------------------------
# ffmpeg discovery
# ---------------------------------------------------------------------------

def _has_theora(exe: str) -> bool:
    try:
        out = subprocess.run([exe, "-hide_banner", "-encoders"], capture_output=True, text=True, timeout=30)
    except Exception:
        return False
    return "libtheora" in out.stdout


def find_ffmpeg() -> str:
    candidates: list[str] = []
    env = os.environ.get("FFMPEG_THEORA")
    if env:
        candidates.append(env)
    # Homebrew's ffmpeg-full (keg-only); the default `ffmpeg` has no libtheora.
    candidates += sorted(glob.glob("/opt/homebrew/Cellar/ffmpeg-full/*/bin/ffmpeg"), reverse=True)
    candidates += sorted(glob.glob("/usr/local/Cellar/ffmpeg-full/*/bin/ffmpeg"), reverse=True)
    candidates.append(shutil.which("ffmpeg") or "ffmpeg")
    for exe in candidates:
        if exe and os.path.exists(exe) and _has_theora(exe):
            return exe
    raise SystemExit(
        "no ffmpeg with libtheora found.\n"
        "  brew install ffmpeg-full          # keg-only, includes libtheora + libvorbis\n"
        "  or set FFMPEG_THEORA=/path/to/ffmpeg\n"
        "The stock `ffmpeg` formula cannot encode Theora, and plugin.movie cannot\n"
        "decode anything else."
    )


def ffprobe_json(path: str) -> dict[str, Any]:
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", path],
        capture_output=True, text=True,
    )
    if out.returncode != 0:
        raise SystemExit(f"not a readable media file: {path}\n{out.stderr.strip()}")
    return json.loads(out.stdout)


def video_stream(info: dict[str, Any]) -> dict[str, Any]:
    for s in info.get("streams") or []:
        if s.get("codec_type") == "video":
            return s
    raise SystemExit("no video stream")


def audio_stream(info: dict[str, Any]) -> dict[str, Any] | None:
    for s in info.get("streams") or []:
        if s.get("codec_type") == "audio":
            return s
    return None


# ---------------------------------------------------------------------------
# probe / verify
# ---------------------------------------------------------------------------

def probe_frame(path: str, at: float = 0.3) -> dict[str, Any]:
    """Decode one frame with ffmpeg and report whether it has any picture in it.

    A Theora file whose header is fine but whose frames are empty plays as a
    black rectangle and looks exactly like "the plugin is broken".
    """
    with __import__("tempfile").TemporaryDirectory() as tmp:
        png = os.path.join(tmp, "f.png")
        subprocess.run(["ffmpeg", "-v", "error", "-ss", f"{at:.3f}", "-i", path,
                        "-frames:v", "1", "-update", "1", "-y", png], capture_output=True)
        if not os.path.exists(png):
            return {"decoded": False}
        with Image.open(png) as im:
            arr = np.asarray(im.convert("RGB"), dtype=np.int16)
    return {
        "decoded": True,
        "mean": round(float(arr.mean()), 1),
        "std": round(float(arr.std()), 1),
        "size": [int(arr.shape[1]), int(arr.shape[0])],
    }


def verify(path: str, expect_fps_max: float = 30.0) -> int:
    info = ffprobe_json(path)
    v = video_stream(info)
    a = audio_stream(info)
    problems: list[str] = []

    if v.get("codec_name") != "theora":
        problems.append(f"video codec is {v.get('codec_name')}, plugin.movie needs theora")
    if v.get("pix_fmt") != "yuv420p":
        problems.append(f"pix_fmt is {v.get('pix_fmt')}, theoraplay only decodes TH_PF_420 (yuv420p)")

    w, h = int(v.get("width") or 0), int(v.get("height") or 0)
    if w % 2 or h % 2:
        problems.append(f"{w}x{h} is not even — 4:2:0 chroma needs even dimensions")
    elif w % 16 or h % 16:
        print(f"note: {w}x{h} is not a multiple of 16; Theora pads internally, it will play", file=sys.stderr)

    num, _, den = str(v.get("r_frame_rate") or "0/1").partition("/")
    fps = float(num) / float(den or 1) if float(den or 1) else 0.0
    if fps > expect_fps_max:
        problems.append(f"{fps:.0f} fps is above the {expect_fps_max:.0f} fps sanity limit "
                        "for frame-driven playback")

    if a is not None:
        if a.get("codec_name") != "vorbis":
            problems.append(f"audio codec is {a.get('codec_name')}, plugin.movie expects vorbis")
        if int(a.get("channels") or 0) > MAX_AUDIO_CHANNELS:
            problems.append(f"{a.get('channels')} audio channels; the plugin mixes mono/stereo only")

    frame = probe_frame(path)
    if not frame.get("decoded"):
        problems.append("no frame could be decoded")
    elif frame["std"] < 1.0:
        problems.append(f"frame looks blank (std {frame['std']})")

    report = {
        "file": os.path.relpath(path, REPO_ROOT) if path.startswith(REPO_ROOT) else path,
        "codec": v.get("codec_name"),
        "pix_fmt": v.get("pix_fmt"),
        "size": [w, h],
        "fps": round(fps, 3),
        "frames": int(v.get("nb_frames") or 0) or None,
        "duration_s": round(float((info.get("format") or {}).get("duration") or 0), 3),
        "audio": ({"codec": a.get("codec_name"), "channels": int(a.get("channels") or 0)} if a else None),
        "carries_alpha": False,
        "frame_check": frame,
        "ok": not problems,
        "problems": problems,
    }
    print(json.dumps(report, indent=2))
    if problems:
        for p in problems:
            print(f"FAIL {p}", file=sys.stderr)
        return 1
    return 0


# ---------------------------------------------------------------------------
# encode
# ---------------------------------------------------------------------------

def encode(src: str, dst: str, video_q: int, audio_q: int, fps: float | None,
           scale: tuple[int, int] | None, install: bool,
           crop: tuple[int, int, int, int] | None = None) -> int:
    """Encode `src` to Theora.

    `crop` is (x, y, w, h) in source pixels and is applied before scaling. It
    exists for split takes: a character occupies ~3-13 % of the chroma canvas,
    so shipping the whole flat field costs 512x288x4 = 590 KB of texture per
    layer and the same again uploaded every frame, for pixels that key straight
    out. Cropping is applied here, not to clip.mp4, so the master stays full
    canvas and can be re-cropped without a re-render.
    """
    ffmpeg = find_ffmpeg()
    info = ffprobe_json(src)
    v = video_stream(info)
    a = audio_stream(info)
    w, h = int(v.get("width") or 0), int(v.get("height") or 0)
    filters: list[str] = []
    if crop:
        cx, cy, cw, ch = crop
        # 4:2:0 needs even dimensions and an even origin, or the decoder
        # subsamples against the wrong phase.
        cw, ch, cx, cy = cw - cw % 2, ch - ch % 2, cx - cx % 2, cy - cy % 2
        filters.append(f"crop={cw}:{ch}:{cx}:{cy}")
        w, h = cw, ch
    if scale:
        w, h = scale
        filters.append(f"scale={w}:{h}:flags=lanczos")
    w -= w % 2
    h -= h % 2

    argv = [ffmpeg, "-v", "error", "-stats", "-i", src]
    if filters:
        argv += ["-vf", ",".join(filters)]
    argv += ["-c:v", "libtheora", "-q:v", str(video_q), "-pix_fmt", "yuv420p"]
    if fps:
        argv += ["-r", f"{fps:g}"]
    if a is not None:
        # -ac 2 unconditionally: a 5.1 source would otherwise pass through and
        # the plugin would play it wrong (README caveat).
        argv += ["-c:a", "libvorbis", "-q:a", str(audio_q), "-ac", str(MAX_AUDIO_CHANNELS)]
    else:
        argv += ["-an"]
    argv += ["-y", dst]

    os.makedirs(os.path.dirname(os.path.abspath(dst)) or ".", exist_ok=True)
    print(" ".join(argv), file=sys.stderr)
    if subprocess.run(argv).returncode != 0:
        print("ffmpeg failed", file=sys.stderr)
        return 3

    rc = verify(dst)
    if rc == 0 and install:
        os.makedirs(APP_VIDEO_DIR, exist_ok=True)
        target = os.path.join(APP_VIDEO_DIR, os.path.basename(dst))
        shutil.copy2(dst, target)
        print(f"installed -> {os.path.relpath(target, REPO_ROOT)}", file=sys.stderr)
    return rc


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("encode", help="mp4 -> theora .ogv, then verify it")
    e.add_argument("input")
    e.add_argument("-o", "--output")
    e.add_argument("--video-q", type=int, default=DEFAULT_VIDEO_Q)
    e.add_argument("--audio-q", type=int, default=DEFAULT_AUDIO_Q)
    e.add_argument("--fps", type=float, default=None,
                   help="re-time to this fps; keep it well under config.lua's fps")
    e.add_argument("--scale", nargs=2, type=int, metavar=("W", "H"))
    e.add_argument("--crop", metavar="X:Y:W:H",
                   help="crop to one character's box before encoding (split takes)")
    e.add_argument("--install", action="store_true",
                   help="also copy into Solar2D/App/<book>/assets/videos/")

    def _encode(a) -> int:
        crop = None
        if a.crop:
            try:
                crop = tuple(int(n) for n in a.crop.replace(",", ":").split(":"))
            except ValueError:
                crop = ()
            if len(crop) != 4:
                print(f"--crop wants x:y:w:h, got {a.crop!r}", file=sys.stderr)
                return 2
        return encode(a.input, a.output or os.path.splitext(a.input)[0] + ".ogv",
                      a.video_q, a.audio_q, a.fps,
                      tuple(a.scale) if a.scale else None, a.install, crop)

    e.set_defaults(func=_encode)

    v = sub.add_parser("verify", help="check a .ogv against everything theoraplay needs")
    v.add_argument("input")
    v.set_defaults(func=lambda a: verify(a.input))

    def _all(a) -> int:
        vids = sorted(f for f in glob.glob(os.path.join(OUT_DIR, "*.mp4")))
        if not vids:
            print(f"no clips in {OUT_DIR}", file=sys.stderr)
            return 2
        rc = 0
        for src in vids:
            dst = os.path.splitext(src)[0] + ".ogv"
            print(f"\n== {os.path.basename(src)}", file=sys.stderr)
            rc |= encode(src, dst, a.video_q, a.audio_q, a.fps, None, a.install)
        return rc

    al = sub.add_parser("all", help="encode every out/*.mp4")
    al.add_argument("--video-q", type=int, default=DEFAULT_VIDEO_Q)
    al.add_argument("--audio-q", type=int, default=DEFAULT_AUDIO_Q)
    al.add_argument("--fps", type=float, default=None)
    al.add_argument("--install", action="store_true")
    al.set_defaults(func=_all)

    a = ap.parse_args(argv)
    return int(a.func(a))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
