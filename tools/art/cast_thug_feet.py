"""Robot thug A: the shoe foot line of every cut cell (his big claw cut out) against the cell's line.

In the down and down-right cells (and a few right / up-right attack, hit and fall cells) the claw
hangs as low as the shoes or lower. CUT names, per (sheet, pitch, facing column, drawing row), the
side and the percent of the cell's opaque width (alpha >= 128) that is the claw; the sole is the
lowest opaque row of what is left (the way cast_thug_soles.py cuts the claw from the eight-drawing
walk). cast_thug_pack.py stands those cells on that sole. Standing cells (walk, attack, hit, fall
drawing 0) are judged against the foot line (row FOOT); the fall's resting drawings (1, 2) by their
body bottom against the fall cell's ground row (the cell centre). `--review` writes overlays.
"""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

VIEW = Path(__file__).resolve().parents[2] / 'project/features/characters/art/view'
REVIEW = Path('C:/Users/kazda/kiro/gtai-art/foes-n29/thug/pack')
FOOT = 224
FACES = ('down', 'dr', 'right', 'ur', 'up')
ROWS = {'armed_walk': 4, 'attack': 4, 'hit': 1, 'fall': 3}
# (sheet, pitch, column, row): (lo, hi), the claw's span in percent of the cell's opaque width.
CUT = {}
for _row in range(4):
    CUT['armed_walk', 70, 0, _row] = (0, 47)
    CUT['armed_walk', 70, 1, _row] = (0, 50)
    CUT['armed_walk', 70, 2, _row] = (36, 100)
    CUT['armed_walk', 55, 0, _row] = (0, 38)
    CUT['armed_walk', 55, 1, _row] = (0, 40)
CUT.update({
    ('attack', 70, 0, 1): (0, 33), ('attack', 70, 0, 2): (0, 27),
    ('attack', 70, 1, 1): (0, 34), ('attack', 70, 1, 2): (0, 25),
    ('attack', 55, 0, 1): (0, 45), ('attack', 55, 0, 2): (0, 35),
    ('attack', 55, 1, 1): (14, 50), ('attack', 55, 1, 2): (18, 49),
    ('hit', 70, 0, 0): (0, 32), ('hit', 70, 1, 0): (0, 37),
    ('hit', 55, 0, 0): (0, 45), ('hit', 55, 1, 0): (0, 45),
    ('fall', 70, 0, 0): (0, 48), ('fall', 70, 1, 0): (0, 52),
    ('fall', 70, 2, 0): (26, 100), ('fall', 70, 3, 0): (28, 100),
    ('fall', 55, 0, 0): (0, 29), ('fall', 55, 1, 0): (0, 45),
})


def cut(mask, key):
    """The mask without the claw columns of CUT[key] (unchanged when the key has no cut)."""
    if key not in CUT:
        return mask
    xs = np.flatnonzero(mask.any(axis=0))
    lo, hi = (xs[0] + round((xs[-1] + 1 - xs[0]) * pct / 100) for pct in CUT[key])
    mask = mask.copy()
    mask[:, lo:hi] = False
    return mask


def bottom(mask):
    """One past the lowest opaque row."""
    return int(np.flatnonzero(mask.any(axis=1))[-1]) + 1


def cells(sheet, pitch):
    """(column, row, alpha mask, ground row) per cell of a shipped sheet."""
    alpha = np.array(Image.open(VIEW / f'p{pitch}/robot_thug_{sheet}.png').convert('RGBA'))[:, :, 3] >= 128
    rows = ROWS[sheet]
    ch, cw = alpha.shape[0] // rows, alpha.shape[1] // 5
    line = ch // 2 if sheet == 'fall' else FOOT
    for col in range(5):
        for row in range(rows):
            yield col, row, alpha[row * ch:(row + 1) * ch, col * cw:(col + 1) * cw], line


def measure(pitch):
    """Rows (sheet, pitch, facing, drawing, kind, gap, claw cut) where gap = line - bottom (+ above)."""
    out = []
    for sheet in ROWS:
        for col, row, mask, line in cells(sheet, pitch):
            resting = sheet == 'fall' and row > 0
            key = (sheet, pitch, col, row)
            low = bottom(mask if resting else cut(mask, key))
            kind = 'body' if resting else 'shoe'
            out.append((sheet, pitch, FACES[col], row, kind, line - low, CUT.get(key, '')))
    return out


def review(pitch, dest):
    """Every cell's bottom 100 rows at 2x: claw cut tinted red, the sole row cyan, the line magenta."""
    tiles = []
    for sheet in ROWS:
        rgba = np.array(Image.open(VIEW / f'p{pitch}/robot_thug_{sheet}.png').convert('RGBA'))
        rows = ROWS[sheet]
        ch, cw = rgba.shape[0] // rows, rgba.shape[1] // 5
        for col, row, mask, line in cells(sheet, pitch):
            kept = cut(mask, (sheet, pitch, col, row))
            px = rgba[row * ch:(row + 1) * ch, col * cw:(col + 1) * cw].copy()
            px[mask & ~kept] = (220, 40, 40, 255)
            im = Image.new('RGBA', (cw, ch), (150, 150, 150, 255))
            im.alpha_composite(Image.fromarray(px))
            draw = ImageDraw.Draw(im)
            draw.line((0, line, cw, line), fill=(255, 0, 255, 255))
            draw.line((0, bottom(kept) - 1, cw, bottom(kept) - 1), fill=(0, 230, 230, 255))
            draw.text((3, line - 98), f'{sheet} {FACES[col]} {row}', fill=(255, 255, 255, 255))
            tile = im.crop((0, line - 100, cw, line + 4))
            tiles.append(tile.resize((tile.width * 2, tile.height * 2), Image.Resampling.NEAREST))
    width, height = max(t.width for t in tiles), tiles[0].height
    plate = Image.new('RGB', (width * 4, height * ((len(tiles) + 3) // 4)))
    for i, tile in enumerate(tiles):
        plate.paste(tile.convert('RGB'), ((i % 4) * width, (i // 4) * height))
    plate.save(dest)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    print('| sheet | pitch | facing | drawing | measured | gap (texels, + above the line) | claw cut |')
    print('|---|---|---|---|---|---|---|')
    worst = {}
    for pitch in (70, 55):
        for sheet, p, face, row, kind, gap, claw in measure(pitch):
            print(f'| {sheet} | {p} | {face} | {row} | {kind} | {gap} | {claw} |')
            worst[sheet, p, kind] = max(worst.get((sheet, p, kind), 0), abs(gap))
        if args.review:
            REVIEW.mkdir(parents=True, exist_ok=True)
            review(pitch, REVIEW / f'feet_{pitch}.png')
    for (sheet, p, kind), gap in worst.items():
        print(f'worst |gap| {sheet} {p} {kind}: {gap}')


if __name__ == '__main__':
    main()
