"""The burning ground's fire loop in the round 2 colour sheet (look lane, n5 2026-11-05; r2_w4).

Re-inks quest 1's fx_fire.png (a vermilion body round a cream core, ink outline and hatching)
token by token with fx_colour.recolour: the body goes the flame family's orange, the core hot
yellow, the ink stays ink. knockout (optional): the core goes clear so the scorch under it shows
as the fire's dark heart, and the body grades hot yellow toward it. Paths and colours are data: tools/art/ground_fire.json.
Deterministic: the same inputs write byte-identical PNGs.

Run from the repo root:
    python tools/art/ground_fire.py tools/art/ground_fire.json
"""

import json
import sys
from pathlib import Path

from PIL import Image, ImageFilter

from fx_colour import _hex, _nearest, recolour


def knockout(src, dst, core_tokens, hot, hot_px):
    """The core (source pixels nearest `core_tokens`) goes clear so the scorch under the fire shows
    through as its dark heart; body pixels within `hot_px` of the core take the flat `hot`
    colour (the flame grades hot toward its heart). The ink stays ink."""
    s = Image.open(src).convert("RGBA")
    img = Image.open(dst).convert("RGBA")
    sp, px = s.load(), img.load()
    core = Image.new("L", img.size, 0)
    cp = core.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = sp[x, y]
            if a > 0 and _nearest((r, g, b)) in core_tokens:
                cp[x, y] = 255
    near = core.filter(ImageFilter.MaxFilter(2 * hot_px + 1)).load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if cp[x, y]:
                px[x, y] = (r, g, b, 0)
            elif a > 0 and near[x, y] and _nearest(sp[x, y][:3]) == "vermilion":
                px[x, y] = tuple(hot) + (a,)
    img.save(dst, optimize=True)


def main(cfg_path):
    cfg = json.loads(Path(cfg_path).read_text(encoding="utf-8"))
    mapping = {tok: _hex(c) for tok, c in cfg["tokens"].items()}
    recolour(cfg["src"], cfg["dst"], mapping)
    k = cfg.get("knockout")
    if k:
        knockout(cfg["src"], cfg["dst"], k["tokens"], _hex(k["hot"]), k["hot_px"])
    print("ground fire ->", cfg["dst"])


if __name__ == "__main__":
    main(sys.argv[1])
