"""Glyph atlas ink boxes (handheld lane, n9): trims each cell of a library glyph atlas to its ink.

The asset lane's atlases (`keyed/ui/ui_pad_glyphs_v1.png` + `.json`, `{name: [x, y, w, h]}`) put each
glyph in a 128 px cell with a margin; PadGlyphArt fits the drawn glyph by its ink box instead, so a
short shoulder bar reads as tall as a face button. Writes `{"cells": {name: [x, y, w, h]}}` (sorted
keys, the box of the pixels whose alpha is above ALPHA) to --out.

--schema= and --doc= add those keys (the shipped pad json: gtai.pad_glyph_atlas/1 and its doc line).

Usage: python -I tools/handheld/glyph_inkbox.py <atlas.png> <cells.json> --out=<json> [--schema=] [--doc=]
"""

import json
import sys

from PIL import Image

ALPHA = 24


def ink_box(img, cell):
    x, y, w, h = cell
    box = img.crop((x, y, x + w, y + h)).getchannel("A").point(lambda a: 255 if a > ALPHA else 0)
    b = box.getbbox()
    if b is None:
        return [x, y, w, h]
    return [x + b[0], y + b[1], b[2] - b[0], b[3] - b[1]]


def main(argv):
    pos = [a for a in argv if not a.startswith("--")]
    opt = {a[2:].split("=", 1)[0]: a.split("=", 1)[1] for a in argv if a.startswith("--") and "=" in a}
    out = opt.get("out")
    if len(pos) != 2 or out is None:
        print(__doc__.strip().splitlines()[-1])
        return 2
    img = Image.open(pos[0]).convert("RGBA")
    with open(pos[1], encoding="utf8") as f:
        cells = json.load(f)
    cells = cells.get("cells", cells)
    doc = {"cells": {k: ink_box(img, v) for k, v in sorted(cells.items())}}
    for key in ("doc", "schema"):
        if key in opt:
            doc[key] = opt[key]
    with open(out, "w", encoding="utf8", newline="\n") as f:
        json.dump(doc, f, sort_keys=True, separators=(", ", ": "))
        f.write("\n")
    print(f"{len(doc['cells'])} cells -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
