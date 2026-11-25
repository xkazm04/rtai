"""Cut the n30 per-bay hall roof slabs and the roof plume sheet (white key, despeckled, red fire moved to amber).

python tools/art/prologue_yard_roof.py --sources DIR [--out DIR] [--contact PNG] [--no-amber]
Reads DIR/roof-{shutter-w,burst,feed,shutter-e,collapsed}.png and DIR/plumes-*.png. Writes
hall_roof_<bay>.png (cropped flush left and right, trimmed top and bottom, size_m at 15.15 m wide) and
hall_plume_<n>.png (one per connected plume, trimmed, size_m at a stated scale), and prints both.
--contact lays the slabs over the shipped tall bays at the table's centres at 32 px/m on a dark ground.
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import prologue_yard_cut as cut
from prologue_yard_arched import despeckle
from prologue_yard_hall import OUT, SHADOW, WHITE, amber_shift, red_share, trimmed

HERE = Path(__file__).resolve().parent
BAY_WIDTH_M = 15.15
SLABS = {
    "roof-shutter-w": "hall_roof_shutter_w",
    "roof-burst": "hall_roof_burst",
    "roof-feed": "hall_roof_feed",
    "roof-shutter-e": "hall_roof_shutter_e",
    "roof-collapsed": "hall_roof_collapsed",
}
# A column belongs to the slab when this share of the slab's rows is opaque there; the side cut then
# steps INSET px further in, so the drawn side outline goes and neighbouring slabs butt as one roof.
SOLID_SHARE = 0.85
INSET = 6
# Plume sheets: puffs within GROUP px of each other are one plume; pieces under MIN_AREA px are dropped.
GROUP = 8
MIN_AREA = 4000
PUFF_SHARE = 0.08
PUFF_REACH = 160
PLUME_TALLEST_M = 6.0
# Contact sheet: the five bays of arched_line.factory_front in SLABS order (x, y centre m, sprite, flip).
PPM = 32
FRONT = [
    (-3.0, -4.94, "hall_tall_shutter_bay", False),
    (11.8, -4.765, "hall_tall_burst_bay", False),
    (26.6, -4.86, "hall_tall_feed_bay", True),
    (41.4, -4.94, "hall_tall_shutter_bay", True),
    (56.2, -4.7, "hall_tall_collapsed_bay", False),
]
TUCK_M = 0.6
GROUND = (24, 21, 19, 255)


def keyed(path):
    """The white-keyed, despeckled RGBA of one source sheet."""
    sheet = Image.open(path).convert("RGB")
    return despeckle(np.asarray(cut.key_full(sheet, WHITE, SHADOW)))


def flush_sides(rgba):
    """Cropped to the columns solid over SOLID_SHARE of the slab's rows (less INSET), trimmed top and bottom."""
    alpha = rgba[..., 3]
    rows = np.where(alpha.any(axis=1))[0]
    if rows.size == 0:
        raise ValueError("slab contains only background")
    body = alpha[rows.min() : rows.max() + 1] > 200
    solid = np.where(body.mean(axis=0) >= SOLID_SHARE)[0]
    if solid.size == 0:
        raise ValueError("no solid slab column")
    x0, x1 = solid.min() + INSET, solid.max() + 1 - INSET
    if x1 - x0 < alpha.shape[1] // 4:
        raise ValueError("slab too narrow after the flush cut")
    side = rgba[:, x0:x1]
    ys = np.where(side[..., 3].any(axis=1))[0]
    return np.ascontiguousarray(side[ys.min() : ys.max() + 1])


def slab_size_m(rgba):
    """The size_m [w, h] that keeps the slab's aspect at the bay width."""
    h, w = rgba.shape[:2]
    return [BAY_WIDTH_M, round(BAY_WIDTH_M * h / w, 2)]


