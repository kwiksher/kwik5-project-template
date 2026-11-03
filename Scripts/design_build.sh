#!/usr/bin/env bash
# Build the design bench book (name from Scripts/book.yaml) with the kwik CLI.
#
# Landscape page canvas: 1920 x 1280 = 480 x 320 design px at 4x, which is exactly the box
# the layer transform places (docs/DESIGN-BOOK-PLAN.md §1.2). Coordinates are PSD px,
# layer centres; design px = PSD px / 4.
#
#   Scripts/design_build.sh                     # build everything
#   Scripts/design_build.sh group text          # only named pages (shared furniture included)
#   TEXT_TEMPLATES=on Scripts/design_build.sh   # option O3-B: palette text on every page
#
# Prerequisites: Scripts/design_media.py --make and Scripts/design_sheets.py --pack --install-cast
#
# Rules this script observes (docs/DESIGN-BOOK-PLAN.md §6.3, §8b):
#   * every `layer add` carries explicit --x/--y/--size: otherwise the layer is tiled into the
#     first free cell (lib/layer_ops.lua:594);
#   * every `command add` passes the COMPLETE parameter object from `kwik help command <verb>`:
#     the generator writes parameters positionally and leaves a blank for a missing one, which is
#     a Lua syntax error that kills the whole book at boot (DESIGN-BOOK-PLAN.md §8b.2);
#   * table-valued class props travel in checked-in files copied with `--layer <f>@<class>` (D9);
#   * the registry is checked in and copied, because `kwik asset sync` cannot write a non-empty
#     model.lua in this CLI build (§8b.1); `kwik asset check` is the gate.

set -euo pipefail

cd "$(dirname "$0")/.."
REPO="$(pwd)"

BOOK="$(python3 -c 'import sys; sys.path.insert(0, "Scripts"); from book_config import DESIGN_BOOK; print(DESIGN_BOOK)' 2>/dev/null || echo book_design)"
K="${KWIK:-/Users/ymmtny/workspace/kwik/kwik-visual-code-CLI/kwik5-CLI/kwik}"
SRC="Photoshop/$BOOK"
APP="Solar2D/App/$BOOK"
# the sprite benches use the book's first character, straight out of book.yaml
CAST0="$(python3 -c 'import sys; sys.path.insert(0, "Scripts"); from book_config import CHARACTERS; print(CHARACTERS[0] if CHARACTERS else "hero")' 2>/dev/null || echo hero)"
SHEET="${CAST0}_views"
TEXT_TEMPLATES="${TEXT_TEMPLATES:-off}"

PAGES=(
  thumbnailNavigation thumbnailNavigation_grid
  group group_annotated
  text text_themed
  image sprite sprite_texturepacker sprite_animate
  audio sync
  video video_png
  animation interaction
  record
)

# ---- landscape layout grid (PSD px on 1920 x 1280; design = /4) -------------
CARD_X=960; CARD_Y=640; CARD_W=1920; CARD_H=1280

KICKER_X=560;  KICKER_Y=70;   KICKER_W=800;  KICKER_H=60;  KICKER_FS=18
TITLE_X=960;   TITLE_Y=140;   TITLE_W=1300; TITLE_H=110;  TITLE_FS=48
HOME_X=1800;   HOME_Y=80;     HOME_W=130;   HOME_H=130
PLATE_Y=1185;  PLATE_H=190
BODY_X=960;    BODY_Y=1185;   BODY_W=1800;  BODY_H=150;   BODY_FS=22

# control row: four 260x100 slots
CTL_Y=1010; CTL_W=260; CTL_H=100
CTL_X0=510; CTL_X1=810; CTL_X2=1110; CTL_X3=1410

VIEW_X=960; VIEW_Y=560          # specimen viewport centre
VIEW_W=1400; VIEW_H=680         # x 260..1660, y 220..900

say()  { printf '\n== %s\n' "$*"; }
run()  { printf '   $'; printf ' %q' "$@"; printf '\n'; "$@"; }

kw() { run "$K" "$@" --book "$BOOK"; }

layer() {
  local name="$1" page="$2" x="$3" y="$4" size="$5"; shift 5
  kw layer add "$name" --pages "$page" --x "$x" --y "$y" --size "$size" --force "$@" >/dev/null
}

setp() {
  local name="$1" page="$2"; shift 2
  kw layer set "$name" --pages "$page" "$@" >/dev/null
}

# text NAME PAGE X Y WxH SIZE "contents"
text() {
  local name="$1" page="$2" x="$3" y="$4" size="$5" fs="$6" contents="$7"
  layer "$name" "$page" "$x" "$y" "$size" --class text
  setp "$name" "$page" --class text "fontSize=$fs" alignment=center "contents=$contents"
}

# btn NAME PAGE X Y WxH CMD "label"
btn() {
  local name="$1" page="$2" x="$3" y="$4" size="$5" cmd="$6" label="$7"
  layer "${name}_btn" "$page" "$x" "$y" "$size" --class button --action "onTap=$cmd"
  text "${name}_lbl" "$page" "$x" "$y" "$size" 16 "$label"
}

# goto_page PAGE TARGET COMMAND
goto_page() {
  kw command add "$3" --pages "$1" --force \
    --actions "[{\"command\":\"page.gotoPage\",\"params\":{\"pageName\":\"$2\",\"effect\":\"fade\",\"delay\":0,\"duration\":0}}]" >/dev/null
}

commands() {
  kw command add "$2" --pages "$1" --force --actions "$3" >/dev/null
}

furniture() {
  local page="$1"
  kw layer add card --pages "$page" --force --layer "$SRC/templates/shared_image.lua" >/dev/null
  text kicker "$page" "$KICKER_X" "$KICKER_Y" "${KICKER_W}x${KICKER_H}" "$KICKER_FS" ""
  text title  "$page" "$TITLE_X"  "$TITLE_Y"  "${TITLE_W}x${TITLE_H}"   "$TITLE_FS"  ""
  # O1 = B (options.md): home is the baked grid, not the kNavi strip
  goto_page "$page" thumbnailNavigation_grid go_home
  layer home "$page" "$HOME_X" "$HOME_Y" "${HOME_W}x${HOME_H}" --class button --action onTap=go_home
  layer plate "$page" "$CARD_X" "$PLATE_Y" "${CARD_W}x${PLATE_H}" --color '#17130F'
  text body "$page" "$BODY_X" "$BODY_Y" "${BODY_W}x${BODY_H}" "$BODY_FS" ""
  if [ "$TEXT_TEMPLATES" = "on" ]; then
    local role
    for role in kicker title body; do
      cp "$SRC/layers/text/${role}_text.lua" "$APP/components/$page/layers/${role}_text.lua"
    done
  fi
}

