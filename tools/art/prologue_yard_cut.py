"""Cut prologue yard art from a flat, light-matte PNG.

python tools/art/prologue_yard_cut.py sheet.png job.json foundry
Job example: {"px_per_m": 96, "pieces": [{"id": "fan", "box": [12, 8, 300, 220],
              "size_m": [3, 2]}]}. Box coordinates are source x, y, width, height.
Set "mode": "ground" for opaque, seamless crops. For pieces, leave a clear sheet
border for matte sampling or set "background": "#eee8dc" to its RGB colour.
"fit": true preserves the trimmed aspect ratio inside each metre box. For ink on
white, "shadow_ink": "#211e1c" unmattes exterior shadow to transparent ink.
An "ink_only" row applies that treatment throughout a ground mark.
An "outline" polygon (local box pixels) cuts a fixture out of its mounting wall.
"turn_clockwise" rotates the cut before sizing. "trim_to_solid" removes only the
outer margin beyond the opaque bounding box, for art mapped to a collision box.
"end_rise" raises the right end by a fraction of the cut height before fitting.
"bend" eases that rise into the existing curve. "mirror" reverses the finished cut.
"""

import argparse
import json
import math
import re
from pathlib import Path
from tempfile import TemporaryDirectory

import numpy as np
from PIL import Image, ImageColor, ImageDraw, ImageFilter

ART = Path(__file__).resolve().parents[2] / "project/boot/prologue/art"
ID = re.compile(r"[a-z][a-z0-9]*(?:_[a-z0-9]+)*")


def sheet_matte(sheet):
    """Median of the four outside edges, ignoring pieces which touch a minority of the border."""
    rgb = np.asarray(sheet.convert("RGB"))
    border = np.concatenate((rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]))
    return np.median(border, axis=0)


def key_piece(crop, matte, shadow_ink=None, ink_only=False):
    """Estimate edge coverage against nearby ink, then remove the matte from that soft edge."""
    cut = key_full(crop, matte, shadow_ink, ink_only)
    bounds = cut.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("piece contains only background")
    return cut.crop(bounds)


def key_full(crop, matte, shadow_ink=None, ink_only=False):
    """key_piece without the final trim: the cut keeps the crop's size and pixel positions."""
    pixels = np.asarray(crop.convert("RGBA"), dtype=np.float32)
    offset = pixels[..., :3] - np.asarray(matte, dtype=np.float32)
    distance = np.max(np.abs(offset), axis=2)
    levels = Image.fromarray(np.rint(distance).astype(np.uint8))
    near_matte = np.asarray(levels.filter(ImageFilter.MinFilter(5))) <= 3
    ink = np.asarray(levels.filter(ImageFilter.MaxFilter(5))).astype(np.float32)
    coverage = np.where(near_matte, distance / np.maximum(ink, 32), 1.0)
    coverage[distance <= 3] = 0
    if shadow_ink is not None:
        # A printed grey shadow is paper showing through black ink. Find the paper
        # up to the object's outline, including broad shadow ramps beyond that outline.
        rgb = pixels[..., :3]
        solid = (np.ptp(rgb, axis=2) > 21) | (np.min(rgb, axis=2) < 70)
        field = Image.fromarray((solid * 255).astype(np.uint8)).copy()
        ImageDraw.floodfill(field, (0, 0), 128)
        exterior = (np.asarray(field) == 128) | near_matte | (distance < 25)
        ink_alpha = np.max(-offset / np.maximum(np.subtract(matte, shadow_ink), 1), axis=2)
        coverage = np.where(exterior | ink_only, ink_alpha.clip(0, 1), coverage)
        coverage[distance <= 5] = 0
    if ink_only:
        # Marks have no paper-coloured fill. Also key matte trapped inside a dark loop.
        coverage[distance <= 24] = 0
    clean = matte + offset / np.maximum(coverage[..., None], 1 / 255)
    rgba = np.dstack((clean, pixels[..., 3] * coverage))
    return Image.fromarray(np.rint(rgba).clip(0, 255).astype(np.uint8))


def tile_ground(crop):
    """Move each wrap seam to the middle and blend the continuous source across it."""
    pixels = np.asarray(crop.convert("RGB"), dtype=np.float32)
    for axis in (0, 1):
        span = pixels.shape[axis]
        shift = span // 2
        # Complementary smoothstep weights. The outside edges come from adjoining source pixels.
        t = np.clip(np.abs(np.arange(span) - shift + 0.5) / max(1, span / 4), 0, 1)
        weight = (t * t * (3 - 2 * t)).astype(np.float32)
        weight = weight[:, None, None] if axis == 0 else weight[None, :, None]
        pixels = pixels * (1 - weight) + np.roll(pixels, shift, axis=axis) * weight
    return Image.fromarray(np.rint(pixels).clip(0, 255).astype(np.uint8))


