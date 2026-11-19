# REPORT lane anim, n19 (2026-11-18 21:53 to 2026-11-19 08:00)

- Branch `n19-anim`, cut from `int-n19` at `28302bd3c`. Director: Claude (Opus); builder: Astra (all product edits).
- Gate (b63c755fa, 05:55-06:04): `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n19-anim\build\gate\b63c755fa635\gate.json` (lint 19/19 over 1618 files; unit 3005/0/2 skipped; scenarios 55; parity 1200 steps bit for bit, planted mutation caught; look goldens 11/11 + block 5/5; export-audit 740/0). Earlier PASS: c07ebf33e (`build/gate/c07ebf33e50b/gate.json`), f63f8f094 (`build/gate/f63f8f094768/gate.json`). Final `--reels` gate on b63c755fa started 07:31 after the freeze (detached; log `build/gate-logs/gate-b63c755fa-reels.out.txt`, result `build/gate/b63c755fa635/gate.json`); At 07:39 its evidence step had passed (selftest, look goldens 11/11, export-audit 740/0; `build/gate/b63c755fa635/evidence.log`) and the reels step was still running (node PID 14589); its final verdict lands in that gate.json.
- Frames: `C:/Users/kazda/kiro/gtai-masters/n19/anim/frames.json` (best first).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Far cops draw as cops (GDScript LOD path): `RigVariant.look_for` shared by `CharacterRigs.baked_cell` and `_acquire` (87f5a019e), test red on old code (a6ad0e96e) | `evidence/farcop/probe_before.json`, `gtai-masters/n19/anim/farcop/character_pair_t360_32ppm.png` | heat 3 seed 18, 16 px/m: 58 far-cop draws, 58 drawn as ped row 7 before, 0 after (25 patrol + 33 riot). Mutate character_rigs 1/1, rig_variant 2/2 |
| 1b. Native city writer half | handed to gfx (`evidence/farcop/NEED-gfx.md`); gfx landed it at n19-gfx b9cddfe91 | re-run `dev/sim/far_cop_rows.gd` after the merge |
| 2. Tonnage's redrawn req221 profile cells landed (18c38e915, 78/78 byte-identical elsewhere), steps timed from pad contacts (27d2338bd), step caps p70 2.0 / p55 off (e0a504451) | `evidence/tonnage-hold/cap_sweep_32ppm.md`, `gtai-masters/n19/anim/tonnage-hold/profile_before_after_64ppm.png` | worst hold 16.1 -> 15.5 px (48 t); p70 110 t film worst 25.4 -> 18.4, mean 9.47, stance drift 2.99 px (< 3). Bar (< 9 worst) not met by retiming alone; met with derived midpoints, rows 2c-2f. Mutate ghost_stride 23/24 |
| 3. Rivet native x1.5 knock (e4d879d28), strike (1cca98628), base frames (ed4f9c495), four-frame walk (4b31b3b3c), verify (ae74bd261) | `gtai-masters/n19/anim/rivet-x15/{strike_t1527,knock_t240,walk_t184}_64ppm_x2.png`, `evidence/rivet-x15/README.md` | 8 originals + 8 x1.5 cuts rebuilt byte-exact; bbox/feet within 1 px at 64 px/m; collar within 1.7 px; unit --all 2975/0; mutate knock 1/1, strike 5/5, res 1/1. Reload was already x1.5 |
| 4a. Ohm cast wind-up, ticks 0-2 electrodes up, bolt tick unchanged (75143d50e) | `gtai-masters/n19/anim/ghost-cells/ohm_cast_8dir_64ppm.png`, `ohm_cast_ticks_32ppm.png` + `.mp4` | mutate ghost_drawn 4/4; goldens 16/16 |
| 4b. Dent and Ohm hit from behind (19135b1b0), blow within 60 deg of facing | `gtai-masters/n19/anim/ghost-cells/dent_ohm_hitback_64ppm.png`, `p55_dent_ohm_hitback_64ppm.png` | flag off = 576 crops identical; mutate 12/12 |
| 4c. Kerf run16 planted feet measured in all 8 octants (7ecf4047f) | `evidence/ghost-cells/kerf_run_hold_ride_32ppm.txt` | worst hold px@32: right 9.0, toward-right 8.9, toward 16.7, toward-left 8.9, left 10.0, away-left 9.4, away 25.3, away-right 9.4 |
| 4d. Kerf run16 rows 1 (toward) and 5 (away): 8 duplicate pairs each filled with in-betweens derived by script from his own keys (3eb1b98da) | `gtai-masters/n19/anim/ghost-cells/kerf_run16_axial_64ppm.png`, `kerf_run16_axial_ticks_32ppm.png`, `evidence/ghost-cells/kerf_run_hold_ride_32ppm.txt` | worst ride px@32: toward 16.71 -> 8.37, away 25.31 -> 8.97 (bar < 9); 64 other cells byte-identical; worst octant now left profile 10.01 |
| 2b. Tonnage step-5 mid cell (a2e7b603b) | `gtai-masters/n19/anim/tonnage-hold/tonnage_step5_32ppm.png`, `evidence/tonnage-hold/step5_32ppm.md` | that transition 16.19 -> 11.26 px; 110 t mean 9.47 -> 8.91, drift 2.99 -> 2.38; overall worst still 18.39 (C3) |
| 4e. LEVEL raised with evidence (453d55fce, b63c755fa) | `LEVEL.md` | Ohm combat feel 2 -> 3; Dent and Ohm hit cells 3 -> 4 (directional hit read, past Rivet); Tonnage planted feet 2 -> 3 (all 16 walk rows worst hold <= 7.131 px@32, `evidence/tonnage-hold/holds_it4.md`) |
| 5a. Claw throw p55 cells for patrol / riot / SWAT wired (98e30b34a) | `gtai-masters/n19/anim/death-cells/A/after-64.jpg` vs `before-64.jpg` | 446 pre-existing grids byte-identical; unit --changed 1721/0 |
| 5b. Claw throw p70 cells for the eight human peds (cap, elder, hat, hood, jogger, punk, shopper, worker) wired (1f57e2d10); proven on a real card-drawn hood | `gtai-masters/n19/anim/death-cells/B/real-after-64.jpg` vs `real-before-64.jpg`, clip `gtai-masters/n19/anim/death-cells/B/hood-and-thug-32.mp4` | `test_claw_card_victims` red 1/2 on HEAD -> 3/0; 449 pre-existing PNGs byte-identical; unit --changed 1725/0 |
| 5c. Molotov torch p55 cells for patrol / riot / SWAT wired (d136db41a) | `gtai-masters/n19/anim/death-cells/C/final-64.jpg` vs `before-64.jpg` | torch test red 3/1 -> 4/0; 60 alpha masks keep every source pixel; red edge pixels shifted to orange |
| 2c. Tonnage p70 right profile: nine more midpoints derived from his own keys (4535fb7ef). **Bar met** for this sheet | `gtai-masters/n19/anim/tonnage-hold/it4-midpoints-64ppm.png`, `evidence/tonnage-hold/holds_it4.md` | 110 t leg-2 film at 32 px/m: worst hold 18.395 -> 7.121 px (bar < 9), mean 8.911 -> 5.005, stance drift 2.381 -> 2.082; 192 base cells byte-identical; mutate ghost_stride 8/8, ghost_sheet 21/21; unit --changed 2982/0 |
| 2d. Tonnage p70 LEFT profile: ten midpoints from his own left keys (f63f8f094). **Bar met** | `gtai-masters/n19/anim/tonnage-hold/it4-left-midpoints-64ppm.png`, `evidence/tonnage-hold/holds_it4.md` | worst hold 18.401 -> 7.018 px@32, mean 9.504 -> 5.008, drift 3.342 -> 2.440; 192 cells byte-identical; mutate stride 13/13, sheet 12/13 (equivalent survivor) |
| 2e. Tonnage p70 3/4 rows (all four): 160 cells derived from his own keys (d698f9f09). **Bar met** | `gtai-masters/n19/anim/tonnage-hold/it4-diag-{right,left}-{toward,away}-midpoints-64ppm.png`, `evidence/tonnage-hold/holds_it4.md` | worst hold px@32 (logged-key measure, 110 t): right toward 16.39 -> 3.90, right away 21.89 -> 5.08, left toward 17.53 -> 2.90, left away 21.04 -> 5.50; mean stance drift max 2.80 (< 3); mutate stride 21/21, sheet 42/44 |
| 2f. Tonnage p55 profiles: 20 derived cells per side between his 8 keys, timing uncapped (c07ebf33e). **Bar met** | `gtai-masters/n19/anim/tonnage-hold/it4-p55-{right,left}-midpoints-64ppm.png`, `evidence/tonnage-hold/holds_it4.md` | worst hold 31.71 -> 7.13 (right), 31.59 -> 7.11 (left); drift 2.76 / 2.66; 170/170 original-key crops byte-identical; unit --changed 2986/0; mutate stride 2/2, sheet 27/30 incl. the phase-zero line |
| 2g. Tonnage's last eight walk rows measured and derived (dcd270e82 p55 four 3/4 + toward/away, a49d8867a p70 toward/away), p55 profile pads rolled about the ankle (ed9a67db8), loader survivors killed (84aaf1131). **Item 2 closed: all 16 walk rows (8 facings x 2 pitches) under the bar** | `gtai-masters/n19/anim/tonnage-hold/it5-{p55-right-toward,p55-right-away,p55-left-toward,p55-left-away,p55-toward,p55-away,p70-toward,p70-away}-midpoints-64ppm.png`, `it5-p55-{right,left}-profile-tilt-64ppm.png`, `evidence/tonnage-hold/holds_it4.md`, `evidence/tonnage-hold/p55_pad_tilt.md` | worst hold px@32 before -> after: p55 3/4 26.1/34.1/25.9/33.9 -> 3.0/3.7/3.8/3.9, p55 toward/away 17.1/22.2 -> 2.4/3.4, p70 toward/away 12.0/19.8 -> 2.9/3.4; worst of all 16 rows 7.131, mean stance drift <= 2.799; 344 derived cells, 170 original-key crops byte-identical; p55 pad rim angle error 31 -> 2.5 deg; mutate ghost_sheet 25/25 (both survivors killed); unit --changed 2989/0 |
| 7. Contact and cast shadows triangulate at any city coordinate: polygons built about local zero (c07cab306), gfx's report | `evidence/shadow-tri/README.md`, `gtai-masters/n19/anim/shadow-tri/{before,after}-t1-64ppm.png` | seed-5 arena repro 2 -> 0 triangulation errors; observer 312 of 16,282 figure outlines failed before, 0 after; 0 px frame diff at 64 px/m; placement test (fb63aecfa) mutate 7/7 |
| 6. Crowd atlas pop at the 16-rig switch (gfx's report): 160 px cells with headroom, capture origin restored on the quad, live bullet fall baked at p70 (b472095b6, tests 595b5a652) | `gtai-masters/n19/anim/crowd-pop/{coat-hat,riot,overalls-bald}-switch.png`, clip `crowd-ring-32ppm.mp4`, `evidence/crowd-pop/REPORT.md`, `audit_before.json` / `audit_after.json` | clipped cells 176 -> 0 of 400; baked/live height 0.37-1.04 -> 0.99-1.01; feet error 8 -> 1 px at 64 px/m; atlas 12.5 -> 19.5 MiB; 13 look goldens re-blessed (named); headroom test red on old layout (46.9 < 64.7 px). Mutate ghost_sheet 60/84 |

## What does not
- Item 1 film: the 16 px/m heat-3 clip exists only BEFORE (`gtai-masters/n19/anim/farcop/before/heat3_city_16ppm.mp4`); AFTER is a 32 px/m clip (`after/heat3_city_32ppm.mp4`) plus 16 and 32 px/m stills. The clip records the native city writer, which still draws far cops on ped row 7 on n19-anim alone (gfx's half, b9cddfe91), so an after film of the city view only shows the fix once gfx merges: film it on the merged revision (`FAR_COP_CLIP=1 FAR_COP_PPM=16`, `dev/sim/far_cop_rows.tscn`).
- Kerf's run16: four octants ride 9.0 to 10.0 px (bar 9). These are two-tick holds riding one tick of ground (8.8 px/tick at run speed), the floor for 16 drawings at this cadence, not held duplicates (`gtai-masters/n19/anim/ghost-cells/raw/c/kerf_baseline_hold_trace.txt`). Going under needs a new drawing every tick. Planted feet stays level 2.
- Held, not shipped (`evidence/death-cells/NEED-ai.md`): the robot thug's p70 claw throw grid (robots die on the power-down route, never reach `KillFallCells`) and the worker burn pair (combat requires a standing char set, none delivered). Both wait in `gtai-masters/n19/anim/death-cells/held/`. Patrol lying char, directional collapses and Torque gang burn need combat-side selectors.
- The dropped rifle after the claw kill lies ~0.86 m from the patrol boots (owner verdict 0.5 m): pre-existing, combat-owned (NEED ai).

## What blocked or slowed you
- Quick gate's Godot step fails on untouched characters/ and souls/ files (standalone `--check-only` cannot see autoloads): 20 min; worked round with `--no-godot` + `run_unit.mjs --changed`.
- Set B (p70 claw grids) stopped at `KillFallCells.attach:19` (combat): the film victim was a lab-guard parts rig; re-briefed onto a real card ped (05b).

## Calls for the owner
- Ohm's bolt still leaves on the decision tick, so during the 3 wind-up ticks it is drawn from the raised electrode (`ghost-cells/ohm_cast_8dir_64ppm.png`, away-left cell). Recommended: keep render-only. Alternative: delay the bolt 3 ticks (gameplay change, would ship behind an OFF flag).

## Merge notes
- `tools/art/rivet_frames.py` conflicts with n19-guns on one adjacent line in `_manifest` (guns: `str(Path(lib)/row['sheet'])`; anim: appends `--layout_h`): keep both.
- `tools/debt/baseline.json`: run `node tools/debt/merge_baseline.mjs` after the conflict, then `--update`.
- `evidence/crowd-pop/NEED-gfx.md`: gfx passes slot+1 in the people body custom.y (`render.cpp:95`, `sim_render.gd:64`); part 1 LANDED on n19-gfx at 0dc71557a (gfx JOURNAL 04:25; slots 0/15/511 tested); on n19-anim alone a baked far ped is ~12% shorter than its rig (crown intact, feet aligned). Part 2 (noir crowd shader include) is merge-time (gfx brief 13 rehearsal patch under gtai-masters/n19/gfx/merge/). Five look goldens changed on both lanes (auto-48/56/64ppm-ov, d4-48ppm, d5-48ppm-ov): re-render them on the merged revision after the DLL rebuild.
- move's NEED anim (`n19-move/JOURNAL.md` line 50): `StrideMatch.profile_cycle` exists only on n19-move, so the call cannot land here. `rivet_walk.gd:167` (the cadence cap) is unchanged on n19-anim; after both merge, insert `if not running: cycle = StrideMatch.profile_cycle(card, scale / RES, cycle)` just before the cap. anim agrees with move's measurement (slide 14.2 -> 0.7 cm at 2.4 m/s).
- After gfx's b9cddfe91 merges, re-run `dev/sim/far_cop_rows.gd` (expect 0 cop instances on ped rows in the native writer).

## Next steps
1. On the merged revision (after gfx b9cddfe91 + 0dc71557a): re-run `dev/sim/far_cop_rows.tscn` at 16 px/m with `FAR_COP_CLIP=1`; expect 0 far cops on ped rows in both paths and a 16 px/m after clip; re-render the five shared look goldens.
2. Kerf run16: four octants sit at the two-tick floor (9.0-10.0 px@32). Going under needs run32-class art (a drawing per tick); request it only if the owner judges the run at 32 px/m as skating.
3. Tonnage's 344 derived walk cells are script in-betweens of his own keys: if the owner wants hand-drawn quality, a drawn pass over the busiest midpoints (p55 3/4 rows) is the upgrade; the measure is already met.
4. Combat-side selectors (lane ai) for the held art: robot claw throw (power-down route), worker burn (standing char set), patrol lying char, directional collapses, Torque gang burn (`evidence/death-cells/NEED-ai.md`).
5. Claw-kill rifle drop 0.86 m vs the 0.5 m verdict (lane ai/guns).

## Astra ledger
| tag | min | verdict |
|---|---|---|
| farcop | 18 | accepted |
| tonnage-hold | 18 | bounced (partly kept) |
| tonnage-cap | 17 | bounced (code kept, values overridden) |
| rivet-x15 | 34 | accepted |
| ghost-cells | 49 | accepted |
| death-cells | 22 | partly accepted (A) |
| death-cells-b | 27 | partly accepted (C; B re-scoped) |
| death-cells-close | 4 | accepted (B x8 peds, clean tree) |
| kerf-away | 18 | accepted |
| crowd-pop | 37 | accepted (cut off by the session end after its commits) |
| shadow-tonnage | 33 | accepted (its shadow test killed 0/7: fixed next call) |
| tonnage-left | 25 | accepted (shadow placement test 7/7) |
| tonnage-diag | 65 | accepted (p70 3/4 rows + p55 profiles, bar met) |
| tonnage-close | 63 | accepted (last 8 rows, pad roll, loader survivors: item 2 closed) |
| level-honest | 3 | accepted (Tonnage Planted feet 2 -> 3, no unevidenced level-4 claims) |

Totals: 15 calls, 433 min. 11 accepted, 2 partly accepted (death-cells, death-cells-b), 2 bounced (tonnage-hold, tonnage-cap; their code kept, values set by the next brief).

What I would brief differently:
- State the measurable bar and the exact measuring command in the first brief (Tonnage took four calls because the first two briefs said "fix the held frames" before the < 9 px@32 table per row was the acceptance check).
- Name the real victim/actor the film must use (set B ran on a lab-guard parts rig and hit a combat-owned path; a card ped from the start would have saved a call).
- Start long calls only with > 75 min of director session left (crowd-pop died with session 3), and put a TIME BOX line in every brief.
- Ask for the mutation-killing test in the same brief as the change (shadow-tonnage's test killed 0/7 and needed a follow-up).
