#!/usr/bin/env bash
# Reproduce every generated page artifact from the text sources.
#
#   Scripts/book.fountain            (source of truth: scenes, tags, captions)
#     -> Photoshop/<book>/<page>/page.model.md   + page.layers.yaml + page.audios.yaml
#     -> Photoshop/<book>/<page>/page.psd        + png/<layer>.png      (Photoshop track)
#     -> Solar2D/App/<book>/components/<page>/layers/*.lua  (build artifact)
#
# `--check` mode writes nothing and exits non-zero if anything on disk differs
# from what the sources produce — that is the CI/regression gate.
#
# Usage:
#   Scripts/build_book.sh              # rebuild everything
#   Scripts/build_book.sh --check      # verify only
#
# Requires .venv with pyyaml, pillow, psd-tools (see docs/PIPELINE.md).
set -euo pipefail

cd "$(dirname "$0")/.."
PY="${PYTHON:-.venv/bin/python}"
MODE="${1:-}"

# The authored page tree is decided in Scripts/paths.py (default
# Photoshop/<book>); override with BOOK_PAGES_DIR to build a scratch copy.
BOOK_NAME="$(python3 -c 'import sys; sys.path.insert(0, "Scripts"); from book_config import BOOK; print(BOOK)' 2>/dev/null || echo book)"
export BOOK_PAGES_DIR="${BOOK_PAGES_DIR:-Photoshop/$BOOK_NAME}"

if [[ ! -x "$PY" ]]; then
  echo "error: $PY not found — create it with: uv venv .venv && uv pip install --python $PY pyyaml pillow psd-tools" >&2
  exit 2
fi

run() { if [[ "$MODE" == "--check" ]]; then "$@" --check; else "$@"; fi; }

# The bleed is a crop of a larger source, so that source has to exist first.
# It is derived (a near-lossless enlargement of the approved plate), so it is
# rebuilt only when missing or the wrong size.
if [[ "$MODE" == "--check" ]]; then
  echo "== 1/9 large sources (crop basis for the bleed)"
  "$PY" Scripts/upscale_plates.py --check | tail -1
else
  echo "== 1/9 large sources (crop basis for the bleed)"
  if ! "$PY" Scripts/upscale_plates.py --check >/dev/null 2>&1; then
    "$PY" Scripts/upscale_plates.py --all | tail -1
  else
    echo "   up to date"
  fi
fi

echo "== 2/9 fountain -> models + YAML"
run "$PY" Scripts/fountain2pages.py

echo "== 3/9 YAML -> PSD + per-layer PNG"
for yaml in "$BOOK_PAGES_DIR"/*/page.layers.yaml; do
  if [[ "$MODE" == "--check" ]]; then
    "$PY" Scripts/create_layered_psd.py "$yaml" --check >/dev/null
  else
    "$PY" Scripts/create_layered_psd.py "$yaml" >/dev/null
  fi
  echo "   $(dirname "$yaml")"
done

# page.model.md records the md5 of the overscan plate it points at, and that
# plate is written by step 2 — so re-run the model pass once the plates exist.
# On a built tree this is a no-op diff; on a clean tree it settles in one run.
if [[ "$MODE" != "--check" ]]; then
  echo "== 3b/9 model pass (bg provenance md5s)"
  "$PY" Scripts/fountain2pages.py | tail -1
fi

# A PSD written by psd-tools carries no embedded thumbnail, so the exporter
# panel's file list falls back to <page>/thumbnail.jpg. Cosmetic, hence skipped in
# --check: a stale preview is worth nobody's build failure.
if [[ "$MODE" != "--check" ]]; then
  echo "== 3c/9 panel thumbnails"
  "$PY" Scripts/psd_thumbnails.py | tail -1
fi

echo "== 4/9 YAML -> Solar2D layer Lua"
run "$PY" Scripts/layers2lua.py --all

echo "== 5/9 geometry proof (frame 480x320, bg bleed 107/20)"
if [[ "$MODE" == "--check" ]]; then
  "$PY" Scripts/frame_proof.py --all --skip-composite >/dev/null
  echo "   ok"
else
  "$PY" Scripts/frame_proof.py --all >/dev/null
  echo "   docs/evidence/frame_*.png, docs/evidence/final_*.png"
fi

echo "== 6/9 narration assets"
"$PY" Scripts/render_audio.py --check | tail -1

# The last step is the proof, not a rebuild: every installed layer PNG must be
# byte-identical to the processed source the build just wrote, and every PSD's
# bg layer must hash to that same source.  Non-zero exit lists the offenders.
echo "== 7/9 asset gate (installed PNGs vs sources, PSD bg)"
"$PY" Scripts/asset_gate.py --quiet

# The bleed is the only synthesised pixels in the book, so it is measured: the
# invented band must be a reflection of the *adjacent* edge (continuous join),
# never the opposite edge of the scene.
echo "== 8/9 overscan (crop is real pixels, no reflection, seam interior-like)"
"$PY" Scripts/overscan_check.py | tail -1

# The video track is derived from the same Fountain plus book.video.yaml: ten
# story records, their i2v request bodies, and the 16:9 reference frames. Not a
# book page, so it runs last and never blocks the page gate on a missing frame.
echo "== 9/9 video stories (book.video.yaml -> 10 stories + requests)"
if [[ "$MODE" == "--check" ]]; then
  "$PY" Scripts/video_stories.py --check
else
  "$PY" Scripts/video_stories.py --frames | tail -3
fi

echo
if [[ "$MODE" == "--check" ]]; then
  echo "ok: sources and generated files agree"
else
  echo "ok: rebuilt. Next: kwik asset check && kwik run . --skin kwikEditorLandscape"
fi
