"""Stream FX in the D5 ink print (weapon-art lane, iteration 3, 2026-11-04).

Replaces two iteration-1 cells that failed the in-game read (arena clips, 64 px/m):
- flame_0..2: the round puffs drew the flamethrower's stream as a row of beads. Now a flame TONGUE
  pointing +x (the jet direction): a round vermilion head with a paper heart, ragged licks trailing
  back toward -x, so overlapping tongues read as one gushing jet. Anchor = the head's centre.
- arc_0..2: the electro bolt's 9 px stroke was a thin white scribble at game scale. Now a 20 px paper
  zigzag in a 10 px ink ring with forked side branches. Anchor = the tail (x 12), +x to the head.
Same rules as weapon_fx.py: flat fills, bold ink ring, seeded grain, palette tokens only.
Run after weapon_fx.py and weapon_fx_blast.py into the same folder (it replaces their rows):
    python tools/art/weapon_fx_jet.py <fx_dir>
"""

import json
import math
import random
import sys
from pathlib import Path

from PIL import ImageDraw

from weapon_fx import PAPER, SS, VERMILION, _canvas, _compose, _save


def _ellipse(d, cx, cy, rx, ry):
    d.ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS], fill=255)


def _licks(d, rng, x0, cy, half, n, reach):
    """n ragged flame licks from a root at x0 (spread over +-half) back toward -x."""
    for i in range(n):
        root_y = cy + (i - (n - 1) / 2) * (2 * half / max(n - 1, 1))
        tip = (x0 - reach * rng.uniform(0.6, 1.0), root_y + rng.uniform(-0.5, 0.5) * half)
        w = half * rng.uniform(0.35, 0.55)
        mid = ((x0 + tip[0]) / 2, (root_y + tip[1]) / 2 + rng.uniform(-6, 6))
        pts = [(x0, root_y - w), (mid[0], mid[1] - w * 0.5), tip, (mid[0], mid[1] + w * 0.5), (x0, root_y + w)]
        d.polygon([(x * SS, y * SS) for x, y in pts], fill=255)


def tongue(frame, out, seed):
    w, h = 220, 120
    cy = h / 2
    rng = random.Random(seed * 31 + frame)
    body = _canvas(w, h)
    d = ImageDraw.Draw(body)
    _ellipse(d, 150, cy, 46, 42 + frame * 2)
    _ellipse(d, 108, cy + rng.uniform(-5, 5), 36, 33)
    _licks(d, rng, 112, cy, 30, 3 + frame % 2, 92)
    core = _canvas(w, h)
    dc = ImageDraw.Draw(core)
    _ellipse(dc, 156, cy, 24, 21)
    _licks(dc, rng, 150, cy, 12, 2, 52)
    _save(_compose([(body, VERMILION), (core, PAPER)], w, h, seed + frame, outline=9), out / f"flame_{frame}.png")
    return [w, h], [150, int(cy)]


def bolt(frame, out, seed):
    w, h = 320, 120
    cy = h / 2
    rng = random.Random(seed * 13 + frame)
    m = _canvas(w, h)
    d = ImageDraw.Draw(m)
    pts = [(12, cy)]
    for i in range(1, 8):
        pts.append((12 + (w - 24) * i / 7, cy + (rng.uniform(-34, 34) if i < 7 else 0)))
    d.line([(x * SS, y * SS) for x, y in pts], fill=255, width=20 * SS, joint="curve")
    for x, y in pts[1:6:2]:
        a = rng.choice((-1, 1)) * rng.uniform(0.6, 1.1)
        bx, by = x + math.cos(a) * 46, y + math.sin(a) * 46
        d.line([(x * SS, y * SS), (bx * SS, by * SS)], fill=255, width=10 * SS)
    _save(_compose([(m, PAPER)], w, h, seed + frame, outline=10), out / f"arc_{frame}.png")
    return [w, h], [12, int(cy)]


def main(dst):
    out = Path(dst)
    rows_path = out / "fx_rows.json"
    rows = json.loads(rows_path.read_text()) if rows_path.exists() else []
    new = []
    for f in range(3):
        size, anchor = tongue(f, out, 29)
        new.append({"id": f"flame_{f}", "size_px": size, "anchor_px": anchor})
        size, anchor = bolt(f, out, 37)
        new.append({"id": f"arc_{f}", "size_px": size, "anchor_px": anchor})
    ids = {r["id"] for r in new}
    rows = [r for r in rows if r["id"] not in ids] + new
    rows_path.write_text(json.dumps(rows, indent=1, sort_keys=True))
    print(f"wrote {len(new)} stream fx cells to {out}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
