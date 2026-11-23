# Brief n26 pressure 03: the rocket trooper against a moving player

Hard stop 15:35 (or 75 min after you start, whichever is earlier) wall clock (stop, commit what is green, report). Commit deadline 15:20.

## Setup, every shell
`export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/pressure` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before any Godot,
test, gate or tool run. One Godot process at a time in this worktree (run batches with `--jobs=1`). A windowed run uses
`--position 0,1440`. After new scripts: one `"$GODOT_BIN" --headless --path project --import` before committing.

## Goal (owner's pick, verbatim intent)
"Rocket trooper: find a middle, faster rest or better lead, tuned until circling costs health."
Today `enemies.json` `weapons.rocket`: `cooldown_s` 1.4, `aim_lead` 0.8, `speed_mps` 13, `aim_lock_s` 0.2 (roster),
telegraph 0.8 s on the `rocket_trooper` row. At 1.4 he rarely hits a sprinter; at 0.55 he killed 6 of 15 test runs
before wave 6. The aim logic is `project/features/combat/squad/foe_rocket.gd` `_track()`: it leads LINEARLY over
lock + flight, so a player circling the trooper at 9.3 m/s and 10 m is always off the line (the arc bends away).

The result must hold all three:
- (a) a player who circles WITHOUT dashing takes rocket damage. Target: about **one rocket hit (direct or splash) per two
  troopers per wave** for the `average` test player (`test_player.json`), measured over 10 seeds;
- (b) a player who dashes across the rocket's path after the lock (15-tick human reaction, the shipped dash) takes
  **no** hit;
- (c) **nobody dies to rockets alone before wave 6** (killer `rocket` before wave 6: 0 of 30 runs, 3 profiles x 10 seeds).
Rocket `speed_mps` stays 13 (a decision line pins it so the dash clears the 5 m shot). Damage, splash and every other
weapon stay as they are (no balance retune this run).

## Levers (pick by measurement, keep the alternative one data value away)
1. `cooldown_s` (rest): sweep 1.4, 1.1, 0.9, 0.75.
2. Lead: `aim_lead` share, AND a better lead model: an orbit-aware lead that predicts Rivet's angular motion around
   the trooper (bearing rate from consecutive tracked samples, range rate kept) instead of a straight line, so a steady
   circle is hit and only a change of course after the lock (a dash) dodges. If you add it, it is a data value on the
   weapon row (e.g. `"lead_model": "linear" | "orbit"`, default `linear` so every other weapon and every tape that has
   no rocket keeps its bytes), documented in the table's `doc` string and the schema.
3. Nothing else (no telegraph, lock, speed or damage changes).

## Steps
1. Arena first (fast): `project/dev/gauntlet/fire_gap_arena.gd` already measures 30 s at 10 m for motions
   "standing" and "circle". Add a motion "circle_dash": circles like "circle" and, 15 ticks after the trooper's aim
   LOCKS, dashes once across the locked line using the shipped dash numbers from `rivet_motion.json` (read them, do not
   copy) and then keeps circling. Run every lever combination at 10 m and 14 m, seeds 1 to 5: hits / launches for
   standing, circle, circle_dash. Write `evidence/n26-pressure/trooper/arena.md` (+ json). Shortlist two candidates
   where circle loses health and circle_dash takes 0.
2. Gauntlet for the two candidates and the current values (control): `tools/gauntlet/ablate.mjs` / `batch.mjs`
   (see `docs/gauntlet-loop.md`; ablate wants a SHA, not HEAD), profiles novice, average, expert, 10 seeds, greedy,
   wheel, `--jobs=1`, waves capped at 12 to save time. For each run you need rocket hits per wave and troopers per wave:
   count them dev-side if you can (a dev probe on the Events bus); if the result file must carry it, an OPTIONAL
   per-wave field (`rocket_hits`, `troopers`) in the gauntlet result is allowed (schema optional field, measurement
   only, no sim change, run digests unchanged). Report per candidate: rocket hits per trooper per wave (average
   profile, and all), killers before wave 6, median death wave per profile.
3. Ship the candidate closest to (a) that meets (b) and (c). Commit the data (+ the lead model if used) in one commit
   "Rocket trooper: <values> so circling costs health".
