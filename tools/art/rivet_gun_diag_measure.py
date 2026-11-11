"""n17 rivet-strike: measure a gun's drawn diagonal fire strip for RivetGunDiag.

usage: python -I tools/art/rivet_gun_diag_measure.py <dir> <gun>[,<gun>...] [--res=1.5]

<dir> holds rivet_eq_<gun>_diag.png and its flashless twin rivet_eq_<gun>_diag_noflash.png (4 cells,
RivetStrips' DIAG order). Per cell it prints:
- deg: the drawn gun's screen angle (y down): the flash is the biggest hot blob of pixels that differ
  from the twin; from its pixel nearest the body centre (the root) to its farthest (the tip);
- root: that root in 110 space (strip px / --res), the rivet_muzzle.json point;
- helm: the helmet's centre x (strip px): the widest opaque run under the figure's top plate, read
  on the twin (check at 2x: a hose or raised gun touching the helmet widens it);
- boot: the lowest opaque row of the twin's figure (strip px; a toward flash or blade below the boots
  is not in the twin, a toward gun may be: check at 2x).
Deterministic; reads only, writes nothing.
"""

import sys

import numpy as np
from PIL import Image
from scipy import ndimage

CELLS = 4


def cell_stats(a, b):
    diff = (np.abs(a - b).sum(axis=2) > 60) & (a[:, :, 3] > 128)
    hot = diff & (a[:, :, 0] > 200) & (a[:, :, 1] > 150)
    body = b[:, :, 3] > 128
    by, bx = np.nonzero(body)
    cy, cx = by.mean(), bx.mean()
    lab, n = ndimage.label(hot)
    out = {"boot": int(by.max())}
    if n:
        sizes = ndimage.sum(hot, lab, range(1, n + 1))
        fy, fx = np.nonzero(lab == int(np.argmax(sizes)) + 1)
        d = (fx - cx) ** 2 + (fy - cy) ** 2
        i, j = int(np.argmin(d)), int(np.argmax(d))
        out["deg"] = round(float(np.degrees(np.arctan2(fy[j] - fy[i], fx[j] - fx[i]))))
        out["root"] = (int(fx[i]), int(fy[i]))
    top = int(by.min())
    best = (0, 0, 0)
    for y in range(top + 3, min(top + 45, body.shape[0])):
        xs = np.nonzero(body[y])[0]
        if len(xs) == 0:
            continue
        runs = np.split(xs, np.nonzero(np.diff(xs) > 1)[0] + 1)
        seed = int(np.median(np.nonzero(body[top])[0]))
        for r in runs:
            if r[0] <= seed <= r[-1] and r[-1] - r[0] > best[0]:
                best = (int(r[-1] - r[0]), int(r[0]), int(r[-1]))
    out["helm"] = (best[1] + best[2]) / 2.0
    return out


def main(argv):
    d, guns = argv[0], argv[1].split(",")
    res = 1.5
    for a in argv[2:]:
        if a.startswith("--res="):
            res = float(a[6:])
    for g in guns:
        a = np.asarray(Image.open(f"{d}/rivet_eq_{g}_diag.png").convert("RGBA")).astype(int)
        b = np.asarray(Image.open(f"{d}/rivet_eq_{g}_diag_noflash.png").convert("RGBA")).astype(int)
        w = a.shape[1] // CELLS
        rows = [cell_stats(a[:, c * w : (c + 1) * w], b[:, c * w : (c + 1) * w]) for c in range(CELLS)]
        deg = [r.get("deg") for r in rows]
        root = [None if "root" not in r else [round(r["root"][0] / res), round(r["root"][1] / res)] for r in rows]
        print(f"{g}: cell {w}x{a.shape[0]} deg {deg} helm {[r['helm'] for r in rows]} "
              f"boot {[r['boot'] for r in rows]} root110 {root}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
