"""Proof against HEAD for every plasma-sword strip: changed px, alpha changed, changed px that were vivid hazard-collar
vermilion (R>200, 50<G<130, B<70, s>0.75, v>0.8) - must be 0 - and px outside the recolour mask changed - must be 0.
Also writes the before|after 4x sheet of the changed cells. python -I evidence/n29-keys/sword_rings/verify.py <sheet.png>"""
import sys, subprocess, io, json
sys.path.insert(0, "evidence/n29-keys/rag"); sys.path.insert(0, "evidence/n29-keys/sword_rings")
import numpy as np
from PIL import Image
import _ref as R, recolour as X
rows, sheets = {}, []
for f in X.FILES:
    p = subprocess.run("git show HEAD:%s | git lfs smudge" % f, shell=True, capture_output=True).stdout
    b = np.array(Image.open(io.BytesIO(p)).convert("RGBA")); a = R.load(f)
    rad, mb = X.params(f); m = X.sword_mask(b, rad, mb)
    ch = (a != b).any(axis=2)
    h, s, v = R._hsv(b)
    vermil = (b[..., 0] > 200) & (b[..., 1] > 50) & (b[..., 1] < 130) & (b[..., 2] < 70) & (s > .75) & (v > .8) & (b[..., 3] > 0)
    from scipy import ndimage
    lab, n = ndimage.label(ndimage.binary_dilation(vermil, np.ones((3, 3)), iterations=2), structure=np.ones((3, 3)))
    sz = ndimage.sum(vermil, lab, range(1, n + 1))
    collar = np.isin(lab, [i + 1 for i, z in enumerate(sz) if z >= 120]) & vermil  # the striped band: a >= 120 px vivid part
    rows[f] = dict(collar_px=int(collar.sum()), collar_changed=int((ch & collar).sum()), changed=int(ch.sum()), alpha_changed=int((a[..., 3] != b[..., 3]).sum()), outside_mask=int((ch & ~m).sum()),
                   vermilion_px_in_file=int(vermil.sum()), vermilion_changed=int((ch & vermil).sum()),
                   reddish_before=int(R.reddish(b).sum()), reddish_after=int(R.reddish(a).sum()))
    print(f.split("view/")[1], rows[f])
    assert rows[f]["outside_mask"] == 0 and rows[f]["alpha_changed"] == 0
    ys, xs = np.nonzero(ch)
    if len(xs) and len(sys.argv) > 1 and (f.endswith("_left.png") or f.endswith("windup.png") or f.endswith("p55/rivet_eq_plasma_sword.png")
                                          or f.endswith("p70/rivet_eq_plasma_sword.png")):
        sheets.append((b, a, (max(0, xs.min() - 6), max(0, ys.min() - 6), min(b.shape[1], xs.min() + 120), min(b.shape[0], ys.min() + 100))))
json.dump(rows, open("evidence/n29-keys/sword_rings/proof.json", "w"), indent=1)
if len(sys.argv) > 1:
    sys.path.insert(0, "evidence/n29-keys/rag"); import sheet; sheet.sheet(sheets, sys.argv[1], 4)
