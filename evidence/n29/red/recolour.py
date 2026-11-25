"""n29 combat 02a: the fire cells' red/vermilion/orange-red moved onto the amber hue of ElectricArc.HALO
(#edab42, 36.8 deg), deterministic, per pixel. Run from the repo root: python -I evidence/n29/red/recolour.py [--fire-loop] [--dry]

A pixel moves when alpha > 0 and it is reddish by the n28 counter's gate (R>170, G<110, B<90) or its HSV hue is
in 345..25 deg with saturation > 0.35. It keeps alpha, its max channel (HSV value) and its min channel (so its
saturation): R = max, B = min, G = min + (max - min) * 36.8 / 60, then all three times DARKEN. Every other pixel
(cream, ink, grey, already amber) keeps its bytes. Prints per file: reddish px before -> after, changed px."""
import hashlib, sys
import numpy as np
from PIL import Image

TARGET = (0xED, 0xAB, 0x42)  # ElectricArc.HALO
HUE_T = 60.0 * (TARGET[1] - TARGET[2]) / (TARGET[0] - TARGET[2])  # 36.84 deg
DARKEN = 1.0  # at most 0.85 per the brief, if amber reads too pale on cream at 32 px/m
FX = "project/features/combat/weapons/art/fx/"
FILES = [FX + "blast_0.png", FX + "blast_1.png"]
FILES += [FX + "flame_%d.png" % i for i in range(3)]
FILES += [FX + "colour/flame_cone_%d.png" % i for i in range(3)]
FILES += [FX + "colour/flame_%d.png" % i for i in range(3)]
FILES += [FX + "colour/ground_fire.png"]
# n29 call 2 (director 02:04): quest 1's fire loop draws the burning ground and the burn bursts
FIRE_LOOP = "project/features/fx/art/fx_fire.png"
ATLAS = "project/features/fx/art/fx_atlas.png"
ATLAS_CELLS = [9, 10, 11, 12]  # the explosion kind; 8 columns of 256 px
CELL = 256
MUZZLE_CELLS = [0, 1, 2, 8, 13, 14]  # muzzle kind (0-2), small burst, ricochet stars


def reddish(a):
    return (a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90) & (a[..., 3] > 0)


def mask(a):
    rgb = a[..., :3].astype(np.float64)
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    d = np.where(mx > mn, mx - mn, 1.0)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    h = np.where(mx == r, ((g - b) / d) % 6.0, np.where(mx == g, (b - r) / d + 2.0, (r - g) / d + 4.0)) * 60.0
    s = np.where(mx > 0, (mx - mn) / np.where(mx > 0, mx, 1.0), 0.0)
    band = ((h >= 345.0) | (h <= 25.0)) & (s > 0.35) & (mx > mn)
    return (band | reddish(a)) & (a[..., 3] > 0)


def remap(a):
    """Returns (new array, changed px)."""
    m = mask(a)
    rgb = a[..., :3].astype(np.float64)
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    new = np.stack([mx, mn + (mx - mn) * HUE_T / 60.0, mn], axis=2) * DARKEN
    new = np.clip(np.rint(new), 0, 255).astype(np.uint8)
    out = a.copy()
    out[..., :3][m] = new[m]
    return out, int((out != a).any(axis=2).sum())


def load(path):
    im = Image.open(path)
    if im.mode != "RGBA":
        raise SystemExit("%s: mode %s, expected RGBA" % (path, im.mode))
    return np.array(im)


def cell_hash(a, i):
    r, c = divmod(i, 8)
    return hashlib.sha256(a[r * CELL:(r + 1) * CELL, c * CELL:(c + 1) * CELL].tobytes()).hexdigest()[:16]


def one(path, dry):
    a = load(path)
    b, n = remap(a)
    print("%s reddish %d -> %d, changed %d px" % (path, int(reddish(a).sum()), int(reddish(b).sum()), n))
    if not dry:
        Image.fromarray(b, "RGBA").save(path, optimize=True)


def muzzle(dry):
    """n29 combat 02b: the muzzle flash cells (flash_* + colour/ variants) and fx_atlas cells 0-2, 8, 13, 14 only."""
    files = [FX + "flash_%s_%d.png" % (g, i) for g in ("nuke", "tube", "pistol", "smg") for i in range(3)]
    files += [FX + "colour/flash_%s_%d.png" % (g, i) for g in ("nuke", "tube", "pistol", "smg") for i in range(3)]
    for p in files:
        one(p, dry)
    a = load(ATLAS)
    b = a.copy()
    cells = MUZZLE_CELLS
    for i in cells:
        r, c = divmod(i, 8)
        sl = (slice(r * CELL, (r + 1) * CELL), slice(c * CELL, (c + 1) * CELL))
        b[sl], n = remap(a[sl])
        print("%s#cell%d reddish %d -> %d, changed %d px" % (ATLAS, i, int(reddish(a[sl]).sum()),
              int(reddish(b[sl]).sum()), n))
    for i in range(32):
        if i not in cells and cell_hash(a, i) != cell_hash(b, i):
            raise SystemExit("atlas cell %d moved" % i)
    print("atlas cells other than %s: pixel sha256 identical" % cells)
    if not dry:
        Image.fromarray(b, "RGBA").save(ATLAS, optimize=True)


def main(dry):
    for p in FILES:
        a = load(p)
        b, n = remap(a)
        print("%s reddish %d -> %d, changed %d px" % (p, int(reddish(a).sum()), int(reddish(b).sum()), n))
        if not dry:
            Image.fromarray(b, "RGBA").save(p, optimize=True)
    a = load(ATLAS)
    b = a.copy()
    for i in ATLAS_CELLS:
        r, c = divmod(i, 8)
        sl = (slice(r * CELL, (r + 1) * CELL), slice(c * CELL, (c + 1) * CELL))
        b[sl], n = remap(a[sl])
        print("%s#cell%d reddish %d -> %d, changed %d px" % (ATLAS, i, int(reddish(a[sl]).sum()),
              int(reddish(b[sl]).sum()), n))
    for i in range(32):
        if i not in ATLAS_CELLS and cell_hash(a, i) != cell_hash(b, i):
            raise SystemExit("atlas cell %d moved" % i)
    print("atlas cells other than %s: pixel sha256 identical" % ATLAS_CELLS)
    if not dry:
        Image.fromarray(b, "RGBA").save(ATLAS, optimize=True)


if __name__ == "__main__":
    if "--muzzle" in sys.argv:  # python -I evidence/n29/red/recolour.py --muzzle [--dry]
        muzzle("--dry" in sys.argv)
    elif "--fire-loop" in sys.argv:  # python -I evidence/n29/red/recolour.py --fire-loop
        one(FIRE_LOOP, "--dry" in sys.argv)
    else:
        main("--dry" in sys.argv)
