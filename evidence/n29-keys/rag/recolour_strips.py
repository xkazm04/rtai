"""n29 keys rag2: the molotov flame amber (#EDAB42, combat's hue remap in _ref.py) in the item art and in Rivet's strips.
Run from the repo root: python -I evidence/n29-keys/rag/recolour_strips.py [--dry] [--json out.json]
Flame mask per cell (strips): loose reddish blobs (8-connected, <= 1200 px, never the cell's biggest blob = the collar/rust
body) with the most yellow-white core around them, plus the small rag blobs right under it. Item art: a box on the rag.
Proofs printed and asserted: nothing outside the masks changed; the collar blob's strict reddish count before == after."""
import json, sys
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
from scipy import ndimage
import _ref as R

A = "project/features/combat/weapons/art/"
V = "project/features/characters/art/view/"
BOXES = {A + "molotov/held.png": (0, 152, 345, 475), A + "molotov/pickup.png": (0, 164, 337, 463),
         A + "held_55/molotov.png": (0, 263, 440, 647)}
EQ = [V + p + "/rivet_eq_molotov" + s + ".png" for p in ("p55", "p70") for s in ("", "_left")]
WALK = V + "p70/rivet_walk_eq_molotov.png"
ALL8 = np.ones((3, 3))


def col_cells(a):
    cols = np.nonzero((a[..., 3] > 0).any(axis=0))[0]
    runs, s, p = [], cols[0], cols[0]
    for c in cols[1:]:
        if c - p > 3:
            runs.append((0, a.shape[0], int(s), int(p) + 1))
            s = c
        p = c
    runs.append((0, a.shape[0], int(s), int(p) + 1))
    return runs


