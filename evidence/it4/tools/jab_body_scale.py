"""n15 hero (scratch): body height (alpha > 100, teal wisps masked out) of Dent's act cells vs the jab cells, per facing.

usage: py -3 -I evidence/it4/tools/jab_body_scale.py <act cells dir> <jab cells dir> [<out dir for rescaled jab cells>]
"""
import statistics, sys
from pathlib import Path
from PIL import Image


def body_h(p: Path) -> int:
    im = Image.open(p).convert("RGBA")
    px = im.load()
    rows = []
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a > 100 and not (b > r + 40 and g > r + 25):
                rows.append(y)
                break
    return (max(rows) - min(rows) + 1) if rows else 0


act, jab = Path(sys.argv[1]), Path(sys.argv[2])
out = Path(sys.argv[3]) if len(sys.argv) > 3 else None
for f in range(1, 6):
    a = statistics.median(body_h(act / f"{f}_{c}.png") for c in (1, 3))  # wind-up and follow: upright
    j = statistics.median(body_h(jab / f"{f}_{n}.png") for n in (1, 3))
    k = a / j
    print(f"facing {f}: act body {a} px, jab body {j} px, k {k:.3f}")
    if out:
        out.mkdir(parents=True, exist_ok=True)
        for n in (1, 2, 3):
            im = Image.open(jab / f"{f}_{n}.png").convert("RGBA")
            im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS).save(out / f"{f}_{n}.png")
