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
}
OUT = "project/features/combat/weapons/art/showcase"


def main() -> None:
    lib, ids = sys.argv[1], sys.argv[2].split(",")
    for wid in ids:
        for form, suffix in FORMS.items():
            suffix = SOURCE.get((wid, form), suffix)
            src = os.path.join(lib, "keyed", "weapon", f"{wid}_{suffix}.png")
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
