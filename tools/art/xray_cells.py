"""Pack the asset lane's per-kind electro X-ray cells (it418/it422 A3, p70) for KillShockFx.

Each kind's two 256x384 frames (1: cream bones on ink, 2: the inverse) are cropped to their
shared alpha box (feet on the box floor), downscaled by SCALE (Lanczos) and laid side by side:
`project/features/combat/weapons/art/gore/xray_<kind>.png`, two equal cells across.

Usage: python tools/art/xray_cells.py [<library keyed/street dir>]
"""

import sys
from pathlib import Path

from PIL import Image

KINDS = ["cop_patrol", "cop_riot", "swat", "ped_hood", "ped_cap", "ped_worker", "ped_suit", "ped_generic"]
SCALE = 0.5
SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/kazda/kiro/gtai-art/library/keyed/street")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore"


def union_box(frames):
    boxes = [f.split()[3].getbbox() for f in frames]
    return (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))


def main():
    for kind in KINDS:
        cells = SRC / f"xray_{kind}_70_cells"
        frames = [Image.open(cells / f"1_{n}.png").convert("RGBA") for n in (1, 2)]
        box = union_box(frames)
        w = round((box[2] - box[0]) * SCALE)
        h = round((box[3] - box[1]) * SCALE)
        sheet = Image.new("RGBA", (w * 2, h), (0, 0, 0, 0))
        for n, f in enumerate(frames):
            sheet.paste(f.crop(box).resize((w, h), Image.LANCZOS), (w * n, 0))
        dest = OUT / f"xray_{kind}.png"
        sheet.save(dest, optimize=True)
        print(f"{dest.name}: {w}x{h} per cell (box {box})")


if __name__ == "__main__":
    main()
