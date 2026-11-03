# Building a design book (`<book>_design`)

A design book is not a story. It is a **bench**: every page shows one plugin
mechanism on purpose, at a known size, with an artifact that proves it worked.
The value is not the pictures — it is that each page states what it proves and
leaves evidence a second person can re-check.

Use one when a real book is about to depend on a mechanism you have not yet
watched work (sprite sheets, audio channels, video, animation, interaction,
recording). Build the bench first, then the book.

## What it is, and is not

| it is | it is not |
|---|---|
| one page per Kwik component class, on purpose, at a known size | a story with a plot |
| a test bench with evidence attached to each page | a demo reel |
| the place where plugin defects are found and written down | a place to hide a workaround |

The corollary that bites: **the person who built the pages cannot be the only
judge of them.** In the reference project every page was "green" in the
builder's own captures while three were black on a human's screen. File one
review issue per page — current capture, what the page must show, known
defects, a done-when list — and close it on evidence the builder did not
produce alone.

## 1. The four contracts, decided before the first page

These are the only numbers that must never drift. Put them in one file per
project and never type them twice.

| contract | reference value | what breaks if it changes |
|---|---|---|
| page frame | 1920 × 1280 (1.5:1) | every layer coordinate, every PSD, every thumbnail |
| content scale | 0.25 → 480 × 320 | every display size, the editor preview, captures |
| design resolution / orientation | landscape, one orientation only | touch coordinates, sweep scripts |
| capture size | the 480 × 320 page area at 2× | evidence comparability across pages |

## 2. Page inventory from the mechanism list, not from imagination

Enumerate the plugin's classes and give each a page whose *purpose* is stated in
its label. A page you cannot state a pass condition for does not belong in the
book. Keep the inventory as data so the sweep can iterate it.

## 3. Skeleton, then gate 0

Before any art: index, one page, bg layer, and a capture that returns. Gate 0 is
"one page renders and captures with 0 Lua errors". Do not build four pages on an
unverified skeleton — the first real page always exposes a scale or parenting
defect that invalidates every page built on it.

## 4. The two scale traps

* Layers are authored in **content units**: `1920 × 0.25 = 480`. Sizing from
  `display.contentWidth` gives 960 in production and 480 in the editor, so the
  page changes size with the mode.
* Kwik clamps `kwikGlobal.scale` to 0.25 for values ≥ 1, so a PSD-pixel layer
  declared at 1280 wide lands at 480. Declare PSD pixels and let the runtime
  scale; do not pre-divide.

## 5. Draw order: what draws last wins

Emit layers in the order they must paint, and remember two failure modes that
look like rendering bugs:

* a background emitted after the art hides it;
* hiding the layer you replace does not remove it — the stale object stays visible
  under the new one.

Every object belongs to `UI.sceneGroup`; remove it in `didHide`. A parentless
object survives the page turn and reappears on the next page.

## 6. Benches

Three benches paid for themselves in the reference project:

| bench | page proves | the trap |
|---|---|---|
| sprite sheet | the exporter's frames are addressable and animatable | five different frame-order/filename constructions fail before one works — keep the working one and the failing ones in the doc |
| video-once | one decoder plays, keys, and survives a page turn | `plugin.movie` wants a resource-relative path; `MovieRect` can hand back a nil texture in Kwik layers |
| video-layered | N decoders on one page, each independently controlled | geometry comes from the poster; transport bar is one tap target per layer |

The two video benches are **different mechanisms**, not one implementation with a
loop — do not collapse them.

## 7. Gates, written before the work

Write the table first, fill it as you go. Reference gates:

```bash
Scripts/design_build.sh                 # regenerate the design book
Scripts/design_build.sh --check         # CI: sources and generated files agree
Scripts/page_sweep.sh                   # every page: capture, colours, errors, framing
```

A sweep row is `page · colours · framing · errors · time`; `errors` counts Lua
errors in the simulator log and must be 0 for every page.

## 8. Evidence that is actually evidence

* capture in **production** mode — the editor paints its own chrome into the
  stage capture, so a "no editor chrome" claim taken in development mode is false;
* one capture per page, named `<page>.png`, from the page's own hook, not from a
  screenshot of a window;
* the log line that records the run (timestamp, error count) travels with the
  capture;
* a defect that is known and accepted is written in the page's doc, not left for
  the next reader to rediscover.

## 9. Carry a defect register forward

Keep a running list of plugin defects with the exact reproduction and the
workaround in force. In the reference project that register is why the video book
kept the fixed local `plugin_movie` build and never declared the plugin in
`build.settings`. A workaround without a written reason becomes a myth, and myths
get "cleaned up" by the next person.
