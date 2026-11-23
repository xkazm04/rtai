"""Boot windows in percent of the opaque figure width, contact/pass/contact/pass.

Inspect the drawings in game order. Windows isolate the weight-bearing shoe from
the swing shoe, gun and shield. They follow the figure when a cutter translates it.
Only the alpha outline inside the window supplies the measured point.
"""
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / 'project/features/characters/art/view'
# Within each row pair, keep the foot which landed, including the partly
# occluded shoe in a passing pose. Front and back columns also drive the cutter.
ARMED = {
    70: [
        [(42, 77), (50, 79), (12, 49), (15, 49)],
        [(41, 88), (49, 71), (0, 29), (14, 49)],
        [(48, 88), (39, 55), (44, 83), (8, 43)],
        [(37, 76), (30, 58), (0, 32), (8, 30)],
        [(38, 77), (50, 82), (18, 52), (17, 48)],
    ],
    55: [
        [(38, 78), (51, 76), (19, 55), (23, 49)],
        [(47, 94), (48, 69), (0, 38), (20, 49)],
        [(52, 98), (39, 59), (52, 97), (8, 44)],
        [(41, 77), (31, 68), (0, 33), (12, 32)],
        [(42, 78), (50, 78), (14, 49), (14, 48)],
    ],
}
UNARMED = {
    70: [
        [(40, 80), (50, 74), (22, 55), (23, 49)],
        [(52, 97), (51, 80), (0, 39), (21, 53)],
        [(58, 100), (55, 80), (57, 100), (9, 57)],
        [(40, 82), (31, 77), (0, 50), (12, 32)],
        [(39, 75), (50, 78), (16, 48), (20, 49)],
    ],
    55: [
        [(41, 78), (50, 72), (21, 53), (22, 49)],
        [(53, 97), (54, 75), (0, 37), (29, 56)],
        [(58, 100), (57, 80), (58, 100), (11, 59)],
        [(50, 85), (40, 82), (14, 48), (20, 42)],
        [(43, 78), (51, 76), (20, 49), (23, 50)],
    ],
}
# Direction order here is down-right, right. The slab occludes a supporting
# boot in the three-quarter sequence, so that whole-contact gate stays open.
OTHERS = {
    'sergeant_mulroney': {
        70: [[(42, 71), (39, 57), (0, 24), (17, 43)],
             [(49, 80), (17, 43), (49, 81), (17, 43)]],
        55: [[(46, 77), (21, 44), (34, 66), (25, 43)],
             [(52, 92), (13, 44), (47, 84), (11, 45)]],
    },
    'cop_riot': {
        70: [[(45, 82), (49, 67), (39, 74), (22, 51)],
             [(58, 100), (53, 68), (59, 100), (18, 57)]],
        55: [[(48, 84), (49, 67), (5, 36), (21, 53)],
             [(58, 100), (54, 76), (57, 100), (23, 59)]],
    },
    'swat': {
        70: [[(43, 84), (45, 69), (0, 26), (17, 47)],
             [(50, 94), (39, 61), (45, 86), (9, 47)]],
        55: [[(47, 95), (51, 75), (54, 100), (20, 52)],
             [(55, 100), (41, 63), (48, 93), (4, 48)]],
    },
    'rocket_trooper': {
        70: [[(39, 66), (40, 58), (51, 78), (39, 57)],
             [(47, 75), (37, 51), (46, 76), (33, 52)]],
        55: [[(38, 65), (36, 52), (39, 66), (36, 53)],
             [(44, 72), (31, 51), (43, 72), (32, 52)]],
    },
    'shield_robot': {
        70: [None, [(47, 79), (49, 69), (49, 79), (16, 68)]],
        55: [None, [(41, 77), (43, 62), (47, 78), (18, 61)]],
    },
}


def bounds(mask):
    ys, xs = np.nonzero(mask)
    if not len(xs):
        raise ValueError('no alpha >128 in cell')
    return int(xs.min()), int(ys.min()), int(xs.max()+1), int(ys.max()+1)


def band(mask, limits=(0, 100)):
    x, y, right, bottom = bounds(mask)
    left = x + round((right-x)*limits[0]/100)
    stop = x + round((right-x)*limits[1]/100)
    ys, xs = np.nonzero(mask[:, left:stop])
    if not len(xs):
        raise ValueError('empty boot window')
    # Same bottom 5% band as foot_slide.sole_x, restricted to the support
    # boot. The second coordinate is the actual lowest opaque pixel centre.
    low = ys.max()
    xs = xs[ys >= low-max(1, round((bottom-y-1)*.05))]
    return np.array([left+(xs.min()+xs.max()+1)/2, low+.5])


def body_point(mask):
    x, y, right, bottom = bounds(mask)
    # Midpoint of the upper-body outline at 30% of standing height.
    height = y + round((bottom-y-1)*.30)
    xs = np.flatnonzero(mask[height])
    return np.array([(xs[0]+xs[-1]+1)/2, height+.5])


def window(name, pitch, facing, row):
    if name in ('cop_patrol_armed_walk', 'cop_patrol_walk'):
        table = ARMED if 'armed' in name else UNARMED
        return table[pitch][facing][row]
    key = name.removesuffix('_armed_walk')
    if key not in OTHERS or facing not in (1, 2):
        raise ValueError(f'unregistered boot in {name}, column {facing}')
    windows = OTHERS[key][pitch][facing-1]
    if windows is None:
        raise ValueError('support sole is hidden behind the slab during the down-right contact')
    return windows[row]


@lru_cache(maxsize=128)
def alpha(path):
    with Image.open(ROOT / 'project' / path.removeprefix('res://')) as im:
        return np.asarray(im.convert('RGBA'))[:, :, 3] > 128


def cell(path, rect):
    x, y, w, h = rect
    return alpha(path)[y:y+h, x:x+w]


def project(sprite, point):
    ox, oy, xx, xy, yx, yy = sprite['xf']
    u, v = point
    return np.array([ox+xx*u+yx*v, oy+xy*u+yy*v])


@lru_cache(maxsize=512)
def registered(path, rect, col, row):
    mask = cell(path, rect)
    name = Path(path).stem.replace('_planted_', '_')
    pitch = int(Path(path).parent.name[1:])
    return band(mask, window(name, pitch, col, row))
