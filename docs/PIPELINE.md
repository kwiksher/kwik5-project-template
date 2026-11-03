# The page pipeline

Every script that turns an authoring source into a running book. The scripts are
generic; a **book** is the data that makes them concrete, and that data lives in
one file: `Scripts/book.yaml` (see §2).

```
book.fountain ──fountain2pages──> Photoshop/<book>/<page>/page.{model.md,layers.yaml,audios.yaml}
                                              │
                            ┌─────────────────┼──────────────────┐
                    create_layered_psd   render_pages        video_stories
                            │                 │                   │
                  page.psd + png/      art/bg.png (render)   stories.yaml → clips
                            │                 │                   │
                     layers2lua ──────────────┴────────> Solar2D/App/<book>/…
```

## 1. Setup

```bash
python3 -m venv .venv
.venv/bin/pip install -r Scripts/requirements.txt
python3 Scripts/book_config.py          # what the pipeline sees of your book
```

`Scripts/requirements.txt` carries the four hard dependencies (`pyyaml`,
`pillow`, `numpy`, `psd-tools`); `scipy` is optional and only speeds up
`identity_check.py`.

## 2. `Scripts/book.yaml` — the only book-shaped file

```yaml
book: book                 # Solar2D app name AND Photoshop/<book> page tree name
design_book: book_design   # app name for the sprite/contact-sheet bench
canvas: {width: 1920, height: 1280, scale: 0.25}   # safe area
bg:     {width: 2776, height: 1440}                # overscan backdrop plate
art_direction: >- …        # style clause every prompt ends with
cast:                      # identity lives here, never in a prompt
  hero:  {name: Hero, subject_id: 1, trigger: hero_v1, kind: character, description: …}
  friend:{name: Friend, subject_id: 2, trigger: friend_v1, kind: character, description: …}
  meadow:{name: Meadow, subject_id: 3, trigger: meadow_v1, kind: environment, description: …}
placement:                 # page -> [(tag, x, y, w, h)] PSD pixels, centres
  p1: [[hero, 1250, 640, 480, 900]]
  p2: [[hero, 620, 660, 470, 880], [friend, 1250, 930, 430, 430]]
crops: {}                  # page -> {top|bottom|left|right: fraction to trim}
```

`book_config.py` loads it and exposes `BOOK`, `CANVAS`, `BG`, `ART_DIRECTION`,
`CAST`, `CHARACTERS`, `ENVIRONMENTS`, `PLACEMENT`, `CROPS`, `DESIGN_BOOK`.
Nothing downstream carries a cast, a placement or an art-direction clause of its
own, so a second book is a second YAML file:

```bash
BOOK_YAML=Scripts/book.other.yaml python3 Scripts/build_book.sh
BOOK=other python3 Scripts/book_config.py
```

`paths.py` is the other seam — it derives every path from `book`:

| what | where |
|---|---|
| authored page tree | `Photoshop/<book>/` (`BOOK_PAGES_DIR` overrides) |
| processed layers | `Photoshop/<book>/<page>/png/<layer>.png` |
| emitted Lua | `Solar2D/App/<book>/components/<page>/layers/*.lua` |
| installed PNGs | `Solar2D/App/<book>/assets/images/<page>/<layer>.png` |
| clips / audio | `Solar2D/App/<book>/assets/{videos,audios}/` |

## 3. Scripts

**Sources → page tree**

| script | does |
|---|---|
| `fountain2pages.py` | `Scripts/book.fountain` → `page.model.md`, `page.layers.yaml`, `page.audios.yaml`; `--check` fails if the tree is stale |
| `fountain2pages.py --page` | re-emit one page only |

**Page tree → Photoshop**

| script | does |
|---|---|
| `create_layered_psd.py` | `page.layers.yaml` → `page.psd` + one processed PNG per layer; `--check`, `--dataset`; also owns `chroma_key()` / `dominant_border_color()` used by the video scripts |
| `create_scene_psd.py` | the older, standalone scene tool: a plain `scene_layers.yaml` → PSD, no page tree, no page geometry contract |
| `psd_thumbnails.py` | embeds a thumbnail into a `page.psd` |
| `upscale_plates.py` | deterministic 2× backdrop plate enlargement (lanczos / external engine) |
| `frame_proof.py` | renders one page's composites to PNG for review |

