"""n11 combat: the drawn hit cells (the asset lane's <kind>_hit_70_cells, 5 facings of a body thrown
back by a round) laid out as the game's card grids: 5 facings across, one row, each cell 344 x 256
with the planted boot on the cell's centre line at StreetWalkerCards.FOOT_Y, so the rest of the
figure leans off the point the rig stands on. The figure fills FILL of the cell's height (the
standing strip's 1.7 m). Blue is toned to the same kind's armed walk (street_tone), a riot or SWAT
sheet's orange arm band is greyed (street_armband, colour law). Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_hit.py [--lib=<library>/keyed/street] [--only=char|<kind>]
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
    # n15 item 2: quest 1's dock contractor (assets it321, hit stagger v2 A; StreetQuestHit draws it)
    "contractor": ("contractor_hit.png", None, False),
}
# it14: the per-site flinch cells drawn for a kind (<site>_<col>.png, the right-hand facings 1..5;
# the left ones mirror as the grid does), each to <kind>_<site>_hit.png on the same layout.
SITES = {"cop_patrol": ["shoulder", "gut"]}
# n11 it33: the asset lane's drawn burning man (<kind>_hit_70_cells/burn/1_<col>.png, arms flailing,
# flames up his sides), packed as <kind>_burn_hit.png on the same layout for a LIVING burn.
# n11 it34: the asset lane's burn cells for six more kinds (06:17-06:37 offers; suit, shopper and
# elder were drawn singed, not burning, and keep the walk under the loops).
BURNS = {k: "burn/1" for k in ("cop_patrol", "cop_riot", "swat", "thug", "ped_hood", "ped_cap", "ped_punk", "ped_jogger")}
# n15 combat: a redrawn thrown-back set in a version folder (<kind>_hit_70_cells/<v>/1_<col>.png). Its
# poses differ in height (the elder's v3 flings an arm wide, the SWAT's v4 carbine hangs past his boots),
# so the five cells take ONE scale, the tallest filling FILL, and stand on the planted boot's own bottom,
# not the cell's lowest pixel (a cane tip). Height-fitting each cell drew the elder's low flung pose 1.25 x.
# Removing a line packs that kind's first set as before.
# n15 c-2 (owner call): the thrown-back redraws at the walk camera (assets it268, picks in the it350 reply):
# head and shoulders the largest shapes, the legs short stubs, never a whole upturned face.
VERSIONS = {
    "swat": "v4",
    "ped_elder": "v3",
    "cop_patrol": "v2",
    "ped_cap": "v2",
    "ped_hat": "v2",
    "ped_jogger": "v2",
    "ped_shopper": "v2",
    "ped_suit": "v3",
    "ped_punk": "v3",
    "ped_hood": "v3",
    "thug": "v4",
    "contractor": "v3",
}
# A version whose poses match an earlier set but reach lower (the contractor's v3 carbine hangs below his boots,
# assets it359 (3)) takes that set's scale, its hat where the old set's hat stood (`like`; never by the cell's height).
SCALE_FROM = {"contractor": "v2"}
# px added under such a grid's cells, so the hanging muzzle is not cut flat at the floor (the feet stay CELL_H *
# FOOT_Y from the top; StreetQuestHit scales its cell and foot line by the texture's height).
PAD_BELOW = 32
# n15 combat: the burning figure's second flail frame (burn/1b_<col>.png) as <kind>_flail_burn_hit.png on
# the same layout, each facing at the scale its burn/1 cell takes, so the two frames swap without a pop.
FLAILS = "burn/1b"
# n15 combat: the drawn charred man standing (assets it272, cop patrol only, B; smoke stripped) for a fire death,
# <kind>_char_hit.png on the same layout, each facing at its burn/1 cell's scale like FLAILS (the burning man
# turns to char without a size pop). KillCharFx draws it in place of the char-shaded card.
# assets it359 (A, no smoke): the thug, the hooded pedestrian and the riot cop, the flamethrower's most frequent kills.
# assets it363 (A; ped_cap B, its strap letters erased): the capped and jogging pedestrians, the punk and the SWAT man.
# assets it371 (A): the SWAT man's char cells again with empty hands (char_v2): his carbine falls at the kill and
# lies at his feet, so a charred carbine across his body read as a second gun.
CHARS = {k: "char/1" for k in ("cop_patrol", "thug", "ped_hood", "cop_riot", "ped_cap", "ped_jogger", "ped_punk")}
CHARS["swat"] = "char_v2/1"


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


def boot_bottom(alpha: np.ndarray) -> int:
    """The lowest solid row under the planted boot's run (foot_x), not under a cane or a muzzle."""
    h = alpha.shape[0]
    band = (alpha[int(h * (1.0 - FOOT_BAND)) :] > 128).any(axis=0)
    x = int(foot_x(alpha))
    lo, hi = x, x
    while lo > 0 and band[lo - 1]:
        lo -= 1
    while hi < len(band) - 1 and band[hi + 1]:
        hi += 1
    return int(np.nonzero((alpha[:, lo : hi + 1] > 128).any(axis=1))[0].max()) + 1


