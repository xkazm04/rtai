"""Palette counts on opaque pixels of every shipped robot thug sheet (n29 checklist).

Strict red (outside the lens), teal (hue 160-200, S >= 0.35, V >= 0.35), vermilion, navy, amber.
Also reports where each non-zero cluster sits (bounding box per sheet) so it can be looked at.
"""
import colorsys
import sys
from pathlib import Path

import numpy as np
from PIL import Image

VIEW = Path('project/features/characters/art/view')
OUT = Path('build/look/n29-thug/partb')


def hsv(px):
    mx, mn = px.max(axis=1), px.min(axis=1)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = px[:, 0], px[:, 1], px[:, 2]
    d = np.maximum(mx - mn, 1e-6)
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    return h, sat, mx


def masks(a):
    px = a[..., :3] / 255
    flat = px.reshape(-1, 3)
    h, s, v = hsv(flat)
    r, g, b = flat.T
    h, s, v = h.reshape(px.shape[:2]), s.reshape(px.shape[:2]), v.reshape(px.shape[:2])
    r, g, b = r.reshape(h.shape), g.reshape(h.shape), b.reshape(h.shape)
    return {
        'red': (r > .47) & (g < .24) & (b < .24),
        'teal': (h >= 160) & (h <= 200) & (s >= .35) & (v >= .35),
        'verm': (h >= 5) & (h <= 20) & (s > .75) & (v > .6),
        'navy': (h >= 190) & (h <= 250) & (s > .2) & (v > .08),
        'amber': (h >= 35) & (h <= 50) & (s > .6) & (v > .6),
    }


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rows = []
    for pitch in (70, 55):
        for path in sorted((VIEW / f'p{pitch}').glob('*thug*.png')):
            a = np.asarray(Image.open(path).convert('RGBA'), dtype=np.float32)
            solid = a[..., 3] > 127
            n = int(solid.sum())
            m = {k: v & solid for k, v in masks(a).items()}
            parts = [f'{k} {int(v.sum())}' for k, v in m.items()]
            box = {}
            for k, v in m.items():
                ys, xs = np.nonzero(v)
                if k in ('red', 'teal', 'verm', 'amber') and len(ys):
                    box[k] = (int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max()))
            print(f'{pitch} {path.name:42s} solid {n:7d} ' + ' '.join(parts), box if box else '')
            rows.append((pitch, path.name, n, {k: int(v.sum()) for k, v in m.items()}))
            if any(m[k].sum() for k in ('teal', 'verm')):
                img = a.copy()
                for k in ('teal', 'verm'):
                    img[m[k]] = (255, 0, 255, 255)
                Image.fromarray(img.astype(np.uint8)).save(OUT / f'pal_{pitch}_{path.stem}.png')
    return rows


if __name__ == '__main__':
    sys.exit(0 if main() is not None else 1)
