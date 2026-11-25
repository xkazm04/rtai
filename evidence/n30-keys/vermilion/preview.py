"""n30-19: heat -> amber preview. Per weapon with a heat part: current | proposed, showcase (p70) above in play
(held_55, Rivet p70 cell). Recolour only the px of the heat parts' vermilion mask (undilated, inside the part's
component): hue and saturation of #ffbf56, value = the source px's own value (max channel), alpha untouched.
Nothing in project/ changes. build.py and held_build.py run on import, so their spec prefix (everything before
the `rows, summ, stills` line: SPEC / HELD / CELL / run) is exec'd instead of duplicated. python -I, worktree root."""
import colorsys, sys
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, "evidence/n30-keys/vermilion")


def prefix(name):
    src = open(f"evidence/n30-keys/vermilion/{name}").read()
    ns = {"__name__": name}
    exec(compile(src.split("rows, summ, stills = [], [], []")[0], name, "exec"), ns)
    return ns


B, HB = prefix("build.py"), prefix("held_build.py")
OUT = "C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/"
AH, AS, _ = colorsys.rgb_to_hsv(*(c / 255 for c in (0xFF, 0xBF, 0x56)))


def recolour(a, hm):
    """a RGBA uint8, hm bool mask. Returns copy; rgb = hsv(AH, AS, v_src) inside hm, nothing else changes."""
    out = a.copy()
    v = a[..., :3].max(axis=2).astype(float) / 255
    h6 = AH * 6
    i, f = int(h6), h6 - int(h6)
    p, q, t = v * (1 - AS), v * (1 - AS * f), v * (1 - AS * (1 - f))
    rgb = {0: (v, t, p), 1: (q, v, p), 2: (p, v, t), 3: (p, q, v), 4: (t, p, v), 5: (v, p, q)}[i]
    new = np.stack([np.clip(np.rint(c * 255), 0, 255) for c in rgb], axis=2).astype(np.uint8)
    out[hm, :3] = new[hm]
    assert (out[~hm] == a[~hm]).all(), "px outside the mask changed"
    assert (out[..., 3] == a[..., 3]).all(), "alpha changed"
    return out


def heat_mask(lab, cls_of):
    return np.isin(lab, [i for i, c in cls_of.items() if c == "heat"])


def pair(a, hm, k, label):
    b = recolour(a, hm)
    ys, xs = np.nonzero(a[..., 3] > 0)
    x0, x1, y0, y1 = max(xs.min() - 4, 0), min(xs.max() + 5, a.shape[1]), max(ys.min() - 4, 0), min(ys.max() + 5, a.shape[0])
    ims = []
    for arr in (a, b):
        bg = Image.new("RGBA", (a.shape[1], a.shape[0]), (40, 40, 48, 255))
        bg.alpha_composite(Image.fromarray(arr))
        ims.append(bg.crop((x0, y0, x1, y1)).resize(((x1 - x0) * k, (y1 - y0) * k), Image.NEAREST).convert("RGB"))
    s = Image.new("RGB", (ims[0].width * 2 + 8, ims[0].height + 20), (20, 20, 24))
    s.paste(ims[0], (0, 0))
    s.paste(ims[1], (ims[0].width + 8, 0))
    d = ImageDraw.Draw(s)
    d.text((4, s.height - 16), f"CURRENT | PROPOSED (heat -> amber)  {label}  {k}x", fill=(230, 230, 230))
    return s, int(hm.sum())


def stack(imgs):
    st = Image.new("RGB", (max(i.width for i in imgs), sum(i.height for i in imgs) + 4 * len(imgs)), (20, 20, 24))
    y = 0
    for i in imgs:
        st.paste(i, (0, y))
        y += i.height + 4
    return st


showcase = {}
for w in B["ORDER"]:
    if not any(c == "heat" for _, _, c, _ in B["SPEC"].get(w, [])):
        continue
    f = B["D"][w]["file"]
    a, m, lab = B["labelled"](f)
    cls_of = {i: c for ids, _, c, _ in B["SPEC"][w] for i in ids}
    showcase[w] = (a, heat_mask(lab, cls_of), f.replace(B["ROOT"], ""), lab, cls_of)

inplay = {}
HELD_ORDER = HB["NAMED"] + ["chainsaw", "hand_cannon", "pistol", "katana", "electro_baton", "plasma_rifle", "mini_nuke_empty",
                            "rocket_launcher_empty", "mini_nuke_small", "rocket_launcher_small"]
for w in HELD_ORDER:
    rules = HB["HELD"].get(w, [])
    if w == "rocket_launcher_empty":
        rules = []
    if w in ("mini_nuke_small", "rocket_launcher_small"):
        rules = HB["HELD"]["rocket_launcher"] if w.startswith("rocket") else HB["HELD"]["mini_nuke"][:1]
    runs = [(f"held_55/{w}.png", HB["held_path"](w), False, rules, (), 2)]
    if w in HB["CELL"]:
        r, col = HB["CELL"][w]
        runs.append((f"p70 rivet_eq_{w}_left.png cell 0", HB["cell_path"](w), True, r, col, 4))
    for rel, path, cell, rl, col, k in runs:
        a, lab, cls_of, _ = HB["run"](w, path, cell, rl, col)
        hm = heat_mask(lab, cls_of)
        if hm.any():
            inplay.setdefault(w, []).append((a, hm, rel, k))

weapons = [w for w in B["ORDER"] + HELD_ORDER if w in showcase or w in inplay]
weapons = list(dict.fromkeys(weapons))
rows, stills, danger_changed = [], [], 0
for w in weapons:
    imgs, npx_s, npx_p = [], 0, []
    if w in showcase:
        a, hm, rel, lab, cls_of = showcase[w]
        s, n = pair(a, hm, 4, f"{w} {rel}")
        imgs.append(s)
        npx_s = n
        dm = np.isin(lab, [i for i, c in cls_of.items() if c == "danger"])
        danger_changed += int((recolour(a, hm)[dm] != a[dm]).any())
    for a, hm, rel, k in inplay.get(w, []):
        s, n = pair(a, hm, k, f"{w} {rel}")
        imgs.append(s)
        npx_p.append(f"{n} ({rel.split(' ')[0].replace('held_55/', 'held_55 ')}{' cell' if 'cell' in rel else ''})")
    st = stack(imgs)
    st.save(OUT + f"preview_{w}_4x.png")
    stills.append(st)
    rows.append(f"| {w} | {npx_s if w in showcase else '-'} | {', '.join(npx_p) or '-'} |")
CW = 1600
rs = [s.resize((CW, max(1, int(s.height * CW / s.width))), Image.NEAREST) for s in stills]
sheet = Image.new("RGB", (CW, sum(r.height for r in rs)), (20, 20, 24))
y = 0
for r in rs:
    sheet.paste(r, (0, y))
    y += r.height
sheet.save(OUT + "preview_contact_4x.png")
print(f"danger parts changed: {danger_changed}")
print("\n".join(rows))
