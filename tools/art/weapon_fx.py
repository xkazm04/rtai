"""Procedural weapon FX art in the D5 ink print (weapon-art lane, 2026-11-04).

Muzzle flashes, tracer, casing, smoke and flame puffs, electro arcs and the rocket, drawn as
flat fills inside a bold ink outline with a seeded print grain, in the palette tokens only
(paper, ink, wash, steel; vermilion only for fire and the hazard band, fx layer = danger cue).
Deterministic: the same seed writes byte-identical PNGs.

Units are rig part px (320 part px = 1 m, the cutout rig's scale), authored at SS x and
downsampled so the ink edge stays clean. Run from the repo root:
    python tools/art/weapon_fx.py project/features/combat/weapons/art/fx
"""

import json
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

INK = (27, 21, 23)
PAPER = (242, 232, 213)
PAPER_2 = (233, 220, 195)
WASH = (108, 97, 97)
STEEL = (143, 136, 129)
INK_2 = (81, 71, 72)
VERMILION = (232, 80, 42)
SS = 4
OUTLINE = 7  # part px of ink around every shape


def _canvas(w, h):
    return Image.new("L", (w * SS, h * SS), 0)


def _compose(layers, w, h, seed, grain=0.10, outline=OUTLINE):
    """layers: [(mask L image at SS, rgb)], first is the silhouette base. Ink ring around the union."""
    union = Image.new("L", layers[0][0].size, 0)
    for m, _ in layers:
        union = Image.composite(Image.new("L", union.size, 255), union, m)
    ring = union.filter(ImageFilter.MaxFilter(_odd(outline * SS)))
    img = Image.new("RGBA", union.size, INK + (0,))
    img.paste(INK + (255,), (0, 0), ring)
    for m, rgb in layers:
        img.paste(rgb + (255,), (0, 0), m)
    img = img.resize((w, h), Image.LANCZOS)
    return _grain(img, seed, grain)


def _odd(n):
    n = int(n)
    return n + 1 if n % 2 == 0 else n


def _grain(img, seed, amount):
    rng = random.Random(seed)
    px = img.load()
    w, h = img.size
    for _ in range(int(w * h * amount)):
        x, y = rng.randrange(w), rng.randrange(h)
        r, g, b, a = px[x, y]
        if a > 200 and (r, g, b) != INK:
            k = 0.86 if rng.random() < 0.7 else 1.06
            px[x, y] = (min(255, int(r * k)), min(255, int(g * k)), min(255, int(b * k)), a)
    return img


def _poly(mask, pts):
    ImageDraw.Draw(mask).polygon([(x * SS, y * SS) for x, y in pts], fill=255)
    return mask


def _star(cx, cy, length, width, spikes, rng, back=0.25):
    """A forward flash: a long spike along +x, side spikes fanning back."""
    pts = []
    n = spikes * 2
    for i in range(n):
        a = -math.pi * 0.62 + (math.pi * 1.24) * i / (n - 1)
        outer = i % 2 == 0
        r = (length if abs(a) < 0.2 else length * rng.uniform(0.38, 0.62)) if outer else width * 0.32
        if outer and abs(a) > 1.2:
            r = width * rng.uniform(0.55, 0.8)
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r * (width / length * 1.6)))
    pts.append((cx - length * back, cy + width * 0.18))
    pts.append((cx - length * back, cy - width * 0.18))
    return pts


def muzzle_flash(name, length, width, frame, out, seed):
    rng = random.Random(seed * 31 + frame)
    k = (1.0, 0.8, 0.58)[frame]
    body = _star(0.0, 0.0, length * k, width * k, 7, rng)
    core = _star(0.0, 0.0, length * k * 0.48, width * 0.42 * k, 5, rng)
    m = OUTLINE + 4
    x0, y0 = min(x for x, _ in body) - m, min(y for _, y in body) - m
    w = int(max(x for x, _ in body) - x0 + m)
    h = int(max(y for _, y in body) - y0 + m)
    layers = [(_poly(_canvas(w, h), [(x - x0, y - y0) for x, y in body]), PAPER)]
    if frame < 2:
        layers.append((_poly(_canvas(w, h), [(x - x0, y - y0) for x, y in core]), VERMILION))
    _save(_compose(layers, w, h, seed + frame), out / f"{name}_{frame}.png")
    return [w, h], [int(-x0 - length * k * 0.25), int(-y0)]


