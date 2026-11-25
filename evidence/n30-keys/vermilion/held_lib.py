"""In-play vermilion: targets (held_55 file + one side-facing p70 Rivet cell per weapon) and component labelling.
Reuses comps.vmask (same mask as the showcase list). python -I, no recolour."""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, "evidence/n30-keys/vermilion")
from comps import vmask, ROOT
V70 = "project/features/characters/art/view/p70/"
NAMED = ["ray_gun", "electro_gun", "rocket_launcher", "mini_nuke", "homing_shard", "flamethrower", "machine_pistol", "gatling"]
OTHER = ["chainsaw", "hand_cannon", "pistol", "katana", "electro_baton", "plasma_rifle"]
EXTRA = ["mini_nuke_empty", "rocket_launcher_empty", "mini_nuke_small", "rocket_launcher_small"]


def held_path(w):
    return f"{ROOT}held_55/{w}.png"


def cell_path(w):
    return f"{V70}rivet_eq_{w}_left.png"


def load(path, cell=False):
    """RGBA array; for a Rivet strip, cell 0 (strip width / 3: the left strips hold 3 side cells)."""
    a = np.array(Image.open(path).convert("RGBA"))
    if cell:
        a = a[:, : a.shape[1] // 3]
    return a


def labelled(path, cell=False):
    a = load(path, cell)
    m = vmask(a)
    lab, _ = ndimage.label(ndimage.binary_dilation(m, iterations=2))
    return a, m, lab * m


def comps(lab):
    out = []
    for i in np.unique(lab):
        if i == 0:
            continue
        ys, xs = np.nonzero(lab == i)
        out.append(dict(id=int(i), px=len(ys), bbox=[int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]))
    return sorted(out, key=lambda c: -c["px"])
