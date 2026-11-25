# REPORT lane keys, run n30 (2026-11-25 day), branch `n30-keys` from `5114a4441`

DRAFT (session 6, 15:50): sections are filled as items land; the final version is written at 18:55.

## What works

- **p55 sprint collar rows 3, 6, 7 rigid, 8/8 cells each, by per-cell 2x image edits** (row 4's cell of the same column, or a
  mirrored row 2 cell / an accepted neighbour, as the reference; neck-only composite): row 3 (`bf7b78fd6`, `0b1a1cd27`), row 7
  (`47aed0529`), row 6 (`6ba1b9d68`), the four front-end leftovers r7c3 r7c4 r6c2 r6c6 (`2641a10fe`) and row 6's orange visor kept
  pixel-exact inside protect boxes (`68d873f9e`: 40/6/55/39 visor px -> 0). Every accepted cell: 0 px changed outside its mask,
  alpha identical, the other cells bit-identical, registration IoU 0.976-0.991. In game at 64 px/m only the changed rows' ticks
  differ, in the neck window. Sprint drift at 64 px/m 3.83 cm (bar 3.83 +- 0.1), identical to n27. Evidence
  `evidence/n30-keys/collar_cells.md`; stills in `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/` (`row67_64_ingame_final.png`
  before | after at 4 ticks, `row3_64_ingame.png`, `r3c1_4x.png`, `row3_4x.png`, `row6_4x.png`, `row7_4x.png`). In the real
  game (arena, bot Rivet, view tilt = p55 art, `tools/film/compare.mjs` 5114a4441 | HEAD): `collar/collar_p55_64_compare.png`
  (tick 300, row 7 sprint: soft rope -> flat striped ring) and `collar/collar_p55_rows367_32.mp4` (1920x1080 60/1, 1200 frames,
  20.0 s; Rivet is small in it, the still is the proof; `b129dbee9`, `evidence/n30-keys/films.md`).
  **Sprint tour** (`22d3c0fb1`, `84fbcc2a2`): the arsenal recorder's `--sprint-tour=on --weapon=hands` sprints Rivet once through
  the 8 octants in the real arena at p55, 5114a4441 (snapshot, re-imported) | HEAD, same ticks: `collar/collar_p55_sprint_tour_32_realtime.mp4`
  (1920x1080 60/1, 1442 frames, 24.0 s, the tour played twice at real speed), `collar_p55_sprint_tour_64.png` (8 octants, before above
  after) and `_64_zoom.png`. Octants E, SW, W are sheet rows 3, 6, 7 (`RivetFrames.BASE_OCT`): rope before, flat striped ring after;
  the other five octants pixel-identical.
- **The molotov runs on its own p70 run sheet** (`4513bda2a`): rows edited from the plasma rifle's run rows one row per job
  (10 images), soles registered to the donor; rows 4 and 8 cols 2, 6 on the donor's legs under a seam. Walk hold 0.43 / 1.56 cm
  (bar 2); run step 5.77 / 6.85 cm (bar 7; donor 6.69 / 8.93) after row 1 cols 5, 6 were registered 1 px to the donor's planted
  sole x (`0e399a732`; it was 7.28 / 9.86; `run_row_k` cannot move it: the cycle floor binds). Evidence `evidence/n30-keys/grid_molotov.md`, grid
  `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_64.png` (rendered before the 1 px fix; the 64 px/m grid at HEAD is
  the tour still `molotov/molotov_p70_sprint_tour_64.png`, 8 octants, stop-gap above HEAD).
- **p70 aim-left collar rigid** (not an owner pick; the rigid-collar law): audit `57c72c41a` (`evidence/n30-keys/eq_collar_audit.md`)
  found the band drawn as a knit rope in the p70 `_left` aim strips of the rocket launcher, mini-nuke and gatling (p70 is the
  in-play default). The lane's last 8 images: 7 cells rigid by per-cell 2x edits with Gloria's `_left` cell as the reference
  (`8776d8711` gatling c1 c2, `f371eddb6` rocket launcher c0 c1 c2, `f3aefd0a2` mini-nuke c1 c2); mini-nuke c0 rejected on sight.
  Per cell alpha identical, 0 px outside a declared band box, 0 px changed in the weapon box. In game (arsenal turn, p70,
  64 px/m) only neck px change: `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/{rocket_launcher,mini_nuke,gatling}_left_64_ingame.png`.
  At 32 px/m (`a09f9be52`): `eq_collar/eq_collar_left_turn32.mp4`, the arsenal turn of the three weapons, 5114a4441 | HEAD at the
  same ticks (1920x1080 60/1, 1920 frames, 32.0 s); 55 / 37 / 36 of 160 frames differ per weapon, at most 283 / 422 / 320 px, all
  in a ~40x20 px neck box; 3x pair `eq_collar_left_32_zoom.png`.
