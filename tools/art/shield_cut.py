"""Cut the riot shield's frosted plate from a keyed riot sheet: shield_cut.py <sheet> <x0,y0,x1,y1> <out.png> [h=96]
Light low-saturation grey (the plate) -> largest component -> holes filled (slot, rivets) -> grown
5 px to take the ink rim -> the sheet's own pixels inside, upright, h px tall."""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage as nd
im = np.asarray(Image.open(sys.argv[1]).convert("RGBA")).astype(np.float32)
x0, y0, x1, y1 = map(int, sys.argv[2].split(","))
c = im[y0:y1, x0:x1].copy()
rgb = c[:, :, :3] / 255.0
mx, mn = rgb.max(2), rgb.min(2)
sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
m = (c[:, :, 3] > 128) & (sat < 0.2) & (mx > 0.5)
lab, n = nd.label(m)
big = lab == (np.argmax(np.bincount(lab.ravel())[1:]) + 1)
big = nd.binary_fill_holes(nd.binary_closing(big, iterations=3))
grow = nd.binary_dilation(big, iterations=5) & (c[:, :, 3] > 128)
ink = (mx < 0.3)
keep = big | (grow & ink)
keep = nd.binary_fill_holes(keep)
out = c.copy()
out[:, :, 3] = np.where(keep, c[:, :, 3], 0)
ys, xs = np.where(keep)
out = out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
h = int(sys.argv[4]) if len(sys.argv) > 4 else 96
img = Image.fromarray(out.clip(0, 255).astype(np.uint8))
w = round(img.width * h / img.height)
img.resize((w, h), Image.LANCZOS).save(sys.argv[3])
print(sys.argv[3], img.size, "->", (w, h), "plate px", int(big.sum()))
