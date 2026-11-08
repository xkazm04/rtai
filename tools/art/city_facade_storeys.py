"""Cut the p70 storey sheets from the flat frontal elevations (n10 world, item 1).

A half-height wall shows fewer storeys, each at the elevation's own proportions, so the sheet
keeps one row per storey kind: the upper storey (none for the shop) above the ground storey,
three bays across. FacadeStrips stacks them from the ground up (city_facades.json `storeys`).

usage: python tools/art/city_facade_storeys.py <elevations_dir> <out_dir>
"""

import sys
from pathlib import Path

from PIL import Image

BAY_PX = 256  # a sheet bay's width; a storey keeps the elevation's bay : height aspect

# style -> (bay x edges, upper storey y band or None, ground storey y bands), elevation px
STYLES = {
    "tenement": ((0, 516, 1024, 1536), (261, 524), [(777, 1024)]),
    # the shop is one storey high at half height: its pale sign band and awning, then the door
    # and kick plate; the middle of the glass is cut out, a whole pane reads as a black band
    "shop": ((0, 510, 1030, 1536), None, [(505, 720), (830, 1024)]),
    "tall": ((0, 485, 960, 1448), (235, 370), [(845, 1086)]),
}


def bands_h(bands: list) -> int:
    return sum(b - a for a, b in bands)


def row(sheet: Image.Image, xs: tuple, bands: list, top: int, out: Image.Image, h: int) -> None:
    """Pastes the row's bands (stacked top to bottom) per bay, h px tall in all."""
    for i in range(3):
        cut = Image.new("RGB", (xs[i + 1] - xs[i], bands_h(bands)))
        y = 0
        for a, b in bands:
            cut.paste(sheet.crop((xs[i], a, xs[i + 1], b)), (0, y))
            y += b - a
        out.paste(cut.resize((BAY_PX, h), Image.LANCZOS), (BAY_PX * i, top))


def cut(src: Path, out_dir: Path, style: str) -> tuple:
    xs, upper, ground = STYLES[style]
    sheet = Image.open(src / f"facade_{style}.png").convert("RGB")
    bay_w = (xs[3] - xs[0]) / 3.0
    up_h = 0 if upper is None else round(BAY_PX * (upper[1] - upper[0]) / bay_w)
    gr_h = round(BAY_PX * bands_h(ground) / bay_w)
    out = Image.new("RGB", (BAY_PX * 3, up_h + gr_h))
    if upper is not None:
        row(sheet, xs, [upper], 0, out, up_h)
    row(sheet, xs, ground, up_h, out, gr_h)
    out.save(out_dir / f"facade_{style}_storeys.png")
    return up_h, gr_h


def main() -> None:
    src, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    for style in STYLES:
        up_h, gr_h = cut(src, out_dir, style)
        print(f"{style}: upper_h {up_h} ground_h {gr_h}")


if __name__ == "__main__":
    main()
