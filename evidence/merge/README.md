# Merge notes: `d-bodies` with `d-slice` and `d-vehicles` (collisions lane, 2026-11-03 13:40)

Trial merges were done in scratch worktrees (`x-bodies-slice`, `x-bodies-veh`) off `d-bodies` at
1402492, with `d-slice` at d1938b4 and `d-vehicles` at 27f4192. Nothing was pushed or committed
to another lane. `git merge-tree` against d-combat, d-cast, d-audio, d-city and d-save conflicts
only in JOURNAL.md and the 11 look goldens, which whoever merges last re-blesses.

## d-bodies x d-slice

- Conflicts: `JOURNAL.md` (keep both) and `project/boot/collect_call/collect_call_stage.gd`.
- Resolution: `bodies-x-slice-stage.patch` (diff against d-slice's file), or the whole resolved file
  in `collect_call_stage.resolved.gd.txt`. It keeps slice-play's StageLines, pilot and
  `_collide_hostiles`, and adds three things:
  1. **The read-back (REQUEST 1).** At the start of the stage step,
     `arena.rivet.pos = follow.target` while the city body is on: where the city's people left him.
     Without it, the stage's own Rivet position never feels the people. People are still pushed off
     him, but he does not lose the share of speed his mass should cost him.
  2. `ArenaBodies.resolve` after `arena.step`: Rivet against the guards.
  3. `arena.rivet.pos = _collide(...)` before `_collide_hostiles()`, so a shove never leaves
     Rivet or a guard inside a wall.
- Measured on the merged tree (native sim, headless):
  - All 16 scenarios pass, including quest1_input, quest1_keys, the bodies scenarios,
    replay_60s, city_replay and rig_stress.
  - Quest 1, bot-driven to "paid": 11241 ticks with the read-back and 11241 without it. Rivet never
    came within 2.9 m of a city person or 1.0 m of a guard on that route, so the line changes nothing
    on the quest's own path.
  - `scenario_quest1_walkin.gd.txt` stands 5 city peds on Rivet's own path in the real quest 1
    session (stage + city), then walks him through them at 1.4 m/s and sprints at 6 m/s, for 8 s each.
    The overlap is measured at the DRAWN position (the stage's arena pos, before that tick's city
    resolve):

    | run (deterministic: 2 runs alone + full suite + quest1_* sequence) | walk overlap | walk progress | run overlap | run knockdowns |
    |---|---|---|---|---|
    | with the read-back | 0.0073 m | 10.59 m | 0.031 m | 5 |
    | without it (planted) | 0.0103 m | 11.21 m (= free walk) | 0.015 m | 5 |

  - Reading: overlap stays at or below 1 px at 32 px/m either way, because the light humans take
    68 % of every overlap. The read-back is what makes Rivet's 160 kg real: he loses 5 % of his walk
    pace through a crowd instead of none. The 0.031 m at a sprint is one tick of motion before the
    city resolves (the view draws the stage pos). A resolve after the city step would take it to
    0.0003 m, but needs a hook in World's loop, which slice-play owns. Not done.
  - The same "with" numbers come out in the full 16-scenario suite and after the other quest 1
    scenarios in one process: deterministic, no leak between scenarios. An earlier copy of
    `quest1-walkin.json` was stale (left by the planted run in the same evidence folder).
    Caught and replaced.
- To keep the probe as a live test after the merge, copy `scenario_quest1_walkin.gd.txt` to
  `project/tests/scenarios/scenario_quest1_walkin.gd`. It needs a verdict: walk overlap < 0.02 m,
  0 knockdowns; run, at least 1 knockdown.

## d-bodies x d-vehicles

- Conflicts:
  - `JOURNAL.md`, `native/SConstruct`, `native/sim_core/src/sim_constants.h`,
    `project/features/city/sim/sim_constants.gd` and `project/tests/parity/city_parity.gd`.
  - The constants source `tools/gen_constants/sim_constants.json` auto-merges cleanly. Vehicles adds
    F_PASSING = 8 and OBST_MAX; bodies adds M_DOWN = 4, BD_* and BR_*. Nothing collides.
- Resolution (`bodies-x-vehicles.patch`, diff against d-vehicles):
  1. SConstruct: the union of both CORE lists (`car_pass` and `body`).
  2. `node tools/gen_constants/gen.mjs` regenerates both constants files. Do not hand-merge them.
  3. city_parity.gd: keep both sides. In the step loop, the `knocks += ...` line, then
     `_vehicle_inputs(a, b, st)`. Then both helper blocks (`body_spec`, and `_vehicle_inputs`,
     `_strike`, `_obstacles`).
  4. **REQUEST 2**, `boot/city_vehicle_world.gd` `set_focus`: `_city.body.on = not in_car`. With the
     body on, the car's centre would carry Rivet's 0.42 m body, shove people and "tackle" them at car
     speed, alongside the vehicles lane's own strike.
- Measured on the merged tree:
  - Native rebuilt (template_debug). `node tools/tests/run_parity.mjs`: **exact over 1200 steps**,
    and the planted mutation is caught at step 629.
  - All 15 scenarios pass, including vehicle carnage, drive (replay identical) and yield,
    replay_60s, city_replay, the 4 bodies scenarios and rig_stress.
  - Not measured: how many body knockdowns a drive makes without line 4. The fix is from reading the
    code, not from a failing run.
- Note to vehicles: a non-lethal car strike sets M_FLEE after a 1 m shove. M_DOWN (lie
  `down_s`, get up, flee from the hit point) now exists in both sims if they want a car knockdown to
  look like a tackle. It is their call.
