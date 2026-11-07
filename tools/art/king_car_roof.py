"""d8 bosses: cut the throne-car's roof plan and the throne's cards for one view pitch.

usage: python -I tools/art/king_car_roof.py <sheet.png> <out dir>

The sheet (Codex, chroma #00B140, refs king_car_55.png) holds the whole car from straight above
(nose right: gold bumpers, the hood with a laurel gun-mount ring, the plum glass windscreen, the
gilded cabin roof between drape rails, the quilted rear deck) on the top row, and the empty throne
seen from behind and from the front at the view's pitch on the bottom row. Each is keyed
(cut_facings.key_out), cut by its blob (king_parts_pitch.blobs), and its crimson velvet shifted to
plum (hue 325-360/0-6, sat > 0.3, val < 0.75; SHIFT_DEG, DARKEN). The roof is
resized to the car's footprint (KingBodyView CAR_LEN_M x CAR_W_M at ROOF_PPM, bumper to bumper);
the throne cards keep their aspect at half size. Deterministic.
"""

import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut_facings import key_out  # noqa: E402
from king_parts_pitch import blobs  # noqa: E402

ORDER = ["car_roof", "throne_back", "throne_front"]
CAR_M = (6.6, 2.5)
ROOF_PPM = 128
# -24 degrees, value x0.85: plum (#5A2335 is hue 343); the bust's -32 read violet on a large area
SHIFT_DEG = 24.0
DARKEN = 0.85


def plum(img: Image.Image) -> Image.Image:
    rgba = np.asarray(img.convert("RGBA"))
    hsv = np.asarray(img.convert("RGB").convert("HSV")).astype(np.float32)
    h = hsv[..., 0] * 360.0 / 255.0
    s = hsv[..., 1] / 255.0
    v = hsv[..., 2] / 255.0
    m = ((h >= 325) | (h <= 6)) & (s > 0.3) & (v < 0.75)
    hsv[..., 0] = np.where(m, np.mod(h - SHIFT_DEG, 360.0), h) * 255.0 / 360.0
    hsv[..., 2] = np.where(m, hsv[..., 2] * DARKEN, hsv[..., 2])
    rgb = np.asarray(Image.fromarray(hsv.astype(np.uint8), "HSV").convert("RGB"))
    out = np.dstack([np.where(m[..., None], rgb, rgba[..., :3]), rgba[..., 3]])
    return Image.fromarray(out.astype(np.uint8), "RGBA")


def main() -> None:
    sheet, out_dir = sys.argv[1], sys.argv[2]
    parts = dict(zip(ORDER, blobs(key_out(Image.open(sheet), 40.0))))
    os.makedirs(out_dir, exist_ok=True)
    roof = plum(parts["car_roof"]).resize(
        (round(CAR_M[0] * ROOF_PPM), round(CAR_M[1] * ROOF_PPM)), Image.LANCZOS
    )
    roof.save(os.path.join(out_dir, "car_roof.png"))
    for name in ORDER[1:]:
        card = plum(parts[name])
        card.resize((card.width // 2, card.height // 2), Image.LANCZOS).save(
            os.path.join(out_dir, name + ".png")
        )
    print("parts:", len(ORDER), "->", out_dir)


if __name__ == "__main__":
    main()
