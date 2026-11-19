"""Cut Rivet's p55/p70 vault and cover strips directly from the paired image_gen masters.

python tools/art/move_cells_cut.py [--masters DIR] [--scale 1.0|1.5]
The standing figure is 110 px at 1x. Crouched and airborne poses retain their own height.
The palm anchors the plant, the soles anchor every other cell. Landing claws can extend
below the soles, so the reader seats those frames with the extra clearance in the strip.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "project/features/characters/art/rivet/moves"
LAYOUT = ROOT / "project/data/tables/rivet_moves.json"
MASTERS = Path("C:/Users/kazda/kiro/gtai-masters/n19/move/masters")
# Projected crown-to-contact heights in the strip's 110 px space. Both views have
# separately drawn foreshortening. Match the helmet size across each pitch's poses.
HEIGHT = {"vault_plant": (80, 88), "vault_land": (78, 82),
          "cover_low": (86, 90), "cover_high": (110, 110)}
# Sole y in the uncropped master, where the gripper/probe hangs below the foot.
SOLE_Y = {"vault_land": (633, 624), "vault_land_left": (728, 666)}
# Leave room for the landing grip below the ordinary foot pad, common to all eight cells.
OVERHANG = 20


def keyed_half(file: Path, pitch: int) -> tuple[Image.Image, int]:
    with Image.open(file) as master:
        half = master.width // 2
        pixels = np.array(master.crop((pitch * half, 0, (pitch + 1) * half, master.height))
                          .convert("RGBA"))
    r, g, b = pixels[:, :, :3].astype(np.int16).transpose(2, 0, 1)
    key = (b > g + 14) & (r > g + 14)
    pixels[key] = 0
    figure = Image.fromarray(pixels)
    box = figure.getbbox()
    if box is None or box[0] == 0 or box[2] == half:
        raise ValueError(f"{file}: empty figure or figure crossing its pitch cell")
    return figure.crop(box), box[1]


def cut_cell(masters: Path, name: str, pitch: int, scale: float) -> tuple[Image.Image, int]:
    crop, top = keyed_half(masters / f"{name}.png", pitch)
    sole = SOLE_Y[name][pitch] - top if name in SOLE_Y else crop.height
    height = round(HEIGHT[name.removesuffix("_left")][pitch] * scale)
    ratio = height / sole
    size = (round(crop.width * ratio), round(crop.height * ratio))
    cell = crop.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    return cell, height


def strip(masters: Path, output: Path, pitch: int, scale: float, layout: dict) -> None:
    cells = [cut_cell(masters, name, pitch, scale) for name in layout["cells"]]
    pad = round(layout["foot_pad"] * scale)
    width = max(cell.width for cell, _ in cells) + 2 * pad
    anchor = max(sole for _, sole in cells) + pad
    height = anchor + round(OVERHANG * scale) + pad
    sheet = Image.new("RGBA", (width * len(cells), height))
    for i, (cell, sole) in enumerate(cells):
        y = anchor - sole
        if y + cell.height > height - pad:
            raise ValueError(f"{layout['cells'][i]} exceeds the foot clearance")
        sheet.paste(cell, (i * width + (width - cell.width) // 2, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--masters", type=Path, default=MASTERS)
    parser.add_argument("--scale", type=float, choices=(1.0, 1.5), default=1.0)
    args = parser.parse_args()
    layout = json.loads(LAYOUT.read_text(encoding="utf-8"))
    name = "rivet_moves_x15.png" if args.scale == 1.5 else "rivet_moves.png"
    for i, pitch in enumerate(("p55", "p70")):
        strip(args.masters, ART / pitch / name, i, args.scale, layout)


if __name__ == "__main__":
    main()
