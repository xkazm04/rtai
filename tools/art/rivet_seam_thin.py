"""n5-cast: quiet the thin interior seams of Rivet's hybrid core parts so the 32 px/m core sticker
(print_part.gdshader: d >= 0.40 prints ink, else cream) reads as a cream plate with its bold marks,
not as aliased specks. Dark pixels (d >= 0.40) that are inside the part (more than EDGE px from the
alpha edge) and belong to a thin stroke (removed by a binary opening of radius R) are moved along
their hue to d = TO (just under the sticker threshold, so at 48 px/m they print as the mid wash).
Bold marks (survive the opening), the outer outline band and vermilion are untouched.
Usage: python tools/art/rivet_seam_thin.py <src.png> <dst.png> [--r=3] [--edge=10] [--to=0.38] [--mid=0.75]"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

CREAM = np.array([0.949, 0.910, 0.835]); INK = np.array([0.090, 0.075, 0.106])
W = np.array([0.299, 0.587, 0.114]); LC = CREAM @ W; LI = INK @ W

src, dst = sys.argv[1], sys.argv[2]
opt = dict(x[2:].split("=") for x in sys.argv[3:] if "=" in x)
r, edge, to = int(opt.get("r", 3)), float(opt.get("edge", 10)), float(opt.get("to", 0.38))
mid_hi = float(opt.get("mid", 0.0))  # > 0: also quiet inner mid tones with d below this
a = np.asarray(Image.open(src).convert("RGBA")).astype(float) / 255
rgb = a[..., :3]
solid = a[..., 3] > 0.45
d = np.clip((LC - rgb @ W) / (LC - LI), 0, 1)
verm = rgb[..., 0] * 255 - np.max(rgb[..., 1:], axis=-1) * 255 > 62
dark = (d >= 0.40) & solid & ~verm
st = ndimage.generate_binary_structure(2, 1)
bold = ndimage.binary_opening(dark, structure=st, iterations=r)
inner = ndimage.distance_transform_edt(solid) > edge
thin = dark & ~bold & inner
if mid_hi > 0:
    thin |= dark & inner & (d < mid_hi)
s = np.where(thin, to / np.maximum(d, 1e-4), 1.0)[..., None]
out = a.copy(); out[..., :3] = np.clip(CREAM + (rgb - CREAM) * s, 0, 1)
print(src, "dark px", int(dark.sum()), "thin quieted", int(thin.sum()), "bold kept", int((dark & bold).sum()))
Image.fromarray((out * 255 + 0.5).astype(np.uint8)).save(dst)
