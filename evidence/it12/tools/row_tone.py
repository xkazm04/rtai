"""row_tone.py <sheet> <cols> <rows> <row 1-based> <ref cols a,b> <fix cols c,d,..> <out>: scale the
RGB of the fix cells of one row so the mean skin colour (opaque, chroma > 30, red > blue) of those
cells matches the ref cells' mean on that row. Alpha and every other cell untouched. Prints gains."""
import sys
from PIL import Image
src, cols, rows, row = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]) - 1
ref = [int(c) - 1 for c in sys.argv[5].split(",")]
fix = [int(c) - 1 for c in sys.argv[6].split(",")]
im = Image.open(src).convert("RGBA")
w, h = im.width // cols, im.height // rows
def box(c): return (c * w, row * h, c * w + w, row * h + h)
def skin(cs):
    px = [p for c in cs for p in im.crop(box(c)).getdata() if p[3] > 200 and max(p[:3]) - min(p[:3]) > 30 and p[0] > p[2]]
    return [sum(p[i] for p in px) / len(px) for i in range(3)]
a, b = skin(ref), skin(fix)
g = [a[i] / b[i] for i in range(3)]
print("ref", [round(x) for x in a], "fix", [round(x) for x in b], "gain", [round(x, 3) for x in g])
for c in fix:
    cell = im.crop(box(c))
    px = [(min(255, round(p[0] * g[0])), min(255, round(p[1] * g[1])), min(255, round(p[2] * g[2])), p[3]) for p in cell.getdata()]
    cell.putdata(px)
    im.paste(cell, box(c)[:2])
im.save(sys.argv[7])
