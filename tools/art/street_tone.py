"""n8 street: match a strip's uniform blue to a reference card's (the cop-tone default, `navy`).

usage: python -I tools/art/street_tone.py <in.png> <ref.png> <out.png>

A library walk strip drawn from another sheet carries its own blue (cop_patrol_walk_70: a lighter
slate, _55: royal); the standing card it walks beside is the navy-fixed cop_patrol sheet. Every
blue pixel of <in> (hue 190-250 deg, saturation > 0.2, value > 0.08, alpha > 0) is moved so the
blue pixels' mean hue, saturation and value equal <ref>'s: hue shifted, saturation and value
scaled (shading kept). Every other pixel (skin, belt, boots, ink) is untouched. Deterministic.
"""

import sys

import numpy as np
from PIL import Image


def _hsv(path: str):
    img = Image.open(path).convert("RGBA")
    rgba = np.asarray(img).astype(np.float64) / 255.0
    hsv = np.asarray(img.convert("RGB").convert("HSV")).astype(np.float64) / 255.0
    h, s, v = hsv[..., 0] * 360.0, hsv[..., 1], hsv[..., 2]
    mask = (h > 190.0) & (h < 250.0) & (s > 0.2) & (v > 0.08) & (rgba[..., 3] > 0.5)
    return img, h, s, v, mask


def main() -> None:
    src, h, s, v, m = _hsv(sys.argv[1])
    _, rh, rs, rv, rm = _hsv(sys.argv[2])
    dh = rh[rm].mean() - h[m].mean()
    ks = rs[rm].mean() / s[m].mean()
    kv = rv[rm].mean() / v[m].mean()
    print(f"blue px {m.sum()}: hue {dh:+.1f} deg, sat x{ks:.2f}, value x{kv:.2f}")
    h2 = np.where(m, (h + dh) % 360.0, h) / 360.0
    s2 = np.where(m, np.clip(s * ks, 0.0, 1.0), s)
    v2 = np.where(m, np.clip(v * kv, 0.0, 1.0), v)
    hsv = (np.stack([h2, s2, v2], axis=-1) * 255.0).round().astype(np.uint8)
    rgb = np.asarray(Image.fromarray(hsv, "HSV").convert("RGB"))
    out = np.asarray(src).copy()
    out[..., :3] = np.where(m[..., None], rgb, out[..., :3])
    Image.fromarray(out, "RGBA").save(sys.argv[3])


if __name__ == "__main__":
    main()
