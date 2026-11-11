"""n15 hero it15: where Ohm's drawn bolt hand is in each CUT cell of an act sheet: the largest white
spark cluster's pixels that touch the teal arm (within 3 px) = the fingertips. Prints per row the tip
in cell px and relative to the feet point (cell centre x, cell bottom - PAD 2).
usage: py -3 -I ohm_hand.py <ohm_act.png> [cols=4] [rows=5] [col=1]"""
import sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGBA")
cols = int(sys.argv[2]) if len(sys.argv) > 2 else 4
rows = int(sys.argv[3]) if len(sys.argv) > 3 else 5
col = int(sys.argv[4]) if len(sys.argv) > 4 else 1
cw, ch = im.width // cols, im.height // rows
for r in range(rows):
    px = im.crop((col * cw, r * ch, (col + 1) * cw, (r + 1) * ch)).load()
    white = {(x, y) for y in range(ch) for x in range(cw)
             if px[x, y][3] > 200 and min(px[x, y][:3]) > 225}
    seen, best = set(), []
    for p in white:
        if p in seen:
            continue
        comp, stack = [], [p]
        seen.add(p)
        while stack:
            q = stack.pop(); comp.append(q)
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    n = (q[0] + dx, q[1] + dy)
                    if n in white and n not in seen:
                        seen.add(n); stack.append(n)
        if len(comp) > len(best):
            best = comp
    def teal(x, y):
        if not (0 <= x < cw and 0 <= y < ch):
            return False
        R, G, B, A = px[x, y]
        return A > 200 and G > R + 40 and B > R + 20 and max(R, G, B) < 225
    root = [p for p in best if any(teal(p[0] + dx, p[1] + dy) for dx in range(-3, 4) for dy in range(-3, 4))]
    if not root:
        print(r, "no root"); continue
    x = sum(p[0] for p in root) / len(root); y = sum(p[1] for p in root) / len(root)
    print(f"row {r}: spark {len(best)} px, root {len(root)} px at cell ({x:.0f},{y:.0f}) = feet ({x - cw / 2:+.0f},{y - (ch - 2):+.0f})")
