"""regrid.py <in.png> <cols> <rows> <cell_w> <out.png>: re-lay a packed ghost grid into wider cells,
padding each cell evenly left and right (the figure keeps its offset from the cell centre), so a
repack whose widest cell shrank keeps the committed cell width and every unchanged cell's pixels."""
import sys
from PIL import Image
src, cols, rows, cw, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
im = Image.open(src).convert("RGBA")
w, h = im.width // cols, im.height // rows
pad = (cw - w) // 2
assert cw >= w and (cw - w) % 2 == 0, (w, cw)
o = Image.new("RGBA", (cw * cols, h * rows), (0, 0, 0, 0))
for r in range(rows):
    for c in range(cols):
        o.paste(im.crop((c * w, r * h, c * w + w, r * h + h)), (c * cw + pad, r * h))
o.save(out)
print(out, o.size)
