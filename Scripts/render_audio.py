#!/usr/bin/env python3
"""Generate each page's declared narration through Guaardvark's Audio Foundry.

``Photoshop/<book>/<page>/page.audios.yaml`` declares what a page needs. This script turns
the ``narration_*.wav`` entries into real files at
``Solar2D/App/<book>/assets/audios/<name>`` (the exact names the YAML declares)
and reports the rest.

Backend: Guaardvark Audio Foundry, Kokoro TTS (``/generate/voice``) — local,
no cloud, no billing. SFX and music beds need Stable Audio Open, which is
CUDA-only on this machine (Apple Silicon MPS is experimental and disabled), so
those entries are left as declared-but-not-generated; nothing is fabricated.

Usage
-----
    python3 Scripts/render_audio.py --generate
    python3 Scripts/render_audio.py --check
"""

from __future__ import annotations

import argparse
import glob
import os
import shutil
import sys
from typing import Any

import yaml

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from paths import AUDIOS_DIR
sys.path.insert(0, os.path.join(REPO_ROOT, "Scripts"))
from paths import PAGES_DIR  # noqa: E402  — single source of truth for the page tree
AUDIO_DEST = AUDIOS_DIR
FOUNDRY = os.environ.get("AUDIO_FOUNDRY", "http://127.0.0.1:8206")
VOICE = "af_heart"


def die(msg: str, code: int = 2):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(code)


def http_post(url: str, payload: dict, timeout: float = 180.0) -> dict:
    import json
    import urllib.error
    import urllib.request

    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        die(f"{url}: HTTP {exc.code}: {body[:400]}", 3)


def declared() -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for path in sorted(glob.glob(os.path.join(PAGES_DIR, "*", "page.audios.yaml"))):
        page = os.path.basename(os.path.dirname(path))
        with open(path, encoding="utf-8") as fh:
            entries = yaml.safe_load(fh) or []
        for entry in entries:
            items.append({"page": page, **entry})
    return items


def dest_for(name: str) -> str:
    return os.path.join(AUDIO_DEST, name)


def generate(items: list[dict[str, Any]], force: bool) -> int:
    made = 0
    for item in items:
        name = str(item["name"])
        text = str(item.get("description", "")).strip()
        if not name.startswith("narration_") or not text:
            continue
        if os.path.exists(dest_for(name)) and not force:
            print(f"  {item['page']}/{name}: exists")
            continue
        result = http_post(
            FOUNDRY + "/generate/voice",
            {"text": text, "voice": VOICE, "backend": "kokoro"},
        )
        src = result.get("path")
        if not src or not os.path.exists(src):
            die(f"{item['page']}/{name}: Audio Foundry returned no file: {result}")
        os.makedirs(AUDIO_DEST, exist_ok=True)
        shutil.copy2(src, dest_for(name))
        print(
            f"  {item['page']}/{name}: {result.get('duration_s')}s "
            f"({result.get('meta', {}).get('backend')}/{result.get('meta', {}).get('voice')})"
        )
        made += 1
    return made


def check(items: list[dict[str, Any]]) -> int:
    missing = 0
    for item in items:
        name = str(item["name"])
        exists = os.path.exists(dest_for(name))
        kind = name.split("_", 1)[0]
        if kind == "narration":
            state = "generated" if exists else "MISSING"
            if not exists:
                missing += 1
        else:
            state = "declared, not generated (SFX/music backend unavailable on MPS)"
        print(f"  {item['page']:>5}/{name:<46} {state}")
    if missing:
        print(f"check FAILED: {missing} narration file(s) missing", file=sys.stderr)
        return 1
    print("ok: every declared narration file exists")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--generate", action="store_true", help="render missing narration")
    parser.add_argument("--check", action="store_true", help="verify declared narration exists")
    parser.add_argument("--force", action="store_true", help="re-render existing narration")
    args = parser.parse_args(argv)

    items = declared()
    if not items:
        die("no page.audios.yaml found — run Scripts/fountain2pages.py")

    if args.generate:
        made = generate(items, args.force)
        print(f"generated {made} narration file(s) into assets/audios/")
    if args.check or not args.generate:
        return check(items)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
