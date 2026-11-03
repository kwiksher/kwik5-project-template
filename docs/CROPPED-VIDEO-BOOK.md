# Building a cropped video book (`<book>-video-cropped`)

The layered variant: each page is a **stack of per-character clips**, each one
encoded down to that character's own box. `<book>-video` remains the full-canvas
single-take build, so the two can be compared on the same source.

Choose this when characters must be timed, scaled or muted independently —
parallax, a character who reacts late, a page where one actor is replaced. The
cost is N decoders and N layers per page, and a composition that must be kept
aligned by arithmetic instead of by a single frame.

## 1. Where the layers come from

A cropped/layered page's **plate carries the setting and no characters** — the
cast arrives as keyed sprites on their own layers. The plate prompt is generated
per page from the scene's environment tag plus its `plate:` camera line; see
[`PIPELINE.md`](PIPELINE.md) §5 for what does and does not control its style.

Do **not** author per-character shots by hand if per-page shots already exist.
Every page's shipped together-take already lists its cast with fractions of the
render canvas:

```yaml
- id: chroma_bath_splash          # the together-take
  for_story: p6
  sprites:
    - {subject: <book>, x: 0.52, y: 0.68, h: 0.26}
    - {subject: hero,   x: 0.18, y: 0.50, h: 0.55}
    - {subject: friend,     x: 0.76, y: 0.52, h: 0.60}
```

Split it by emitting one shot per entry, **copying the placement verbatim**:

```yaml
- id: chroma_split_<page>_friend
  for_story: p6
  out_slug: split-<page>-<character>     # its own out/<slug>/ — never the page's
  subject: friend
  duration_s: 5.0
  sprites:
    - {subject: friend, x: 0.76, y: 0.52, h: 0.60}
  camera: "locked off, full body head to toe, no cropping, no zoom"
  motion: >-
    Only the friend is in frame; no other character is present. <the page's motion>
```

`out_slug` is not cosmetic: without it every take for the page lands in
`out/<page>/clip.mp4` and the last render wins. The page's own together-take must
survive.

`motion` is a derivation (`"Only the <subject> is in frame; …"` + the page's own
motion). It works because the reference frame is a sprite composite — identity
comes from the shipped art, not the prompt — but hand-authored per-character
motion animates better. Spend that effort only on pages you intend to keep.

### The invented cast comes from the prompt

A per-character take is i2v from a sprite on a flat field, so the model uses that
freedom to add people. The chroma probe cannot see it: the field is clean, the
*content* is wrong.

The usual cause is not the model — it is a `motion` text copied from the page's
together-take, so it still describes the other characters:

```yaml
# together-take motion, reused by mistake in a single-character take:
motion: the girl laughs and lifts the puppy closer to her chest …
# the model draws what the prompt describes: a second figure, right there
```

Every split `motion` must describe **only its own subject**. `identity_check.py`
enforces it (§6) and the fix is re-rendering, not tolerance.

A rejected take must not ship. Mark its layer `enabled: false` in
`book.video.yaml` — `video_stories.py` drops it before writing `index.lua` and
prunes any scene, component, video or poster left over from the previous emit,
so the tree always says exactly what the book is.

## 2. Crop the encode, not the master

A character occupies **3–13 %** of a 512×288 chroma canvas. Shipping the whole
field costs 590 KB of texture per layer and re-uploads it every frame for pixels
that key straight out.

Measure, never author, the box: the character moves, and a hand-typed box goes
stale the moment a take is re-rendered. `Scripts/render_local.py --autocrop`:

1. decodes the finished take and unions the non-key pixels across **all** frames;
2. grows the box by ≥10 px (the purity probe samples an 8 px border band);
3. aligns origin and size to even values for 4:2:0;
4. stores the box in `out/<slug>/chroma.json`;
5. encodes `clip.ogv` with `--crop x:y:w:h`, leaving `clip.mp4` full-canvas.

```bash
Scripts/render_local.py --shot chroma_split_<page>_friend --promote --autocrop
Scripts/render_local.py --shot chroma_split_<page>_friend --reencode --autocrop  # no re-render
```

### What cropping buys, and what it costs

Measured on three layers (<book> 96×84, hero 100×158, friend 110×236):

| | full canvas ×3 | cropped | |
|---|---|---|---|
| texture memory | 1.69 MB | 195 KB | 8.9× less |
| pixels composited per frame | 442,368 | 49,824 | 8.9× less |
| texture upload at 16 fps | 27.0 MB/s | 3.0 MB/s | 8.9× less |
| **file bytes** | 101 KB | 111 KB | **+10 % — worse** |
| decode CPU | 0.07 ms/frame | 0.05–0.07 ms/frame | negligible either way |

So crop for **memory and fill rate**, never for file size: the flat field is the
cheapest thing in a Theora frame, and cropping raises bits per remaining pixel.
If you need bytes, lower `--video-q` from 7 to 5.

## 3. Geometry: two coordinate systems, one conversion

Three different spaces meet on a stacked page. Get this wrong and the layers
stack in the middle of the page (which is what happened first).

| space | what it is |
|---|---|
| clip pixels | the crop box lives here, e.g. 512×288 canvas |
| page units | the layer's authored frame: **1280 × 720** (16:9 inside the 3:2 page) |
| content units | what the runtime draws: `page_units × 0.375` → 480 × 270 |

For a crop box `(x, y, w, h)` on a canvas `cw × ch`:

