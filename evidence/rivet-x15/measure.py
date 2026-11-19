"""Measure the eight matched 300 px crops shown in the native-cut comparisons."""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image

# For each pose, x ranges containing the selected boot, and a collar ROI (x0,y0,x1,y1).
POSES = [
    ("knock", "car_knock_clip", "before", "knock", 280,
     [(95, 115, (102, 159, 178, 186)), (174, 200, (119, 132, 202, 163))]),
    ("strike", "cursor_sweep", "before", "strike", 1467,
     [(150, 173, (125, 120, 209, 167)), (80, 107, (128, 103, 194, 137))]),
    ("frames", "car_knock_clip", "knock", "frames2", 120,
     [(157, 164, (106, 124, 194, 156)), (147, 158, (116, 100, 181, 125))]),
    ("walk", "car_knock_clip", "frames2", "walk", 184,
     [(135, 166, (105, 121, 194, 164)), (135, 166, (108, 98, 193, 143))]),
]


def rgb(path):
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.int16)


def measure(image, ground, region):
    mask = np.abs(image - ground).max(axis=2) >= 24
    y, _ = np.nonzero(mask)
    left, right, (x0, y0, x1, y1) = region
    sole = np.nonzero(mask[:, left:right])[0].max()
    # Select the bright orange stripes inside the collar rectangle on the rendered frame.
    roi = Image.fromarray(image[y0:y1, x0:x1].astype(np.uint8)).convert("HSV")
    h, s, v = np.asarray(roi).transpose(2, 0, 1)
    cy, cx = np.nonzero((h > 3) & (h < 24) & (s > 190) & (v > 145))
    return int(y.max() - y.min() + 1), int(sole), np.array([cx.mean() + x0, cy.mean() + y0])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masters", type=Path)
    root = parser.parse_args().masters / "raw"
    for name, scene, before, after, tick, regions in POSES:
        for art, roi in zip(("p70", "p55"), regions):
            suffix = f"-{scene}-{art}_{tick:04d}.png"
            a, b, ground = [rgb(root / (arm + suffix)) for arm in (before, after, "matte")]
            h0, foot0, c0 = measure(a, ground, roi)
            h1, foot1, c1 = measure(b, ground, roi)
            diff = 100 * (a != b).any(axis=2).mean()
            print(f"{name} {art} t{tick}: crop {diff:.2f}%, height {h0}->{h1}, "
                  f"boot {foot0}->{foot1}, collar dx/dy {c1[0]-c0[0]:+.1f}/{c1[1]-c0[1]:+.1f}")


if __name__ == "__main__":
    main()
