"""In-play list: classify vermilion components of the held_55 file and of one side-facing p70 Rivet cell per weapon
(parts named by eye from held_ids.py crops; rules are on component px/bbox/ids), render stills, write the rows to
a temp file for the md section. python -I, no recolour. Run from the worktree root. build.py is not imported (it runs
on import); tint() is copied from it so the stills look the same."""
import sys
from PIL import Image, ImageDraw
from scipy import ndimage
sys.path.insert(0, "evidence/n30-keys/vermilion")
from held_lib import *
H, DG, DS, SP, RV = "heat", "danger", "design", "speckle", "rivet"
AMBER = (255, 176, 0)
OUT = "C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/"


def tint(img, mask, cls):
    px = np.array(img)
    big = np.kron(mask, np.ones((4, 4), bool))
    if big.shape != px.shape[:2]:
        return img
    if cls == H:
        px[big, :3] = (px[big, :3] * 0.35 + np.array(AMBER) * 0.65).astype(np.uint8)
    elif cls == DS:
        yy, xx = np.mgrid[:big.shape[0], :big.shape[1]]
        px[big & (((xx + yy) % 8) < 3), :3] = (150, 150, 150)
    elif cls == DG:
        px[ndimage.binary_dilation(big, iterations=3) & ~big, :3] = (255, 255, 255)
    return Image.fromarray(px)


def tint_k(img, mask, cls, k):
    """tint at any scale k (build.tint is fixed at 4)."""
    px = np.array(img)
    big = np.kron(mask, np.ones((k, k), bool))
    if cls == H:
        px[big, :3] = (px[big, :3] * 0.35 + np.array(AMBER) * 0.65).astype(np.uint8)
    elif cls == DS:
        yy, xx = np.mgrid[:big.shape[0], :big.shape[1]]
        px[big & (((xx + yy) % 8) < 3), :3] = (150, 150, 150)
    elif cls == DG:
        px[ndimage.binary_dilation(big, iterations=k - 1) & ~big, :3] = (255, 255, 255)
    return Image.fromarray(px)


def ids(*n):
    return lambda c: c["id"] in n


def xmin(x, px=0):
    return lambda c: c["bbox"][0] >= x and c["px"] >= px


STRIPE = "warning stripes on the warhead nose: the live round"
CABLE = "thin copper cable arc over the body: current wire, goes amber"
RUST = "rust patches and flecks, no part"
COLLAR = "Rivet's own hazard collar (owner's vermilion), not weapon art"
HELD = {
    "ray_gun": [(ids(1, 3, 4, 5, 7, 8, 10), "feed cable arcs", H, CABLE)],
    "electro_gun": [(ids(1, 2, 4, 5, 20, 22, 25), "feed cable arcs", H, CABLE)],
    "rocket_launcher": [(xmin(500, 100), "warhead nose stripes", DG, STRIPE)],
    "mini_nuke": [(xmin(480, 100), "warhead nose stripes", DG, STRIPE), (ids(5, 14), "coolant cable arc", H, CABLE)],
    "mini_nuke_empty": [(ids(5, 13), "coolant cable arc", H, CABLE)],
    "homing_shard": [(ids(1, 2, 3), "coiled hose arcs", DS, "design colour, keep (owner): the showcase class of the hoses")],
    "machine_pistol": [(ids(1, 2, 3), "coolant cable arcs", H, CABLE)],
    "chainsaw": [(ids(11, 23, 24, 32, 36, 38, 41), "ignition cable loop", H, "copper cable looped off the engine: current wire")],
    "electro_baton": [(xmin(280), "coil winding", H, "copper coil at the prongs: current, amber")],
    "plasma_rifle": [(ids(1, 2, 4, 5, 6), "feed cable arcs", H, CABLE)],
}
CELL = {
    "ray_gun": ([(ids(28), "emitter coil rings", H, "copper coil rings at the dish: the charged coil"),
                 (ids(19), "feed pipe loop", H, "pipe loop over the body: hot pipe")], [30, 31, 32, 33, 35, 26]),
    "electro_gun": ([(ids(16), "barrel coil", H, "the coil that makes the arc: current, amber")], [14, 17, 18, 19, 21]),
    "rocket_launcher": ([(ids(29), "warhead nose stripes", DG, STRIPE)], [17, 19, 20, 21, 23, 24, 25]),
    "mini_nuke": ([], [20, 24, 25, 27, 28]),
    "homing_shard": ([(ids(19), "hose loop", DS, "design colour, keep (owner): the showcase class of the hoses")], [21, 32, 36, 37, 41, 49]),
    "flamethrower": ([], [27, 28, 29, 36, 37]),
    "machine_pistol": ([], [19, 23, 29, 32, 33, 35]),
    "gatling": ([], [22, 24, 25, 31, 33]),
    "plasma_rifle": ([], [19, 21, 30, 31, 33, 35]),
    "chainsaw": ([], [16, 19, 20, 21, 22, 23]),
}


