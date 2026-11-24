"""Hat (mean HSV of the cap above the face) and vest hue of every contractor sheet, plus red/teal/vermilion counts.

Hat mask: the top 13 % of each drawing's body box (the 8-drawing and walk cells; hat pieces in the fall are
whole components), alpha >= 128, ink (max RGB < 60) excluded. Vest: yellow-leaning bright pixels (hue 35 to 80
deg, saturation > .45, value > .55). Pass: hat saturation <= .12 and value >= .78; vest hue 50 to 62 deg.
"""
import colorsys
import sys
from pathlib import Path

import numpy as np
from PIL import Image

VIEW = Path('project/features/characters/art/view')


def hsv(px):
    m = px.mean(axis=0) / 255
    return colorsys.rgb_to_hsv(*m)


def hat_and_vest(path, rows):
    a = np.asarray(Image.open(path).convert('RGBA'))
    h, w = a.shape[0] // rows, a.shape[1] // 5
    hat, vest = [], []
    for r in range(rows):
        for c in range(5):
            t = a[r * h:(r + 1) * h, c * w:(c + 1) * w]
            solid = t[..., 3] >= 128
            ys = np.where(solid.any(axis=1))[0]
            if not len(ys):
                continue
            top, bot = ys[0], ys[-1]
            cap = solid.copy()
            cap[int(top + .13 * (bot - top)):] = False
            px = t[cap][:, :3].astype(float)
            hat.append(px[px.max(axis=1) >= 60])
            p = t[solid][:, :3].astype(float) / 255
            mx, mn = p.max(axis=1), p.min(axis=1)
            sat = (mx - mn) / np.maximum(mx, 1e-6)
            hue = np.array([colorsys.rgb_to_hsv(*q)[0] * 360 for q in p[::5]])
            ok = (hue >= 35) & (hue <= 80) & (sat[::5] > .45) & (mx[::5] > .55)
            vest.append(hue[ok])
    hat = np.concatenate(hat)
    return hsv(hat), len(hat), np.median(np.concatenate(vest)), np.concatenate(vest)


def counts(path):
    a = np.asarray(Image.open(path).convert('RGBA'), dtype=np.float32)
    px = a[a[..., 3] > 127][:, :3] / 255
    r, g, b = px.T
    hue = np.array([colorsys.rgb_to_hsv(*p)[0] * 360 for p in px[::7]])
    mx, mn = px.max(axis=1)[::7], px.min(axis=1)[::7]
    sat = (mx - mn) / np.maximum(mx, 1e-6)
    return (int(((r > .47) & (g < .24) & (b < .24)).sum()),
            int(((hue >= 165) & (hue <= 195) & (sat > .4) & (mx > .3)).sum() * 7),
            int(((hue >= 5) & (hue <= 20) & (sat > .75) & (mx > .6)).sum() * 7),
            int(((hue < 45) & (hue >= 20) & (sat > .6) & (mx > .5)).sum() * 7))


if __name__ == '__main__':
    for pitch in (70, 55):
        for name, rows in (('armed_walk', 4), ('planted8_armed_walk', 8), ('attack', 4), ('cast_hit', 1)):
            path = VIEW / f'p{pitch}/contractor_{name}.png'
            (hh, hs, hv), n, vh, v = hat_and_vest(path, rows)
            red, teal, verm, amber = counts(path)
            print(f'{pitch} {name:20s} hat n={n:6d} H {hh * 360:5.1f} S {hs:.3f} V {hv:.3f}  vest hue median {vh:5.1f} '
                  f'(<45: {np.mean(v < 45):.1%})  red {red} teal~{teal} vermilion~{verm} amber-orange~{amber}')
        for name in ('cast_hit', 'cast_fall'):
            red, teal, verm, amber = counts(VIEW / f'p{pitch}/contractor_{name}.png')
            print(f'{pitch} {name:20s} red {red} teal~{teal} vermilion~{verm} amber-orange~{amber}')
    print('cut check (opaque px, alpha >= 128, 50-level channel lead): green / magenta')
    for path in sorted(VIEW.glob('p*/contractor_*.png')):
        if path.stem in ('contractor_card', 'contractor_fall', 'contractor_hit'):
            continue
        r, g, b, al = np.asarray(Image.open(path).convert('RGBA'), dtype=int).transpose(2, 0, 1)
        solid = al >= 128
        print(f'  {path.parent.name}/{path.name:36s} {Image.open(path).size} '
              f'{int((solid & (g - np.maximum(r, b) > 50)).sum())} / {int((solid & (np.minimum(r, b) - g > 50)).sum())}')
