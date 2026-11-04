"""Weapon FX in the round 2 colour sheet (look lane, n5 2026-11-04; target r2_w4_fx_colour.jpg).

Re-inks the weapon-art lane's FX PNGs (tools/art/weapon_fx*.py: flat palette fills, a bold ink
outline, a seeded grain) into the sheet's colours, token by token: every opaque pixel is matched
to its nearest palette token (ink, paper, wash, steel, ink_2, vermilion) and moved to that
family's colour for the token, keeping its grain offset. The ink outline stays ink, so the
effects still sit in the print. No deep blood red anywhere (red is blood only); teal stays for
souls, so the shard glint is cyan-white. The families and colours are data:
tools/art/fx_colour.json. Deterministic: the same inputs write byte-identical PNGs.

Run from the repo root:
    python tools/art/fx_colour.py project/features/combat/weapons/art/fx \
        project/features/combat/weapons/art/fx/colour
"""

import json
import math
import sys
from pathlib import Path

from PIL import Image

TOKENS = {
    "ink": (27, 21, 23),
    "paper": (242, 232, 213),
    "paper_2": (233, 220, 195),
    "wash": (108, 97, 97),
    "steel": (143, 136, 129),
    "ink_2": (81, 71, 72),
    "vermilion": (232, 80, 42),
}


def _hex(s):
    s = s.lstrip("#")
    return tuple(int(s[i : i + 2], 16) for i in (0, 2, 4))


def _nearest(rgb):
    best, dist = "ink", 1 << 30
    for name, t in TOKENS.items():
        d = sum((a - b) * (a - b) for a, b in zip(rgb, t))
        if d < dist:
            best, dist = name, d
    return best


def recolour(src, dst, mapping):
    img = Image.open(src).convert("RGBA")
    px = img.load()
    cache = {}
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            key = (r, g, b)
            if key not in cache:
                tok = _nearest(key)
                to = mapping.get(tok)
                if to is None:
                    cache[key] = key
                else:
                    base = TOKENS[tok]
                    cache[key] = tuple(
                        max(0, min(255, c + (k - t))) for c, k, t in zip(to, key, base)
                    )
            px[x, y] = cache[key] + (a,)
    img.save(dst, optimize=True)


def inner_band(path, colour, px, sectors=180):
    """r2_w4's fire inside the smoke: non-ink pixels within `px` of the ring's inner edge (per
    angle sector round the cell's centre, the nearest opaque pixel) take the flat `colour`."""
    img = Image.open(path).convert("RGBA")
    pix = img.load()
    cx, cy = img.width / 2, img.height / 2
    inner = [1e9] * sectors
    polar = {}
    for y in range(img.height):
        for x in range(img.width):
            if pix[x, y][3] >= 128:
                d = math.hypot(x - cx, y - cy)
                k = int((math.atan2(y - cy, x - cx) + math.pi) / (2 * math.pi) * sectors) % sectors
                polar[(x, y)] = (d, k)
                inner[k] = min(inner[k], d)
    ink = TOKENS["ink"]
    for (x, y), (d, k) in polar.items():
        r, g, b, a = pix[x, y]
        if d - inner[k] < px and sum(abs(c - t) for c, t in zip((r, g, b), ink)) >= 60:
            pix[x, y] = tuple(colour) + (a,)
    img.save(path, optimize=True)


def main(src_dir, out_dir):
    table = json.loads((Path(__file__).parent / "fx_colour.json").read_text("utf8"))
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    done = 0
    for fam in table["families"]:
        mapping = {k: _hex(v) for k, v in fam["tokens"].items()}
        for prefix in fam["files"]:
            for src in sorted(Path(src_dir).glob(prefix + "*.png")):
                recolour(src, out / src.name, mapping)
                if "inner" in fam:
                    inner_band(out / src.name, _hex(fam["inner"]["colour"]), fam["inner"]["px"])
                done += 1
    print(f"fx_colour: {done} PNGs -> {out}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