page_title() { setp title "$1" --class text "contents=$2"; }
page_body()  { setp body  "$1" --class text "contents=$2"; }

want() {
  local p="$1" x
  for x in "${SELECTED[@]}"; do [ "$x" = "$p" ] && return 0; done
  return 1
}

SELECTED=("$@")
[ ${#SELECTED[@]} -eq 0 ] && SELECTED=("${PAGES[@]}")

# ---------------------------------------------------------------------------
# 1. book + pages
# ---------------------------------------------------------------------------

say "book $BOOK"
if [ ! -d "$APP" ]; then
  run "$K" book new "$BOOK" "${PAGES[@]}" --no-layer
else
  # Create only the pages that are missing. `page add --force` REPLACES each named page with a fresh
  # skeleton — i.e. it empties the scene — so running it on an existing book wipes every layer that a
  # previous build added, which is exactly what happened on 2026-10-28: 13 pages ended up with
  # `layers = { }` and their screenshots came back black.
  missing=()
  for p in "${PAGES[@]}"; do
    [ -f "$APP/$p.lua" ] || missing+=("$p")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    kw page add "${missing[@]}" --no-layer >/dev/null
  fi
fi

# Only the pages being rebuilt: this loop used to walk every page, so a partial build (e.g.
# `design_build.sh interaction`) deleted the background layer from all 17 pages and only the rebuilt
# one got it back. That is how the book ended up with zero bg.lua files.
for p in "${SELECTED[@]}"; do
  kw layer remove bg --pages "$p" --images >/dev/null 2>&1 || true
  rm -f "$APP/components/$p/layers/bg.lua"
done

# ---------------------------------------------------------------------------
# 2. option pair O1 — navigation
# ---------------------------------------------------------------------------

if want thumbnailNavigation; then
  say "thumbnailNavigation (O1-A, component)"
  kw layer add bg --pages thumbnailNavigation --force --layer "$SRC/templates/shared_bg.lua" >/dev/null
  text title    thumbnailNavigation "$TITLE_X" 150 "${TITLE_W}x${TITLE_H}" 48 "$BOOK"
  text subtitle thumbnailNavigation "$TITLE_X" 265 "1300x80" 20 "cast · sheets · audio · video · reuse · motion"

  # O1-A is a component, not a layer, so it hangs off the page's onInit. `layer add` regenerates
  # the scene file, so the patch runs last and is idempotent.
  sed -i '' "s|onInit = function(scene) print(\"onInit\") end|onInit = function(UI) require(\"App.$BOOK.components.shared.thumbnail_nav\").create(UI) end|" \
    "$APP/thumbnailNavigation.lua"
fi

if want thumbnailNavigation_grid; then
  say "thumbnailNavigation_grid (O1-B, baked grid)"
  text title thumbnailNavigation_grid "$TITLE_X" 120 "${TITLE_W}x${TITLE_H}" 44 "$BOOK"
  # dark panel behind the block: the thumbnails are captures of this same beige book
  kw layer add grid_panel --pages thumbnailNavigation_grid --force --x 960 --y 660 --size 1500x820 \
    --layer "$SRC/templates/grid_panel.lua" >/dev/null
  grid_pages=(group group_annotated text text_themed image sprite sprite_texturepacker
              sprite_animate audio sync video video_png animation interaction record)
  mkdir -p "$APP/assets/images/thumbnailNavigation_grid"
  # Thumbnails used to come from design_media.py's generated tiles ($BOOK + a label), so
  # the grid showed fifteen near-identical blank cards (auditor). Build them from the real page
  # captures in evidence/ instead: 480x320 page area -> 600x400 (3:2, the cell aspect).
  if [ -f "$SRC/evidence/group.png" ]; then
    .venv/bin/python - "$SRC/evidence" "$APP/assets/thumbnails" <<'PY_THUMBS'
import os, sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
n = 0
for f in sorted(os.listdir(src)):
    if not f.endswith(".png") or f in ("contact_sheet.png", "reference_comparison.png"):
        continue
    im = Image.open(os.path.join(src, f)).convert("RGB")
    im.resize((600, 400), Image.LANCZOS).save(os.path.join(dst, f))
    n += 1
print("      %d thumbnails rebuilt from evidence captures" % n)
PY_THUMBS
  fi
  i=0
  # 15 cells, 5 columns x 3 rows on the 1920x1280 canvas: 256x171 thumbnails (3:2, the asset
  # aspect) with a 30 px gutter, so the block spans x 260..1660 and is centred vertically
  # (rows at 429 / 640 / 851). The hit target is the transparent template, not `--class button`,
  # which paints a grey tile over the thumbnail (issue #3).
  for p in "${grid_pages[@]}"; do
    col=$(( i % 5 )); row=$(( i / 5 ))
    x=$(( 388 + col * 286 )); y=$(( 430 + row * 245 ))
    cp "$APP/assets/thumbnails/$p.png" "$APP/assets/images/thumbnailNavigation_grid/th_$p.png"
    layer "th_$p" thumbnailNavigation_grid "$x" "$y" 256x150 --image
    goto_page thumbnailNavigation_grid "$p" "go_$p"
    layer "hb_$p" thumbnailNavigation_grid "$x" "$y" 256x150 --class button --action "onTap=go_$p"
    # label sits ON the thumbnail's lower band: a 256-design-px cell is 64 content px wide, so a
    # caption below the cell overflows into its neighbours. Names are abbreviated to fit.
    case "$p" in
      group_annotated)     short="grp_ann" ;;
      text_themed)         short="text_th" ;;
      sprite_texturepacker) short="sprite_tp" ;;
      sprite_animate)      short="sprite_an" ;;
      animation)           short="anim" ;;
      interaction)         short="interact" ;;
      *)                   short="$p" ;;
    esac
    # Caption BELOW the cell. At +62 it sat on the thumbnail's own dark footer band, where black
    # glyphs on a dark strip were unreadable (auditor). +105 clears the 171-tall cell and still fits
    # above the next row (rows are 211 apart).
    text  "hl_$p" thumbnailNavigation_grid "$x" "$(( y + 106 ))" 256x60 22 "$short"
    i=$(( i + 1 ))
  done
  # `kw layer add --layer <template>` lands LAST in the scene list, i.e. frontmost — so the page
  # background must be added after the content, or it paints over every thumbnail and label
  # (issue #3: the 47-layer grid rendered as an empty card).
  kw layer add bg --pages thumbnailNavigation_grid --force --layer "$SRC/templates/shared_bg.lua" >/dev/null
fi

# ---------------------------------------------------------------------------
# 3. option pair O2 — the frame as a group
# ---------------------------------------------------------------------------

