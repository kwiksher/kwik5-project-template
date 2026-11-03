#!/usr/bin/env python3
"""Catalogue everything under Solar2D/App/<book>/assets into one browsable HTML page.

    python3 Scripts/design_assets_html.py [--book <book>_design] [--out PATH]

Writes `<book>/DESIGN-BOOK-ASSET.html` next to `assets/`, so every <img>/<video>/<audio>
src is a plain relative path and the page works from the file system with no server.

Media is NOT embedded: the asset tree is tens of megabytes, and a base64 copy would be
both slow and stale the moment the build re-runs. The page records size and dimensions,
which is what a reviewer needs in order to notice a wrong-sized sheet or a 1-colour PNG.
"""
import argparse
import os
import re
import subprocess
import sys
from html import escape

from book_config import DESIGN_BOOK

from PIL import Image

VIDEO_EXT = {".mp4", ".mov", ".m4v"}
AUDIO_EXT = {".mp3", ".wav", ".ogg", ".m4a"}
IMAGE_EXT = {".png", ".jpg", ".jpeg", ".gif", ".webp"}
SIDECAR_EXT = {".lua", ".json", ".yaml", ".yml", ".md5", ".txt", ".plist", ".csv"}


def human(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024


def duration(path):
    try:
        out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                              "-of", "csv=p=0", path], capture_output=True, text=True).stdout.strip()
        return float(out) if out else None
    except Exception:
        return None


def dimensions(path):
    try:
        with Image.open(path) as im:
            return im.size, im.mode
    except Exception:
        return None, None


def colour_count(path):
    try:
        with Image.open(path) as im:
            im = im.convert("RGB")
            if im.width * im.height > 4_000_000:
                return None
            return len(im.getcolors(maxcolors=1 << 24) or [])
    except Exception:
        return None


def collect(root):
    items = []
    for dirpath, _dirnames, filenames in os.walk(root):
        for name in sorted(filenames):
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, os.path.dirname(root))
            ext = os.path.splitext(name)[1].lower()
            if name.startswith(".") or name == ".DS_Store":
                continue
            st = os.stat(full)
            it = {"path": rel, "name": name, "size": st.st_size, "mtime": st.st_mtime,
                  "ext": ext, "dir": os.path.relpath(dirpath, os.path.dirname(root))}
            if ext in IMAGE_EXT:
                (it["dims"], mode) = dimensions(full)
                it["mode"] = mode
                it["colours"] = colour_count(full)
                it["kind"] = "image"
            elif ext in VIDEO_EXT:
                it["duration"] = duration(full)
                it["kind"] = "video"
            elif ext in AUDIO_EXT:
                it["duration"] = duration(full)
                it["kind"] = "audio"
            elif ext in SIDECAR_EXT:
                it["kind"] = "sidecar"
            else:
                it["kind"] = "other"
            items.append(it)
    return items


