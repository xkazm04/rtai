"""n7-melee: fit a Codex top-down plasma sword part to the held part's geometry (backlog item 3).

Keys the #00B140 green (weapon_cut.key), keeps the largest opaque component, scales it so the
part is `--length` px long (the old held_long's length_px, so length_m and the draw scale stay),
pads `--margin` px round it and prints the weapon_art.json numbers: size_px, length_px,
grip_px (the bore row at `--grip-u` of the length) and muzzle_px (the rightmost opaque px on the
bore row). The bore row is the blade's mid height measured at 0.75 of the length. `--icon PATH`
also writes the HUD silhouette (the part padded 8 px, weapon_cut.icon), as weapon_cut --icon does
for a side cell. Deterministic.

    python tools/art/plasma_blade_fit.py SRC DST --length 526 --grip-u 0.0894 --margin 6
    python tools/art/plasma_blade_fit.py SRC PICKUP --length 475 --margin 6 --icon ICON
"""

import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, str(Path(__file__).parent))
from weapon_cut import icon, key  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--length", type=int, default=526)
    ap.add_argument("--grip-u", type=float, default=0.10)
    ap.add_argument("--margin", type=int, default=6)
    ap.add_argument("--icon", default="")
    a = ap.parse_args()
    rgb = np.array(Image.open(a.src).convert("RGB"))
    rgb, alpha = key(rgb)
    lab, n = ndimage.label(alpha > 0)
    sizes = ndimage.sum(alpha > 0, lab, range(1, n + 1))
    keep = lab == (int(np.argmax(sizes)) + 1)
    alpha = np.where(keep, alpha, 0).astype(np.uint8)
    ys, xs = np.nonzero(alpha)
    box = (xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)
    part = Image.fromarray(np.dstack([rgb, alpha])).crop(box)
    k = a.length / part.width
    part = part.resize((a.length, max(1, round(part.height * k))), Image.LANCZOS)
    m = a.margin
    out = Image.new("RGBA", (part.width + 2 * m, part.height + 2 * m), (0, 0, 0, 0))
    out.paste(part, (m, m))
    out.save(a.dst, optimize=False)
    if a.icon:
        pad = np.zeros((out.height + 16, out.width + 16, 4), np.uint8)
        pad[8:-8, 8:-8] = np.array(out)
        Image.fromarray(icon(pad)).save(a.icon, optimize=False)
    al = np.array(out)[:, :, 3]
    col = al[:, m + round(0.75 * a.length)]
    rows = np.nonzero(col > 127)[0]
    bore = int(round((rows.min() + rows.max()) / 2))
    tip = int(np.nonzero(al[bore] > 127)[0].max())
    grip = m + round(a.grip_u * a.length)
    print(f"size_px [{out.width}, {out.height}] length_px {a.length}")
    print(f"grip_px [{grip}, {bore}] muzzle_px [{tip}, {bore}]")


if __name__ == "__main__":
    main()
