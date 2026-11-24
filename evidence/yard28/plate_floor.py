"""Plate floor sample: patches of bare concrete in the plate and their mean sRGB, L*, hue, chroma.
python -W ignore -I evidence/yard28/plate_floor.py [overlay.png]"""
import sys
import numpy as np
from PIL import Image, ImageDraw
PLATE = "C:/Users/kazda/kiro/gtai-art/factory-n25/out/a-torn-line.png"
# (name, cx, cy, half) in plate pixels: bare floor, away from paint lines, stains, tyre marks, fire glow
PATCHES = [("yard left", 450, 545, 14), ("yard centre", 560, 590, 14), ("yard centre-right", 800, 520, 14), ("yard mid-back", 700, 480, 10), ("yard below forklift", 760, 640, 12),
           ("panel right", 1590, 520, 14), ("panel lower", 1560, 780, 14), ("panel mid", 1640, 440, 8)]
def lab(rgb):
    c = rgb / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]])
    xyz = c @ m.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 216 / 24389, np.cbrt(xyz), (24389 / 27 * xyz + 16) / 116)
    return 116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])
def sample(img, cx, cy, h):
    p = np.asarray(img.convert("RGB"), dtype=float)[cy - h:cy + h, cx - h:cx + h].reshape(-1, 3)
    return p
if __name__ == "__main__":
    img = Image.open(PLATE); ov = img.convert("RGB"); d = ImageDraw.Draw(ov)
    rows = []
    for n, x, y, h in PATCHES:
        p = sample(img, x, y, h); L, a, b = lab(p)
        rows.append((n, p.mean(0), L.mean(), np.hypot(a.mean(), b.mean()), np.degrees(np.arctan2(b.mean(), a.mean())) % 360))
        d.rectangle([x - h, y - h, x + h, y + h], outline=(0, 255, 0), width=2)
    for n, rgb, L, C, H in rows:
        print(f"{n:18s} sRGB {rgb[0]:.0f},{rgb[1]:.0f},{rgb[2]:.0f}  L* {L:.1f}  C* {C:.1f}  hue {H:.1f}")
    L = np.mean([r[2] for r in rows]); C = np.mean([r[3] for r in rows]); H = np.mean([r[4] for r in rows])
    rgb = np.mean([r[1] for r in rows], 0)
    print(f"MEAN of {len(rows)}: sRGB {rgb[0]:.0f},{rgb[1]:.0f},{rgb[2]:.0f}  L* {L:.1f}  C* {C:.1f}  hue {H:.1f}  (L* sd {np.std([r[2] for r in rows]):.1f})")
    if len(sys.argv) > 1: ov.save(sys.argv[1])
