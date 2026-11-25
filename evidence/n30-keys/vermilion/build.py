"""Steps 3-5: classify vermilion components per weapon (spec below, named by eye from the 4x crops),
render the stills + contact sheet, write evidence/n30-keys/vermilion_list.md. python -I, no recolour."""
import json, sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
sys.path.insert(0, "evidence/n30-keys/vermilion")
from comps import vmask, ROOT
OUT = "C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/"
D = json.load(open("evidence/n30-keys/vermilion/comps.json"))
H, DG, DS, SP = "heat", "danger", "design", "speckle"
# weapon -> list of (component ids, part name, class, why); every other component = speckle
SPEC = {
    "ray_gun": [([8, 14], "grip coil winding", H, "copper coil wrapped round the grip: current wire, goes amber"),
                ([7, 5], "side feed cables", H, "cables running to the emitter: current"),
                ([1], "top feed pipe", H, "copper pipe arching over the body: hot pipe"),
                ([3, 4], "emitter rings", H, "two copper coil rings before the dish: the charged coil, amber like the arc"),
                ([6], "warning triangle", DG, "solid triangle decal: a hazard mark")],
    "electro_gun": [([6], "barrel coil (3 rings)", H, "the coil that makes the arc: current, amber"),
                    ([12], "warning slash plate", DG, "diagonal hazard stripe on a plate: warning")],
    "rocket_launcher": [([6, 12], "warhead nose stripes", DG, "warning stripes on the round's nose: the warhead"),
                        ([2, 3], "fuse cables", H, "orange cable looping between the two charge boxes: current")],
    "mini_nuke": [([43, 45, 42, 48], "muzzle warning stripes", DG, "hazard stripe plate under the muzzle: live charge"),
                  ([56, 58, 59], "coolant hoses", H, "copper hose elbows under the barrel: hot pipe")],
    "homing_shard": [([35, 36, 40, 41, 47], "stripe plates (3)", DG, "diagonal hazard stripes on the body plates: warning"),
                     ([1, 2, 4], "coiled hoses", DS, "design colour, keep (owner)")],
    "flamethrower": [([12, 11, 7], "feed pipe", H, "pipe running to the nozzle: hot pipe, amber"),
                     ([4], "nozzle cage", H, "burner cage around the flame: heat")],
    "electro_baton": [([1], "coil winding", H, "copper coil at the prongs: current, amber")],
    "machine_pistol": [([1, 9], "coolant pipe loop", H, "copper U-pipe over the receiver: hot pipe")],
    "plasma_rifle": [([1], "feed cables", H, "orange cables over the top rail: current")],
    "gatling": [([7, 9, 11], "warning stripe panel", DG, "hazard stripe window on the receiver: warning")],
    "plasma_sword": [([19, 20], "hilt hoses", H, "copper hoses into the blade: current"),
                     ([5], "warning stripe plate", DG, "hazard stripes on the hilt block: warning")],
}
ORDER = ["ray_gun", "electro_gun", "rocket_launcher", "mini_nuke", "homing_shard", "flamethrower", "electro_baton",
         "machine_pistol", "plasma_rifle", "gatling", "plasma_sword", "chainsaw", "katana", "hand_cannon", "pistol",
         "assault_rifle", "gloria"]
SPECKLE_NOTE = {"chainsaw": "rust patches on the bar and body", "katana": "rust patches on the blade and guard",
                "hand_cannon": "rust flecks over the body", "pistol": "rust flecks over the body",
                "assault_rifle": "rust flecks", "gloria": "stray specks"}
PROP = {"ray_gun": "grip coil, cables, pipe, emitter rings -> amber; triangle stays vermilion",
        "electro_gun": "barrel coil -> amber; warning plate stays vermilion",
        "rocket_launcher": "fuse cables -> amber; nose stripes stay vermilion; rust stays",
        "mini_nuke": "hoses -> amber; muzzle stripes stay vermilion; plum casing stays (design, hue below vermilion)",
        "homing_shard": "stripe plates stay vermilion; hoses stay (design colour, keep)",
        "flamethrower": "feed pipe and nozzle cage -> amber; tank rust stays",
        "electro_baton": "coil -> amber; bar rust stays",
        "machine_pistol": "coolant loop -> amber; rust stays",
        "plasma_rifle": "cables -> amber",
        "gatling": "stripe panel stays vermilion",
        "plasma_sword": "hoses -> amber; hilt stripes stay vermilion (n29 excluded this weapon; owner's call)"}
AMBER = (255, 176, 0)