def img_card(it, thumb_class=""):
    dims = f"{it['dims'][0]}×{it['dims'][1]}" if it.get("dims") else "?"
    meta = [dims, human(it["size"])]
    if it.get("colours") is not None:
        meta.append(f"{it['colours']} colour" + ("" if it["colours"] == 1 else "s"))
    single = it.get("colours") == 1
    return f"""
    <figure class="card{' flat' if single else ''}">
      <a href="{escape(it['path'])}" target="_blank"><img loading="lazy" src="{escape(it['path'])}" alt="{escape(it['name'])}"></a>
      <figcaption>
        <code>{escape(os.path.basename(it['path']))}</code>
        <span class="meta">{' · '.join(meta)}</span>
        <span class="path">{escape(it['dir'])}/</span>
      </figcaption>
    </figure>"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--book", default=DESIGN_BOOK)
    ap.add_argument("--root", default=None, help="assets dir (default Solar2D/App/<book>/assets)")
    ap.add_argument("--out", default=None)
    a = ap.parse_args()

    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    assets = a.root or os.path.join(repo, "Solar2D", "App", a.book, "assets")
    if not os.path.isdir(assets):
        sys.exit(f"no assets at {assets}")
    out = a.out or os.path.join(os.path.dirname(assets), "DESIGN-BOOK-ASSET.html")

    items = collect(assets)
    by_kind = {k: [i for i in items if i["kind"] == k] for k in ("image", "video", "audio", "sidecar", "other")}
    total = sum(i["size"] for i in items)

    # images grouped by their page folder, with `shared` first and empty page folders listed explicitly
    page_dirs = sorted(d for d in os.listdir(os.path.join(assets, "images"))
                       if os.path.isdir(os.path.join(assets, "images", d))) if os.path.isdir(os.path.join(assets, "images")) else []
    images_by_dir = {}
    for it in by_kind["image"]:
        images_by_dir.setdefault(os.path.dirname(it["path"]), []).append(it)
    empty_pages = [p for p in page_dirs if not images_by_dir.get(f"assets/images/{p}")]

    sprites = [i for i in by_kind["image"] if "/sprites/" in i["path"]]
    sprite_side = [i for i in by_kind["sidecar"] if "/sprites/" in i["path"]]
    thumbs = [i for i in by_kind["image"] if "/thumbnails/" in i["path"]]
    seq = [i for i in by_kind["image"] if "/design_seq/" in i["path"]]
    shared = [i for i in by_kind["image"] if "/images/shared/" in i["path"]]
    excluded_dirs = {"assets/images/shared", "assets/sprites", "assets/thumbnails",
                     "assets/videos/design_seq"}
    page_imgs = {k: v for k, v in images_by_dir.items() if k not in excluded_dirs}

    nav = """
    <nav>
      <a href="#summary">Summary</a><a href="#sprites">Spritesheets</a><a href="#video">Video</a>
      <a href="#audio">Audio</a><a href="#thumbs">Thumbnails</a><a href="#shared">Shared</a>
      <a href="#pages">Page images</a><a href="#sidecars">Sidecars</a>
    </nav>"""

    def section(id_, title, count, body, note=""):
        return (f'<section id="{id_}"><h2>{title}<span class="count">{count}</span></h2>'
                + (f'<p class="note">{note}</p>' if note else "") + body + "</section>")

    summary_rows = "".join(
        f"<tr><td>{label}</td><td class='n'>{len(by_kind[k])}</td>"
        f"<td class='n'>{human(sum(i['size'] for i in by_kind[k]))}</td></tr>"
        for label, k in (("images", "image"), ("videos", "video"), ("audio", "audio"),
                         ("sidecars (lua/json/yaml/md5)", "sidecar"), ("other", "other")))

    sprite_body = '<div class="grid wide">' + "".join(img_card(i) for i in sprites) + "</div>"
    if sprite_side:
        sprite_body += ('<h3>Sidecars</h3><table class="files"><tr><th>file</th><th>size</th></tr>'
                        + "".join(f"<tr><td><code>{escape(i['name'])}</code></td><td class='n'>{human(i['size'])}</td></tr>"
                                  for i in sprite_side) + "</table>")

    video_body = ""
    for v in by_kind["video"]:
        dur = f"{v['duration']:.3f} s" if v.get("duration") else "?"
        video_body += (f'<figure class="card wide"><video controls preload="metadata" src="{escape(v["path"])}"></video>'
                       f'<figcaption><code>{escape(v["name"])}</code><span class="meta">{dur} · {human(v["size"])}</span>'
                       f'<span class="path">{escape(v["dir"])}/</span></figcaption></figure>')
    if seq:
        video_body += f'<h3>design_seq — {len(seq)} PNG frames</h3><div class="grid small">' + "".join(img_card(i) for i in seq) + "</div>"

    audio_body = '<table class="files"><tr><th>file</th><th>duration</th><th>size</th><th>play</th></tr>'
    for s in by_kind["audio"]:
        dur = f"{s['duration']:.3f} s" if s.get("duration") else "?"
        audio_body += (f'<tr><td><code>{escape(s["path"].replace("assets/",""))}</code></td><td class="n">{dur}</td>'
                       f'<td class="n">{human(s["size"])}</td><td><audio controls preload="none" src="{escape(s["path"])}"></audio></td></tr>')
    audio_body += "</table>"

    thumbs_body = '<div class="grid small">' + "".join(img_card(i) for i in thumbs) + "</div>"
    shared_body = '<div class="grid">' + "".join(img_card(i) for i in shared) + "</div>"

    pages_body = ""
    for d in sorted(page_imgs):
        page = d.rsplit("/", 1)[-1]
        pages_body += f'<h3 id="page-{escape(page)}">{escape(page)}<span class="count">{len(page_imgs[d])}</span></h3>'
        pages_body += '<div class="grid">' + "".join(img_card(i) for i in page_imgs[d]) + "</div>"
    if empty_pages:
        pages_body += ('<p class="note warn">Page folders with no images at all: '
                       + ", ".join(f"<code>{escape(p)}</code>" for p in empty_pages)
                       + " — these pages draw no image layers (or their assets live under <code>sprites/</code> or <code>videos/</code>).</p>")

    side_body = '<table class="files"><tr><th>file</th><th>size</th></tr>'
    for s in by_kind["sidecar"] + by_kind["other"]:
        side_body += f"<tr><td><code>{escape(s['path'].replace('assets/',''))}</code></td><td class='n'>{human(s['size'])}</td></tr>"
    side_body += "</table>"

    html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>{escape(a.book)} — assets</title>
<style>
  :root {{ --ink:#1d2024; --dim:#6b7280; --line:#e3e6ea; --bg:#fbfbfa; --card:#fff; }}
  * {{ box-sizing:border-box; }}
  body {{ margin:0; background:var(--bg); color:var(--ink); font:15px/1.55 -apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif; }}
  .wrap {{ max-width:1240px; margin:0 auto; padding:48px 28px 96px; }}
  header {{ border-bottom:2px solid var(--ink); padding-bottom:22px; }}
  .kicker {{ font-size:12px; letter-spacing:.16em; text-transform:uppercase; color:var(--dim); font-weight:600; }}
  h1 {{ font-size:38px; letter-spacing:-.02em; margin:10px 0 6px; }}
  .sub {{ color:#3f4650; max-width:80ch; }}
  nav {{ display:flex; flex-wrap:wrap; gap:6px 14px; margin:18px 0 8px; font-size:13px; }}
  nav a {{ color:#2a6f8f; text-decoration:none; border-bottom:1px solid transparent; }}
  nav a:hover {{ border-color:#2a6f8f; }}
  h2 {{ font-size:13px; letter-spacing:.14em; text-transform:uppercase; color:var(--dim);
        margin:52px 0 8px; padding-bottom:8px; border-bottom:1px solid var(--line);
        display:flex; justify-content:space-between; align-items:baseline; }}
  h2 .count, h3 .count {{ font-size:12px; color:var(--dim); letter-spacing:0; }}
  h3 {{ font-size:15px; margin:26px 0 10px; display:flex; gap:8px; align-items:baseline; }}
  h3 .count {{ font-weight:400; }}
  .grid {{ display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:14px; }}
  .grid.small {{ grid-template-columns:repeat(auto-fill,minmax(148px,1fr)); }}
  .grid.wide {{ grid-template-columns:repeat(auto-fill,minmax(320px,1fr)); }}
  .card {{ margin:0; background:var(--card); border:1px solid var(--line); border-radius:10px; overflow:hidden; }}
  .card img {{ display:block; width:100%; height:150px; object-fit:contain; background:
      repeating-conic-gradient(#f2f3f5 0% 25%, #fff 0% 50%) 50% / 14px 14px; }}
  .grid.small .card img {{ height:132px; }}
  .grid.wide .card img {{ height:280px; }}
  .card.wide {{ max-width:720px; }}
  .card.wide video {{ display:block; width:100%; background:#000; }}
  .card.flat img {{ background:#000; }}
  .card.flat {{ border-color:#c43a3a; }}
  figcaption {{ padding:8px 10px 10px; font-size:12px; display:flex; flex-direction:column; gap:2px; }}
  figcaption code {{ font:12px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace; overflow-wrap:anywhere; }}
  .meta {{ color:var(--dim); }}
  .path {{ color:#9aa2ab; font-size:11px; overflow-wrap:anywhere; }}
  table.files {{ width:100%; border-collapse:collapse; font-size:13px; }}
  table.files th {{ text-align:left; font-size:11px; letter-spacing:.08em; text-transform:uppercase;
      color:var(--dim); border-bottom:2px solid var(--line); padding:6px 8px; }}
  table.files td {{ padding:5px 8px; border-bottom:1px solid var(--line); }}
  table.files td.n, td.n {{ text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }}
  table.files audio {{ height:28px; }}
  .note {{ color:var(--dim); font-size:13px; max-width:100ch; }}
  .note.warn {{ border-left:3px solid #c43a3a; padding-left:12px; }}
  .summary {{ display:grid; grid-template-columns:1fr auto auto; max-width:520px; font-size:13.5px; }}
  .summary div {{ padding:5px 8px; border-bottom:1px solid var(--line); }}
  .summary div:nth-child(3n+2), .summary div:nth-child(3n) {{ text-align:right; font-variant-numeric:tabular-nums; }}
</style></head>
<body><div class="wrap">
<header>
  <div class="kicker">Design book · asset catalogue</div>
  <h1>{escape(a.book)} — assets</h1>
  <p class="sub">Everything under <code>Solar2D/App/{escape(a.book)}/assets</code>, by kind and by page.
  Paths are relative, so this page works straight from the file system. Nothing is embedded: a
  32 MB base64 copy would be slow and would go stale on the next build.</p>
</header>
{nav}

<section id="summary"><h2>Summary<span class="count">{len(items)} files · {human(total)}</span></h2>
<div class="summary">
  <div>images</div><div>{len(by_kind['image'])}</div><div>{human(sum(i['size'] for i in by_kind['image']))}</div>
  <div>videos</div><div>{len(by_kind['video'])}</div><div>{human(sum(i['size'] for i in by_kind['video']))}</div>
  <div>audio</div><div>{len(by_kind['audio'])}</div><div>{human(sum(i['size'] for i in by_kind['audio']))}</div>
  <div>sidecars</div><div>{len(by_kind['sidecar'])}</div><div>{human(sum(i['size'] for i in by_kind['sidecar']))}</div>
  <div>other</div><div>{len(by_kind['other'])}</div><div>{human(sum(i['size'] for i in by_kind['other']))}</div>
</div>
<p class="note">A red border means the PNG has a <strong>single colour</strong> — almost always a failed render
rather than art. Sprite sheets, page images and thumbnails are separated below so a wrong one is easy to spot.</p>
</section>

{section('sprites', 'Spritesheets', f"{len(sprites)} sheets", sprite_body,
         "Loaded by the <code>sprite</code>, <code>sprite_texturepacker</code> and <code>sprite_animate</code> pages, each with its own metadata file (uniform grid / TexturePacker JSON / Animate JSON).")}

{section('video', 'Video', f"{len(by_kind['video'])} files · {len(seq)} frames", video_body,
         "The <code>video</code> page plays the mp4 through the native player; the <code>video_png</code> page walks the PNG sequence with a scripted frame player.")}

{section('audio', 'Audio', f"{len(by_kind['audio'])} files", audio_body,
         "Short one-shot, long ambience and the per-word sync clips. Durations are from ffprobe, not from the manifest.")}

{section('thumbs', 'Thumbnails', f"{len(thumbs)} files", thumbs_body,
         "What the navigation pages are supposed to show, one per page.")}

{section('shared', 'Shared images', f"{len(shared)} files", shared_body,
         "Reused by every page: the specimen card and its background, one digest for the whole book.")}

{section('pages', 'Page images', f"{sum(len(v) for v in page_imgs.values())} files across {len(page_imgs)} pages", pages_body)}

{section('sidecars', 'Sidecars and other files', f"{len(by_kind['sidecar']) + len(by_kind['other'])} files", side_body,
         "Metadata the layers and the build read: sprite frame tables, the asset registry, checksums.")}

<p class="note" style="margin-top:40px">Generated by <code>Scripts/design_assets_html.py</code> —
re-run it after a build to refresh sizes, dimensions and durations.</p>
</div></body></html>"""

    with open(out, "w", encoding="utf-8") as fh:
        fh.write(html)
    print(f"wrote {out} ({len(html)/1024:.0f} KB, {len(items)} files, {human(total)})")


if __name__ == "__main__":
    main()