build_group_page() {
  local page="$1" annotated="$2"
  furniture "$page"
  page_title "$page" "group"
  page_body  "$page" "one layer.showHide moves the whole chrome"

  if [ "$annotated" = "yes" ]; then
    # panels 470 tall on y 490: at 560x520 on y 520 they ran into the footer plate, so the page no
    # longer looked like the mechanical `group` page it is supposed to annotate (auditor). 470 leaves
    # the dark footer plate and the body line visible below them.
    layer p_r1 "$page" 400  490 560x470 --color '#241F18'
    layer p_r2 "$page" 960  490 560x470 --color '#241F18'
    layer p_r3 "$page" 1520 490 560x470 --color '#241F18'
    text  r1_txt "$page" 400  490 520x430 18 "R1 asset — one PNG (images/shared/specimen_frame.png) is drawn by all 17 pages"
    text  r2_txt "$page" 960  490 520x430 18 "R2 code — one module (components/shared/specimen_frame.lua) is required by every page"
    text  r3_txt "$page" 1520 490 520x430 18 "R3 class — one class file is copied to N pages by layer add --pages"
  fi
  if [ "$annotated" = "yes" ]; then
    kw layer add frame --pages "$page" --force --layer "$SRC/layers/group_annotated/frame.lua@group" >/dev/null
  else
    kw layer add frame --pages "$page" --force --layer "$SRC/layers/group/frame.lua@group" >/dev/null
  fi

  # the probe is the only motion on these pages: a small pulsing square well inside the plate.
  # At 180x180 on design 760,900 the pulse scale (up to 1.35x = 306 px) plus its rotation put a
  # grey diamond through the bottom edge of the card, past the page frame (issue #5).
  layer probe "$page" 960 850 40x40 --class pulse
  setp  probe "$page" --class pulse autoPlay=true loop=0 duration=1200
  commands "$page" go_hideframe '[{"command":"layer.showHide","params":{"target":"frame","delay":0,"hide":true,"time":300,"toggle":true}}]'
  btn hideframe "$page" "$CTL_X0" "$CTL_Y" "${CTL_W}x${CTL_H}" go_hideframe "hide frame"

}

if want group;           then say "group (O2-A)";           build_group_page group no; fi
if want group_annotated; then say "group_annotated (O2-B)"; build_group_page group_annotated yes; fi

# ---------------------------------------------------------------------------
# 4. option pair O3 — text colour
# ---------------------------------------------------------------------------

build_text_page() {
  local page="$1" themed="$2"
  kw layer add card --pages "$page" --force --layer "$SRC/templates/shared_image.lua" >/dev/null
  text kicker "$page" "$KICKER_X" "$KICKER_Y" "${KICKER_W}x${KICKER_H}" 18 "O3 text colour"
  text title  "$page" "$TITLE_X"  "$TITLE_Y"  "${TITLE_W}x${TITLE_H}"  "$TITLE_FS" "$( [ "$themed" = yes ] && echo themed || echo default )"
  goto_page   "$page" thumbnailNavigation_grid go_home   # O1 = B
  layer home  "$page" "$HOME_X" "$HOME_Y" "${HOME_W}x${HOME_H}" --class button --action onTap=go_home
  layer plate "$page" "$CARD_X" "$PLATE_Y" "${CARD_W}x${PLATE_H}" --color '#17130F'
  text body   "$page" "$BODY_X" "$BODY_Y" "${BODY_W}x${BODY_H}" "$BODY_FS" "kicker 18 · title 48 · body 22 — no colour props vs checked-in palette"

  layer swatch "$page" 960 520 1400x420 --color '#EDE3D2'
  text  swatch_txt "$page" 960 520 1340x380 30 "default colour on paper"

  if [ "$themed" = "yes" ]; then
    # The checked-in palette class files carry `contents = ""` on purpose (they are templates), so a
    # plain `cp` over the generated class erased every caption on this page: title, kicker and body
    # all rendered blank while their layers were present and correctly placed (issue #7). Carry the
    # generated `contents` string across into the palette copy.
    python3 - "$SRC/layers/text" "$APP/components/$page/layers" <<'PY_PAL'
import os, re, sys
src, dst = sys.argv[1], sys.argv[2]
for role in ("kicker", "title", "body"):
    gen = os.path.join(dst, role + "_text.lua")
    pal = os.path.join(src, role + "_text.lua")
    if not (os.path.exists(gen) and os.path.exists(pal)):
        continue
    m = re.search(r'contents\s*=\s*"((?:[^"\\]|\\.)*)"', open(gen).read())
    text = m.group(1) if m else ""
    out = re.sub(r'contents\s*=\s*"[^"]*"', 'contents = "%s"' % text, open(pal).read(), count=1)
    open(gen, "w").write(out)
    print("      palette %s keeps contents %r" % (role, text))
PY_PAL
  fi
}

if want text;        then say "text (O3-A, plugin defaults)"; build_text_page text no; fi
if want text_themed; then say "text_themed (O3-B, palette)";  build_text_page text_themed yes; fi

# ---------------------------------------------------------------------------
# 5. image — cast art
# ---------------------------------------------------------------------------

if want image; then
  say "image"
  furniture image
  page_title image "image"
  page_body  image "cast renders installed 1:1 on a 1920x1280 canvas"
  i=0
  for c in hero friend; do
    x=$(( 480 + i * 480 ))
    layer "$c" image "$x" 560 300x450 --image
    text "n_$c" image "$x" 880 300x80 20 "$c"
    i=$(( i + 1 ))
  done
fi

# ---------------------------------------------------------------------------
# 6. sprite benches — one frame table, three metadata contracts
#
# `display.newSprite` composites black on this simulator build (§8b.16), so the benches show the same
# frame table through ordinary image layers: design_sheets.py --frames crops each rect using the very
# rectangles the .lua/.json sidecars carry, and components/shared/sheet_player.lua plays them.
# What is still compared is the metadata contract — the sprite class itself is the thing to re-test
# when the renderer is fixed.

