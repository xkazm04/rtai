"""Re-composes the kerb ground art for the 12 m street (owner call C1, ask visual-fixes-1 B).

Today's kerb tile is 8 m: 3 m of sidewalk, the kerb stone at ~3.0-3.2 m, then ~4.8 m of asphalt.
The narrow tile keeps the 8 m grid and the 8 m lane tile: 6 m of sidewalk (3 m of extra paving cut
from sidewalk_tone, then today's 3.2 m), then 2.0 m of asphalt (today's rows just past the kerb).
The corner tile is today's corner shifted 2.79 m toward the street, the L above and left of it
filled from the new straight tile (and its quarter turn), so every edge profile matches.
Usage: python tools/art/narrow_kerb.py   (run from the repo root; PIL only)
"""
from PIL import Image

G = "project/features/city/art/ground/"
PX = 96  # px per metre
KERB_END = 308  # row where the kerb stone ends in today's kerb art
ROAD_PX = 2 * PX  # 2.0 m of asphalt
EXTRA = 768 - KERB_END - ROAD_PX  # rows of added paving (268 = 2.79 m)


def straight(name: str) -> Image.Image:
    src = Image.open(G + name + ".png").convert("RGBA")
    paving = Image.open(G + "sidewalk_tone.png").convert("RGBA")
    out = Image.new("RGBA", (768, 768))
    out.paste(paving.crop((0, 384 - EXTRA, 768, 384)), (0, 0))  # ends before the slab joint at 384
    out.paste(src.crop((0, 0, 768, KERB_END + ROAD_PX)), (0, EXTRA))
    return out


def corner(s: Image.Image) -> Image.Image:
    src = Image.open(G + "curb_corner_tone.png").convert("RGBA")
    r = s.transpose(Image.Transpose.ROTATE_90)  # sidewalk on the left
    out = Image.new("RGBA", (768, 768))
    out.paste(r, (0, 0))
    out.paste(s.crop((0, 0, EXTRA, 768)), (0, 0))
    out.paste(src.crop((0, 0, 768 - EXTRA, 768 - EXTRA)), (EXTRA, EXTRA))
    return out


names = ["curb_straight_tone", "curb_straight_tone_b", "curb_straight_tone_c"]
tiles = [straight(n) for n in names]
for n, im in zip(names, tiles):
    im.save(G + n.replace("curb_", "curb12_") + ".png")
corner(tiles[0]).save(G + "curb12_corner_tone.png")
print("ok")
