# Builder n31-melee-02p3b (opus, ~40 min): flip --melee-sweep ON with deliberate re-pins

Read `evidence/briefs/n31-common.md` (binding), `evidence/n31-melee/02-sweep/flip-attempt.md` and
`build/n31/02p3/flip_state.md`. Tag `02p3b`. HARD STOP: commit by 35 min into the call, report and END by 45 min.

## Director decision (supersedes the 02p3 stop rule)
Quest 1's SCRIPT and lines must not change; its INPUT REPLAY HASH (`scenario_quest1_input`) moving because the melee
hit now follows the blade is the deliberate change the owner asked for (he plays quest 1 with melee). Re-pin it.
Native parity must still pass unchanged.

## Do
1. `git apply build/n31/02p3/flip.patch` (12 files; check it still applies on HEAD; resolve by hand if 04b's marks
   commits touched a test it edits).
2. Re-pin, each once: `scenario_quest1_input` final hash, `scenario_prologue_pilot` seeds (result bytes / finish
   ticks), `test_prologue_encounter` survivors (9 -> 8), the three state digests already in the patch. Fix
   `scenario_rivet_city_melee`'s planted fault so it is caught again (move the "gun reach" stand-off past the new
   longest sweep reach 2.25 m + 0.45 + margin; say the new distance) - a test file, not prologue code.
3. Control: run `test_rig_head_card` and `test_prologue_pump_tell` with `--melee-sweep=off` on the flipped tree (or
   on HEAD before applying): if they fail there too, they are not ours (say so); if only with the flip, fix or report.
4. `node tools/tests/run_unit.mjs` (full) and `node tools/tests/run_scenarios.mjs` green (FLAKY/CONTENDED reported as
   such), `city_parity_ref` unmoved.
5. ONE dated line in `docs/decisions.md`: `- [2026-11-26] DECISION melee n31 item 2: --melee-sweep on by default
   (hit swept over the drawn cutting ticks, reach/arc from the drawn blade; --melee-sweep=off = before); moved
   <list every digest and test pin>; quest 1 input hash re-pinned deliberately (melee in quest 1), its script
   unchanged; native parity unmoved.` Commit (tests + patch files + decisions) in one commit.
Merge note to report: the prologue pilot digests also belong to the ground lane's scenarios; the Director re-pins
on merge if ground moved them too. Then report and END.

## Director addendum (session 4, 00:47)
Builder 02p4 runs in parallel (films, a new dev scene under `project/dev/melee_n31/sweep_clip*`, `tools/melee/play_take.mjs`,
masters folder): do not touch those. You own every test pin, `docs/decisions.md` this session, and the patch files.
Lane lock `build/n31/godot.lock`: take it per Godot run, remove only a lock whose first word is `02p3b`
(`grep -q "^02p3b " build/n31/godot.lock && rm build/n31/godot.lock`); 02p4 will queue behind you, so release it
between runs. Your full unit run also covers `test_blade_marks` / `test_claw_marks` (04c changed them after its last
run): name their result in the report. Windows: commit by 01:20, report and END by 01:30. If the full scenario run
is still going at 01:15, commit what is green with the scenario result named as pending in the commit body, then
finish the run and commit any re-pin as a second commit before 01:30. Before killing any PID print its CommandLine
and kill only if it names this worktree or your own tool.
