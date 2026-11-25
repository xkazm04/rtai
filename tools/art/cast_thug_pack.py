"""Cut robot thug A (hazard-striped claws): the four-drawing walk, attack, hit and fall sheets.

Reuses the gunner's cutter (cast_gunner_pack) with the thug's sources and name: every sheet is scaled by
the figure's own body height per facing to the patrol cop's drawn height and anchored on the foot line.
The fall sheets draw the body only (no loose part). Enclosed key holes (the green patch of hit_70 col 3)
are filled from the surrounding opaque colour, so the keyer cannot punch a hole into the leg.
"""
import argparse

import cv2
import numpy as np
from PIL import Image

import cast_gunner_pack as cg

SRC = cg.Path('C:/Users/kazda/kiro/gtai-art/foes-n26/thug')
PACK = cg.Path('C:/Users/kazda/kiro/gtai-art/foes-n29/thug')


def fill_holes(im):
    """Fill transparent pixels enclosed by the figure with the nearest opaque colour."""
    arr = np.array(im)
    alpha = (arr[:, :, 3] > 0).astype(np.uint8)
    pad = np.pad(alpha, 1)
    flood = pad.copy()
    cv2.floodFill(flood, np.zeros((pad.shape[0] + 2, pad.shape[1] + 2), np.uint8), (0, 0), 2)
    hole = (flood[1:-1, 1:-1] == 0)
    if hole.any():
        hole = cv2.dilate(hole.astype(np.uint8), np.ones((3, 3), np.uint8)) > 0
        hole &= True
        rgb = cv2.inpaint(np.ascontiguousarray(arr[:, :, :3]), (hole & (alpha == 0)).astype(np.uint8) * 255, 3, cv2.INPAINT_TELEA)
        arr[:, :, :3] = np.where((hole & (alpha == 0))[:, :, None], rgb, arr[:, :, :3])
        arr[:, :, 3] = np.where(hole, 255, arr[:, :, 3])
    return Image.fromarray(arr), int(hole.sum())


_sheet = cg.sheet


def sheet(path, layout, keep_props=True):
    strips = _sheet(path, layout, keep_props)
    return [[(fill_holes(im)[0], mask) for im, mask in strip] for strip in strips]


EIGHT = cg.Path('C:/Users/kazda/kiro/gtai-art/foes-n26/thug8c/out')


def source(action, pitch):
    if action == 'planted8_armed_walk':
        return [sum(sheet(EIGHT / f'thug8c_{pitch}_{f}_t3.png', (4, 4)), []) for f in cg.FACES]
    path = SRC / 'out' / f'thug_{action}_{pitch}.png'
    if action == 'hit':
        return [[d] for d in sheet(path, (5, 3))[0]]
    return sheet(path, [3 if action == 'fall' else 4] * 5, keep_props=action != 'fall')


cg.FACES = ('down', 'dr', 'right', 'ur', 'up')
cg.sheet, cg.source, cg.SRC, cg.NAME = sheet, source, PACK, 'robot_thug'


def stripe_hue(a):
    """Hazard-stripe pixels (amber, saturated, bright) of an RGBA array: (mask, hue in degrees, hsv)."""
    hsv = cv2.cvtColor(a[:, :, :3], cv2.COLOR_RGB2HSV_FULL).astype(np.float32)
    hue, sat, val = hsv[..., 0] * 360 / 256, hsv[..., 1] / 255, hsv[..., 2] / 255
    return (a[:, :, 3] >= 128) & (sat > .55) & (val > .5) & (hue >= 15) & (hue <= 65), hue, hsv


def tone_stripes(dest, pitch):
    """Shift the eight-drawing walk's stripe hue onto the four-drawing walk's median (stripes only)."""
    want = stripe_hue(np.array(Image.open(cg.VIEW / f'p{pitch}/robot_thug_armed_walk.png').convert('RGBA')))
    a = np.array(Image.open(dest).convert('RGBA'))
    mask, hue, hsv = stripe_hue(a)
    before, target = np.median(hue[mask]), np.median(want[1][want[0]])
    hsv[..., 0][mask] = (hue[mask] + target - before) * 256 / 360
    red = (a[:, :, 3] >= 128) & ((hue < 12) | (hue > 345)) & (hsv[..., 1] > 128) & (hsv[..., 2] > 89)
    hsv[..., 0][red] = 14 * 256 / 360  # rust edge pixels of the amber: never red
    a[:, :, :3] = cv2.cvtColor(np.clip(hsv, 0, 255).astype(np.uint8), cv2.COLOR_HSV2RGB_FULL)
    Image.fromarray(a).save(dest)
    print(pitch, 'stripe median before', round(before, 2), 'target', round(target, 2), 'after', round(np.median(stripe_hue(a)[1][stripe_hue(a)[0]]), 2))

if __name__ == '__main__':
    argparse.ArgumentParser(description=__doc__).parse_args()
    (PACK / 'pack').mkdir(parents=True, exist_ok=True)
    for pitch in (70, 55):
        target = cg.heights(pitch)
        for action in ('armed_walk', 'attack', 'hit', 'fall'):
            print(pitch, action, cg.pack(action, pitch, target).name)
        eight = cg.pack('planted8_armed_walk', pitch, cg.np.array(cg.shipped_heights(cg.VIEW / f'p{pitch}/robot_thug_armed_walk.png')))
        tone_stripes(eight, pitch)
