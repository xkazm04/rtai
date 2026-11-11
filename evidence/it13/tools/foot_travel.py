"""Ground contacts per frame of one drawn row (n15 hero it13; the n11 tool is gone).

usage: foot_travel.py <sheet.png> <row 0-based> [band px=4] [cols=8] [rows=5]
Per column: the figure's lowest opaque row, the opaque pixels within <band> px above it,
grouped into contacts (x gap > 6 px); prints their centres (cell px) and widths.
"""
import sys
import numpy as np
from PIL import Image

sheet, row = sys.argv[1], int(sys.argv[2])
band = int(sys.argv[3]) if len(sys.argv) > 3 else 4
cols = int(sys.argv[4]) if len(sys.argv) > 4 else 8
rows = int(sys.argv[5]) if len(sys.argv) > 5 else 5
a = np.asarray(Image.open(sheet).convert("RGBA"))[..., 3]
cw, ch = a.shape[1] // cols, a.shape[0] // rows
for c in range(cols):
    cell = a[row * ch:(row + 1) * ch, c * cw:(c + 1) * cw] > 128
    ys = np.where(cell.any(1))[0]
    low = ys.max()
    xs = np.where(cell[low - band + 1:low + 1].any(0))[0]
    groups, start = [], xs[0]
    for i in range(1, len(xs) + 1):
        if i == len(xs) or xs[i] - xs[i - 1] > 6:
            groups.append((start, xs[i - 1])); start = xs[i] if i < len(xs) else 0
    # per contact, its lowest row (a lifted toe sits higher than the planted sole)
    out = []
    for g0, g1 in groups:
        col_low = max(np.where(cell[:, x])[0].max() for x in range(g0, g1 + 1))
        out.append(f"{(g0 + g1) / 2:6.1f} (w{g1 - g0 + 1:3d}, y{col_low})")
    print(f"f{c + 1}: low y {low}  " + "  ".join(out))
