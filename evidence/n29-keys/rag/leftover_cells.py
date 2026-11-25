"""n29 keys: the last five molotov flame cells (flame still joined to the body blob), hand-checked boxes (6x crops looked at),
cell-local (x0, x1, y0, y1); same remap as recolour_strips.py. python -I evidence/n29-keys/rag/leftover_cells.py [--dry] [sheet.png]"""
import sys, json
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
import _ref as R, recolour_strips as X, sheet

V = X.V
JOBS = [(V + "p55/rivet_eq_molotov.png", 1, [(0, 21, 53, 85)]),
        (V + "p55/rivet_eq_molotov.png", 7, [(55, 79, 88, 104), (72, 79, 80, 88)]),
        (V + "p55/rivet_eq_molotov_left.png", 2, [(53, 67, 101, 121)]),
        (V + "p70/rivet_walk_eq_molotov.png", 5, [(15, 43, 74, 112)]),
        (V + "p70/rivet_walk_eq_molotov.png", 9, [(12, 42, 66, 105)])]
if __name__ == "__main__":
    dry = "--dry" in sys.argv
    by = {}
    for f, k, boxes in JOBS:
        by.setdefault(f, []).append((k, boxes))
    pairs, rep = [], {}
    for f, items in by.items():
        a = R.load(f); out = a.copy(); mask = np.zeros(a.shape[:2], bool)
        full, _ = R.remap(a)
        cells = X.col_cells(a) if f in X.EQ else X.grid_cells(a)
        for k, boxes in items:
            cy0, cy1, cx0, cx1 = cells[k]
            for x0, x1, y0, y1 in boxes:
                mask[cy0 + y0:cy0 + y1, cx0 + x0:cx0 + x1] = True
            pairs.append((a, out, (cx0, cy0, cx1, cy1), mask, full, f, k))
        out[mask] = full[mask]
        ch = (out != a).any(axis=2)
        assert int((ch & ~mask).sum()) == 0 and (out[..., 3] == a[..., 3]).all()
        rep[f] = dict(changed=int(ch.sum()), outside=0, reddish_before=int(R.reddish(a).sum()), reddish_after=int(R.reddish(out).sum()),
                      per_cell={k: int(ch[cells[k][0]:cells[k][1], cells[k][2]:cells[k][3]].sum()) for k, _ in items})
        print(f.split("view/")[1], rep[f])
        if not dry:
            Image.fromarray(out, "RGBA").save(f, optimize=True)
        for p in pairs:
            if p[5] == f:
                pass
    sh = [(p[0], (lambda o, m, fl: np.where(m[..., None], fl, o))(p[0], p[3], p[4]), p[2]) for p in pairs]
    if len(sys.argv) > 1 and sys.argv[-1].endswith(".png"):
        sheet.sheet(sh, sys.argv[-1], 4)
    json.dump(rep, open("evidence/n29-keys/rag/leftover_proof.json", "w"), indent=1)
