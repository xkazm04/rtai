"""d8 bosses: cut the King's boss-palette part sheet into rig parts for one view pitch.

usage: python -I tools/art/king_parts_pitch.py <sheet.png> <king art dir> <out dir>

The sheet (Codex, chroma #00B140) holds 7 parts seen from straight above, pointing right, in two
rows: plate, piston forearm, upper arm, thigh / shin, foot, megaphone. Each is keyed (the
cut_facings key), cropped to its own box and resized to EXACTLY the size of today's part of the
same name (features/characters/art/king/), so parts.json's pivots and the rig's offsets hold.
The right press forearm is composed: the piston up to the plate's pin, then the plate. Raw
colours (no print snap): the court draws these raw under the court's pitch (KingArt).
Deterministic.
"""

import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut_facings import key_out  # noqa: E402

# sheet order (row-major) -> the part names it dresses
ORDER = ["plate", "piston", "upperarm", "thigh", "shin", "foot", "horn"]
DRESS = {
    "press_plate": "plate",
    "l_forearm": "piston",
    "r_forearm": "piston",
    "l_forearm_endon": "piston",
    "r_forearm_endon": "piston",
    "l_upperarm": "upperarm",
    "r_upperarm": "upperarm",
    "l_upperarm_endon": "upperarm",
    "r_upperarm_endon": "upperarm",
    "l_thigh": "thigh",
    "r_thigh": "thigh",
    "l_shin": "shin",
    "r_shin": "shin",
    "l_foot": "foot",
    "r_foot": "foot",
    "l_foot_toeoff": "foot",
    "r_foot_toeoff": "foot",
}


def blobs(rgba: np.ndarray) -> list[Image.Image]:
    solid = rgba[:, :, 3] > 128
    lab, n = ndimage.label(ndimage.binary_closing(solid, iterations=3))
    boxes = ndimage.find_objects(lab)
    big = [b for b in boxes if (b[0].stop - b[0].start) * (b[1].stop - b[1].start) > 4000]
    rows = sorted(big, key=lambda b: b[0].start)
    mid = rgba.shape[0] * 0.5
    top = sorted([b for b in rows if (b[0].start + b[0].stop) * 0.5 < mid], key=lambda b: b[1].start)
    bot = sorted([b for b in rows if (b[0].start + b[0].stop) * 0.5 >= mid], key=lambda b: b[1].start)
    return [Image.fromarray(rgba[b]) for b in top + bot]


def main() -> None:
    sheet, king_dir, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    rgba = key_out(Image.open(sheet), 40.0)
    parts = dict(zip(ORDER, blobs(rgba)))
    os.makedirs(out_dir, exist_ok=True)
    for name, src in DRESS.items():
        size = Image.open(os.path.join(king_dir, name + ".png")).size
        parts[src].resize(size, Image.LANCZOS).save(os.path.join(out_dir, name + ".png"))
    size = Image.open(os.path.join(king_dir, "r_forearm_press.png")).size
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    arm_h = int(size[1] * 0.57)
    out.alpha_composite(parts["piston"].resize((250, arm_h), Image.LANCZOS), (0, (size[1] - arm_h) // 2))
    plate = parts["plate"].resize((size[0] - 216, size[1]), Image.LANCZOS)
    out.alpha_composite(plate, (216, 0))
    out.save(os.path.join(out_dir, "r_forearm_press.png"))
    print("parts:", len(DRESS) + 1, "->", out_dir)


if __name__ == "__main__":
    main()
