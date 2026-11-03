#!/usr/bin/env python3
"""The book's own data, loaded from ``Scripts/book.yaml``.

The pipeline scripts are generic; a *book* is the data that makes them concrete:

    book:            the Solar2D app name / Photoshop page-tree name
    canvas, bg:      render contract (safe area, background plate size)
    art_direction:   the style clause every prompt ends with
    cast:            characters and environments — identity + descriptions
    placement:       page -> [character, x, y, w, h] (PSD pixels, centres)
    crops:           page -> dead band to trim off a render
    design_book:     app name for the design/asset-preview book

Before this module that data lived inside `fountain2pages.py` (cast, placement),
`cast_sheets.py` (cast), `render_layered.py` (sprites) and `identity_check.py`
(character names), so reusing the pipeline for a second book meant edits in five
files. Now it is one YAML file, and those scripts read it from here.

Every accessor has a neutral default, so a checkout with no `book.yaml` still
imports and runs (it just has no cast and no placements).

    BOOK_YAML   override the config path (absolute, or relative to repo root)
    BOOK        override just the book name (also honoured by `paths.py`)
"""

from __future__ import annotations

import os
from typing import Any

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CONFIG_PATH = os.environ.get("BOOK_YAML") or os.path.join(
    REPO_ROOT, "Scripts", "book.yaml"
)


def _load() -> dict[str, Any]:
    if not os.path.exists(CONFIG_PATH):
        return {}
    try:
        import yaml
    except ImportError:  # the pipeline works without the config, but warns loudly
        print(
            f"book_config: {CONFIG_PATH} exists but PyYAML is not installed "
            "(pip install pyyaml); ignoring the book's own data.",
        )
        return {}
    with open(CONFIG_PATH, encoding="utf-8") as fh:
        data = yaml.safe_load(fh) or {}
    if not isinstance(data, dict):
        raise SystemExit(f"{CONFIG_PATH}: expected a mapping at the top level")
    return data


CFG: dict[str, Any] = _load()

#: Solar2D app name and Photoshop page-tree name, e.g. ``Photoshop/<book>/<page>``.
BOOK: str = os.environ.get("BOOK") or str(CFG.get("book") or "book")

CANVAS: dict[str, Any] = dict(CFG.get("canvas") or {"width": 1920, "height": 1280, "scale": 0.25})
BG: dict[str, Any] = dict(CFG.get("bg") or {"width": 2776, "height": 1440})

ART_DIRECTION: str = str(CFG.get("art_direction") or "").strip()

#: Cast registry: tag -> {name, subject_id, trigger, kind, description, ...}.
#: ``kind`` is ``character`` or ``environment``; both are tagged in the fountain.
CAST: dict[str, dict[str, Any]] = dict(CFG.get("cast") or {})

#: page id -> [(tag, x, y, w, h), ...] in PSD pixels, ordered back to front.
PLACEMENT: dict[str, list[tuple[str, int, int, int, int]]] = {
    str(page): [tuple(entry) for entry in entries]  # type: ignore[misc]
    for page, entries in (CFG.get("placement") or {}).items()
}

#: page id -> {"top"|"bottom"|"left"|"right": fraction of the render to cut.
CROPS: dict[str, dict[str, float]] = {
    str(page): {str(edge): float(frac) for edge, frac in edges.items()}
    for page, edges in (CFG.get("crops") or {}).items()
}

#: App name for the design/asset-preview book (sprites, contact sheets).
DESIGN_BOOK: str = str(CFG.get("design_book") or f"{BOOK}_design")

#: Character tags only, back-to-front order preserved from ``cast`` insertion order.
CHARACTERS: list[str] = [
    tag for tag, entry in CAST.items() if entry.get("kind", "character") == "character"
]

#: Environment tags (backdrops, locations).
ENVIRONMENTS: list[str] = [
    tag for tag, entry in CAST.items() if entry.get("kind") == "environment"
]


#: Optional frozen predecessor: page -> bg image lookup for pages whose art was
#: authored before this book, e.g. ``archive/V1/Solar2D/App/<book>/assets/images``.
#: Empty when the book has no predecessor.
ARCHIVE_IMAGES: str = (
    os.path.join(REPO_ROOT, str(CFG["archive_images"]))
    if CFG.get("archive_images")
    else ""
)


def cast_entry(tag: str) -> dict[str, Any]:
    """The cast entry for *tag*, or an empty dict — never raises."""
    return CAST.get(tag, {})


def subject_ids(tags: list[str]) -> list[int]:
    return sorted(
        int(entry["subject_id"])
        for tag in tags
        if (entry := CAST.get(tag)) and "subject_id" in entry
    )


def triggers(tags: list[str]) -> list[str]:
    return [str(CAST[tag]["trigger"]) for tag in tags if CAST.get(tag, {}).get("trigger")]


if __name__ == "__main__":
    print(f"config:      {CONFIG_PATH}{'' if os.path.exists(CONFIG_PATH) else '  (absent)'}")
    print(f"book:        {BOOK}")
    print(f"design_book: {DESIGN_BOOK}")
    print(f"cast:        {', '.join(CAST) or '-'}")
    print(f"characters:  {', '.join(CHARACTERS) or '-'}")
    print(f"environments:{', '.join(ENVIRONMENTS) or '-'}")
    print(f"placement:   {len(PLACEMENT)} page(s): {', '.join(PLACEMENT) or '-'}")
    print(f"crops:       {len(CROPS)} page(s)")
