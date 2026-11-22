# Brief 02 `dash`: the dash on Shift (lane motion, n24)

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on.

## Why
Owner, verbatim: "introduce dash on 'Shift' button on direction WASD -> it will help chasing cops to support
speed, and dodge major projectiles and bosses". Another lane (pressure) consumes this in its gauntlet test player
as soon as it is committed, and doubles enemy damage and shortens their fire gaps tonight: the dash must make
a moving, skilled player survive that.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`; any windowed run `--position 0,1440`.
- One Godot process at a time in this lane. Free your own processes by PID; never kill by name.
- Kit: `tools/README.md`; `tools/gate/quick.mjs` before each commit; `node tools/tests/run_unit.mjs --changed`;
  `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` (the shipped tapes and replays).

## The contract (wire identifiers fixed between lanes: use exactly these)
- Input action `dash`, default key Shift, a NEW row in `project/data/tables/input_actions.json`:
  `"bit": 18, "wire_bit": 31` (wire bits 0-15 actions, 16-28 aim, 29 cover, 30 guard; 31 is the last free one).
  Existing rows keep their bits so recorded tapes replay byte-identical. The ghost lane takes `"bit": 19,
  "wire_bit": 32` for `ghost_deploy`; for that, widen the mask in `project/core/replay/tick_input.gd:16` from
  `& 0xFFFFFFFF` to `& 0xFFFFFFFFFFFF` (48 bits; `pack()` shifts buttons by 16 so this stays inside int64, and
  under 2^53 for JSON up to wire bit 36). Make exactly that one-line edit (the ghost lane may make the identical
  one) and add a unit test that bit 31 and bit 32 survive `pack()`/`unpack()`. Check every other place that
  assumes 32 button bits (`grep -rn "0xFFFFFFFF\|<< 16\|>> 16" project/core/replay project/features/player`,
  the replay file writer/reader, `ControlsReplay`) and report what you found.
- `sprint` leaves Shift: its row keeps bit 5 and its pad button, its `keys` become `[]`.
- Numbers in a new block `dash` of `project/data/tables/rivet_motion.json` (+ the schema if the table has one,
  + the `doc`): `distance_m`, `ticks`, `cooldown_ticks`, `iframe_ticks` (0 = none), `enabled`, plus whatever
  else you need (below). Direction = the held move input (WASD / stick), the facing when none is held.
- Count: `PlayerMotion.dashes` (an int like `rolls`). In the gauntlet result each wave carries `dashes` (count):
  `project/features/gauntlet/gauntlet_wave_stats.gd` is the pressure lane's file: add ONE line in its begin
  function and ONE line in `finish` that call a helper in your own new file (e.g.
  `PlayerMotionDashStats.begin(stage)` / `.finish(stage, row)`), and name both lines in your report. Add the optional
  `dashes` field (integer, minimum 0, a description) to the wave object of
  `project/data/schemas/gauntlet_run.schema.json` and nothing else there.

## Design (the director's starting numbers; measure and adjust, record what you chose)
- Start: `distance_m` 4.5 over `ticks` 10 on an ease-out curve like the roll (`PlayerMotion._roll_step`: the
  covered distance is exactly distance_m), `cooldown_ticks` 40 after the dash ends, exit speed = the run
  (walk_mps) along the dash, so he does not stop dead.
- `hold_sprints` (bool, true): holding Shift after the burst keeps sprint speed (`sprint.sprint_mps`) while the
  stick is held: the keyboard's sprint is folded into the dash key ("support speed"). false = the burst only.
  The pad's sprint button keeps the old held sprint.
- I-frames: `iframe_ticks` 0 against everything by default. Measure, in a unit or integration test on the real
  enemy round code: an enemy `rocket` (enemies.json `weapons.rocket`: 9 m/s, splash 3 m) fired at Rivet from 5,
  8 and 12 m, Rivet standing, then pressing dash sideways after a 15-tick (250 ms) reaction: is he outside the
  splash at detonation? Same for the boss `stomp` (reach 3.5 m, splash 3.5 m) from its tell. If a dash at 15
  ticks of reaction cannot clear a rocket from 8 m, add a short window against blasts only (`blast_iframe_ticks`)
  and say so; never i-frames against bullets. Write the measured table into `evidence/n24-motion/dash_dodge.md`.
- Chase: a fleeing human runs at ~4.5 m/s (bodies.json; check what a gauntlet cop's flee speed really is).
  Measure the net speed of a repeated dash (dash, cooldown, dash) with and without hold_sprints vs a plain run,
  and the time to close 10 m on a fleeing cop. Into the same evidence file.
- Wall: the dash ends at a wall (the displacement is blocked: find where the stage resolves Rivet's move
  against solids and bodies, and stop the dash on the first tick its step is cut by more than half); the
  cooldown starts. No passing through solids or bodies; a dash into a body does not tackle unless the tackle
  rules already say so at that closing speed (bodies.json): report which happens.
- Not during a roll, a vault, cover or a death; a roll press during a dash is ignored. The dash does not cancel
  a reload (it continues) and does not block fire. A melee swing in progress continues while he dashes (do not
  touch melee files). Record each of these as one `DECISION` line in `docs/decisions.md` (append, one line).
- Put the dash in its own file `project/features/player/player_motion_dash.gd` (PlayerMotion is at 190 lines);
  `PlayerMotion.step` calls it; `PlayerMotionTable.read` loads it.
- Replay identity: `PlayerMotion.write_state` feeds the replay/state digest. Append the dash state to it ONLY
  when the dash has been used in this run (dashes > 0 or active or cooling down), so a tape without a dash press
  writes the same bytes as before. Prove: every shipped tape and replay scenario passes unchanged; a test that
  `write_state` bytes are identical to the pre-dash layout when no dash was pressed; a test that a recorded
  tick stream WITH dash presses replays to the same digest twice.
- Look: during the dash draw the run frames with an afterimage / smear in Rivet's own colours (his body
  greys and the vermilion collar; no teal: teal is souls; no red: red is blood), in a new render-only file
  `project/features/player/player_motion_dash_view.gd` hooked by one line where the rig is drawn (name it).
  Use the run grid he would show; no new character art.

## Tests (`project/tests/unit/test_player_motion_dash*.gd`)
Direction (held WASD, diagonal, none -> facing), distance (exactly distance_m in open ground), cooldown (a press
during cooldown does nothing, the next after it dashes), wall (ends at the wall, cooldown starts, never inside the
solid), enabled false (Shift does nothing), hold_sprints, the input row's bit (31) and the 48-bit pack round trip,
tape identity (above). Then `node tools/tests/run_unit.mjs --changed` and the scenarios.

## Commits (one per change, staged per path)
1. input row + mask widening + sprint off Shift + the dash on the tick + table + tests. Then STOP AND PRINT
   the sha in a line `MILESTONE dash <sha>` in your report, and go on.
2. the gauntlet `dashes` count + schema.
3. the dash view.
4. the dodge/chase measurement file.
After commit 1: `node tools/mutate/mutate.mjs --file=project/features/player/player_motion_dash.gd --max=20`
and quote the score.
If time remains: a 32 px/m film (tilt 70, 1080p60, 15 to 40 s, check `ffprobe`) of the dash crossing an enemy
rocket's path and of Rivet catching a running cop with the dash, into
`C:/Users/kazda/kiro/gtai-masters/n24/motion/dash_*.mp4` plus a 64 px/m still of the afterimage.

## Files you may touch (allowlist)
`project/features/player/player_motion*.gd` (+ new `player_motion_dash*.gd`), `top_down_mover.gd`,
`stride_match.gd`, `live_input.gd`, `player_command.gd`, `project/data/tables/rivet_motion.json` (+ schema),
`rivet_bob.json`, the `dash` row and the sprint row's `keys` in `project/data/tables/input_actions.json`,
`project/core/replay/tick_input.gd` (the one mask line), `project/features/player/player_actions.gd` only if the
new bit needs it (name the lines), new tests `project/tests/unit/test_player_motion_dash*.gd` and
`test_tick_input_wide*.gd`, new files under `project/dev/motion/`, `evidence/n24-motion/**`, the masters folder,
the two one-line call sites in `gauntlet_wave_stats.gd`, one rig-draw call site, the `dashes` field in
`gauntlet_run.schema.json`, appended lines in `docs/decisions.md`, appended `KNOWN_FLAGS` lines in
`project/boot/launch_args.gd` (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n24 motion"`).
Any other path: stop and report a NEED with the file and why.

## Forbidden
`melee_*.gd`, `player_melee.gd`, `player_shock.gd`, `melee_weapons.json`, `enemies.json`, `weapons.json`,
`player_deflect.gd`, `player_guard*.gd`, `combat.json`, other files in `project/features/gauntlet/**`,
`project/dev/gauntlet/**`, `test_player.json`, `project/features/souls/**`, `ghost_*.json`, `powers.json`, the
`ghost_deploy` row, any art, `combat_arena.gd` beyond a one-line call site. No `git stash`, no `git add -A/./-u`,
no `commit -a`, no amend, no rebase, no reset --hard, never push. Commit `.uid` files with new scripts (run a
Godot `--import` after adding scripts). No sim, parity or bake digest may move; shipped tapes replay identical.

## Report
Files changed, commits (sha + subject), the `MILESTONE dash <sha>` line, the chosen numbers and why, the
dodge/chase table, the mask audit, the call-site lines, the mutate score, anything not done and why.
