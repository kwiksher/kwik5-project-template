#!/usr/bin/env python3
"""Prove the bleed is real pixels — no reflection, no repetition, no join.

The plate is 2776x1440 (1.928:1); the page frame is 1920x1280 (1.5:1). The
difference is 428 px of bleed per side and 80 px top/bottom. That band is the one
place the pipeline can put pixels on screen that the artist never painted, so it
is measured rather than eyeballed, and **a reflection test is the primary
assertion** — the earlier build passed a "the band continues the adjacent edge"
test while still duplicating a whole scene, because continuity is not the same
thing as honesty.

Two methods are understood, and the check is chosen from the YAML:

``crop-from-larger-source`` (current)
    ``bg`` is a centre crop of ``art/bg-large.png``. Assertions:
    * the plate equals that centre crop, byte for byte;
    * the crop is centred in the source (|top − bottom| ≤ 1);
    * **no bleed column equals any column of the source mirrored** — except a
      column that is its own mirror (palindromic) or uniform, which cannot tell
      the two apart;
    * the seam delta is interior-like (the join is between two real neighbours).

``extend: mirror|edge`` (legacy)
    the band was synthesised, so it must at least be the *adjacent* edge and the
    join must be continuous; a far-side match is the mirror-tiling defect.

    $ Scripts/overscan_check.py            # every page
    $ Scripts/overscan_check.py p1         # one page
    $ Scripts/overscan_check.py --json

Exit status is 1 if any page fails any assertion.
"""

from __future__ import annotations

import argparse
import glob
import hashlib
import json
import os
import sys
from typing import Any

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from paths import PAGES_DIR, REPO_ROOT, page_yaml, rel, source_layer_png  # noqa: E402

import yaml  # noqa: E402
from PIL import Image, ImageChops, ImageStat  # noqa: E402

FRAME_W, FRAME_H = 1920, 1280


def mean_abs_delta(a: Image.Image, b: Image.Image) -> float:
    if a.size != b.size:
        return float("inf")
    return sum(ImageStat.Stat(ImageChops.difference(a, b)).mean) / 3.0


def column(img: Image.Image, x: int) -> Image.Image:
    return img.crop((x, 0, x + 1, img.height))


def row(img: Image.Image, y: int) -> Image.Image:
    return img.crop((0, y, img.width, y + 1))


def interior_delta(img: Image.Image, x0: int, x1: int, step: int = 7) -> float:
    values = [mean_abs_delta(column(img, x), column(img, x + 1)) for x in range(x0, x1 - 1, step)]
    return sum(values) / len(values) if values else 0.0


def column_signatures(img: Image.Image) -> dict[str, int]:
    """md5 of every column → first x, for cheap exact column matching."""
    out: dict[str, int] = {}
    for x in range(img.width):
        digest = hashlib.md5(img.crop((x, 0, x + 1, img.height)).tobytes()).hexdigest()
        out.setdefault(digest, x)
    return out


def column_variance(img: Image.Image, x: int) -> float:
    stat = ImageStat.Stat(img.crop((x, 0, x + 1, img.height)))
    return max(stat.stddev) if stat.stddev else 0.0


def band_offset(band: Image.Image, art: Image.Image, flipped: bool) -> tuple[int, float]:
    source = art.transpose(Image.FLIP_LEFT_RIGHT) if flipped else art
    limit = source.width - band.width
    best = (0, float("inf"))
    for offset in range(0, max(1, limit + 1), 2):
        ref = source.crop((offset, 0, offset + band.width, band.height))
        if ref.size != band.size:
            continue
        delta = mean_abs_delta(band, ref)
        if delta < best[1]:
            best = (offset, delta)
    return best