4. Tests (re-derive from what they mean): `project/tests/unit/test_gauntlet_fire_gaps.gd`
   `test_rocket_uses_a_real_lock_and_circle_preserves_sprint_speed` today expects at most one hit on the circler.
   Change it to this item's meaning: circle (no dash) at 10 m takes at least N hits in 30 s (N from your measurement,
   with margin), circle_dash takes 0, standing still takes every launch; keep the lock assertions. Add a unit test for
   the orbit lead if you build it (a steady circle is hit, a dash after the lock is not). Fixtures move only with a
   comment saying what the bound means.
5. Runs: `node tools/tests/run_unit.mjs --changed`, then the FULL `node tools/tests/run_unit.mjs`, then the scenario
   suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`). All green or every red one named with
   its cause. Quest 1 tapes, `replay_60s` and the prologue scenarios must NOT move; if any does, stop and report.
   Then `node tools/gate/quick.mjs` before each commit.
6. `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_rocket.gd --max=20 --lines=<changed lines>`
   (or the new lead file), quote killed/(killed+survived).
7. One line in `docs/decisions.md`:
   `- [2026-11-23] DECISION pressure rocket trooper: rest <x> s, lead <model/share>; circle <hits/launches>, dash 0, rocket hits per trooper per wave <n> (average, 10 seeds), rocket deaths before wave 6 0/30; rejected <the others, one number each>.`

## Allowlist (any other path: stop and report a NEED)
`project/data/tables/enemies.json` (the `rocket` weapon row and the `rocket_trooper` row only),
`project/data/schemas/enemies.schema.json` (one optional field), `project/features/combat/squad/foe_rocket.gd` and a new
small lead helper beside it, `project/features/combat/ai/enemy_brain.gd` (`led_offset` only if needed),
`project/dev/gauntlet/**`, `project/features/gauntlet/gauntlet_wave_stats.gd` + `project/data/schemas/gauntlet_run.schema.json`
(optional measurement fields only), `project/tests/unit/test_gauntlet_fire_gaps.gd` and new unit tests for the lead,
`evidence/n26-pressure/trooper/**`, `docs/decisions.md` (append one line), `tools/debt/baseline.json` (only via
`node tools/debt/debt.mjs --update`, add `--accept-regression="<reason> for n26 pressure"` if dev code rises).
Forbidden: `input_actions.json`, `rivet_motion.json`, `project/features/player/**`, `project/features/souls/**`,
`project/features/combat/kills/**`, `ghost_attacks.json`, `ghost_forms.json`, `cast_cards.json`, `project/boot/prologue/**`,
`prologue_stage.json`, `test_player.json`, any art, root `JOURNAL.md` / `REPORT.md`.

## Law
Typed GDScript, files about 200 lines (300 hard; `foe_rocket.gd` is 157: put a new lead model in its own file),
functions <= 40 lines, <= 5 params, `Log` not print, no global RNG, sim steps on `SimClock.TICK_DT`.
Fix lint and format findings in your own edit and go on. Stage per path; `git commit -- <paths>`; no stash, no
`add -A`, no amend, no rebase, no reset --hard, never push. Commit `.uid` with any new `.gd`.

## Report
The arena table, the gauntlet table per candidate, what shipped and why, tests changed and their new bounds,
unit/scenario counts, mutate score, digests moved (must be none outside gauntlet/rocket fixtures), commits.

## Lessons from call 01 (bind this call)
- Commit BEFORE the long suites: the full scenario suite took 25+ min under machine load and call 01 missed its commit
  deadline with everything staged. Order: change + unit --changed + quick -> commit -> full unit -> scenarios
  (`node tools/tests/run_scenarios.mjs --only=<names>` for the touched ones plus `replay_60s` and quest 1 if the full run
  does not fit) -> fix-up commit if needed.
- The pre-commit hook's tool tests can fail on process-timing checks under load: retry the commit once; do not change
  hook settings or lane env overrides.

## Time budget (Director, 13:30): the day is short, keep the batches small
- Step 1 arena: at most 8 lever combinations (rest 1.4/1.1/0.9 x lead linear/orbit, plus 0.75 orbit and 0.75 linear
  only if the others miss (a)), 10 m and 14 m, seeds 1-3. Stop sweeping once two candidates meet (a) and (b).
- Step 2 gauntlet: control + 2 candidates on the `average` profile, 10 seeds, waves capped at 12 (that is the (a) metric);
  then ONLY the candidate you ship on `novice` and `expert`, 10 seeds each, waves capped at 6 (that is (c): killer
  `rocket` before wave 6). `--jobs=1`. If one arm takes over 15 min, cut seeds to 6 and say so.
- Item 5 (the Director's medians on the final state) comes later; do not run full 40-wave batches here.
