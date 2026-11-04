#!/usr/bin/env python3
"""Close the pinholes a chroma key leaves behind in a cut-out sprite.

Keying out a background leaves fully transparent pixels *inside* the artwork: one
or two pixels of alpha 0 sitting in otherwise solid fur, where the key colour
survived between brush strokes. Over a white page they are invisible; over any
other background they read as bright speckles, and scaling the sprite down makes
them worse.

Two passes, both of which only ever raise alpha — the silhouette never grows
beyond a pixel, and no edge is softened or sharpened:

  1. enclosed   — transparent pixels that cannot be reached from the image border
  2. near-enclosed — alpha < 32 with at least 6 of 8 fully opaque neighbours,
     which catches pinholes that leak to the background through a 1 px channel

Colour is taken from the *nearest fully opaque pixel* (multi-source BFS), not from
an average of neighbours. Averaging drags in the pale fringe left by the key and
produces bright smears; nearest-opaque keeps the local fur colour.

Partial alpha (1–254) is left exactly as it is: that is the sprite's antialiasing,
not a defect.

    fix_sprite_holes.py SPRITE.png [--dry-run] [--backup]

Exit status: 0 nothing to do or fixed clean, 1 dry-run with work pending, 2 residue.
"""
import argparse, os, shutil, sys
from collections import deque

import numpy as np
from PIL import Image


def enclosed_transparent(alpha):
    """True where a pixel is fully transparent and cannot be reached from the border."""
    h, w = alpha.shape
    trans = alpha == 0
    seen = np.zeros_like(trans, bool)
    dq = deque()
    for x in range(w):
        for y in (0, h - 1):
            if trans[y, x] and not seen[y, x]:
                seen[y, x] = True
                dq.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if trans[y, x] and not seen[y, x]:
                seen[y, x] = True
                dq.append((y, x))
    while dq:
        y, x = dq.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and trans[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                dq.append((ny, nx))
    return trans & ~seen


def nearest_opaque_colour(arr):
    """RGB of the closest fully opaque pixel, for every pixel (multi-source BFS)."""
    h, w = arr.shape[:2]
    solid = arr[:, :, 3] == 255
    colour = np.zeros((h, w, 3), np.uint8)
    have = solid.copy()
    colour[solid] = arr[solid, :3]
    dq = deque(map(tuple, np.argwhere(solid)))
    while dq:
        y, x = dq.popleft()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                ny, nx = y + dy, x + dx
                if 0 <= ny < h and 0 <= nx < w and not have[ny, nx]:
                    have[ny, nx] = True
                    colour[ny, nx] = colour[y, x]
                    dq.append((ny, nx))
    return colour


def holes_and_near(alpha):
    """The two masks this script closes: truly enclosed, and near-enclosed pinholes."""
    holes = enclosed_transparent(alpha)
    solid = alpha == 255
    op = solid.astype(np.int16)
    k = np.zeros_like(alpha, np.int16)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dy == 0 and dx == 0:
                continue
            k += np.roll(np.roll(op, dy, 0), dx, 1)
    near = (alpha < 32) & (k >= 6) & ~holes
    return holes, near


def fill_transparent_holes(arr):
    """Close keyed pinholes in an RGBA uint8 array. Returns (array, n_enclosed, n_near).

    Only ever raises alpha, and takes each fill colour from the nearest fully
    opaque pixel, so the silhouette does not grow and the key fringe is never
    averaged into the fill. Generators should call this on their output rather
    than shipping a sprite with holes in it.
    """
    out = arr
    total_holes = total_near = 0
    # Iterate to a fixed point. Filling a pixel makes it an opaque neighbour, which
    # can promote further pinholes, so a single pass leaves a residue (measured: 43
    # then 1 and only then 0). Converging here keeps the generator and the CLI in
    # step, and makes a second run a no-op.
    for _ in range(12):
        holes, near = holes_and_near(out[:, :, 3])
        n1, n2 = int(holes.sum()), int(near.sum())
        if n1 + n2 == 0:
            break
        colour = nearest_opaque_colour(out)
        filled = out.copy()
        for mask in (holes, near):
            ys, xs = np.where(mask)
            filled[ys, xs, :3] = colour[ys, xs]
            filled[ys, xs, 3] = 255
        out = filled
        total_holes += n1
        total_near += n2
    return out, total_holes, total_near


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sprite")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--backup", action="store_true")
    a = ap.parse_args()

    im = Image.open(a.sprite)
    had_alpha = im.mode in ("RGBA", "LA") or "transparency" in im.info
    im = im.convert("RGBA")
    arr = np.array(im)
    alpha = arr[:, :, 3]
    if not had_alpha or not (alpha == 0).any():
        print(f"{a.sprite}: no transparency — nothing to do")
        return 0

    holes, near = holes_and_near(alpha)

    n1, n2 = int(holes.sum()), int(near.sum())
    print(f"{a.sprite}: {im.size[0]}x{im.size[1]}  enclosed={n1}  near-enclosed={n2}")
    if n1 + n2 == 0:
        return 0
    if a.dry_run:
        print("dry run — nothing written")
        return 1

    colour = nearest_opaque_colour(arr)
    out = arr.copy()
    for mask in (holes, near):
        ys, xs = np.where(mask)
        out[ys, xs, :3] = colour[ys, xs]
        out[ys, xs, 3] = 255

    if a.backup:
        bak = a.sprite + ".bak"
        if not os.path.exists(bak):
            shutil.copy2(a.sprite, bak)
            print("backup:", bak)
    Image.fromarray(out).save(a.sprite)

    left = int(enclosed_transparent(np.array(Image.open(a.sprite))[:, :, 3]).sum())
    print(f"written {a.sprite}  enclosed now={left}  alpha0 "
          f"{int((alpha == 0).sum())} -> {int((np.array(Image.open(a.sprite))[:, :, 3] == 0).sum())}")
    return 0 if left == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
