# REPORT: n11 lane hero (Rivet and the ghosts)

Written it11 23:25, refreshed it13 01:16 and it17 (06:05, 2026-11-10). Branch `n11-hero`, cut from main `812a0b06`. Evidence is under `C:\Users\kazda\kiro\gtai-masters\n11\hero\` (`frames.json`, 15 entries, best first); the working log is `JOURNAL.md`; per-character levels with evidence paths are in `LEVEL.md`. All file names below are in that masters folder unless they carry a path.

## What works, with evidence

| Owner's note | What changed | Evidence |
|---|---|---|
| "Direction of player should follow cursor" | `rivet.facing` is the aim wherever a device aims, a sprint included; drawn octant from the aim with a 4 deg hold; aim taken from gun height through the combo projection (18a4b74f). The ghost forms follow the same look (57bf1dd3). Controller aim unchanged. | `aim_sweep_before_after_sprint_64ppm.png`, `ghost_aim_sweep_walk_64ppm.png`; drawn-octant error, mean/worst deg: Rivet walk 11.6/26.7, every ghost about 11.4/25 (11.25 is the floor of any 8-cell card) |
| "Melee attack follows always only one direction" | The sim direction and hit area were already right; the art was stuck on one cell. Rivet's bare claw plays a drawn 8-direction strike (6f591976); blades use the baked cell only where it points the cursor's way and a game arc along the aim elsewhere (c8d71e34). Each ghost has drawn act cells by facing (6d2e643e, 5af9ba1d). | `melee_8dir_drawn_strike_64ppm.png`, `melee_8dir_before_after_claw_blade_64ppm.png`, `ghost_melee_8dir_64ppm.png` |
| "Rivet jumps too much" | The drawn helmet travel in the walk/run grids comes back as a height stretch from the feet, so the feet stay planted; only the run's flight frames lift (6e10aa7a, 4b80f997). Sprint head line range 10 -> 2 px. | `bob_film_right_before_after_64ppm.png`, `bob_before_sprint.gif` / `bob_after_sprint.gif` |
| "Increase size ... to 150%" | One data value, `data/tables/player_scale.json` `k` 1.5, render only (61d5d9eb). Rivet's walk and run grids repacked at x1.5 resolution (568d26f9); since it14 his p70 pistol (facing, fire, left), plasma rifle and katana strips are cut at x1.5 too (`RivetRes.X15`: 8ae5cc25, 0af2d9af, 8a279b28), so standing and shooting he is no longer a 110 px upscale. | `size_150_before_after_walk_64ppm.png`, `size_150_ghost_forms_64ppm.png`, `rivet_x15_grids_before_after_64ppm.png`, `rivet_x15_pistol_strip_before_after_64ppm.png` (zoom `rivet_x15_pistol_strip_zoom_x2_64ppm.png`), `rivet_x15_plasma_strip_before_after_64ppm.png`, `rivet_x15_katana_strip_before_after_64ppm.png` |
| "Ghosts ... need animations and polish Rivet received" | `GhostDrawn`: each form is one drawn figure on Rivet's strip format, with a drawn walk, run grids where the form is fast, act cells (wind-up/strike/follow/hit), feet stepped by the ground walked on a stride measured off the drawn stance foot (`GhostStride`). All four at p70 **and** the 55 boss pitch (Tonnage's 55 since it14, 450acaa3). Tonnage walks on **16 drawn frames on all five facings** (it14-16: 14db3b0a, 1fd66481, 3091a7be), more than Rivet's 8. Dent runs at 7 m/s on all five facings, arms alternating with the legs (43f0ea59, 78268732, 9f11a80b). | `tonnage_walk16_all_rows_before_after_64ppm.png` (clip `tonnage_walk16_toward_before_after_clip_64ppm.gif`), `dent_run8_r4_arms_before_after_64ppm.png`, `tonnage_p55_v3_before_after_64ppm.png`, `dent_drawn_p55_before_after_64ppm.png`, `kerf_drawn_run8_64ppm.png`, `ghost_acts_seen_64ppm.png`; levels in `LEVEL.md` |

Owner's correction (track the level, keep raising): `LEVEL.md` holds one row per measure, one column per character, each cell with level and evidence. Every ghost reached Rivet's level 3 on facing cards, cursor facing and attack directions (dates in the table); Tonnage's 16-frame walk is the first level-4 candidate (past Rivet). The bar was raised on two rows (it10): no visible snap between octants, and anticipation on every attack.

## What does not work yet (as of it17)

- **Hit and death cells** of Tonnage, Dent and Ohm are wired but not filmed (level 2): the weakest cells left in `LEVEL.md`. Combat feel for the ghosts is level 2 (Tonnage's wind-up reads through the floor ring more than his body; Ohm's bolt carries the direction, his body barely).
- **Planted feet on the ghosts** are level 2: measured on the sheets (Tonnage's stance pad slide per stance 32 -> 21 and 58 -> 40 cell px), not yet in world space on the dark arena floor. Tonnage's m34 timing gain (3091a7be) is measured on the sheet, not seen in a film (the every-4th-tick film never lands on that frame).
- Rivet's strips other than p70 pistol, plasma rifle and katana (other weapons, every p55 strip, reload, knock, strike) are still 110 px upscaled; switching weapon or a boss fight softens him.
- Ohm's walk is B art (stubby); Dent's 3/4 away run slot 7 lifts the far hand above the helmet for one frame (redraw requested).
- Tonnage's drawn figure carries a white-blue spark outline where his old card glowed teal: the soul colour reads less on the drawn ghosts (all four).
- Doors, alleys, vehicles and quest scenes at x1.5 not checked; 32 px/m not looked at.
- **Intermittent `scenario_rig_stress` error**: `Parameter "t" is null` under `RivetFrames._set_strip` on its COMBO pass, 2 of about 8 full scenario runs since the x1.5 sheets (it11, it16), never alone. A diagnostic (c6d07c8a) now logs the sheet path when a strip loads empty; it has not fired since. Not called a flake, not fixed: see Merge notes.
- Bench: one run, CONTENDED (01:33, other lanes running): p99 3.68 ms, 1 % low 224 fps. No quiet-machine number.

## Calls for the owner

1. **x1.5 is visual only.** Rivet and the ghosts draw at x1.5; hitboxes, collision and reach stay as before, so doorways and replays hold. The alternative (sim size x1.5) is one data value plus a replay re-bless. Still: `size_150_before_after_walk_64ppm.png`.
2. **Tonnage's size.** The forms table makes him 3x base Rivet, then x1.5: about 4.95 m drawn, filling a 300 px crop at 64 px/m and hiding cops near him. Keep, or take him back to x1.0 (one value). Still: `size_150_ghost_forms_64ppm.png`, `ghost_melee_8dir_64ppm.png`.
3. **The ghosts' left facings are mirrored** right facings (five drawn facings, three mirrored), as Rivet's grids were before n9. Drawn left rows are a request to the assets lane. Still: `ghost_melee_8dir_64ppm.png` (the left octants).
4. **Dent's melee press with no seized car does nothing visible** (melee is his overload command; the seize is on fire). A player mashing melee as Dent sees no reaction. A design call, not this lane's sim. Still: `ghost_acts_seen_64ppm.png`.

## Merge notes

- Render-only changes throughout; no replay or parity golden moved or re-blessed on this lane (see JOURNAL GATES lines).
- New data table `player_scale.json` (+ schema); new art under `features/souls/art/view/p70|p55/` and x1.5 Rivet strips under the Rivet art folder (`RivetRes.X15` lists them); tools `tools/art/ghost_pack.py`, `rivet_frames.py` (`fig_h` per manifest row).
- Debt baseline raised once with `--accept-regression` (`ghost_form_view.gd` 206 -> 208 lines, `dev_loc` +6); see JOURNAL it9.
- Watch `scenario_rig_stress` after the merge (the intermittent null texture above). If it fires, the log line `strip <path> loaded empty` names the sheet. To fall that sheet back to 110 px: drop its `fig_h` from `tools/art/rivet_frames.json`, re-cut it (`py -3 -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json --only=<name>`, which reproduced the committed 110 cuts byte-exactly) and remove it from `RivetRes.X15`, in one commit.
- `ASSETS-REPLIES.md` in the lane root is the assets lane's reply file, not part of the merge.
- GATES (final): see the last GATES line in JOURNAL.
