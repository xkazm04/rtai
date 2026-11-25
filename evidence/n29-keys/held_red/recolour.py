"""True-red -> amber (hue 37, s<=0.72, v kept) on plain files. Run: python -I recolour.py <masters_dir>"""
import sys, json, colorsys
import numpy as np
from PIL import Image
sys.path.insert(0, "evidence/n29-keys/held_red")
A = "project/features/combat/weapons/art/"
FILES = [A + "showcase/crate/p70.png"]  # baton held and electro_gun icon tried, reverted (olive speckle)
M = sys.argv[1]
def masks(a):
    r, g, b, al = [a[..., i].astype(float) for i in range(4)]
    red = (r > 170) & (g < 110) & (b < 90) & (al > 0)
    mx = np.maximum(np.maximum(r, g), b); mn = np.minimum(np.minimum(r, g), b); d = mx - mn + 1e-9
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    s = d / (mx + 1e-9); v = mx / 255
    return red & ~((h >= 9) & (h <= 24) & (s > 0.6) & (v > 0.6))
res = {}
for p in FILES:
    im = Image.open(p); mode = im.mode
    a = np.array(im.convert("RGBA")); m = masks(a); b = a.copy()
    for y, x in zip(*np.where(m)):
        r, g, bl = a[y, x, :3] / 255.0
        h, s, v = colorsys.rgb_to_hsv(r, g, bl)
        n = colorsys.hsv_to_rgb(37 / 360, min(s, 0.72), v)
        b[y, x, :3] = [round(c * 255) for c in n]
    outside = int((np.any(a != b, axis=-1) & ~m).sum())
    Image.fromarray(b).save(p)
    name = p.replace("/", "_")
    def up(arr): return Image.fromarray(arr).resize((arr.shape[1] * 4, arr.shape[0] * 4), Image.NEAREST)
    ys, xs = np.where(m); y0, y1, x0, x1 = ys.min(), min(ys.max() + 1, ys.min() + 128), xs.min(), min(xs.max() + 1, xs.min() + 128)
    A_, B_ = up(a[y0:y1, x0:x1]), up(b[y0:y1, x0:x1])
    s = Image.new("RGBA", (A_.width * 2 + 8, A_.height), (60, 60, 70, 255)); s.alpha_composite(A_, (0, 0)); s.alpha_composite(B_, (A_.width + 8, 0))
    s.save(M + "/" + name + "_before_after_4x.png")
    res[p] = {"mask_px": int(m.sum()), "changed_outside_mask": outside, "mode": mode}
json.dump(res, open("evidence/n29-keys/held_red/recolour_proof.json", "w"), indent=1)
print(res)
