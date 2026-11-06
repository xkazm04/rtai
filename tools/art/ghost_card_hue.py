"""d8 chars: palette guard for a ghost card strip (colour rules: red is blood only, teal is the souls').

usage: python -I tools/art/ghost_card_hue.py <in.png> <out.png> [--debug=<png>]

A generated sheet can carry hues the game reserves: Ohm's 55 body sheet tips its cable beard in red
and violet, and the despilled wisps keep a violet fringe. On every opaque, saturated pixel:
  - red (hue 330..15 deg) -> copper (hue 24 deg, the welder's electrodes), value kept;
  - violet / blue-violet (hue 235..330 deg) -> soul teal (hue 174 deg), value kept.
Rust (hue 15..45) and the plating's greys are untouched. --debug writes the changed pixels in white
on black. Deterministic. Prints the counts.
"""

import sys

import numpy as np
from PIL import Image

COPPER_H = 24.0 / 360.0
TEAL_H = 174.0 / 360.0


def rgb_to_hsv(a: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    mx = a.max(axis=2)
    mn = a.min(axis=2)
    d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-6), 0.0)
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    dd = np.maximum(d, 1e-6)
    h = np.where(mx == r, ((g - b) / dd) % 6.0, np.where(mx == g, (b - r) / dd + 2.0, (r - g) / dd + 4.0))
    return (h / 6.0) % 1.0, s, mx


def hsv_to_rgb(h: np.ndarray, s: np.ndarray, v: np.ndarray) -> np.ndarray:
    i = np.floor(h * 6.0).astype(int) % 6
    f = h * 6.0 - np.floor(h * 6.0)
    p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    choices = [(v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q)]
    out = np.zeros(h.shape + (3,), dtype=np.float32)
    for k, (r, g, b) in enumerate(choices):
        m = i == k
        out[m] = np.stack([r[m], g[m], b[m]], axis=1)
    return out


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    debug = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--debug=")), "")
    img = np.asarray(Image.open(args[0]).convert("RGBA"), dtype=np.float32) / 255.0
    h, s, v = rgb_to_hsv(img[:, :, :3])
    live = (img[:, :, 3] > 0.05) & (v > 0.18)
    deg = h * 360.0
    red = live & (s > 0.35) & ((deg >= 330.0) | (deg < 15.0))
    violet = live & (s > 0.2) & (deg >= 235.0) & (deg < 330.0)
    h2 = h.copy()
    h2[red] = COPPER_H
    h2[violet] = TEAL_H
    rgb = hsv_to_rgb(h2, s, v)
    out = img.copy()
    m = red | violet
    out[m, :3] = rgb[m]
    Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)).save(args[1])
    if debug:
        Image.fromarray((m * 255).astype(np.uint8)).save(debug)
    print(f"red->copper {int(red.sum())} px, violet->teal {int(violet.sum())} px")


if __name__ == "__main__":
    main()
