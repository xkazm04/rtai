"""d9 seams: lift the planter strips' foliage and soil values so the world print reads the leaves.

usage: python -I tools/art/planter_value_lift.py <in.png> <out.png> [leaf_gamma=0.58] [soil_gamma=0.45]

The world print (look_d4.gdshader `plates`) turns luminance into ink density, (0.93 - lum) * 1.25,
and steps it into paper / light / mid / dark washes. planter_v3's leaves sit at lum 0.46 (p90
0.58) and its brown soil at 0.20, so at 32 px/m leaves, soil and the concrete rim all print in the
mid and dark washes: one dark block (v2's leaves had highlights to 0.64 and almost no soil).
This raises the value (HSV V) of the foliage (hue 55-160 deg) by V ** leaf_gamma and of the soil
(hue 5-55 deg) by V ** soil_gamma, hue kept; pixels fade in over saturation
0.15-0.25 and value 0.10-0.20, so the drawn ink lines, the grey concrete and the ink outline stay.
The lifted soil keeps SOIL_CHROMA of its chroma (a lifted brown turns orange, and the print's
vermilion plate, reserved for danger marks, starts at density 0.26): the tool fails if any opaque
pixel's vermilion density (the shader's formula) exceeds VERM_MAX. Alpha unchanged. Prints each class's mean luminance before and after.
Deterministic. d9 strips: p55 from city_prop_cut.py's planter_v3 cut, p70 from n8's; both at the defaults.
"""

import sys

import numpy as np
from PIL import Image

LUMA = np.array([0.299, 0.587, 0.114])
SOIL_CHROMA = 0.5
VERM_MAX = 0.2


def _smooth(lo: float, hi: float, x: np.ndarray) -> np.ndarray:
    t = np.clip((x - lo) / (hi - lo), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def lift(rgba: np.ndarray, leaf_gamma: float, soil_gamma: float) -> tuple:
    rgb = rgba[..., :3]
    mx = rgb.max(-1)
    mn = rgb.min(-1)
    s = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0.0)
    hsv = np.asarray(Image.fromarray((rgb * 255).round().astype(np.uint8)).convert("HSV"))
    h = hsv[..., 0].astype(float) / 255.0 * 360.0
    w = _smooth(0.15, 0.25, s) * _smooth(0.10, 0.20, mx) * (rgba[..., 3] > 0.0)
    leaf = ((h > 55.0) & (h < 160.0)) * w
    soil = ((h > 5.0) & (h <= 55.0)) * w
    gamma = np.where(leaf > 0, leaf_gamma, np.where(soil > 0, soil_gamma, 1.0))
    weight = np.maximum(leaf, soil)
    v_new = np.power(np.maximum(mx, 1e-6), gamma)
    k = 1.0 + (v_new / np.maximum(mx, 1e-6) - 1.0) * weight
    lifted = rgb * k[..., None]
    grey = (lifted @ LUMA)[..., None]
    chroma = 1.0 - (1.0 - SOIL_CHROMA) * soil[..., None]
    out = rgba.copy()
    out[..., :3] = np.clip(grey + (lifted - grey) * chroma, 0.0, 1.0)
    return out, leaf > 0.5, soil > 0.5


def verm_density(rgba: np.ndarray) -> float:
    c = rgba[..., :3][rgba[..., 3] > 0.5]
    return float(np.clip((c[:, 0] - c[:, 1:].max(-1) - 0.12) * 2.6, 0.0, 1.0).max())


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src = np.asarray(Image.open(sys.argv[1]).convert("RGBA")).astype(float) / 255.0
    leaf_gamma = float(sys.argv[3]) if len(sys.argv) > 3 else 0.58
    soil_gamma = float(sys.argv[4]) if len(sys.argv) > 4 else 0.45
    out, leaf, soil = lift(src, leaf_gamma, soil_gamma)
    for name, m in (("leaf", leaf), ("soil", soil)):
        before = (src[..., :3][m] @ LUMA).mean() if m.any() else 0.0
        after = (out[..., :3][m] @ LUMA).mean() if m.any() else 0.0
        print("%s px %d lum %.3f -> %.3f" % (name, int(m.sum()), before, after))
    verm = verm_density(out)
    print("vermilion density max %.3f (limit %.2f)" % (verm, VERM_MAX))
    if verm > VERM_MAX:
        sys.exit("FAIL: the lift would print vermilion; lower soil_gamma's lift")
    Image.fromarray((out * 255.0).round().astype(np.uint8), "RGBA").save(sys.argv[2])


if __name__ == "__main__":
    main()
