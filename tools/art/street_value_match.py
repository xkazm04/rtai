"""n8 street: tone a ped's fall grid to the identity its still and walk wear, by value.

usage: python -I tools/art/street_value_match.py <ref_walk.png> <src_grid.png> <out.png> [sat=0.47]

The library's v3 identity sheets changed a ped's cloth value (ped_cap_70_v3: the taupe hoodie
became oatmeal) after its fall grid was drawn. This maps the value distribution of the source
grid's low-saturation pixels (cloth, ink, cap, jeans: saturation under `sat`) onto the reference
walk strip's by quantile matching (101 quantiles), scaling each pixel's RGB by new / old value so
hue and saturation stay; the lifted pixels lose up to 15 % saturation (oatmeal is paler than the
lifted taupe). Skin (saturation over sat + 0.05) is untouched, blended over 0.1 of saturation.
Alpha unchanged. Raw art. Deterministic.
"""

import sys

import numpy as np
from PIL import Image


def _hsv(a: np.ndarray) -> tuple:
    rgb = a[..., :3]
    mx = rgb.max(-1)
    mn = rgb.min(-1)
    return mx, np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)


def main() -> None:
    ref = np.asarray(Image.open(sys.argv[1]).convert("RGBA")).astype(float) / 255
    src = np.asarray(Image.open(sys.argv[2]).convert("RGBA")).astype(float) / 255
    sat = float(sys.argv[4]) if len(sys.argv) > 4 else 0.47
    rv, rs = _hsv(ref)
    sv, ss = _hsv(src)
    rm = (ref[..., 3] > 0.9) & (rs < sat)
    sm = (src[..., 3] > 0.5) & (ss < sat)
    q = np.linspace(0, 1, 101)
    rq = np.quantile(rv[rm], q)
    sq = np.quantile(sv[sm], q)
    newv = np.interp(sv, sq, rq)
    w = np.clip((sat + 0.05 - ss) / 0.1, 0, 1)
    g = np.where(sv > 1e-3, newv / np.maximum(sv, 1e-3), 1.0)
    g = 1 + (g - 1) * w
    rgb = src[..., :3] * g[..., None]
    lift = np.clip((g - 1.1) / 0.3, 0, 1)[..., None] * 0.15
    grey = rgb.mean(-1, keepdims=True)
    out = src.copy()
    out[..., :3] = np.clip(rgb + (grey - rgb) * lift, 0, 1)
    Image.fromarray((out * 255 + 0.5).astype(np.uint8)).save(sys.argv[3])
    print("value quantiles src", np.round(sq[::10], 2), "ref", np.round(rq[::10], 2))


if __name__ == "__main__":
    main()
