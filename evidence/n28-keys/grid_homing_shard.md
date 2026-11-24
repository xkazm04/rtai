# Homing shard at tilt 70: own walk and run grids, by sheet-sized image edit (the n28 test)

The homing shard now walks and runs on `rivet_walk_eq_homing_shard.png` (4 columns) and `rivet_run8_eq_homing_shard.png` (8 columns), edited from the plasma rifle's two packed sheets. Before, it walked on the bare-claw stride with the shard on the palm. P55 is untouched.

## Route and cost

Route tested: **one edit of each whole sheet** (walk sheet 8 columns x 4 rows landscape, run sheet 8 x 8, the donor cells on a flat key background with gutters; image 2 = the homing shard equipped strip). **2 images** for 16 rows (the per-row route cost 16 images a weapon; electro gun: 16). Round: `C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/` (`STATE.md`, `jobs.json`, `scripts/prep.py` cut and register, `scripts/diffmask.py`, `scripts/finish_tone.py`, `scripts/stride.py`, `scripts/capture28.py`).

Cutting: key the green, cut every cell, scale it by dome width (whole-pixel best fit) and align the sole line to the donor cell. Two candidates per cell: raw (the edit as drawn) and legs-kept (the donor's pixels below a seam at 64 % of the figure, the edit above). Legs-kept was rejected for every row: the seam runs through the shard where the weapon dips below the hip (run row 6 shows the horn sliced; walk rows 1 and 3 keep donor rifle pixels below the seam), so it fails "no plasma rifle remnant". Raw passes everything, so **16 of 16 rows are raw**, 0 legs-kept, 0 re-edited. Images used: 2 of the 10 allowed.

The edit kept the legs: leg overlap with the donor is 0.89 to 0.94 on 12 rows, 0.72 to 0.80 on run rows 2, 6, 7 (the edit drew a slightly different leg line there); sole travel still matches the donor (next column) so the stride data barely moves.

## Per-row bars (against the plasma rifle row of the same facing)

Dome width within 3 %, sole line within 2 px (110 px space), tone within 2 per channel of the equipped strip, the leading boot per column read from the signed sole travel (same sign as the donor wherever the donor moves more than 8 px). Collar, shard and "no plasma rifle remnant" were judged by eye on every cell (contact montage of donor | raw | legs-kept for all 16 rows, full size for walk rows 1, 5, 6 and run rows 1, 5, 6, 8); colour law: the shard is the equipped strip's plum and magenta crystals, no red, no teal.

| Row | Facing | Gait | Route | Dome width dev (max of cells) | Sole y dev (110 px) | Leg overlap with donor (min IoU) | Signed travel own / donor (px) | Tone dev (RGB, max abs) | Pass |
|---|---|---|---|---:|---:|---:|---|---:|---|
| 1 | front | walk | raw | 0.00 % | 0.00 | 0.92 | -17.3, 17.3 / -18.0, 18.0 | 0.00 | yes |
| 2 | front right | walk | raw | 0.71 % | 0.00 | 0.91 | -9.3, 9.3 / -9.3, 9.3 | 0.00 | yes |
| 3 | right | walk | raw | 1.27 % | 0.00 | 0.89 | 47.0, 37.0 / 45.7, 33.3 | 0.00 | yes |
| 4 | back right | walk | raw | 0.69 % | 0.00 | 0.94 | -32.3, 32.3 / -31.7, 31.7 | 0.00 | yes |
| 5 | back | walk | raw | 0.00 % | 0.00 | 0.93 | 20.3, -20.3 / 20.3, -20.3 | 0.10 | yes |
| 6 | front left | walk | raw | 0.80 % | 0.00 | 0.92 | -13.0, 13.0 / -14.0, 14.0 | 0.30 | yes |
| 7 | left | walk | raw | 0.00 % | 0.00 | 0.91 | 31.7, 41.0 / 31.0, 41.0 | 0.20 | yes |
| 8 | back left | walk | raw | 0.77 % | 0.00 | 0.93 | -14.0, 14.0 / -14.0, 14.0 | 0.10 | yes |
| 1 | front | run8 | raw | 0.74 % | 0.00 | 0.91 | 1.7, 3.3 / 2.0, 3.3 | 0.10 | yes |
| 2 | front right | run8 | raw | 0.76 % | 0.00 | 0.80 | 45.0, 49.0 / 44.0, 47.7 | 0.10 | yes |
| 3 | right | run8 | raw | 0.00 % | 0.00 | 0.89 | 67.7, 63.7 / 68.0, 63.7 | 0.00 | yes |
| 4 | back right | run8 | raw | 0.00 % | 0.00 | 0.89 | -3.3, -0.7 / -3.0, -1.3 | 0.10 | yes |
| 5 | back | run8 | raw | 2.74 % | 0.00 | 0.93 | 4.3, -4.0 / 4.7, -4.0 | 0.10 | yes |
| 6 | front left | run8 | raw | 0.74 % | 0.00 | 0.72 | 42.7, 41.7 / 44.0, 43.0 | 0.10 | yes |
| 7 | left | run8 | raw | 0.00 % | 0.00 | 0.78 | 62.7, 62.7 / 62.0, 62.7 | 0.20 | yes |
| 8 | back left | run8 | raw | 1.69 % | 0.00 | 0.89 | 49.0, 47.3 / 47.3, 46.3 | 0.00 | yes |

Run row 5 (back) has the widest dome deviation, 2.74 %: the dome is narrow in the back view, so one pixel of resize rounding is a large share. Row order is the sheet's: front, front right, right, back right, back, front left, left, back left.

## Stride and wiring

Walk cycle 78.7 px, right-profile contact-to-passing 25.0 / 34.0 packed texels (plasma rifle: 76, shipped pin). Run rows: the stride rule gave k 0.94 to 0.99 for three rows, but the plasma rifle donor has no run_row_k either and the sole travel matches it, so the homing shard keeps k = 1 (with k 0.97 on the profile row the first in-game measure was run 8.59 cm; with k = 1, 5.44 cm). Data: `grid_stride.armed_cycle_cell` and `walk_profile_travel` rows in `rivet_motion.json`, pinned in `test_rivet_grid_stride.gd`; the loader picked the new files by name, no `walk_grid` row was needed.

## Feet (`tools/film/foot_slide.py`, right-profile lane, mean / max cm; the legs-film rig, `grid_homing_shard_foot_slide_*.json`)

| ppm | Homing shard walk | Homing shard run | Plasma rifle walk | Plasma rifle run |
|---|---|---|---|---|
| 32 | 1.09 / 2.28 | 5.44 / 8.53 | 5.63 / 7.19 | 4.35 / 7.69 |
| 64 | 1.34 / 2.22 | 4.42 / 8.05 | (not run) | (not run) |

Limits at 32 px/m: walk mean <= 2 cm, run mean <= 7 cm. Both met. The rig film runs the profile lane at its own speeds (the walk and run lane speeds in the json); the same-tick stills below are real input at 6.75 and 9.3 m/s.

## Stills and film

- [Stop-gap | new homing shard | plasma rifle, 32 px/m](C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_homing_shard_32.png) and [64 px/m](C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_homing_shard_64.png): eight facings walking at 6.75 and sprinting at 9.3 m/s, the same tick in each arm (row labels read "walk #n / run #n" in sample order and "g" = the sprite row the arena sampled).
- [Film, 32 px/m, tilt 70, 1080p60, 16.5 s](C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_homing_shard_32.mp4): the new grids walking and sprinting in 8 directions. ffprobe: 1920x1080, 60/1, 991 frames, 16.52 s.
- The stop-gap arm was rendered from this tree with the weapon's grid temporarily withheld (`walk_grid.by_weapon.homing_shard = bare_claw`, reverted); its samples show `rivet_walk8.png` / `rivet_run8.png` strips.

## Recommendation for the next four (mini-nuke, molotov, plasma sword, ray gun)

Use the same sheet-sized edit, 2 images each (8 for the four), then a retry budget of 1 to 2 images per weapon for rows that fail. It worked here because the model kept the donor legs, stride, pose and collar and replaced only the held part: every dome, sole and tone bar passed on the first cut. Changes to make:

1. Donor by grip: plasma rifle for long two-hand weapons (mini-nuke, ray gun); for the molotov (thrown, one hand) and the plasma sword (a blade held out) the plasma rifle's two-hand pose is a poorer donor than a one-hand family, so cut the donor from the pistol or katana sheets and ask for the held part to move to the one hand.
2. Add to the prompt: "the held part stays inside its cell" and "legs, boots and soles must be pixel-identical to image 1" (the three run rows with 0.72 to 0.80 leg overlap are the only soft spot).
3. Keep the raw cut; do not build legs-kept for weapons that dip below the hip (the seam slices them). Where the weapon sits above the hip (the sword raised, the molotov in the hand), legs-kept is safe and gives the donor's soles exactly.
4. Keep k = 1 when the own travel is within 3 % of the donor's (the donor has no k): the stride rule alone over-corrects.
5. Cap the run of image jobs at one at a time; both edits here landed on the first try.