def run(w, path, cell, rules, collar=()):
    a, m, lab = labelled(path, cell)
    cs = {c["id"]: c for c in comps(lab) if c["px"] >= 15}
    parts, cls_of = [], {}
    for pred, part, c, why in rules:
        hit = [i for i, d in cs.items() if i not in cls_of and pred(d)]
        if hit:
            parts.append((part, c, sum(cs[i]["px"] for i in hit), why))
            cls_of.update({i: c for i in hit})
    if collar:
        hit = [i for i in collar if i in cs]
        parts.append(("Rivet's collar", RV, sum(cs[i]["px"] for i in hit), COLLAR))
        cls_of.update({i: RV for i in hit})
    rest = int(m.sum()) - sum(p[2] for p in parts)
    parts.append(("scattered wear and Rivet's cracks" if collar else "scattered wear", SP, rest, RUST))
    return a, lab, cls_of, parts


def crop_still(a, lab, cls_of, k, label):
    bg = Image.new("RGBA", (a.shape[1], a.shape[0]), (40, 40, 48, 255))
    bg.alpha_composite(Image.fromarray(a))
    ys, xs = np.nonzero(a[..., 3] > 0)
    x0, x1, y0, y1 = max(xs.min() - 4, 0), min(xs.max() + 5, a.shape[1]), max(ys.min() - 4, 0), min(ys.max() + 5, a.shape[0])
    left = bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * k, (y1 - y0) * k), Image.NEAREST).convert("RGB")
    right = left.copy()
    for c in (DS, H, DG):
        mk = np.isin(lab, [i for i, cc in cls_of.items() if cc == c])[y0:y1, x0:x1]
        if mk.any():
            right = tint_k(right, mk, c, k)
    s = Image.new("RGB", (left.width * 2 + 8, left.height + 22), (20, 20, 24))
    s.paste(left, (0, 0))
    s.paste(right, (left.width + 8, 0))
    d = ImageDraw.Draw(s)
    d.text((4, s.height - 18), label, fill=(230, 230, 230))
    lx = left.width + 16
    for txt, col in (("danger: white outline", (255, 255, 255)), ("heat: amber fill", AMBER), ("design: grey hatch", (150, 150, 150)),
                     ("speckle, Rivet collar: none", (90, 90, 90))):
        d.rectangle([lx, s.height - 16, lx + 9, s.height - 7], fill=col)
        d.text((lx + 13, s.height - 18), txt, fill=(220, 220, 220))
        lx += 170
    return s


rows, summ, stills = [], [], []
ORDER = NAMED + ["chainsaw", "hand_cannon", "pistol", "katana", "electro_baton", "plasma_rifle", "mini_nuke_empty", "rocket_launcher_empty",
                 "mini_nuke_small", "rocket_launcher_small"]
for w in ORDER:
    rules = HELD.get(w, [])
    if w == "rocket_launcher_empty":
        rules = []
    if w in ("mini_nuke_small", "rocket_launcher_small"):
        rules = HELD["rocket_launcher"] if w.startswith("rocket") else HELD["mini_nuke"][:1]
    runs = [(f"held_55/{w}.png", held_path(w), False, rules, ())]
    if w in CELL:
        r, col = CELL[w]
        runs.append((f"p70 rivet_eq_{w}_left.png cell 0", cell_path(w), True, r, col))
    imgs = []
    for rel, path, cell, rl, col in runs:
        a, lab, cls_of, parts = run(w, path, cell, rl, col)
        for part, c, px, why in parts:
            if px > 0:
                rows.append(f"| {w} | `{rel}` | {part} | {c} | {px} | {why} |")
        tot = {c: sum(p[2] for p in parts if p[1] == c) for c in (DG, H, DS, SP, RV)}
        summ.append((w, rel, tot))
        imgs.append(crop_still(a, lab, cls_of, 2 if not cell else 4, f"{w}  {rel}"))
    W = max(i.width for i in imgs)
    st = Image.new("RGB", (W, sum(i.height for i in imgs) + 4 * len(imgs)), (20, 20, 24))
    y = 0
    for i in imgs:
        st.paste(i, (0, y))
        y += i.height + 4
    st.save(OUT + f"{w}_held_4x.png")
    stills.append(st)
CW = 1600
rs = [s.resize((CW, max(1, int(s.height * CW / s.width))), Image.NEAREST) for s in stills]
sheet = Image.new("RGB", (CW, sum(r.height for r in rs)), (20, 20, 24))
y = 0
for r in rs:
    sheet.paste(r, (0, y))
    y += r.height
sheet.save(OUT + "contact_held_4x.png")
srows = [f"| {w} | `{rel}` | {t[DG]} | {t[H]} | {t[DS]} | {t[SP]} | {t[RV]} |" for w, rel, t in summ]
open("C:/Users/kazda/AppData/Local/Temp/held_rows.md", "w").write("\n".join(rows) + "\n@@\n" + "\n".join(srows) + "\n")
print("\n".join(srows))
