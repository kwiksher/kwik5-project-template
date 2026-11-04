# The sprite book — a catalogue of every still

A story book stages **one still per character per page**. That makes the pose
library invisible: you only ever see the handful of stills the pages happen to
use, and a defect in the other forty never shows up in the book you read. The
sprite book is the index of it — one page per character, every pose side by side
and labelled, plus a props page and a contact page at thumbnail size.

It is not a book you ship to a reader. It is the bench where you look at the art
before the story book consumes it.

```
Photoshop/<book>/_sprites/<character>/<pose>.png   →  Photoshop/<book>_sprites/<page>/page.layers.yaml
Photoshop/<book>/_sprites/<character>.png              (the "standing" baseline still)
Photoshop/<book>/_sprites/props/*.png
                                                   →  Solar2D/App/<book>_sprites/  (page.lua, components, assets)
```

## 1. Build

```bash
Scripts/build_sprites_book.sh            # build
Scripts/build_sprites_book.sh --check    # verify only; non-zero if anything is stale
```

Four transforms, the same ones the story book uses, with `KWIK_BOOK` pointed at
`<book>_sprites`:

| step | script | writes |
|---|---|---|
| author pages | `sprites_book.py` | `Photoshop/<book>_sprites/<page>/page.layers.yaml` |
| rasterise | `create_layered_psd.py` | `page.psd` + `png/<layer>.png` |
| emit + install | `layers2lua.py` | `Solar2D/App/<book>_sprites/**`, `index.lua` |
| gate | `asset_gate.py` | — verifies installed PNGs match their sources |

`--check` runs all four in verify mode, which is what makes "the catalogue is
current" a claim rather than an opinion:

```text
ok: 5/5 pages, 109/109 layer images match
ok: catalogue pages and generated files agree
```

## 2. Where the data comes from

Nothing about the cast is written into this script:

- **which characters have a page** — `CHARACTERS` from `Scripts/book.yaml`
- **which stills exist** — the files under `Photoshop/<book>/_sprites/<character>/`,
  plus `<character>.png` as the `standing` baseline
- **props** — `_sprites/props/*.png`, on their own page
- **descriptions** — the character's `description` in `book.yaml`, used as the page legend

So adding a pose is dropping a PNG into the right folder and re-running; adding a
character is a `book.yaml` entry and it gets a page for free. The catalogue cannot
drift from the art, because it reads the art.

**Pose order** is the one piece of taste. `ORDER` in `sprites_book.py` maps a pose
name to a rank (a story's reading order is not alphabetical — walk, run, play,
crouch, wash, sit, sleep); anything unlisted sorts after these, alphabetically.
Leave it empty for plain alphabetical order.

## 3. Page anatomy

Everything is in PSD pixels (1920×1280 canvas, centres not top-left — the same
contract as any page layer):

| layer | what |
|---|---|
| `card` | full-canvas flat fill, the page colour |
| `panel` | the stage the keyed stills read against (see §4) |
| `title`, `legend` | page name, and the character's description |
| `still_NN` + `label_NN` | one cell per still: `fit: contain`, `transparent_color: auto`, with the pose name under it |
| `footer` | how many stills, where they come from |

Constants worth knowing before you change the look: `PANEL`, `GRID` (origin, width,
top/bottom, label height), `COLUMNS`, `MAX_STILL_H` (a page of one wide prop should
not stretch it to the full panel), and the palette — `CARD_COLOUR`,
`PANEL_COLOUR`, `LABEL_COLOUR`, `INK`/`INK_MUTED`.

## 4. Two defects this bench exists to catch

Both were found by looking at a catalogue page over a background, and neither was
visible in the story book.

**A near-black stage panel.** `#14110D` read as a black slab against the cream
cards. The panel needs contrast against the page — cream cells on a cream page
vanish — but "black" is not the only way to get it. A muted mid tone from the
book's own palette (for example `#5C6652`, a sage, measured `(92,102,82)`) keeps
the stills and the sand labels readable without the slab. **Do not remove the fill
instead**: with alpha 0 the stills drop straight into the page, which is the whole
problem the panel solves.

**Stills with transparent holes.** A chroma key leaves fully transparent pixels
*inside* the artwork — invisible on white, bright speckles over any other
background, worse when scaled down. `fix_sprite_holes.py` closes them in two
passes and only ever raises alpha, so the silhouette never grows:

```bash
python3 Scripts/fix_sprite_holes.py Photoshop/<book>/_sprites/<character>/<pose>.png
```

Fill colour comes from the nearest fully opaque pixel (multi-source BFS), not a
neighbour average — averaging pulls in the pale key fringe and smears it across
the art. Partial alpha is left alone: that is antialiasing, not a defect. It
iterates to a fixed point because filling a pixel makes it an opaque neighbour and
promotes further pinholes (measured: one pass left 43, the next 1, then 0).

Generators should call it rather than ship a holed sprite — anything that keys a
backdrop and writes a PNG should run the result through `fill_transparent_holes()`.

## 5. Never re-key a cut-out

`create_layered_psd.py` keys a flat backdrop out of a layer when it declares
`transparent_color`. It **skips that** when the source already has fully
transparent pixels, and it must: a generated sprite's border is transparent but
still carries RGB, so `auto` resolves the key colour to whatever is in that
border and keys the *artwork*.

Measured on a real still whose transparent border carried mud-brown RGB:

```text
dominant_border_color(…) = (120, 80, 48)
opaque px 289,809 → 143,677 after re-key     (146,132 lost — half the figure)
```

The catalogue went from "head and scarf solid, torso dissolving" to correct once
re-keying cut-outs was skipped. If you add a sprite-producing step, keep it
cut-out (alpha present) rather than flattening it onto a colour.

## 6. Reading it

Set the book in the Simulator and page through:

```lua
-- Solar2D/main.lua
env.book = "<book>_sprites"
```

Then look at each still **over the panel**, not over white — that is where
pinholes, keyed-through bodies and stray haloes show. This is a review bench, so
being boring and uniform is the point: the same panel, the same cell size, the
same label position, so a difference means something.
