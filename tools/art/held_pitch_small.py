"""Small held parts for the raised-camera views (d8-weapons, 2026-11-06).

The three-quarter held parts (features/combat/weapons/art/held_<pitch>/, weapon_held_pitch.json)
printed bigger and muddier than the slim top-down part at the shipped 32 px/m: the side body's
mid tones crossed the print shader's small-scale posterize into ink. This writes
`held_<pitch>/<id>_small.png`, the same part on the SAME canvas (grip, muzzle and length stay
valid) re-toned with held_small.py's curve (Rivet's tone budget, an inked silhouette), which
HeldPitchArt draws below weapon_art.json's held_small_below_ppm, as WeaponArt does for `top`.

Re-tone the RAW cut (before the print prep, which grows the line work into solid ink so the full
part survives the mips at 48 px/m): re-toning the prepped part keeps that ink and stays a blob.

    python tools/art/held_pitch_small.py [--raw <cut_dir>] <held_pitch_dir> [ids...]   (default: every part;
        --raw: where the unprepped cut <id>.png lives, on the same canvas; default the held dir)
    python tools/art/held_pitch_small.py --sim <out.png> <held_pitch_dir> [ids...]   (print preview)
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
import held_small as hs  # noqa: E402

# Pale already (held_small.SKIP): re-toning flattens the glass and the glow core.
SKIP = hs.SKIP
EDGE = 6  # part px of silhouette ink: the side body is drawn finer than the top-down parts
# Two-tone (ink body, the drawn cream kept as paper), as held_small.py does for Gloria: the re-toned
# 55 long guns printed as pale clubs at 32 px/m, merging with the visor and the legs; the two-tone
# cell reads as a dark gun with pale details (d8 iteration 4, filmed at 32 tilt; the full tan part
# still draws from held_small_below_ppm up). homing_shard too (filmed at 32). Not the baton: as two-tone
# it printed as a solid black stick at 48 px/m (its pale bands gone).
TWO_TONE = hs.TWO_TONE + ("plasma_rifle", "electro_gun", "ray_gun", "homing_shard")


def main(argv):
    sim = None
    raw = None
    while argv and argv[0] in ("--sim", "--raw"):
        if argv[0] == "--sim":
            sim = argv[1]
        else:
            raw = Path(argv[1])
        argv = argv[2:]
    root = Path(argv[0])
    ids = argv[1:] or sorted(p.stem for p in root.glob("*.png") if not p.stem.endswith("_small"))
    tiles = []
    for wid in ids:
        if wid in SKIP:
            continue
        src = raw / f"{wid}.png" if raw is not None and (raw / f"{wid}.png").exists() else root / f"{wid}.png"
        rgba = np.asarray(Image.open(src).convert("RGBA"))
        small = hs.two_tone(rgba) if wid in TWO_TONE else hs.retone(rgba, None, EDGE)[0]
        if sim is None:
            Image.fromarray(small).save(root / f"{wid}_small.png", optimize=True)
            print(f"{wid}: small")
            continue
        sc = 1.4 * 32.0 / 600.0 * 1.2
        for zoom in (1.0, 1.5):
            tiles.append((wid, zoom, hs.print_sim(rgba, sc * zoom, 0.1 * zoom), hs.print_sim(small, sc * zoom, 0.1 * zoom)))
    if sim:
        hs._sheet(tiles, sim)


if __name__ == "__main__":
    main(sys.argv[1:])
