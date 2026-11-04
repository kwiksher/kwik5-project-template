#!/usr/bin/env bash
# Build (or verify) the `<book>_sprites` catalogue — every still the story book can
# stage, as pages you can review in the app.
#
#   Scripts/build_sprites_book.sh            # build
#   Scripts/build_sprites_book.sh --check    # verify only, non-zero if anything is stale
#
# Same four transforms as the story book, with KWIK_BOOK pointed at the catalogue:
#
#   Scripts/sprites_book.py        -> Photoshop/<book>_sprites/<page>/page.layers.yaml
#   create_layered_psd.py          -> page.psd + png/<layer>.png
#   layers2lua.py                  -> Solar2D/App/<book>_sprites/{<page>.lua,components,assets,index.lua}
#   asset gate                     -> installed PNGs match their sources
#
# Every still comes from Photoshop/<book>/_sprites, so the catalogue cannot drift
# from the art the story pages stage — add a pose there, re-run this, and it appears.
# CHARACTERS come from Scripts/book.yaml, so a new character gets a page for free.
set -euo pipefail

cd "$(dirname "$0")/.."
PY="${PYTHON:-.venv/bin/python}"
MODE="${1:-}"

if [[ ! -x "$PY" ]]; then
  echo "error: $PY not found — create it with: uv venv .venv && uv pip install --python $PY pyyaml pillow psd-tools" >&2
  exit 2
fi

# the *base* book name: KWIK_BOOK is what this script is about to set, so ignore it
BOOK_NAME="$(python3 -c 'import os, sys; os.environ.pop("KWIK_BOOK", None); sys.path.insert(0, "Scripts"); from book_config import BOOK; print(BOOK)' 2>/dev/null || echo book)"
export KWIK_BOOK="${BOOK_NAME}_sprites"
PAGES_DIR="Photoshop/${KWIK_BOOK}"

run() { if [[ "$MODE" == "--check" ]]; then "$@" --check; else "$@"; fi; }

echo "== 1/4 catalogue pages (stills -> page.layers.yaml)"
run "$PY" Scripts/sprites_book.py

echo "== 2/4 YAML -> PSD + per-layer PNG"
for yaml in "$PAGES_DIR"/*/page.layers.yaml; do
  if [[ "$MODE" == "--check" ]]; then
    "$PY" Scripts/create_layered_psd.py "$yaml" --check >/dev/null
  else
    "$PY" Scripts/create_layered_psd.py "$yaml" >/dev/null
  fi
  echo "   $(dirname "$yaml")"
done

echo "== 3/4 YAML -> Kwik layer Lua + installed assets + index.lua"
run "$PY" Scripts/layers2lua.py --all

echo "== 4/4 asset gate (installed PNGs vs sources)"
"$PY" Scripts/asset_gate.py --quiet

if [[ "$MODE" == "--check" ]]; then
  echo
  echo "ok: catalogue pages and generated files agree"
else
  echo
  echo "ok: rebuilt $KWIK_BOOK. Open it by setting env.book = \"$KWIK_BOOK\" in Solar2D/main.lua"
fi
