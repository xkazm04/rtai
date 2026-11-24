# n27 Gloria at the 55 degree camera (brief n27-04)

Starts from `de294053e`. Part A is committed (`2a9630ecb`). Part B (the director's replacement: prove the stop-gap at tilt 55) is evidence only; there are no p55 walk/run grids to ship.

## Which setting selects p55
The arena game takes `--view=tilt` (p55) or `--view=tilt70` (p70); the film scenes (`grid_arena_film`, `n27_stills`, `n27_clip`) read it through ArenaArgs. The log line `strip=res://features/characters/art/view/p55/rivet_eq_gloria.png` proves the p55 art is the one drawn.

## Images: IMAGES 3 of 3
Round `gtai-art/rivet-n27/gloria-p55/` (jobs.json, refs/, out/, gen.log, STATE.md). Image one = the shipped p55 pistol strip (`rivet_eq_pistol_noflash` 8 cells as 2 rows of 4, `_diag_noflash` 4 cells, `_left` 3 cells) x3 on #00B140;
image two = the SHIPPED p70 Gloria cells 0, 2, 5 (so p55 and p70 show the same gun). Prompt: keep every figure exactly (pose, one gun hand, free claw, hose, rigid striped hazard collar, size, spacing, order), replace only the pistol with Gloria's compact nail gun as drawn on image two's figures, same size and angle per figure, no flash.
Jobs `gloria_p55_main`, `gloria_p55_diag`, `gloria_p55_left`.

## Cut and registration (`gloria-p55/cut2.py`, `install55.py`, `weapon_art55.py`)
Same method as p70 (`evidence/n27-keys/gloria.md`): key, de-halo, figures by connected component (the model's white letterbox bands on the diag and left sheets are keyed out first),
scale and shift by head/torso mask IoU onto the p55 pistol's cells (196x171 main/diag, 133x172 left): IoU 0.93-0.98 main, 0.91-0.97 diag, 0.94-0.96 left; tone matched per channel.
The p55 strips are now the pistol's size (1568x171, 784x171, 399x172); the old Gloria p55 strips were 1808x171 / 904x171 / 678x171 (the long gun needed wider cells).
Flash: the p55 pistol's own flash pixels pasted at her muzzle (offsets main cell 5 (-7,-4), cell 6 (1,0); diag (1,1) (-1,-1) (0,-1) (-5,2) strip px).

## Data changed (p55 gloria only)
- `rivet_muzzle.json` p55: main cells 3 [97,49], 4 [109,55], 5 [111,48], 6 [51,67] (cell 1 dropped, like the pistol); diag [106,80] [93,24] [19,78] [34,25]; left [8,47] [7,46] [2,47]; `rivet_eq_gloria_left_fire` removed.
- `rivet_gun_diag.gd` p55/gloria: DEG [37,-42,145,-138], HELMET_X [97.5,66.5,96.5,126.5] (the p55 pistol's); FOOT_PX stays 2.0 (the pistol's).
- `rivet_cell_feet.gd`: the `p55/rivet_eq_gloria.png:6` entry dropped (the p55 pistol has none).
- `rivet_res.gd`: p55 `rivet_eq_gloria_left_fire.png` removed; the strip, its noflash twin and `.import` files deleted (nothing loads them; the p55 `_left_fire` keyed her as a long gun).
- `tools/art/rivet_frames.json` p55 gloria entries like the pistol's (sheet names not committed), left_fire entries removed.
- `held_55/gloria.png`, `gloria_small.png` (605x382, the p70 gun at the pistol's held length of 349 px, right aligned) and `showcase/p55/gloria.png` (346x205) cut from the p70 gun.
  **NEED, resolved:** `weapon_held_pitch.json` holds the p55 held geometry (not `weapon_art.json`): gloria p55 grip_px [354,262], length_px 349, muzzle_px [599,158] re-measured on the new png (were [323,236], 589, [596,150] for the long gun). Nothing else in the file changed.
- 8 provenance lines appended.
- `test_rivet_walk_held_only.gd`: a cold-start case (`_grid`/`_held_only` cleared, then `held_only(gloria, p70)`). Mutation of `rivet_frames_grids.gd` lines 23-27, 47-49 before it: 4 killed of 5 (the survivor deleted the lazy `_load()` in `held_only`); after it: 5 killed of 5 (100 %, 320 s).

## Looked at (tilt 55, arena, Gloria equipped, 64 px/m, 8 aim octants, rest and fire)
`gtai-masters/n27/keys/gloria_p55_before_after_64.png` (old | new | p55 pistol; the old column rendered in a temp worktree at `de294053e` after copying the import cache, `git worktree remove`d afterwards, so no index games in this tree).
The old column shows the long two-handed gun in every panel. New: one hand, free claw free, no second gun, the game's flare at the muzzle on the shot tick, left octants use her drawn left strip.
Standing height (head top to foot point, mean of 8 octants): old 153.5 px, new 153.9 px, pistol 153.4 px (octant 0: 154 / 155 / 155).

## Part B: p55 walk and run (no grids)
p55 never had Gloria walk/run grids (no `p55/rivet_*_eq_gloria.png`), so at p55 she walks on the bare stride with the held part on the palm; the `bare_claw_p70` row in `rivet_motion.json` is p70 only and p55 needs no row. No per-facing grid table (no grids), no stride data.
- `gloria_p55_walk_64.png`: standing | walking 6.75 | sprinting 9.3 m/s at octants 0, 2, 4, 6; the compact gun is in the palm in every frame, no long gun.
- `gloria_p55_walk_run_32.mp4`: 16 s, 32 px/m, tilt 55, walking then sprinting in 8 directions (one per second) with the trigger held late in each beat. ffprobe: 1920x1080, 60 fps, 961 frames, 16.02 s.
- Capture scripts (outside the repo): `gloria-p55/capture/` (`n27_stills`, `n27_clip` scenes copied into `project/dev/motion` for the run and deleted).

## Ranked: which other p55 eq strips share the pistol's body pose (measured, not built)
Method: each weapon's p55 `rivet_eq_<w>_noflash.png` facing cells 0-4 are placed on the p55 pistol's cell by bottom-centre, shifted +-8 px x / +-6 px y to the best overlap; IoU of the figure silhouettes in the upper half (head, torso, arm and gun) and in the lower half (legs and boots).
Legs are the number that matters for a grid transplant (the gun is what gets replaced); the new Gloria strip scores 0.966 / 0.947 against the pistol, the ceiling for an edit of the pistol strip.
Upper / lower mean over facings 0-4:
1. hand_cannon 0.938 / 0.841 (the closest family; lower facings 0.76-0.89)
2. plasma_rifle 0.894 / 0.793
3. electro_gun 0.866 / 0.789
4. ray_gun 0.890 / 0.783
5. assault_rifle 0.894 / 0.779
6. machine_pistol 0.889 / 0.769
7. homing_shard 0.840 / 0.763
8. rocket_launcher 0.794 / 0.748
9. mini_nuke 0.870 / 0.728
10. gatling 0.775 / 0.645 (a different body pose; do not transplant onto the pistol grid)
None of them reaches Gloria's 0.95 legs, because those strips were drawn separately (different leg poses and stances), not as edits of the pistol strip. The route that scored for Gloria is an image edit of the shipped p55 pistol strip (new strip = pistol body), which then makes the transplant exact by construction. Caveat: the grid-row poses differ from the eq cells (n27-03b), so even then the grid needs a hand-aligned gun mask and row-to-cell pairing by gun match; this call did not attempt a grid.

Commits: `2a9630ecb` (part A), the evidence commit below.
