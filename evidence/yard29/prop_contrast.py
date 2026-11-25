"""n29 impression props: mean |prop - floor ring| luminance at 32 px/m, tick 300.
python -W ignore -I evidence/yard29/prop_contrast.py <dir with i20_/pre_/after_{mid,gate}_32.png> [overlay dir]
Camera (yard_film.gd + YardCamera): mid centre (35.21, 19.93), gate centre (36, 34); x 32 px/m, y 32*sin70 px/m; 1920x1080, centre pixel (960, 540).
Prop boxes: the row's cover `at` / `size_m` (upright footprint, w = size_x*32, h = size_y*32 px, centred at the projected `at`), the
prop pixels = art pixels with alpha > 128 (the row's `crop` applied, resized to the box). Floor ring = pixels inside the box grown 32 px (1 m)
minus the box grown 3 px, minus every other cover/debris piece of the row (any actor or decal still in the ring counts as floor: same for all three looks).
Fence (gate camera): footprint Rect2(x, 33.35..34) = screen rows 520..540; prop = that whole box over x 0..680 and 1090..1720 (the open gate
leaf and post stay out); ring = the 35 rows above it (485..520) over the same x. Luminance = Rec.709 linear light of the final frame.
Rows are read from the table at each look's commit (build/dress_<rev>.json = git show <rev>:project/data/tables/prologue_yard_dressings.json,
HEAD = build/dress_head.json): i20 = c649a15d6, pre = 8b2ada27e, after = HEAD."""
import json, sys
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage

D = Path(sys.argv[1]); OV = Path(sys.argv[2]) if len(sys.argv) > 2 else None
LOOKS = {"i20": "c649a15d6", "pre": "8b2ada27e", "after": "head"}
CAM = {"mid": (35.21, 19.93), "gate": (36.0, 34.0)}
KY = 32 * np.sin(np.radians(70))
IDS = {"forklift (burnt_pickup)": "burnt_pickup", "scrap_skip": "scrap_skip", "fallen_fridges": "fallen_fridges"}
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
lum = lambda rgb: lin(rgb.astype(np.float32) / 255.0) @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)

def box(p, cam):
    w, h = int(round(p["size_m"][0] * 32)), int(round(p["size_m"][1] * 32))
    x = 960 + (p["at"][0] - cam[0]) * 32; y = 540 + (p["at"][1] - cam[1]) * KY
    return int(round(x - w / 2)), int(round(y - h / 2)), w, h

def mask(p, x0, y0, w, h):
    img = Image.open("project/" + p["art"].replace("res://", "")).convert("RGBA")
    if "crop" in p:
        W, H = img.size; c = p["crop"]
        img = img.crop((int(c["origin"][0] * W), int(c["origin"][1] * H), int((c["origin"][0] + c["size"][0]) * W), int((c["origin"][1] + c["size"][1]) * H)))
    return np.asarray(img.resize((w, h), Image.BILINEAR))[..., 3] > 128

out = {}
for look, rev in LOOKS.items():
    row = json.load(open(f"build/dress_{rev}.json", encoding="utf-8"))["dressings"]["arched_line"]
    cover = {p["id"]: p for p in row["layout"]["cover"] if "id" in p}
    img = np.asarray(Image.open(D / f"{look}_mid_32.png").convert("RGB"))
    L = lum(img)
    boxes = {k: box(cover[i], CAM["mid"]) for k, i in IDS.items()}
    allbox = np.zeros(L.shape, bool)
    for q in row["layout"]["cover"] + row["layout"]["debris"]:  # every other placed piece is not floor (rotated ones: the square of the longer side)
        if "at" not in q or "size_m" not in q or q.get("id") in IDS.values(): continue
        qq = dict(q); s_ = max(q["size_m"]) if q.get("rotation_deg", 0) % 180 else None
        if s_: qq["size_m"] = [s_, s_]
        x0, y0, w, h = box(qq, CAM["mid"]); allbox[max(y0, 0):max(y0 + h, 0), max(x0, 0):max(x0 + w, 0)] = True
    for x0, y0, w, h in boxes.values(): allbox[max(y0, 0):y0 + h, max(x0, 0):x0 + w] = True
    for k, i in IDS.items():
        x0, y0, w, h = boxes[k]
        pm = np.zeros(L.shape, bool); pm[y0:y0 + h, x0:x0 + w] = mask(cover[i], x0, y0, w, h)
        bm = np.zeros(L.shape, bool); bm[y0:y0 + h, x0:x0 + w] = True
        ring = ndimage.binary_dilation(bm, iterations=32) & ~ndimage.binary_dilation(bm, iterations=3) & ~(allbox & ~bm)
        out.setdefault(k, {})[look] = (float(abs(L[pm].mean() - L[ring].mean())), float(L[pm].mean()), float(L[ring].mean()), int(pm.sum()))
        if OV and look == "after":
            o = img.copy(); o[pm] = (255, 0, 255); o[ring & (np.arange(1920)[None, :] % 4 == 0)] = (0, 255, 0); Image.fromarray(o).save(OV / f"ov_{i}.png")
    g = np.asarray(Image.open(D / f"{look}_gate_32.png").convert("RGB")); G = lum(g)
    fx = np.zeros(G.shape, bool); fr = np.zeros(G.shape, bool)
    for a, b in ((0, 680), (1090, 1720)):
        fx[520:540, a:b] = True; fr[485:520, a:b] = True
    out.setdefault("south fence", {})[look] = (float(abs(G[fx].mean() - G[fr].mean())), float(G[fx].mean()), float(G[fr].mean()), int(fx.sum()))
print("| prop | i20 | before (8b2ada27e) | after (HEAD) | after / i20 | before / i20 |\n|---|---|---|---|---|---|")
for k, v in out.items():
    i, p, a = v["i20"][0], v["pre"][0], v["after"][0]
    print(f"| {k} | {i:.4f} | {p:.4f} | {a:.4f} | {a / i * 100:.0f} % | {p / i * 100:.0f} % |")
print(json.dumps({k: {l: [round(x, 4) for x in t[:3]] + [t[3]] for l, t in v.items()} for k, v in out.items()}))
