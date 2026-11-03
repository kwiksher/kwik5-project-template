#!/usr/bin/env python3
"""Make one larger source per page, so the bleed is a crop and nothing repeats.

The page frame is 1920x1280 (1.5:1) and the plate the Simulator sees is
2776x1440 (1.928:1). Two ways to get from one to the other:

* invent the extra 428/80 px (any ``extend:`` mode) — every invented band is a
  repetition of pixels the reader can already see, and mirror-*tiling* is how the
  "second cottage" defect happened;
* enlarge the approved composition once and crop both sizes out of the same
  enlargement. Every pixel in the plate is then a real pixel of the approved art.

This script does the second: it writes ``art/bg-large.png`` at
``ceil(1280 * 2776 / 1920) x 2776`` = **2776x1852**, the smallest enlargement whose
centre 2776x1440 still contains the full 1920x1280 frame. ``create_layered_psd``
then crops

    bleed plate  2776x1440  = centre of 2776x1852   (205 px off the top, 206 off
                                                    the bottom)
    page plate   1920x1280  = centre of the same file — a concentric crop, so the
                                                    frame is pixel-for-pixel the
                                                    middle of the bleed

Engines
-------
``lanczos`` (default) resamples once with Pillow's Lanczos filter. At 1.4458x this
is a near-lossless enlargement: it adds no detail and invents nothing.

``guaardvark`` sends the plate to the Guaardvark Upscaling service (Real-ESRGAN /
HAT-L). It is kept because a GAN upscale is the nicer source when a GPU is
available, but on this box the service is CPU-only (health reports
``gpu: N/A``): HAT-L 4x on 1920x1280 burned a full core for minutes without
finishing, and Real-ESRGAN had not finished a single 480x320 tile after three
minutes. Eleven pages that way is hours of CPU for an enlargement that needs to
be near-lossless, not hallucinated — so the default is ``lanczos`` and the
choice is recorded in each ``page.model.md``.

Usage
-----
    Scripts/upscale_plates.py --all                  # every page, Lanczos
    Scripts/upscale_plates.py p1 p3                  # some pages
    Scripts/upscale_plates.py --all --engine guaardvark --model RealESRGAN_x4plus
    Scripts/upscale_plates.py --check                # verify only, no writes
"""

from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
import time
from typing import Any

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from book_config import BOOK  # noqa: E402
from paths import PAGES_DIR, page_yaml, rel  # noqa: E402

import yaml  # noqa: E402
from PIL import Image  # noqa: E402

# The enlargement: the plate is 2776x1440, the frame 1920x1280, so the large
# source must be tall enough that its centre 1440 rows still hold all 1280.
FRAME_W, FRAME_H = 1920, 1280
PLATE_W, PLATE_H = 2776, 1440
LARGE_W = PLATE_W
LARGE_H = -(-FRAME_H * PLATE_W // FRAME_W)  # ceil -> 1851
if LARGE_H % 2:  # the PSD/emitter lint rejects odd layer sizes, and the extra
    LARGE_H += 1  # row is harmless once it is cropped off again -> 1852
CROP_TOP = (LARGE_H - PLATE_H) // 2  # 206
CROP_BOTTOM = LARGE_H - PLATE_H - CROP_TOP  # 206


def die(msg: str, code: int = 2) -> None:
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def md5(path: str) -> str:
    with open(path, "rb") as fh:
        return hashlib.md5(fh.read()).hexdigest()


def approved_plate(page: str) -> Image.Image:
    """The 1920x1280 composition as approved — cropped, then fitted, as the emitter does."""
    import create_layered_psd as psd
    import fountain2pages as f2p

    image_rel, _provenance = f2p.art_for(page)
    source = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), image_rel)
    if not os.path.exists(source):
        die(f"{page}: approved art not found: {image_rel}")
    with Image.open(source) as im:
        img = psd.apply_crop(im, f2p.CROPS.get(page)).convert("RGB")
    return psd.fit_into(img, FRAME_W, FRAME_H, "cover").convert("RGB")


