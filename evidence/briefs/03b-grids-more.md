# Brief 03b `grids` (resume): the next weapons' drawn grids, and the dash decision lines (lane motion, n24)

Hard stop: 22:22 wall clock (check `date`). Commit deadline: 22:12 (one weapon committed by 21:55 at the latest, even if alone). Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on. No amend, no rebase,
no `git stash`, no `git add -A/./-u`, no `commit -a`, no reset --hard, never push. Stage per path.
mutate: `--max=20`, changed lines only. Everything from brief 03 still binds (pipeline, accept rule, allowlist,
forbidden list, environment): this is the same session, continued.

## 0. Five minutes: decision lines (append to `docs/decisions.md`, one line each, AGENTS.md format, 2026-11-22)
`docs/decisions.md` is added to your allowlist for this item only (append only; grep first, skip a line that exists).
- `DECISION n24 sprint`: `sprint` leaves Shift (keeps bit 5 and its pad button, keys []); on the keyboard the sprint is
  folded into the dash: holding Shift after the burst keeps the 9.3 m/s sprint (`rivet_motion.json` `dash.hold_sprints`
  true; false = burst only). Why: the owner's "dash ... to support speed" with one key. Rejected: a second keyboard
  sprint key; no keyboard sprint (loses the 9.3 m/s the chase needs).
- `DECISION n24 dash numbers`: distance_m 4.5, ticks 10, cooldown_ticks 40, iframe_ticks 0; measured in
  `evidence/n24-motion/dash_dodge.md` (rocket at 5/8/12 m cleared by +1.3/+1.4/+1.4 m after a 15-tick reaction; stomp
  cleared at 1.8-3.5 m; repeated-dash chase 10.8 m/s vs run 6.75 vs a fleeing cop 3.2). Rejected: a blast i-frame window
  (measured as not needed).
- `DECISION n24 dash wire`: logical bit 18 / wire bit 31; `TickInput` mask 48 bits; schema maxima 19/32 as ghost; dash
  state enters `PlayerMotion.write_state` only once a dash was used, so tapes without a dash keep their bytes.
- `DECISION n24 rivet legs fallback`: a held weapon without its own walk/run grid walks on the bare-claw walk8/run8 legs
  with the weapon-art held part on the painted palm (`rivet_motion.json` `walk_grid`), so nothing slides; masking the
  donor grid's drawn weapon was rejected (floor showed through the wrist). Own drawn grids replace it per weapon.
One commit.

## 1. Then the weapons, in this order, p70 first, each committed before the next
1. `rocket_launcher` (two-hand / heavy family: read `rivet_armed_run_twohand_it129.md` and
   `rivet_armed_run_blade_heavy_it131.md`; the tube must sit on the shoulder or in both hands as on
   `rivet_eq_rocket_launcher*.png`, never hanging at his side).
2. `chainsaw` (blade-heavy family; the bar forward as on its eq strip, never dangling blade down).
3. `electro_baton` (one-hand / blade family as fits its eq strip).
4. `assault-rifle`, then `hand_cannon`, `machine_pistol`, if time is left.
Same accept rule as brief 03: every row looked at in the game at 32 and 64 px/m, the stride measured into
`rivet_walk.gd` + `evidence/n24-motion/grid_<weapon>.md`, `walk_grid` pointing at it, a before (fallback) | after
(own grid) still at the same tick into `C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_<weapon>_<32|64>.png`,
`run_unit --changed` + `tools/gate/quick.mjs` green, one commit per weapon with pngs + .import + provenance.
If p55 for a weapon would cost more than 15 minutes, ship p70 alone (p55 stays on the fallback: say so in the
weapon's grid md) and go to the next weapon: the owner plays at tilt 70.
Reuse what worked for gloria (your scripts in the 1948 round: cut_rows.py, stride.py, pack_candidate.py): copy them
into the new round dir, do not rewrite them.

## 2. The game-speed before|after film (if a weapon landed and at least 15 minutes are left before the hard stop)
The owner judges by films of the real game: Rivet in the arena (or gauntlet) with the wheel, at his real walk
(6.75 m/s) and run, 32 px/m tilt 70 1080p60, 15 to 40 s (`ffprobe` it), the fallback beside the own grid, for each
weapon that landed (gloria first). Into `C:/Users/kazda/kiro/gtai-masters/n24/motion/legs_game_32.mp4`, plus a
`frames.json` entry (keep the existing entries). Use `project/dev/motion/grid_arena_film.*` if that is what you built.

## Report
Per weapon: done / partial / fallback kept, row grades, stride numbers, stills, commit sha; decision lines' commit;
the film path and its ffprobe line; image_gen count and minutes.

## Known: quick's Godot check is red for reasons outside this lane
`tools/gate/quick.mjs` FAILs with ~475 "Identifier not found: Log / LaunchArgs" and "Failed to compile depended
scripts": `--check-only -s` does not register autoloads, so every unchanged file that uses `Log` fails the same way
(the director reproduced it on unmodified `cut_rig.gd` at d50add33b). Do not chase it and do not let it hold a
commit: the compile check that counts is `node tools/tests/run_unit.mjs --changed` (plus lint in pre-commit). Quote
quick's lint/format lines only. Gloria p70 was committed by the director as d50add33b.
