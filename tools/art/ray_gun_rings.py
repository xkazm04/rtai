"""Stretch the ray gun's emitter rings sideways in its held (top-down) part (weapon-art, 2026-11-04 iteration 5).

In Rivet's claw at 32 px/m the ray gun and the homing shard gun printed as the same long pale bar: the rings stood
only about 15 px proud of the body. This stretches the two ring groups across the bore line (the rings' own centre
row) by K, so the ray gun has a ribbed outline wider than any other gun. Deterministic; the source is the cut Codex
part. Writes the new held.png and prints the rows added on top (grip/muzzle y move down by it).

    python tools/art/ray_gun_rings.py <held_in.png> <held_out.png>
"""

import sys

from PIL import Image

GROUPS = [(156, 246), (276, 336)]  # ring columns in the cut part
BORE_Y = 82  # the rings' centre row (grip_px / muzzle_px y)
K = 1.45


def main(src_path, out_path):
    src = Image.open(src_path).convert("RGBA")
    grown = [src.crop((x0, 0, x1, src.height)).resize((x1 - x0, int(round(src.height * K))), Image.LANCZOS)
             for x0, x1 in GROUPS]
    top = int(round(BORE_Y * K)) - BORE_Y  # rows the stretched rings reach above the old top
    h = max(src.height + top, max(g.height for g in grown))
    out = Image.new("RGBA", (src.width, h), (0, 0, 0, 0))
    out.alpha_composite(src, (0, top))
    for (x0, _x1), g in zip(GROUPS, grown):
        out.paste(Image.new("RGBA", (g.width, h), (0, 0, 0, 0)), (x0, 0))
        out.alpha_composite(g, (x0, 0))
    out.save(out_path)
    print(top)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
