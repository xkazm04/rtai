"""Step 1-2: per weapon, pick the representative file and list vermilion connected components."""
import sys, re, json, colorsys, os
import numpy as np
from PIL import Image
from scipy import ndimage
ROOT = "project/features/combat/weapons/art/"
def vmask(a):
    r, g, b, al = [a[..., i].astype(float) / 255 for i in range(4)]
    mx = np.maximum(np.maximum(r, g), b); mn = np.minimum(np.minimum(r, g), b)
    d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-9), 0)
    h = np.zeros_like(mx)
    dd = np.maximum(d, 1e-9)
    h = np.where(mx == r, ((g - b) / dd) % 6, np.where(mx == g, (b - r) / dd + 2, (r - g) / dd + 4)) * 60
    return (h >= 9) & (h <= 24) & (s > 0.6) & (mx > 0.6) & (al > 0)
def weapon_of(path):
    p = path[len(ROOT):]
    parts = p.split("/")
    name = os.path.splitext(parts[-1])[0]
    if parts[0] == "showcase": w = name
    elif parts[0] == "held_55": w = name
    else: w = parts[0]
    w = re.sub(r"_(small|empty|empty_small)$", "", w)
    return w
def files():
    t = open("evidence/n29-keys/held_red/table.md").read()
    return re.findall(r"\| `(project/features/combat/weapons/art/[^`]+)` \|", t)
def pick(w, fs):
    cands = [f for f in fs if weapon_of(f) == w]
    for pat in ("showcase/p70/", "/held.png", "showcase/p55/", "held_55/", ""):
        for f in cands:
            if pat in f: return f
if __name__ == "__main__":
    fs = files(); tot = {}
    for f in fs:
        n = int(vmask(np.array(Image.open(f).convert("RGBA"))).sum())
        w = weapon_of(f); tot.setdefault(w, []).append((n, f))
    out = {}
    for w, l in sorted(tot.items()):
        mxn = max(n for n, _ in l)
        if mxn < 50: continue
        f = pick(w, fs)
        a = np.array(Image.open(f).convert("RGBA")); m = vmask(a)
        lab, k = ndimage.label(ndimage.binary_dilation(m, iterations=2))
        lab = lab * m
        comps = []
        for i in range(1, k + 1):
            ys, xs = np.nonzero(lab == i)
            if len(ys) == 0: continue
            comps.append(dict(id=i, px=len(ys), bbox=[int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]))
        out[w] = dict(file=f, size=list(a.shape[1::-1]), total=int(m.sum()), maxfile=mxn, comps=sorted(comps, key=lambda c: -c["px"]))
        print(w, f.replace(ROOT, ""), a.shape[1::-1], int(m.sum()), "max", mxn, "comps", len(comps), [c["px"] for c in out[w]["comps"][:8]])
    json.dump(out, open("evidence/n30-keys/vermilion/comps.json", "w"), indent=1)
