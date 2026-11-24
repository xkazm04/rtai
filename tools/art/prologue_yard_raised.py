"""Cut the n27 raised_line art: raised belt beams with their hanging appliances, strapped pallets,
the warm floor tile and the stains plate. Sources live in tools/art/prologue_yard_sources/n27.

python tools/art/prologue_yard_raised.py [--sources DIR]   (rewrites project/boot/prologue/art/raised_line)

A beam canvas is 5.4 x 1.2 m: a layout cover row with no skin and no rotation is drawn stretched
over its collision box (PrologueYardPaint.wreck), so the beam fills the box exactly. Hanging appliances are separate pieces under the beam's long edge; they do not block.
Prints the size in metres of every piece the dressing row places by footprint.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import prologue_yard_cut as cut

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "project/boot/prologue/art/raised_line"
PPM = 128
TIGHT = ("pallet_three", "pallet_double", "pallet_broken")
BOX_W, BOX_H, CANVAS_W = 5.4, 1.2, 5.4
SHADOW = (0x21, 0x1E, 0x1C)
WHITE = (255, 255, 255)
# section: (crop box x, y, w, h on raised-belt-top.png, source row where the beam ends)
SECTIONS = {
    "straight_a": ((30, 150, 860, 300), 336),
    "straight_b": ((905, 150, 840, 300), 336),
    "curve": ((30, 450, 860, 420), 752),
}
TORN = (905, 570, 840, 300)
VARIANTS = {
    "belt_straight_a": ("straight_a", None),
    "belt_straight_a_m": ("straight_a", Image.Transpose.FLIP_LEFT_RIGHT),
    "belt_straight_b": ("straight_b", None),
    "belt_curve_e": ("curve", Image.Transpose.FLIP_TOP_BOTTOM),
    "belt_curve_w": ("curve", Image.Transpose.ROTATE_180),
}


def keyed(sheet, box):
    crop = sheet.crop((box[0], box[1], box[0] + box[2], box[1] + box[3]))
    return np.asarray(cut.key_full(crop, WHITE, SHADOW))


def split_beam(rgba, split):
    """The beam canvas rows and the hanger strip under it, over the same columns."""
    solid = rgba[..., 3] == 255
    rows = np.where(solid[:split].sum(axis=1) > 3)[0]
    cols = np.where(solid[:split].sum(axis=0) > 3)[0]
    y0, x0, x1 = rows[0], cols[0], cols[-1] + 1
    margin = round((x1 - x0) * (CANVAS_W - BOX_W) / (2 * BOX_W))
    xs, xe = max(0, x0 - margin), min(rgba.shape[1], x1 + margin)
    hang = rgba[split:, xs:xe]
    used = np.where(hang[..., 3].max(axis=1) > 0)[0]
    hang = hang[: used[-1] + 1] if used.size else hang[:1]
    return Image.fromarray(rgba[y0:split, xs:xe]), Image.fromarray(hang), split - y0


def resized(image, width_m, height_m):
    return image.resize((round(width_m * PPM), max(1, round(height_m * PPM))), Image.Resampling.LANCZOS)


def belt(sheet, sizes):
    parts = {name: split_beam(keyed(sheet, box), split - box[1]) for name, (box, split) in SECTIONS.items()}
    for out, (src, turn) in VARIANTS.items():
        beam, hang, beam_rows = parts[src]
        if turn is not None:
            beam, hang = beam.transpose(turn), hang.transpose(turn)
        hang_m = hang.height * BOX_H / beam_rows
        resized(beam, CANVAS_W, BOX_H).save(OUT / f"{out}.png")
        resized(hang, CANVAS_W, hang_m).save(OUT / f"{out}_hang.png")
        sizes[out + "_hang_m"] = [CANVAS_W, round(hang_m, 3)]
    rgba = keyed(sheet, TORN)
    ys, xs = np.where(rgba[..., 3] == 255)
    whole = Image.fromarray(rgba[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1])
    canvas = Image.new("RGBA", (round(whole.width * CANVAS_W / BOX_W), whole.height))
    canvas.paste(whole, ((canvas.width - whole.width) // 2, 0))
    resized(canvas, CANVAS_W, BOX_H).save(OUT / "belt_torn.png")


def pallets(sheet, sizes):
    full = np.asarray(cut.key_full(sheet.convert("RGB"), WHITE, SHADOW))
    labels, _ = ndimage.label(ndimage.binary_dilation(full[..., 3] == 255, iterations=6))
    found = [(b[0].start, b[0].stop, b[1].start, b[1].stop) for b in ndimage.find_objects(labels)]
    found = [b for b in found if b[1] - b[0] > 150]
    ordered = sorted(b for b in found if b[0] < 500)
    ordered = sorted(ordered, key=lambda b: b[2]) + sorted((b for b in found if b[0] >= 500), key=lambda b: b[2])
    names = ["pallet_two", "pallet_three", "pallet_double", "pallet_toppled", "pallet_broken"]
    for name, (y0, y1, x0, x1) in zip(names, ordered):
        piece = Image.fromarray(full[y0:y1, x0:x1])
        piece = piece.resize((piece.width, round(piece.height * 0.75)), Image.Resampling.LANCZOS)
        scale = min(2.4 / piece.width, 1.6 / piece.height)
        art = resized(piece, piece.width * scale, piece.height * scale)
        tight = name in TIGHT  # collision box = the drawing for the extra stacks
        canvas = Image.new("RGBA", art.size if tight else (round(2.4 * PPM), round(1.6 * PPM)))
        canvas.paste(art, ((canvas.width - art.width) // 2, canvas.height - art.height))
        canvas.save(OUT / f"{name}.png")
        sizes[name + "_art_m"] = [round(piece.width * scale, 2), round(piece.height * scale, 2)]


def floors(sources):
    Image.open(sources / "floor-tile.png").convert("RGB").resize((768, 768), Image.Resampling.LANCZOS).save(
        OUT / "floor_tile.png"
    )
    Image.open(sources / "floor-stains.png").convert("RGB").save(OUT / "floor_stains.png")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources/n27")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    sizes = {}
    belt(Image.open(args.sources / "raised-belt-top.png").convert("RGB"), sizes)
    pallets(Image.open(args.sources / "pallet-stacks.png"), sizes)
    floors(args.sources)
    print(json.dumps(sizes, indent=1))


if __name__ == "__main__":
    main()
