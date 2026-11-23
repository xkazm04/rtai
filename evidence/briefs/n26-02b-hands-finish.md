# Brief n26-02b-hands-finish (resume of call 02): close the cadence, then the parked prompt fix

Same lane, worktree, environment and repo law as `evidence/briefs/n26-02-hands-cadence.md` (re-read its top block and allowlist).
**Hard stop: 14:47 wall clock. Commit deadline: 14:40.** Check `date` first. No amend, rebase, stash, `add -A/./-u`,
`commit -a`, `reset --hard`, push. Fix lint and format findings in your own edit and go on. mutate `--max=20`, changed lines.

## 1. Director review of fba046f21 (your hands_after.md confirms it: front/back rows now hold 1 tick, "6-7 -> 1-1")
`_bare_cycles` maps a row whose drawn travel is zero (front / back / depth rows: `bare_run` p70 rows 0, 4, `[0,7.86]`, the
p55 zeros, most of `bare_walk`) to the floor `speed / bare_max_cycles_s` = 7.5 cycles/s: at 9.3 m/s that is one new drawing
EVERY tick on the front and back rows, a leg flicker the old code never showed (it used the 258 / 212 cycle there).
Rule instead, per boot component: when the measured travel is below a minimum (put `bare_min_travel` in `grid_stride`, e.g. 40 %
of the pitch's `run_cycle_cell` / `cycle_cell`), use the OLD cycle for that component (`run_cycle_cell`/`cycle_cell` x scale, the
old cap `MAX_RUN_CYCLES_S` / `MAX_CYCLES_S` floor), so a row with no drawn stride animates exactly as before; only rows with a
real measured stride take the measured cycle. Revisit `bare_max_cycles_s` 7.5: no measured row may hold a drawing for less than
2 ticks at 9.3 m/s; if a profile row needs it, say so with the number. Unit test: a zero-travel row returns the old cycle; a
measured row returns its own; phase stays continuous on a row change. Then commit (scenarios green, tapes byte-identical).

## 2. Finish brief 02 items D to G
D after table beside before (`evidence/n26-keys/hands_after.md`): report the profile rows (left / right, the armed standard's
ruler) as the headline, and say plainly that front / back rows have no drawn stride along travel and the ~60 cm in-drawing
excursion is the 6-7 tick hold of one drawing at 6.75 m/s (sprite limit), with the numbers. E films to
`C:\Users\kazda\kiro\gtai-masters\n26\keys\` (`hands_before_after_32.mp4` 15-40 s, `ffprobe` it; `hands_after_64.mp4` or `.png`),
before = `869642e12`, after = your cadence commit, same ticks; include a straight run toward the camera so the front row is seen.
F mutate `rivet_walk.gd` (+ `rivet_grid_stride.gd` if time) changed lines. G the decision line with the numbers.

## 3. Then the parked prompt fix (10 minutes)
Your previous call parked `build/quest1_live_controls.patch` (`project/boot/quest1_controls_text.gd`: the English desktop
strings follow the live bindings, `[F]` claw and `[1]` car, instead of the literals "Space: quick claw" / "F: car").
The director ALLOWS the two assertion updates in `project/tests/unit/test_quest1_card.gd` so that they expect the live
bindings (the owner's key table: claw F, car 1); change nothing else in that test. Apply the patch if the working tree does
not already hold it, `node tools/tests/run_unit.mjs --select=test_quest1_card,test_prompt_device,test_quest_blade` green,
`node tools/gate/quick.mjs`, one commit `-- project/boot/quest1_controls_text.gd project/tests/unit/test_quest1_card.gd`.
Delete the patch file after. Both files are allowed for this item only. Then write your final message: files, commits, numbers, film paths with ffprobe durations, NEED lines.


## Also
- The FULL scenario suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`): 68/68 on your last code commit (only 9 ran last call); quote the line.
- Delete your mutate scratch dirs `build/mutate/scratch-JStaOq`, `scratch-l7rENf` (git-ignored, yours) after the mutate run.
- Re-measure and re-film AFTER item 1 (the films must show the shipped cadence); keep the diagonal and profile gains you got
  (front right 70 -> 1.7 cm, right 8.1 -> 0.9 cm at p70 6.75): they are the real win; the 1-tick front rows were not.
