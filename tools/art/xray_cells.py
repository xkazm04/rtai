"""Pack the asset lane's per-kind electro X-ray cells (it418/it422 A3, p70) for KillShockFx.

Each kind's two 256x384 frames (1: cream bones on ink, 2: the inverse) are cropped to their
shared alpha box (feet on the box floor), downscaled by SCALE (Lanczos) and laid side by side:
`project/features/combat/weapons/art/gore/xray_<kind>.png`, two equal cells across.

n16 it4: `--pitch=55` packs the p55 set (asset lane 15:01, `xray_<kind>_55_cells`) into
`xray_<kind>_55.png`; the boss/tilt p55 view flashes those (KillXray.ART_55).

Usage: python tools/art/xray_cells.py [<library keyed/street dir>] [--pitch=55]
"""

import sys
from pathlib import Path

from PIL import Image

KINDS = ["cop_patrol", "cop_riot", "swat", "ped_hood", "ped_cap", "ped_worker", "ped_suit", "ped_generic"]
SCALE = 0.5
ARGS = [a for a in sys.argv[1:] if not a.startswith("--pitch=")]
PITCH = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--pitch=")), "70")
SRC = Path(ARGS[0] if ARGS else "C:/Users/kazda/kiro/gtai-art/library/keyed/street")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore"


def union_box(frames):
    boxes = [f.split()[3].getbbox() for f in frames]
    return (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))


def main():
    for kind in KINDS:
        cells = SRC / f"xray_{kind}_{PITCH}_cells"
        frames = [Image.open(cells / f"1_{n}.png").convert("RGBA") for n in (1, 2)]
        box = union_box(frames)
        w = round((box[2] - box[0]) * SCALE)
        h = round((box[3] - box[1]) * SCALE)
        sheet = Image.new("RGBA", (w * 2, h), (0, 0, 0, 0))
        for n, f in enumerate(frames):
            sheet.paste(f.crop(box).resize((w, h), Image.LANCZOS), (w * n, 0))
        dest = OUT / (f"xray_{kind}.png" if PITCH == "70" else f"xray_{kind}_{PITCH}.png")
        sheet.save(dest, optimize=True)
        print(f"{dest.name}: {w}x{h} per cell (box {box})")


if __name__ == "__main__":
    main()