build_sprite_page() {
  local page="$1" sheetType="$2" sheetInfo="$3" legend="$4"
  # The reel experiment (§8b.19) is retired: objects added by a copied class or from `onInit` are not
  # composited on these pages either, so the bench stays on the real `sprite` class and waits for the
  # renderer fix (§8b.16).
  for stale in reel f01 f02 f03 f04 f05 f06 f07 f08 stage views_btn views_lbl pairs_btn pairs_lbl pause_btn pause_lbl play_btn play_lbl; do
    kw layer remove "$stale" --pages "$page" >/dev/null 2>&1 || true
  done
  for stale in go_views go_pairs go_pause go_play; do
    kw command remove "$stale" --pages "$page" >/dev/null 2>&1 || true
  done

  furniture "$page"
  page_title "$page" "sprite · $sheetType"
  page_body  "$page" "the same PNG through the $sheetType loader · frames drawn as images: display.newSprite does not surface (recorder 1 colour vs 463 on this path)"

  # Pre-crop every frame out of the sheet. `display.newSprite` never reaches the surface in this book
  # (plugin recorder: 1 colour, versus 463 for the same page on the plain-image path), so the benches
  # draw frame PNGs with display.newImageRect. The sheet itself is still built and its metadata still
  # read by the class -- that contract is the point of the three pages.
  mkdir -p "$APP/assets/sprites/${SHEET}_frames"
  .venv/bin/python - "$APP/assets/sprites" "$SHEET" <<'PY_FRAMES'
import os, sys
from PIL import Image
sheet_name = sys.argv[2]
out = os.path.join(sys.argv[1], sheet_name + "_frames")
os.makedirs(out, exist_ok=True)
sheet = Image.open(os.path.join(sys.argv[1], sheet_name + ".png")).convert("RGBA")
cols, rows = 4, 2
fw, fh = sheet.width // cols, sheet.height // rows
n = 0
for r in range(rows):
    for c in range(cols):
        n += 1
        sheet.crop((c * fw, r * fh, (c + 1) * fw, (r + 1) * fh)).save(
            os.path.join(out, "frame_%02d.png" % n))
print("      cropped %d frames of %dx%d" % (n, fw, fh))
PY_FRAMES
  kw layer add stage --pages "$page" --force --layer "$SRC/layers/sprite/stage.lua@sprite" >/dev/null
  setp stage "$page" --class sprite "sheetType=$sheetType"
  setp stage "$page" --class sprite "sheetInfo=$sheetInfo"
  setp stage "$page" --class sprite "filename=sprites/$SHEET.png"

  text legend "$page" 1450 560 900x600 16 "$legend"

  commands "$page" go_views '[{"command":"sprite.play","params":{"target":"stage","sequence":"views"}}]'
  commands "$page" go_pairs '[{"command":"sprite.play","params":{"target":"stage","sequence":"pairs"}}]'
  commands "$page" go_pause '[{"command":"sprite.pause","params":{"target":"stage"}}]'
  commands "$page" go_play  '[{"command":"sprite.play","params":{"target":"stage","sequence":"views"}}]'
  btn views "$page" "$CTL_X0" "$CTL_Y" "${CTL_W}x${CTL_H}" go_views "views"
  btn pairs "$page" "$CTL_X1" "$CTL_Y" "${CTL_W}x${CTL_H}" go_pairs "pairs"
  btn pause "$page" "$CTL_X2" "$CTL_Y" "${CTL_W}x${CTL_H}" go_pause "pause"
  btn play  "$page" "$CTL_X3" "$CTL_Y" "${CTL_W}x${CTL_H}" go_play  "play"
}

if want sprite; then
  say "sprite (uniform-sized)"
  build_sprite_page sprite uniform-sized sprites/$SHEET.lua \
    "views 1..8 in order, 1200 ms per frame · metadata: uniform-sized grid, 4x2 cells of 320x480, no sidecar file"
fi
if want sprite_texturepacker; then
  say "sprite_texturepacker"
  build_sprite_page sprite_texturepacker TexturePacker sprites/$SHEET.lua \
    "same frames, rects read from assets/sprites/$SHEET.lua · delete that file and --frames cannot crop, which is the test"
fi
if want sprite_animate; then
  say "sprite_animate"
  build_sprite_page sprite_animate Animate sprites/$SHEET.json \
    "same frames, rects read from assets/sprites/$SHEET.json (Adobe Animate shape, spriteSourceSize offsets)"
fi

# ---------------------------------------------------------------------------
# 7. audio
# ---------------------------------------------------------------------------

if want audio; then
  say "audio"
  furniture audio
  page_title audio "audio"
  page_body  audio "page-level audios: short (blip 0.6 s) and long (ambience 20 s)"
  layer meter audio 960 470 700x200 --color '#C8A24A'
  text  info  audio 960 720 1400x220 18 "short/design_blip.wav · long/design_ambience.mp3 · channels 1 and 2"

  commands audio go_blip '[{"command":"audio.play","params":{"target":"design_blip","channel":1,"delay":0,"loops":0,"fadein":0,"volume":8,"listener":""}}]'
  commands audio go_amb  '[{"command":"audio.play","params":{"target":"design_ambience","channel":2,"delay":0,"loops":-1,"fadein":0,"volume":5,"listener":""}}]'
  commands audio go_stop '[{"command":"audio.stop","params":{"target":"design_ambience"}}]'
  commands audio go_fade '[{"command":"audio.fadeOut","params":{"target":"design_ambience","duration":2000}}]'
  btn blip     audio "$CTL_X0" "$CTL_Y" "${CTL_W}x${CTL_H}" go_blip "blip"
  btn ambience audio "$CTL_X1" "$CTL_Y" "${CTL_W}x${CTL_H}" go_amb  "ambience"
  btn stop     audio "$CTL_X2" "$CTL_Y" "${CTL_W}x${CTL_H}" go_stop "stop"
  btn fade     audio "$CTL_X3" "$CTL_Y" "${CTL_W}x${CTL_H}" go_fade "fade"
fi

# ---------------------------------------------------------------------------
# 8. sync
# ---------------------------------------------------------------------------

if want sync; then
  say "sync"
  furniture sync
  page_title sync "sync"
  page_body  sync "timed words over 3 s of audio · tap a word to hear it"

  kw layer add sentence --pages sync --force --layer "$SRC/layers/sync/sentence.lua@sync" >/dev/null
  setp sentence sync --class sync autoPlay=true
  setp sentence sync --class sync wordTouch=true
  setp sentence sync --class sync langClassDelegate=true

  # `syncAudioText.play` calls obj:play() on the *event target*, so it only works when the sync
  # layer itself is tapped — a separate button would call :play() on a button. The button therefore
  # reloads the page (replay from word one) and per-word taps are the class's own wordTouch.
  commands sync go_replay '[{"command":"page.reload","params":{"canvas":true}}]'
  btn replay sync "$CTL_X0" "$CTL_Y" "${CTL_W}x${CTL_H}" go_replay "replay"
fi

# ---------------------------------------------------------------------------
# 9. video
# ---------------------------------------------------------------------------

