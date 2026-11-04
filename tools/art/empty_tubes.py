"""Empty tubes for the rocket launcher and the mini-nuke (weapon-art lane, iteration 9, 2026-11-04;
rivet-arsenal REQUEST 11).

The held parts show the striped warhead in the tube at all times, also right after the shot and
through the reload, while RivetMagView already carries the next rocket in the off claw. `held_empty`
is the same part with the warhead cut away just past the front band's ink edge and an open mouth
inked in its place (an ink rim around a near-black bore, squashed edge-on as seen from above), on
the SAME canvas: grip_px, muzzle_px, length_px and size_px stay valid, so a view swaps the texture
and nothing else. Cut columns were measured on the held parts (the front band's ink column).

    python tools/art/empty_tubes.py <weapon_art_dir>
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw

INK = (27, 21, 23)
BORE = (44, 37, 39)
SS = 4
# weapon id -> first column past the front band's ink edge (part px)
CUTS = {"rocket_launcher": 461, "mini_nuke": 350}


def _extent(px, x, h):
    ys = [y for y in range(h) if px[x, y][3] > 200]
    return ys[0], ys[-1]


def empty(src, dst, cut):
    im = Image.open(src).convert("RGBA")
    w, h = im.size
    px = im.load()
    top, bot = _extent(px, cut - 1, h)
    for x in range(cut, w):
        for y in range(h):
            px[x, y] = (0, 0, 0, 0)
    cy, ry = (top + bot) / 2, (bot - top) / 2 - 7
    big = Image.new("RGBA", (w * SS, h * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    rx = 11
    d.ellipse([(cut - rx) * SS, (cy - ry) * SS, (cut + rx) * SS, (cy + ry) * SS], fill=INK + (255,))
    d.ellipse([(cut - rx + 4) * SS, (cy - ry + 6) * SS, (cut + rx - 5) * SS, (cy + ry - 6) * SS], fill=BORE + (255,))
    mouth = big.resize((w, h), Image.LANCZOS)
    # the mouth sits on the band's face: only its front half shows past the band
    front = Image.new("L", (w, h), 0)
    ImageDraw.Draw(front).rectangle([cut - 4, 0, w, h], fill=255)
    im.paste(mouth, (0, 0), Image.composite(mouth.getchannel("A"), Image.new("L", (w, h), 0), front))
    im.save(dst)
    return [w, h]


if __name__ == "__main__":
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art")
    for wid, cut in CUTS.items():
        print(wid, empty(root / wid / "held.png", root / wid / "held_empty.png", cut))
