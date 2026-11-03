#!/usr/bin/env bash
# Record the review clip from the `record` page itself.
#
#   Scripts/record_clip.sh
#
# Why not `kwik record`: the plugin recorder photographs the editor viewport and on this rig returns a
# 480x294 frame holding only the page's bottom-right quadrant, so the badge and the footer line are
# mostly outside it (auditor). Instead the page's own capture hook saves 90 consecutive frames of its
# page group at 15 fps while RECORD_FRAMES is present, this script crops them to the 480x320 page area
# and encodes out/design.mp4 — a real, chrome-free recording of the page.
set -uo pipefail
cd "$(dirname "$0")/.."

K="${KWIK:-$HOME/workspace/kwik/kwik-visual-code-CLI/kwik5-CLI/kwik}"
SANDBOX="$HOME/Library/Application Support/Corona Simulator/Solar2D-25A024ACB0E7C931BC3D57FD948681E7"
OUT=out/design.mp4
TMP=$(mktemp -d "${TMPDIR:-/tmp}/kwik-record-XXXXXX")   # outside the repo: no untracked artefacts

touch Solar2D/RECORD_FRAMES
rm -f "$SANDBOX/Documents"/rec_*.png "$SANDBOX/Documents/rec_geom.txt"

python3 - <<'PY'
import re
p = "Solar2D/main.lua"; s = open(p).read()
s = re.sub(r'^env\.page\s*=\s*"[^"]*"', 'env.page = "record"', s, count=1, flags=re.M)
s = re.sub(r'^env\.mode = "[^"]*"', 'env.mode = "development"', s, count=1, flags=re.M)
open(p, "w").write(s)
PY

pkill -f "Corona Simulator" 2>/dev/null; sleep 2
rm -f .kwik/logs/simulator.log
timeout 45 "$K" run . >/dev/null 2>&1
sleep 18
rm -f Solar2D/RECORD_FRAMES

COUNT=$(ls "$SANDBOX/Documents"/rec_*.png 2>/dev/null | wc -l | tr -d ' ')
echo "frames saved: $COUNT"
if [ "$COUNT" -lt 60 ]; then
  echo "too few frames — aborting" >&2; exit 1
fi

.venv/bin/python - "$SANDBOX" "$TMP" <<'PY'
import glob, os, sys
from PIL import Image
sandbox, tmp = sys.argv[1], sys.argv[2]
geom = open(os.path.join(sandbox, "Documents", "rec_geom.txt")).read().split()
x0, y0, w, h, xmin, ymin = (float(v) for v in geom)
left, top = round(x0 - xmin), round(y0 - ymin)
box = (left, top, left + round(w), top + round(h))
files = sorted(glob.glob(os.path.join(sandbox, "Documents", "rec_*.png")))
for f in files:
    im = Image.open(f).convert("RGB").crop(box)
    im.save(os.path.join(tmp, os.path.basename(f)))
print("cropped %d frames to %dx%d (offset %d,%d)" % (len(files), box[2]-box[0], box[3]-box[1], left, top))
PY

mkdir -p out
ffmpeg -v error -y -framerate 15 -i "$TMP/rec_%03d.png" -c:v libx264 -pix_fmt yuv420p -r 15 "$OUT"

rm -rf "$TMP"

echo "--- $OUT"
ffprobe -v error -show_entries stream=width,height,r_frame_rate,nb_frames \
  -show_entries format=duration -of default=nw=1 "$OUT"
