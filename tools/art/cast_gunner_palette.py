"""Palette counts on opaque pixels of every robot gunner sheet: navy plates, red, teal, vermilion."""
import colorsys
from pathlib import Path

import numpy as np
from PIL import Image

VIEW = Path('project/features/characters/art/view')


def counts(path):
    a = np.asarray(Image.open(path).convert('RGBA'), dtype=np.float32)
    solid = a[..., 3] > 127
    px = a[solid][:, :3] / 255
    mx, mn = px.max(axis=1), px.min(axis=1)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = px.T
    hue = np.array([colorsys.rgb_to_hsv(*p)[0] * 360 for p in px[::7]])
    s7, v7 = sat[::7], mx[::7]
    navy = ((hue >= 190) & (hue <= 250) & (s7 > .2) & (v7 > .08)).sum() * 7
    red = ((r > .47) & (g < .24) & (b < .24)).sum()
    teal = ((hue >= 165) & (hue <= 195) & (s7 > .4) & (v7 > .3)).sum() * 7
    verm = ((hue >= 5) & (hue <= 20) & (s7 > .75) & (v7 > .6)).sum() * 7
    return len(px), int(navy), int(red), int(teal), int(verm)


if __name__ == '__main__':
    for pitch in (70, 55):
        for path in sorted((VIEW / f'p{pitch}').glob('robot_gunner_*.png')):
            n, navy, red, teal, verm = counts(path)
            print(f'{pitch} {path.name:42s} solid {n:7d} navy {navy / n:6.1%} red {red} teal~{teal} vermilion~{verm}')
