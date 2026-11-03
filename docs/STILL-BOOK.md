# Building a still book (PSD → Kwik pages)

The `<book>` variant: a story book whose pages are composited still layers,
authored as PSDs, exported to Lua, and drawn by the runtime with no GPU work.

## 1. Sources own the content

```
Scripts/book.fountain          story: captions, cast tags, page order
pages/<page>/page.layers.yaml  one file per page: layer list, geometry, assets
Photoshop/<book>/              flat PSDs (one per page) + _sprites/ per character
Scripts/fountain2pages.py      fountain → pages/<page>/page.layers.yaml
Scripts/create_layered_psd.py  layers yaml → PSD
Scripts/layers2lua.py          PSD / layers yaml → Solar2D layer lua
Scripts/build_book.sh          the whole chain;  --check for CI
```

Nothing downstream is hand-written. The Fountain owns story, the layers YAML
owns geometry, the PSDs own art, and everything under `Solar2D/App/<book>/` is
generated from them.

## 2. The build, and the gate

```bash
Scripts/build_book.sh            # fountain → layers → PSD → Lua → assets
Scripts/build_book.sh --check    # verify only; exit 1 on drift
```

`--check` is the contract that makes the rest trustworthy: it rebuilds in memory
and diffs against the tree. Wire it into CI and into every "done" claim. In the
reference project it reports e.g. `ok: 9/9 steps, sources and generated files
agree`.

**Background art is not part of `build_book.sh`** — plates are rendered separately
by `render_pages.py` (a GPU job), and the build only consumes `art/bg.png`. What
the plate looks like is decided by three things — layered vs baked, the scene's
environment tag, and the per-page `plate:` camera line — all documented in
[`PIPELINE.md`](PIPELINE.md) §5. Read that before authoring a page's setting, or
every page in the book renders the same building.

## 3. Layers and the two scale traps

A layer file loads its own image and sizes itself; do **not** use
`components.kwik.layer_image.createImage()`:

* it resolves through `UI.props.imgDir`, which only the editor sets, so a page
  comes out missing in production;
* it multiplies by `kwikGlobal.scale`, a 480×320 design space, so a 1280×720
  layer comes out quarter-size.

Instead, resolve the path yourself, try `path` and `App/<book>/path`, and size in
**content units**: `1920 * 0.25 = 480` wide, 320 tall. Never size from
`display.contentWidth` — that is 960 in production and 480 in the editor, so the
page changes size with the mode.

```lua
local SCALE = 0.25
local w, h = 1920 * SCALE, 1280 * SCALE
```

## 4. Draw order is the layer order

Later layers paint over earlier ones. Two consequences that cost real time in the
reference project:

* a background layer emitted *after* the art hides the art;
* hiding the layer you replace does not remove it — a stale poster stayed visible
  under a newly spawned video because it was hidden, not destroyed.

Every display object belongs in `UI.sceneGroup`, and must be removed in
`didHide`/`destroy`. A parentless object lives on the stage and survives the page
turn — in practice you get the previous page's leftovers on top of the next page.

## 5. Image suffix ladders

`config.lua` declares `imageSuffix` `@2x`/`@4x`. Emit the ladder from one master
(`<page>_bg.png`, `@2x`, `@4x`) and have layers ask for the base name; the runtime
picks the file. Do not emit only the base — it will look soft on every device
that asks for `@2x`.

## 6. Page inventory and the sweep

The set of pages is data (`index.lua`), not a convention. The reference project
verifies every page with a sweep script that, per page: switches `env.page`,
relaunches the Simulator, waits for the page's own capture hook, records colour
count, framing verdict, Lua error count and a timestamp into a log. That log is
the evidence behind "17/17 pages pass" — keep it as a build artefact.

```bash
Scripts/page_sweep.sh              # all pages
Scripts/page_sweep.sh text sync    # named pages only
```

Capture in **production** mode: the editor paints its own chrome (a green page
guide) into the stage capture, and a record that says "no editor chrome" has to
be true of the run it describes.

## 7. Gate list before calling a still book done

1. `Scripts/build_book.sh --check` → *sources and generated files agree*.
2. Page sweep → every page captured, 0 Lua errors, framing verdict recorded.
3. No generated file edited by hand (`git grep "do not edit by hand" -- <file>`).
4. Assets present where layers expect them — a missing image logs a warning and
   leaves the page blank, which is easy to miss in a log full of noise.
