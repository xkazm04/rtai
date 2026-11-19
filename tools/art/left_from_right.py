"""Build SW/W/NW from the shipped SE/E/NE cells at their exact native scale.

Coordinates in the manifest refer to the original, right-facing cell. Each
band is a sequence of (x, top, bottom) knots, inclusive. Reflect its texture
in the local coordinates of the band so the rim, silhouette and perspective
survive. Hide polygons describe exposed hardware now occluded on the far side.
Only those regions can differ from a pixel-for-pixel mirror.
"""
import numpy as np
from PIL import Image, ImageDraw


def turn_band(original, work, knots):
    knots = np.asarray(knots, dtype=int)
    xs, top, bottom = knots.T
    h, w = work.shape[:2]
    if (len(xs) < 2 or np.any(np.diff(xs) <= 0) or min(xs) < 0 or max(xs) >= w
            or min(top) < 0 or max(bottom) >= h or np.any(top > bottom)):
        raise ValueError("band must be ordered and inside the source cell")
    columns = np.arange(xs[0], xs[-1]+1)
    hi = np.rint(np.interp(columns, xs, top)).astype(int)
    lo = np.rint(np.interp(columns, xs, bottom)).astype(int)
    for i, dest in enumerate(columns):
        j = len(columns)-1-i
        donor_y = np.rint(np.linspace(hi[j], lo[j], lo[i]-hi[i]+1)).astype(int)
        patch = work[hi[i]:lo[i]+1, dest]
        donor = original[donor_y, columns[j]]
        solid = (patch[:, 3] >= 128) & (donor[:, 3] >= 128)
        patch[solid, :3] = donor[solid, :3]


def mirror_cell(image, regions):
    source = np.asarray(image.convert("RGBA"))
    work = source.copy()
    for region in regions:
        if "band" in region:
            turn_band(source, work, region["band"])
        elif "hide" in region:
            mask = Image.new("1", image.size)
            ImageDraw.Draw(mask).polygon([tuple(pt) for pt in region["hide"]], fill=1)
            work[np.asarray(mask)] = 0
        elif "gun_mask" not in region:
            raise ValueError(f"unknown correction for {region['part']}")
    return Image.fromarray(work[:, ::-1])


def build(source, dest, facings):
    with Image.open(source) as strip:
        if strip.width % 8 or len(facings) != 3:
            raise ValueError("expected eight equipped cells and three left-facing recipes")
        w, h = strip.width//8, strip.height
        out = Image.new("RGBA", (3*w, h))
        for i, regions in enumerate(facings, 1):
            cell = strip.crop((i*w, 0, (i+1)*w, h))
            out.paste(mirror_cell(cell, regions), ((i-1)*w, 0))
    out.save(dest, optimize=True)
