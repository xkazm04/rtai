"""Cut the trooper's cased rocket and three left-facing plumes from the directed plate.

python tools/art/enemy_rocket_cut.py [--source plate.png --out directory] [--check]
"""
import argparse
import hashlib
import io
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

ART = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art"
SOURCE = ART / "source/enemy_rocket/enemy_rocket_a.png"
PX_PER_M = 64
BODY_SIZE = (90, 45)  # 1.4 m nose to nozzle at the cut's 64 px/m.
MAX_JET_WIDTH = 64  # Keep the plate's relative flicker lengths; the longest plume is 1 m.
GLOW_PAD = 6
RIM = (146, 201, 245)
CORE = (232, 247, 255)


def cut_parts(plate):
    rgb = np.array(plate.convert("RGB"))
    hsv = np.asarray(plate.convert("HSV")).astype(int)
    # Hue wraps at 256. A saturation floor keeps the dark neutral casing intact.
    distance = abs((hsv[..., 0] - 100 + 128) % 256 - 128)
    keyed = (distance < 36) & (hsv[..., 1] > 74)
    labels, count = ndimage.label(~keyed, structure=np.ones((3, 3)))
    areas = np.bincount(labels.ravel(), minlength=count + 1)
    boxes = ndimage.find_objects(labels)
    parts = []
    for label in np.flatnonzero(areas[1:] > 1000) + 1:
        rows, cols = boxes[label - 1]
        pixels = rgb[rows, cols].copy()
        # Suppress residual green at the silhouette before filtering with premultiplied alpha.
        r, g, b = pixels.transpose(2, 0, 1)
        np.minimum(g, np.maximum(r, b), out=g)
        alpha = (labels[rows, cols] == label).astype(np.uint8) * 255
        parts.append((rows.start, cols.start, Image.fromarray(np.dstack((pixels, alpha)))))
    if len(parts) != 4:
        raise ValueError(f"expected a body and three plumes, found {len(parts)} components")
    body, *plumes = sorted(parts, key=lambda part: part[0])
    return body[2], [p[2] for p in sorted(plumes, key=lambda part: part[1])]


def reduce_part(part, size, body):
    pixels = np.array(part.resize(size, Image.Resampling.LANCZOS))
    raw = np.asarray(part).astype(int)
    red, green, blue, alpha = raw.transpose(2, 0, 1)
    # Area coverage of the drawn blue strokes preserves the thin rim at gameplay zoom.
    ice = (blue - red > 52) & (green > 140) & (alpha > 0)
    coverage = Image.fromarray(ice.astype(np.uint8) * 255).resize(size, Image.Resampling.BOX)
    visible = pixels[..., 3] >= 175
    pixels[(np.asarray(coverage) >= (32 if body else 146)) & visible, :3] = RIM
    if not body:
        hot = (red > 202) & (blue > 229) & (alpha > 0)
        coverage = Image.fromarray(hot.astype(np.uint8) * 255).resize(size, Image.Resampling.BOX)
        pixels[(np.asarray(coverage) > 125) & visible, :3] = CORE
    return Image.fromarray(pixels)


def glow_mask(body):
    alpha = Image.new("L", (body.width + 2 * GLOW_PAD, body.height + 2 * GLOW_PAD))
    alpha.paste(body.getchannel("A"), (GLOW_PAD, GLOW_PAD))
    mask = Image.new("RGBA", alpha.size, "white")
    mask.putalpha(alpha.filter(ImageFilter.MaxFilter(7)).filter(ImageFilter.GaussianBlur(1.1)))
    return mask


def outputs(source):
    with Image.open(source) as plate:
        body, jets = cut_parts(plate)
    scale_y = BODY_SIZE[1] / body.height
    jet_scale = MAX_JET_WIDTH / max(jet.width for jet in jets)
    casing = reduce_part(body, BODY_SIZE, True)
    images = {"body": casing, "glow": glow_mask(casing)}
    for index, jet in enumerate(jets):
        size = (round(jet.width * jet_scale), round(jet.height * jet_scale))
        images[f"exhaust_{index}"] = reduce_part(jet, size, False)
    result = {}
    for name, image in images.items():
        stream = io.BytesIO()
        image.save(stream, format="PNG")
        result[f"enemy_rocket_{name}.png"] = stream.getvalue()
        print(f"{name}: {image.width} x {image.height} px")
    # The nose and nozzle are on the long axis. Use the centre of the actual leftmost nozzle ink.
    alpha = np.asarray(body)[..., 3]
    nozzle_y = np.flatnonzero(alpha[:, 0])
    anchor = [0, round((nozzle_y[0] + nozzle_y[-1] + 1) / 2 * scale_y, 2)]
    meta = {"generated": "DO NOT EDIT; tools/art/enemy_rocket_cut.py", "nozzle_px": anchor,
            "px_per_m": PX_PER_M, "schema": "gtai.enemy-rocket-art/1",
            "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest()}
    result["enemy_rocket_cut.json"] = (json.dumps(meta, indent=2, sort_keys=True) + "\n").encode()
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--out", type=Path, default=ART)
    parser.add_argument("--check", action="store_true", help="re-cut and compare file hashes")
    args = parser.parse_args()
    if not args.check:
        args.out.mkdir(parents=True, exist_ok=True)
    for name, data in outputs(args.source).items():
        path = args.out / name
        if args.check:
            if not path.is_file() or hashlib.sha256(data).digest() != hashlib.sha256(path.read_bytes()).digest():
                raise SystemExit(f"stale cut: {path}")
        else:
            path.write_bytes(data)
    print("cut hashes match" if args.check else "wrote body, glow mask, three plumes and nozzle metadata")


if __name__ == "__main__":
    main()