```python
k  = 1280 / cw                       # page units per clip pixel
px, py = (x + w/2) * k, (y + h/2) * k      # layer centre, page units
pw, ph = w * k, h * k                      # layer size, page units

kd = 480 / cw                        # content units per clip pixel
dx = (x + w/2 - cw/2) * kd                 # offset from the stage centre
dy = (y + h/2 - ch/2) * kd
```

`dy` is **not** `py × 0.375`: the clip is 16:9 and the page is 3:2, so the video
band is centred vertically and the two vertical origins differ by 25 content
units. That 25 is the bug that puts every layer 25 units too high.

Two more rules, both learned by watching it break:

* the layer carries its own `width`/`height`/`x`/`y` **and** `aspect = w/h` —
  the class otherwise forces 16:9 and stretches a cropped texture;
* the class takes its geometry from the **poster object**, so the poster layer
  must be positioned too:
  `px, py = display.contentCenterX + dx, display.contentCenterY + dy`.
  A centred poster stacks every layer on top of the others.

## 4. Transport: one bar per character, four buttons

A video layer builds its own transport bar, so a 3-layer page draws three of
them, one under each character. That is the default (`controls: per_layer` in
`book.video.yaml`): each bar drives only its own clip, so a character can be
paused while the others keep moving. Switch a page to `per_page` when it should
play as one beat — then only the page's **first** layer carries a bar, emitted
with `stackSync = true`, and that one bar fans out across every layer on the
page (`_playSelf` / `_pauseSelf` / `_restartSelf` / `_stopSelf`).

The bar is always **four buttons** — restart, play/pause, stop, visibility:

```
|◀    ▶/||    ■    ◉̸
```

Restart rewinds and plays; pause freezes in place; stop rewinds and stays
paused; visibility hides the clip *and* its poster, leaving the bar tappable so
the character can come back. Button 4 is the visibility toggle; there used to be
a fifth button whose glyph duplicated restart.

Narration is separate from controls: it goes on the page's **first** layer only,
whatever the transport scheme is, or three narrators talk at once.

And the bar must fit: the plate is the single tap target, so its width has to
contain the whole button row. On a 480-wide page take it always did; on a
~100-wide cropped layer the outer two glyphs are drawn **outside** the plate —
visible buttons, no hit area. Size the bar to the layer's box:

```lua
if btnW * 4 + gap * 3 > w then barH = math.max(16, w / 5.05) end
```

`per_layer` bars are also emitted with `compactControls = true`, so the plate
hugs the button row instead of spanning the layer — two full-width plates on one
page sit on top of each other. The trade-off is real: fitting four buttons into a
character column means small buttons (~18 units instead of 26). If you need big
buttons, use one `per_page` transport on the first layer.

## 5. Emitting a second book from the same sources

Keep both variants in one project and switch with `env.book`:

```yaml
cropped_book:
  id: <book>-video-cropped
  label: "… cropped per-character build"
  pages:
    - page: <page>
      from_story: p6
      label: "p6 — the bath"
      layers:
        - {slug: split-<page>-<character>, shot: chroma_split_<page>_<character>}
        - {slug: split-<page>-<character>,   shot: chroma_split_<page>-hero}
        - {slug: split-<page>-<character>,     shot: chroma_split_<page>_friend}
```

The emitter then writes `Solar2D/App/<book>-video-cropped/`:

```
index.lua                                  scene order
<page>.lua                                 bg + one ogv layer per cast member
components/<page>/layers/<page>_bg.lua     backdrop, borrowed from the video book
components/<page>/layers/<slug>_video.lua  poster; carries the layer's box
components/<page>/layers/<slug>_video_ogv.lua  the clip: aspect + geometry
assets/videos/<slug>.ogv                   cropped clips
assets/images/<slug>/<slug>_video.png      poster at the crop's aspect (0.75 × box)
assets/audios/<narration>.wav              one per page
```

The backdrop ladder is copied from the full-canvas book, so both variants show
identical art behind the cast.

## 6. Gates

```bash
.venv/bin/python Scripts/chroma_key.py probe out/<slug>/clip.ogv --color '#00B140'   # per layer
.venv/bin/python Scripts/identity_check.py                                          # cast, shape, colour
.venv/bin/python Scripts/identity_check.py --json                                   # {"takes": …, "bad": …}
.venv/bin/python Scripts/video_stories.py --check
Scripts/build_book.sh --check
```

`identity_check.py` compares each take with the plate it was rendered from
(`chroma.json` → `reference_frame`) over nine decoded frames: the biggest other
connected blob relative to the character (`2nd`), the same for a blob standing
away from the body (`far`), bbox fill against the plate (`fill`), and a coarse
RGB histogram against the plate (`colour`). A detached hand or boot ~0.20 of the
body and hugging it passes; a second character of 0.35 or more fails even when
adjacent. Verdicts: `ok`, `extra-cast`, `shape-drift`, `colour-drift`, `empty`,
`no-clip`; exit 1 if anything fails.

Then, in the Simulator with `env.book = "<book>-video-cropped"`: characters in
the same relative positions as the full-canvas book, no green anywhere, one
transport bar per character (`per_layer`) or one per page (`per_page`) — pick
one and hold it — narration starts once. Capture as evidence —
`display.save(display.getCurrentStage(), {filename=…, baseDir=system.DocumentsDirectory})`
from the layer's own `debug`/`capture` property, since screen recording is often
not permitted for the terminal.