if want video; then
  say "video"
  furniture video
  page_title video "video"
  page_body  video "local mp4 · burnt-in timecode so pause/resume/loop are visible"
  layer screen video 960 540 960x540 --class video
  setp screen video --class video url=videos/design_slate.mp4
  setp screen video --class video autoPlay=false
  setp screen video --class video loop=true
  setp screen video --class video isLocal=true
  setp screen video --class video keepImage=true
  # layer_video sizes the native object from layerProps: with `shapedWith` set it takes
  # width/height verbatim (960x540 DESIGN px = a video covering the whole content at 4x), and only
  # the else-branch divides by 4. Clearing shapedWith in the generated base layer is what makes the
  # video 240x135, exactly the `screen` rect on the plate.
  # NOTE: "" is truthy in Lua -- layer_video tests `if layerProps.shapedWith then`, so it must be nil
  sed -i '' 's/  shapedWith = "new_rectangle",/  shapedWith = nil,/' "$APP/components/video/layers/screen.lua"
  # The generated go_play/go_pause/go_resume/go_mute commands resolve `UI.videos["screen"]`, but
  # layer_video registers only `UI.videos[<target>.."_video"]` ("screen_video"). Every video command
  # therefore received nil and did nothing, whatever the button did. Publish both keys.
  python3 - "$APP/components/video/layers/screen_video.lua" <<'PY_VID'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("return require(\"components.kwik.layer_video\").set(M)", """local baseVideo = require("components.kwik.layer_video").set(M)
local originalDidShow = baseVideo.didShow
function baseVideo:didShow(UI)
  if originalDidShow then originalDidShow(UI) end
  if UI.videos ~= nil then
    local player = UI.videos[self.properties.target .. "_video"] or UI.videos[self.properties.target]
    UI.videos[self.properties.target] = player
    -- native video on macOS has play/pause/seek but no resume/unmute; the generated go_vresume
    -- command calls obj:resume() and crashed the page ("attempt to call method 'resume'").
    if player ~= nil then
      player.resume = player.resume or function(self) self:play() end
      player.unmute = player.unmute or function(self) self.isMuted = false end
      -- "play" on a finished video should rewind first: native play() resumes from where it stopped,
      -- so tapping play after the slate ends looked like nothing happened (operator report).
      if player.rewindAware ~= true then
        local rawPlay = player.play
        player.play = function(self, ...)
          -- native video exposes totalTime/currentTime (duration is nil on this build). A finished
          -- video ignores play(): measured currentTime stuck at 6/6 after go_vplay. Pause, rewind and
          -- seek again after play so the counter really restarts.
          local total = (self.totalTime or self.duration) or 0
          local pos   = self.currentTime or 0
          if total > 0 and pos >= total - 0.3 then
            -- A finished native video ignores a bare play(); measured. pause -> seek(0) -> play is
            -- what actually restarts it: probe went 6/6 -> 0 -> 0.61 s after 600 ms. A trailing
            -- seek(0) (tried first) stops it again, which is why the earlier wrapper looked broken.
            self:pause()
            self:seek(0)
            return rawPlay(self, ...)
          end
          return rawPlay(self, ...)
        end
        player.rewindAware = true
      end
    end
  end
end
return baseVideo""")
open(p, "w").write(s)
PY_VID

  commands video go_vplay   '[{"command":"video.play","params":{"target":"screen"}}]'
  commands video go_vpause  '[{"command":"video.pause","params":{"target":"screen"}}]'
  commands video go_vresume '[{"command":"video.resume","params":{"target":"screen"}}]'
  # `AC.Video` has no `resume` method (commands/kwik/videoAction.lua defines play, pause, mute,
  # unmute, muteUnmute -- no resume), so go_vresume called a nil function and the resume button never
  # worked. On a paused native video resume IS play, so point the generated command at play.
  sed -i '' 's/AC\.Video:resume(obj)/AC.Video:play(obj)/' "$APP/commands/video/go_vresume.lua"
  commands video go_vmute   '[{"command":"video.muteUnmute","params":{}}]'
  btn play   video "$CTL_X0" "$CTL_Y" "${CTL_W}x${CTL_H}" go_vplay   "play"
  btn pause  video "$CTL_X1" "$CTL_Y" "${CTL_W}x${CTL_H}" go_vpause  "pause"
  btn resume video "$CTL_X2" "$CTL_Y" "${CTL_W}x${CTL_H}" go_vresume "resume"
  btn mute   video "$CTL_X3" "$CTL_Y" "${CTL_W}x${CTL_H}" go_vmute   "mute"
fi

# ---------------------------------------------------------------------------
# 10. video_png
# ---------------------------------------------------------------------------

if want video_png; then
  say "video_png"
  furniture video_png
  page_title video_png "video_png"
  page_body  video_png "24 numbered PNGs, no codec · autoplay only (the class has no command surface)"
  kw layer add screen --pages video_png --force --layer "$SRC/layers/video_png/screen.lua@video_png" >/dev/null
fi

# ---------------------------------------------------------------------------
# 11. animation
# ---------------------------------------------------------------------------

if want animation; then
  say "animation"
  furniture animation
  page_title animation "animation"
  page_body  animation "six classes, one source image · play all or pause all"

  # labels were at +150 design and the control row at CTL_Y=1010, which put both on the same line:
  # "path"/"pulse" collided with "play all"/"pause all" (auditor finding). Labels up, controls down.
  ANIM_LBL_DY=170
  ANIM_CTL_Y=1035
  mkdir -p "$APP/assets/images/animation"
  anim_names=(a_blink a_bounce a_linear a_path a_pulse a_rotation)
  anim_class=(blink  bounce  linear  path  pulse  rotation)
  anim_play=()
  anim_pause=()
  i=0
  for n in "${anim_names[@]}"; do
    c="${anim_class[$i]}"
    # design-space plate is x 480..1440, y 293..987 (the 480x320 content box maps back through
    # app.getPosition at content/1920 and content/1280), so cells must sit inside THAT, not inside
    # 0..1920: three 220x280 cells on centres 600/960/1320 and rows 480/830 leave every image and
    # label inside the card.
    col=$(( i % 3 )); row=$(( i / 3 ))
    x=$(( 600 + col * 360 )); y=$(( 430 + row * 340 ))
    cp Photoshop/<book>/cast/$CAST0/png/body_front.png "$APP/assets/images/animation/$n.png"
    # the animation registry key is <layer>_<class>, so commands must name that, not the layer
    commands animation "go_pause_$n" "[{\"command\":\"animation.pause\",\"params\":{\"target\":\"${n}_${c}\"}}]"
    layer "$n" animation "$x" "$y" 200x200 --image --class "$c" --action "onTap=go_pause_$n"
    # loop 0 = forever: the six defaults are finite loops that all finish inside ~3 s, which makes the
    # bench useless after a few seconds and hides whether pause did anything.
    setp "$n" animation --class "$c" loop=0
    text "lbl_$n" animation "$x" "$(( y + ANIM_LBL_DY ))" 260x60 16 "$c"
    anim_play+=("{\"command\":\"animation.play\",\"params\":{\"target\":\"${n}_${c}\"}}")
    anim_pause+=("{\"command\":\"animation.pause\",\"params\":{\"target\":\"${n}_${c}\"}}")
    i=$(( i + 1 ))
  done

  # The animation classes carry absolute DESIGN coordinates in sibling tables M.from / M.to
  # (layer_animation.lua:75/120 -> app.getPosition). The generated defaults are x=0/y=0 (linear) or
  # y=-100 (bounce), so every object flew to the canvas origin or off the top of the card
  # (issue #16). `kwik layer set` cannot write those tables -- it only writes M.properties
  # (lib/layer_ops.lua:1300-1320) -- so they are pinned per cell, around the cell's own centre.
  python3 - "$APP/components/animation/layers" <<'PY_ANIM'
