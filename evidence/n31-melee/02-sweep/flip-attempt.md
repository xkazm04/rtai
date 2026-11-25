# n31 melee 02p3 part 4 - flip --melee-sweep ON (director 00:08): attempted, REVERTED (quest 1 moved)

Flip as built (patch kept at `build/n31/02p3/flip.patch`, 12 files, not committed): `MeleeHit.sweep =
default_sweep()` = on unless `--melee-sweep=off` (old `--melee-sweep` still accepted, a no-op); launch_args
comment; sweep tests restore the default in after_each; `play_baseline.mjs` without `--sweep` passes
`--melee-sweep=off`; three melee tests pinned to the before (test_live_chainsaw plasma flank,
test_melee_lethal plasma three, test_player_shock mash); three state digests re-pinned (test_player_guard_pilot
and test_rivet_wheel_pilot e49fc269.. -> 24ca6e8e.., test_rivet_cover 2333f228.. -> 9f638256..).

Runs on the flip (lane lock held):
- `node tools/tests/run_unit.mjs --changed` (full fallback): `4379 passed, 10 failed, 2 skipped, FLAKY 1`
  (the 6 above, fixed in the patch but not re-run; plus test_prologue_encounter:63 survivors 9 -> 8 = prologue
  lane, a NEED; test_rig_head_card:59 and test_prologue_pump_tell:99 / :0 `cast_shotgun_pump` meta - relation to
  the flip not established, no flag-off control run).
- `node tools/tests/run_scenarios.mjs --quiet-wait=1`: `scenario-tests: exit 1, 430.9 s, 3 of 68 failed`:
  - `scenario_quest1_input.gd: quest 1 input final hash changed: 08e2072799320511ca53be0d518f0fd7f6d162b64c8e22d1130b65cbe07ba0b4`
    -> QUEST 1 MOVED: the brief's stop rule; the flip was reverted (`git checkout --` of the 12 files).
  - `scenario_prologue_pilot.gd`: every seed's result bytes / finish ticks moved (e.g. seed 42 13278 -> 10029 ticks).
  - `scenario_rivet_city_melee.gd`: `planted fault not caught: a bot at gun reach landed the full loadout`
    (the sweep's longer drawn reach lands from where the planted fault expects a miss).
  - native parity (`city_parity_ref`) and the other quest1_* scenarios passed.

What the next call needs (NEED): an owner/director call on quest 1 - either quest 1 keeps the one-tick before
(the flip scoped so quest 1 runs `--melee-sweep=off`, i.e. a quest-1 exception in the quest boot path, a
quest1 file outside this lane) or quest 1's input hash is re-pinned as a deliberate change; the prologue lane
re-pins scenario_prologue_pilot and test_prologue_encounter; rivet_city_melee's planted fault needs a gun-reach
distance past the new 2.25 m sweep reach.
