"""King's press plates (lane n7-king it8), drawn in the King parts' own steel, no generation.

The target (BOSSES.md, boss_king.jpg; the original REG-1): "two piston arms ending in flat press
plates" and a shoulder megaphone. KingPlan inherited Rivet's claw hand (left) and a megaphone
forearm (right), so on foot he read as a claw and a horn. This writes into art/king/:
    press_plate.png      the left hand cell: a short ram stub and a wide flat plate across the arm
    r_forearm_press.png  the right forearm: the left piston (l_forearm) with the same plate on its end
    megaphone.png        the megaphone horn cut from r_forearm.png, worn on the right shoulder
and adds their parts.json entries (sizes, pivots). The steel greys stay greys: the boss print's
gold swap (KingRigs.GOLD_SWAP) gilds the arms in game, the part art never carries the gold.

    python tools/art/king_press_parts.py
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

ART = Path("project/features/characters/art/king")
SS = 4  # supersampling for the anti-aliased ink edges
INK = (27, 21, 23, 255)
STEEL = (150, 128, 132, 255)
STEEL_HI = (196, 176, 178, 255)
STEEL_LO = (112, 92, 98, 255)
RIVET = (214, 196, 194, 255)
## The plate: length along the arm and span across it (px of the cell), and the ram stub's length.
## Seen from straight above a press plate shows its broad striking face (it presses down), so it is
## a near-square block (the target's square fists), not the thin bar of its edge (58 x 196, it8a).
PLATE_LEN = 150
PLATE_SPAN = 186
STUB_LEN = 34
STUB_W = 46


def _plate(d: ImageDraw.ImageDraw, x0: float, cy: float, s: int) -> None:
    """A flat plate whose arm-side face starts at x0 (cell px), centred on cy."""
    h = PLATE_SPAN / 2
    box = [x0 * s, (cy - h) * s, (x0 + PLATE_LEN) * s, (cy + h) * s]
    d.rounded_rectangle(box, radius=10 * s, fill=INK)
    inner = [box[0] + 7 * s, box[1] + 7 * s, box[2] - 7 * s, box[3] - 7 * s]
    d.rounded_rectangle(inner, radius=6 * s, fill=STEEL)
    face = [inner[0] + 6 * s, inner[1] + 6 * s, inner[2] - 18 * s, inner[3] - 6 * s]
    d.rectangle(face, fill=STEEL_HI)
    d.rectangle([inner[2] - 16 * s, inner[1], inner[2], inner[3]], fill=STEEL_LO)  # the leading edge
    for k in (-0.22, 0.22):  # two ribs along the arm, one across: the striking face's grid
        y = (cy + k * PLATE_SPAN) * s
        d.rectangle([face[0], y - 3 * s, face[2], y + 3 * s], fill=INK)
    xm = (face[0] + face[2]) / 2
    d.rectangle([xm - 3 * s, face[1], xm + 3 * s, face[3]], fill=INK)
    for ky in (-0.4, 0.4):
        for kx in (0.14, 0.78):
            x, y = (x0 + kx * PLATE_LEN) * s, (cy + ky * PLATE_SPAN) * s
            d.ellipse([x - 6 * s, y - 6 * s, x + 6 * s, y + 6 * s], fill=INK)
            d.ellipse([x - 3.5 * s, y - 3.5 * s, x + 3.5 * s, y + 3.5 * s], fill=RIVET)


def _stub(d: ImageDraw.ImageDraw, x0: float, x1: float, cy: float, s: int) -> None:
    h = STUB_W / 2
    d.rectangle([x0 * s, (cy - h) * s, x1 * s, (cy + h) * s], fill=INK)
    d.rectangle([x0 * s, (cy - h + 6) * s, x1 * s, (cy + h - 6) * s], fill=STEEL)
    d.rectangle([x0 * s, (cy - 5) * s, x1 * s, (cy + 5) * s], fill=STEEL_HI)


def _down(img: Image.Image) -> Image.Image:
    return img.resize((img.width // SS, img.height // SS), Image.LANCZOS)


def press_plate() -> dict:
    """The hand cell: pivot_a at the stub's root (the wrist), pivot_b at the plate's face."""
    w, hgt = 26 + STUB_LEN + PLATE_LEN + 8, PLATE_SPAN + 12
    cy = hgt / 2
    img = Image.new("RGBA", (w * SS, hgt * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([4 * SS, (cy - 22) * SS, 48 * SS, (cy + 22) * SS], fill=INK)  # the wrist socket
    d.ellipse([10 * SS, (cy - 16) * SS, 42 * SS, (cy + 16) * SS], fill=STEEL_HI)
    _stub(d, 26, 26 + STUB_LEN + 6, cy, SS)
    _plate(d, 26 + STUB_LEN, cy, SS)
    _down(img).save(ART / "press_plate.png")
    return _entry((w, hgt), (26.0, cy), (26.0 + STUB_LEN + PLATE_LEN, cy))


def forearm_press(meta: dict) -> dict:
    """The left piston (mirrored across the arm for the right side) with the plate on its end."""
    src = Image.open(ART / "l_forearm.png").convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
    pa, pb = meta["l_forearm"]["pivot_a"], meta["l_forearm"]["pivot_b"]
    w, hgt = int(pb[0]) + STUB_LEN + PLATE_LEN + 8, PLATE_SPAN + 12
    cy = hgt / 2
    big = Image.new("RGBA", (w * SS, hgt * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    _stub(d, pb[0] - 10, pb[0] + STUB_LEN + 6, cy, SS)
    _plate(d, pb[0] + STUB_LEN, cy, SS)
    img = _down(big)
    oy = int(round(cy - (src.height - pa[1])))  # the flip moves the arm's axis to height - y
    img.alpha_composite(src, (0, oy))
    img.save(ART / "r_forearm_press.png")
    return _entry((w, hgt), (pa[0], cy), (pb[0], cy))


def megaphone() -> dict:
    """The horn and its clamp from r_forearm.png (x >= 290), pivot at the clamp (the shoulder)."""
    src = Image.open(ART / "r_forearm.png").convert("RGBA")
    horn = src.crop((292, 0, src.width, src.height))
    horn = horn.crop(horn.getbbox())
    horn.save(ART / "megaphone.png")
    return _entry(horn.size, (8.0, horn.height / 2), (float(horn.width), horn.height / 2))


def _entry(size: tuple, pa: tuple, pb: tuple) -> dict:
    return {
        "size": [int(size[0]), int(size[1])],
        "sheet": "tools/art/king_press_parts.py",
        "cell": 0,
        "scale": 1.0,
        "pivot_a": [float(pa[0]), float(pa[1])],
        "pivot_b": [float(pb[0]), float(pb[1])],
    }


def main() -> None:
    path = ART / "parts.json"
    meta = json.loads(path.read_text(encoding="utf-8"))
    meta["press_plate"] = press_plate()
    meta["r_forearm_press"] = forearm_press(meta)
    meta["megaphone"] = megaphone()
    path.write_text(json.dumps(meta, indent=1) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