def tracer(out, seed):
    w, h = 260, 34
    m = _poly(_canvas(w, h), [(10, h / 2), (w - 26, h / 2 - 7), (w - 10, h / 2), (w - 26, h / 2 + 7)])
    hot = _poly(_canvas(w, h), [(w - 120, h / 2), (w - 28, h / 2 - 3), (w - 18, h / 2), (w - 28, h / 2 + 3)])
    _save(_compose([(m, PAPER_2), (hot, PAPER)], w, h, seed, outline=5), out / "tracer.png")
    return [w, h], [w - 10, h // 2]


def casing(out, seed):
    w, h = 48, 30
    m = _canvas(w, h)
    ImageDraw.Draw(m).rounded_rectangle([8 * SS, 8 * SS, 40 * SS, 22 * SS], radius=5 * SS, fill=255)
    rim = _poly(_canvas(w, h), [(8, 7), (14, 7), (14, 23), (8, 23)])
    _save(_compose([(m, STEEL), (rim, PAPER)], w, h, seed, outline=5), out / "casing.png")
    return [w, h], [w // 2, h // 2]


def _blob(w, h, rng, lobes, r0, cx=None, cy=None):
    m = _canvas(w, h)
    d = ImageDraw.Draw(m)
    cx = w / 2 if cx is None else cx
    cy = h / 2 if cy is None else cy
    for i in range(lobes):
        a = 2 * math.pi * i / lobes + rng.uniform(-0.3, 0.3)
        rr = r0 * rng.uniform(0.5, 0.75)
        x, y = cx + math.cos(a) * r0 * 0.45, cy + math.sin(a) * r0 * 0.45
        d.ellipse([(x - rr) * SS, (y - rr) * SS, (x + rr) * SS, (y + rr) * SS], fill=255)
    d.ellipse([(cx - r0 * 0.6) * SS, (cy - r0 * 0.6) * SS, (cx + r0 * 0.6) * SS, (cy + r0 * 0.6) * SS], fill=255)
    return m


def puff(name, size, frame, fill, core, out, seed):
    w = h = size
    rng = random.Random(seed * 17 + frame)
    r0 = size * (0.30 + 0.06 * frame)
    body = _blob(w, h, rng, 6, r0)
    layers = [(body, fill)]
    if core is not None:
        layers.append((_blob(w, h, rng, 4, r0 * 0.5, w * 0.46, h * 0.46), core))
    _save(_compose(layers, w, h, seed + frame), out / f"{name}_{frame}.png")
    return [w, h], [w // 2, h // 2]


def arc(frame, out, seed):
    w, h = 320, 90
    rng = random.Random(seed * 13 + frame)
    m = _canvas(w, h)
    d = ImageDraw.Draw(m)
    pts = [(12, h / 2)]
    for i in range(1, 9):
        pts.append((12 + (w - 24) * i / 8, h / 2 + rng.uniform(-28, 28) * (1 if i < 8 else 0)))
    d.line([(x * SS, y * SS) for x, y in pts], fill=255, width=9 * SS, joint="curve")
    for x, y in pts[2:7:2]:
        bx, by = x + rng.uniform(16, 40), y + rng.choice((-1, 1)) * rng.uniform(16, 30)
        d.line([(x * SS, y * SS), (bx * SS, by * SS)], fill=255, width=5 * SS)
    _save(_compose([(m, PAPER)], w, h, seed + frame, outline=6), out / f"arc_{frame}.png")
    return [w, h], [12, h // 2]


def rocket(out, seed):
    w, h = 200, 70
    cy = h / 2
    body = _poly(_canvas(w, h), [(30, cy - 12), (150, cy - 12), (178, cy), (150, cy + 12), (30, cy + 12)])
    fins = _poly(_canvas(w, h), [(14, cy - 28), (46, cy - 10), (46, cy + 10), (14, cy + 28), (26, cy)])
    band = _poly(_canvas(w, h), [(132, cy - 12), (146, cy - 12), (146, cy + 12), (132, cy + 12)])
    nose = _poly(_canvas(w, h), [(150, cy - 12), (178, cy), (150, cy + 12)])
    layers = [(body, STEEL), (fins, INK_2), (nose, WASH), (band, VERMILION)]
    _save(_compose(layers, w, h, seed), out / "rocket.png")
    return [w, h], [178, int(cy)]


def _save(img, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, optimize=False)


def main(dst):
    out = Path(dst)
    rows = []
    for name, length, width in (("flash_pistol", 110, 70), ("flash_smg", 90, 46), ("flash_tube", 170, 120)):
        for f in range(3):
            size, anchor = muzzle_flash(name, length, width, f, out, 7)
            rows.append({"id": f"{name}_{f}", "size_px": size, "anchor_px": anchor})
    for fn in (tracer, casing, rocket):
        size, anchor = fn(out, 11)
        rows.append({"id": fn.__name__, "size_px": size, "anchor_px": anchor})
    for f in range(3):
        size, anchor = puff("smoke", 120, f, WASH, None, out, 23)
        rows.append({"id": f"smoke_{f}", "size_px": size, "anchor_px": anchor})
        size, anchor = puff("flame", 130, f, VERMILION, PAPER, out, 29)
        rows.append({"id": f"flame_{f}", "size_px": size, "anchor_px": anchor})
        size, anchor = arc(f, out, 37)
        rows.append({"id": f"arc_{f}", "size_px": size, "anchor_px": anchor})
    (out / "fx_rows.json").write_text(json.dumps(rows, indent=1, sort_keys=True))
    print(f"wrote {len(rows)} fx cells to {out}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
