"""Packs the library's king_robe cells (assets it108: the King's long drawn robe from the waist down, the
king_legs layout cell for cell: 5 facings x [standing + a 4-frame walk]) into the game's legs grid at
each pitch: the same cell size as art/p<pitch>/king_legs.png, ONE scale per sheet (the legs' own: the
library standing height -> the game legs' standing height), soles on the legs' sole line (KingLegsCard
SOLE_Y 0.94), centred across the cell. Writes art/p<pitch>/king_robe.png.

    python tools/art/king_robe.py
"""

from pathlib import Path

from PIL import Image

LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/boss")
REPO = Path(__file__).resolve().parents[2]
ART = REPO / "project/features/bosses/king/art"
SOLE_Y = 0.94
# pitch -> (cells folder, the library legs sheet's standing height in px: deliveries/king_robe_it108.md)
SHEETS = {55: ("king_robe_55_cells", 180.0), 70: ("king_robe_70_v2_cells", 135.0)}


def legs_standing_px(legs: Image.Image) -> float:
    w, h = legs.width // 5, legs.height // 5
    tops = []
    for c in range(5):
        box = legs.crop((c * w, 0, (c + 1) * w, h)).getbbox()
        tops.append(box[3] - box[1])
    return sum(tops) / len(tops)


def pack(pitch: int) -> Path:
    folder, lib_standing = SHEETS[pitch]
    legs = Image.open(ART / f"p{pitch}/king_legs.png").convert("RGBA")
    cw, ch = legs.width // 5, legs.height // 5
    k = legs_standing_px(legs) / lib_standing
    sheet = Image.new("RGBA", legs.size, (0, 0, 0, 0))
    for r in range(5):
        for c in range(5):
            cell = Image.open(LIB / folder / f"{r + 1}_{c + 1}.png").convert("RGBA")
            size = (max(1, round(cell.width * k)), max(1, round(cell.height * k)))
            small = cell.resize(size, Image.Resampling.LANCZOS)
            x = c * cw + (cw - size[0]) // 2
            y = r * ch + round(ch * SOLE_Y) - size[1]
            sheet.alpha_composite(small, (x, max(r * ch, y)))
    out = ART / f"p{pitch}/king_robe.png"
    sheet.save(out, optimize=True)
    print(out.relative_to(REPO).as_posix(), legs.size, f"k={k:.3f}")
    return out


if __name__ == "__main__":
    for p in SHEETS:
        pack(p)