**Page tree → Solar2D**

| script | does |
|---|---|
| `layers2lua.py` | `page.layers.yaml` → `components/<page>/layers/*.lua`; `--all` for the whole tree |
| `build_book.sh` | the whole gate: fountain → PSD/PNG → Lua; `--check` mode for CI |

**Video**

| script | does |
|---|---|
| `video_stories.py` | `stories.yaml` → resolve prompts, `plan.json`, batch-video request bodies, i2v reference frames; `--app` also emits the video book and copies assets |
| `render_local.py` | renders the video book locally (Simulator + capture) |
| `chroma_key.py` | keys a rendered clip (`key clip.mp4 -o clip.webm --format webm\|prores\|pngseq`) |
| `to_ogv.py` | any clip → `.ogv` for the Kwik movie plugin, optionally installing it into `assets/videos/` |
| `render_audio.py` | narration scripts → `assets/audios/` |

**Checks and benches**

| script | does |
|---|---|
| `asset_gate.py` | every emitted PNG exists and matches its layer box |
| `overscan_check.py` | background plates cover the canvas after overscan |
| `identity_check.py` | is a per-character take the character it claims? Compares each take with its reference plate (cast, shape, colour) over nine frames; `--json`; exit 1 on any `extra-cast` / `shape-drift` / `colour-drift`. A rejected take is dropped by `enabled: false` in `book.video.yaml` |
| `cast_sheets.py` | character sprite contact sheets from `Photoshop/<book>/cast/` |
| `design_sheets.py`, `design_media.py`, `design_assets_html.py` | the `<book>_design` bench: sprite sheets, deterministic test media, HTML evidence |
| `page_sweep.sh`, `record_clip.sh` | batch capture helpers for the Simulator |

## 4. Runtime component

`Solar2D/custom/components/ogv.lua` is the movie layer every video variant uses:
it takes its box from its poster, sizes its own four-button transport bar
(restart, play/pause, stop, visibility), and either drives only its own clip
(`per_layer`, the default) or the whole page (`per_page`, `stackSync = true`).
See `docs/CROPPED-VIDEO-BOOK.md` §4.

## 5. Page background art — what actually controls it

`render_pages.py` renders a page's plate from `page.model.md`, which `fountain2pages.py`
generates from the fountain scene. Three things decide what comes out, in this order.

### 5.1 Layered or baked decides whether the plate has characters on it

| page mode | who draws the cast | plate prompt |
|---|---|---|
| **layered** (`_sprites/<name>.png` layers in `page.layers.yaml`) | the sprites, composited by `create_layered_psd.py` | `## Plate Prompt` — setting only, `subject_ids: []` |
| **baked** (no sprite layers) | the image model, painted into the plate | `## Prompt` — art direction + cast + action |

Both are legitimate; they are different products. A layered page's plate is scenery, and
anyone composited over it is the cast. A baked page's plate *is* the illustration.

Deciding is a data edit, not a code edit (see §2): add or remove `_sprites` layers in
`page.layers.yaml` and the page flips mode on the next `fountain2pages.py` run.

### 5.2 The setting comes from the scene's own environment tag

Every scene tags the place it happens in, and each tag is an `kind: environment` entry
in `book.yaml`. **One environment per book is the classic mistake**: every plate then
renders the same building from a slightly different angle, and interior beats (kitchen,
bedroom) get handed an exterior. Tag what the beat needs — meadow, porch, doorstep,
path, scullery, kitchen, bedroom — and give each a distinct description in `book.yaml`.

```yaml
cast:
  porch:
    name: Farmhouse Porch
    kind: environment
    description: >-
      the front of a weathered stone cottage seen close: a sage-green plank door on
      open hinges, a stone lintel, climbing rose, two leaded windows, pots of
      geraniums on the flags, rough grass and gravel in the foreground
```

Environments carry **no `subject_id` and no `trigger`** — they have no LoRA — so both are
optional in the cast schema.

### 5.3 `plate:` — the per-page camera, and why it is not optional

Plate renders are **deterministic**: the same prompt returns a byte-identical image. Two
pages that share a setting will therefore come back as *the same picture* unless something
page-specific differs. The `plate:` key in the scene meta is that something:

