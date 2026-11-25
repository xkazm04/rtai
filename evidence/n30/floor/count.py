"""Counts per still in the blast floor box. python -I count.py <dir> [<dir2>]"""
import sys, colorsys
import numpy as np
from PIL import Image
BOX = {68: (860, 340, 1340, 760), 70: (860, 340, 1340, 760), 72: (860, 340, 1340, 760),
       484: (380, 0, 1880, 1080), 486: (380, 0, 1880, 1080)}
DISC = (1095, 405, 460)  # the nuke light (t478-513) and a margin: excluded at 484/486
HUD = (0, 860, 450, 1080)
def mask(t, shape):
    ys, xs = np.mgrid[0:shape[0], 0:shape[1]]
    x0, y0, x1, y1 = BOX[t]
    m = (xs >= x0) & (xs < x1) & (ys >= y0) & (ys < y1)
    m &= ~((xs >= HUD[0]) & (xs < HUD[2]) & (ys >= HUD[1]) & (ys < HUD[3]))
    if t >= 478:
        m &= np.hypot(xs - DISC[0], ys - DISC[1]) > DISC[2]
    return m
def counts(a, m):
    f = a.astype(float) / 255
    r, g, b = f[..., 0], f[..., 1], f[..., 2]
    verm = (r - np.maximum(g, b)) >= 0.31
    red = (a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90)
    mx, mn = f.max(-1), f.min(-1)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    d = np.maximum(mx - mn, 1e-6)
    hue = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    amber = (hue >= 25) & (hue <= 50) & (sat >= 0.45) & (mx > mn)
    teal = (np.minimum(g, b) - r) >= 0.26
    return [int((x & m).sum()) for x in (verm, red, amber, teal)]
def main():
    dirs = sys.argv[1:]
    print('tick | ' + ' | '.join('%s verm/red/amber/teal' % d.split('/')[-1] for d in dirs) + (' | px changed in box / outside' if len(dirs) == 2 else ''))
    for t in sorted(BOX):
        arrs = [np.asarray(Image.open('%s/t%d.png' % (d, t)).convert('RGB')) for d in dirs]
        m = mask(t, arrs[0].shape)
        row = ['/'.join(map(str, counts(a, m))) for a in arrs]
        if len(arrs) == 2:
            diff = np.abs(arrs[0].astype(int) - arrs[1].astype(int)).max(-1) > 0
            x0, y0, x1, y1 = BOX[t]
            ys, xs = np.mgrid[0:diff.shape[0], 0:diff.shape[1]]
            inbox = (xs >= x0) & (xs < x1) & (ys >= y0) & (ys < y1)
            row.append('%d / %d' % ((diff & inbox).sum(), (diff & ~inbox).sum()))
        print('t%d | ' % t + ' | '.join(row))
    for t in (520, 540, 580):
        arrs = [np.asarray(Image.open('%s/t%d.png' % (d, t)).convert('RGB')) for d in dirs]
        full = np.ones(arrs[0].shape[:2], bool)
        row = ['/'.join(map(str, counts(a, full))) for a in arrs]
        if len(arrs) == 2:
            row.append('%d whole frame' % (np.abs(arrs[0].astype(int) - arrs[1].astype(int)).max(-1) > 0).sum())
        print('t%d (whole frame, fire ring) | ' % t + ' | '.join(row))

if __name__ == "__main__":
    main()