def grid_cells(a, ch=188, cw=169):
    return [(r * ch, min((r + 1) * ch, a.shape[0]), c * cw, min((c + 1) * cw, a.shape[1]))
            for r in range(a.shape[0] // ch) for c in range(a.shape[1] // cw + 1) if c * cw < a.shape[1]]


def flame_mask(a, cell):
    y0, y1, x0, x1 = cell
    sub = a[y0:y1, x0:x1]
    h, s, v = R._hsv(sub)
    core = (h >= 38) & (h <= 62) & (s > 0.3) & (v > 0.85) & (sub[..., 3] > 0)
    lab, n = ndimage.label(R.mask(sub), structure=ALL8)
    if n == 0:
        return None, None, 0
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    big = int(np.argmax(sizes)) + 1
    best, bc = None, 9
    for i in range(1, n + 1):
        if i == big or not 25 <= sizes[i - 1] <= 1200:
            continue
        c = int((ndimage.binary_dilation(lab == i, ALL8, iterations=3) & core).sum())
        if c > bc:
            best, bc = i, c
    if best is None:  # the flame is joined to the body blob by a thin neck: split it by erosion, grow back inside the mask
        bm = lab == big
        for it in (1, 2, 3):
            el, en = ndimage.label(ndimage.binary_erosion(bm, ALL8, iterations=it), structure=ALL8)
            if en < 2:
                continue
            es = ndimage.sum(np.ones_like(el), el, range(1, en + 1))
            bigc = int(np.argmax(es)) + 1
            cand = [(int((ndimage.binary_dilation(el == i, ALL8, iterations=it + 3) & core).sum()), i)
                    for i in range(1, en + 1) if i != bigc and 12 <= es[i - 1] <= 900]
            cand = [c for c in cand if c[0] > bc]
            if not cand:
                continue
            fl = ndimage.binary_dilation(el == max(cand)[1], ALL8, iterations=it) & bm
            body = ndimage.binary_dilation(el == bigc, ALL8, iterations=it) & bm
            fl &= ~body
            fx = np.nonzero(fl.any(axis=0))[0]
            if len(fx) == 0 or fx.max() - fx.min() > 33:  # a real flame is <= 31 px wide; wider = it leaked into the head
                continue
            full = np.zeros(a.shape[:2], bool)
            full[y0:y1, x0:x1] = fl
            cm = np.zeros(a.shape[:2], bool)
            cm[y0:y1, x0:x1] = bm & ~fl
            return full, bm & ~fl, int(bm.sum())
        return None, lab == big, 0
    ys, xs = np.nonzero(lab == best)
    fy1, fx0, fx1 = ys.max() + 1, xs.min() - 4, xs.max() + 5
    keep = lab == best
    for i in range(1, n + 1):  # the lit rag right under the flame: small, narrow, inside its columns
        if i in (big, best) or sizes[i - 1] > 150:
            continue
        yy, xx = np.nonzero(lab == i)
        if xx.min() >= fx0 and xx.max() < fx1 and fy1 - 6 <= yy.min() <= fy1 + 14 and xx.max() - xx.min() < 15:
            keep |= lab == i
    full = np.zeros(a.shape[:2], bool)
    full[y0:y1, x0:x1] = keep
    return full, lab == big, int(sizes[big - 1])


def one(f, dry, rep):
    a = R.load(f)
    out = a.copy()
    mask = np.zeros(a.shape[:2], bool)
    full, _ = R.remap(a)
    rows = []
    if f in BOXES:
        y0, y1, x0, x1 = BOXES[f]
        mask[y0:y1, x0:x1] = True
    else:
        for k, cell in enumerate(col_cells(a) if f in EQ else grid_cells(a)):
            fm, collar, _ = flame_mask(a, cell)
            y0, y1, x0, x1 = cell
            cm = np.zeros(a.shape[:2], bool)
            if collar is not None:
                cm[y0:y1, x0:x1] = collar
            if fm is None:
                rows.append((k, 0, int(R.reddish(a)[cm].sum()), int(R.reddish(a)[cm].sum()), "no flame"))
                continue
            assert not (fm & cm).any(), "flame touches collar blob"
            mask |= fm
            r0 = int(R.reddish(a)[fm].sum())
            rows.append((k, int(fm.sum()), r0, int(R.reddish(a)[cm].sum()), "flame"))
    out[mask] = full[mask]
    changed = (out != a).any(axis=2)
    outside = int((changed & ~mask).sum())
    assert outside == 0 and (out[..., 3] == a[..., 3]).all()
    rep[f] = dict(before=int(R.reddish(a).sum()), after=int(R.reddish(out).sum()), changed=int(changed.sum()),
                  outside=outside, mask=int(mask.sum()), cells=rows)
    print("%s reddish %d -> %d, mask %d px, changed %d, outside mask %d" % (f.split("art/")[-1], rep[f]["before"],
          rep[f]["after"], rep[f]["mask"], rep[f]["changed"], outside))
    for r in rows:
        print("   cell %d: %s mask %d flame-reddish %d collar-reddish(before=after, asserted below)" % (r[0], r[4], r[1], r[2]))
    # collar proof: every px outside the mask is byte-identical, so the biggest blob per cell (collar + body) is too
    assert (out[~mask] == a[~mask]).all()
    if dry:  # review copies, never the project file
        import os
        os.makedirs("build/n29rag2/after", exist_ok=True)
        Image.fromarray(out, "RGBA").save("build/n29rag2/after/" + f.split("art/")[-1].replace("/", "__"))
    if not dry and changed.any():
        Image.fromarray(out, "RGBA").save(f, optimize=True)
    return a, out, mask


if __name__ == "__main__":
    rep = {}
    for f in list(BOXES) + EQ + [WALK]:
        if f.endswith("held_55/molotov.png") or f.startswith(V) or "molotov/held" in f or "molotov/pickup" in f:
            one(f, "--dry" in sys.argv, rep)
    if "--json" in sys.argv:
        json.dump(rep, open(sys.argv[sys.argv.index("--json") + 1], "w"), indent=1)
