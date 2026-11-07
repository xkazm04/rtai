"""d9 seams: grey out a strip's warm armband (vermilion is reserved for danger marks, objectives,
Rivet's collar and the King's cape; the riot cop's library walk sheets draw an orange band).

usage: python -I tools/art/street_armband.py <in.png> <out.png>

Every opaque pixel with hue under 40 deg, saturation over 0.5 and value over 0.4 (the band; skin
is under 0.5 saturation on these sheets) keeps its value and loses its hue: saturation 0.06, a
cool grey like the visor's steel. Every other pixel is untouched. Deterministic.
"""

import sys

import numpy as np
from PIL import Image


def main() -> None:
    img = Image.open(sys.argv[1]).convert("RGBA")
    rgba = np.asarray(img).copy()
    hsv = np.asarray(img.convert("RGB").convert("HSV")).astype(np.float64)
    h, s, v = hsv[..., 0] * 360.0 / 255.0, hsv[..., 1] / 255.0, hsv[..., 2] / 255.0
    m = (rgba[..., 3] > 128) & (h < 40.0) & (s > 0.5) & (v > 0.4)
    print(f"band px {int(m.sum())}")
    grey = np.stack([np.full_like(h, 215.0 / 360.0), np.full_like(s, 0.06), v * 0.85], axis=-1)
    rgb = np.asarray(Image.fromarray((grey * 255.0).round().astype(np.uint8), "HSV").convert("RGB"))
    rgba[..., :3] = np.where(m[..., None], rgb, rgba[..., :3])
    Image.fromarray(rgba, "RGBA").save(sys.argv[2])


if __name__ == "__main__":
    main()
