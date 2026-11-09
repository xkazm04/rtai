# REPORT: n11 lane hero (Rivet and the ghosts), DRAFT written it11 23:25

DRAFT: a later session refreshes this at 07:40. Evidence is under `C:\Users\kazda\kiro\gtai-masters\n11\hero\` (`frames.json`, best first); the working log is `JOURNAL.md`, and the per-character levels are in `LEVEL.md`.

## What works, with evidence

| Owner's note | What changed | Evidence |
|---|---|---|
| "Direction of player should follow cursor" | `rivet.facing` is the aim wherever a device aims, a sprint included; drawn octant from the aim with a 4 deg hold; aim taken from gun height through the combo projection (18a4b74f). The ghost forms follow the same look (57bf1dd3). Controller aim unchanged. | `aim_sweep_before_after_sprint_64ppm.png`, `ghost_aim_sweep_walk_64ppm.png`; measured drawn-octant error, mean/worst deg: Rivet walk 11.6/26.7, every ghost about 11.4/25 (11.25 is the floor of any 8-cell card) |
| "Melee attack follows always only one direction" | The sim direction and hit area were already right; the art was stuck on one cell. Rivet's bare claw plays a drawn 8-direction strike (6f591976); blades use the baked cell only where it points the cursor's way and a game arc along the aim elsewhere (c8d71e34). Each ghost has drawn act cells by facing (6d2e643e, 5af9ba1d). | `melee_8dir_drawn_strike_64ppm.png`, `melee_8dir_before_after_claw_blade_64ppm.png`, `ghost_melee_8dir_64ppm.png` |
| "Rivet jumps too much" | The drawn helmet travel in the walk/run grids now comes back as a height stretch from the feet, so the feet stay planted; only the run's flight frames lift (6e10aa7a, 4b80f997). Sprint head line range 10 -> 2 px. | `bob_film_right_before_after_64ppm.png`, `bob_before_sprint.gif` / `bob_after_sprint.gif` |
| "Increase size ... to 150%" | One data value, `data/tables/player_scale.json` `k` 1.5, render only (61d5d9eb). Walk and run grids repacked at x1.5 resolution so moving Rivet is not an upscale (568d26f9). | `size_150_before_after_walk_64ppm.png`, `size_150_ghost_forms_64ppm.png`, `rivet_x15_grids_before_after_64ppm.png` |
| "Ghosts ... need animations and polish Rivet received" | `GhostDrawn`: each form is one drawn figure on Rivet's strip format, with an 8-frame walk, a run grid (Kerf), act cells (wind-up/strike/follow/hit), feet stepped by the ground walked on a stride measured off the drawn stance foot. Kerf and Ohm also at the 55 boss pitch (it11). | `kerf_drawn_run8_64ppm.png`, `ghost_acts_seen_64ppm.png`, `ohm_drawn_p55_before_after_64ppm.png`, `kerf_run8_p55_before_after_64ppm.png`; levels in `LEVEL.md` |

## What does not work yet (as of it11)

- Rivet's walk and run grids are native at x1.5 since it11 (568d26f9); his one-row strips (facing, fire, knock, strike) are still 110 px upscaled, softer when he stops or shoots.
- Tonnage's drawn walk is a rocking shuffle whose feet never travel, so his feet slide at 4.2 m/s; a stamping walk8 is being drawn.
- Dent, Tonnage at the 55 boss pitch keep the old card (no 55 walk grid yet).
- No ghost attack has anticipation except Tonnage's wind-up (the sim counts a strike only when it lands).
- Doors, alleys, vehicles and quest scenes at x1.5 not checked; 32 px/m not looked at.
- Gates: see the latest GATES line in JOURNAL. The reel gate, bench and an export were not run as of it11.

## Calls for the owner

1. **x1.5 is visual only.** Rivet and the ghosts draw at x1.5; hitboxes, collision and reach stay as before, so doorways and replays hold. The alternative (sim size x1.5) is one data value plus a replay re-bless. Still: `size_150_before_after_walk_64ppm.png`.
2. **Tonnage's size.** The forms table makes him 3x base Rivet, then x1.5: about 4.95 m drawn, filling a 300 px crop at 64 px/m and hiding cops near him. Keep, or take him back to x1.0 (one value). Still: `size_150_ghost_forms_64ppm.png`, `ghost_melee_8dir_64ppm.png`.
3. **Dent's melee press with no seized car does nothing visible** (melee is his overload command; the seize is on fire). A player mashing melee as Dent sees no reaction. A design call, not this lane's sim. Still: `ghost_acts_seen_64ppm.png`.

## Merge notes

- Render-only changes throughout; no replay or parity golden moved or re-blessed (see JOURNAL GATES).
- New data table `player_scale.json` (+ schema); new art under `features/souls/art/view/p70|p55/`.
- Debt baseline raised once with `--accept-regression` (`ghost_form_view.gd` 206 -> 208 lines, `dev_loc` +6); see JOURNAL it9.
