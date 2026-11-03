#!/usr/bin/env python3
"""Prove the Simulator is loading exactly the PNGs the pipeline produced.

`layers2lua.py` copies ``<pages>/<page>/png/<layer>.png`` into
``Solar2D/App/<book>/assets/images/<page>/<layer>.png`` and compares with
``filecmp`` at that moment.  That guards the copy it just made; it says nothing
about a tree that was rebuilt in a different order, an asset staged by hand, or
a PSD re-emitted after the install.  This gate is the standalone proof, meant to
run as the **last** step of a page build:

    $ Scripts/asset_gate.py            # or: build_book.sh (runs it for you)
    ok: 10/10 pages, 45/45 layer images match
    $ echo $?
    0

It checks two things per page, by md5:

1. every installed ``assets/images/<page>/<layer>.png`` against the processed
   layer PNG it was copied from — the file the Simulator actually loads;
2. the **PSD's** ``bg`` layer against that same source, by decoded RGBA hash, so
   a PSD rebuilt after the install cannot hide behind an unchanged PNG.

Failures are listed one per line and exit non-zero:

    p3/caption: installed 6e0b6a9b… != source 1b3f2c07…

``--check`` is accepted as a synonym (the mode name the other stages use).
"""

from __future__ import annotations

import argparse
import glob
import hashlib
import os
import sys
from typing import Any

import yaml

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from paths import (  # noqa: E402
    PAGES_DIR,
    installed_layer_png,
    page_psd,
    page_yaml,
    rel,
    source_layer_png,
)


def die(msg: str, code: int = 2) -> None:
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def md5_file(path: str) -> str:
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def md5_rgba(path: str) -> str:
    """md5 of decoded RGBA bytes — independent of PNG encoder settings."""
    from PIL import Image

    with Image.open(path) as im:
        return hashlib.md5(im.convert("RGBA").tobytes()).hexdigest()


def psd_layer_signature(psd_path: str, name: str) -> tuple[str, int, int, int, int] | None:
    """(rgba md5, left, top, width, height) for one PSD layer."""
    from psd_tools import PSDImage

    psd = PSDImage.open(psd_path)
    for layer in psd:
        if layer.name == name:
            image = layer.topil()
            if image is None:
                return None
            rgba = image.convert("RGBA")
            return (
                hashlib.md5(rgba.tobytes()).hexdigest(),
                layer.left,
                layer.top,
                layer.width,
                layer.height,
            )
    return None


def layers_of(page: str) -> list[dict[str, Any]]:
    with open(page_yaml(page), "r", encoding="utf-8") as fh:
        spec = yaml.safe_load(fh) or {}
    return [layer for layer in spec.get("layers", []) if layer.get("name")]


def page_ids() -> list[str]:
    found = [
        os.path.basename(os.path.dirname(path))
        for path in glob.glob(os.path.join(PAGES_DIR, "*", "page.layers.yaml"))
    ]
    return sorted(found)


def check_page(page: str) -> tuple[int, int, list[str]]:
    """(layers checked, layers matching, problems) for one page."""
    problems: list[str] = []
    layers = layers_of(page)
    checked = matched = 0

    for layer in layers:
        name = str(layer["name"])
        src = source_layer_png(page, name)
        dst = installed_layer_png(page, name)
        checked += 1
        if not os.path.exists(src):
            problems.append(f"{page}/{name}: missing source {rel(src)}")
            continue
        if not os.path.exists(dst):
            problems.append(f"{page}/{name}: missing installed {rel(dst)}")
            continue
        want, got = md5_file(src), md5_file(dst)
        if want == got:
            matched += 1
        else:
            problems.append(f"{page}/{name}: installed {got} != source {want}")

    # The PSD is a build artifact too: a stale PSD next to fresh PNGs is the
    # exact case this gate exists for, and the bg plate is the layer whose
    # provenance a reviewer will ask about.
    psd = page_psd(page)
    if not os.path.exists(psd):
        problems.append(f"{page}: missing {rel(psd)}")
    else:
        src = source_layer_png(page, "bg")
        if os.path.exists(src):
            sig = psd_layer_signature(psd, "bg")
            if sig is None:
                problems.append(f"{page}: PSD has no 'bg' layer")
            else:
                want = md5_rgba(src)
                got = sig[0]
                if want != got:
                    problems.append(f"{page}/bg: PSD {got} != source {want}")

    return checked, matched, problems


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="md5 gate: installed layer PNGs vs processed sources, PSD bg vs source"
    )
    parser.add_argument("pages", nargs="*", help="page ids (default: every page)")
    parser.add_argument(
        "--check",
        action="store_true",
        help="synonym for the default behaviour, kept for build_book.sh symmetry",
    )
    parser.add_argument("-q", "--quiet", action="store_true", help="only print failures")
    args = parser.parse_args(argv)

    if not os.path.isdir(PAGES_DIR):
        die(f"page tree not found: {rel(PAGES_DIR)}")

    pages = args.pages or page_ids()
    if not pages:
        die(f"no page.layers.yaml under {rel(PAGES_DIR)}")

    total_layers = total_matched = 0
    good_pages = 0
    problems: list[str] = []
    for page in pages:
        checked, matched, page_problems = check_page(page)
        total_layers += checked
        total_matched += matched
        problems += page_problems
        if not page_problems:
            good_pages += 1
            if not args.quiet:
                print(f"  ok {page}: {matched}/{checked} layer images")

    if problems:
        print(file=sys.stderr)
        for problem in problems:
            print(f"FAIL {problem}", file=sys.stderr)
        print(
            f"\n{good_pages}/{len(pages)} pages clean, "
            f"{total_matched}/{total_layers} layer images match",
            file=sys.stderr,
        )
        return 1

    print(
        f"ok: {good_pages}/{len(pages)} pages, "
        f"{total_matched}/{total_layers} layer images match"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
