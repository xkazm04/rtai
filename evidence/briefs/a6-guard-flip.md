# Brief a6-flip: can `wheel` be the default? Measure it, make our side hash-neutral, decide (lane `guard`, run n22, item 6)

Wall-clock HARD STOP: 04:40 local (the wrapper stops the call at 75 minutes). Commit by 04:30. If short of time, commit what is green and report what is left.
Commit each part as it lands: Part B first, then Part C.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Headless only in this call. Never kill by name, only your own PIDs.

## The rule (the lane brief, item 6)
Make `wheel` the default only if: the full gate is green, the 60 s replay and the quest 1 scenario are byte-identical, and every
test that presses right mouse or the old melee binding is pinned. Otherwise leave `legacy` the default and say exactly what blocks
the flip. The gauntlet scene passes `--controls=wheel` itself either way (street's file; not yours: just check it does, by grep, and
report).

## Part A: measure (no product edit yet, about 25 minutes)
Run the full scenario suite twice, headless, once as today and once with `--controls=wheel` appended after `--`
(`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --controls=wheel`; if the runner rejects the flag,
find the narrowest way to pass it, e.g. `GTAI_` env or the runner's own arg list, and say how). For each scenario record: pass /
fail and, where the scenario prints or compares a digest or final hash, both values. Same for the 60 s replay
(`scenario_city_replay`) and the quest 1 scenarios (`scenario_quest1_*`, `scenario_quest_collect_call`). Also run
`node tools/tests/run_unit.mjs` once with the flag if `run_unit.mjs` can pass it (if not, skip and say so). Write the table to
`build/flip/flip-table.md` and quote it in your report.

What I already know (read-only pre-check): only `test_controls_guard.gd` and `test_rivet_wheel_pilot.gd` send raw RMB.
`scenario_rivet_katana.gd` / `scenario_rivet_chainsaw.gd` rely on the `melee` action swinging the DRAWN blade (under wheel Space is
a claw strike: they should change), `quest_hauler_rec` / `quest_crush_rec` / `quest_ghost_rec` inject the raw `melee` binding
(Space, unchanged). `StagePilot.write_state` appends `guard.write_state` / `wheel.write_state` whenever they exist, and the wheel
builds a carry for loadout-less stages (`RivetWheel.carry_for`), so a wheel default moves every state digest that hashes the pilot
even when no guard or scroll input is ever given. Confirm or correct each of these with the measurement.

## Part B: make our side hash-neutral at rest (only inside the allowlist, its own commit)
Goal: with `--controls=wheel` and inputs that never press `guard`, `weapon_next/prev` or a slot key, the hashed pilot state is
byte-identical to legacy. Pick the cleanest of:
- the guard and wheel write nothing while they are in their rest state and have never left it (a `_touched: bool` that latches on
  the first raise / scroll and is itself never reset); once touched they write their full state every tick from then on. Unit
  test: rest = 0 bytes, touched = full bytes, a touched-then-rested guard still writes;
- or an equivalent you can argue is sounder (say why).
The carry built by `carry_for` for loadout-less stages: it must not change the hash while nothing was picked up (same latch idea,
or build it lazily on the first pickup / wheel input). Keep `--controls=legacy` byte-identical (the existing legacy pin tests stay
green). Re-run Part A's wheel column after the change and show which digests now match legacy.
If a scenario still differs under wheel because the CONTROLS really differ (katana/chainsaw: Space no longer swings a drawn blade),
that is expected: do NOT change the scenario (not ours); list it as a pin the Director must add at merge.

## Part C: decide and record (its own commit)
- Flip `ControlsMode.id()` so an absent `--controls` means `wheel` ONLY if, after Part B, every scenario and unit test passes under
  the wheel default without editing any file outside the allowlist, the 60 s replay hash is `cbeb734ff9b97c41`, and the quest 1
  scenarios' digests equal legacy's. Then the whole unit suite + scenarios once more on the flipped default.
- Otherwise do NOT flip. Write `build/flip/blockers.md`: each blocker as `file: what changes under wheel, the one-line pin or edit
  that would fix it, whose file it is`. Include `project/boot/quest1_card.gd` (help text names right click for electroshock; under
  wheel it must say right click guards, left click swings/fires: a string change with Loc keys, not ours).
- Append to `docs/decisions.md` (append only, one line each, today's date 2026-11-21, `DECISION guard:` prefix):
  1. enemy round size and splash read in guard code (`features/combat/enemy_rounds.gd`) over the enemies.json weapons block, not in
     foes' `enemy_roster.gd` / `enemy_pit.gd`; rejected: editing foes' files.
  2. a front melee hit on a raised guard drains `guard.melee_drain` (20) instead of dealing damage; rejected: no melee interaction.
  3. under `--controls=wheel` Space (`melee`) is a claw strike that keeps the selection; rejected: Space selects hands.
  4. Rivet's own blasts never hurt him (owner Call in REPORT); rejected: self-damage.
  5. the flip outcome (flipped, or legacy default kept and why, naming blockers.md's top items), and the hash-neutral rest rule if
     Part B landed.

## Part D (only if time is left before 04:25): two telemetry details from your film, then mutation top-up
From a5: (a) a wall stopped the rocket on stage tick 114 but stamped its effect tick 113; (b) during one claw strike `melee_swings` rose 1 -> 5 over ticks 56-60 while the combo started once. Find who reads each (grep; the loop lane counts swings and hits per wave). If (b) is a real double count in a file of the allowlist, fix it with a test; if it is outside, write it in the report as a NEED with file:line. (a): say whether the off-by-one is visible to anything that matters (replay, telemetry); fix only if inside the allowlist and harmless to the legacy hash.
`node tools/mutate/mutate.mjs --file=project/features/combat/shot.gd --max=20` scored 11/19 at the iface; 6 survivors were on old
lines. Add tests only for survivors on lines our lane added (`size`, `read_size`), quote the score. Then the same for the file Part B
changed most (`--max=20`, `--lines=` the changed lines).

## Allowlist (any other path: stop that part, report a NEED, go on with the rest)
`project/features/player/**`, `project/boot/collect_call/stage_pilot.gd` (only the guard/wheel call sites; one-line edits),
`project/features/combat/shot.gd`, `project/features/combat/enemy_rounds.gd`, `project/features/combat/rivet_blast.gd`,
`project/tests/unit/test_player_guard*.gd`, `test_rivet_wheel*.gd`, `test_controls*.gd`, `test_shot*.gd`, `test_rivet_blast*.gd`,
`test_enemy_rounds*.gd` (new test files with these prefixes allowed), `docs/decisions.md` (append only), `build/**`.
Forbidden: every scenario under `project/tests/scenarios/`, `project/boot/quest1_card.gd`, `project/core/**`, loc tables,
`project/data/tables/enemies.json` rows, `project/dev/gauntlet/**`, `project/features/gauntlet/**`, `project/features/combat/ai/**`,
`project/features/combat/squad/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Law
Never delete or reword an existing comment. A debt-ratchet rise from your own lines goes through
`node tools/debt/debt.mjs --update --accept-regression="<what> (n22 guard)"`. Typed GDScript, warnings are errors; files about
200 lines (hard 300), functions <= 40 lines, <= 5 params; `Log` not `print`; no global RNG; the 60 Hz tick. `.uid` with new
scripts (`--import` once). `node tools/gate/quick.mjs` before each commit. One commit per part, staged per path. Banned:
`git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix lint and format findings in your own
edit and go on. Mutate capped at `--max=20`. Never stop the whole call for a NEED that only blocks one part.

## Report
Per part: commit SHA + files; the Part A table (before and after Part B); the flip verdict with the exact reason; the decisions.md
lines as written; mutate scores; `--changed` unit count and the scenario count with the 60 s replay hash on the final commit.