def labelled(f):
    a = np.array(Image.open(f).convert("RGBA"))
    m = vmask(a)
    lab, _ = ndimage.label(ndimage.binary_dilation(m, iterations=2))
    return a, m, lab * m


def tint(img, mask, cls):
    px = np.array(img)
    big = np.kron(mask, np.ones((4, 4), bool))
    if cls == H:
        px[big, :3] = (px[big, :3] * 0.35 + np.array(AMBER) * 0.65).astype(np.uint8)
    elif cls == DS:
        yy, xx = np.mgrid[:big.shape[0], :big.shape[1]]
        px[big & (((xx + yy) % 8) < 3), :3] = (150, 150, 150)
    elif cls == DG:
        px[ndimage.binary_dilation(big, iterations=3) & ~big, :3] = (255, 255, 255)
    return Image.fromarray(px)


rows, summ, stills = [], [], []
for w in ORDER:
    d = D[w]
    f = d["file"]
    a, m, lab = labelled(f)
    cls_of, parts = {}, []
    for ids, part, c, why in SPEC.get(w, []):
        px = int(sum((lab == i).sum() for i in ids))
        parts.append((part, c, px, why))
        for i in ids:
            cls_of[i] = c
    spx = int(m.sum()) - sum(p[2] for p in parts)
    if spx > 0:
        parts.append(("scattered wear", SP, spx, SPECKLE_NOTE.get(w, "small orange flecks and rust patches, no part")))
    tot = {c: sum(p[2] for p in parts if p[1] == c) for c in (DG, H, DS, SP)}
    rel = f.replace(ROOT, "")
    for part, c, px, why in parts:
        rows.append(f"| {w} | `{rel}` | {part} | {c} | {px} | {why} |")
    summ.append((w, tot, d["maxfile"]))
    ys, xs = np.nonzero(a[..., 3] > 0)
    x0, x1, y0, y1 = max(xs.min() - 4, 0), min(xs.max() + 5, a.shape[1]), max(ys.min() - 4, 0), min(ys.max() + 5, a.shape[0])
    bg = Image.new("RGBA", (a.shape[1], a.shape[0]), (40, 40, 48, 255))
    bg.alpha_composite(Image.fromarray(a))
    left = bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * 4, (y1 - y0) * 4), Image.NEAREST).convert("RGB")
    right = left.copy()
    for c in (DS, H, DG):
        mk = np.isin(lab, [i for i, cc in cls_of.items() if cc == c])[y0:y1, x0:x1]
        if mk.any():
            right = tint(right, mk, c)
    W = left.width
    Hh = left.height + 26
    still = Image.new("RGB", (W * 2 + 8, Hh), (20, 20, 24))
    still.paste(left, (0, 0))
    still.paste(right, (W + 8, 0))
    dr = ImageDraw.Draw(still)
    dr.text((4, Hh - 20), f"{w}  {rel}", fill=(230, 230, 230))
    lx = W + 16
    for txt, col in (("danger: white outline", (255, 255, 255)), ("heat: amber fill", AMBER),
                     ("design: grey hatch", (150, 150, 150)), ("speckle: none", (90, 90, 90))):
        dr.rectangle([lx, Hh - 18, lx + 9, Hh - 9], fill=col)
        dr.text((lx + 13, Hh - 20), txt, fill=(220, 220, 220))
        lx += 140
    still.save(OUT + f"{w}_4x.png")
    stills.append(still)
CW = 1600
rs = [s.resize((CW, max(1, int(s.height * CW / s.width))), Image.NEAREST) for s in stills]
sheet = Image.new("RGB", (CW, sum(r.height for r in rs)), (20, 20, 24))
y = 0
for r in rs:
    sheet.paste(r, (0, y))
    y += r.height
sheet.save(OUT + "contact_4x.png")
head = open("evidence/n30-keys/vermilion/head.md").read()
srows = [f"| {w} | {t[DG]} | {t[H]} | {t[DS]} | {t[SP]} | {PROP.get(w, 'no change: wear only')} |" for w, t, _ in summ]
body = (head + "\n## Per-part list\n\n| weapon | file shown | part | class | px | one line why |\n|---|---|---|---|---|---|\n"
        + "\n".join(rows) + "\n\n## Per-weapon summary\n\n"
        "| weapon | danger px | heat px | design px | speckle px | proposed (owner's yes) |\n|---|---|---|---|---|---|\n"
        + "\n".join(srows) + "\n")
open("evidence/n30-keys/vermilion_list.md", "w").write(body)
print("\n".join(srows))