def plume_labels(alpha):
    """Labels of the sheet's plumes: puffs closer than GROUP px merged; a piece under PUFF_SHARE of the
    biggest joins the nearest plume within PUFF_REACH px (a detached puff) or is dropped (paper noise)."""
    labels, count = ndimage.label(ndimage.binary_dilation(alpha > 0, iterations=GROUP))
    labels[alpha == 0] = 0
    if count == 0:
        return labels
    areas = ndimage.sum(alpha > 128, labels, range(1, count + 1))
    big = np.isin(labels, 1 + np.where(areas >= PUFF_SHARE * areas.max())[0])
    reach, (iy, ix) = ndimage.distance_transform_edt(~big, return_indices=True)
    small = (labels > 0) & ~big
    near = small & (reach <= PUFF_REACH)
    labels[near] = labels[iy[near], ix[near]]
    labels[small & ~near] = 0
    return labels


def split_plumes(rgba):
    """One trimmed RGBA per plume, in reading order: rows (pieces whose spans overlap), then x."""
    labels = plume_labels(rgba[..., 3])
    pieces = []
    for index, box in enumerate(ndimage.find_objects(labels), start=1):
        if box is None:
            continue
        piece = rgba[box].copy()
        piece[labels[box] != index, 3] = 0
        if (piece[..., 3] > 128).sum() >= MIN_AREA:
            pieces.append((box[0].start, box[0].stop, box[1].start, trimmed(piece)))
    rows, bottom = [], -1
    for start, stop, x, piece in sorted(pieces, key=lambda p: p[0]):
        if start >= bottom:
            rows.append([])
        rows[-1].append((x, piece))
        bottom = max(bottom, stop)
    return [piece for row in rows for _, piece in sorted(row, key=lambda p: p[0])]


def plume_scale(plumes):
    """Metres per source px: the tallest plume of the sheet is PLUME_TALLEST_M tall."""
    return PLUME_TALLEST_M / max(p.shape[0] for p in plumes)


def fire_spot(rgba):
    """(x, y) of the largest bright amber fire patch, or the slab's centre when it has none."""
    rgb = rgba[..., :3].astype(np.float32) / 255
    top, low = rgb.max(axis=2), rgb.min(axis=2)
    fire = ((top - low) / np.maximum(top, 1e-6) > 0.5) & (top > 0.8) & (rgba[..., 3] > 200)
    labels, count = ndimage.label(fire)
    if count == 0:
        return rgba.shape[1] // 2, rgba.shape[0] // 2
    sizes = ndimage.sum(fire, labels, range(1, count + 1))
    y, x = ndimage.center_of_mass(fire, labels, int(np.argmax(sizes)) + 1)
    return int(x), int(y)


def _scaled(rgba, width):
    image = Image.fromarray(rgba)
    return image.resize((width, max(1, round(image.height * width / image.width))), Image.LANCZOS)


def roof_line(rgba):
    """First row where the bay is opaque across SOLID_SHARE of its width: its roof strip under the baked plumes."""
    rows = np.where(((rgba[..., 3] > 200).mean(axis=1)) >= SOLID_SHARE)[0]
    return int(rows[0]) if rows.size else 0


