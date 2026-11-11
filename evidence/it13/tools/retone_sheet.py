"""Carry the asset lane's per-cell re-tone onto a packed ghost sheet without repacking.

For each (sheet cell <- source cell) pair, fit an affine RGB map pretone->new on the
source cell's opaque pixels (same file, same geometry, only the tone moved), then apply
it to the packed sheet cell's RGB. Alpha is never touched, so shapes stay pixel-exact.

usage: retone_sheet.py <sheet.png> <cols> <rows> <pretone_dir> <new_dir> <map> [<out>]
  map: comma list of srow:scol=crow_ccol, 1-based (e.g. 1:1=1_1,1:2=1_2)
       or 'grid' = sheet row r col c <- r_c for every pretone file
"""
import os, sys
import numpy as np
from PIL import Image


def fit(pre, new):
    a = np.asarray(Image.open(pre).convert("RGBA"), dtype=np.float64)
    b = np.asarray(Image.open(new).convert("RGBA"), dtype=np.float64)
    if a.shape != b.shape:
        raise SystemExit(f"shape differs {pre}: {a.shape} vs {b.shape}")
    m = (a[..., 3] > 200) & (b[..., 3] > 200)
    x = np.c_[a[m][:, :3], np.ones(m.sum())]
    y = b[m][:, :3]
    coef, *_ = np.linalg.lstsq(x, y, rcond=None)
    res = np.abs(x @ coef - y).mean()
    return coef, res, np.abs(a[m][:, :3] - y).mean()


def main():
    sheet, cols, rows, pre_d, new_d, spec = sys.argv[1:7]
    out = sys.argv[7] if len(sys.argv) > 7 else sheet
    cols, rows = int(cols), int(rows)
    img = np.asarray(Image.open(sheet).convert("RGBA"), dtype=np.float64).copy()
    cw, ch = img.shape[1] // cols, img.shape[0] // rows
    if spec == "grid":
        pairs = []
        for f in sorted(os.listdir(pre_d)):
            r, c = f[:-4].split("_")
            pairs.append((int(r), int(c), f))
    else:
        pairs = []
        for item in spec.split(","):
            sc, cell = item.split("=")
            r, c = sc.split(":")
            pairs.append((int(r), int(c), cell + ".png"))
    for r, c, f in pairs:
        coef, res, moved = fit(os.path.join(pre_d, f), os.path.join(new_d, f))
        y0, x0 = (r - 1) * ch, (c - 1) * cw
        blk = img[y0:y0 + ch, x0:x0 + cw]
        m = blk[..., 3] > 0
        rgb = np.c_[blk[m][:, :3], np.ones(m.sum())] @ coef
        blk[m, :3] = np.clip(np.rint(rgb), 0, 255)
        print(f"{os.path.basename(sheet)} r{r}c{c} <- {f}: source moved {moved:5.2f}, fit residual {res:4.2f}")
    Image.fromarray(img.astype(np.uint8), "RGBA").save(out)


main()