import glob, os, re, sys
d = sys.argv[1]
# Only the three classes that animate POSITION are pinned; blink/pulse/rotation leave their
# generated defaults, which already sit on their cell (verified in the runtime dump).
# Units differ per class: `linear` assigns to.x/to.y straight onto obj.x/obj.y (content px),
# while `path`/`bounce` route them through app.getPosition. Cell centres in content px keep all of
# them inside the plate; `linear` additionally slides 60 px, which is the demo.
moves = {"a_linear": (60, 0), "a_bounce": (0, -999), "a_path": (0, 0)}

def xy(text):
    x = float(re.search(r"\n\s*x\s*=\s*([-\d.]+)", text).group(1))
    y = float(re.search(r"\n\s*y\s*=\s*([-\d.]+)", text).group(1))
    return x, y

def pin(block, x, y):
    block = re.sub(r"(\n\s*x\s*=\s*)[-\d.]+,", r"\g<1>%g," % x, block, count=1)
    block = re.sub(r"(\n\s*y\s*=\s*)[-\d.]+,", r"\g<1>%g," % y, block, count=1)
    block = re.sub(r"(\n\s*alpha\s*=\s*)[-\d.]+,", r"\g<1>1,", block, count=1)
    return block

# pulse fades from alpha 0, so a still capture catches an invisible cell; keep it opaque and let it
# pulse its scale instead. Only its `from` block is touched — its positions already sit on the cell.
pulse = os.path.join(d, "a_pulse_pulse.lua")
if os.path.exists(pulse):
    src = open(pulse).read()
    src = re.sub(r"M\.from = \{.*?\n\}", lambda m: re.sub(r"(\n\s*alpha\s*=\s*)[-\d.]+,", r"\g<1>1,", m.group(0), count=1), src, count=1, flags=re.S)
    open(pulse, "w").write(src)
    print("      pulse kept opaque")

for f in sorted(glob.glob(os.path.join(d, "a_*_*.lua"))):
    layer = os.path.basename(f).rsplit("_", 1)[0]
    base = os.path.join(d, layer + ".lua")
    if layer not in moves or not os.path.exists(base):
        continue
    bx, by = xy(open(base).read())
    # design -> content is the PLATE mapping, not a plain half: app.getPosition puts the 1920x1280
    # canvas on the 480x320 plate at content (240,135), i.e. x/4 + 240, y/4 + 135. Using bx/2 put the
    # `linear` specimen at content 660,221 -- the page's top-right corner instead of its cell
    # (auditor finding 2).
    cx, cy = bx / 4.0 + 240.0, by / 4.0 + 135.0
    dx, dy = moves[layer]
    if dy == -999:      # bounce assigns `to.y` as its own travel, not a position: 0 = in place
        cy, dy = 0, 0
    src = open(f).read()
    src = re.sub(r"M\.from = \{.*?\n\}", lambda m: pin(m.group(0), cx, cy), src, count=1, flags=re.S)
    src = re.sub(r"M\.to = \{.*?\n\}", lambda m: pin(m.group(0), cx + dx, cy + dy), src, count=1, flags=re.S)
    open(f, "w").write(src)
    print("      pinned %s from (%g,%g) to (%g,%g)" % (layer, cx, cy, cx + dx, cy + dy))
PY_ANIM

  # The path bench follows assets/images/animation/a_path_Path_open.json. That file was a leftover
  # from a portrait export: its points (185..375, 1025..1215 in design px) are outside the plate, so
  # the image flew to the bottom-left corner and over the footer (auditor finding). Regenerate it as a
  # small closed loop around the a_path cell centre (600,830 design) so the class still demonstrates
  # a path animation, inside the card.
  .venv/bin/python - "$APP/assets/images/animation/a_path_Path_open.json" <<'PY_PATH'
import json, sys
# a_path is grid index 3: col 0, row 1 -> design centre (600, 430 + 340) = (600, 770). The loop
# must sit inside that cell; at y 830 (the previous row layout) the rotated 220x240 specimen swept
# down through the lbl row at 900 and into the control row at 1020 (auditor).
cx, cy, half_w, half_h = 600, 770, 40, 40
pts = [[cx - half_w, cy - half_h], [cx + half_w, cy - half_h],
       [cx + half_w, cy + half_h], [cx - half_w, cy + half_h]]
# the exporter writes each point three times (control point, anchor, anchor)
json.dump([[p[0], p[1], p[0], p[1], p[0], p[1]] for p in pts], open(sys.argv[1], "w"))
print("      path loop rewritten inside the a_path cell")
PY_PATH
  IFS=,; play_json="[${anim_play[*]}]"; pause_json="[${anim_pause[*]}]"; unset IFS
  commands animation go_anim_play  "$play_json"
  commands animation go_anim_pause "$pause_json"
  btn play  animation "$CTL_X0" "$ANIM_CTL_Y" "${CTL_W}x${CTL_H}" go_anim_play  "play all"
  btn pause animation "$CTL_X1" "$ANIM_CTL_Y" "${CTL_W}x${CTL_H}" go_anim_pause "pause all"
fi

# ---------------------------------------------------------------------------
# 12. interaction
# ---------------------------------------------------------------------------

