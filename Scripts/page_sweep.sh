#!/usr/bin/env bash
# Re-run the page sweep and regenerate Photoshop/<book>_design/evidence/page-sweep.log.
#
#   Scripts/page_sweep.sh            # all 17 pages
#   Scripts/page_sweep.sh text sync  # only the named pages (log is appended)
#
# For every page it: switches env.page in Solar2D/main.lua, relaunches the simulator, waits for the
# page's own capture hook to save app_<page>.png + page_<page>.png, copies the 480x320 page area to
# evidence/<page>.png, and appends page / colours / framing verdict / error count / timestamp to the
# log. This is the script behind the "17/17 framing PASS, 0 Lua errors" claim — the log is a build
# artefact, not a hand-kept note.
set -uo pipefail
cd "$(dirname "$0")/.."

K="${KWIK:-$HOME/workspace/kwik/kwik-visual-code-CLI/kwik5-CLI/kwik}"
PAGES=(thumbnailNavigation thumbnailNavigation_grid group group_annotated text text_themed image
       sprite sprite_texturepacker sprite_animate audio sync video video_png animation interaction record)
SELECTED=("$@")
[ ${#SELECTED[@]} -eq 0 ] && SELECTED=("${PAGES[@]}")

# Every capture in this sweep is taken in production mode: the editor paints its own chrome (the green
# page guide) into the stage capture, and the record of "no editor chrome" has to be true of the run.
python3 - <<'PY_MODE'
import re
p = "Solar2D/main.lua"; s = open(p).read()
s = re.sub(r'^env\.mode = "[^"]*"', 'env.mode = "production"', s, count=1, flags=re.M)
open(p, "w").write(s)
PY_MODE

LOG=Photoshop/<book>_design/evidence/page-sweep.log
[ ${#SELECTED[@]} -eq ${#PAGES[@]} ] && printf 'page\tcolours\tframing\terrors\ttime\n' > "$LOG"

SANDBOX="$HOME/Library/Application Support/Corona Simulator/Solar2D-25A024ACB0E7C931BC3D57FD948681E7"

for pg in "${SELECTED[@]}"; do
  python3 - "$pg" <<'PY'
import re, sys
p = "Solar2D/main.lua"
s = open(p).read()
s = re.sub(r'^env\.page\s*=\s*"[^"]*"', 'env.page = "%s"' % sys.argv[1], s, count=1, flags=re.M)
open(p, "w").write(s)
PY
  pkill -f "Corona Simulator" 2>/dev/null; sleep 2
  rm -f .kwik/logs/simulator.log
  timeout 45 "$K" run . >/dev/null 2>&1
  sleep 12
  .venv/bin/python - "$SANDBOX" "$pg" "$LOG" <<'PY'
import datetime, sys
from PIL import Image
sandbox, pg, log = sys.argv[1], sys.argv[2], sys.argv[3]
im = Image.open(f"{sandbox}/Documents/app_{pg}.png").convert("RGB").crop((240, 135, 720, 455))
im.save(f"Photoshop/<book>_design/evidence/{pg}.png")
text = open(".kwik/logs/simulator.log").read()
errors = text.count("ERROR")
if f"framing:{pg}]" in text and "PASS" in text.split(f"framing:{pg}]")[1][:200]:
    framing = "PASS"
elif "no card/bg" in text:
    framing = "skipped"
else:
    framing = "-"
with open(log, "a") as fh:
    fh.write(f"{pg}\t{len(set(im.getdata()))}\t{framing}\t{errors}\t{datetime.datetime.now():%H:%M:%S}\n")
print(f"{pg:26s} {len(set(im.getdata())):>6} colours  framing={framing:8s} errors={errors}")
PY
done

python3 - <<'PY_MODE'
import re
p = "Solar2D/main.lua"; s = open(p).read()
s = re.sub(r'^env\.mode = "[^"]*"', 'env.mode = "development"', s, count=1, flags=re.M)
open(p, "w").write(s)
PY_MODE

echo "log: $LOG"
