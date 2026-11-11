"""n17 rivet-strike (DEFECTS #9): builds rivet_eq_<gun>_noflash.png, a gun's equipped strip with its
fire cells (5 FIRE_SIDE, 6 FIRE_CAM) swapped for the asset lane's flashless ones (it454:
library/keyed/rivet/fire_noflash/<art>/rivet_eq_<gun>_fire_noflash.png, 2 cells, the game's own
cells with the painted flash erased). Same canvas and cell size as the strip, every other cell
copied, so RivetNoFlash swaps only the texture: the muzzle, feet and res tables keyed by the strip's
path still apply.

    python tools/art/rivet_fire_noflash.py <delivery dir: .../fire_noflash> [--check]
"""

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / "project/features/characters/art/view"
GUNS = [
    "pistol",
    "machine_pistol",
    "gatling",
    "plasma_rifle",
    "hand_cannon",
    "gloria",
    "electro_gun",
    "rocket_launcher",
]
CELLS = 8
FIRE = (5, 6)


def build(src: Path, art: str, gun: str) -> Image.Image:
    strip = Image.open(VIEW / art / f"rivet_eq_{gun}.png").convert("RGBA")
    two = Image.open(src / art / f"rivet_eq_{gun}_fire_noflash.png").convert("RGBA")
    cw, h = strip.width // CELLS, strip.height
    if two.size != (cw * 2, h):
        raise SystemExit(f"{art}/{gun}: flashless {two.size} != 2 x {cw}x{h}")
    out = strip.copy()
    for i, cell in enumerate(FIRE):
        out.paste((0, 0, 0, 0), (cell * cw, 0, cell * cw + cw, h))
        out.paste(two.crop((i * cw, 0, i * cw + cw, h)), (cell * cw, 0))
    return out


def main() -> None:
    src = Path(sys.argv[1])
    check = "--check" in sys.argv
    for art in ("p70", "p55"):
        for gun in GUNS:
            img = build(src, art, gun)
            dst = VIEW / art / f"rivet_eq_{gun}_noflash.png"
            if check:
                same = dst.exists() and Image.open(dst).convert("RGBA").tobytes() == img.tobytes()
                print(f"{'ok' if same else 'DIFFERS'} {dst.relative_to(ROOT)}")
            else:
                img.save(dst, optimize=True)
                print(f"wrote {dst.relative_to(ROOT)} {img.size}")


if __name__ == "__main__":
    main()
