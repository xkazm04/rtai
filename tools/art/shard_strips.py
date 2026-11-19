"""Cut the shard cartridge and strips from their catalogued masters (no mirrored poses).

python tools/art/shard_strips.py <n19/guns/masters>
The main facings come from the original keyed library. Both diagonal twins use the lit
master's bounds; the rectangles below isolate the small shard beyond each funnel.
"""
import json
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

from assault_rifle_parts import keyed, size
from assault_rifle_strips import diagonal_row

GUN = "homing_shard"
CUT = Path(__file__).with_name("rivet_frames.py")
VIEW = Path("project/features/characters/art/view")
PART = Path("project/features/combat/weapons/art") / GUN
# Local bounds in each 2x2 source tile, excluding the muzzle's copper lip.
SPARK = {
    "p55": [(401, 377, 455, 416), (502, 84, 558, 119),
            (108, 338, 161, 375), (4, 44, 54, 79)],
    "p70": [(478, 457, 523, 489), (531, 116, 570, 154),
            (98, 378, 138, 410), (70, 59, 110, 96)],
}


def diagonals(src, pitch, corrected):
    dark = np.array(src)
    for i, (x0, y0, x1, y1) in enumerate(SPARK[pitch]):
        x = (i % 2) * src.width // 2
        y = (i // 2) * src.height // 2
        dark[y+y0:y+y1, x+x0:x+x1] = 0
    # The away-left redraw puts the empty cable claw on the visible shoulder.
    src = src.copy()
    dark = Image.fromarray(dark)
    box = (src.width // 2, src.height // 2, src.width, src.height)
    h = src.crop(box).getbbox()
    height = h[3] - h[1]
    bounds = corrected.getbbox()
    body = corrected.crop(bounds)
    blank = corrected.copy()
    spark = (328, 298, 400, 343) if pitch == "p55" else (286, 276, 360, 324)
    blank.paste((0, 0, 0, 0), spark)
    blank = blank.crop(bounds)
    for sheet, figure in ((src, body), (dark, blank)):
        sheet.paste((0, 0, 0, 0), box)
        figure = size(figure, round(figure.width * height / figure.height))
        sheet.paste(figure, (box[0] + (src.width//2 - figure.width)//2, box[1] + h[1]))
    return diagonal_row(src), diagonal_row(dark)


def cut(src, out, row, pixels=None):
    args = [sys.executable, str(CUT), str(src), str(out), row["counts"], "--fig_h=" + str(row["fig_h"])]
    if "act_k" in row:
        args.append("--act_k=" + str(row["act_k"]))
    if pixels:
        args.append("--pixels=" + str(pixels))
    subprocess.run(args, check=True)


def main_twins(masters, pitch, manifest):
    name = "rivet_eq_" + GUN
    row = manifest["strips"][pitch][name]
    base = masters / f"{GUN}_{pitch}_original.png"
    cut(Path(manifest["library"]) / row["sheet"], base, row)
    image = Image.open(base).convert("RGBA")
    lit = np.array(image)
    dark = lit.copy()
    cw = image.width // 8
    height = image.height
    yy, xx = np.indices((height, cw))
    # Register the clean funnel face from original facing 0 by its centre,
    # horizontal/vertical radii and slant. Only the two firing apertures are resampled.
    if pitch == "p55":
        cap = (141, 93, 5.6, 14.2, 0.04)
        mouths = [(164, 85, 4.8, 14.8, -0.04), (136, 105, 11.3, 15.2, -0.12)]
    else:
        cap = (180, 157, 9.2, 19.5, -0.28)
        mouths = [(226, 131, 7.0, 21.0, -0.16), (141.5, 131, 19.5, 17.0, 0.0)]
    for i, (cx, cy, rx, ry, slant) in enumerate(mouths):
        start = (i + 5) * cw
        source = np.array(image)[:, start:start+cw]
        dst = dark[:, start:start+cw]
        u = (xx - cx - slant * (yy - cy)) / rx
        v = (yy - cy) / ry
        aperture = u*u + v*v <= 1.0
        if pitch == "p55":
            effect = (xx >= 169) if i == 0 else ((xx >= 130) & (yy >= 78) & (yy < 124)
                & (source[:, :, 2].astype(int) > source[:, :, 1].astype(int) + 12))
        else:
            effect = ((xx >= 227) & (yy > 92)) if i == 0 else (
                (xx >= 107) & (xx <= 171) & (yy >= 129)
                & ((abs(xx - cx) <= 15) | (yy >= 149)))
            light = source[:, :, 0].astype(float)*.30 + source[:, :, 1]*.60 + source[:, :, 2]*.10
            t = light / 255
            rim_light = aperture & ((u > -0.6) if i == 0 else (v > -0.7))
            color = (effect | rim_light) & (source[:, :, 3] > 0)
            violet = np.stack([74 + 181*t, 14 + 241*t**3, 120 + 135*t], axis=2)
            lit[:, start:start+cw, :3][color] = violet[color]
        dst[effect & ~aperture] = 0
        sx, sy, sw, sh, shear = cap
        # Sample the original aperture with a bilinear affine warp at native strip resolution.
        ax = sw/rx
        bx = (shear*sh/ry - ax*slant)
        transform = (ax, bx, sx-ax*cx-bx*cy, 0, sh/ry, sy-sh/ry*cy)
        replacement = np.asarray(image.transform((cw, height), Image.Transform.AFFINE, transform,
                                                  resample=Image.Resampling.BILINEAR))
        dst[aperture] = replacement[aperture]
    dest = VIEW / pitch
    if pitch == "p70":
        Image.fromarray(lit).save(dest / (name + ".png"), optimize=True)
    Image.fromarray(dark).save(dest / (name + "_noflash.png"), optimize=True)


def build(masters):
    man = json.loads(CUT.with_suffix(".json").read_text())
    mag = keyed(masters / (GUN + "_mag_raw.png"))
    mag = mag.crop(mag.getbbox())
    ImageOps.expand(size(mag, 62), 2).save(PART / "mag.png", optimize=True)
    for pitch in ("p55", "p70"):
        rows = man["strips"][pitch]
        for mode in ("diag", "reload", "reload_left"):
            stem = GUN + "_" + pitch + "_" + mode
            src = keyed(masters / (stem + "_raw.png"))
            key = masters / (stem + "_key.png")
            if mode == "diag":
                src, dark = diagonals(src, pitch, keyed(masters / (stem + "_corrected.png")))
                dark.save(masters / (stem + "_dark.png"))
            src.save(key)
            name = "rivet_eq_" + GUN + "_diag" if mode == "diag" else "rivet_reload_" + GUN + mode[6:]
            dest = VIEW / pitch / (name + ".png")
            cut(key, dest, rows[name])
            if mode == "diag":
                cut(key, dest.with_stem(name + "_noflash"), rows[name], masters / (stem + "_dark.png"))
        main_twins(masters, pitch, man)


if __name__ == "__main__":
    build(Path(sys.argv[1]))