def cropped(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    return im.crop(im.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox())


def cell(path: Path, out: Image.Image, col: int, k: float = 0.0, boot: bool = True) -> None:
    im = cropped(path)
    uniform = k > 0.0 and boot
    if k <= 0.0:
        k = CELL_H * FILL / im.height
    im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
    alpha = np.asarray(im.getchannel("A"))
    x = round(CELL_W * col + CELL_W / 2.0 - foot_x(alpha))
    y = round(CELL_H * FOOT_Y) - (boot_bottom(alpha) if uniform else im.height)
    x0 = CELL_W * col
    if uniform:
        # a flung hand past the cell edge would land in the next facing's cell: shift the figure in
        # (the boot leaves the centre line by that much, at most about 0.15 m in game) instead
        x = min(max(x, x0), x0 + CELL_W - im.width)
    if x < x0 or x + im.width > x0 + CELL_W or y < 0 or y + im.height > CELL_H:
        print(f"WARNING {path.parent.name}/{path.name} col {col}: {im.size} clips the {CELL_W}x{CELL_H} cell at x={x - x0}, y={y}")
    out.alpha_composite(im, (x, y))


def hat_x(alpha: np.ndarray) -> float:
    """The x centre of the figure's top 15 % (the hat): a register that a hanging gun does not move."""
    top = alpha[: max(1, int(alpha.shape[0] * 0.15))] > 128
    xs = np.nonzero(top.any(axis=0))[0]
    return (xs.min() + xs.max() + 1) / 2.0


def like(old: Path, new: Path, out: Image.Image, col: int, k: float) -> None:
    """`new` at `old`'s scale with its hat where `old`'s hat lands in the cell (SCALE_FROM): the boot finder
    would take a muzzle hanging past the boots for the planted boot."""
    a = cropped(old)
    a = a.resize((round(a.width * k), round(a.height * k)), Image.LANCZOS)
    alpha = np.asarray(a.getchannel("A"))
    x0 = min(max(round(CELL_W * col + CELL_W / 2.0 - foot_x(alpha)), CELL_W * col), CELL_W * col + CELL_W - a.width)
    y0 = round(CELL_H * FOOT_Y) - boot_bottom(alpha)
    b = cropped(new)
    b = b.resize((round(b.width * k), round(b.height * k)), Image.LANCZOS)
    x = round(x0 + hat_x(alpha) - hat_x(np.asarray(b.getchannel("A"))))
    x = min(max(x, CELL_W * col), CELL_W * col + CELL_W - b.width)
    if y0 + b.height > out.height:
        print(f"WARNING {new.parent.name}/{new.name} col {col}: {b.size} clips the cell's floor by {y0 + b.height - out.height} px")
    out.alpha_composite(b, (x, y0))


def grey_cyan(path: Path) -> None:
    """Cyan-teal (hue 165-205 deg) to its own grey value: the char cells' stripped smoke left faint teal traces
    (teal is for souls only)."""
    px = np.asarray(Image.open(path).convert("RGBA")).astype(np.float32)
    rgb = px[:, :, :3] / 255.0
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    hue = np.degrees(np.arctan2(np.sqrt(3) * (g - b), 2 * r - g - b)) % 360
    mask = (hue >= 165) & (hue <= 205) & (sat > 0.03)
    grey = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    px[mask, :3] = grey[mask, None] * 255.0
    Image.fromarray(px.round().astype(np.uint8)).save(path)


def build(lib: Path, name: str, spec: tuple, tmp: Path, site: str = "1") -> None:
    file, ref, band = spec
    if site == FLAILS:
        file = file.replace("_hit.png", "_flail_burn_hit.png")
    elif site != "1":
        file = file.replace("_hit.png", f"_{site.split('/')[0].split('_v')[0]}_hit.png")  # char_v2/1 -> _char_
    pad = PAD_BELOW if site == "1" and name in SCALE_FROM else 0
    sheet = Image.new("RGBA", (CELL_W * 5, CELL_H + pad), (0, 0, 0, 0))
    paths = [lib / f"{name}_hit_70_cells/{site}_{col + 1}.png" for col in range(5)]
    k = 0.0
    if site == "1" and name in VERSIONS:
        paths = [p.parent / VERSIONS[name] / p.name for p in paths]
        olds = [p.parent.parent / SCALE_FROM[name] / p.name for p in paths] if name in SCALE_FROM else paths
        k = CELL_H * FILL / max(cropped(p).height for p in olds)
    for col in range(5):
        if site == "1" and name in SCALE_FROM:
            like(olds[col], paths[col], sheet, col, k)
            continue
        if site in (FLAILS, CHARS.get(name)):  # frame 1's own height-fill scale for this facing
            k = CELL_H * FILL / cropped(lib / f"{name}_hit_70_cells/{BURNS[name]}_{col + 1}.png").height
            if site == CHARS.get(name):  # a char cell taller than its burn cell stays inside the cell (the thug's col 4)
                k = min(k, CELL_H * FOOT_Y / cropped(paths[col]).height)
        cell(paths[col], sheet, col, k, boot=site not in (FLAILS, CHARS.get(name)))
    here = tmp / file
    sheet.save(here)
    tools = Path(__file__).parent
    if ref is not None:
        subprocess.run([sys.executable, "-I", str(tools / "street_tone.py"), str(here), str(P70 / ref), str(here)], check=True)
    if band:
        subprocess.run([sys.executable, "-I", str(tools / "street_armband.py"), str(here), str(here)], check=True)
    if site == CHARS.get(name):
        grey_cyan(here)
    Image.open(here).save(P70 / file, optimize=True)
    print(f"{file}: {(P70 / file).stat().st_size} bytes")


def main() -> None:
    lib = LIB
    only = ""  # --only=char packs just the CHARS sheets (a full re-pack drifts some burn grids by a few px)
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
        elif arg.startswith("--only="):
            only = arg[7:]
    with tempfile.TemporaryDirectory() as t:
        for name, spec in SHEETS.items():
            if only == "char":
                if name in CHARS:
                    build(lib, name, spec, Path(t), CHARS[name])
                continue
            if only and only != name:  # --only=<kind>: that kind's sheets alone
                continue
            build(lib, name, spec, Path(t))
            for site in SITES.get(name, []) + ([BURNS[name], FLAILS] if name in BURNS else []) + ([CHARS[name]] if name in CHARS else []):
                build(lib, name, spec, Path(t), site)


if __name__ == "__main__":
    main()