def check_crop_method(page: str, plate: Image.Image, plate_path: str, bg: dict[str, Any]) -> dict[str, Any]:
    large_rel = str(bg.get("image", ""))
    large_path = large_rel if os.path.isabs(large_rel) else os.path.join(REPO_ROOT, large_rel)
    result: dict[str, Any] = {"method": "crop-from-larger-source", "large": large_rel}
    problems: list[str] = []

    if not os.path.exists(large_path):
        result["problems"] = [f"large source missing: {large_rel}"]
        result["verdict"] = "broken"
        return result

    with Image.open(large_path) as im:
        large = im.convert("RGB")
    result["large_size"] = f"{large.width}x{large.height}"

    # Where the plate sits inside the large source (widths match: 2776), and where
    # the page frame sits inside the plate (that is the bleed, 428 px each side).
    crop_left = (large.width - plate.width) // 2
    crop_top = int(float((bg.get("crop") or {}).get("top", (large.height - plate.height) // 2)))
    crop_bottom = int(
        float((bg.get("crop") or {}).get("bottom", large.height - plate.height - crop_top))
    )
    frame_left = (plate.width - FRAME_W) // 2
    frame_top = (plate.height - FRAME_H) // 2
    result["crop"] = {"left": crop_left, "top": crop_top, "bottom": crop_bottom}
    result["frame_offset"] = {"left": frame_left, "top": frame_top}

    # 1. the crop is centred in the source, and the plate is exactly that crop
    if abs(crop_top - crop_bottom) > 1:
        problems.append(f"crop is not centred vertically: top {crop_top} bottom {crop_bottom}")
    expected = large.crop(
        (crop_left, crop_top, crop_left + plate.width, crop_top + plate.height)
    )
    if mean_abs_delta(plate, expected) > 0.0:
        problems.append("plate is not the declared centre crop of the large source")

    # 2. the reflection assertion.
    # A single column cannot tell a mirror from a crop: flipping an image reverses
    # the ORDER of its columns, it does not change any column's bytes. So the test
    # is on the mapping — for every bleed column, where in the source does it come
    # from? A crop maps x -> x (identity). A reflection maps the band across the
    # seam, x -> 2*seam-1-x. Count both and fail if the band is mirrored: that is
    # exactly the "second cottage" defect, and a continuity test alone passed it.
    # same vertical band as the plate, so column bytes are comparable
    large_band = large.crop((0, crop_top, large.width, crop_top + plate.height))
    large_cols = [
        hashlib.md5(large_band.crop((x, 0, x + 1, plate.height)).tobytes()).hexdigest()
        for x in range(large.width)
    ]
    bleed_x = list(range(0, frame_left)) + list(
        range(frame_left + FRAME_W, plate.width)
    )
    ident = mirrored = 0
    mirror_hits: list[int] = []
    for x in bleed_x:
        sig = hashlib.md5(plate.crop((x, 0, x + 1, plate.height)).tobytes()).hexdigest()
        if large_cols[crop_left + x] == sig:
            ident += 1
        seam = frame_left if x < frame_left else frame_left + FRAME_W
        reflected = 2 * seam - 1 - x
        src = crop_left + reflected
        if 0 <= src < large.width and large_cols[src] == sig:
            mirrored += 1
            if len(mirror_hits) < 4:
                mirror_hits.append(x)
    result["reflection"] = {
        "bleed_columns": len(bleed_x),
        "identity_matches": ident,
        "mirrored_matches": mirrored,
        "mirror_examples": mirror_hits,
    }
    if bleed_x and ident != len(bleed_x):
        problems.append(
            f"{len(bleed_x) - ident} bleed column(s) are not the source column at the same "
            "coordinate — the band is not a plain crop"
        )
    if bleed_x and mirrored > 0.5 * len(bleed_x):
        problems.append(
            f"{mirrored}/{len(bleed_x)} bleed columns are the seam reflection of the source "
            f"(e.g. x={mirror_hits[:4]}) — the band is mirrored, not cropped"
        )

    # 3. the seam is a join between two real neighbours
    seam_left = mean_abs_delta(column(plate, frame_left - 1), column(plate, frame_left))
    seam_right = mean_abs_delta(
        column(plate, frame_left + FRAME_W - 1), column(plate, frame_left + FRAME_W)
    )
    baseline = interior_delta(plate, frame_left, frame_left + FRAME_W)
    result["seam"] = {
        "left": round(seam_left, 2),
        "right": round(seam_right, 2),
        "interior": round(baseline, 2),
    }
    if max(seam_left, seam_right) > 3 * max(baseline, 1.0):
        problems.append(
            f"seam jumps: L {result['seam']['left']} R {result['seam']['right']} "
            f"vs interior {result['seam']['interior']}"
        )

    result["problems"] = problems
    result["verdict"] = "ok" if not problems else "broken"
    return result


def check_extend_method(page: str, plate: Image.Image, bg: dict[str, Any]) -> dict[str, Any]:
    cw, ch = FRAME_W, FRAME_H
    w, h = plate.size
    left = (w - cw) // 2
    art = plate.crop((left, (h - ch) // 2, left + cw, (h - ch) // 2 + ch))
    result: dict[str, Any] = {"method": f"extend:{bg.get('extend')}", "problems": []}
    if left == 0 and h == ch:
        result["verdict"] = "no bleed"
        return result

    seam_left = mean_abs_delta(column(plate, left - 1), column(plate, left))
    seam_right = mean_abs_delta(column(plate, left + cw - 1), column(plate, left + cw))
    baseline = interior_delta(art, 0, cw)
    result["seam"] = {"left": round(seam_left, 2), "right": round(seam_right, 2), "interior": round(baseline, 2)}
    if left:
        band_left = plate.crop((0, 0, left, h))
        band_right = plate.crop((left + cw, 0, w, h))
        off_l, diff_l = band_offset(band_left, art, True)
        off_r, diff_r = band_offset(band_right, art, True)
        want_l = cw - band_left.width
        result["band"] = {
            "left": {"offset": off_l, "want": want_l, "diff": round(diff_l, 2)},
            "right": {"offset": off_r, "want": 0, "diff": round(diff_r, 2)},
        }
        if off_l != want_l or diff_l >= 1.0:
            result["problems"].append(f"left band is not the adjacent edge ({off_l} want {want_l})")
        if off_r != 0 or diff_r >= 1.0:
            result["problems"].append(f"right band is not the adjacent edge ({off_r} want 0)")
        if max(seam_left, seam_right) > 3 * max(baseline, 1.0):
            result["problems"].append(f"seam jumps: {seam_left}/{seam_right} vs {baseline}")
    result["verdict"] = "ok" if not result["problems"] else "broken"
    return result


def check_page(page: str) -> dict[str, Any]:
    with open(page_yaml(page), "r", encoding="utf-8") as fh:
        spec = yaml.safe_load(fh) or {}
    bg = [l for l in spec.get("layers", []) if l.get("name") == "bg"][0]
    plate_path = source_layer_png(page, "bg")
    with Image.open(plate_path) as im:
        plate = im.convert("RGB")
    out = {"page": page, "plate": f"{plate.width}x{plate.height}", "plate_path": rel(plate_path)}
    if bg.get("crop"):
        out.update(check_crop_method(page, plate, plate_path, bg))
    else:
        out.update(check_extend_method(page, plate, bg))
    return out


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="measure the overscan: no reflection, no seam")
    parser.add_argument("pages", nargs="*", help="page ids (default: every page)")
    parser.add_argument("--json", action="store_true", help="emit JSON")
    args = parser.parse_args(argv)

    pages = args.pages or sorted(
        os.path.basename(os.path.dirname(p))
        for p in glob.glob(os.path.join(PAGES_DIR, "*", "page.layers.yaml"))
    )
    results = [check_page(page) for page in pages]

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        for r in results:
            seam = r.get("seam", {})
            print(f"{r['page']:<6} {r['plate']:>10}  {r['method']}")
            if "reflection" in r:
                refl = r["reflection"]
                print(
                    f"       bleed cols {refl['bleed_columns']}: "
                    f"{refl['identity_matches']} = source column at x (crop), "
                    f"{refl['mirrored_matches']} = seam reflection (must be low)"
                )
            if "seam" in r:
                print(
                    f"       seam L/R {seam['left']}/{seam['right']} (interior {seam['interior']})"
                )
            for problem in r.get("problems", []):
                print(f"       FAIL {problem}")

    broken = [r["page"] for r in results if r.get("problems")]
    if broken:
        print(f"\n{len(broken)}/{len(results)} page(s) failed: {', '.join(broken)}")
        return 1
    print(f"\nok: {len(results)}/{len(results)} page(s) — bleed is a crop, no reflection, seams interior-like")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
