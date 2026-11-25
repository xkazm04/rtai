"""n29 keys sword rings: the plasma sword's copper/red hilt rings -> steel (hue 218, s 0.10, value and alpha kept; combat's
rule, evidence/n29 recolour.py of n23-street) in Rivet's strips. The rings are small (<25 px parts), so the mask is the red
hue rule AND 'within R px of a blade' (the amber blade blobs, >= MINB px); the collar sits far from the blade.
python -I evidence/n29-keys/sword_rings/recolour.py [--dry] [--json out] [--R=n]"""
import sys, glob, json, colorsys
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
from scipy import ndimage
import _ref as R

V = "project/features/characters/art/view/"
FILES = sorted(f.replace("\\", "/") for f in glob.glob(V + "p*/rivet_*eq_plasma_sword*.png"))
ALL8 = np.ones((3, 3))


def red(a):
    h, s, v = R._hsv(a)
    return ((h <= 17) | (h >= 325)) & (s > 0.45) & (v > 0.22) & (a[..., 3] > 0)


def blades(a, minb):
    h, s, v = R._hsv(a)
    amb = (h >= 36) & (h <= 62) & (s > 0.7) & (v > 0.88) & (a[..., 3] > 0)
    lab, n = ndimage.label(amb, structure=ALL8)
    sz = ndimage.sum(amb, lab, range(1, n + 1))
    return np.isin(lab, [i + 1 for i, z in enumerate(sz) if z >= minb])


def sword_mask(a, rad, minb):
    near = ndimage.distance_transform_edt(~blades(a, minb)) <= rad
    return red(a) & near


def steel(a, m):
    out = a.copy()
    for y, x in zip(*np.nonzero(m)):
        v = a[y, x, :3].max() / 255.0
        out[y, x, :3] = [int(round(c * 255)) for c in colorsys.hsv_to_rgb(218 / 360, 0.10, v)]
    return out


def params(f):
    return (int([x for x in sys.argv if x.startswith("--R=")][0][4:]) if any(x.startswith("--R=") for x in sys.argv)
            else (14 if "/p55/" in f else 19)), (60 if "/p55/" in f else 28 if f.endswith("p70/rivet_eq_plasma_sword_windup.png") else 100)


if __name__ == "__main__":
    dry, rep = "--dry" in sys.argv, {}
    for f in FILES:
        a = R.load(f)
        rad, minb = params(f)
        m = sword_mask(a, rad, minb)
        out = steel(a, m)
        ch = (out != a).any(axis=2)
        outside = int((ch & ~m).sum())
        assert outside == 0 and (out[..., 3] == a[..., 3]).all() and (out[~m] == a[~m]).all()
        rep[f] = dict(red_before=int(red(a).sum()), mask=int(m.sum()), changed=int(ch.sum()), outside=outside,
                      red_after=int(red(out).sum()))
        print(f.split("view/")[1], rep[f])
        if not dry and ch.any():
            Image.fromarray(out, "RGBA").save(f, optimize=True)
    if "--json" in sys.argv:
        json.dump(rep, open(sys.argv[sys.argv.index("--json") + 1], "w"), indent=1)
