# Brief n26-02-hands-cadence: bare hands' feet match the ground

Lane `keys`, branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Hard stop: 13:35 wall clock. Commit deadline: 13:28.** Commit each step as it lands (small commits, staged per path,
`git commit -- <paths>`). No amend, no rebase, no stash, no `add -A/./-u`, no `reset --hard`, never push.
Fix lint and format findings in your own edit and go on. If time runs out, commit what is green and say what is left.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; add
`--rendering-driver d3d12` for anything that renders. One Godot process at a time. Windowed runs only with `--position 0,1440`.

## Background (read first)
`evidence/n24-motion/slide_before.md` (last paragraph), `evidence/n24-motion/slide_after.md`,
`evidence/n24-motion/grid_machine_pistol.md` (the measuring standard), `project/features/characters/rivet_walk.gd`,
`rivet_stride.gd`, `tools/film/foot_slide.py`. Found last run, not fixed: with bare hands the run8 drawings hold 13-14 ticks
each at 3.2 m/s and the planted boot slides inside a step (67 cm in-drawing excursion at 64 px/m, net drift 5.3 cm).
In the game Rivet runs at 6.75 m/s and sprints (hold Space now, or the sprint action) at 9.3 m/s: both are above
`RUN_FROM_MPS` (2.5), so both draw `rivet_run8.png`. Things to check, not conclusions: `RUN_CYCLE_CELL` (258 at p70, 212 at
p55) against the run8 sheet's actual drawn stance travel per row (the armed runs were calibrated per row, bare was not);
`MAX_RUN_CYCLES_S` (3.5) lengthening the cycle at 9.3 m/s (a floor of 2.66 m per cycle); walk8 below 2.5 m/s.

## 0. First, 15 minutes at most: close brief n26-01 (keys; its call hit the time cap during mutate)
- `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_deploy.gd --max=20 --lines=<lines changed in 974647488>`; quote killed/(killed+survived); kill a survivor with a test if cheap. Delete any stale scratch it left under `build/mutate/`.
- `project/boot/quest1_controls_text.gd`: its English strings still say "Space: quick claw" and "F: car (soon)": make them follow the table (`[melee]` / `[car]` via the existing key-name helper, as the `_PAD` variants do) if e75e90ce1 did not; this file is allowed for this item.
- `project/features/player/player_motion.gd`: restore the class header doc that 974647488 cut to one line (sprint above the 7.5 m/s tackle line and its slower turn, the roll press, vault, station cover, the dash burst), and add a unit test for the new in-car early stop in `PlayerMotion.drive` (no movement and no sprint while driving or in a door). Comments + test only; allowed for this item.
One commit, then go on.

## Do, in this order
A. **Data first, no behaviour change** (the deferred n24 item): move the per-grid stride numbers (`RUN_CYCLE_CELL`,
   `CYCLE_CELL`, `ARMED_CYCLE_CELL`, `RUN_ROW_K` from `rivet_walk.gd`, `WALK_PROFILE_TRAVEL` from `rivet_stride.gd`) into a
   `grid_stride` block of `project/data/tables/rivet_motion.json` (+ schema), read once and cached; restore the doc comments
   squeezed out last run. Prove identity: a unit test that pins every old value, and `run_unit --changed` green. Commit.
B. **Measure before** at the game speeds 6.75 and 9.3 m/s, bare hands, p70 and p55, 32 and 64 px/m, per facing row:
   ticks each drawing holds, net stance drift (cm), in-drawing excursion (cm). Use the real game (arena, keyboard-equivalent
   input), not a lab board. Save the numbers and before frames (`--rev=<commit A>`) under `build/` and the table under
   `evidence/n26-keys/hands_before.md`.
C. **Fix the cadence** so the planted boot holds the ground at walk (6.75) and sprint (9.3): bare run8 (and walk8) per-row
   cycle from measured drawn travel, the cap revisited, both pitches. Target: net stance drift <= 2 cm walk / <= 6 cm run mean
   at 32 px/m (the armed standard), and each drawing held no longer than the drawn travel allows. If 8 drawings cannot keep
   the in-drawing excursion small at 9.3 m/s, say so with the number, do not hide it. Values go in `grid_stride`, not code.
D. **Measure after** the same way; `evidence/n26-keys/hands_after.md` with before beside after.
E. **Films** (record after the change): a before beside after at the same tick of bare-hands running and sprinting
   (`node tools/film/compare.mjs ... --a=<commit before> --b=<commit after>` or the n24 `legs_film` capture scene in
   `C:\Users\kazda\kiro\gtai-masters\n24\motion\capture-source\`, copied into `project/dev/motion/`), 32 px/m 1080p60,
   15-40 s (check with `ffprobe`), plus a 64 px/m close-up, to `C:\Users\kazda\kiro\gtai-masters\n26\keys\`
   (`hands_before_after_32.mp4`, `hands_after_64.mp4` or `.png`). Do not write `frames.json` (the director does).
F. Mutate after the last code commit: `node tools/mutate/mutate.mjs --file=project/features/characters/rivet_walk.gd --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
G. One line appended to `docs/decisions.md`: `- [2026-11-23] DECISION n26 hands cadence: ...` (numbers before/after).

## Acceptance
`node tools/lint/lint.mjs` green, `node tools/tests/run_unit.mjs --changed` then the full run green,
`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` green (tapes byte-identical: the walk is view only;
if any digest moves, stop and report). `node tools/gate/quick.mjs` before each commit. Run a Godot `--import` before
committing new files.

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/rivet_walk.gd`, `rivet_stride.gd`, `stride_match.gd` (if it exists), new
`project/features/characters/rivet_grid_stride.gd`, `project/data/tables/rivet_motion.json` + `project/data/schemas/rivet_motion.schema.json`,
`project/tests/unit/test_rivet_*`, new `project/dev/motion/**`, `tools/film/**` (only additive), `evidence/n26-keys/**`,
`docs/decisions.md` (append one line), `tools/debt/baseline.json` through the debt tool only, `.uid` files of new scripts,
`C:\Users\kazda\kiro\gtai-masters\n26\keys\`.
Forbidden (other lanes): `project/features/souls/**` except what brief 01 touched, `project/features/combat/**`,
`combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`, `project/boot/prologue/**`, `prologue_stage.json`, cast art, `native/`.

## End with
Files and commits, the before/after table, test/scenario/lint/mutate numbers, film paths with ffprobe durations, NEED lines.
