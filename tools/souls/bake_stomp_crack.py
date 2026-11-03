"""Bake the Hauler stomp crack from the D5 road tile's own crack art (no new art, no AI).

Takes the forked, hatched crack of road_intersection_tone_cracks.png (the big connected ink
components, specks dropped), centres it on the fork (where its three branches meet), and lays a
second copy rotated 180 degrees over it, so the burst has branches all round out of one
point, like ground split by a slam, and bolds the strokes so they read at gameplay zoom. Writes an RGBA sprite, fork at the image centre.
usage: python tools/souls/bake_stomp_crack.py <tile_cracks.png> <out.png>
"""
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

FORK = (180, 306)  # x, y of the fork in the 768 px tile overlay
HALF = 300  # output half size in px (tile px)
MIN_PX = 400  # components smaller than this are specks
BOLD = 3  # max-filter size that thickens every stroke
INK = (34, 30, 36)  # the overlay's darkest ink
DEEP = (14, 12, 14)  # the stomp crack's ink
PAPER = (222, 212, 190)  # the chipped edge (the D5 paper)
PAPER_A = 170
EDGE = 3  # px the edge sits down-right of the stroke

src = np.asarray(Image.open(sys.argv[1]).convert("RGBA"))
alpha = src[..., 3] > 0
lab, n = ndimage.label(ndimage.binary_dilation(alpha, iterations=3))
sizes = ndimage.sum(alpha, lab, range(1, n + 1))
keep = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s >= MIN_PX]) & alpha
crack = src.copy()
crack[..., 3] = np.where(keep, src[..., 3], 0)

size = HALF * 2
canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
img = Image.fromarray(crack, "RGBA")
canvas.alpha_composite(img, (HALF - FORK[0], HALF - FORK[1]))
flip = Image.new("RGBA", (size, size), (0, 0, 0, 0))
flip.alpha_composite(img, (HALF - FORK[0], HALF - FORK[1]))
flip = flip.rotate(180, center=(HALF, HALF))
out = np.asarray(Image.alpha_composite(flip, canvas)).copy()
# Bold the line work (the tile's cracks are drawn for 96 px/m; the stomp must read at 32-48):
# grow the ink by BOLD px, new pixels in the crack's own darkest ink.
grown = ndimage.maximum_filter(out[..., 3], size=BOLD)
new = (grown > 0) & (out[..., 3] == 0)
out[new, :3] = INK
out[..., 3] = grown
# Dark-on-dark asphalt hides the tile's ink, so the stomp crack is drawn in deepest ink with a
# chipped paper edge (the stroke shifted down-right by EDGE px, outside the ink): relief that reads.
ink = grown > 0
out[ink, :3] = DEEP
edge = np.roll(np.roll(ink, EDGE, 0), EDGE, 1) & ~ink
out[edge, :3] = PAPER
out[edge, 3] = PAPER_A
Image.fromarray(out, "RGBA").save(sys.argv[2])
print("components kept", int(sum(1 for s in sizes if s >= MIN_PX)), "px", int(keep.sum()))
