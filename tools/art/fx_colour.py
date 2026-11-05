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

from fx_flash import flash
from fx_rim import rim

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


def _polar(img, pix, sectors):
    """Every opaque pixel's (distance, angle sector) round the cell's centre, and the ring's
    inner radius per sector (the nearest opaque pixel)."""
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
    return polar, inner


def inner_band(path, colour, px, sectors=180):
    """r2_w4's fire inside the smoke: non-ink pixels within `px` of the ring's inner edge (per
    angle sector round the cell's centre, the nearest opaque pixel) take the flat `colour`."""
    img = Image.open(path).convert("RGBA")
    pix = img.load()
    polar, inner = _polar(img, pix, sectors)
    ink = TOKENS["ink"]
    for (x, y), (d, k) in polar.items():
        r, g, b, a = pix[x, y]
        if d - inner[k] < px and sum(abs(c - t) for c, t in zip((r, g, b), ink)) >= 60:
            pix[x, y] = tuple(colour) + (a,)
    img.save(path, optimize=True)


def pockets(path, colour, n, r_px, seed=1.0, core=None, core_k=0.45, core_in=0.0, wobble=0.0, hot=None):
    """r2_w4's fire pockets inside the smoke: `n` round orange pockets centred on the ring's
    inner edge at hashed angles (radius r_px[0]..r_px[1]), clipped to the non-ink ring pixels,
    each with a hot `core` disc (core_k x its radius, moved core_in x its radius toward the
    blast centre) when given. wobble > 0 makes each pocket's edge lumpy (a hashed 3- and
    5-lobe radial wobble of that share of its radius; 0 = round discs). hot = (colour, k): a
    hotter disc at k x the core's radius inside it (graded fire; None = off). Hash-placed from
    `seed`: deterministic."""
    img = Image.open(path).convert("RGBA")
    pix = img.load()
    cx, cy = img.width / 2, img.height / 2
    sectors = 180
    polar, inner = _polar(img, pix, sectors)
    rin = sorted(inner)[sectors // 2]

    def h(i, s):
        v = math.sin(i * 12.9898 + s * 78.233) * 43758.5453
        return v - math.floor(v)

    discs = []
    for i in range(n):
        a = (i + 0.5 + (h(i, seed) - 0.5) * 0.6) / n * 2 * math.pi
        r = r_px[0] + (r_px[1] - r_px[0]) * h(i, seed + 3.3)
        c = rin + r * 0.3
        cc = c - r * core_in  # the hot core sits toward the blast centre
        discs.append(
            (
                cx + math.cos(a) * c,
                cy + math.sin(a) * c,
                r,
                cx + math.cos(a) * cc,
                cy + math.sin(a) * cc,
                h(i, seed + 5.1) * 6.283,
                h(i, seed + 7.7) * 6.283,
            )
        )

    def edge(px, py, d):
        if wobble <= 0.0:
            return d[2]
        t = math.atan2(py - d[1], px - d[0])
        return d[2] * (1.0 + wobble * (0.6 * math.sin(3 * t + d[5]) + 0.4 * math.sin(5 * t + d[6])))

    ink = TOKENS["ink"]
    for (x, y), (d, k) in polar.items():
        r_, g, b, a = pix[x, y]
        if sum(abs(c - t) for c, t in zip((r_, g, b), ink)) < 60:
            continue
        hit = None
        for disc in discs:
            dx, dy, _, kx, ky = disc[:5]
            er = edge(x, y, disc)
            q = (x - dx) ** 2 + (y - dy) ** 2
            if q >= er * er:
                continue
            kr = edge(x, y, (kx, ky) + disc[2:]) * core_k
            kq = (x - kx) ** 2 + (y - ky) ** 2
            if core is not None and kq < kr * kr:
                hit = hot[0] if hot is not None and kq < (kr * hot[1]) ** 2 else core
                break
            hit = colour
        if hit is not None:
            pix[x, y] = tuple(hit) + (a,)
    img.save(path, optimize=True)


def _flash(path, spec):
    """fx_flash.flash over the frame (r2_w4's white-hot core + spikes); colours are hex in the table."""
    img = Image.open(path).convert("RGBA")
    _, inner = _polar(img, img.load(), 180)
    s = dict(spec, **{k: _hex(spec[k]) for k in ("spike", "burst", "hot", "mid") if k in spec})
    flash(img, sorted(inner)[90], s).save(path, optimize=True)


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
                if "pockets" in fam:
                    pk = fam["pockets"]
                    pockets(
                        out / src.name,
                        _hex(pk["colour"]),
                        pk["n"],
                        pk["r_px"],
                        seed=pk.get("seed", 1.0),
                        core=_hex(pk["core"]) if "core" in pk else None,
                        core_k=pk.get("core_k", 0.45),
                        core_in=pk.get("core_in", 0.0),
                        wobble=pk.get("wobble", 0.0),
                        hot=(_hex(pk["hot"]), pk["hot_k"]) if "hot" in pk else None,
                    )
                elif "inner" in fam:
                    inner_band(out / src.name, _hex(fam["inner"]["colour"]), fam["inner"]["px"])
                if "rim" in fam:
                    rk = fam["rim"]
                    paper = None if rk.get("flat") else mapping.get("paper", TOKENS["paper"])
                    rim(out / src.name, _hex(rk["colour"]), rk["px"], paper, core_min=rk.get("core_min", 150))
                if "flash" in fam:
                    _flash(out / src.name, fam["flash"])
                done += 1
    print(f"fx_colour: {done} PNGs -> {out}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
