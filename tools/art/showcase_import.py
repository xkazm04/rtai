"""Bring the asset library's showcase cuts into the game (n8-hud, WeaponShowcase):
library keyed/weapon/<id>_<70|55|icon>.png -> features/combat/weapons/art/showcase/<p70|p55|icon>/<id>.png,
alpha-trimmed and scaled to at most MAX_W px wide (the views size them by the weapon's length).
A per-weapon SOURCE override takes another pitch's cut where the library says its own is not true
(the assets lane, 20:57: weapon_showcase_long_70's column 1 is a near side view: use the 55).

usage: python tools/art/showcase_import.py <library_dir> <id>[,<id>...]
"""
import os
import sys
from PIL import Image

MAX_W = 384
FORMS = {"p70": "70", "p55": "55", "icon": "icon"}
# (id, form) -> library suffix to read instead
SOURCE = {
    ("gloria", "p70"): "55",
    ("plasma_rifle", "p70"): "55",
    ("gatling", "p70"): "55",
    # the assets lane, 21:0x: weapon_showcase_heavy's icon column is washed-out cream; cut from 70
    ("rocket_launcher", "icon"): "70",
    ("flamethrower", "icon"): "70",
    # n8-hud it12: the assets lane's 0505 raise (B, hud's REQUEST): the chainsaw's top plane shows
    ("chainsaw", "p70"): "70_v2",
}
# (id, form) -> (library sheet, column, row): a cell cut straight from a sheet the library has not
# cut per weapon. n8-hud it19: weapon_showcase_heavy_70_v3 (0745, B) fixed column 3 (the icon) to
# the rust/brass of columns 1-2 ("for the HUD the icon column is now usable as is").
SHEET = {
    ("rocket_launcher", "icon"): ("keyed/improve/weapon_showcase_heavy_70_v3.png", 2, 0),
    ("flamethrower", "icon"): ("keyed/improve/weapon_showcase_heavy_70_v3.png", 2, 1),
    ("molotov", "icon"): ("keyed/improve/weapon_showcase_heavy_70_v3.png", 2, 2),
}
OUT = "project/features/combat/weapons/art/showcase"


def _runs(mask: list) -> list:
    out, start = [], None
    for i, on in enumerate(mask + [False]):
        if on and start is None:
            start = i
        elif not on and start is not None:
            out.append((start, i))
            start = None
    return out


def _cell(lib: str, sheet: str, col: int, row: int) -> Image.Image:
    """The (col, row) figure of a keyed sheet: the alpha's column and row runs are the grid."""
    im = Image.open(os.path.join(lib, sheet)).convert("RGBA")
    a = im.getchannel("A").point(lambda v: 255 if v >= 16 else 0)
    w, h = im.size
    px = a.load()
    xs = _runs([any(px[x, y] for y in range(0, h, 2)) for x in range(w)])
    ys = _runs([any(px[x, y] for x in range(0, w, 2)) for y in range(h)])
    return im.crop((xs[col][0], ys[row][0], xs[col][1], ys[row][1]))


def main() -> None:
    lib, ids = sys.argv[1], sys.argv[2].split(",")
    for wid in ids:
        for form, suffix in FORMS.items():
            suffix = SOURCE.get((wid, form), suffix)
            src = os.path.join(lib, "keyed", "weapon", f"{wid}_{suffix}.png")
            if (wid, form) in SHEET:
                sheet, col, row = SHEET[(wid, form)]
                src = f"{os.path.join(lib, sheet)}[{col},{row}]"
                im = _cell(lib, sheet, col, row)
            else:
                im = Image.open(src).convert("RGBA")
            box = im.getchannel("A").point(lambda v: 255 if v >= 16 else 0).getbbox()
            im = im.crop(box) if box else im
            if im.width > MAX_W:
                im = im.resize((MAX_W, round(im.height * MAX_W / im.width)), Image.LANCZOS)
            os.makedirs(os.path.join(OUT, form), exist_ok=True)
            im.save(os.path.join(OUT, form, f"{wid}.png"))
            print(f"{src} -> {OUT}/{form}/{wid}.png {im.size}")


if __name__ == "__main__":
    main()