if want interaction; then
  say "interaction"
  furniture interaction
  page_title interaction "interaction"
  page_body  interaction "tap, drag, scroll, spin · drive them with kwik interact send"

  commands interaction go_flash '[{"command":"layer.showHide","params":{"target":"t_flash","delay":0,"hide":true,"time":120,"toggle":true}}]'
  layer t_button interaction 620 430 440x300 --color '#2E271E' --class button --action onTap=go_flash
  layer t_flash  interaction 960 300 150x150 --color '#C8A24A' --class button --action onTap=go_flash

  layer t_drag interaction 1300 430 440x300 --color '#2E271E' --class drag
  setp  t_drag interaction --class drag backToOrigin=true

  # Operator: "scroll needs more text". One line was not enough to scroll; this is a real paragraph,
  # several times taller than the panel.
  #
  # Wiring, and why the order matters: the `group` class takes the layers created ABOVE it as its
  # members, so the text is added first and `content` right after it -- content then owns the text.
  # The scroll must be pointed at the PANEL (target) with that group as contents and type=group, so
  # layer_scroll does `contents = UI.groups["content"]` and inserts the group into its scrollview;
  # that insertion is what clips and scrolls. Previously target was the text itself, so the long
  # paragraph was never inside the viewport and simply drew over the panel and the page edge.
  text  t_scroll_txt interaction 620 780 420x900 18 \
    "scroll me — this is the contents the scroll class clips. Drag inside the panel and the column moves under the frame while the panel itself stays put. The text is one long string: the layer is 420 px wide, so it wraps into the column you see, and it is deliberately several times taller than the panel so there is somewhere to scroll to. Keep dragging past the bottom and the list stops at the last line; drag back to the top and it stops there too. Touch scrolling, momentum and clipping all come from the plugin's scroll class — the page only supplies this text and the panel around it."
  kw layer add content --pages interaction --force --layer "$SRC/layers/interaction/content.lua@group" >/dev/null
  layer t_scroll interaction 620 780 440x300 --class scroll
  setp  t_scroll interaction --class scroll target=t_scroll
  setp  t_scroll interaction --class scroll contents=content
  setp  t_scroll interaction --class scroll type=group
  # area=manual: the class sizes the scrollview from the target object's x/y, and at didShow time the
  # panel is still at 0,0 (the editor applies layer positions after create), so the viewport landed at
  # the far left of the page. Manual geometry in scene-local coordinates is deterministic: the panel
  # is 440x300 design = 110x75 content, centred on the page grid at (395,330); the text column is
  # 900 design = 225 content tall.
  setp  t_scroll interaction --class scroll area=manual
  setp  t_scroll interaction --class scroll top=292.5
  setp  t_scroll interaction --class scroll left=340
  setp  t_scroll interaction --class scroll width=110
  setp  t_scroll interaction --class scroll height=75
  setp  t_scroll interaction --class scroll scrollWidth=110
  setp  t_scroll interaction --class scroll scrollHeight=225
  setp  t_scroll interaction --class scroll verticalScrollDisabled=false
  setp  t_scroll interaction --class scroll horizontalScrollDisabled=true
  setp  t_scroll interaction --class scroll verticalScrollDisabled=false
  setp  t_scroll interaction --class scroll horizontalScrollDisabled=true

  layer t_spin interaction 1300 780 440x300 --color '#2E271E' --class spin

  # Labels sat at 605/955 design, which is 286/382 content -- the panel bottom edge is at 280/367,
  # so their top halves were cut by the panel (auditor). 640/990 clears both.
  # Measured from the runtime dump: panels are centred at content y 242 and 330, 75 tall, so their
  # edges are 280 / 293 / 368. A label at 293 lands exactly on the second row's top edge, which reads
  # as a label belonging to the wrong panel. Row 1 sits above its panel, row 2 below its panel.
  text l1 interaction 620 240 440x60 16 "button"
  text l2 interaction 1300 240 440x60 16 "drag"
  text l3 interaction 620 980 440x60 16 "scroll"
  text l4 interaction 1300 980 440x60 16 "spin"
fi

# ---------------------------------------------------------------------------
# 13. record
# ---------------------------------------------------------------------------

if want record; then
  say "record"
  furniture record
  page_title record "record"
  # the recorder writes 15 fps / 90 frames (design_media.py --make); 30 fps drops frames (§8b.8)
  page_body  record "6 s at 15 fps must show exactly two badge turns"
  mkdir -p "$APP/assets/images/record"
  cp Photoshop/<book>/cast/$CAST0/png/body_front.png "$APP/assets/images/record/badge.png"
  layer badge record 960 560 300x450 --image --class rotation
  # 360 deg every 3000 ms, looping: a correct 6 s recording is exactly two turns.
  setp badge record --class rotation duration=3000 loop=0 autoPlay=true
  text  counter record 960 900 800x100 24 "6 s = 2 turns"
fi

# ---------------------------------------------------------------------------
# 13a. sync word clips
# ---------------------------------------------------------------------------
# lib/util.lua:284 validates `assets/audios/<sentenceDir>/<word>.mp3`, while syncSound.lua:89-95
# loads `assets/audios/sync/<sentenceDir>/<word>.mp3`. With sentenceDir = "sync/design_sync" the
# second path doubles the segment, so the clips are mirrored where the loader looks (§8b.15).
if [ -d "$APP/assets/audios/sync/design_sync" ]; then
  mkdir -p "$APP/assets/audios/sync/sync/design_sync"
  cp "$APP/assets/audios/sync/design_sync/"*.mp3 "$APP/assets/audios/sync/sync/design_sync/" 2>/dev/null || true
  say "sync word clips mirrored for syncSound"
fi

# ---------------------------------------------------------------------------
# 13a2. shape layers are authored in 1920x1280 PSD coordinates, but layer_shape.createRectangle
# takes width/height raw while it scales x/y by 0.25 (layer_image scales both). Every rectangle
# therefore rendered 4x too large — a 1920-wide plate in a 480-wide design box. Setting xScale /
# yScale to 0.25 makes them match the image layers. 204 of the book's 249 layers are shapes.
say "shape layer scale"
python3 - <<'PY'
import glob, io
n = 0
for f in glob.glob("Solar2D/App/<book>_design/components/*/layers/*.lua"):
    s = io.open(f, encoding="utf-8").read()
    if "layer_shape" not in s or "xScale = 1," not in s:
        continue
    s = s.replace("  xScale = 1,", "  xScale = 0.25,").replace("  yScale = 1,", "  yScale = 0.25,")
    io.open(f, "w", encoding="utf-8").write(s)
    n += 1
print("   scaled %d shape layers" % n)
PY

# 13b. framing check on every page
# ---------------------------------------------------------------------------
# The plugin already centres a 480x320 page in the 960x590 content. This module MEASURES that and
# never moves the group: the first version shifted every page by a quarter-page because its centre()
# averaged localToContent(0,0) with localToContent(w,h). See the module header.
say "framing check"
for p in "${PAGES[@]}"; do
  if [ "$p" = "thumbnailNavigation" ]; then
    sed -i '' "s|onInit = function(UI) require(\"App.$BOOK.components.shared.thumbnail_nav\").create(UI) end|onInit = function(UI) require(\"App.$BOOK.components.shared.framing\").apply(UI); require(\"App.$BOOK.components.shared.thumbnail_nav\").create(UI) end|" "$APP/$p.lua"
  else
    sed -i '' "s|onInit = function(scene) print(\"onInit\") end|onInit = function(UI) require(\"App.$BOOK.components.shared.framing\").apply(UI) end|" "$APP/$p.lua"
  fi
  # drop the retired reel-era hook if a previous build left it in the scene
  sed -i "" "s|; require(\"App.$BOOK.components.shared.sheet_player\").attach(UI, { interval = 1200 })||" "$APP/$p.lua"
  grep -q "shared.sheet_player" "$APP/$p.lua" && echo "   WARN sheet_player hook still in $p"
  grep -q "shared.framing" "$APP/$p.lua" || echo "   WARN framing not applied to $p"
