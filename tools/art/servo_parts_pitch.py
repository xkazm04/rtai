"""d8 bosses: cut Servo's boss-palette part sheet into his rig parts for one view pitch.

usage: python -I tools/art/servo_parts_pitch.py <sheet.png> <today's servo art dir> <out dir>

The sheet (Codex, chroma #00B140, from servo_55.png) holds 9 top-view parts in two rows: torso,
head (front = right), 3-row rack / pad, arm, thigh, shin, pelvis, drone. Each is keyed, cropped,
turned to the rig's convention (front down the page: the head turns 90 degrees) and resized to
EXACTLY today's part of the same name, so ServoRig's sizes (ART_PPM) and struts hold. The 2-row
rack and the drone keep today's art (their layouts differ). Deterministic.
"""

import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut_facings import key_out  # noqa: E402
from king_parts_pitch import blobs  # noqa: E402

ORDER = ["torso", "head", "rack", "pad", "arm", "thigh", "shin", "pelvis", "drone"]
DRESS = {
    "torso": ("torso", 0),
    "head": ("head", -90),
    "rack3": ("rack", 0),
    "pad": ("pad", 0),
    "pad_hazard": ("pad", 0),
    "arm": ("arm", 0),
    "thigh": ("thigh", 0),
    "shin": ("shin", 0),
    "pelvis": ("pelvis", 0),
}


def main() -> None:
    sheet, art_dir, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    parts = dict(zip(ORDER, blobs(key_out(Image.open(sheet), 40.0))))
    os.makedirs(out_dir, exist_ok=True)
    for name, (src, turn) in DRESS.items():
        size = Image.open(os.path.join(art_dir, name + ".png")).size
        img = parts[src].rotate(turn, expand=True) if turn else parts[src]
        img.resize(size, Image.LANCZOS).save(os.path.join(out_dir, name + ".png"))
    print("parts:", len(DRESS), "->", out_dir)


if __name__ == "__main__":
    main()