- **The vermilion list** (`fb93bfd25`, `391d529fa`, `evidence/n30-keys/vermilion_list.md`): see Calls 1.
- **Molotov film** (`cb361f4f8`, `evidence/n30-keys/films.md`): `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/molotov_32.mp4`
  (stop-gap | n30 | plasma rifle at 32 px/m over a 64 px/m tile; 1920x1080 60/1, 921 frames, 15.35 s by ffprobe) and
  `molotov_before_after_64.png`.
  **Molotov sprint tour at p70** (`88a0b7ff6`, after the run-step fix): the arsenal recorder's `--sprint-tour=on --weapon=molotov
  --pitch=p70` in the real arena, 5114a4441 (stop-gap, `rivet_run8.png`) | HEAD (`rivet_run8_eq_molotov.png`), same ticks:
  `molotov/molotov_p70_sprint_tour_32.mp4` (1920x1080 60/1, 1440 frames, 24.0 s, real speed, the tour played twice),
  `molotov_p70_sprint_tour_64.png` (8 octants, before above after) and `_64_zoom.png`. All 8 octants change (22.9k-27.8k px):
  before a loose bottle dangles from the spike arm with no flame; after the bottle sits in the claw, lit, in every octant.
- **The arsenal turn recorder fires at HEAD again** (`020878888`, `47fb6df5c`, `evidence/n30-keys/arsenal_turn.md`): the
  recorder presses the weapon's slot key on its first step (the wheel had stowed the gun); pistol and Gloria runs exit 0 with
  8 rest + 8 fire stills each (HEAD before: exit 1); unit test `test_arsenal_turn.gd`, the guard's hand mutation caught.
  Mutate (`--max=6`, changed lines, `test_arsenal_turn`) first scored 16.7 % = 1 / (1 + 5); the equip rule moved into
  `EQUIP_STEPS` + a static `slot_on_step` and two tests pin it and the fire bit (`4ee6f7b27`, `74fc5e382`): targeted lines
  **100 % = 4 / (4 + 0)**; a wide run over the arena-bound code 35 % = 7 / (7 + 13) (survivors `_ready`/`_record`, which only
  the real runs exercise). The sprint tour's `tour_input` (`arsenal_sprint_rec.gd:13`, lines 4-15): **100 % = 4 / (4 + 0)**.

## Gate

- `node tools/gate/run.mjs --rev=HEAD` on `a09f9be52` (15:37, 26 min; the lane's last code commit is `22d3c0fb1`, later commits are
  evidence/journal only): `gate: PASS; build/gate/a09f9be527a0/gate.json` (lint 19/19 over 2292 files, unit 4316 passed / 0 failed /
  2 skipped, scenarios 68, parity bit-exact + planted mutation caught at step 629, selftest, export-audit 1003 / 0 failed).
- Earlier: `node tools/gate/run.mjs --rev=HEAD` on `74fc5e382` (14:16, 21 min): `gate: PASS; build/gate/74fc5e382e63/gate.json` (lint 19/19,
  unit 4314 passed / 0 failed / 2 skipped, scenarios 68, parity bit-exact, selftest, export-audit 1003 / 0 failed). Reels gate: owed after the freeze.

## What does not

- Row 8's touch-ups (cell 4: a notch where the helmet meets the ring's left end; cell 8: a light streak on the helmet right of
  the ring) kept shipped: two image edits each did not touch the defect (both lie just outside the collar hull).
- Rivet's collar still reads as rope in some p70 cells, and the run's 60 images are spent: mini-nuke `_left` c0 (its edit was
  rejected on sight), gatling `_left` c0, `gatling_diag` c0/c2, the two `_left_fire` strips, and the 9 cells listed in Next steps 2.
  The `_left_fire` cells are another drawing, so a shot swaps the new ring for a few torn bits under the visor, not for a clear rope.
- `molotov/molotov_32.mp4` (n30-05) was filmed before the run-step fix `0e399a732`; the p70 sprint tour clip is the current one.

## What blocked or slowed you (minutes each)

- Lane Godot lock, 21 min (11:46-12:07): builder n30-07's mutate held it while n30-06's collar install waited; n30-06 ended
  uncommitted and its waiting script ran on after it (installed at 12:21), picked up by n30-08.

- gtai-masters `n24` and `n26` were deleted at ~12:56 (not by this lane): the dev capture harnesses that n29/n30 films used
  (`run_hands.py`, `capture_film.py`) copied their Godot sources from there. The collar film moved to `tools/film/compare.mjs`.
- 25 min on builder n30-11 (collar film): its before sheet was taken with `git show`, which writes the git-LFS pointer; Godot
  imported it as an empty texture. Stopped; the sheet and its `.import` restored to HEAD and re-imported.

## Calls for the owner

1. **Vermilion per weapon, danger or heat (no recolour made).** Showcase (item art) and in play (`held_55` + Rivet's p70 strip
   cell); stills `C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/<weapon>_4x.png` (showcase) and `<weapon>_held_4x.png`
   (in play), contact sheets `contact_4x.png`, `contact_held_4x.png`. Proposal = what goes amber on your yes; danger stays vermilion.
   **What your yes would look like** (`d8aabf6ae`, preview only, no shipped art changed): `vermilion/preview_contact_4x.png`, current |
   proposed per weapon (showcase, then in play), heat parts only, recoloured to the game's amber `#ffbf56` hue and saturation with each
   pixel's own value kept; danger px changed 0, alpha identical (`evidence/n30-keys/vermilion/preview.py`). The copper parts come out
   as warm brass rather than glowing amber, because the source px are dark; if you want them to glow, the recolour can also lift the
   value (one number in the script): **brass or glow side by side** (`bc87ac787`): `vermilion/preview3_contact_4x.png` and
   `preview3_<weapon>_4x.png`, CURRENT | BRASS (value kept) | GLOW (value lifted 0.55: `v' = 0.55 + 0.45 v`); BRASS identical to the
   first preview in 19/19 panels, danger px changed 0 in both. Glow reads as lit amber on the same parts, flatter shading; on the
   pale bodies (machine pistol, plasma rifle) it sits close to the body tone. Say "brass", "glow", or another lift.

   | weapon | danger (stays vermilion) | heat (to amber on your yes) | design / wear (keep) |
   |---|---|---|---|
   | rocket launcher | warhead nose stripes (in play 4008 px, the whole nose) | showcase fuse cables (130 px; absent in play) | rust patches |
   | mini-nuke | warhead nose stripes (in play 6082 px); showcase muzzle stripes | coolant arc over the body (935 px in play), showcase hoses | plum casing, yellow/black hazard bands |
   | ray gun | showcase warning triangle (117 px; absent in play) | grip coil, feed cables, top pipe, emitter rings (3048 px showcase, 269 in play) | - |
   | electro gun | showcase warning plate (127 px; absent in play) | barrel coil, feed arcs (2114 showcase, 425 in play) | - |
   | homing shard | showcase stripe plates (362 px) | - | red-orange hoses (design colour, keep) |
   | gatling | showcase stripe panel (117 px) | - | - |
   | plasma sword | hilt stripes (52 px) | hilt hoses (128 px) | - |
   | flamethrower | - | showcase feed pipe and nozzle cage (400 px) | tank rust |
   | machine pistol | - | coolant / cable loop (871 showcase, 699 in play) | - |
   | plasma rifle | - | feed cables (351 / 339) | - |
   | electro baton | - | coil winding (295 / 889) | - |
   | chainsaw | - | ignition cable loop (679 in play) | rust wear |
   | katana, hand cannon, pistol, assault rifle, Gloria | - | - | rust flecks only: no change |

   Unsure: the ray gun's two emitter rings are classed heat (a charged coil); if you read them as the live emitter they stay
   vermilion. The rocket launcher's empty tube keeps a 329 px orange sliver at the nose ring's cut edge (counted wear).

