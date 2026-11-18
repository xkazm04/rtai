"""Cut the ray gun's independently drawn poses at the neighbours' 165 texture px.

python tools/art/ray_strips.py <n19/guns/masters>
The magenta key keeps the projectile's lime. Lit and dark share the lit cut geometry.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage

from assault_rifle_parts import size
from assault_rifle_strips import diagonal_row
from shard_strips import CUT, VIEW, cut

GUN = "ray_gun"


def keyed(path):
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(float)
    red, green, blue = rgb.transpose(2, 0, 1)
    spill = np.minimum(red, blue) - green
    alpha = 255 - np.clip((spill - 8) * 4, 0, 255)
    rgb[:, :, 0] -= np.maximum(spill - 8, 0)
    rgb[:, :, 2] -= np.maximum(spill - 8, 0)
    rgba = np.dstack((rgb, alpha)).clip(0, 255).astype(np.uint8)
    rgba[alpha == 0] = 0
    return Image.fromarray(rgba)


def remove_detached(tile):
    # The dash is isolated by the reference sheet's gutter. Preserve all attached ink.
    rgba = np.array(tile)
    labels, _ = ndimage.label(rgba[:, :, 3] > 24)
    sizes = np.bincount(labels.ravel())
    body = labels == (1 + np.argmax(sizes[1:]))
    rgba[~ndimage.binary_dilation(body, iterations=2)] = 0
    return Image.fromarray(rgba)


def lime(light):
    # Stops sampled from the shipped colour/ray_beam_0 sprite, dark edge to white core.
    stops = [[123, 217, 43], [134, 228, 54], [217, 255, 110], [253, 255, 234]]
    return np.stack([np.interp(light, [0, .60, .92, 1], channel) for channel in zip(*stops)], axis=-1)


def diagonals(src, corrected):
    src = src.copy()
    box = (src.width//2, src.height//2, src.width, src.height)
    old = src.crop(box).getbbox()
    corrected = corrected.crop(corrected.getbbox())
    corrected = size(corrected, round(corrected.width*(old[3]-old[1])/corrected.height))
    src.paste((0, 0, 0, 0), box)
    src.paste(corrected, (box[0]+(src.width//2-corrected.width)//2, box[1]+old[1]))
    dark = src.copy()
    for i in range(4):
        x, y = i % 2, i // 2
        bounds = (x*src.width//2, y*src.height//2, (x+1)*src.width//2, (y+1)*src.height//2)
        lit = np.array(src.crop(bounds))
        clean = remove_detached(src.crop(bounds))
        dash = (lit[:, :, 3] > 0) & (np.asarray(clean)[:, :, 3] == 0)
        light = lit[dash, :3].astype(float) @ np.array([.3, .6, .1]) / 255
        lit[dash, :3] = lime(light)
        src.paste(Image.fromarray(lit), bounds)
        dark.paste(clean, bounds)
    return diagonal_row(src), diagonal_row(dark)


def main_twins(masters, pitch, man):
    name = "rivet_eq_" + GUN
    row = man["strips"][pitch][name]
    base = masters / f"{GUN}_{pitch}_original.png"
    cut(Path(man["library"]) / row["sheet"], base, row)
    image = Image.open(base).convert("RGBA")
    lit = np.array(image)
    dark = lit.copy()
    cw = image.width // 8
    height = image.height
    yy, xx = np.indices((height, cw))
    for i in (5, 6):
        start = i * cw
        src = lit[:, start:start+cw]
        dst = dark[:, start:start+cw]
        if pitch == "p55":
            # Three short glints outside the rim are already detached on this pitch.
            effect = (xx >= 184) if i == 5 else ((xx >= 138) & (yy >= 69) & (yy <= 96))
        else:
            side = i == 5
            cx, cy = (319, 178) if side else (186, 175)
            effect = (xx >= 317) if side else ((yy >= 175) & (abs(xx-cx) < 62))
            effect &= (abs(yy-cy) < 52) if side else (yy < 229)
            # Register the clean bulb and brass lip from facing zero where the flare crosses them.
            mx, my, rx, ry, slant = (311, 179, 11, 25, -.14) if side else (185, 172, 25, 17, -.05)
            u = (xx-mx-slant*(yy-my))/rx
            v = (yy-my)/ry
            cap = (u*u+v*v <= 1.0) & effect
            sx, sy = 124, 215
            ax = 16.0/rx
            bx = -.18*12.8/ry - ax*slant
            xf = (ax, bx, sx-ax*mx-bx*my, 0, 12.8/ry, sy-12.8*my/ry)
            clean = np.asarray(image.transform((cw,height), Image.Transform.AFFINE, xf,
                                               resample=Image.Resampling.BILINEAR))
            dst[cap] = clean[cap]
            bulb = ((xx-cx)/6.0)**2 + ((yy-cy)/6.2)**2 <= 1
            effect &= ~bulb
        light = src[:, :, :3].astype(float) @ np.array([.30, .60, .10]) / 255
        color = effect & (src[:, :, 3] > 0)
        src[color, :3] = lime(light[color])
        dst[effect if pitch == "p55" else effect & ~cap] = 0
    dest = VIEW / pitch
    Image.fromarray(lit).save(dest / (name + ".png"), optimize=True)
    Image.fromarray(dark).save(dest / (name + "_noflash.png"), optimize=True)


def build(masters):
    man = json.loads(CUT.with_suffix(".json").read_text())
    mag = keyed(masters / (GUN + "_mag_raw.png"))
    mag = size(mag.crop(mag.getbbox()), 62)
    dest = Path("project/features/combat/weapons/art") / GUN
    ImageOps.expand(mag, 2).save(dest / "mag.png", optimize=True)
    for pitch in ("p55", "p70"):
        rows = man["strips"][pitch]
        for mode in ("diag", "reload", "reload_left"):
            stem = GUN + "_" + pitch + "_" + mode
            src = keyed(masters / (stem + "_raw.png"))
            if mode == "diag":
                src, dark = diagonals(src, keyed(masters / (stem + "_corrected.png")))
                dark.save(masters / (stem + "_dark.png"))
            key = masters / (stem + "_key.png")
            src.save(key)
            name = "rivet_eq_" + GUN + "_diag" if mode == "diag" else "rivet_reload_" + GUN + mode[6:]
            dest = VIEW / pitch / (name + ".png")
            cut(key, dest, rows[name])
            if mode == "diag":
                cut(key, dest.with_stem(name + "_noflash"), rows[name], masters / (stem + "_dark.png"))
        main_twins(masters, pitch, man)


if __name__ == "__main__":
    build(Path(sys.argv[1]))
