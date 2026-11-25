"""n30 shade05: n29's prop_contrast.py adapted. Mean |prop - floor ring| luminance at 32 px/m, mid camera, tick 300, plus the forklift's mean CIELAB.
python -W ignore -I evidence/yard30/prop_contrast30.py <dir with i20_mid_32.png, today_mid_32.png, after_mid_32.png>
Method as in evidence/yard29/prop_contrast.py (boxes from the row's cover at/size_m, prop = art alpha > 128 pixels, ring = 1 m round the box minus the
other placed pieces, Rec.709 linear luminance of the final frame). Looks: i20 = c649a15d6 (n29's i20 still), today = 5114a4441, after = HEAD
(rows via git show). Colour: mean of the forklift pixels' sRGB -> linear -> XYZ (D65) -> CIELAB; C* = hypot(a*, b*), hue = atan2(b*, a*) in degrees."""
import json, subprocess, sys
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage

D = Path(sys.argv[1])
LOOKS = {"i20": "c649a15d6", "today": "5114a4441", "after": "HEAD"}
CAM = {"mid": (35.21, 19.93)}
KY = 32 * np.sin(np.radians(70))
IDS = {"forklift (burnt_pickup)": "burnt_pickup", "scrap_skip": "scrap_skip", "fallen_fridges": "fallen_fridges"}
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
lum = lambda rgb: lin(rgb.astype(np.float32) / 255.0) @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
M = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]])
WP = np.array([0.95047, 1.0, 1.08883])

def lab(rgb):
    t = (lin(rgb.astype(np.float64) / 255.0) @ M.T) / WP
    f = np.where(t > 216 / 24389, np.cbrt(t), (24389 / 27 * t + 16) / 116)
    return 116 * f[:, 1] - 16, 500 * (f[:, 0] - f[:, 1]), 200 * (f[:, 1] - f[:, 2])

def row_at(rev):
    txt = subprocess.run(["git", "show", f"{rev}:project/data/tables/prologue_yard_dressings.json"], capture_output=True, check=True).stdout
    return json.loads(txt)["dressings"]["arched_line"]

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

out = {}; colour = {}
for look, rev in LOOKS.items():
    row = row_at(rev)
    cover = {p["id"]: p for p in row["layout"]["cover"] if "id" in p}
    img = np.asarray(Image.open(D / f"{look}_mid_32.png").convert("RGB"))
    L = lum(img)
    boxes = {k: box(cover[i], CAM["mid"]) for k, i in IDS.items()}
    allbox = np.zeros(L.shape, bool)
    for q in row["layout"]["cover"] + row["layout"]["debris"]:
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
        if i == "burnt_pickup":
            l_, a_, b_ = (float(v.mean()) for v in lab(img[pm]))
            colour[look] = (l_, a_, b_, float(np.hypot(a_, b_)), float(np.degrees(np.arctan2(b_, a_)) % 360))
print("| prop | i20 | today (1.0) | after (0.5) | today / i20 | after / i20 |")
print("|---|---|---|---|---|---|")
for k, v in out.items():
    i, p, a = v["i20"][0], v["today"][0], v["after"][0]
    print(f"| {k} | {i:.4f} | {p:.4f} | {a:.4f} | {p / i * 100:.0f} % | {a / i * 100:.0f} % |")
print()
print("| forklift | L* | a* | b* | C* | hue deg |")
print("|---|---|---|---|---|---|")
for look, c in colour.items():
    print(f"| {look} | " + " | ".join(f"{x:.1f}" for x in c) + " |")
print(json.dumps({"lum": {k: {l: [round(x, 4) for x in t[:3]] + [t[3]] for l, t in v.items()} for k, v in out.items()}, "lab": {k: [round(x, 2) for x in c] for k, c in colour.items()}}))