```fountain
<!-- page: p3 | spread: 3 | caption: "…" | plate: the porch head-on, the open door centred, the stone step across the bottom of frame -->
```

Give every page a `plate:` line saying where the camera is, and what the frame contains.
This is also the place to encode story-specific detail the plate must show — *“the front
door standing wide open onto a dark hallway”* — because anything only written in the
`action` line is excluded from a layered page's plate prompt (the action names characters).

### 5.4 What does *not* control the style

Measured on the reference build, same model/style/size (`zimage-turbo` / `artistic` /
1536×1024 / `auto_enhance: false` / guidance 0):

| variant | texture (laplacian) | saturation | tonal range |
|---|---|---|---|
| cast-free plate prompt | 10.03 | 71.6 | 55.6 |
| cast described + character LoRA ids | 13.62 | 93.2 | 40.4 |
| cast described, `subject_ids: []` | 13.62 | 93.2 | **40.4** (byte-identical) |
| cast described + "flat illustrated, no brush texture" + negatives | 13.46 | 91.1 | 40.5 |

- **Character LoRA ids are inert.** Dropping them changed nothing — the output was
  byte-identical. Do not chase style through `subject_ids`.
- **Style instructions are ignored while figures are in the prompt.** A flat/illustrative
  clause plus a negative list of “brush texture, paper grain, painterly strokes” moved
  texture by 0.16.
- **Style flips on figures-vs-no-figures.** The only clean, flat, illustrative plates are
  the cast-free ones. If a book must look flat throughout, its pages must be **layered**.
- **Render settings are not the variable.** An older, clean plate from the same project
  used the identical model/style/size/guidance.

### 5.5 The prompt shapes

Both builders share `FULL_BLEED` (“runs to every edge — no border, no margin, no frame, no
vignette, no white surround”) and `COLOUR` (“rich, well-saturated gouache… not washed out,
not pastel”) — without the first, plates come back inset inside a cream margin.

```text
# layered page — ## Plate Prompt
<art_direction>

Setting:
- <environment name>: <description>

Empty setting: no characters, no people, no animals, no figures anywhere in the frame
— the scene is staged with nothing in it.

<FULL_BLEED>

<COLOUR>

View: <the scene's plate: line>

Composition: the whole scene inside a 3:2 landscape frame, nothing essential near the edges.
```

Read what a page will actually send before rendering:

```bash
python3 -c "import sys;sys.path.insert(0,'Scripts');import render_pages as r;print(r.parse_model('p3'))"
```

If a plate prompt ever seems ignored, that call is the answer: `parse_model()` falls back
to the full cast-bearing `## Prompt` whenever the `## Plate Prompt` block does not match,
and it does so **silently**.

## 6. Gates

```bash
python3 Scripts/fountain2pages.py --check      # the authored page tree is current
Scripts/build_book.sh --check                  # every generated file agrees with its source
.venv/bin/python Scripts/video_stories.py --check
python3 Scripts/overscan_check.py
python3 Scripts/asset_gate.py
```

All gates are read-only in `--check` mode; without it they rewrite their outputs.

## 7. What this repo does *not* contain — and where to look instead

Artwork, clips, audio and story text. `Photoshop/<book>/`, `out/` and
`Solar2D/App/<book>/assets/` are yours to create; the example `book.yaml` ships
placeholder cast entries so the scripts run before you have a single image.

For a **working reference**, see the `biscuit-comes-home` project
(https://github.com/Kwik-Dev/biscuit-comes-home). It is a real book built with
these exact scripts, with all four variants side by side:

| variant | what to look at there |
|---|---|
| still | `Photoshop/<book>/` page tree, `Solar2D/App/<book>/components/` |
| video | `Photoshop/<book>/video/stories.yaml`, emitted `Solar2D/App/<book>-video/` |
| cropped video | the `cropped_book` block in `book.video.yaml`, `Solar2D/App/<book>-video-cropped/` |
| design | `design_build.sh` and the `<book>_design` app |

Read it as an *example of the shape* — its cast, placements and art direction are
that book's, and belong in your `Scripts/book.yaml`, not here. Its
`docs/VIDEO-HANDOFF.md` is the long-form account of every trap the pipeline hits
(decoder pacing, oversized textures, transport fan-out, duplicate cast in split
takes); this repo's `docs/` carries the rules, that one carries the war stories.
