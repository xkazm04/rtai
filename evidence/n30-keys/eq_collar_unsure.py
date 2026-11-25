"""n30-20: contact sheets (cell | rigid reference, 4x NEAREST neck crop) for the UNSURE collar cells.
Run: python -I evidence/n30-keys/eq_collar_unsure.py   (from the worktree root)"""
from PIL import Image, ImageDraw
import numpy as np

V = "project/features/characters/art/view/p70/"
OUT = "C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/"
K, CW, CH = 4, 76, 48


def cell(path, cols, rows, r, c):
    im = Image.open(V + path).convert("RGBA")
    w, h = im.size
    cw, ch = w // cols, h // rows
    return im.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))


def centre(cl):
    a = np.array(cl).astype(int)
    m = (a[..., 3] > 200) & (a[..., 0] > 200) & (a[..., 1] > 55) & (a[..., 1] < 125) & (a[..., 2] < 60)
    m[int(m.shape[0] * 0.7):] = False
    ys, xs = np.nonzero(m)
    if len(xs) < 12:
        return None
    return int(np.median(xs)), int(np.median(ys))


def tile(cl, label):
    c = centre(cl)
    t = Image.new("RGBA", (CW * K, CH * K), (60, 60, 60, 255))
    if c:
        bg = Image.new("RGBA", cl.size, (128, 128, 140, 255))
        bg.alpha_composite(cl)
        x, y = c
        bg = bg.crop((x - CW // 2, y - CH // 2, x + CW // 2, y + CH // 2))
        t = bg.resize((CW * K, CH * K), Image.NEAREST)
    ImageDraw.Draw(t).text((3, 3), label + ("" if c else " (no collar px)"), fill=(255, 255, 0, 255))
    return t


# (sheet, strip file, cols, rows, [(r,c)], reference file, ref cols, ref rows, ref (r,c) rule)
# ref rule: "same" = same r,c ; ("fix", r, c) = fixed ref cell
SPECS = [
    ("gatling_eq", "rivet_eq_gatling.png", 8, 1, [(0, c) for c in (0, 1, 3, 5, 7)], "rivet_eq_pistol.png", 8, 1, "same"),
    ("mini_nuke_eq", "rivet_eq_mini_nuke.png", 8, 1, [(0, c) for c in (1, 3, 5, 7)], "rivet_eq_pistol.png", 8, 1, "same"),
    ("electro_gun_diag", "rivet_eq_electro_gun_diag.png", 4, 1, [(0, 0), (0, 2)], "rivet_eq_hand_cannon_diag.png", 4, 1, "same"),
    ("flamethrower_left", "rivet_eq_flamethrower_left.png", 3, 1, [(0, 2)], "rivet_eq_gloria_left.png", 3, 1, "same"),
    ("reload_gatling", "rivet_reload_gatling.png", 8, 1, [(0, c) for c in range(8)], "rivet_reload_pistol.png", 8, 1, "same"),
    ("run8_eq_plasma_sword", "rivet_run8_eq_plasma_sword.png", 8, 8, [(2, 4), (3, 1), (5, 5)], "rivet_run8.png", 8, 8, "same"),
    ("run8_eq_assault_rifle", "rivet_run8_eq_assault_rifle.png", 8, 8, [(2, 4)], "rivet_run8.png", 8, 8, "same"),
    ("walk_eq_electro_baton", "rivet_walk_eq_electro_baton.png", 4, 8, [(r, c) for r in range(6) for c in range(4)], "rivet_walk_eq_gloria.png", 4, 8, "same"),
]


def main() -> None:
    for name, f, cols, rows, cells, rf, rcols, rrows, _rule in SPECS:
        pairs = []
        for r, c in cells:
            a = tile(cell(f, cols, rows, r, c), f"{name} r{r}c{c}")
            b = tile(cell(rf, rcols, rrows, r, c), f"ref {rf[:-4][6:]} r{r}c{c}")
            row = Image.new("RGBA", (a.width * 2 + 6, a.height), (20, 20, 20, 255))
            row.paste(a, (0, 0))
            row.paste(b, (a.width + 6, 0))
            pairs.append(row)
        per = 8 if name == "walk_eq_electro_baton" else len(pairs)
        n = 0
        for i in range(0, len(pairs), per):
            chunk = pairs[i:i + per]
            S = Image.new("RGB", (chunk[0].width, len(chunk) * (chunk[0].height + 4)), (20, 20, 20))
            for j, p in enumerate(chunk):
                S.paste(p.convert("RGB"), (0, j * (p.height + 4)))
            suffix = "" if len(pairs) <= per else f"_{n}"
            S.save(f"{OUT}unsure_{name}{suffix}_4x.png")
            n += 1


main()
