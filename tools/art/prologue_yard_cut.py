"""Cut prologue yard art from a flat, light-matte PNG.

python tools/art/prologue_yard_cut.py sheet.png job.json foundry
Job example: {"px_per_m": 96, "pieces": [{"id": "fan", "box": [12, 8, 300, 220],
              "size_m": [3, 2]}]}. Box coordinates are source x, y, width, height.
Set "mode": "ground" for opaque, seamless crops. For pieces, leave a clear sheet
border for matte sampling or set "background": "#eee8dc" to its RGB colour.
"""

import argparse
import json
import math
import re
from pathlib import Path
from tempfile import TemporaryDirectory

import numpy as np
from PIL import Image, ImageColor, ImageFilter

ART = Path(__file__).resolve().parents[2] / "project/boot/prologue/art"
ID = re.compile(r"[a-z][a-z0-9]*(?:_[a-z0-9]+)*")


def sheet_matte(sheet):
    """Median of the four outside edges, ignoring pieces which touch a minority of the border."""
    rgb = np.asarray(sheet.convert("RGB"))
    border = np.concatenate((rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]))
    return np.median(border, axis=0)


def key_piece(crop, matte):
    """Estimate edge coverage against nearby ink, then remove the matte from that soft edge."""
    pixels = np.asarray(crop.convert("RGBA"), dtype=np.float32)
    offset = pixels[..., :3] - np.asarray(matte, dtype=np.float32)
    distance = np.max(np.abs(offset), axis=2)
    levels = Image.fromarray(np.rint(distance).astype(np.uint8))
    near_matte = np.asarray(levels.filter(ImageFilter.MinFilter(5))) <= 3
    ink = np.asarray(levels.filter(ImageFilter.MaxFilter(5))).astype(np.float32)
    coverage = np.where(near_matte, distance / np.maximum(ink, 32), 1.0)
    coverage[distance <= 3] = 0
    clean = matte + offset / np.maximum(coverage[..., None], 1 / 255)
    rgba = np.dstack((clean, pixels[..., 3] * coverage))
    cut = Image.fromarray(np.rint(rgba).clip(0, 255).astype(np.uint8))
    bounds = cut.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("piece contains only background")
    return cut.crop(bounds)


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


def extract(sheet, row, ppm, mode, matte):
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
    if mode == "ground":
        return tile_ground(crop.resize(size, Image.Resampling.LANCZOS))
    return key_piece(crop, matte).resize(size, Image.Resampling.LANCZOS)


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
        pieces[name] = extract(sheet, row, job["px_per_m"], mode, matte)
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
