"""n15 combat: the asset lane's drawn gib pieces (assets it359/it363: <kind>_gib_70_cells/1_<k>.png, six per
kind in GibCardCut order: head, torso, image-left arm, image-right arm, image-left leg, image-right leg; torn
sooty edges, no blood) packed as p70/<kind>_gib.png: six CELL x CELL cells across, each piece centred in
its cell, all six at ONE scale per kind so its torso is TORSO_PX tall (the pieces keep their drawn
proportions; the game sizes the torso to the card's torso band, GibCardPieces). TORSO_PX 64 keeps the
pieces' downscale in game near the walking card's (192 px cell for 1.7 m): at 128 they drew ~5x down without
mipmaps and speckled (filmed at 48 px/m). Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/gib_pieces.py [--lib=<library>/keyed/street]
"""

import subprocess
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
P70 = ROOT / "project/features/characters/art/view/p70"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/street")
CELL = 96
TORSO_PX = 64
PIECES = 6
# The riot's orange arm bands are greyed (street_armband, colour law).
BANDS = {"cop_riot_gib.png"}
# out file -> the armed walk whose uniform blue the pieces take (street_tone, as the hit sheets): drawn lighter than
# the card's navy, the pieces read as another man's uniform in flight (filmed at 48 px/m, session 5).
TONES = {"cop_patrol_gib.png": "cop_patrol_armed_walk.png", "cop_riot_gib.png": "cop_riot_armed_walk.png"}
# library folder (under LIB) -> out file. The patrol takes v2 (head seen from above, the card's slate blue).
KINDS = {
    "cop_patrol_gib_70_cells/v2": "cop_patrol_gib.png",
    "cop_riot_gib_70_cells": "cop_riot_gib.png",
}
# Drawn too (it363 A), NOT packed: in the lone rocket shot the thug and the hooded pedestrian are rigs, not cards, so
# GibCardCut never cuts them and their pieces were never seen. Add them here (and to GibCardPieces.GRIDS) once filmed:
# "thug_gib_70_cells": "thug_gib.png", "ped_hood_gib_70_cells": "ped_hood_gib.png".


def cropped(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    return im.crop(im.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox())


def build(lib: Path, folder: str, out: str) -> None:
    pieces = [cropped(lib / folder / f"1_{k + 1}.png") for k in range(PIECES)]
    k = TORSO_PX / pieces[1].height
    sheet = Image.new("RGBA", (CELL * PIECES, CELL), (0, 0, 0, 0))
    for i, im in enumerate(pieces):
        im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
        if im.width > CELL or im.height > CELL:
            print(f"WARNING {folder} piece {i + 1}: {im.size} is larger than the {CELL} cell")
        sheet.alpha_composite(im, (CELL * i + (CELL - im.width) // 2, (CELL - im.height) // 2))
    sheet.save(P70 / out, optimize=True)
    if out in TONES:
        tone = Path(__file__).parent / "street_tone.py"
        subprocess.run([sys.executable, "-I", str(tone), str(P70 / out), str(P70 / TONES[out]), str(P70 / out)], check=True)
    if out in BANDS:
        band = Path(__file__).parent / "street_armband.py"
        subprocess.run([sys.executable, "-I", str(band), str(P70 / out), str(P70 / out)], check=True)
    print(f"{out}: {(P70 / out).stat().st_size} bytes, k {k:.3f}")


def main() -> None:
    lib = LIB
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
    for folder, out in KINDS.items():
        build(lib, folder, out)


if __name__ == "__main__":
    main()
