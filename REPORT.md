# n19 lane `move`: Rivet's vault and cover (final, 07:40, HEAD `ae211dfb3`)

Director: Claude Opus 5.5. Builder: GPT-6.2 Astra. Branch `n19-move`, cut from `int-n19` at `28302bd3c`.
Masters and frames live in `C:/Users/kazda/kiro/gtai-masters/n19/move/` (not in git); best-first list in its `frames.json`.

> Numbers marked (Astra) come from the builder's report; the director re-ran the gate (three times, last on the final code commit) and read every diff.
> Animation: vault and cover use drawn image_gen cells (`project/features/characters/art/rivet/moves/`), not rig stand-in poses; the car enter/exit is a render-only motion of the existing cells.

## What works

| Item | Evidence | Number |
|---|---|---|
| Vault (on by default; `--no-vault` turns it off) | `project/features/player/player_vault.gd`, `vault_probe.gd`, `vault_city.gd`; scenario `rivet_vault` (pit arena + city block, aimed and free approaches); masters `cells/vault/sheets/p70_64_crate.png` | 1,080 attempts, 514 landed, 0 forbidden overlaps (director run, 23:47) |
| Cover (on by default; `--no-cover`) | `player_cover.gd`, `cover_query.gd`, `cover_view.gd`, `cover_upper_card.gd`; scenario `rivet_cover`; `cells/cover/sheets/p70_64_low.png`, `p55_64_high.png` | 800 presses, 488 snaps, 360 peeks, 312 refused (director run, 23:47) |
| Replay identity | `project/tests/scenarios/scenario_moves_replay.gd` (vault, snap, peek, fire, leave: 215 ticks); `scenario_moves_fuzz.gd` replays both 6,000-tick tapes on a fresh stage | per-tick position + final digest identical; in the director's gate run 04:31 (60 scenarios passed) |
| Flags switch off cleanly | `project/tests/unit/test_moves_off.gd` pins flag-off stage bytes to the pre-vault locomotion; `scenario_moves_fuzz.gd` off control (`--no-vault --no-cover`) | off tape: 0 vault starts, 0 snaps, digest equal to the same tape with cover bits stripped |
| Drawn cells | `project/features/characters/art/rivet/moves/`, `tools/art/move_cells_cut.py`, 8 of 10 image_gen masters accepted | p55/p70 at x1.0 and x1.5 |
| Walk-slide measurement + proposal | `tools/film/foot_slide.py`, `project/features/player/stride_match.gd`, `gtai-masters/n19/move/walk/INDEX.md` | planted-step drift 14.2 -> 0.7 cm at 2.4 m/s (p55 pistol, 64 px/m) (Astra) |
| Solid fuzz (both moves, free input) | `project/tests/scenarios/scenario_moves_fuzz.gd` + `moves_fuzz_tape.gd`: hostile bursts (sprint, roll, cover, fire, roll-then-cover, cover-then-roll) through the real pilot input path, pit arena + city block, checked after every whole stage step with the shared `VaultTrial.forbidden_contact` | 24,000 checked ticks (2 x 6,000 per map), 0 forbidden overlaps; every counter non-zero (Astra counts; scenario green in the director's gate) |
| Car enter/exit | `project/features/vehicles/vehicle_doors.gd` (sim phase, `--car-doors`, data `doors.enabled` false), `vehicle_door_view.gd` (render-only motion, on); `scenario_vehicle_doors.gd`; frames `car/INDEX.md` | enter 14 ticks, exit 10 ticks below 1.5 m/s; flag-off digests unchanged (gate 60/60); mutate door file 17/20 = 85 % (Astra) |
| Street fuzz in quest 1's real city (traffic + peds) | `project/tests/scenarios/scenario_moves_street.gd` (+ `street_moves_tape.gd`, `street_moves_trace.gd`, `street_moves_contacts.gd`: an independent check of the baked parked-car footprints); frames `street/street_64.png`, `street/street_32.mp4` | 6,000 ticks with 100 traffic cars and 300 peds: 21 vault starts, 87 refusals, 21 landings (6 into the road beside moving traffic), 0 forbidden overlaps, twice identical, off control 0 starts; Rivet's centre is over a parked car only while airborne over his own vault target (Astra; scenario counted in the final gate run) |
| Mutation (sampled, after gap tests) | `build/mutate/calls-polish-survivors.md` (per-survivor diagnosis) | `player_vault.gd` 20/20 (was 50 % at 22:41, 14/20 before the last tests), `stride_match.gd` 14/15 (1 equivalent), `vehicle_door_view.gd` 14/14; `vault_probe.gd` 10/19 -> 19/19 and `vault_city.gd` 13/15 -> 15/15 after 7 gap tests (`build/mutate/probe-survivors.md`, no production bug found); earlier `player_cover.gd` 19/20, `cover_query.gd` 18/19, `vehicle_doors.gd` 17/20 (Astra) |
| Snapshot gate (director, final commit) | `build/gate/ae211dfb35b0/gate.json` (log `build/gate-final.log`) | `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n19-move\build\gate\ae211dfb35b0\gate.json` on `ae211dfb3` (07:41): lint 19/19 over 1665 files, unit 3060 passed 0 failed 2 skipped, scenarios 61/61, parity bit for bit over 1200 steps (planted mutation caught at 629), look goldens 11/11, block goldens 5/5, export-audit 754 loaded 0 failed. Earlier PASS on eea5e9b9 (`build/gate/eea5e9b92ac8/gate.json`). `--reels` was not run: it did not fit between the freeze and the report. Commits after `ae211dfb3` touch only REPORT.md and JOURNAL.md |

## What does not
- Cover snaps only to arena **station** boxes, because the arena's shot-stop rule (`ArenaWalls.blocks`) knows only stations. City props stop no shot today, so cover refuses in the open city and in quest 1 instead of faking protection. Quest 1's hide stays its own case (the p55 hide card is a dumpster with Rivet inside, not wall cover).
- Bare `--replay` of an arena recording exits 1 at tick 60: boot (`project/boot/world.gd`) picks city systems and the replay header (`project/core/replay/replay_log.gd`) records no session type or move flags. The recording reproduces inside an arena session. Not move-owned.
- The walk keeps visible ride inside one held drawing (47.1 -> 33.7 cm) after the cadence match: the armed walk has 4 cells.
- Car doors: the sim door phase is OFF (`doors.enabled` false): turning it on changes the city state bytes while a door walk is active, and only gfx re-blesses digests tonight. Flag off, the view plays a short cosmetic ease into and out of the car.

## What blocked or slowed you
- Waiting on Astra with no Godot allowed: about 30 min of idle director time at 02:10-02:40.
- The freeze fell before the reels gate could run: a ~15 min gate does not fit in the 10 min between freeze and report.
- An Astra call started from the director's own shell died with the director session (vault-view, 23:20): about 38 min of builder time lost until calls were launched detached.

## Calls for the owner
Stills: `C:/Users/kazda/kiro/gtai-masters/n19/move/calls/` (INDEX.md there), same tick, tilt 70, 64 and 32 px/m, shipped value on the left.
- **Cover peek distance** (`cover-64-t162.png`): `peek_m` 0.8 (shipped) vs 0.45. At both values Rivet's first round past the station end is not stopped by the box he covers behind (`ArenaWalls.blocks` false and false), so 0.45 is safe for his own fire and reads as a tighter half-body peek; 0.8 puts him visibly clear of the box end. Recommendation: 0.45 if the owner wants peeks to feel like cover, 0.8 if the owner prefers a clear firing lane. One data value in `rivet_motion.json`.
- **Vault into a guard** (`vault-64-t012.png`): `vault.bodies_block_landing` false (shipped: the vault tackles, peak 12.2 m/s, guard shoved 1.74 m) vs true (the vault refuses, `landing_blocked`, guard moved 0.00 m). Recommendation: true (humans stay weaker than Rivet either way; a refusal keeps the vault a traversal move, and the tackle is a guns/melee question). Shipped false so tonight's behaviour matches the evidence the gate ran.
- **Car doors** (`car-64-t124.png`): flag off (instant seat, render-only ease) vs `--car-doors` (14-tick enter, 10-tick exit in the sim). Turning the sim phase on moves city digests (gfx re-bless). Recommendation: on, in the night that re-blesses city digests.
- **Walk slide** (`NEED anim`): one line in `project/features/characters/rivet_walk.gd` calling `StrideMatch.profile_cycle` for the walk band (planted-step drift 14.2 -> 0.7 cm at 2.4 m/s). Anim owns the file.

## Merge notes
- One-line call sites in other lanes' files: `project/features/characters/rivet_frames.gd` (2 lines, anim), `project/features/arena/prop_occlusion.gd` (4 added lines, ai), `project/features/arena/arena_rigs.gd` (3 lines, ai), `project/boot/collect_call/collect_call_stage.gd` (airborne guard on `_collide`, `collide_preview`), `project/boot/launch_args.gd` (5 appended flags: `--vault`, `--no-vault`, `--cover`, `--no-cover`, `--car-doors`), `project/boot/city_characters.gd:100` (one line: the car-door view wraps `if rivet_on_foot:`).
- Conflicts at 03:15: with n19-ai in `launch_args.gd` (keep both blocks) and `prop_occlusion.gd` (take ai's `_hits_of`, add `h.rig = rigs[i]` after its `h.area = area`); `tools/debt/baseline.json` with every lane (`node tools/debt/merge_baseline.mjs`).

## Next steps
- Owner Calls: `peek_m`, `vault.bodies_block_landing`, car-door sim phase (all one data value each).
- Cover in the open city and in quest 1 needs a city shot-stop for props (gfx/ai: it moves city combat and digests). Then the quest-1 hide can become a cover case.
- Anim applies the `StrideMatch` line in `rivet_walk.gd` and re-cuts the armed walk with more than 4 cells (the ride inside one held drawing stays at 33.7 cm).
- The ai lane can call `CoverQuery` (`project/features/player/cover_query.gd`: cover near a point, the side it protects) for enemies in cover.
- Replay header: record the session type and move flags so a bare `--replay` of an arena recording reproduces (boot/core).

## Astra ledger
| Call | Minutes | Verdict |
|---|---|---|
| vault-core | 23 | accepted with follow-up |
| vault-fix | 16 | accepted |
| vault-view | 38 | abandoned (cut with the director session; all work committed) |
| cover-core | 22 | accepted with follow-up |
| cover-view | 53 | accepted |
| move-cells | 43 | accepted with follow-up |
| cells-fix (+ flip-on) | 75 | accepted |
| tidy-walk | 26 | accepted |
| solid-fuzz (+ car doors) | 72 | accepted with follow-up (launch_args reword, door ghost over the roof) |
| street-fuzz | 24 | accepted (my brief's literal "centre never over a parked car" rule was wrong for a vault over a bonnet; Astra reported the counterexample instead of weakening the check: right call) |
| calls-polish | 62 | accepted (launch_args restored verbatim, car door drawn beneath the sedan, three Call stills, `vault.bodies_block_landing` data value, mutation gaps closed) |
| probe-mutate | 25 | accepted (vault_probe 19/19, vault_city 15/15; tests only) |

13 calls, about 480 builder minutes. What I would brief differently: launch every call detached from the first one (lost vault-view); name the shared-file rule (append-only `launch_args.gd`) in every brief, not just the first (it slipped twice); write acceptance checks as properties, not literal rules (the street-fuzz "never over a parked car" line was wrong for a bonnet vault); and end the last package by 06:45 so the reels gate fits before the freeze.