def isolate(crop, point, matte):
    """Pick one connected silhouette on a crowded decal sheet, preserving holes in the ink."""
    rgb = np.asarray(crop.convert("RGB"), dtype=np.float32)
    ink = np.max(np.abs(rgb - matte), axis=2) > 24
    mask = Image.fromarray(ink.astype(np.uint8) * 255).copy()
    if mask.getpixel(tuple(point)) != 255:
        raise ValueError("isolate point must be on the piece, relative to its box")
    ImageDraw.floodfill(mask, tuple(point), 128)
    selected = mask.point(lambda v: 255 if v == 128 else 0).filter(ImageFilter.MaxFilter(5))
    return Image.composite(crop, Image.new("RGB", crop.size, tuple(map(int, matte))), selected)


def extract(sheet, row, job, matte):
    ppm = job["px_per_m"]
    x, y, w, h = row["box"]
    if any(type(n) is not int for n in (x, y, w, h)) or min(w, h) <= 0:
        raise ValueError("box needs integer x, y and positive integer width, height")
    if x < 0 or y < 0 or x + w > sheet.width or y + h > sheet.height:
        raise ValueError("box extends beyond the source image")
    width, height = row["size_m"]
    if any(not math.isfinite(n) or n <= 0 for n in (width, height, ppm)):
        raise ValueError("size_m and px_per_m must be finite and positive")
    size = (max(1, round(width * ppm)), max(1, round(height * ppm)))
    crop = sheet.crop((x, y, x + w, y + h))
    if job.get("mode") == "ground":
        return tile_ground(crop.resize(size, Image.Resampling.LANCZOS))
    if "isolate" in row:
        crop = isolate(crop, row["isolate"], matte)
    if "outline" in row:
        mask = Image.new("L", crop.size)
        ImageDraw.Draw(mask).polygon([tuple(p) for p in row["outline"]], fill=255)
        paper = Image.new("RGB", crop.size, tuple(map(int, matte)))
        crop = Image.composite(crop.convert("RGB"), paper, mask)
    shadow = ImageColor.getrgb(job["shadow_ink"]) if "shadow_ink" in job else None
    piece = key_piece(crop, matte, shadow, row.get("ink_only", False))
    if row.get("turn_clockwise", False):
        piece = piece.transpose(Image.Transpose.ROTATE_270)
    if "end_rise" in row:
        # Project the rail within its assigned footprint. Translate whole columns
        # together so hooks still hang vertically from their point on the rail.
        h, w = piece.height, piece.width
        along = np.linspace(0, 1, w)
        rise = np.rint(h * row["end_rise"] * along ** (3 if row.get("bend") else 1)).astype(int)
        drops = rise.max() - rise
        canvas = np.zeros((h + drops.max(), w, 4), dtype=np.uint8)
        canvas[np.arange(h)[:, None] + drops, np.arange(w)] = np.asarray(piece)
        piece = Image.fromarray(canvas)
    if row.get("mirror", False):
        piece = piece.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    if job.get("fit", False):
        scale = min(size[0] / piece.width, size[1] / piece.height)
        size = tuple(max(1, round(span * scale)) for span in piece.size)
    if row.get("ink_only", False) and shadow is not None:
        # Resample the coverage alone. Premultiplied RGBA interpolation otherwise leaves
        # bright RGB flecks on very low-alpha pixels along the printed lines.
        mark = Image.new("RGBA", size, shadow)
        mark.putalpha(piece.getchannel("A").resize(size, Image.Resampling.LANCZOS))
        return mark
    piece = piece.resize(size, Image.Resampling.LANCZOS)
    if row.get("trim_to_solid", False):
        solid = piece.getchannel("A").point(lambda a: 255 if a == 255 else 0).getbbox()
        if solid is None:
            raise ValueError("cover piece has no fully opaque ink")
        piece = piece.crop(solid)
    return piece


def cut_job(sheet, job):
    mode = job.get("mode", "pieces")
    if mode not in ("ground", "pieces") or not job["pieces"]:
        raise ValueError("expected mode pieces or ground and a nonempty pieces list")
    matte = ImageColor.getrgb(job["background"]) if "background" in job else sheet_matte(sheet)
    if len(matte) != 3:
        raise ValueError("background needs an RGB colour")
    pieces = {}
    for row in job["pieces"]:
        name = row["id"]
        if not ID.fullmatch(name) or name in pieces:
            raise ValueError(f"invalid or repeated piece id: {name}")
        pieces[name] = extract(sheet, row, job, matte)
    return pieces


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("job", type=Path)
    parser.add_argument("dressing")
    args = parser.parse_args()
    if not ID.fullmatch(args.dressing):
        parser.error("dressing must be a snake_case id")
    try:
        with Image.open(args.source) as sheet:
            pieces = cut_job(sheet, json.loads(args.job.read_text(encoding="utf-8")))
    except (KeyError, OSError, TypeError, ValueError) as error:
        parser.error(str(error))
    folder = ART / args.dressing
    folder.mkdir(parents=True, exist_ok=True)
    # Encode every PNG successfully before replacing any previously cut art.
    with TemporaryDirectory(dir=folder) as scratch:
        for name, image in pieces.items():
            image.save(Path(scratch) / f"{name}.png")
        for name, image in pieces.items():
            dest = folder / f"{name}.png"
            (Path(scratch) / dest.name).replace(dest)
            print(f"{dest}: {image.width}x{image.height}")


if __name__ == "__main__":
    main()
