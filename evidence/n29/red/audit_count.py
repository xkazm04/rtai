"""n28 vs n29 reddish counts (same gate as count_red.py) per PNG: old rev via git show | git lfs smudge, new rev = HEAD blobs.
Run: python -I evidence/n29/red/audit_count.py [oldrev] [newrev] > table"""
import subprocess, sys, io, glob
import numpy as np
from PIL import Image

OLD = sys.argv[1] if len(sys.argv) > 1 else "c649a15d6"
NEW = sys.argv[2] if len(sys.argv) > 2 else "HEAD"


def red(a):
    return int(((a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90) & (a[..., 3] > 0)).sum())


def blob(rev, p):
    raw = subprocess.run(["git", "show", "%s:%s" % (rev, p)], capture_output=True).stdout
    if raw.startswith(b"version https://git-lfs"):
        raw = subprocess.run(["git", "lfs", "smudge"], input=raw, capture_output=True).stdout
    return raw


def counts(rev):
    out = {}
    files = subprocess.run(["git", "ls-tree", "-r", "--name-only", rev, "project/features/combat", "project/features/fx/art"],
                           capture_output=True, text=True).stdout.split()
    for p in files:
        if not p.endswith(".png"):
            continue
        if p.startswith("project/features/fx/art/") and not p.endswith("fx_atlas.png"):
            continue
        a = np.array(Image.open(io.BytesIO(blob(rev, p))).convert("RGBA"))
        if p.endswith("fx_atlas.png"):
            for i in range(32):
                r, c = divmod(i, 8)
                out["%s#cell%d" % (p, i)] = red(a[r * 256:(r + 1) * 256, c * 256:(c + 1) * 256])
        else:
            out[p] = red(a)
    return out


o, n = counts(OLD), counts(NEW)
for k in sorted(set(o) | set(n), key=lambda k: -max(o.get(k, 0), n.get(k, 0))):
    if o.get(k, 0) or n.get(k, 0):
        print(o.get(k, 0), n.get(k, 0), k)
print("TOTAL", sum(o.values()), sum(n.values()))
