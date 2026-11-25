"""Cut the four n29 tall burning hall bays (white key, despeckled, trimmed, red fire moved to amber).

python tools/art/prologue_yard_hall_tall.py [--sources DIR] [--no-amber]
(writes arched_line/hall_tall_{burst,shutter,feed,collapsed}_bay.png and prints each size_m at 15.15 m wide)
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

import prologue_yard_cut as cut
from prologue_yard_arched import despeckle
from prologue_yard_hall import MARGIN, OUT, SHADOW, WHITE, amber_shift, red_share

HERE = Path(__file__).resolve().parent
BAY_WIDTH_M = 15.15
CUTS = {
    "tall-burst-bay": "hall_tall_burst_bay",
    "tall-shutter-bay": "hall_tall_shutter_bay",
    "tall-feed-bay": "hall_tall_feed_bay",
    "tall-collapsed-bay": "hall_tall_collapsed_bay",
}
# Source crop per job (x0, x1, wall base row): x through the middle of each end's outermost brick
# pier, so the rounded gable ends go and neighbouring bays butt into one continuous facade; below,
# RUBBLE_M of rubble band under the wall base is kept and everything lower (the feed bay's belt
# stub out in the yard) is dropped.
CROP = {
    "tall-burst-bay": (190, 1545, 733),
    "tall-shutter-bay": (190, 1545, 764),
    "tall-feed-bay": (298, 1462, 648),
}
RUBBLE_M = 0.8


def trimmed(rgba):
    """Trimmed to the alpha with a MARGIN above and below; the sides stay flush with the pier cut."""
    ys = np.where(rgba[..., 3].any(axis=1))[0]
    y0, y1 = ys.min(), ys.max() + 1
    out = np.zeros((y1 - y0 + 2 * MARGIN, rgba.shape[1], 4), np.uint8)
    out[MARGIN : MARGIN + y1 - y0] = rgba[y0:y1]
    return out


def cut_one(path, amber=True):
    """The keyed, despeckled, trimmed RGBA of one source sheet and its red share before the shift."""
    sheet = Image.open(path).convert("RGB")
    x0, x1, base = CROP.get(path.stem, (0, sheet.width, sheet.height))
    rubble = round(RUBBLE_M * (x1 - x0) / BAY_WIDTH_M)
    sheet = sheet.crop((x0, 0, x1, min(sheet.height, base + rubble)))
    rgba = trimmed(despeckle(np.asarray(cut.key_full(sheet, WHITE, SHADOW))))
    before = red_share(rgba)
    return (amber_shift(rgba) if amber else rgba), before


def size_m(rgba):
    """The size_m [w, h] that keeps the cut's aspect at the bay width."""
    h, w = rgba.shape[:2]
    return [BAY_WIDTH_M, round(BAY_WIDTH_M * h / w, 2)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources/n29")
    parser.add_argument("--no-amber", action="store_true", help="skip the red-to-amber shift")
    args = parser.parse_args()
    for src, name in CUTS.items():
        path = args.sources / f"{src}.png"
        if not path.exists():
            print(f"{name}: no source {path.name}, skipped")
            continue
        rgba, before = cut_one(path, not args.no_amber)
        Image.fromarray(rgba).save(OUT / f"{name}.png")
        h, w = rgba.shape[:2]
        print(f"{name}: {w}x{h} size_m {size_m(rgba)}; red {before * 100:.2f}% -> {red_share(rgba) * 100:.2f}%")


if __name__ == "__main__":
    main()