2. **p70 aim-left collar (made without your pick).** Seven `_left` aim cells of the rocket launcher, mini-nuke and gatling now
   wear the rigid striped ring like Gloria's, chainsaw's and the assault rifle's: `eq_collar/<weapon>_left_64_ingame.png` (before |
   after, 64 px/m; at 32 px/m `eq_collar/eq_collar_left_turn32.mp4`). Keep, or revert the three art commits. Still rope: mini-nuke `_left` c0, gatling `_left` c0, `gatling_diag`
   c0/c2, the two `_left_fire` strips (no images left this run).

## Merge notes

- Files: `project/features/characters/art/view/p70/rivet_eq_{rocket_launcher,mini_nuke,gatling}_left.png`,
  `project/features/characters/art/view/p55/rivet_run8.png`, `project/features/characters/art/view/p70/rivet_run8_eq_molotov.png`
  (+ `.import`), `project/data/tables/rivet_motion.json` (molotov `run_row_k` rows), `project/tests/unit/test_rivet_grid_stride.gd`,
  `project/tests/unit/test_rivet_walk_sprint_fallback.gd`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (append).
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on the add/add conflict.
- Temp left for the post-merge cleanup (this lane's): `gtai-gate-a09f9be527a0`, `gtai-gate-74fc5e382e63`, `gtai-mutate-dc83624c`, and the
  `build/turn-snapshots` / `gtai-film-*` snapshots of 5114a4441 used for the before films.

## Next steps

1. Rivet's collar still rope in: p70 mini-nuke `_left` c0, gatling `_left` c0, `gatling_diag` c0/c2, `gatling_left_fire`,
   `mini_nuke_left_fire` (`evidence/n30-keys/eq_collar_audit.md`), and the p55 run row 8 cell 4 notch / cell 8 streak. Same per-cell
   2x route; for row 8 the mask must reach past the collar hull (the defects sit on the helmet edge), about 8 images in all.
2. The UNSURE p70 cells are settled (`a744fe9ac`, `evidence/n30-keys/eq_collar_audit.md` "UNSURE settled"): 9 ROPE, 41 RIGID. The
   next-run edit list is 9 images, one per cell (run8 plasma sword r2c4, run8 assault rifle r2c4, gatling eq c3, electro gun diag
   c0/c2, flamethrower left c2, reload gatling c3/c5/c6), each with its rigid reference named; contact sheets
   `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/unsure_<strip>_4x.png`.
3. `tools/film/arsenal_turn.mjs` could pass `--sprint-tour` and re-import its snapshots (a snapshot copies the worktree's import
   cache, so an edited sheet renders as HEAD's until `--import`); today the tour film uses a scratch script under `build/n30-16/`.
4. The vermilion recolour, once you answer Calls 1: masked recolours (like the n29 sword rings) per weapon in the heat column.

## Builder ledger

| call | model | min | verdict | note |
|---|---|---|---|---|
| n30-01 collar-cell-r3c1 | opus | 7 | accepted | proved the per-cell 2x route on one cell |
| n30-02 vermilion-list | sonnet | 3 | accepted | showcase classes; held art left for 02b |
| n30-02b vermilion-held | sonnet | 5 | accepted | in-play classes |
| n30-03 molotov-run-rows | opus | 24 | accepted | 8/8 rows, 10 images |
| n30-04 collar-cells | opus | 24 | accepted | rows 3, 6, 7 (20 cells), 30 images |
| n30-05 molotov-film | sonnet | 8 | accepted | |
| n30-06 collar-leftovers | opus | 30 | bounced | 4 cells accepted in the round, not installed: lock starved by n30-07's mutate |
| n30-07 arsenal-turn-fire | sonnet | 38 | accepted | mutate not scored |
| n30-08 collar-install | opus | 15 | accepted | caught a stale import in n30-06's leftover run |
| n30-09 molotov-step | sonnet | 19 | accepted | 1 px registration, 7.28 -> 5.77 cm |
| n30-10 eq-collar-audit | sonnet | 6 | accepted | |
| n30-11 collar-film | sonnet | 18+ | abandoned | harness source deleted; LFS pointer as before sheet; stopped |
| n30-12 eq-collar-cells | opus | 20 | accepted | 7 of 8 cells, last 8 images |
| n30-13 collar-film-compare | sonnet | 19 | accepted | row 7 only in frame |
| n30-14 decision-lines | sonnet | 2 | accepted | |
| n30-15 arsenal-turn-pins | sonnet | 14 | accepted | mutate 16.7 % -> 100 % on the target lines |
| n30-16 sprint-tour | opus | 20 | accepted | caught a stale import in the before snapshot; clip encoded at half speed (I re-cut it at real speed) |
| n30-17 molotov-tour | sonnet | 9 | accepted | p70 molotov sprint tour, snapshot re-imported up front |
| n30-18 eq-collar-film | sonnet | 11 | accepted | 32 px/m turn clip of the aim-left collar |
| n30-19 vermilion-preview | sonnet | 2 | accepted | heat -> amber preview per weapon, no Godot, beside the gate |
| n30-20 unsure-collar | sonnet | 2 | accepted | UNSURE cells settled at 4x, next-run list of 9 images |
| n30-21 vermilion-glow | sonnet | 5 | accepted | glow column (value lift 0.55) beside brass for Calls 1 |

Brief differently: give one builder the whole Godot lock window (no mutate beside an install); name `tools/film/blob.mjs` for any
before asset; never rely on dev harnesses that live outside the repo (masters can be pruned); the 15-25 min one-point calls were
again the best value.
