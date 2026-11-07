"""n8 street: cut a library FALL strip (keyed, 5 rows = facings x 3 columns = buckle, mid-fall, lying)
into a game grid: 5 columns (facing camera, 3/4 toward, side, 3/4 away, back; the RigHeadCard frame
order) x 3 rows (the fall frames), every cell the same size, with each figure's FEET at the cell's
centre, so the game anchors every frame at the person's ground point (StreetWalkerFall).

usage: python -I tools/art/street_fall.py <keyed_fall.png> <out.png> [stand_px=177] [--stretch=1.5]

--stretch=K: the library B fix (round 20261107-0137): the lying frame of the facing-camera and back
rows is drawn as tall as the standing one; it is stretched K along the fall axis (vertical), about
the feet, so the corpse lies a body's length from them.

--back-from-away: the back row's lying frame is the 3/4-away row's (lying on the up-right
diagonal, 45 deg off the blow), for a strip whose drawn back corpse reads as a man standing with
raised hands (cop_patrol_fall_70's named fault; the same corpse turned 180 deg read so too: any
face-down body lying head-up on screen does at 70 deg, a diagonal one reads as lying).

The feet: buckling (frame 0) the box centre on the bottom line, as the walker strips are placed
(a held case would pull a centroid sideways and jump at the blow); mid-fall the lowest rows' x
centroid; lying (frame 2) the end of the body away from the facing's fall direction (the 5 %
of the figure's pixels lowest along it). Scaled so the buckling figures (frame 0) stand stand_px
tall on average: 0.93 of the still strip's ~190 px figure in its 192 px cell (StreetWalkerCards'
px per HEIGHT_M), so the grid shares the still's px/m. Raw art. Deterministic.
"""

import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import street_walk as sw  # noqa: E402

# The fall direction on screen per facing (x right, y down = toward the camera).
FALL_DIR = [(0.0, 1.0), (0.707, 0.707), (1.0, 0.0), (0.707, -0.707), (0.0, -1.0)]


def _thirds(solid: np.ndarray, y0: int, y1: int) -> list:
    prof = solid[y0:y1].sum(axis=0).astype(np.int64)
    w = prof.size
    cuts = [0] + [sw._valley(prof, w * k / 3 - w * 0.08, w * k / 3 + w * 0.08) for k in (1, 2)] + [w]
    return list(zip(cuts, cuts[1:]))


def _main(mask: np.ndarray) -> np.ndarray:
    """The figure and its props, without the sheet's loose specks (< 1 %) and a neighbour row's
    reach into the band (a part under 10 % touching the band's top or bottom edge)."""
    lab, n = ndimage.label(ndimage.binary_dilation(mask, iterations=3))
    sizes = ndimage.sum(mask, lab, range(1, n + 1))
    edge = set(np.unique(lab[0])) | set(np.unique(lab[-1]))
    keep = [
        i + 1
        for i, v in enumerate(sizes)
        if v >= sizes.max() * 0.01 and not (i + 1 in edge and v < sizes.max() * 0.1)
    ]
    return mask & np.isin(lab, keep)


def _feet(mask: np.ndarray, facing: int, frame: int) -> tuple:
    ys, xs = np.nonzero(mask)
    if frame == 0:  # the box centre, as street_head/street_walk place the walker (no jump)
        return mask.shape[1] / 2.0, float(ys.max())
    if frame == 1:
        y1 = ys.max()
        low = ys >= y1 - max(3, int((y1 - ys.min()) * 0.06))
        return float(xs[low].mean()), float(y1)
    ux, uy = FALL_DIR[facing]
    proj = xs * ux + ys * uy
    low = proj <= np.percentile(proj, 5)
    return float(xs[low].mean()), float(ys[low].mean())


def main() -> None:
    opts = [a for a in sys.argv[1:] if a.startswith("--")]
    sys.argv = [sys.argv[0]] + [a for a in sys.argv[1:] if not a.startswith("--")]
    stretch = 1.0
    for o in opts:
        if o.startswith("--stretch="):
            stretch = float(o[10:])
    back_from_away = "--back-from-away" in opts
    stand_px = float(sys.argv[3]) if len(sys.argv) > 3 else 177.0
    rgba = np.asarray(Image.open(sys.argv[1]).convert("RGBA"))
    solid = rgba[:, :, 3] > 128
    bands = sw._bands(solid.sum(axis=1).astype(np.int64), 5)
    figs = []  # (facing, frame, crop, feet x in crop, feet y in crop)
    for f, (y0, y1) in enumerate(bands):
        for i, (x0, x1) in enumerate(_thirds(solid, y0, y1)):
            m = _main(solid[y0:y1, x0:x1])
            ys, xs = np.nonzero(m)
            a, b, c, d = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
            fx, fy = _feet(m[a:b, c:d], f, i)
            crop = rgba[y0 + a : y0 + b, x0 + c : x0 + d].copy()
            crop[solid[y0 + a : y0 + b, x0 + c : x0 + d] & ~m[a:b, c:d], 3] = 0
            if i == 2 and f in (0, 4) and stretch != 1.0:
                h = round(crop.shape[0] * stretch)
                crop = np.asarray(Image.fromarray(crop).resize((crop.shape[1], h), Image.LANCZOS))
                fy *= stretch
            figs.append((f, i, crop, fx, fy))
        print(f"facing {f}: sizes {[(g[2].shape[1], g[2].shape[0]) for g in figs[-3:]]}, "
              f"feet {[(round(g[3]), round(g[4])) for g in figs[-3:]]}")
    if back_from_away:
        _, _, crop, fx, fy = next(g for g in figs if g[0] == 3 and g[1] == 2)
        at = next(j for j, g in enumerate(figs) if g[0] == 4 and g[1] == 2)
        figs[at] = (4, 2, crop, fx, fy)
        print("back lying frame = the 3/4-away lying frame")
    k = stand_px / np.mean([g[2].shape[0] for g in figs if g[1] == 0])
    print(f"stretch {stretch} on the facing-camera and back lying frames")
    hw = max(max(g[3], g[2].shape[1] - g[3]) for g in figs) * k
    hh = max(max(g[4], g[2].shape[0] - g[4]) for g in figs) * k
    cw, ch = int(np.ceil(hw)) * 2 + 4, int(np.ceil(hh)) * 2 + 4
    grid = Image.new("RGBA", (cw * 5, ch * 3), (0, 0, 0, 0))
    for f, i, crop, fx, fy in figs:
        im = Image.fromarray(crop)
        w, h = max(1, round(crop.shape[1] * k)), max(1, round(crop.shape[0] * k))
        im = im.resize((w, h), Image.LANCZOS)
        grid.paste(im, (f * cw + round(cw / 2 - fx * k), i * ch + round(ch / 2 - fy * k)))
    grid.save(sys.argv[2])
    print(f"{sys.argv[2]}: 5 facings x 3 frames of {cw}x{ch}, scale {k:.3f}, feet at the centre")


if __name__ == "__main__":
    main()
