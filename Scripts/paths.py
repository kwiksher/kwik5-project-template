#!/usr/bin/env python3
"""One place for every path the page pipeline derives from.

Before this module each script carried its own ``PAGES_DIR = .../pages``, so
moving the authored page tree meant a five-file edit and a rebuild that could
silently disagree with the emitter.  Now the tree root is decided once, here,
and every consumer imports it:

    Photoshop/<book>/<page>/page.model.md    authored model   (fountain2pages.py)
    Photoshop/<book>/<page>/page.layers.yaml authored layers  (fountain2pages.py)
    Photoshop/<book>/<page>/png/<layer>.png  processed layers (create_layered_psd.py)
    Photoshop/<book>/<page>/page.psd         Photoshop document
    Photoshop/<book>/_sprites/<character>.png  keyed character sprites

``<book>`` comes from ``Scripts/book.yaml`` (see ``book_config.py``); the page
tree is artwork, so it lives next to the other authored Photoshop material, not
at the repo root.  ``BOOK_PAGES_DIR`` overrides the page tree (absolute, or
relative to the repo root) so a scratch copy can be built without touching the
real one, and ``BOOK`` overrides just the name.

Install paths are derived from the same root, never typed twice:

    Solar2D/App/<book>/assets/images/<page>/<layer>.png   (emitted, installed)
    Solar2D/App/<book>/components/<page>/layers/*.lua     (emitted)
"""

from __future__ import annotations

import os

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

try:  # same directory, so this works however the script was invoked
    from book_config import BOOK  # noqa: F401
except ImportError:  # pragma: no cover — standalone use, e.g. copied elsewhere
    BOOK = os.environ.get("BOOK") or "book"

#: Authored page tree (models, YAML, PSDs, processed PNGs, sprites).
PAGES_DIR = os.path.abspath(
    os.environ.get("BOOK_PAGES_DIR") or os.path.join(REPO_ROOT, "Photoshop", BOOK)
)

#: Keyed character sprites shared by the layered pages.
SPRITE_DIR = os.path.join(PAGES_DIR, "_sprites")

#: Authored video store (stories.yaml, frames, requests) and the Photoshop root.
VIDEO_DIR = os.path.join(PAGES_DIR, "video")
PHOTOSHOP_DIR = os.path.dirname(PAGES_DIR)

#: Solar2D app root for the book.
BOOK_DIR = os.path.join(REPO_ROOT, "Solar2D", "App", BOOK)

#: Emitted layer Lua, one directory per page.
COMPONENTS_DIR = os.path.join(BOOK_DIR, "components")

#: Emitted layer PNGs, one directory per page; this is what the Simulator reads.
ASSETS_DIR = os.path.join(BOOK_DIR, "assets", "images")

#: Emitted clips and audio.
VIDEOS_DIR = os.path.join(BOOK_DIR, "assets", "videos")
AUDIOS_DIR = os.path.join(BOOK_DIR, "assets", "audios")


def rel(path: str) -> str:
    """Repo-relative form of *path*, for messages and comments."""
    try:
        return os.path.relpath(os.path.abspath(path), REPO_ROOT)
    except ValueError:  # different drive on Windows
        return path


def page_dir(page: str) -> str:
    return os.path.join(PAGES_DIR, page)


def source_layer_png(page: str, layer: str) -> str:
    """The processed layer PNG written by ``create_layered_psd.py``."""
    return os.path.join(PAGES_DIR, page, "png", f"{layer}.png")


def installed_layer_png(page: str, layer: str) -> str:
    """The copy the Simulator loads."""
    return os.path.join(ASSETS_DIR, page, f"{layer}.png")


def page_psd(page: str) -> str:
    return os.path.join(PAGES_DIR, page, "page.psd")


def page_yaml(page: str) -> str:
    return os.path.join(PAGES_DIR, page, "page.layers.yaml")


def page_model(page: str) -> str:
    return os.path.join(PAGES_DIR, page, "page.model.md")


def page_audios(page: str) -> str:
    return os.path.join(PAGES_DIR, page, "page.audios.yaml")


def page_layer_lua(page: str, layer: str) -> str:
    return os.path.join(COMPONENTS_DIR, page, "layers", f"{layer}.lua")
