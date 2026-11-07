"""d9 seams: the sim bike's flat print for `top` (traffic atlas cell 9, the sim art id ART_BIKE).

No top-down bike exists in the library (vehicle_cards.py: "no top-down footprint"), so the print is
the bike card's tail facing at 70 (column 4 of row 9 of features/vehicles/art/p70/traffic_cards.png:
at a 70-degree pitch that view is nearly plan), turned nose to +x and scaled to BIKE_M (2.1 m long,
the side view's measured length) at the atlas's 80 px/m, centred in a 512 x 256 cell. Every traffic
atlas (intact, hijack, d1, d2; and the vehicles feature's wreck atlas) grows from 3 x 3 to 3 x 4
cells (1536 x 1024) with the bike at cell 9 = (0, 3); cells 10 and 11 stay empty. A bike has no
damage states: d1/d2/wreck repeat the intact print. Idempotent: re-running on a 3 x 4 atlas
rewrites cell 9.

usage: python tools/art/bike_top_print.py [--check]
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2] / "project"
CARDS = ROOT / "features/vehicles/art/p70/traffic_cards.png"
CARD_PX = 448  # vehicle card cell, 7 m at 64 px/m
CARD_PPM = 64.0
ATLASES = [
    ROOT / "features/city/art/vehicles/traffic_atlas.png",
    ROOT / "features/city/art/vehicles/traffic_atlas_hijack.png",
    ROOT / "features/city/art/vehicles/traffic_atlas_d1.png",
    ROOT / "features/city/art/vehicles/traffic_atlas_d2.png",
    ROOT / "features/vehicles/art/traffic_atlas_wreck.png",
]
CELL = (512, 256)
PPM = 80.0
BIKE_ROW, TAIL_COL = 9, 4
LENGTH_M = 2.1
CELL_ID = 9


def bike_print() -> Image.Image:
    sheet = Image.open(CARDS).convert("RGBA")
    x0, y0 = TAIL_COL * CARD_PX, BIKE_ROW * CARD_PX
    tail = sheet.crop((x0, y0, x0 + CARD_PX, y0 + CARD_PX))
    tail = tail.crop(tail.getchannel("A").getbbox())
    top = tail.rotate(-90, expand=True)  # nose away (screen up) -> nose to +x
    w = round(LENGTH_M * PPM)
    h = max(1, round(top.height * PPM / CARD_PPM))  # the width keeps the card's scale
    return top.resize((w, h), Image.LANCZOS)


def place(atlas_path: Path, bike: Image.Image) -> Image.Image:
    src = Image.open(atlas_path).convert("RGBA")
    out = Image.new("RGBA", (CELL[0] * 3, CELL[1] * 4), (0, 0, 0, 0))
    out.paste(src.crop((0, 0, CELL[0] * 3, CELL[1] * 3)), (0, 0))
    cx, cy = (CELL_ID % 3) * CELL[0], (CELL_ID // 3) * CELL[1]
    out.paste((0, 0, 0, 0), (cx, cy, cx + CELL[0], cy + CELL[1]))
    out.alpha_composite(bike, (cx + (CELL[0] - bike.width) // 2, cy + (CELL[1] - bike.height) // 2))
    return out


def main() -> int:
    bike = bike_print()
    bad = 0
    for p in ATLASES:
        out = place(p, bike)
        if "--check" in sys.argv:
            same = Image.open(p).convert("RGBA").tobytes() == out.tobytes()
            print(("ok   " if same else "DIFF ") + str(p.relative_to(ROOT)))
            bad += 0 if same else 1
        else:
            out.save(p)
            print("wrote", p.relative_to(ROOT), out.size, "bike", bike.size)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
