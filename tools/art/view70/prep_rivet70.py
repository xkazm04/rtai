"""Mask the 5 top-row Rivet 70 figures to head + collar, re-lay them on green for cut_facings.py."""
from PIL import Image
import numpy as np
src = np.asarray(Image.open('C:/Users/kazda/kiro/gtai-art/angle-r1/out/rivet_70.png').convert('RGB')).copy()
Y0 = 20
FIG = [(88, 290, 116, 264, 165, 246), (385, 575, 414, 558, 170, 250), (675, 855, 696, 840, 170, 233),
       (955, 1140, 976, 1114, 160, 246), (1240, 1445, 1268, 1420, 160, 246)]
G = np.array([0, 177, 64], dtype=np.uint8)
out = np.zeros((300, 1536, 3), dtype=np.uint8); out[:] = G
for x0, x1, cx0, cx1, ys, yb in FIG:
    part = src[Y0:Y0 + yb, x0:x1].copy()
    ys_ = ys
    part[ys_:, : cx0 - x0] = G
    part[ys_:, cx1 - x0 :] = G
    out[10:10 + yb, x0:x1] = part
Image.fromarray(out).save('rivet70_heads_green.png')
