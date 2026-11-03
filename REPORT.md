# REPORT: lane rivet-motion (branch `e-motion`), evening run 2026-11-03

**Scope:** the owner asked for four things. Rivet should look like the concept (T2). He should move twin-stick with locomotion animation. He should have a bare-handed melee. A melee-weapon framework should start with the electro baton and the katana.

**Status:** all four are built and tested in this lane's dev scenes. **None of it is wired into the live game yet.** PlayerMotion and MeleeCombo run in the dev scenes and in the arena station data only. So display latency (input to pixel) is **UNMEASURED**.

**Paths used below:**
- `M` = `C:\Users\kazda\kiro\gtai-masters\eve\rivet-motion\`. The owner page is `M\frames.json`, with 15 entries. I checked at 23:40 that every file it lists exists.
- `E` = `evidence/rivet-motion/` in this worktree. It holds the probes and FEEL-NUMBERS.md. `E/clips/` is empty: every clip is under `M\clips\`.

## Gates of record
| Gate | Result | Where / when |
|---|---|---|
| lint | 13/13 over 507 files | re-run 23:30 on 16390b6 (no code change since f5a31e9) |
| unit | 574/574 | f5a31e9; `test_save_slots` 16/16 when run alone (see Blocked) |
| scenarios | 19/19, incl. the 60 s replay | f5a31e9 |
| evidence run (`node tools/evidence/run.mjs --no-bench`) | lint, scenarios, parity exact (mutation caught at step 629), look goldens 11/11 (worst 0.46), block goldens 5/5, **no re-bless** | 36905b3, about 23:00 |

Not re-run after that:
- **The bench.** No runtime path changed: the sim is untouched, PlayerMotion is not in the game, and the rig changes are Rivet-only and view-only.
- **The parity and evidence runs after 36905b3.** The later commits are logic and tests only: 8d88b8b, 9032298, f5a31e9.

The next session can re-check with these commands: `node tools/lint/lint.mjs`, `node tools/tests/run_unit.mjs`, `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`.

## What works (each claim with its evidence)

### 1. Rivet looks closer to the concept (ASK rivet-motion-1, answered A)
- **The change:** `RivetPlan.ARMS` holds one row per form: arm_k, hand_k, arm_w. The base form uses the T2 ratio: arms ×0.72, claw ×0.78, arm width ×0.8. The `mild` and `day` forms are kept for A/B. Commit 5dc151c, in `project/features/characters/rivet_plan.gd`.
- **Footprint** (`E/rivet-footprint.txt`, made by rig_footprint.gd):

  | Body | Footprint |
  |---|---|
  | Rivet, day | 1.90 × 2.05 m |
  | Rivet, now | 1.68 × 1.97 m |
  | Cop | 1.27 × 1.88 m |
  | Ped | 0.69 × 1.34 m |

  Rivet's width now comes from the torso and the hose, not the arms.
- **Lineup:** `M\frames\rivet-proportions-vs-t2-128ppm.png` shows T2 beside the three forms, a cop and a ped. The 32 and 48 px/m lineups are in `M\frames\lineup-*-{32,48}ppm.png`. The scene is `project/dev/rivet_motion/lineup.gd`.
- **Sim untouched:** the body radius stays 0.6 m, so replay and parity cannot move.

### 2. Twin-stick direction: the legs follow the walk, the torso follows the aim
- **The change:** `RigHips` (`project/features/characters/rig_hips.gd`, commit bf41369) turns the hips toward the walk direction. Past 105 degrees it flips to a backpedal. The twist is capped at 70 degrees, and the hips settle on a spring (k 140). It is Rivet-only through `hip_follow`, so cops and peds are byte-identical.
- **The test:** `test_rig_hips`. On a strafe the foot spread goes from 0.4 to 148 part px. A planted fault (a rig with the hips locked) is caught.
- **Clips:** `M\clips\strafe-hips-48ppm.mp4`, plus `strafe-hips-96ppm-sheet.png` (forward, strafe right, backpedal, strafe left).

### 3. Locomotion: sprint and dodge roll as data, plus the gait
- **The model:** `PlayerMotion` (`project/features/player/player_motion.gd`) over `data/tables/rivet_motion.json`, commit 9d92fe4.
- **Sprint:**
  - It is a held key (owner call C19) with a top speed of 6.2 m/s, above the 5.0 m/s tackle line.
  - The sprint reads through four cues:
    - a stride band (`gait_scale` 1.3, from ASK rivet-motion-2, answered B; `sprint_stride` 0.2);
    - a body lean (415bc16);
    - the claw shoulder leading (c2f6c15);
    - an arm pump (012f4ef).
  - Stills: `M\clips\tackle-shoulder-before-after-48ppm-2x.png` and `M\clips\sprint-pump-before-after-48ppm-2x.png`.
- **Roll:** 3.2 m in 22 ticks, i-frames on ticks 2-14, then 10 recovery ticks and 8 cooldown ticks.
- **Tests:** `test_player_motion` passes 6/6, with 2 planted faults caught: a sprint at walk speed, and i-frames that run past the roll.
- **Clip:** `M\clips\motion-course-32ppm.mp4` runs the real PlayerMotion through a strafe box, sprints and rolls. The scene is `project/dev/rivet_motion/motion_course.gd`.
- **Footfalls:** the feet stay planted in the world (RigGait), so they do not skate. The stride probe is in `E/stride-probe.txt`.

### 4. Bare-handed melee
- **Claw combo:**
  - The data is `data/tables/rivet_melee.json`, played by `MeleeTable`, `MeleeHit` and `MeleeCombo` (commit 02524d3).
  - Each hit has windup, active and recovery phases. Input is buffered from cancel tick 4, the combo window is 12 ticks, and the finisher knocks back 2.5 m.
  - The strike poses come from `RigClips.strike()` (commit a692b60).
  - Tests: `test_melee_combo` and `test_melee_cadence`.
- **Charged electroshock:**
  - `MeleeShock` (commit a6f231c): hold to charge; release to stun, scaled by the charge. The arc chains only to metal targets.
  - Test: `test_melee_shock` passes 4/4. A planted fault (zero chain radius) is caught.
  - There is no clip of the shock yet, because no metal enemy rig exists on this branch (REQUEST 2).
- **Tackle:**
  - `test_rivet_tackle_chain` passes 4/4 (commit 936b6a1). From a stand, the sprint crosses the 5 m/s line after 0.84 m, and `bodies.json` (rule `rivet_base -> human`) then gives a knockdown. A walk never knocks down. 2 planted faults are caught.
- **Impact:** hit-stop 3/3/7 ticks, a decaying shake, the cop dies on the finisher, and CombatBlood sprays.
- **The sample reel (the best single piece of evidence):** `M\clips\rivet-reel-48ppm.mp4` (13.3 s), `rivet-reel-32ppm.mp4`, and `rivet-reel-48ppm-sheet.png`.
  - It is shot on the D5 arena floor with the real state machines.
  - In order: a strafe box, a sprint tackle at 6.03 m/s that knocks the ped down, a roll, then a claw kill on a cop. The claws land at ticks 568/579/595, and the cop dies in his blood.
  - The scene is `project/dev/rivet_motion/rivet_reel.gd`.

### 4b. Melee-weapon framework, the electro baton and the katana
- **The table:** `data/tables/melee_weapons.json` (schema `gtai.melee-weapons/1`, commit 5aaaa51). It is separate from gunplay's weapons.json, so the two cannot conflict.
- **Per weapon:** the table sets stun, chain hops, lunge, move_mult, chain radius, length and grip.
- **On screen:** `MeleeWeaponView` (`project/features/player/melee_weapon_view.gd`, commit edb694d) draws the prop, the slash sweep, the smear and the stun zap.
- **The baton's arc:** the finisher arcs through metal (`MeleeTable.chain_for`, commit 8d88b8b). On the station's metal dummies it hits 6, 8 and 10 and stops short of 14. A planted fault (zero radius) is caught. This is logic only, with no clip yet.
- **Tests:** `test_melee_weapons`, with 3 planted faults: a missing weapon, a string move_mult, and a lunge stretched into the recovery.
- **Clips:** `M\clips\weapon-katana-48ppm.mp4`, `weapon-katana-32ppm.mp4`, `weapon-katana-48ppm-sheet.png`, and `weapon-electro_baton-48ppm.mp4`.

### 5. Feel numbers (sim-true at 60 Hz, not perf): `E/FEEL-NUMBERS.md`, `E/motion-probe.json`
| Gait | Top speed | Time to 90 % | Stop distance | Stop time | 180-degree turn |
|---|---|---|---|---|---|
| walk / run | 4.5 m/s | 150 ms | 0.22 m | 117 ms | 250 ms |
| sprint | 6.2 m/s | 350 ms | 0.43 m | 167 ms | 550 ms |

- **Roll:** 367 ms, of which 233 ms are i-frames. The lockout before the next roll is 667 ms.
- **Sim input latency:** 0 ticks; Rivet moves on the tick the key is pressed.
- **Combo cadence** (finisher landing time, mashing at 20 presses/s): claw 0.53 s, baton 0.45 s (the fastest), katana 0.50 s.

### 6. Arena station
- `data/tables/arena_stations/rivet-motion.json` defines 2 stations: the motion course (16 tunables plus a tackle crowd) and the melee dummy line (humans at x 0/2/4, metal dummies at 6/8/10/14, every claw, shock and weapon tunable).
- It validates against the arena lane's `gtai.arena-station/1`. I applied the arena lane's layout notes in commit b03f575.

## What does not work yet (honest)
- **Not in the game.** PlayerMotion, MeleeCombo and MeleeShock are not wired into quest 1 or the exe. The cost of that:
  - display latency is unmeasured;
  - nothing is proven in the city proving block. Only the dev scenes and the arena station data exist.
- **The hit flash is still vermilion.** It comes from the shared rig tint, and red is for blood only. The reel turns the flash off to hide it.
- **The shock and the baton's arc have no clip**, because there is no metal enemy rig on the branch.
- **The weapon props are drawn placeholders:**
  - the katana's smear is faint;
  - at 1x, Rivet's guard mostly hides the baton, and the stun zap does the reading.

  The owner's 21:25 bar is a real-time clip in the final look, so ASK rivet-motion-3 (one clip per weapon) was **not filed**.
- **The chainsaw and the plasma sword are not started.** The brief scheduled them for the night run.
- **Size read:** at 48 px/m Rivet is still about the cop's bulk and clearly bigger than the ped. The owner offered a lower guard pose as the next step; that has not been built.
- **The 32 px/m clips are plain D4.** `look_d5`'s print zoom is 0 at 32 px/m, so a D5 clip at that zoom renders the same as D4.
- **No Rivet contact beat on the tackle.** Only the victim reacts.
- **Teal torch tip:** the torch tip on Rivet's forearm turns teal in the D5 print. That is existing art, not this lane's, and teal is for souls only. Flagged for d5-cast.

## Blocked / friction (and for how long)
- **`test_save_slots` contention:** this cost about 15 minutes over iterations 1 and 6. Every worktree shares `%APPDATA%/RTAI Uprising` (`use_custom_user_dir`), so concurrent lanes collide. The test passes 16/16 alone, and merged main failed it too under load. REQUEST 4 -> int/Director: a per-run user subdir.
- **A parse error in a windowed `-s` runner hangs:** about 10 minutes, and `--write-movie` wrote 200 MB before the timeout. The fix is a headless run of every new runner first.
- **`run_unit.mjs` without `GODOT_BIN` exported:** it reports exit -1 but prints a stale pass count. Lost about 5 minutes twice.
- **The owner's 21:25 direction** ("not judgeable … visual impression is key") moved the lane from breadth to depth for about 45 minutes. This was correct, not a blocker: the reel came out of it, and the weapons were deferred until then.

## Requests open
- **REQUEST 1 -> gunplay:** HitFeel should own a non-red victim flash, and the melee needs a `melee_light` hit class (REQUEST 3). Then swap the clip constants for `HitFeel.land()`, with a `hit_class` per hit.
- **REQUEST 2 -> enemy-ai:** a robot or metal thug rig, needed for the shock and baton-arc clips.
- **REQUEST 4 -> int/Director:** test runs need their own user dir.

## Owner decisions
| ASK | Answer | Applied |
|---|---|---|
| rivet-motion-1 (arms) | A, T2 ratio 0.72 | yes, 5dc151c (the frame labels were re-keyed after the owner's note) |
| rivet-motion-2 (stride) | B, 1.3, as a placeholder under the 21:25 direction | yes, 25a1efc |

## Next steps (night run, in order)
1. Re-read answers.json.
2. Wire PlayerMotion and MeleeCombo into the arena hub and the city block. Then measure display latency and prove the values in the city.
3. Split `combo_clip_run.gd` (216 lines). Then add metal dummies and record the clip of the baton's finisher arc and the charged shock.
4. Replace the drawn props with D5-look weapon art (codex image_gen, with provenance lines). Then ASK rivet-motion-3 with one real-time clip per weapon against the dummy line.
5. Build the chainsaw (a hold-to-grind mode on MeleeCombo) and the plasma sword (a timed block that deflects gunplay's projectiles).
6. HitFeel integration (REQUEST 1), a tackle contact beat on Rivet, and a lower-guard ASK if he still reads large beside the ped.