def _plumed(canvas, top, origin, plumes, first, scale_m):
    """Two plumes standing on the slab's biggest fire patch and a third of a slab to its right."""
    spot = fire_spot(np.asarray(top))
    for j, shift in enumerate((0, top.width // 3)):
        plume = plumes[(first + j) % len(plumes)]
        p = _scaled(plume, max(1, round(plume.shape[1] * scale_m * PPM)))
        x = origin[0] + (spot[0] + shift) % top.width - p.width // 2
        canvas.alpha_composite(p, (x, origin[1] + spot[1] - p.height + 8))


def contact(slabs, plumes, scale_m, art=OUT):
    """Slabs over the shipped bays where the table puts them (bay feet level), each slab's south edge TUCK_M under
    its bay's roof strip, two plumes per slab, PPM px/m on GROUND."""
    width = round(BAY_WIDTH_M * PPM)
    bays = [_scaled(np.asarray(Image.open(art / f"{name}.png").convert("RGBA")), width) for _, _, name, _ in FRONT]
    tops = {i: _scaled(slabs[src], width) for i, src in enumerate(SLABS) if src in slabs}
    left = (FRONT[0][0] - BAY_WIDTH_M / 2) * PPM - 20
    feet = max(y * PPM + b.height / 2 for (_, y, _, _), b in zip(FRONT, bays))
    sky = (
        max([t.height for t in tops.values()] + [0]) + round((PLUME_TALLEST_M + 1) * PPM) + max(b.height for b in bays)
    )
    canvas = Image.new("RGBA", (round((FRONT[-1][0] - FRONT[0][0] + BAY_WIDTH_M) * PPM) + 40, sky + 20), GROUND)
    placed = []
    for i, ((x_m, y_m, _, flip), bay) in enumerate(zip(FRONT, bays)):
        x, y = round(x_m * PPM - width / 2 - left), round(sky - feet + y_m * PPM - bay.height / 2)
        if i in tops:
            eave = y + roof_line(np.asarray(bay)) + round(TUCK_M * PPM)
            placed.append((tops[i], (x, eave - tops[i].height), 2 * i))
            canvas.alpha_composite(tops[i], placed[-1][1])
        canvas.alpha_composite(bay.transpose(Image.FLIP_LEFT_RIGHT) if flip else bay, (x, y))
    for top, origin, first in placed if plumes else []:
        _plumed(canvas, top, origin, plumes, first, scale_m)
    return canvas


def _cut_slabs(sources, out, amber):
    slabs = {}
    for src, name in SLABS.items():
        path = sources / f"{src}.png"
        if not path.exists():
            print(f"{name}: no source {path.name}, skipped")
            continue
        rgba = flush_sides(keyed(path))
        before = red_share(rgba)
        rgba = amber_shift(rgba) if amber else rgba
        Image.fromarray(rgba).save(out / f"{name}.png")
        slabs[src] = rgba
        h, w = rgba.shape[:2]
        print(f"{name}: {w}x{h} size_m {slab_size_m(rgba)}; red {before * 100:.2f}% -> {red_share(rgba) * 100:.2f}%")
    return slabs


def _cut_plumes(sources, out, amber):
    plumes = []
    for path in sorted(sources.glob("plumes-*.png")):
        plumes += split_plumes(keyed(path))
    if not plumes:
        print("plumes: no plumes-*.png source, skipped")
        return [], 0.0
    scale = plume_scale(plumes)
    print(f"plumes: {len(plumes)} at {scale:.5f} m per source px (tallest {PLUME_TALLEST_M} m)")
    for n, rgba in enumerate(plumes, start=1):
        before = red_share(rgba)
        plumes[n - 1] = amber_shift(rgba) if amber else rgba
        h, w = rgba.shape[:2]
        Image.fromarray(plumes[n - 1]).save(out / f"hall_plume_{n}.png")
        size = [round(w * scale, 2), round(h * scale, 2)]
        print(
            f"hall_plume_{n}: {w}x{h} size_m {size}; red {before * 100:.2f}% -> {red_share(plumes[n - 1]) * 100:.2f}%"
        )
    return plumes, scale


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources/n30")
    parser.add_argument("--out", type=Path, default=OUT, help="cut dir (default: the repo arched_line art)")
    parser.add_argument("--contact", type=Path, help="also write the contact sheet here")
    parser.add_argument("--no-amber", action="store_true", help="skip the red-to-amber shift")
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    slabs = _cut_slabs(args.sources, args.out, not args.no_amber)
    plumes, scale = _cut_plumes(args.sources, args.out, not args.no_amber)
    if args.contact and slabs:
        contact(slabs, plumes, scale).save(args.contact)
        print(f"contact: {args.contact}")


if __name__ == "__main__":
    main()
