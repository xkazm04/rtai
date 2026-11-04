"""Impact FX in the D5 ink print (weapon-art lane, iteration 2, 2026-11-04).

The cells gunplay REQUEST 3 and showcase REQUEST 5 asked for: the rocket blast (4 frames: a paper
flash, a vermilion fireball, a wash smoke ring, a thin dying ring), the scorch decal left on the
ground (ink, about 2.5 m at fx_draw_scale 2), the electro spark (3 frames) and Gloria's nail.
Same rules as weapon_fx.py: flat fills, bold ink ring, seeded grain, palette tokens only.
Run after weapon_fx.py, into the same folder (it appends its rows to fx_rows.json):
    python tools/art/weapon_fx_blast.py <fx_dir>
"""

import json
import math
import random
import sys
from pathlib import Path

from PIL import ImageDraw

from weapon_fx import INK, INK_2, PAPER, PAPER_2, SS, STEEL, VERMILION, WASH, _canvas, _compose, _poly, _save


def _burst(cx, cy, r_out, r_in, spikes, rng):
    pts = []
    for i in range(spikes * 2):
        a = 2 * math.pi * i / (spikes * 2) + rng.uniform(-0.08, 0.08)
        r = r_out * rng.uniform(0.72, 1.0) if i % 2 == 0 else r_in * rng.uniform(0.85, 1.1)
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    return pts


def _ring(s, r_out, width, rng, lobes=14):
    """A lumpy ring: a circle of overlapping lobes with the centre cut out."""
    m = _canvas(s, s)
    d = ImageDraw.Draw(m)
    c = s / 2
    for i in range(lobes):
        a = 2 * math.pi * i / lobes + rng.uniform(-0.15, 0.15)
        rr = width * rng.uniform(0.45, 0.7)
        x, y = c + math.cos(a) * (r_out - width / 2), c + math.sin(a) * (r_out - width / 2)
        d.ellipse([(x - rr) * SS, (y - rr) * SS, (x + rr) * SS, (y + rr) * SS], fill=255)
    hole = r_out - width * 1.05
    d.ellipse([(c - hole) * SS, (c - hole) * SS, (c + hole) * SS, (c + hole) * SS], fill=0)
    return m


def blast(frame, out, seed):
    """0 paper flash with a vermilion heart, 1 vermilion fireball with a paper core, 2 wash smoke ring, 3 thin ring."""
    rng = random.Random(seed * 19 + frame)
    s = (300, 380, 440, 480)[frame]
    c = s / 2
    if frame == 0:
        body = _poly(_canvas(s, s), _burst(c, c, s * 0.46, s * 0.22, 11, rng))
        core = _poly(_canvas(s, s), _burst(c, c, s * 0.24, s * 0.12, 7, rng))
        layers = [(body, PAPER), (core, VERMILION)]
    elif frame == 1:
        body = _poly(_canvas(s, s), _burst(c, c, s * 0.46, s * 0.30, 13, rng))
        core = _poly(_canvas(s, s), _burst(c, c, s * 0.26, s * 0.17, 9, rng))
        layers = [(body, VERMILION), (core, PAPER)]
    elif frame == 2:
        layers = [(_ring(s, s * 0.45, s * 0.16, rng), WASH)]
    else:
        layers = [(_ring(s, s * 0.47, s * 0.07, rng, 20), PAPER_2)]
    _save(_compose(layers, s, s, seed + frame, outline=14), out / f"blast_{frame}.png")
    return [s, s], [s // 2, s // 2]


def scorch(out, seed):
    """The ground mark a blast leaves: a ragged ink splat with a wash heart and soot rays."""
    rng = random.Random(seed)
    s = 400
    c = s / 2
    rays = _canvas(s, s)
    d = ImageDraw.Draw(rays)
    for i in range(16):
        a = 2 * math.pi * i / 16 + rng.uniform(-0.12, 0.12)
        r = s * rng.uniform(0.36, 0.48)
        w = rng.uniform(10, 22)
        tip = (c + math.cos(a) * r, c + math.sin(a) * r)
        l = (c + math.cos(a + 1.57) * w, c + math.sin(a + 1.57) * w)
        rr = (c + math.cos(a - 1.57) * w, c + math.sin(a - 1.57) * w)
        d.polygon([(p[0] * SS, p[1] * SS) for p in (l, tip, rr)], fill=255)
    body = _poly(_canvas(s, s), _burst(c, c, s * 0.30, s * 0.22, 12, rng))
    heart = _poly(_canvas(s, s), _burst(c, c, s * 0.14, s * 0.10, 8, rng))
    img = _compose([(rays, INK), (body, INK_2), (heart, WASH)], s, s, seed, grain=0.18, outline=4)
    _save(img, out / "scorch.png")
    return [s, s], [s // 2, s // 2]


def spark(frame, out, seed):
    rng = random.Random(seed * 23 + frame)
    s = 110
    c = s / 2
    m = _canvas(s, s)
    d = ImageDraw.Draw(m)
    for i in range(5 + frame):
        a = 2 * math.pi * i / (5 + frame) + rng.uniform(-0.3, 0.3) + frame * 0.4
        r = s * rng.uniform(0.28, 0.40)
        mid = (c + math.cos(a + 0.3) * r * 0.5, c + math.sin(a + 0.3) * r * 0.5)
        tip = (c + math.cos(a) * r, c + math.sin(a) * r)
        d.line([(c * SS, c * SS), (mid[0] * SS, mid[1] * SS), (tip[0] * SS, tip[1] * SS)], fill=255, width=6 * SS)
    d.ellipse([(c - 10) * SS, (c - 10) * SS, (c + 10) * SS, (c + 10) * SS], fill=255)
    _save(_compose([(m, PAPER)], s, s, seed + frame, outline=7), out / f"spark_{frame}.png")
    return [s, s], [s // 2, s // 2]


def nail(out, seed):
    """Gloria's round: a long steel nail, a flat paper head at the back, the point forward."""
    w, h = 150, 40
    cy = h / 2
    shank = _poly(_canvas(w, h), [(26, cy - 5), (118, cy - 5), (140, cy), (118, cy + 5), (26, cy + 5)])
    head = _canvas(w, h)
    ImageDraw.Draw(head).rounded_rectangle([12 * SS, 6 * SS, 26 * SS, 34 * SS], radius=3 * SS, fill=255)
    _save(_compose([(shank, STEEL), (head, PAPER)], w, h, seed, outline=8), out / "nail.png")
    return [w, h], [140, int(cy)]


def main(dst):
    out = Path(dst)
    rows_path = out / "fx_rows.json"
    rows = json.loads(rows_path.read_text()) if rows_path.exists() else []
    new = []
    for f in range(4):
        size, anchor = blast(f, out, 53)
        new.append({"id": f"blast_{f}", "size_px": size, "anchor_px": anchor})
    for f in range(3):
        size, anchor = spark(f, out, 59)
        new.append({"id": f"spark_{f}", "size_px": size, "anchor_px": anchor})
    for fn in (scorch, nail):
        size, anchor = fn(out, 61)
        new.append({"id": fn.__name__, "size_px": size, "anchor_px": anchor})
    ids = {r["id"] for r in new}
    rows = [r for r in rows if r["id"] not in ids] + new
    rows_path.write_text(json.dumps(rows, indent=1, sort_keys=True))
    print(f"wrote {len(new)} impact fx cells to {out}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
