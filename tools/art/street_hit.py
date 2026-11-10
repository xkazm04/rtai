"""n11 combat: the drawn hit cells (the asset lane's <kind>_hit_70_cells, 5 facings of a body thrown
back by a round) laid out as the game's card grids: 5 facings across, one row, each cell 344 x 256
with the planted boot on the cell's centre line at StreetWalkerCards.FOOT_Y, so the rest of the
figure leans off the point the rig stands on. The figure fills FILL of the cell's height (the
standing strip's 1.7 m). Blue is toned to the same kind's armed walk (street_tone), a riot or SWAT
sheet's orange arm band is greyed (street_armband, colour law). Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_hit.py [--lib=<library>/keyed/street]
"""

import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
P70 = ROOT / "project/features/characters/art/view/p70"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/street")
CELL_W = 344
CELL_H = 256
FILL = 0.96
FOOT_Y = 0.985
FOOT_BAND = 0.12
# library name -> (out file, the armed walk that gives the uniform's blue, grey the arm band)
SHEETS = {
    "cop_patrol": ("cop_patrol_hit.png", "cop_patrol_armed_walk.png", False),
    "cop_riot": ("cop_riot_hit.png", "cop_riot_armed_walk.png", True),
    "swat": ("swat_hit.png", "swat_armed_walk.png", True),
    "ped_suit": ("ped_suit_hit.png", None, False),
    "ped_worker": ("ped_worker_hit.png", None, False),
    # it20: the asset lane's thrown-back cells for the thug and the other seven pedestrians
    "thug": ("thug_hit.png", None, False),
    "ped_hood": ("ped_hood_hit.png", None, False),
    "ped_cap": ("ped_cap_hit.png", None, False),
    "ped_elder": ("ped_elder_hit.png", None, False),
    "ped_hat": ("ped_hat_hit.png", None, False),
    "ped_jogger": ("ped_jogger_hit.png", None, False),
    "ped_punk": ("ped_punk_hit.png", None, False),
    "ped_shopper": ("ped_shopper_hit.png", None, False),
}
# it14: the per-site flinch cells drawn for a kind (<site>_<col>.png, the right-hand facings 1..5;
# the left ones mirror as the grid does), each to <kind>_<site>_hit.png on the same layout.
SITES = {"cop_patrol": ["shoulder", "gut"]}
# n11 it33: the asset lane's drawn burning man (<kind>_hit_70_cells/burn/1_<col>.png, arms flailing,
# flames up his sides), packed as <kind>_burn_hit.png on the same layout for a LIVING burn.
# n11 it34: the asset lane's burn cells for six more kinds (06:17-06:37 offers; suit, shopper and
# elder were drawn singed, not burning, and keep the walk under the loops).
BURNS = {k: "burn/1" for k in ("cop_patrol", "cop_riot", "swat", "thug", "ped_hood", "ped_cap", "ped_punk", "ped_jogger")}


def foot_x(alpha: np.ndarray) -> float:
    """The x centre of the widest solid run in the bottom band: the planted boot."""
    h = alpha.shape[0]
    band = (alpha[int(h * (1.0 - FOOT_BAND)) :] > 128).any(axis=0)
    best = (0, 0)
    start = None
    for x, on in enumerate(list(band) + [False]):
        if on and start is None:
            start = x
        elif not on and start is not None:
            best = max(best, (x - start, start))
            start = None
    return best[1] + best[0] / 2.0


def cell(path: Path, out: Image.Image, col: int) -> None:
    im = Image.open(path).convert("RGBA")
    bbox = im.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox()
    im = im.crop(bbox)
    k = CELL_H * FILL / im.height
    im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
    alpha = np.asarray(im.getchannel("A"))
    x = round(CELL_W * col + CELL_W / 2.0 - foot_x(alpha))
    y = round(CELL_H * FOOT_Y) - im.height
    x0 = CELL_W * col
    if x < x0 or x + im.width > x0 + CELL_W or y < 0:
        print(f"WARNING {path.name} col {col}: {im.size} clips the {CELL_W}x{CELL_H} cell at x={x - x0}, y={y}")
    out.alpha_composite(im, (x, y))


def build(lib: Path, name: str, spec: tuple, tmp: Path, site: str = "1") -> None:
    file, ref, band = spec
    if site != "1":
        file = file.replace("_hit.png", f"_{site.split('/')[0]}_hit.png")
    sheet = Image.new("RGBA", (CELL_W * 5, CELL_H), (0, 0, 0, 0))
    for col in range(5):
        cell(lib / f"{name}_hit_70_cells/{site}_{col + 1}.png", sheet, col)
    here = tmp / file
    sheet.save(here)
    tools = Path(__file__).parent
    if ref is not None:
        subprocess.run([sys.executable, "-I", str(tools / "street_tone.py"), str(here), str(P70 / ref), str(here)], check=True)
    if band:
        subprocess.run([sys.executable, "-I", str(tools / "street_armband.py"), str(here), str(here)], check=True)
    Image.open(here).save(P70 / file, optimize=True)
    print(f"{file}: {(P70 / file).stat().st_size} bytes")


def main() -> None:
    lib = LIB
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
    with tempfile.TemporaryDirectory() as t:
        for name, spec in SHEETS.items():
            build(lib, name, spec, Path(t))
            for site in SITES.get(name, []) + ([BURNS[name]] if name in BURNS else []):
                build(lib, name, spec, Path(t), site)


if __name__ == "__main__":
    main()
