# Brief n20-ohm-04: Ohm's old-man drift, then the morning films

Worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`, branch `n20-ohm`. Read `git log --oneline -12` first: the spectral body
(sheets, jar overlay on `drawn.sprite()`, OhmCharge, OhmSpirit) and the spectral bolt (`ohm_bolt_draw.gd`) are in.
Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png` (hero left, top view right, attack inset). VISUAL
ONLY: no sim, replay, parity or digest moves; speed 4.5 m/s, turn rates, bolt timing, footprint are unchanged.
Everything applies only under `GhostLook.spectral(&"ohm")`; legacy draws exactly as now.

Environment: in every shell `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm` and
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
d3d12` for anything that renders; `--position 0,1440` on every windowed run (never the main display); one Godot at a
time; free only your own PIDs, never kill by name.

## Step 0: merge flight (the director tells you to)
`git merge n20-flight` (allowed tonight; only that branch). It brings hover weight, the ground pool, the tail
ribbon (f183e88a1) and the film tool `tools/film/ghost_films.mjs` (95d914ab8 + 073237b56). Resolve conflicts in
`ghost_hover.json` by keeping flight's schema and OUR ohm row values; run `--changed` tests after the merge.
Flight's package 3 (running now) will make the tail a dense vapour with an ink edge: so in Part A2 tune only the ohm
row's tail numbers (width/length/fray/anchor), never the tail's drawing.

## Files you may edit
`project/features/souls/ohm_*.gd` (+ new `ohm_*.gd`), the `ohm` row of `project/data/tables/ghost_hover.json` (only
that row), `project/features/souls/art/ohm/**`, Ohm files under `art/view/`, `project/dev/ghost-powers/ohm_beat.gd`,
`test_ohm_*` tests. NOT flight's `ghost_*.gd` / `soul_*.gd` / `power_*.gd`, not `ghost_review*`. If flight's code is
what is wrong, write it in your report as `NEED flight: <file> <why>`.

## Part A: flight character (one commit)
The owner's direction: "old and slow: he drifts, the staff planted ahead of him like a walking stick that never
touches the road, the robe and beard arriving late on every turn, a slow sway." No foot contact anywhere.
1. **Slow sway.** A slow roll of the whole body (tilt sprite and top-view parts), period about 2.4 s, amplitude about
   3 deg idle, 1.5 deg at cruise; on top of flight's bank. Deterministic from the tick (no RNG, no frame delta).
2. **Late robe and beard on turns.** Top view (OhmSpirit): the hem and beard parts trail the body yaw through a
   critically damped follow (about 8 ticks hem, 5 ticks beard), clamped to 25 deg, so on a hard turn they swing out
   and settle. Tilt view: the body is one cell, so carry the lateness by the flight tail (`swing_k` up in the ohm row)
   and a short skew/offset of the jar overlay+body only if it reads; do not draw new cells.
3. **Staff ahead.** Top view: the staff stays ahead along his facing at cruise and on turns it leads (the fork turns
   first, the body follows), never touching the road; the fork bobs 2 to 3 px at 32 px/m out of phase with the body.
4. **Drift.** Tune the ohm row for an old man: lower bob (slow, about 90 ticks period), `lag_ticks` long enough that
   he eases into a stop, `lean_deg` small. Keep his shadow at the ground point.
5. Test (`test_ohm_drift.gd` or extend an existing `test_ohm_*`): the sway is periodic and bounded; the hem/beard lag
   is zero at rest, non-zero and clamped right after a 90 deg facing change, back to zero within 60 ticks.
6. Stills (32 px/m, top + tilt70) before/after at the same tick of the move take, mid-turn (the turn southeast ->
   south): `C:\Users\kazda\kiro\gtai-masters\n20\ohm\drift\turn_{before,after}_{top,tilt70}_32.png`. Get the before
   from the commit before yours (a temp worktree at `HEAD` before your change, or shoot before you edit).

## Part A2: the director's notes on the bolt strips (`n20/ohm/bolt/`, 02:35), small fixes, same commit as A or its own
- Top view: the flight tail is a thin pale spike behind the hem, not a robe that thins into the tail (plate). Widen
  it in the ohm row (`tail.width_m` about the hem's width, `fray` up a little, length so the root hides under the
  hem); the hem fronds should continue into it.
- Re-compose both cast strips in time order from ONE cast: jars 1, 2, 3 BEFORE a press, then press, +2, +4, +6
  (today the refill frames come from after the press and sit first, labelled with later ticks). Keep the labels.
- In the top strip at press +2 / +4, white figure-like shapes lie beside the upper victim (and white dashes in the
  tilt below the first victim). Name which effect draws each (KillShockFx X-ray of a killed guard? ShockArcsView
  `_toss` drops? WeaponFx?) in your report with file:line; change only what is in Ohm's files. If it is the shock
  kill, leave it: the director has it as a morning Call.

## Part B: the morning films (no commit needed; files outside git)
Use flight's film tool (after Step 0): `node tools/film/ghost_films.mjs --ghost=ohm --look=spectral
--out=C:/Users/kazda/kiro/gtai-masters/n20/ohm --takes=move,attack,close --stills=163` (read its header for the
delay-on take; if it has no `--ohm-bolt-delay` pass-through, shoot that one by the recipe below). Only if the tool
fails, this recipe (the n19 one,
`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md`, section "Re-shoot a take"): a temporary, uncommitted
`project/override.cfg` with 1920x1080 borderless (delete it afterwards and say so), then per pass:
`"$GODOT_BIN" --path project --rendering-driver d3d12 --windowed --position 0,1440 --resolution 1920x1080
--disable-vsync --fixed-fps 60 --write-movie <abs .avi> --quit-after 370 res://dev/ghost-powers/ghost_review.tscn --
--clean --ghost=ohm --take=<move|attack> --ppm=<32|64> --view=<tilt70|top> --ghost-look=spectral`.
Frames 68..367 (5 s). Each film stacks the 70 deg tilt above the top view (each 1920x510 from source y 242, a 58 px
title, a 2 px divider) into 1920x1080 H.264 60 fps, + AAC from the tilt pass, `-movflags +faststart`; a 960x540 jpg
poster from the film. Deliver into `C:\Users\kazda\kiro\gtai-masters\n20\ohm\`:
- `ohm_move_32.mp4` (+ `.jpg`): the move take, 32 px/m.
- `ohm_attack_32.mp4` (+ `.jpg`): the attack take, 32 px/m.
- `ohm_close_64.mp4` (+ `.jpg`): 64 px/m, 5 s move then 5 s attack (10 s), the camera framed on him.
- `ohm_attack_delay_32.mp4` (+ `.jpg`): attack take with `--ohm-bolt-delay=on` (the cancelled cast's amber vent).
- `ohm_tilt55_32.png`: one still of the attack take press tick in `--view=tilt` (55 deg) at 32 px/m, to prove that tilt.
Check each mp4 with ffprobe (duration, size, codec) and quote it. Godot's movie must show zero SCRIPT ERROR lines:
grep each log and quote the count.

## Acceptance (quote every result)
`node tools/godot/check.mjs` on each changed `.gd`; `node tools/lint/lint.mjs`; `node tools/tests/run_unit.mjs
--changed`; the scenario suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) green;
`node tools/gate/quick.mjs` before the commit; staged per path. Then `node tools/mutate/mutate.mjs
--file=features/souls/ohm_spirit.gd --max=12` and quote killed/(killed+survived).

Hard stop: commit Part A by 60 minutes in; films after it. If short, say exactly which films exist.

## Report
Commit sha, the stills and film paths, test/lint/scenario/mutate numbers, ffprobe lines, and what in the films still
does not look like the plate.
