"""MODELLED floor sweep (offline fallback, no render): re-colour the floor of the n27 raised_line --dusk captures.
python -W ignore -I evidence/yard28/floor_model.py <day dir: build/dusk27/rl_day> <dusk dir: build/dusk27/rl> <dst dir> <L*> <C*> <hue>
For every frame, actor pixels = |hero - ground| > 6 (any channel) keep their value; every other pixel becomes the ground
frame with per-channel linear-light gains that carry the BETWEEN-pools floor colour (172,155,135) to the target L*/C*/hue.
Hero, ground and *_no_rounds are all rewritten, so dusk_contrast.py / rivet_delta.py read them unchanged. Reading: the
cop/round/Rivet pixels are the real renders, only the floor under them moves (no light, shadow or glow re-render)."""
import json, shutil, sys
from pathlib import Path
import numpy as np
from PIL import Image
SRC = {"day": Path(sys.argv[1]), "dusk": Path(sys.argv[2])}; dst = Path(sys.argv[3]); L, C, h = map(float, sys.argv[4:7])
BASE = np.array([172.0, 155.0, 135.0])
def to_lin(c): c = c / 255.0; return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
def to_srgb(l): l = np.clip(l, 0, 1); return np.where(l <= 0.0031308, l * 12.92, 1.055 * l ** (1 / 2.4) - 0.055) * 255.0
def lab2srgb(L, C, h):
    a, b = C * np.cos(np.radians(h)), C * np.sin(np.radians(h)); fy = (L + 16) / 116; fx, fz = fy + a / 500, fy - b / 200
    f = lambda t: np.where(t ** 3 > 216 / 24389, t ** 3, (116 * t - 16) / (24389 / 27))
    xyz = np.array([f(fx) * 0.95047, f(fy), f(fz) * 1.08883])
    m = np.array([[3.2404542, -1.5371385, -0.4985314], [-0.9692660, 1.8760108, 0.0415560], [0.0556434, -0.2040259, 1.0572252]])
    return to_srgb(m @ xyz)
target = lab2srgb(L, C, h)
gain = (to_lin(target) / to_lin(BASE)).astype(np.float32)
print("target sRGB", np.round(target), "gain", np.round(gain, 3))
def recolour(hero, ground, other):
    out = []
    for img in other:
        a = img.astype(np.int16)
        actor = (np.abs(a - ground.astype(np.int16)).max(axis=2) > 6)[..., None]
        out.append(np.where(actor, img, new_ground(ground)).astype(np.uint8))
    return out
def new_ground(g):
    lin = (g.astype(np.float32) / 255.0)
    lin = np.where(lin <= 0.04045, lin / 12.92, ((lin + 0.055) / 1.055) ** 2.4) * gain
    return to_srgb(lin).round()
for arm in ("day", "dusk"):
    src = SRC[arm]; (dst / arm).mkdir(parents=True, exist_ok=True)
    shutil.copy(src / "sample_points.json", dst / arm / "sample_points.json")
    for gpath in sorted(src.glob("*_ground.png")):
        label = gpath.name[:-len("_ground.png")]
        ground = np.asarray(Image.open(gpath).convert("RGB"))
        names = [label] + ([f"{label}_no_rounds"] if (src / f"{label}_no_rounds.png").exists() else [])
        imgs = [np.asarray(Image.open(src / f"{n}.png").convert("RGB")) for n in names]
        for n, im in zip(names, recolour(None, ground, imgs)):
            Image.fromarray(im).save(dst / arm / f"{n}.png")
        Image.fromarray(new_ground(ground).astype(np.uint8)).save(dst / arm / gpath.name)
