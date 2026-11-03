# REPORT: lane `collisions` (branch `d-bodies`), day run 2026-11-03

Owner (11:30): Rivet in his base form never goes through any character. Running into someone is a
tackle, and its result depends on size. Humans always lose. Robots and bosses get designed later.

`M` = `C:\Users\kazda\kiro\gtai-masters\day-d5\collisions\`. Every performance number here is **CONTENDED**:
7 or 8 lanes shared one machine.
Final code commit: `b7fb4f9`. Commits after it change only JOURNAL.md and this report.

## What works (each claim with its evidence)

1. **Rivet has a body in the city sim, in both runtimes, and parity is exact.**
   - Files: `native/sim_core/src/body.cpp` and `project/features/city/sim/sim_body.gd`, written operation for operation.
   - A new sim mode, `M_DOWN` (4), is generated through `tools/gen_constants`.
   - Proof: `node tools/tests/run_parity.mjs` matched exactly over 1200 steps (3532 floats), and the planted mutation was caught at step 629.
   - The parity run drives Rivet's body through the riot, both walking and sprinting, with knockdowns.
   - Log: `M\gates-it47.log`.
2. **The body table.**
   - Files: `project/data/tables/bodies.json` (`gtai.bodies/1`) and `project/data/schemas/bodies.schema.json`.
   - Size classes (radius / mass):

     | Class | Radius | Mass | Note |
     |---|---|---|---|
     | `human` | 0.35 m | 75 kg | |
     | `rivet_base` | 0.42 m | 160 kg | |
     | `robot` | 0.5 m | 300 kg | |
     | `boss` | 1.2 m | 900 kg | |
     | `rivet_ghost` | 0.9 m | 600 kg | reserved, not used yet |

   - The full tackle matrix is in the table. Every pair that involves a robot or a boss is `blocked`: a placeholder until the owner designs them.
   - Why Rivet is 0.42 m:
     - It is 1.2x the human radius, which matches verdict 1 ("only slightly larger than a human").
     - At 160 kg, a human takes 68 % of any overlap, so Rivet keeps most of his speed.
     - The radius is read by class and never from the sprite, so d5-cast's rescale does not affect it.
   - Each class has its own shove/tackle line (`run_mps`): Rivet 5.0 m/s, human 3.2 m/s.
   - Unit tests: `project/tests/unit/test_body_table.gd`. The reader refuses a radius or mass of 0 or less, a missing pair and a missing `run_mps`. Other tests check that Rivet's combat walk stays under the tackle line, and that the line is per class.
3. **No walk-through.** Scenario: `project/tests/scenarios/scenario_bodies_crowd.gd`.

   | Run | Worst Rivet-person overlap |
   |---|---|
   | Before (body off = today's main) | **0.770 m** (his centre sits on a ped) |
   | After, 1.4 m/s walk | **0.0003 m** (tolerance 0.02 m) |
   | After, 4.5 m/s quest-gait walk | 0.0011 m |

   - Person-to-person overlap: 0.006 m.
   - Progress: 19.0 of 19.6 m. The crowd parts into two rows and nobody is knocked down.
   - Planted faults, both caught: radius 0 (0.420 m) and body off (0.770 m).
4. **Tackle.** Scenario: `project/tests/scenarios/scenario_bodies_tackle.gd`.
   - A 6 m/s sprint into a human: 1 knockdown. The human slides 1.93 m, lies down for 1.4 s, gets up and flees from the hit point.
   - Rivet keeps 99 % of his speed. Overlap: 0.00002 m.
   - A sprint into a robot (`BodyContact`): `blocked`. No overlap, and the robot does not move.
   - Planted faults, both caught: tackle off (0 knockdowns), and a table missing the `rivet_base -> robot` row (load error, 0.92 m overlap).
5. **Cops.** Scenario: `scenario_bodies_cop.gd`.
   - A tackled cop is knocked down once, lies for 84 ticks, then resumes as a cop and never flees.
   - Planted fault, caught: with `down_s` 0, the cop is re-tackled every tick.
6. **People running into Rivet do not shove him.** Scenario: `scenario_bodies_runin.gd`.
   - A ped fleeing at 4.5 m/s pushes him 0.093 m (bound 0.15 m).
   - With the rule off, he is pushed 0.61 m, which the scenario catches.
7. **Event.** `actor_knocked_down(attacker_id, defender_id, defender_class, at)` is in `project/data/schemas/events.json` (a shared file, minimal change) and `core/events/events.gd`. It is emitted by `features/bodies/rivet_body.gd`.
8. **Quest 1 arena.** `features/bodies/arena_bodies.gd` resolves Rivet against every live CombatArena hostile, with 2 unit tests. The call site is 3 lines in `boot/collect_call/collect_call_stage.gd`. The quest scenarios are unchanged.
9. **Knockdown pose (rig, drawing only).**
   - `RigFeed.Flag.DOWN` and `RigClips.down`: the body stays upright for 0.12 s while the slide opens a gap, then sprawls, then gets up.
   - Unit test: `test_knockdown_stays_upright_then_sprawls_and_rises` in `project/tests/unit/test_rig_clips.gd`.
   - The approach is described in `project/features/bodies/README.md`.
10. **Gates on the final code** (`node tools/evidence/run.mjs --no-bench --allow-dirty`, 17:00). Log: `M\gates-it47.log`.
    - All green:
      - lint 13/13;
      - unit 337/0;
      - scenarios 12/12, including replay_60s (identical) and `scenario_rig_stress`;
      - parity exact;
      - look goldens 11/11 (worst 0.00) and block goldens 5/5.
    - Unit was also re-run 5 times back to back: 337/0 every time (`M\unit-it45.log`).
    - "Dirty" means only the untracked pre-existing `evidence/clip/` and `evidence/scen/quest-*.json`.
11. **Section 20 bench under the lock** (`node tools/bench/run.mjs --runs=1 --secs=20`). This was a **short** run (1 x 20 s, not 3 x 60 s) and **CONTENDED**.
    - PASS on every hard limit: p99 CPU 2.579 ms, 1 % low 199 fps, worst swap 4.36 ms.
    - Riot rigs p99: 0.463 ms. The 0.407 ms figure from this morning was idle, so the two are not comparable.
    - Evidence: `M\bench-it50.log` and `M\bench-it50\bench-*.json`.
    - CPU-only probe (`project/dev/bench/bodies_cost.gd`, 300-person riot, 23 knockdowns): sim-step p99 with the body on vs off was 0.303 vs 0.301 ms, and 0.289 vs 0.289 ms. That is within noise.
12. **Frames and clip from the real World + CityView + rigs** (`project/dev/showcase/bodies_clip.tscn`). Same seed and tick before and after.
    - What the clip shows:
      - Rivet walks at 4.5 m/s through crowd A, which parts.
      - He sprints at 6 m/s into crowd B: 5 knockdowns, then they get up and flee.
    - Files:
      - main clip: `M\v7\bodies-v7-after-32ppm.mp4` (16.5 s, 32 px/m);
      - side-by-side: `M\v7\bodies-v7-before-after-32ppm.mp4`;
      - stills at 32 and 48 px/m: `M\v2\{before,after}-{32,48}ppm-t{180,500,560,760}.png`;
      - the v7 crops: `M\v7\delay-v2-vs-v7-48ppm.png` and `-32ppm.png`.
    - Index: `M\frames.json` (15 entries, every file present) and `M\ladder.png`.
    - Every still I looked at was top-down: **0 rejected**.
13. **Trial merges with d-slice and d-vehicles.**
    - Notes and patches: `evidence/merge/README.md`.
    - d-slice merge: scenarios 16/16.
    - d-vehicles merge: native rebuilt, parity exact, scenarios 15/15.

## What does not work, or is not done

- **Nobody can be tackled in quest 1 today.** slice-play's Rivet has a single 4.5 m/s gait and no sprint, and the tackle line is 5.0 m/s. A walk always shoves.
  - This needs REQUEST 3 to slice-play (below).
  - Tackles do work in the city clip and the scenarios.
- **A faller is drawn touching Rivet's shoulder** for about 0.12 s of a sprint-through, at 48 px/m.
  - The sim circles do not overlap; the drawn sprawl reaches further than the body radius.
  - 5 fixes were tried (v3-v7). v3-v6 were rejected or reverted; v7 (the delayed sprawl) is kept.
  - Evidence: `M\v3\reverted-lying-radius-v2-vs-v3-48ppm.png` and frames.json entries v3-v6.
  - **Owner question:** is that touch acceptable, or should d5-cast shorten the sprawl art?
- **The arena knockback pops** 1.6 m in a single tick. There is no lying-down state in CombatArena. It cannot happen in quest 1 until a sprint lands.
- **No get-up grace and no recovery cost for Rivet** (a deviation from realtime-combat-semantics; see JOURNAL). This waits for the owner's call.
- **Robots and bosses** have only the neutral `blocked` rows. Deviation: `blocked` means the defender holds and the attacker stops. It does not mean "both pushed", because a mass split let a held sprint push a robot along at 2 m/s.
- **Not measured idle:** the full-length bench and `scenario_city_chase`.
  - `scenario_city_chase` failed twice inside `run.mjs`: the flow field took 2045 and 2267 µs against a 2 ms budget, CONTENDED.
  - It passed standalone 3 times. My branch does not touch flow.
- **The test `test_noir_shadows` is flaky under contention** (the engine reports "Parameter t is null"). It belongs to the noir lane and is not fixed.
- **Untracked files:** the clip media (about 60 MB, in `evidence/clip/`) and `evidence/scen/quest-*.json` are deliberately not committed. `M\` holds the record.

## Blockers (and for how long)

- **Bench lock:** held by other lanes from 16:43 to 17:10. The bench was skipped in 4 iterations (16:52, 17:00, 17:03, 17:04), about 27 minutes in total. It was taken at 17:10, and only a short run fitted.
- **Empty godot-cpp submodule** in a fresh worktree: about 10 minutes in iteration 1. I copied it from n-d5 (not committed).
- **REQUEST 3 to slice-play (a sprint) is still open**, since about 13:00. That is why the quest 1 tackle above cannot happen.

## Requests for the Director to relay

1. **slice-play:** after each `city.step`, read `city.body.pos` back into the pilot and mover. Otherwise the pilot puts Rivet back inside people. The merge patch is in `evidence/merge/README.md`.
2. **vehicles:** set `city.body.on = not in_car` (merge patch ready). It was measured as not necessary today and is kept as the contract.
3. **slice-play:** add a held `sprint` above 5.0 m/s (a `run_mps` in combat.json's rivet row).
4. **audio and the heat ladder:** `actor_knocked_down` is live. A tackled cop is still a cop, and I added no heat rule.
5. **d5-cast:** Rivet's body radius stays 0.42 m whatever the sprite scale. His open arms reach about 1.2 m at 48 px/m.

## Merge notes

- The 11 look goldens conflict with other lanes. Re-bless them **once, on the merged tree**.
- Regenerate the sim constants together with d-vehicles (`node tools/gen_constants`): there are no id collisions (`M_DOWN` 4, `F_PASSING` 8).
- After the merge, rebuild both native DLLs. A stale DLL silently drops the body spec, because `set_body` checks the spec's size.
- Decision lines: `docs/decisions.md`, the 4 lines dated 2026-11-03 for bodies and the look goldens.

## Next steps

1. Owner review of the v7 clip and crop. If the shoulder touch is not OK, ask d5-cast for a shorter sprawl. Do not retry v3-v6.
2. Once slice-play's sprint lands, turn the arena knockback into a slide over ticks, or add a lying state with d5-combat.
3. Run the full bench (3 x 60 s) and `scenario_city_chase` on an idle machine.
4. Get-up grace (about 0.5 s with no re-tackle) and a recovery cost for Rivet: the owner's call.
5. Robot and boss rows when the owner designs them. `ArenaBodies.class_of` needs a body class per fighter.
