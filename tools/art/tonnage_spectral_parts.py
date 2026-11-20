"""Cut the Press Golem 3 x 2 master and preview the five trimmed parts on grey."""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage as ndi


PARTS = ("back", "upper_arm", "forearm", "fist", "hoses")
KEY = np.array([0, 177, 64], dtype=np.float32)


def keyed_image(path):
    rgb = np.asarray(Image.open(path).convert("RGB"), dtype=np.float32)
    # Allow a small shift in the generated field. Sample its flat fill, away from ink.
    samples = rgb[::8, ::8]
    colors, counts = np.unique(samples.reshape(-1, 3), axis=0, return_counts=True)
    key = colors[counts.argmax()]
    if key[1] < 145 or key[0] > 65 or key[2] > 100:
        raise ValueError(f"Expected a green field near {KEY}, sampled {key}")
    distance = np.linalg.norm(rgb - key, axis=2)
    field = distance <= 28
    # Only unmix the ink/key transition touching a keyed pixel. Interior teal stays exact.
    rim = ndi.binary_dilation(field, iterations=2) & ~field
    coverage = np.clip(1 - rgb[:, :, 1] / key[1], 0, 1)
    on_ink_ramp = np.linalg.norm(rgb - (1 - coverage[:, :, None]) * key, axis=2) < 34
    edge = rim & on_ink_ramp
    alpha = np.where(field, 0, np.where(edge, coverage, 1))
    rgb[edge] = np.clip((rgb[edge] - (1 - coverage[edge, None]) * key)
                        / np.maximum(coverage[edge, None], 0.01), 0, 255)
    rgb[field] = 0
    return Image.fromarray(np.dstack((rgb, np.rint(alpha * 255))).astype(np.uint8))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("master", "out_dir", "contact"):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    master = keyed_image(args.master)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    contact = Image.new("RGB", (3 * 512, 2 * 512), "#808080")
    for index, name in enumerate(PARTS):
        row, col = divmod(index, 3)
        # Each master cell has a thin black rule, separated from the part by green.
        cell = master.crop((col * master.width // 3 + 8, row * master.height // 2 + 8,
                            (col + 1) * master.width // 3 - 8, (row + 1) * master.height // 2 - 8))
        box = cell.getbbox()
        if not box or 0 in box[:2] or box[2] == cell.width or box[3] == cell.height:
            raise ValueError(f"Missing or clipped part: {name}")
        part = ImageOps.expand(cell.crop(box), border=2)
        part.save(args.out_dir / f"{name}.png")
        contact.paste(part, (col * 512 + (512 - part.width) // 2,
                             row * 512 + (512 - part.height) // 2), part)
        print(f"{name}: {part.width} x {part.height}")
    contact.save(args.contact)


if __name__ == "__main__":
    main()
