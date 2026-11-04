"""The mini-nuke's own shell cell (weapon-art, 2026-11-04 iteration 20).

Until now the mini-nuke lobbed the rocket cell at 1.5x, so its shell read as a big rocket. This draws a
fat bomb from above in the same D5 ink print as tools/art/weapon_fx.py: a round-bellied steel body,
a boxed ring tail (dark fins), a cream nose cap and a vermilion hazard band (vermilion = danger) with
two ink stripes. The silhouette is the identity: short and fat with a square tail, never a long dart.
Deterministic (seeded grain). Prints the fx row to add to data/tables/weapon_art.json.

    python tools/art/nuke_shell.py project/features/combat/weapons/art/fx
"""

import json
import sys
from pathlib import Path

from PIL import ImageChops, ImageDraw

from weapon_fx import INK_2, PAPER, SS, STEEL, VERMILION, INK, _canvas, _compose, _poly, _save

W, H = 200, 96
CY = H / 2


def _ellipse(box):
    m = _canvas(W, H)
    ImageDraw.Draw(m).ellipse([v * SS for v in box], fill=255)
    return m


def main(dst):
    body = _ellipse((52, CY - 30, 186, CY + 30))
    tail = _poly(_canvas(W, H), [(26, CY - 11), (72, CY - 22), (72, CY + 22), (26, CY + 11)])
    fins = _poly(_canvas(W, H), [(10, CY - 36), (34, CY - 36), (34, CY + 36), (10, CY + 36)])
    spine = _poly(_canvas(W, H), [(10, CY - 5), (60, CY - 5), (60, CY + 5), (10, CY + 5)])
    nose = ImageChops.multiply(_ellipse((52, CY - 30, 186, CY + 30)), _poly(_canvas(W, H), [(160, 0), (W, 0), (W, H), (160, H)]))
    band = ImageChops.multiply(_ellipse((52, CY - 30, 186, CY + 30)), _poly(_canvas(W, H), [(112, 0), (134, 0), (134, H), (112, H)]))
    stripes = _canvas(W, H)
    d = ImageDraw.Draw(stripes)
    for x in (118, 128):
        d.line([(x * SS, (CY - 26) * SS), ((x - 4) * SS, (CY + 26) * SS)], fill=255, width=3 * SS)
    stripes = ImageChops.multiply(stripes, band)
    layers = [(body, STEEL), (tail, INK_2), (fins, INK_2), (spine, INK_2), (nose, PAPER), (band, VERMILION), (stripes, INK)]
    out = Path(dst) / "nuke_shell.png"
    _save(_compose(layers, W, H, 61), out)
    print(json.dumps({"id": "nuke_shell", "size_px": [W, H], "anchor_px": [186, int(CY)]}))


if __name__ == "__main__":
    main(sys.argv[1])
