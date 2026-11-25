# n29 keys: Gloria's p55 held strips in brass + the left p70 strip's muzzle

Brief `evidence/briefs/n29-03b-gloria-strips-live.md`. Round dir `gtai-art/rivet-n29/gloria_p55/` (STATE.md, jobs.json,
cut55.py, install55.py, check55.py, p70left/cut_pad.py). Stills in `gtai-masters/n29/keys/gloria/`.

IMAGES 3 (p55 main, diag, left: one Codex image edit each; image one = the p55 pistol strip, image two = the n28 p70
brass strip). The p70 left fix is a re-cut, no image.

## p70 left (`p70/rivet_eq_gloria_left.png`)
The n28 image source had the whole muzzle; the n28 cut rolled cells 2 and 3 left by 5-6 px with `np.roll`, so the tip
wrapped to the cell's right edge (20 / 18 / 17 opaque px on the edge columns). Re-cut with the same cut on cells widened
191 -> 215 px (12 px each side; the figure stays centred, every reader takes `width / LEFT_CELLS` and centres the cell).
Edge columns 0 opaque px in all three cells. Muzzle rows (110 space) were stale `(58,93) (58,83) (58,74)` -> gun left tip
`(11,58) (5,58) (5,58)`, like the pistol's `(2..8, 62..63)`. Still: `gloria_left_p70_cells.png` (before | after, 4x).

## p55 strips (n27 compact gun -> n28 brass gun)
Cells widened so the longer gun and its pasted flash close inside: main 196 -> 224 px, left 133 -> 161 px
(14 px each side, figure centre unchanged; RivetFrames and RivetMuzzle centre a cell by `width / cells`). The diag strip
keeps the pistol's 196 px cells: `RivetGunDiag.HELMET_X["p55/gloria"]` seats each diagonal cell on its helmet x in strip px,
and a padded cell would move it 14 px (the first commit 7bb6f9cc0 widened diag too; the follow-up commit restores 196 px).
New diag helmet centres 98.5 / 65.5 / 96.0 / 127.0 vs the table's 97.5 / 66.5 / 96.5 / 126.5. There the pistol flash is
scaled about its root to fit (cell 0 x0.91, cell 2 x0.70) with a 6 px fade at the cell edge: cell 2's flash is smaller
than the pistol's. A NEED for the whole flash: HELMET_X p55/gloria +14 with a 224 px diag strip (padded cut kept in
`gtai-art/rivet-n29/gloria_p55/cut/pad14/`). Flash: the pistol's own flash pixels pasted at her muzzle, offsets read by
eye per cell from 5x crops (`v_tips.png`). Muzzle rows re-measured (`rivet_muzzle.json` p55 gloria rows).

| strip | brass hue (median, gun mask) | IoU outside the gun vs pistol | edge px | red / teal |
|---|---|---|---|---|
| main (8) | 31.5-34.2 noflash, 34.9/36.6 in the flash cells | 0.950-0.974 | 0 | 0-3 px (pistol 1-8) / 0 |
| diag (4) | 32.4-34.1 noflash, 34.7-35.3 with flash | 0.950-0.968 | 0 | 1-5 px (pistol 8-12) / 0 |
| left (3) | 35.8-36.0 (gun box) | 0.902-0.925 | 0 | 0 / 0 |

Hue note: by the same mask the shipped p70 brass strip reads 33.4-34.5 (n28's 38.5 was a different mask on the concept),
so p55 matches p70; under the brief's 35-45 band by this mask on main/diag noflash cells. One claw holds the gun, the
other is free in every cell; the collar stays the rigid vermilion/black band. Stills: `gloria_p55_strips.png` (n27 | n29
| pistol, 3x), `p55_strips_4x.png` (pistol | n27 | n29, 4x). All looked at.

Not done: held/held_55 art (lives under `features/combat/`, outside the allowlist), in-game 64 px/m p55 firing still.
