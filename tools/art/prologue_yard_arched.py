"""Cut the n28 arched belt sheet: four sections of a tall arched assembly line (straight A, straight B,
curve, torn end), each trimmed to its alpha with a small margin, plus a measurement file.

python tools/art/prologue_yard_arched.py [--sources DIR]   (rewrites project/boot/prologue/art/arched_line)

belt_sections.json holds per section the size, the y of the bottom of the leg footing plates and the x
extents of each hanging cream appliance, so a caller can scale a section until an appliance is 1.5 to 2 m
wide. belt_straight_a_mirror.png and belt_curve_mirror.png are left-right flips for a paint path that
cannot flip.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import prologue_yard_cut as cut

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "project/boot/prologue/art/arched_line"
SHADOW = (0x21, 0x1E, 0x1C)
WHITE = (255, 255, 255)
MARGIN = 8
# section: crop box (x0, y0, x1, y1) on arched-belt-big.png
SECTIONS = {
    "straight_a": (0, 0, 887, 443),
    "straight_b": (887, 0, 1774, 443),
    "curve": (0, 458, 887, 887),
    "torn": (887, 458, 1774, 887),
}
MIRRORED = ("straight_a", "curve")
MIN_COLUMN_PX = 30
MIN_WIDTH_PX = 60
MAX_GAP_PX = 6
MIN_FOOT_ROW_PX = 25
FAINT_ALPHA, DROP_ALPHA = 90, 14
FOOT_ZONE = 0.3  # the first leg pair only: the far end may carry cables and crumbs
FOOT_PAD_PX = 45  # outlines and the ground shadow reach past the cream


def cream_mask(rgba):
    """Warm off-white enamel: bright, low saturation, mostly opaque (rust and copper are saturated)."""
    rgb = rgba[..., :3].astype(np.float32)
    top, low = rgb.max(axis=2), rgb.min(axis=2)
    saturation = (top - low) / np.maximum(top, 1)
    return (top > 185) & (saturation < 0.45) & (rgba[..., 3] > 128)


def column_groups(mask):
    """[x0, x1) runs of columns holding enough cream pixels, gaps up to MAX_GAP_PX bridged."""
    on = np.append(mask.sum(axis=0) >= MIN_COLUMN_PX, False)
    runs, start, last = [], None, None
    for x, flag in enumerate(on):
        if flag:
            if start is not None and x - last > MAX_GAP_PX + 1:
                runs.append([start, last + 1])
                start = None
            start = x if start is None else start
            last = x
    if start is not None:
        runs.append([start, last + 1])
    return [r for r in runs if r[1] - r[0] >= MIN_WIDTH_PX]


def footing_y(rgba, cream, appliances):
    """Lowest row with a footing-plate-sized run of opaque non-cream pixels outside the appliance columns, in the left zone."""
    solid = (rgba[..., 3] > 200) & ~cream
    solid[:, round(solid.shape[1] * FOOT_ZONE) :] = False
    for x0, x1 in appliances:
        solid[:, max(0, x0 - FOOT_PAD_PX) : x1 + FOOT_PAD_PX] = False
    rows = np.where(solid.sum(axis=1) >= MIN_FOOT_ROW_PX)[0]
    return int(rows[-1]) + 1 if rows.size else 0


def despeckle(rgba):
    """Faint pixels away from the drawing are ground shadow or paper noise: ink-coloured, or gone."""
    out = rgba.copy()
    alpha = out[..., 3]
    near = ndimage.binary_dilation(alpha > 200, iterations=2)
    faint = (alpha <= FAINT_ALPHA) & ~near
    out[faint, :3] = SHADOW
    out[faint & (alpha < DROP_ALPHA), 3] = 0
    return out


def trimmed(rgba):
    ys, xs = np.where(rgba[..., 3] > 0)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    out = np.zeros((y1 - y0 + 2 * MARGIN, x1 - x0 + 2 * MARGIN, 4), np.uint8)
    out[MARGIN : MARGIN + y1 - y0, MARGIN : MARGIN + x1 - x0] = rgba[y0:y1, x0:x1]
    return out


def measure(rgba):
    cream = cream_mask(rgba)
    groups = column_groups(cream)
    return {
        "size_px": [rgba.shape[1], rgba.shape[0]],
        "footing_y_px": footing_y(rgba, cream, groups),
        "appliances_px": groups,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources/n28")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(args.sources / "arched-belt-big.png").convert("RGB")
    report = {}
    for name, box in SECTIONS.items():
        rgba = np.asarray(cut.key_full(sheet.crop(box), WHITE, SHADOW))
        rgba = despeckle(rgba)
        rgba = trimmed(rgba)
        image = Image.fromarray(rgba)
        image.save(OUT / f"belt_{name}.png")
        if name in MIRRORED:
            image.transpose(Image.Transpose.FLIP_LEFT_RIGHT).save(OUT / f"belt_{name}_mirror.png")
        report[name] = measure(rgba)
    (OUT / "belt_sections.json").write_text(json.dumps(report, indent=1) + "\n")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
