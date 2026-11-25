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

## p55 diag flash drawn whole (n29-09, commit 9efd28136)
The diag strip is back on the 224 px padded cut (`gtai-art/rivet-n29/gloria_p55/cut/pad14/`, the pistol's flash unscaled, no
6 px edge fade). `HELMET_X["p55/gloria"]` 97.5 / 66.5 / 96.5 / 126.5 -> 112.5 / 79.5 / 110.0 / 141.0 (the measured 98.5 / 65.5 /
96.0 / 127.0 + 14; the body moves 1 px at most per cell, 0 against its own pixels); diag muzzle rows (116,82) (102,24) (9,84)
(31,25) -> (126,82) (111,24) (18,84) (40,25), the padded measurements. Flash scale 1.0 (was 0.91 / 0.70). Unit `--changed`
1244 passed, 0 failed. Still `gtai-masters/n29/keys/gloria/p55_diag_flash_64.png` (before | after, 2x, cells seated on the helmet
x as `RivetGunDiag.seat` does), composed from the strips: the in-game shot could not be taken (arsenal_turn cannot fire Gloria,
the pilot resets `hold.held`). Mutate: `--lines=72` offers no mutants (a packed-array literal); not run.

## n29-15 Gloria p55 flash in game
- Route 1 (plain, this worktree, no edit): `runGodot(['--rendering-driver','d3d12','--position','0,1440','-s','res://dev/rivet_arsenal/arsenal_turn.gd','--','--weapon=gloria','--pitch=p55','--ppm=64','--out=<build dir>'], {headless:false})` -> `no attack for gloria at octant 0`, exit 1. The pistol fails the same way at HEAD, so it is not a Gloria-only gap.
- Cause (debug log in the snapshot): `RivetCarry.take` selects nothing while `wheel_inventory` is on, and the first `session.step()` runs the hands-first wheel, which stows the gun (`RivetWheel._stow`: `rivet.weapon = &""`, `gun = null`). `DBG0 w=gloria gun=true` became `DBG1 w= gun=false` one step later. Slot 1 holds gloria and pistol alike.
- Route 2 (snapshot `gtai-gflash-4c4b35d858c3` of HEAD `4c4b35d85`, dev-only edit in `project/dev/rivet_arsenal/arsenal_turn_rec.gd`): `TurnPad.slot` ORs the weapon's slot key bit (`RivetCarry.SLOT_ACTIONS[slot]`) for one `_step()` before `_record()`, then 5 idle steps (+8 lines); still crop `Vector2i(204, 194)` -> `(404, 294)` and base 164 -> 214 (the stock crop clips every diagonal flash, pistol too). Both runs exit 0, 16 stills each (`oct0..7_fire`), same runGodot command with `--weapon=gloria` and `--weapon=pistol`. APPDATA the keys lane's.
- Still: `gtai-masters/n29/keys/gloria/p55_flash_ingame_64.png` (6464x1176, 2x nearest; row 1 Gloria, row 2 pistol, octants 0..7 left to right), read by eye.

| octant | flash whole | flash at muzzle tip | gun brass | body |
|---|---|---|---|---|
| 1 (down-right) | yes | yes, starts at the barrel end, about 0-3 px | yes | in place |
| 3 (down-left) | yes | yes, about 0-3 px | yes | in place |
| 5 (up-left) | yes | yes, about 0-3 px | yes | in place |
| 7 (up-right) | whole sprite, its top spike touches the crop top (crop, not sprite) | yes, about 0-3 px | yes | in place |

- Offsets are by eye on the 2x still, not pixel-measured: "0-3 px" is not a proven <= 3 px. Clipped flashes in the game: 0. The pistol row shows the same flash positions.
- Colour: the flash is cream with a red-orange core, the pistol's own art pasted at her muzzle (shared). The "amber, no red" bar is NOT met by the flash art itself (Gloria and pistol alike).
- Snapshot removed after the run; product files in this worktree untouched.
