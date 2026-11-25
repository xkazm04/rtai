"""Cream hanging appliances against the floor: python -W ignore -I evidence/yard29/appliance_delta.py <dusk dir> [overlay.png]
Appliance pixels = art pixels (alpha > 128, value > 0.55, saturation < 0.62, not the dark outline) of the five hang_* debris
pieces, placed at the row's `at` with size_m at 32 px/m (x) and 32 px/m (y, drawn upright, not ground-squashed); the same
frames as the Rivet exposures (camera centre from Rivet's pos_m / xy). Floor = floor_warmth mask pixels inside 1.5 m round
the piece box, minus every hang box. Delta = |mean luminance(appliance) - mean luminance(floor)|, Rec.709 linear light,
dusk hero frame, averaged over the exposures."""
import json, math, os, sys
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, str(Path(__file__).parent))
import floor_warmth_lib as fw

root = Path(sys.argv[1])
_de = (Path(__file__).parent / "rivet_de.py").read_text()
_lines = _de[_de.index("def de2000"):].split(chr(10))
exec(chr(10).join([_lines[0]] + [l for l in __import__("itertools").takewhile(lambda l: l.startswith(" "), _lines[1:])]))  # CIEDE2000 of rivet_de.py only
MODE = os.environ.get("MASK", "cream")  # MASK=rust measures the beam and arches instead of the appliances
ky = 32 * np.sin(np.radians(70))
row = json.loads(Path("project/data/tables/prologue_yard_dressings.json").read_text())["dressings"]["arched_line"]
hangs = [p for p in row["layout"]["debris"] if p["id"].startswith(("hang_", "arch_"))]
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
lum = lambda rgb: lin(rgb.astype(np.float32) / 255.0) @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)

def appliance_mask(art, w, h):
    img = Image.open("project/" + art.replace("res://", "")).convert("RGBA").resize((w, h), Image.BILINEAR)
    a = np.asarray(img, dtype=float)
    rgb = a[..., :3] / 255.0
    mx, mn = rgb.max(2), rgb.min(2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    cream = (mx > 0.55) & (sat < 0.62)
    if MODE == "rust":  # beam and arches: opaque, not cream, not the dark outline
        return (a[..., 3] > 128) & ~cream & (mx > 0.30)
    return (a[..., 3] > 128) & cream

out, over = [], None
for fr in json.loads((root / "sample_points.json").read_text())["frames"]:
    riv = [p for p in fr["points"] if p["kind"] == "rivet"]
    f = root / f"{fr['frame']}.png"
    if not riv or not f.exists():
        continue
    x, y = riv[0]["xy"]; rx, ry = riv[0]["pos_m"]
    cx, cy = rx - (x - 960) / 32.0, ry - (y - 540) / ky
    hero = fw.load_half(f)
    L, a, b = fw.lab(hero)
    wx, wy = fw.world(cx, cy, ky / 2)
    floor = fw.floor_mask(L, np.hypot(a, b), wy, "mid")
    xx = np.arange(960)[None, :]
    allbox = np.zeros(L.shape, bool)
    boxes = []
    for p in hangs:
        w, h = int(round(p["size_m"][0] * 16)), int(round(p["size_m"][1] * 16))
        px, py = 480 + (p["at"][0] - cx) * 16, 270 + (p["at"][1] - cy) * ky / 2
        x0, y0 = int(round(px - w / 2)), int(round(py - h / 2))
        if x0 < 0 or y0 < 0 or x0 + w > 960 or y0 + h > 540:
            continue
        box = np.zeros(L.shape, bool); box[y0:y0 + h, x0:x0 + w] = True
        m = np.zeros(L.shape, bool); m[y0:y0 + h, x0:x0 + w] = appliance_mask(p["art"], w, h)
        boxes.append((box, m)); allbox |= box
    if not boxes:
        continue
    am = np.zeros(L.shape, bool)
    for _, m in boxes: am |= m
    near = ndimage.binary_dilation(allbox, structure=np.ones((49, 49), bool)) & floor & ~ndimage.binary_dilation(allbox, iterations=2)
    if am.sum() < 200 or near.sum() < 500:
        continue
    out.append((fr["tick"], float(abs(lum(hero[am]).mean() - lum(hero[near]).mean())), float(lum(hero[am]).mean()), float(lum(hero[near]).mean()), int(am.sum()), float(de2000((lum_l := L[am].mean(), a[am].mean(), b[am].mean()), (L[near].mean(), a[near].mean(), b[near].mean())))))
    if over is None and len(sys.argv) > 2:
        o = hero.copy(); o[am] = (255, 0, 255); o[near & (xx % 4 == 0)] = (0, 255, 0)
        Image.fromarray(o).save(sys.argv[2])
if out:
    print(json.dumps(dict(delta=round(float(np.mean([o[1] for o in out])), 3), lum_app=round(float(np.mean([o[2] for o in out])), 3),
                          lum_floor=round(float(np.mean([o[3] for o in out])), 3), exposures=len(out), px=out[0][4], de2000=round(float(np.mean([o[5] for o in out])), 1))))
else:
    print(json.dumps(dict(delta=None)))
