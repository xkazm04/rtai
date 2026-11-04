"""Make the homing shard gun's crystal cluster bulge out of its body in the held (top-down) part (weapon-art,
2026-11-04 iteration 5).

In Rivet's claw at 32 px/m the shard gun printed as a slim long bar (the crystals sat inside the body plates), close
to the ray gun. This lifts the cluster (a hand-drawn polygon around the crystals and their ink) and stretches it x2
across the bore line, so a lumpy crystal mass bulges past the body above and below. Deterministic; the source is the
cut Codex part. Writes the new held.png and prints the rows added on top (grip/muzzle y move down by it).

    python tools/art/shard_crystals.py <held_in.png> <held_out.png>
"""

import sys

from PIL import Image, ImageDraw

POLY = [(103, 38), (130, 31), (150, 27), (175, 27), (190, 29), (215, 24), (240, 24), (258, 32), (262, 60),
        (284, 74), (262, 91), (240, 93), (200, 93), (170, 93), (140, 91), (118, 89), (114, 70), (102, 60)]
BOX = (100, 22, 286, 96)
BORE_Y = 60
K = 2.0


def main(src_path, out_path):
    src = Image.open(src_path).convert("RGBA")
    mask = Image.new("L", src.size, 0)
    ImageDraw.Draw(mask).polygon(POLY, fill=255)
    layer = Image.new("RGBA", src.size, (0, 0, 0, 0))
    layer.paste(src, (0, 0), mask)
    layer = layer.crop(BOX)
    grown = layer.resize((layer.width, int(layer.height * K)), Image.LANCZOS)
    cy = BORE_Y - BOX[1]
    top = int(cy * K) - cy
    pad = max(0, top - BOX[1])
    out = Image.new("RGBA", (src.width, src.height + 2 * pad), (0, 0, 0, 0))
    out.alpha_composite(src, (0, pad))
    out.alpha_composite(grown, (BOX[0], BOX[1] + pad - top))
    out.save(out_path)
    print(pad)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
