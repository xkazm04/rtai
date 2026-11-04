"""n5-look: the plasma sword's blade 20 % longer (target r2_w1_plasma_sword_longer; owner round 2).

Stretches only the straight blade section of the held part along +x (nearest-neighbour, so the
ink outline and the speckle keep their pixel size), leaving the hilt and the tip as drawn, and
writes a new PNG beside the old one. Deterministic. Prints the new canvas width, length_px and
muzzle x for weapon_art.json.

    python tools/art/blade_longer.py SRC DST --blade-from 225 --blade-to 455 --tip 480 --k 1.2 --blade-start 218
"""

import argparse

from PIL import Image


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--blade-start", type=int, required=True, help="x where the blade leaves the guard")
    ap.add_argument("--blade-from", type=int, required=True, help="start of the straight section")
    ap.add_argument("--blade-to", type=int, required=True, help="end of the straight section")
    ap.add_argument("--tip", type=int, required=True, help="x of the blade tip")
    ap.add_argument("--k", type=float, default=1.2, help="blade length factor")
    a = ap.parse_args()
    im = Image.open(a.src).convert("RGBA")
    add = round((a.tip - a.blade_start) * (a.k - 1.0))
    mid = im.crop((a.blade_from, 0, a.blade_to, im.height))
    mid = mid.resize((mid.width + add, im.height), Image.NEAREST)
    out = Image.new("RGBA", (im.width + add, im.height), (0, 0, 0, 0))
    out.paste(im.crop((0, 0, a.blade_from, im.height)), (0, 0))
    out.paste(mid, (a.blade_from, 0))
    out.paste(im.crop((a.blade_to, 0, im.width, im.height)), (a.blade_to + add, 0))
    out.save(a.dst, optimize=False)
    print(f"width {out.width} add {add} tip_x {a.tip + add}")


if __name__ == "__main__":
    main()
