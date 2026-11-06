"""Cut the city's south-face wall strips from the assets library's facade kits (n8 city lane).

Each style is one horizontal strip of wall bays (the top-row pieces' walls, below the roof
plane, inside the pieces' side outlines), so a building's south face is tiled bay by bay
(FacadeArt). The roof itself stays the game's top-down roof art, lifted by the view.

usage: python tools/art/city_facade_cut.py <library_root> <out_dir>
"""

import sys
from pathlib import Path

from PIL import Image

# style -> (sheet, [(x0, x1) per bay piece], (y0, y1) wall band, side inset px)
STYLES = {
    "tenement": (
        "keyed/building/facade_kit_55_untapered.png",
        [(73, 354), (442, 724), (812, 1094)],
        (172, 686),
        15,
    ),
    "shop": (
        "keyed/building/facade_shop_55_untapered.png",
        [(38, 381), (410, 754), (782, 1128)],
        (238, 616),
        12,
    ),
}
BAY_W = 256


def cut(lib: Path, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    for style, (sheet, bays, (y0, y1), inset) in STYLES.items():
        src = Image.open(lib / sheet).convert("RGBA")
        h = round((y1 - y0) * BAY_W / (bays[0][1] - bays[0][0] - 2 * inset))
        strip = Image.new("RGBA", (BAY_W * len(bays), h), (0, 0, 0, 0))
        for i, (x0, x1) in enumerate(bays):
            piece = src.crop((x0 + inset, y0, x1 - inset, y1))
            strip.paste(piece.resize((BAY_W, h), Image.LANCZOS), (i * BAY_W, 0))
        # opaque wall: fill any keyed hole (the stoop's steps overhang) with the base's ink
        px = strip.load()
        for y in range(h):
            for x in range(strip.width):
                r, g, b, a = px[x, y]
                if a < 255:
                    k = a / 255.0
                    px[x, y] = (int(r * k + 23 * (1 - k)), int(g * k + 19 * (1 - k)),
                                int(b * k + 27 * (1 - k)), 255)
        strip.save(out / f"facade_{style}.png")
        print(style, strip.size)


if __name__ == "__main__":
    cut(Path(sys.argv[1]), Path(sys.argv[2]))
