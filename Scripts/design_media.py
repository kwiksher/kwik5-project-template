#!/usr/bin/env python3
"""Deterministic test media for the `<book>_design` book.

Everything here is generated, never downloaded, so the book builds offline and every
expected duration / dimension is known in advance and re-checkable.

    .venv/bin/python Scripts/design_media.py --make
    .venv/bin/python Scripts/design_media.py --check
    .venv/bin/python Scripts/design_media.py --thumbs

Outputs (all under Solar2D/App/<book>_design/assets/):

    images/shared/specimen_frame.png   1920x1280  the landscape page card (paper + plate + rule)
    images/shared/specimen_bg.png      1920x1280  the index background
    audios/short/design_blip.wav       0.6 s      one-shot
    audios/long/design_ambience.mp3   20.0 s      loop / fade
    audios/sync/design_sync.mp3        3.0 s      sentence track
    audios/sync/design_sync.txt                   `start end WORD` lines
    audios/sync/design_sync/{one,two,three}.mp3   1.0 s per-word clips
    videos/design_slate.mp4            6.0 s      burnt-in timecode + frame counter
    videos/design_seq/img0001..24.png  24 frames  same look, for video_png
    thumbnails/<page>.png              600x400    placeholder tiles (--thumbs)

Design notes:

* no wall-clock, no hostname, no random seed from the environment: two runs on the same
  Pillow produce identical PNG/WAV bytes, which `--check` relies on;
* the mp4 is produced by ffmpeg from a PNG sequence, so it is reproducible in content
  but not necessarily byte-identical (x264 writes encoder metadata);
* `--check` reads back with ffprobe, so a wrong duration or a 29.97 fps encode fails
  loudly instead of silently skewing the recording gate.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import random
import shutil
import struct
import subprocess
import sys
import wave

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:  # pragma: no cover
    sys.exit("Pillow is required: run with .venv/bin/python")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from book_config import DESIGN_BOOK
BOOK = DESIGN_BOOK
ASSETS = os.path.join(REPO, "Solar2D", "App", BOOK, "assets")
SOURCE = os.path.join(REPO, "Photoshop", BOOK)
MANIFEST = os.path.join(SOURCE, "media.manifest.json")

FFMPEG = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"
FFPROBE = shutil.which("ffprobe") or "/opt/homebrew/bin/ffprobe"

RATE = 44100
SEED = 20260101

# ---- palette (docs/DESIGN-BOOK-PLAN.md §5.2) -------------------------------

PAPER = (242, 232, 216)
PAPER_DARK = (233, 220, 199)
PLATE = (23, 19, 15)
INK = (43, 36, 27)
AMBER = (200, 162, 74)

#: landscape page card: 480x320 design box x 4, matching what the layer transform places
PAGE_W, PAGE_H = 1920, 1280
PLATE_H = 190
HEADER_RULE_Y = 210

SLATE_BG = (22, 20, 18)
SLATE_FG = (242, 232, 216)
SLATE_AMBER = (200, 162, 74)


def out(*parts: str) -> str:
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return path


def srcdir(*parts: str) -> str:
    path = os.path.join(SOURCE, *parts)
    os.makedirs(path, exist_ok=True)
    return path


# ---- images ----------------------------------------------------------------


def grain(width: int, height: int, seed: int) -> Image.Image:
    """Soft paper grain: noise at 1/4 resolution, upscaled, so it reads as fibre."""
    small = Image.new("L", (max(1, width // 4), max(1, height // 4)))
    rng = random.Random(seed)
    small.putdata([rng.randrange(96, 160) for _ in range(small.width * small.height)])
    return small.resize((width, height), Image.BICUBIC)


def paper(width: int, height: int, seed: int) -> Image.Image:
    base = Image.new("RGB", (width, height), PAPER)
    if height > 1:
        top, bottom = PAPER, PAPER_DARK
        grad = Image.new("RGB", (1, height))
        for y in range(height):
            t = y / (height - 1)
            grad.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
        base = grad.resize((width, height), Image.BILINEAR)
    tex = grain(width, height, seed)
    return Image.blend(base, Image.merge("RGB", (tex, tex, tex)), 0.10)


def make_specimen_frame(path: str) -> None:
    """Landscape page card: 1920x1280 = 480x320 design px at 4x."""
    w, h = 1920, 1280
    img = paper(w, h, SEED)
    draw = ImageDraw.Draw(img, "RGBA")

    # plate band across the bottom PLATE_H px, 82 % over the paper (§1.5)
    draw.rectangle([0, h - PLATE_H, w, h], fill=(*PLATE, 209))
    # rule line at the plate's top edge
    draw.rectangle([0, h - PLATE_H - 3, w, h - PLATE_H], fill=(*AMBER, 140))
    # 1 px inset border, 24 px inside
    draw.rectangle([24, 24, w - 25, h - 25], outline=(*INK, 38), width=1)
    # a hairline under the header block, so the title has a floor
    draw.rectangle([120, HEADER_RULE_Y, w - 120, HEADER_RULE_Y + 1], fill=(*INK, 28))

    img.save(path, "PNG", optimize=True)


def make_specimen_bg(path: str) -> None:
    w, h = 1920, 1280
    img = paper(w, h, SEED + 1)
    draw = ImageDraw.Draw(img, "RGBA")
    draw.rectangle([0, 0, w, h], fill=(235, 226, 211, 40))
    img.save(path, "PNG", optimize=True)


def _font(size: int):
    for candidate in (
        "/System/Library/Fonts/Supplemental/Georgia.ttf",
        "/System/Library/Fonts/Supplemental/Times New Roman.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ):
        if os.path.exists(candidate):
            try:
                return ImageFont.truetype(candidate, size)
            except OSError:
                continue
    return ImageFont.load_default()


def slate_frame(index: int, total: int, fps: int) -> Image.Image:
    """One 480x270 frame: timecode, frame counter, corner ticks."""
    w, h = 480, 270
    img = Image.new("RGB", (w, h), SLATE_BG)
    draw = ImageDraw.Draw(img)
    tick, arm = SLATE_AMBER, 26
    for x0, y0, dx, dy in (
        (0, 0, 1, 1),
        (w - 1, 0, -1, 1),
        (0, h - 1, 1, -1),
        (w - 1, h - 1, -1, -1),
    ):
        draw.line([(x0, y0), (x0 + dx * arm, y0)], fill=tick, width=3)
        draw.line([(x0, y0), (x0, y0 + dy * arm)], fill=tick, width=3)

    ms = round(index * 1000 / fps)
    mm, rem = divmod(ms, 60000)
    ss, msec = divmod(rem, 1000)
    draw.text((w // 2, 104), f"{mm:02d}:{ss:02d}.{msec:03d}", font=_font(56), fill=SLATE_FG, anchor="mm")
    draw.text((w // 2, 172), f"frame {index:03d} / {total - 1:03d}", font=_font(26), fill=SLATE_AMBER, anchor="mm")
    # a sweeping bar makes a dropped frame obvious even at thumbnail size
    x = round((index / max(1, total - 1)) * (w - 40)) + 20
    draw.line([(x, 210), (x, 246)], fill=SLATE_FG, width=4)
    draw.line([(20, 246), (w - 20, 246)], fill=(90, 84, 74), width=2)
    return img


def make_slate_mp4(path: str, tmp: str) -> None:
    fps, seconds = 30, 6
    total = fps * seconds
    frames = os.path.join(tmp, "slate")
    os.makedirs(frames, exist_ok=True)
    for i in range(total):
        slate_frame(i, total, fps).save(os.path.join(frames, f"f{i:04d}.png"))
    cmd = [
        FFMPEG, "-y", "-loglevel", "error",
        "-framerate", str(fps),
        "-i", os.path.join(frames, "f%04d.png"),
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20",
        "-movflags", "+faststart", "-an",
        path,
    ]
    run(cmd)


def make_seq(paths: list[str]) -> None:
    total = len(paths)
    for i, path in enumerate(paths):
        slate_frame(i, total, 12).save(path, "PNG", optimize=True)


# ---- audio -----------------------------------------------------------------


def write_wav(path: str, samples: list[float]) -> None:
    with wave.open(path, "wb") as fh:
        fh.setnchannels(1)
        fh.setsampwidth(2)
        fh.setframerate(RATE)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(round(v * 32767)))
        fh.writeframes(bytes(frames))


def tone(seconds: float, hz: float, peak: float, fade: float = 0.01) -> list[float]:
    n = int(seconds * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        env = 1.0
        if fade > 0:
            if t < fade:
                env = t / fade
            elif t > seconds - fade:
                env = max(0.0, (seconds - t) / fade)
        out.append(peak * env * math.sin(2 * math.pi * hz * t))
    return out


def silence(seconds: float) -> list[float]:
    return [0.0] * int(seconds * RATE)


def ambience(seconds: float, peak: float = 0.10) -> list[float]:
    """Filtered noise with a slow swell — quiet, loopable at the ends."""
    rng = random.Random(SEED + 7)
    n = int(seconds * RATE)
    out = []
    lp = 0.0
    for i in range(n):
        lp += 0.02 * (rng.uniform(-1.0, 1.0) - lp)
        t = i / RATE
        swell = 0.55 + 0.45 * math.sin(2 * math.pi * t / seconds - math.pi / 2)
        out.append(peak * swell * lp * 3.0)
    return out


def encode_mp3(wav_path: str, mp3_path: str, bitrate: str = "128k") -> None:
    run([FFMPEG, "-y", "-loglevel", "error", "-i", wav_path, "-b:a", bitrate, mp3_path])


def make_audio(tmp: str) -> None:
    blip = out("audios", "short", "design_blip.wav")
    write_wav(blip, tone(0.6, 1000.0, 0.5))

    amb_wav = os.path.join(tmp, "amb.wav")
    write_wav(amb_wav, ambience(20.0))
    encode_mp3(amb_wav, out("audios", "long", "design_ambience.mp3"))

    pitches = (440.0, 554.0, 659.0)
    sentence = []
    for hz in pitches:
        sentence += tone(1.0, hz, 0.45, fade=0.02)
    sync_wav = os.path.join(tmp, "sync.wav")
    write_wav(sync_wav, sentence)
    encode_mp3(sync_wav, out("audios", "sync", "design_sync.mp3"))

    for name, hz in zip(("one", "two", "three"), pitches):
        wav = os.path.join(tmp, name + ".wav")
        write_wav(wav, tone(1.0, hz, 0.45, fade=0.02))
        encode_mp3(wav, out("audios", "sync", "design_sync", name + ".mp3"))

    with open(out("audios", "sync", "design_sync.txt"), "w", encoding="utf-8", newline="\n") as fh:
        fh.write("0.0 1.0 ONE\n1.0 2.0 TWO\n2.0 3.0 THREE\n")


# ---- thumbnails ------------------------------------------------------------


def book_pages() -> list[str]:
    index = os.path.join(REPO, "Solar2D", "App", BOOK, "index.lua")
    pages: list[str] = []
    with open(index, encoding="utf-8") as fh:
        for line in fh:
            name = line.strip().strip('",').strip()
            if line.strip().startswith('"') and name:
                pages.append(name)
    return pages


def make_thumbs(force: bool = False) -> list[str]:
    """Portrait 400x600 placeholder tiles, one per page in index.lua.

    Real screenshots overwrite these during the G3 gate walk; the placeholders exist
    so the two navigation pages can render before any other page has been visited.
    """
    written = []
    for page in book_pages():
        path = out("thumbnails", page + ".png")
        if os.path.exists(path) and not force:
            continue
        w, h = 600, 400
        img = paper(w, h, SEED + 11)
        draw = ImageDraw.Draw(img, "RGBA")
        draw.rectangle([0, h - 90, w, h], fill=(*PLATE, 205))
        draw.text((w // 2, h - 45), page, font=_font(28), fill=PAPER, anchor="mm")
        draw.text((w // 2, 70), BOOK, font=_font(20), fill=INK, anchor="mm")
        draw.rectangle([18, 18, w - 19, h - 19], outline=(*INK, 40), width=1)
        img.save(path, "PNG", optimize=True)
        written.append(path)
    return written


# ---- cli -------------------------------------------------------------------


def run(cmd: list[str]) -> str:
    try:
        return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout
    except FileNotFoundError:
        sys.exit(f"missing binary: {cmd[0]}")
    except subprocess.CalledProcessError as exc:
        sys.exit(f"{cmd[0]} failed:\n{exc.stderr.strip()}")


def deterministic(paths: list[str]) -> dict[str, str]:
    result = {}
    for path in paths:
        with open(path, "rb") as fh:
            result[os.path.relpath(path, REPO)] = hashlib.md5(fh.read()).hexdigest()
    return result


def make(force: bool) -> int:
    tmp = os.path.join(SOURCE, ".media-tmp")
    os.makedirs(tmp, exist_ok=True)
    try:
        targets = {
            "frame": out("images", "shared", "specimen_frame.png"),
            "bg": out("images", "shared", "specimen_bg.png"),
            "slate": out("videos", "design_slate.mp4"),
        }
        if force or not os.path.exists(targets["frame"]):
            make_specimen_frame(targets["frame"])
            print(f"  ok {os.path.relpath(targets['frame'], REPO)}")
        if force or not os.path.exists(targets["bg"]):
            make_specimen_bg(targets["bg"])
            print(f"  ok {os.path.relpath(targets['bg'], REPO)}")

        make_audio(tmp)
        print("  ok audios (blip 0.6 s, ambience 20 s, sync 3 s + 3 word clips)")

        if force or not os.path.exists(targets["slate"]):
            make_slate_mp4(targets["slate"], tmp)
            print(f"  ok {os.path.relpath(targets['slate'], REPO)}")

        seq = [out("videos", "design_seq", f"img{i:04d}.png") for i in range(1, 25)]
        if force or not all(os.path.exists(p) for p in seq):
            make_seq(seq)
            print(f"  ok videos/design_seq/img0001..0024.png ({len(seq)} frames)")

        thumbs = make_thumbs(force=force)
        if thumbs:
            print(f"  ok thumbnails (placeholder): {len(thumbs)} tiles")

        # the mp4 carries encoder metadata, so it is checked, not hashed
        hashed = [
            targets["frame"], targets["bg"],
            out("audios", "short", "design_blip.wav"),
            out("audios", "long", "design_ambience.mp3"),
            out("audios", "sync", "design_sync.mp3"),
            out("audios", "sync", "design_sync.txt"),
            out("audios", "sync", "design_sync", "one.mp3"),
            out("audios", "sync", "design_sync", "two.mp3"),
            out("audios", "sync", "design_sync", "three.mp3"),
        ] + seq
        manifest = {
            "note": "generated by Scripts/design_media.py; the mp4 is checked with ffprobe, not hashed",
            "md5": deterministic(hashed),
        }
        with open(MANIFEST, "w", encoding="utf-8") as fh:
            json.dump(manifest, fh, indent=2, sort_keys=True)
            fh.write("\n")
        print(f"  ok {os.path.relpath(MANIFEST, REPO)} ({len(hashed)} files)")
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def probe(path: str) -> dict:
    raw = run([
        FFPROBE, "-v", "error",
        "-show_entries", "format=duration:stream=width,height,r_frame_rate,nb_frames,codec_name",
        "-of", "json", path,
    ])
    return json.loads(raw)


def check() -> int:
    problems: list[str] = []

    def need(cond: bool, msg: str) -> None:
        if not cond:
            problems.append(msg)

    # images
    for rel, size in (
        (("images", "shared", "specimen_frame.png"), (PAGE_W, PAGE_H)),
        (("images", "shared", "specimen_bg.png"), (PAGE_W, PAGE_H)),
    ):
        path = out(*rel)
        if not os.path.exists(path):
            problems.append(f"missing {os.path.relpath(path, REPO)}")
            continue
        with Image.open(path) as im:
            need(im.size == size, f"{rel[-1]}: {im.size} != {size}")

    # audio durations
    for rel, seconds in (
        (("audios", "short", "design_blip.wav"), 0.6),
        (("audios", "long", "design_ambience.mp3"), 20.0),
        (("audios", "sync", "design_sync.mp3"), 3.0),
        (("audios", "sync", "design_sync", "one.mp3"), 1.0),
        (("audios", "sync", "design_sync", "two.mp3"), 1.0),
        (("audios", "sync", "design_sync", "three.mp3"), 1.0),
    ):
        path = out(*rel)
        if not os.path.exists(path):
            problems.append(f"missing {os.path.relpath(path, REPO)}")
            continue
        got = float(probe(path)["format"]["duration"])
        need(abs(got - seconds) <= 0.05, f"{rel[-1]}: {got:.3f}s != {seconds:.1f}s")

    # sync text is byte-exact — the loader is column-based
    txt = out("audios", "sync", "design_sync.txt")
    if not os.path.exists(txt):
        problems.append("missing design_sync.txt")
    else:
        with open(txt, "rb") as fh:
            need(fh.read() == b"0.0 1.0 ONE\n1.0 2.0 TWO\n2.0 3.0 THREE\n", "design_sync.txt is not byte-exact")

    # mp4
    slate = out("videos", "design_slate.mp4")
    if not os.path.exists(slate):
        problems.append("missing design_slate.mp4")
    else:
        info = probe(slate)
        fmt = info["format"]
        stream = info["streams"][0]
        need(abs(float(fmt["duration"]) - 6.0) <= 0.1, f"slate duration {fmt['duration']} != 6.0")
        need(stream["width"] == 480 and stream["height"] == 270, f"slate size {stream['width']}x{stream['height']}")
        need(stream["r_frame_rate"] == "30/1", f"slate fps {stream['r_frame_rate']} != 30/1")
        need(stream.get("codec_name") == "h264", f"slate codec {stream.get('codec_name')}")

    # png sequence
    seq = [out("videos", "design_seq", f"img{i:04d}.png") for i in range(1, 25)]
    missing = [p for p in seq if not os.path.exists(p)]
    need(not missing, f"missing {len(missing)} sequence frames")
    for path in seq[:1]:
        if os.path.exists(path):
            with Image.open(path) as im:
                need(im.size == (480, 270), f"seq frame size {im.size}")

    # thumbnails
    pages = book_pages()
    missing_thumbs = [p for p in pages if not os.path.exists(out("thumbnails", p + ".png"))]
    need(not missing_thumbs, f"missing thumbnails: {', '.join(missing_thumbs)}")

    # determinism manifest
    if not os.path.exists(MANIFEST):
        problems.append("missing media.manifest.json")
    else:
        with open(MANIFEST, encoding="utf-8") as fh:
            recorded = json.load(fh)["md5"]
        for rel, digest in recorded.items():
            path = os.path.join(REPO, rel)
            if not os.path.exists(path):
                problems.append(f"missing {rel}")
                continue
            with open(path, "rb") as fh:
                if hashlib.md5(fh.read()).hexdigest() != digest:
                    problems.append(f"drift {rel}")

    for p in problems:
        print(f"FAIL {p}")
    if problems:
        return 3
    print(f"ok media: {len(pages)} thumbnails, {len(recorded)} hashed files, slate 6.0 s @ 30 fps")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--make", action="store_true", help="generate what is missing")
    ap.add_argument("--force", action="store_true", help="regenerate everything")
    ap.add_argument("--check", action="store_true", help="verify durations, dimensions, md5")
    ap.add_argument("--thumbs", action="store_true", help="(re)make placeholder thumbnails")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    if args.check:
        return check()
    if args.thumbs:
        written = make_thumbs(force=True)
        print(f"ok {len(written)} thumbnails")
        return 0
    if args.make or args.force:
        return make(force=args.force)
    ap.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
