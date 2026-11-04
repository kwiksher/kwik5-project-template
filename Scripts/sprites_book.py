#!/usr/bin/env python3
"""Author the `<book>_sprites` catalogue — every still the story book can stage.

A story book picks one still per character per page, so the pose library is
invisible in the book you read: you only ever see the handful of chosen stills.
This book is the index of it — one page per character showing *all* of that
character's stills with each pose labelled, plus a page for props and a contact
page with everything at thumbnail size. Reviewing the library inside the app is
how defects show up at all (a still with transparent pinholes looks fine on white
and is obvious over a panel).

Page layout: cream card, a stage panel the keyed stills read against, a title and
a legend, then the stills laid out as a grid with a label under each.

Authored here as ``page.layers.yaml`` so the existing generators do the rest:

    Scripts/build_sprites_book.sh            # build
    Scripts/build_sprites_book.sh --check    # verify only

which is: this script -> create_layered_psd.py (PSD + per-layer PNG) ->
layers2lua.py (Kwik components, installed assets, index.lua) -> asset gate.

Which characters get a page comes from ``Scripts/book.yaml``; which stills exist
comes from the sprite tree, so the catalogue cannot drift from the art.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import yaml

import fountain2pages as f2p
from book_config import CHARACTERS
from paths import BOOK, PAGES_DIR, REPO_ROOT, rel

CANVAS = {"width": 1920, "height": 1280, "scale": 0.25}
#: app/book name this catalogue lives under. When the generators are already pointed
#: at the catalogue (KWIK_BOOK=<book>_sprites) BOOK *is* the catalogue name.
CATALOGUE = BOOK if BOOK.endswith("_sprites") else f"{BOOK}_sprites"

#: The story book whose stills are catalogued. The catalogue has its own page tree
#: but *no* art of its own: the stills stay in the story book's _sprites/.
BASE_BOOK = BOOK[: -len("_sprites")] if BOOK.endswith("_sprites") else BOOK
SPRITES = f"Photoshop/{BASE_BOOK}/_sprites"

# Page furniture, in PSD px (layer centres, and box sizes).
TITLE = {"x": 960, "y": 100, "w": 1700, "h": 96, "fs": 54}
SUBTITLE = {"x": 960, "y": 178, "w": 1700, "h": 52, "fs": 23}
PANEL = {"x": 960, "y": 665, "w": 1800, "h": 930}
GRID = {"x0": 80, "w": 1760, "top": 216, "bottom": 1114, "label": 46}
FOOTER = {"x": 960, "y": 1200, "w": 1700, "h": 120, "fs": 18}

INK = "#221B14"
INK_MUTED = "#7A6A55"
# Muted sage, not near-black (#14110D read as a black slab against the cream
# cards). Sage keeps the keyed stills and the sand labels readable while
# staying inside the book's earth palette — same value as the design book's
# thumbnail grid panel. Alpha 0 (no fill) drops the stills into the page.
PANEL_COLOUR = "#5C6652"   # 0.36, 0.40, 0.32
LABEL_COLOUR = "#D8C6A8"
CARD_COLOUR = "#F4EDDF"
FONT = "/System/Library/Fonts/Helvetica.ttc"

# Which stills each page shows, and in which order. `standing` first because it is
# the character's baseline; the rest are the poses the story pages stage.
# One page per character (from book.yaml), then props, then the contact sheet.
PAGES: dict[str, dict] = {
    **{
        tag: {"character": tag, "title": f"{tag} · sprites"}
        for tag in CHARACTERS
    },
    "props": {"character": "props", "title": "props · stills"},
    "all": {"character": None, "title": "all sprites"},
}

COLUMNS = {**{tag: 4 for tag in CHARACTERS}, "props": 1, "all": 5}

# A page of one wide prop should not stretch it to the whole panel.
MAX_STILL_H = {"props": 560}

# Reading order for a catalogue is the story's order, not the alphabet. Optional:
# name -> rank for the poses this book actually uses; anything unlisted sorts after
# these, alphabetically. Leave empty for plain alphabetical order.
ORDER: dict[str, int] = {}


def stills_for(character: str) -> list[tuple[str, str]]:
    """[(pose name, repo-relative path)] for one character, `standing` first."""
    base = os.path.join(REPO_ROOT, SPRITES)
    found: list[tuple[str, str]] = []
    standing = os.path.join(base, f"{character}.png")
    if os.path.exists(standing):
        found.append(("standing", rel(standing)))
    poses_dir = os.path.join(base, character)
    if os.path.isdir(poses_dir):
        for name in sorted(os.listdir(poses_dir)):
            if name.endswith(".png"):
                found.append((name[:-4], rel(os.path.join(poses_dir, name))))
    found.sort(key=lambda item: (ORDER.get(item[0], 99), item[0]))
    return found


def all_stills() -> list[tuple[str, str, str]]:
    """[(label, repo-relative path)] across every character and the props."""
    out: list[tuple[str, str, str]] = []
    for character in CHARACTERS:
        for pose, path in stills_for(character):
            out.append((character, pose, path))
    for pose, path in stills_for("props"):
        out.append(("props", pose, path))
    return out


def text_layer(name: str, text: str, x: int, y: int, w: int, h: int, fs: int,
               colour: str, align: str = "left") -> dict:
    return {
        "name": name,
        "x": x,
        "y": y,
        "width": w,
        "height": h,
        "text": text,
        "font_size": fs,
        "font": FONT,
        "text_color": colour,
        "line_height": 1.3,
        "padding_x": 0,
        "padding_y": 0,
        "align": align,
    }


def colour_layer(name: str, x: int, y: int, w: int, h: int, colour: str,
                 opacity: float = 1.0) -> dict:
    layer = {
        "name": name,
        "x": x,
        "y": y,
        "width": w,
        "height": h,
        "color": colour,
    }
    if opacity < 1.0:
        layer["opacity"] = opacity
    return layer


def grid(items: list[tuple[str, str]], columns: int, cell_h: int,
         max_h: int | None = None) -> list[dict]:
    """Lay the stills out left to right, top to bottom, each with its pose label."""
    layers: list[dict] = []
    cell_w = GRID["w"] // columns
    for index, (label, path) in enumerate(items):
        col, row = index % columns, index // columns
        cx = GRID["x0"] + cell_w * col + cell_w // 2
        cell_top = GRID["top"] + row * cell_h
        still_h = cell_h - GRID["label"]
        if max_h:
            still_h = min(still_h, max_h)
        # a still is 768x1024 (3:4); contain it in (cell_w - 60) x still_h
        still_w = int(min(cell_w - 60, still_h * 0.75) )
        layers.append(
            {
                "name": f"still_{index + 1:02d}",
                "image": path,
                "x": cx,
                "y": cell_top + still_h // 2,
                "width": still_w - (still_w % 2),
                "height": still_h - (still_h % 2),
                "fit": "contain",
                "transparent_color": "auto",
                "transparent_tolerance": 40,
            }
        )
        layers.append(
            text_layer(
                f"label_{index + 1:02d}", label, cx, cell_top + still_h + GRID["label"] // 2,
                cell_w - 24, GRID["label"] - 6, 22, LABEL_COLOUR, align="center",
            )
        )
    return layers


def build_page(page: str) -> dict:
    spec = PAGES[page]
    character = spec["character"]
    columns = COLUMNS[page]

    if page == "all":
        entries = [(f"{c} · {p}" if c != "props" else p, path) for c, p, path in all_stills()]
        subtitle = (
            "every still in the library, thumbnails only — one page per character follows"
        )
        footer = (
            f"{len(entries)} stills from {SPRITES}/ · each is a static PNG, keyed on assembly; "
            "motion is the video track's job"
        )
    elif page == "props":
        entries = [(pose, path) for pose, path in stills_for("props")]
        subtitle = "objects a plate does not carry: keyed on the same flat backdrop as the cast"
        footer = (
            f"{len(entries)} prop still(s) from {SPRITES}/props/ · placed as their own layer, "
            "under the cast, by the page that needs them"
        )
    else:
        entries = [(pose, path) for pose, path in stills_for(character)]
        subtitle = f2p.CAST[character]["description"]
        footer = (
            f"{len(entries)} stills from {SPRITES}/{character}/ · one render per pose, keyed on "
            "assembly · the story book stages one still per page"
        )

    rows = max(1, (len(entries) + columns - 1) // columns)
    cell_h = (GRID["bottom"] - GRID["top"]) // rows

    layers: list[dict] = [
        colour_layer("card", CANVAS["width"] // 2, CANVAS["height"] // 2,
                     CANVAS["width"], CANVAS["height"], CARD_COLOUR),
        text_layer("title", spec["title"], TITLE["x"], TITLE["y"], TITLE["w"], TITLE["h"],
                   TITLE["fs"], INK),
        text_layer("legend", subtitle, SUBTITLE["x"], SUBTITLE["y"], SUBTITLE["w"],
                   SUBTITLE["h"], SUBTITLE["fs"], INK_MUTED),
        colour_layer("panel", PANEL["x"], PANEL["y"], PANEL["w"], PANEL["h"], PANEL_COLOUR),
    ]
    layers += grid(entries, columns, cell_h, MAX_STILL_H.get(page))
    layers.append(
        text_layer("footer", footer, FOOTER["x"], FOOTER["y"], FOOTER["w"], FOOTER["h"],
                   FOOTER["fs"], INK_MUTED)
    )

    return {
        "canvas": dict(CANVAS),
        "provenance": f"sprite catalogue page from {SPRITES} (stills are 768x1024 renders)",
        "layers": layers,
    }


def main(argv: list[str]) -> int:
    if "--help" in argv or "-h" in argv:
        # No argument parser: without this, `--help` is an unknown arg that falls
        # through and writes the catalogue wherever KWIK_BOOK points.
        print(__doc__)
        return 0
    if BOOK != CATALOGUE:
        print(
            f"warning: KWIK_BOOK={BOOK!r} — this writes the {rel(PAGES_DIR)} tree anyway "
            f"(expected {CATALOGUE})",
            file=sys.stderr,
        )
    written = unchanged = 0
    for page in PAGES:
        directory = os.path.join(PAGES_DIR, page)
        text = yaml.safe_dump(build_page(page), sort_keys=False, allow_unicode=True, width=100)
        path = os.path.join(directory, "page.layers.yaml")
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as fh:
                if fh.read() == text:
                    unchanged += 1
                    continue
        if "--check" in argv:
            # never touch the tree in check mode, not even a directory
            print(f"  stale: {rel(path)}")
            written += 1
            continue
        os.makedirs(directory, exist_ok=True)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(text)
        print(f"  wrote {rel(path)}")
        written += 1
    print(f"ok: {len(PAGES)} page(s), {written} written, {unchanged} unchanged")
    return 0 if not ("--check" in argv and written) else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
