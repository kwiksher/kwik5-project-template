# Building a video book (`<book>-video`)

One clip per page, rendered by a video model, encoded to Ogg Theora, and keyed at
runtime over the page backdrop. This is the variant to build first: one decoder
and one transport bar per page, and every trap below is smaller than the
per-character variant's (`CROPPED-VIDEO-BOOK.md`).

## 1. Sources

```
Scripts/book.video.yaml        authored direction: beat, motion, camera, duration,
                               chroma contract, keyed pages, chroma_shots
Scripts/video_stories.py       → Photoshop/<book>/video/{stories.yaml,plan.json,requests/*}
                                → Solar2D/App/<book>/  (the whole Kwik book)
Scripts/render_local.py        queue a render, wait, promote, encode
Scripts/to_ogv.py              mp4 → Theora (+ verify)
Scripts/chroma_key.py          probe a chroma field; key to alpha for stills
```

`book.video.yaml` is a *source* like the Fountain: story stays in the Fountain,
only what a moving frame needs lives here. Each story is `{id, name, label,
duration_s, camera, motion, keying}` plus a top-level `keyed_clips` map naming
the pages whose clip is a flat-field take.

## 2. Why a chroma field at all

There is no alpha in any video the renderer writes (H.264/H.265 `yuv420p`), and
Theora has no alpha plane either. So a character that must sit over a moving or
separate plate is rendered on a flat field and keyed in the engine.

* Key colour **`#00B140`**. Not white: a large white field smears into cream
  shirt and highlights, and the key eats the character.
* The class defines its own effect (`filter.custom.ogvChromaKey`) and binds the
  key colour through `CoronaVertexUserData`. Solar2D's built-in
  `filter.chromaKey` exposes no way to bind the colour and keys whole frames out.
* Probe every take before promoting it:

```bash
.venv/bin/python Scripts/chroma_key.py probe out/<slug>/clip.mp4 --color '#00B140'
# verdict ok, purity_median 1.0  (gate: min_key_purity 0.90)
```

The probe samples a border band (`margin_px: 8`). A clip cropped flush to the
character fails purity — keep ≥10 px of green around it.

## 3. Render profile — the numbers that work on an MPS box

```yaml
model: wan22-14b-i2v      # 5B produces black/noise under MPS; 14B works
width: 512, height: 288
duration_frames: 25
fps: 16
num_inference_steps: 4    # with the Lightning LoRAs
# ~110 s per clip on an M5 Pro
```

The delivery plan (`requests/*.json`) is a separate thing: 1280×720 / 97 frames /
30 steps / `wan22-5b` for a GPU host. Do not "fix" the local profile to match it.

```bash
Scripts/render_local.py --list                  # done / pending per page
Scripts/render_local.py --page <slug>           # render + encode one page
Scripts/render_local.py --all-pending
Scripts/render_local.py --page <slug> --chroma  # flat-field take
python3 Scripts/video_stories.py --app          # regenerate the book
```

**Order is enforced, not suggested.** `video_stories.py --app` refuses to run when
`clip.ogv` is older than `clip.mp4`. Skipping the encode ships a stale clip, and
it looks exactly like a render bug.

Folder contract per page:

```
out/<slug>/raw/<stamp>.mp4   verbatim download (never edited)
out/<slug>/clip.mp4          the chosen take
out/<slug>/clip.ogv          what the app ships
out/<slug>/meta.json         provenance: request, batch id, render profile
out/<slug>/chroma.json       keying: shot id, reference frame, purity, crop
```

## 4. The ogv layer class

`Solar2D/custom/components/ogv.lua` plays the clip as a display object through
`plugin.movie` (`CoronaExternalTexture`) with a still fallback.

Facts that cost hours — do not re-derive:

* `plugin.movie` wants a **resource-relative** filename. Hand it the absolute
  path `system.pathForFile` returns and it fails with *attempt to index a nil
  value*, because it re-resolves internally and gets nil.
* `movie.newMovieRect` can return a wrapper with a nil `.texture` in a Kwik layer,
  producing an object with no parent and nothing decoding. The class therefore
  creates the `MovieTexture` itself, resolves the path itself, builds the
  `ImageRect` from `texture.filename`, and parents it explicitly.
* A `plugin.movie` build from the marketplace (2022) frees the decoder on
  `stop()`, which crashes on rewind. Keep the fixed local build in
  `~/Library/Application Support/Corona/Simulator/Plugins/` and **do not declare**
  `["plugin.movie"]` in `build.settings` — declaring it makes the Simulator
  install the marketplace build over your local one.

```bash
stat -f '%z' "$HOME/Library/Application Support/Corona/Simulator/Plugins/plugin_movie.dylib"
# 822,432 = fixed local build   901,136 = 2022 marketplace build (crashes on rewind)
```

## 5. Composition: where the geometry comes from

The class takes its position **and size from the poster object** it finds in
`UI.sceneGroup`, not from `p.x`/`p.y`. The poster is the page's own image layer,
already in content units. Fit the clip into that box at the clip's aspect:

```lua
local aspect = tonumber(p.aspect) or (16 / 9)   -- page takes are 16:9
local w = pageW; local h = w / aspect
if h > pageH then h = pageH; w = h * aspect end
```

Keep `aspect` as a property even if every clip is 16:9 today: the cropped variant
needs it, and a 16:9-only class silently stretches a cropped texture.

## 6. Narration and the transport

* Narration is one `wav` per page in `assets/audios/`, started in `didShow` and
  **must be stopped in `didHide`** — not only in `destroy()`. Kwik keeps the
  previous scene after a page turn, so `destroy()` does not run on the turn and
  the old page narrates over the new one. This shipped once and was caught by an
  audit, with the page-turn probe as evidence.
* The transport bar's plate is the single tap target; the glyphs are decoration.
  Size the plate to contain the whole button row, or buttons are visible and dead
  (see `CROPPED-VIDEO-BOOK.md` §4, where a narrow layer made this fatal).

## 7. Gates before calling a video book done

```bash
python3 Scripts/video_stories.py --check     # generated tree matches the sources
Scripts/build_book.sh --check                # the page pipeline is still green
Scripts/render_local.py --list               # N/N done
.venv/bin/python Scripts/chroma_key.py probe out/<slug>/clip.ogv --color '#00B140'
```

Then look at the book: every page plays, the transport reacts (restart, pause,
stop, rewind), no page shows green, and a page turn does not leave the previous
narrator talking.