def _guaardvark_upscale(path: str, model: str, scale: float, server: str | None) -> str:
    """Queue one image on the Guaardvark upscaler and wait for its output path."""
    cli = os.environ.get("GUAARDVARK_CLI", "guaardvark")
    base = [cli, "upscale"]
    if server:
        base += ["--server", server]

    def call(args: list[str], json_out: bool = True) -> str:
        cmd = base + args + (["--json"] if json_out else [])
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
        if proc.returncode != 0:
            die(f"{' '.join(cmd)} failed: {proc.stderr.strip() or proc.stdout.strip()}")
        return proc.stdout

    import json

    payload = json.loads(call(["image", path, "--model", model, "--scale", f"{scale:.6f}"]))
    if payload.get("status") != "success":
        die(f"upscale request rejected: {payload}")
    job_id = payload["data"]["job_id"]

    deadline = time.time() + 3600
    while time.time() < deadline:
        status = json.loads(call(["status", job_id]))
        data = status.get("data", status)
        state = str(data.get("status", ""))
        if state in {"completed", "complete", "succeeded"}:
            outputs = data.get("outputs") or []
            if not outputs:
                die(f"job {job_id} completed with no outputs")
            return str(outputs[0])
        if state in {"failed", "error", "cancelled"}:
            die(f"job {job_id} {state}: {data.get('error')}")
        time.sleep(5)
    die(f"job {job_id} did not finish within the hour")


def build_large(page: str, engine: str, model: str, server: str | None, check: bool) -> tuple[str, str]:
    """(status, message) for one page."""
    target = os.path.join(PAGES_DIR, page, "art", "bg-large.png")

    if check:
        if not os.path.exists(target):
            return "missing", f"{page}: {rel(target)} missing — run Scripts/upscale_plates.py --all"
        with Image.open(target) as im:
            if im.size != (LARGE_W, LARGE_H):
                return "stale", f"{page}: {rel(target)} is {im.width}x{im.height}, want {LARGE_W}x{LARGE_H}"
        return "ok", f"{page}: {rel(target)} {LARGE_W}x{LARGE_H} md5 {md5(target)}"

    plate = approved_plate(page)

    if engine == "guaardvark":
        tmp = os.path.join("/tmp", f"{BOOK}-{page}-plate.png")
        plate.save(tmp, format="PNG")
        produced = _guaardvark_upscale(tmp, model, LARGE_W / FRAME_W, server)
        with Image.open(produced) as im:
            large = im.convert("RGB").resize((LARGE_W, LARGE_H), Image.LANCZOS)
    else:
        large = plate.resize((LARGE_W, LARGE_H), Image.LANCZOS)

    os.makedirs(os.path.dirname(target), exist_ok=True)
    large.save(target, format="PNG", optimize=True)
    return "wrote", f"{page}: {rel(target)} {LARGE_W}x{LARGE_H} md5 {md5(target)}"


def page_ids() -> list[str]:
    import glob

    return sorted(
        os.path.basename(os.path.dirname(p))
        for p in glob.glob(os.path.join(PAGES_DIR, "*", "page.layers.yaml"))
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="upscale the approved 1920x1280 plate to 2776x1852 so the bleed is a crop"
    )
    parser.add_argument("pages", nargs="*", help="page ids (default with --all: every page)")
    parser.add_argument("--all", action="store_true", help="every page under the page tree")
    parser.add_argument(
        "--engine",
        choices=["lanczos", "guaardvark"],
        default=os.environ.get("BOOK_UPSCALE_ENGINE", "lanczos"),
        help="resampler (default lanczos; see the module docstring for why)",
    )
    parser.add_argument("--model", default="RealESRGAN_x4plus", help="Guaardvark model id")
    parser.add_argument("--server", default=None, help="Guaardvark server URL")
    parser.add_argument("--check", action="store_true", help="verify, write nothing")
    args = parser.parse_args(argv)

    pages = page_ids() if args.all else (args.pages or page_ids())
    if not pages:
        die(f"no page.layers.yaml under {rel(PAGES_DIR)}")

    problems = 0
    for page in pages:
        status, message = build_large(page, args.engine, args.model, args.server, args.check)
        print(f"  {status:<7} {message}")
        if status in {"missing", "stale"}:
            problems += 1

    if problems:
        print(f"\n{problems}/{len(pages)} page(s) need a large source", file=sys.stderr)
        return 1
    if not args.check:
        print(
            f"\nok: {len(pages)} large source(s) — {LARGE_W}x{LARGE_H}, "
            f"centre {PLATE_W}x{PLATE_H} crops the bleed, centre {FRAME_W}x{FRAME_H} the page "
            f"(engine {args.engine})"
        )
    else:
        print(f"\nok: {len(pages)} large source(s) present")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
