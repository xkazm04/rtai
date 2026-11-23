"""Cut the trooper's cased rocket and three left-facing plumes from the directed plate.

python tools/art/enemy_rocket_cut.py [--check]
"""
import argparse
import hashlib
import io
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ART = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art"
SOURCE = ART / "source/enemy_rocket/enemy_rocket_a.png"
PX_PER_M = 64
BODY_SIZE = (62, 31)  # 0.97 m at both camera pitches; fins stay legible at 32 px/m.
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


def outputs():
    with Image.open(SOURCE) as plate:
        body, jets = cut_parts(plate)
    scale_x = BODY_SIZE[0] / body.width
    scale_y = BODY_SIZE[1] / body.height
    result = {}
    for name, part in [("body", body), *((f"exhaust_{i}", jet) for i, jet in enumerate(jets))]:
        size = (round(part.width * scale_x), round(part.height * scale_y))
        # Keep the drawn fins broad, but fit each plume to the nozzle rather than the fin span.
        if name != "body":
            size = (size[0], round(part.height * scale_x))
        image = reduce_part(part, size, name == "body")
        stream = io.BytesIO()
        image.save(stream, format="PNG")
        result[f"enemy_rocket_{name}.png"] = stream.getvalue()
        print(f"{name}: {size[0]} x {size[1]} px")
    # The nose and nozzle are on the long axis. Use the centre of the actual leftmost nozzle ink.
    alpha = np.asarray(body)[..., 3]
    nozzle_y = np.flatnonzero(alpha[:, 0])
    anchor = [0, round((nozzle_y[0] + nozzle_y[-1] + 1) / 2 * scale_y, 2)]
    meta = {"generated": "DO NOT EDIT; tools/art/enemy_rocket_cut.py", "nozzle_px": anchor,
            "px_per_m": PX_PER_M, "schema": "gtai.enemy-rocket-art/1",
            "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest()}
    result["enemy_rocket_cut.json"] = (json.dumps(meta, indent=2, sort_keys=True) + "\n").encode()
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="re-cut and compare file hashes")
    args = parser.parse_args()
    for name, data in outputs().items():
        path = ART / name
        if args.check:
            if not path.is_file() or hashlib.sha256(data).digest() != hashlib.sha256(path.read_bytes()).digest():
                raise SystemExit(f"stale cut: {path}")
        else:
            path.write_bytes(data)
    print("cut hashes match" if args.check else "wrote four sprites and nozzle metadata")


if __name__ == "__main__":
    main()
