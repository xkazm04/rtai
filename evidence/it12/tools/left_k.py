"""left_k.py <right sheet> <left sheet> <cols>: per-cell figure heights (alpha > 100) of the right
sheet's rows 2-4 against the left sheet's rows 1-3, and the k that scales the left onto the right
(sum of right heights / sum of left heights over cells both have)."""
import sys
from PIL import Image
def heights(p, cols, rows):
    im = Image.open(p).convert("RGBA")
    w, h = im.width // cols, im.height // rows
    out = []
    for r in range(rows):
        row = []
        for c in range(cols):
            b = im.crop((c * w, r * h, c * w + w, r * h + h)).split()[3].point(lambda v: 255 if v > 100 else 0).getbbox()
            row.append(b[3] - b[1] if b else 0)
        out.append(row)
    return out
cols = int(sys.argv[3])
right = heights(sys.argv[1], cols, 5)[1:4]
left = heights(sys.argv[2], cols, 3)
pairs = [(a, b) for ra, rb in zip(right, left) for a, b in zip(ra, rb) if a and b]
print("right", right)
print("left ", left)
print(f"k {sum(a for a, _ in pairs) / sum(b for _, b in pairs):.4f}")
