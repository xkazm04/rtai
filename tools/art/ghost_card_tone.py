"""d8 chars: print a ghost card strip cut from an angle sheet to the ghost's in-game part tones.

usage: python -I tools/art/ghost_card_tone.py <card.png> <part.png> <out.png> [hue_lo=135] [hue_hi=175]
       [dark=100]

The 55 sheets draw Dent all teal-steel; in game his plating is a tan crash dummy and teal is only his
soul (the cracks and the wisps: the colour law). Every card pixel whose hue lies in [hue_lo, hue_hi)
(the sheet's body teal-green, not the cyan wisps, not the yellow target discs, not the ink) takes the
colour of the in-game part's plating pixel at the same luminance quantile (the part's own yellow and
ink excluded), so the card's light and shade keep their order and land on the part's palette. The
wisps (cyan, hue >= hue_hi) stay teal. Body pixels darker than `dark` (luminance 0-255: the target
discs' black quarters, the visor, the strap, the seams) turn a warm grey of their own luminance, as
the part draws its strap and visor. Deterministic.
"""

import sys

import numpy as np
from PIL import Image


def hue_sat(rgb: np.ndarray) -> tuple:
    mx, mn = rgb.max(axis=-1), rgb.min(axis=-1)
    d = np.where(mx - mn == 0, 1e-6, mx - mn)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4))
    return h * 60.0, (mx - mn) / np.maximum(mx, 1e-6)


def lum(rgb: np.ndarray) -> np.ndarray:
    return rgb @ np.array([0.299, 0.587, 0.114])


def main() -> None:
    card, part, dst = sys.argv[1], sys.argv[2], sys.argv[3]
    lo = float(sys.argv[4]) if len(sys.argv) > 4 else 135.0
    hi = float(sys.argv[5]) if len(sys.argv) > 5 else 175.0
    dark = float(sys.argv[6]) if len(sys.argv) > 6 else 100.0
    c = np.asarray(Image.open(card).convert("RGBA")).astype(np.float64)
    p = np.asarray(Image.open(part).convert("RGBA")).astype(np.float64)
    ph, ps = hue_sat(p[..., :3])
    pl = lum(p[..., :3])
    plate = (p[..., 3] > 200) & (pl > 40) & ~((ph > 30) & (ph < 70) & (ps > 0.5)) & ~((ph > 150) & (ph < 200) & (ps > 0.4))
    ramp = p[plate][:, :3]
    ramp = ramp[np.argsort(lum(ramp), kind="stable")]
    ch, cs = hue_sat(c[..., :3])
    body = (c[..., 3] > 0) & (ch >= lo) & (ch < hi) & (cs > 0.15)
    cl = lum(c[..., :3])
    shade = body & (cl < dark)
    body &= ~shade
    vals = cl[body]
    q = np.argsort(np.argsort(vals, kind="stable"), kind="stable") / max(len(vals) - 1, 1)
    out = c.copy()
    out[body, :3] = ramp[np.round(q * (len(ramp) - 1)).astype(int)]
    g = cl[shade] * 0.8
    out[shade, :3] = np.stack([g * 1.06, g, g * 0.92], axis=-1)
    Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(dst)
    print(f"{dst}: {int(body.sum())} plating px printed from {len(ramp)} part px")


if __name__ == "__main__":
    main()
