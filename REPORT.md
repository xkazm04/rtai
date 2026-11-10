# REPORT: n11 lane hero (Rivet and the ghosts)

Written it11 23:25, refreshed it13 01:16, it17 (06:05), it18 (07:05) and final at it49 (07:40, 2026-11-10, REPORT phase, nothing built). Branch `n11-hero`, cut from main `812a0b06`. Evidence is under `C:\Users\kazda\kiro\gtai-masters\n11\hero\` (`frames.json`, 15 entries, best first); the working log is `JOURNAL.md`; per-character levels with evidence paths are in `LEVEL.md`. All file names below are in that masters folder unless they carry a path. The final gate logs and a copy of `frames.json` are in the lane cwd under `evidence/n11-hero/` (`unit_it18.txt`, `scen_it18.log`, `reel_it18.txt`).

## What works, with evidence

| Owner's note | What changed | Evidence |
|---|---|---|
| "Direction of player should follow cursor" | `rivet.facing` is the aim wherever a device aims, a sprint included; drawn octant from the aim with a 4 deg hold; aim taken from gun height through the combo projection (18a4b74f). The ghost forms follow the same look (57bf1dd3). Controller aim unchanged. | `aim_sweep_before_after_sprint_64ppm.png`, `ghost_aim_sweep_walk_64ppm.png`; drawn-octant error, mean/worst deg: Rivet walk 11.6/26.7, every ghost about 11.4/25 (11.25 is the floor of any 8-cell card) |
| "Melee attack follows always only one direction" | The sim direction and hit area were already right; the art was stuck on one cell. Rivet's bare claw plays a drawn 8-direction strike (6f591976); blades use the baked cell only where it points the cursor's way and a game arc along the aim elsewhere (c8d71e34). Each ghost has drawn act cells by facing (6d2e643e, 5af9ba1d). | `melee_8dir_drawn_strike_64ppm.png`, `melee_8dir_before_after_claw_blade_64ppm.png`, `ghost_melee_8dir_64ppm.png` |
| "Rivet jumps too much" | The drawn helmet travel in the walk/run grids comes back as a height stretch from the feet, so the feet stay planted; only the run's flight frames lift (6e10aa7a, 4b80f997). Sprint head line range 10 -> 2 px. | `bob_film_right_before_after_64ppm.png`, `bob_before_sprint.gif` / `bob_after_sprint.gif` |
| "Increase size ... to 150%" | One data value, `data/tables/player_scale.json` `k` 1.5, render only (61d5d9eb). Rivet's walk and run grids repacked at x1.5 resolution (568d26f9); since it14 his p70 pistol (facing, fire, left), plasma rifle, katana and chainsaw strips are cut at x1.5 too (`RivetRes.X15`: 8ae5cc25, 0af2d9af, 8a279b28, e59094f8), so standing and shooting he is no longer a 110 px upscale. | `size_150_before_after_walk_64ppm.png`, `size_150_ghost_forms_64ppm.png`, `rivet_x15_grids_before_after_64ppm.png`, `rivet_x15_pistol_strip_before_after_64ppm.png` (zoom `rivet_x15_pistol_strip_zoom_x2_64ppm.png`), `rivet_x15_plasma_strip_before_after_64ppm.png`, `rivet_x15_katana_strip_before_after_64ppm.png`, `rivet_x15_chainsaw_strip_before_after_64ppm.png` |
| "Ghosts ... need animations and polish Rivet received" | `GhostDrawn`: each form is one drawn figure on Rivet's strip format, with a drawn walk, run grids where the form is fast, act cells (wind-up/strike/follow/hit), feet stepped by the ground walked on a stride measured off the drawn stance foot (`GhostStride`). All four at p70 **and** the 55 boss pitch (Tonnage's 55 since it14, 450acaa3). Tonnage walks on **16 drawn frames on all five facings** (it14-16: 14db3b0a, 1fd66481, 3091a7be), more than Rivet's 8. Dent runs at 7 m/s on all five facings, arms alternating with the legs and no wave on the 3/4-away slot 7 (43f0ea59, 78268732, 9f11a80b, ccfd86db; `dent_run8_r4_s7_before_after_64ppm.png`). Tonnage's hit is a drawn recoil (23004b45). | `tonnage_walk16_all_rows_before_after_64ppm.png` (clip `tonnage_walk16_toward_before_after_clip_64ppm.gif`), `dent_run8_r4_arms_before_after_64ppm.png`, `tonnage_p55_v3_before_after_64ppm.png`, `dent_drawn_p55_before_after_64ppm.png`, `kerf_drawn_run8_64ppm.png`, `ghost_acts_seen_64ppm.png`; levels in `LEVEL.md` |

Owner's correction (track the level, keep raising): `LEVEL.md` holds one row per measure, one column per character, each cell with level and evidence. Every ghost reached Rivet's level 3 on facing cards, cursor facing and attack directions (dates in the table); Tonnage's 16-frame walk is the first level-4 candidate (past Rivet). The bar was raised on two rows (it10): no visible snap between octants, and anticipation on every attack.

## What does not work yet (as of it18)

- **Hit cells** were filmed in game at it17 and every ghost now leans back 12 deg off its feet on a hit (`GhostRecoil`, 37c22b27: `ghost_hit_recoil_before_after_64ppm.png`, clip `ghost_hit_recoil_clip_64ppm.gif`). Since it18 Tonnage's HIT column is a drawn recoil on all five facings (23004b45, assets lane v3 A: tipped back, roller lifted, piston up, cables flung, impact star; `tonnage_hit_v3_before_after_64ppm.png`, clip `tonnage_hit_v3_toward_after_clip_64ppm.gif`), so his toward hit no longer reads as his wind-up; on the profile the drawn tip plus the 12 deg lean stack to about 30 deg. Still weak: Ohm's diagonal HIT cell differs little from his walk, and the lean ignores where the blow came from. Combat feel for the ghosts is level 2 (Tonnage's wind-up reads through the floor ring more than his body; Ohm's bolt carries the direction, his body barely).
- **Planted feet on the ghosts** are level 2: measured on the sheets (Tonnage's stance pad slide per stance 32 -> 21 and 58 -> 40 cell px), not yet in world space on the dark arena floor. Tonnage's m34 timing gain (3091a7be) is measured on the sheet, not seen in a film (the every-4th-tick film never lands on that frame).
- Rivet's strips other than p70 pistol, plasma rifle, katana and chainsaw (other weapons, every p55 strip, reload, knock, strike) are still 110 px upscaled; switching weapon or a boss fight softens him.
- Ohm's walk is B art (stubby). (Dent's 3/4-away run slot 7 hand wave is fixed since ccfd86db; at run speed that slot shows for about 2 ticks.)
- Tonnage's drawn figure carries a white-blue spark outline where his old card glowed teal: the soul colour reads less on the drawn ghosts (all four).
- Doors, alleys, vehicles and quest scenes at x1.5 not checked; 32 px/m not looked at.
- **Intermittent `scenario_rig_stress` error**: `Parameter "t" is null` under `RivetFrames._set_strip` on its COMBO pass, 2 of about 8 full scenario runs since the x1.5 sheets (it11, it16), never alone. A diagnostic (c6d07c8a) now logs the sheet path when a strip loads empty; it has not fired since. Not called a flake, not fixed: see Merge notes.
- Bench: one run, CONTENDED (01:33, other lanes running): p99 3.68 ms, 1 % low 224 fps. No quiet-machine number.

## What blocked me, and for how long

Nothing hard-blocked the lane; the losses were friction (each logged as `FRICTION` in JOURNAL, the `tools` lane's work list):
- Machine contention (three lanes on one box): a single `run_unit --select` once took 5 min (timed out at 300 s), a full scenario run about 2-4 min, bench numbers are CONTENDED only. In total roughly an hour of the night went to waiting on gates (an estimate from the JOURNAL GATES timestamps, not measured).
- Before/after films that silently showed the wrong sheet: a `.import` left behind (it13), and `git show <rev>:<png> >` writing an LFS pointer that Godot imports as corrupt with exit 0 (it15, it18). About 30 min re-filming (estimate); the recovery recipe is in JOURNAL it18 FOUND.
- A dev-scene parse error hangs a film to its 150 s timeout (about 8 min, it7); file-size caps at exactly 200 lines on `stage_pilot.gd` / `rivet_frames.gd` forced moves before small additions (several rounds early in the night).
- `tools/evidence/run.mjs` refuses on the assets lane's untracked `ASSETS-REPLIES.md`; ran with `--allow-dirty` (REQUEST tools logged).
- Waiting on art: requested cells arrived through the night (Tonnage walk16, Dent run8, Tonnage hit v3); Ohm's diagonal HIT cells were requested at 07:04 and are not in yet.

## Next steps (next night, in order)

1. `GhostRecoil.LEAN_DEG` per form (Tonnage lower: his drawn cell already tips about 20 deg), and a blow-source field on `Fighter` so the recoil goes away from the attacker.
2. Ohm's diagonal HIT cells on arrival (REQUEST assets in JOURNAL it18): reproduce `ohm_act.png` pixel-exactly with `ghost_pack.py` first, swap column 4, film `--film-form=ohm --film-hurt --film-diag --fixed-fps 60`.
3. The rest of Rivet's strips at x1.5 (p55, other weapons, left rows, reload, knock, strike), one per commit (it14 recipe), so a weapon switch or a boss fight no longer softens him.
4. Planted feet on the ghosts measured in world space on the arena floor (level 2 today, sheet-measured only); the soul teal back on the drawn ghosts' outline (colour law).
5. Doors, alleys, vehicles and quest scenes at x1.5, and a look at 32 px/m; one bench under `bench.lock` on a quiet machine.
6. Watch `scenario_rig_stress` for the intermittent null texture (Merge notes).

## Calls for the owner

1. **x1.5 is visual only.** Rivet and the ghosts draw at x1.5; hitboxes, collision and reach stay as before, so doorways and replays hold. The alternative (sim size x1.5) is one data value plus a replay re-bless. Still: `size_150_before_after_walk_64ppm.png`.
2. **Tonnage's size.** The forms table makes him 3x base Rivet, then x1.5: about 4.95 m drawn, filling a 300 px crop at 64 px/m and hiding cops near him. Keep, or take him back to x1.0 (one value). Still: `size_150_ghost_forms_64ppm.png`, `ghost_melee_8dir_64ppm.png`.
3. **The ghosts' left facings are mirrored** right facings (five drawn facings, three mirrored), as Rivet's grids were before n9. Drawn left rows are a request to the assets lane. Still: `ghost_melee_8dir_64ppm.png` (the left octants).
4. **Dent's melee press with no seized car does nothing visible** (melee is his overload command; the seize is on fire). A player mashing melee as Dent sees no reaction. A design call, not this lane's sim. Still: `ghost_acts_seen_64ppm.png`.
5. **How hard a ghost recoils.** Every drawn ghost leans back 12 deg off its feet on a hit (`GhostRecoil.LEAN_DEG`, one value, 0 = off); on Tonnage's profile it stacks with his drawn tip-back to about 30 deg for 10 ticks, the strongest jolt of the four. Keep, or lower the lean (per form would be a small change). Still: `tonnage_hit_v3_before_after_64ppm.png` (top-left pair), `ghost_hit_recoil_before_after_64ppm.png`.

## Merge notes

- Render-only changes throughout; no replay or parity golden moved or re-blessed on this lane (see JOURNAL GATES lines).
- New data table `player_scale.json` (+ schema); new art under `features/souls/art/view/p70|p55/` and x1.5 Rivet strips under the Rivet art folder (`RivetRes.X15` lists them); tools `tools/art/ghost_pack.py`, `rivet_frames.py` (`fig_h` per manifest row).
- Debt baseline raised once with `--accept-regression` (`ghost_form_view.gd` 206 -> 208 lines, `dev_loc` +6); see JOURNAL it9.
- Watch `scenario_rig_stress` after the merge (the intermittent null texture above). If it fires, the log line `strip <path> loaded empty` names the sheet. To fall that sheet back to 110 px: drop its `fig_h` from `tools/art/rivet_frames.json`, re-cut it (`py -3 -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json --only=<name>`, which reproduced the committed 110 cuts byte-exactly) and remove it from `RivetRes.X15`, in one commit.
- `ASSETS-REPLIES.md` in the lane root is the assets lane's reply file, not part of the merge.
- GATES (it17): evidence `--no-bench` green on bba0ca47 (lint, unit 2252/0, scenarios 55/0, parity bit-exact, selftest, release-compile); full unit 2258/0 and scenarios 55/0 on 37c22b27; reel gate top/tilt70/combo OK on 37c22b27; full unit 2259/0 and scenarios 55/0 on e59094f8 (06:44). GATES (it18): full unit 2259/0 and scenarios 55/0 (0 SCRIPT ERROR, no `loaded empty`) on ccfd86db (the last code-or-art commit); exe produced at 07:06 on 898ab184 (bake 256 chunks, `export_checked.mjs` exit 0, `build/export/windows/RTAI.exe`). Reel gate on 00f2415f (art = ccfd86db): top OK, tilt70 OK, combo OK, exit 0 (07:21).
- Final state (it49, 07:40): no code, art or golden change since ccfd86db; every gate above was taken on that art. HEAD after this commit is docs/evidence only.
