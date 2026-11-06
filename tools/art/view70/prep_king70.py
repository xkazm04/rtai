"""Mask the 5 top-row King 70 figures to the bust (crown, face, fur, chain; no fists), fix the
colours (crown velvet cap plum, cape vermilion), re-lay them on green for cut_facings.py."""
import colorsys
from PIL import Image
import numpy as np
src = np.asarray(Image.open('C:/Users/kazda/kiro/gtai-art/angle-r1/out/king_70.png').convert('RGB')).copy()
Y0 = 40
# x0, x1, window below ysplit (wx0, wx1), ysplit, ybottom  (top-row coords)
FIG = [(25, 345, 108, 258, 172, 226), (345, 628, 362, 572, 125, 226), (645, 878, 650, 832, 125, 212),
       (915, 1185, 992, 1182, 130, 230), (1200, 1505, 1242, 1468, 112, 230)]
G = np.array([0, 177, 64], dtype=np.uint8)
out = np.zeros((300, 1536, 3), dtype=np.uint8); out[:] = G
for x0, x1, wx0, wx1, ys, yb in FIG:
    part = src[Y0:Y0 + yb, x0:x1].copy()
    part[ys:, : wx0 - x0] = G
    part[ys:, wx1 - x0 :] = G
    out[10:10 + yb, x0:x1] = part
a = out.astype(np.float32) / 255.0
r, g, b = a[..., 0], a[..., 1], a[..., 2]
mx, mn = a.max(axis=2), a.min(axis=2)
sat = (mx - mn) / np.maximum(mx, 1e-6)
hue = np.zeros_like(mx)
d = np.maximum(mx - mn, 1e-6)
hue = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60.0
yy = np.arange(a.shape[0])[:, None].repeat(a.shape[1], axis=1)
redish = ((hue >= 330) | (hue <= 22)) & (sat > 0.35) & (mx > 0.18)
# the crown's velvet cap: dark red in the crown band (top ~95 px of each figure) -> plum
cap = redish & (yy < 10 + 100)
# the cape: brick red below the crown band -> vermilion (value kept as shading)
cape = redish & ~cap & (sat > 0.55) & (hue <= 22)
PLUM = np.array([0.42, 0.16, 0.40]); VERM = np.array([0.910, 0.314, 0.165])
k = (mx / np.maximum(mx[cap].max() if cap.any() else 1, 1e-6))[..., None]
a[cap] = np.clip(PLUM * (0.55 + 0.9 * k[cap]), 0, 1)
kc = (mx / 0.85)[..., None]
a[cape] = np.clip(VERM * (0.45 + 0.6 * kc[cape]), 0, 1)
Image.fromarray((a * 255).astype(np.uint8)).save('king70_bust_green.png')
print('cap px', int(cap.sum()), 'cape px', int(cape.sum()))
