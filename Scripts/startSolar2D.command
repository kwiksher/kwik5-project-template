#!/bin/bash
# start_simulator.command
# Usage: ./start_simulator.command [-scale 1x|2x] [--singleton]

SCALE_ARG="1x"
SINGLETON=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -scale|--scale)
      SCALE_ARG="$2"
      shift 2
      ;;
    --singleton)
      SINGLETON=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-scale 1x|2x] [--singleton]"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

case "$SCALE_ARG" in
  1x|1)
    SCALE_NUM=1
    SKIN='KwikEditorLandscape'
    ;;
  2x|2)
    SCALE_NUM=2
    SKIN='KwikEditorLandscape2x'
    ;;
  *)
    echo "Invalid scale: $SCALE_ARG. Use 1x or 2x"
    exit 1
    ;;
esac

MAIN_DIR="Solar2D"
MAIN_FILE="$MAIN_DIR/main.lua"
if [ -f "$MAIN_FILE" ]; then
  if grep -q -E 'scale[[:space:]]*=[[:space:]]*[0-9]+' "$MAIN_FILE"; then
    sed -i '' -E '1,/scale[[:space:]]*=[[:space:]]*[0-9]+/s/(scale[[:space:]]*=[[:space:]]*)[0-9]+/\1'$SCALE_NUM'/' "$MAIN_FILE"
  else
    echo 'scale assignment not found or ambiguous'
    exit 1
  fi
  echo "Updated $MAIN_FILE scale to $SCALE_NUM"
else
  echo "$MAIN_FILE not found in $(pwd)"
fi

LOG="tmp.log"
SIMULATOR_BIN="/Applications/Corona/Corona Simulator.app/Contents/MacOS/Corona Simulator"

if [[ "$SINGLETON" -eq 1 ]]; then
  EXISTING_PIDS=$(pgrep -f "$SIMULATOR_BIN" || true)
  if [[ -n "$EXISTING_PIDS" ]]; then
    echo "Stopping existing Corona Simulator instance(s)..."
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && kill "$pid"
    done <<< "$EXISTING_PIDS"
    sleep 1
  fi
fi

(cd "$MAIN_DIR" && "$SIMULATOR_BIN" -no-console YES -skin "$SKIN" main.lua > "../$LOG" 2>&1 &)
sleep 0.5
code "$LOG"