done

# ---------------------------------------------------------------------------
# 13b. hit targets must be transparent
# ---------------------------------------------------------------------------
# `layer add --class button` fills its rectangle with the CLI default colour 0.5,0.5,0.5,1 and the
# layer is inserted ABOVE the artwork it covers, so every button rendered as a grey tile — on the
# grid that hid all 15 thumbnails (issue #3), on the other pages it tinted the plates. A hit target
# needs fill alpha 0: it stays touchable (unlike isVisible=false) and the editor still outlines it.
# Detected structurally — a layer whose sibling `<name>_button.lua` exists is a button — so it
# covers every page, including the ones added later.
say "transparent hit targets"
hits=0
for dir in "$APP"/components/*/layers; do
  [ -d "$dir" ] || continue
  for f in "$dir"/*.lua; do
    b="${f%.lua}"
    [ -f "${b}_button.lua" ] || continue
    if grep -q '0\.5019607843137255' "$f"; then
      sed -i '' 's/color    = { 0\.5019607843137255, 0\.5019607843137255, 0\.5019607843137255, 1 }/color    = { 0, 0, 0, 0 }/' "$f"
      hits=$(( hits + 1 ))
    fi
    # A fully transparent fill is not enough on this build: a freshly created display rect reports
    # isHitTestable = false, and the scene receives the touch with target = nil, so no button ever
    # fires. Ask for hit testing explicitly on the hit target.
    python3 - "$f" <<'PY_HIT'
import sys
p = sys.argv[1]
s = open(p).read()
if "isHitTestable" in s:
    sys.exit(0)
s = s.replace("  UI.sceneGroup[obj.name] = obj", """  UI.sceneGroup[obj.name] = obj
  obj.isHitTestable = true      -- transparent fill alone does not hit-test on this build""")
open(p, "w").write(s)
PY_HIT
  done
done
echo "   $hits hit target(s) made transparent"

# Button captions are created AFTER their button, so they sit on top of it. Solar2D hit-tests the
# topmost object and propagates to its PARENT, not to siblings below it -- so a text label with no
# listener still swallows the tap and the button underneath never fires (operator: "the play btn
# does not work, my print in go_vplay.lua never runs"). Make every `<name>_lbl` caption
# non-hit-testable; the button underneath keeps the geometry.
labels=0
for f in "$APP"/components/*/layers/*_lbl_text.lua; do
  [ -f "$f" ] || continue
  python3 - "$f" <<'PY_LBL'
import sys
p = sys.argv[1]
s = open(p).read()
if "isHitTestable" in s:
    sys.exit(0)
s = s.replace('return require("components.kwik.layer_text").set(M)', """local baseText = require("components.kwik.layer_text").set(M)
local originalShow = baseText.didShow
function baseText:didShow(UI)
  if originalShow then originalShow(UI) end
  local obj = UI.sceneGroup and (UI.sceneGroup[self.name] or UI.sceneGroup[self.properties and self.properties.target])
  if obj ~= nil then
    obj.isHitTestable = false     -- a caption must not swallow the tap of the button under it
  end
end
return baseText""")
open(p, "w").write(s)
PY_LBL
  labels=$(( labels + 1 ))
done
echo "   $labels caption(s) made non-hit-testable"

# Control captions default to the plugin's cyan (0,1,1,1), which sits on the paper and is barely
# legible there (operator: "buttons of video control are not visible good on background"). Give every
# <name>_lbl caption a dark ink instead; body text on the dark plate keeps its cream/cyan.
ink=0
for f in "$APP"/components/*/layers/*_lbl_text.lua; do
  [ -f "$f" ] || continue
  if grep -q 'color    = { 0, 1, 1, 1 }' "$f"; then
    sed -i '' 's/color    = { 0, 1, 1, 1 }/color    = { 0.16, 0.13, 0.10, 1 }/' "$f"
    ink=$(( ink + 1 ))
  fi
done
echo "   $ink caption(s) recoloured to dark ink"

# ---------------------------------------------------------------------------
# 14. asset registry
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# 13c. text colour: black on paper, cream on the dark plates
# ---------------------------------------------------------------------------
# Operator: "change all the color of the text to black if they are not on black background".
# The plugin default is cyan (0,1,1,1), which is what most of the book inherited. Everything on the
# beige paper becomes black; the text that sits on an opaque dark layer keeps a light ink, otherwise
# it would vanish: `body` is drawn on the `plate` (#17130F) and the three R1/R2/R3 captions on the
# `p_r*` annotation panels (#241F18).
#
# `text_themed` is excluded on purpose: that page IS the palette option (O3-B) -- repainting it black
# would make it identical to `text` and the comparison would prove nothing.
BLACK='{ 0, 0, 0, 1 }'
CREAM='{ 0.95, 0.92, 0.86, 1 }'
painted=0
for f in "$APP"/components/*/layers/*_text.lua; do
  [ -f "$f" ] || continue
  # Only genuine TEXT classes. The glob `*_text.lua` also matches the base layer of the grid cell
  # that happens to be called `text` -- hb_text.lua (its transparent hit target) and hl_text.lua (its
  # caption base). Painting those black produced a solid black tile where the `text` thumbnail
  # should be (auditor finding 1). A text class is the one that requires layer_text.
  grep -q 'components.kwik.layer_text' "$f" || continue
  page=$(basename "$(dirname "$(dirname "$f")")")
  layer=$(basename "$f" _text.lua)
  [ "$page" = "text_themed" ] && continue
  ink="$BLACK"
  case "$layer" in
    body|r1_txt|r2_txt|r3_txt) ink="$CREAM" ;;   # on the dark footer plate / annotation panels
    hl_*) ink="$CREAM" ;;                        # grid captions sit on the dark grid panel
  esac
  sed -i '' -E "s/^( *color += +)\{[^}]*\},/\1$ink,/" "$f"
  painted=$(( painted + 1 ))
done
echo "   $painted text layer(s) recoloured (black on paper, cream on the dark plates)"

say "asset registry"
for p in "${SELECTED[@]}"; do
  case "$p" in
    audio)
      run "$K" asset link audios/short/design_blip.wav --book "$BOOK" --class audio --page audio >/dev/null || true
      run "$K" asset link audios/long/design_ambience.mp3 --book "$BOOK" --class audio --page audio >/dev/null || true
      ;;
  esac
done

# see §8b.1: `asset sync` cannot write a non-empty model.lua in this CLI build, so the registry
# is checked in and `asset check` (which uses the working parser) is the gate.
cp "$SRC/model.lua" "$APP/assets/model.lua"
run "$K" asset check "$BOOK"

say "done"
run "$K" page "$BOOK"
