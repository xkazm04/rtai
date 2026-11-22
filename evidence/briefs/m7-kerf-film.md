# Brief m7 (lane moves, n23, follow-up of m5/m6): a Kerf film where the carrier survives the landing, so "behind it, facing its back" reads

Wall clock: start 07:06. **Commit deadline 07:45. Hard stop 07:50.** If it is not green by 07:42, commit nothing and report. Setup: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`, windowed runs at `--position 0,1440` (never the main display). One Godot at a time for this lane (the director runs none while you work).

## Why

In `C:\Users\kazda\kiro\gtai-masters\n23\moves\kerf_blink_behind.mp4` the shipped 99-damage slice kills the shield carrier on the landing tick, so the owner sees where Kerf lands but never Kerf behind a living carrier, facing its back. m6 (`29bd06ce8`) added a probe-only `--slice-k` to the kill-time probe; at 0.1 the shield robot survives one slice in both arms (front 1.98, rear 9.9 of 10 hp).

## What to do

1. Give the film scene (`project/dev/moves/move_film*.gd`) the same probe-only slice scale (a flag, declared in its `KNOWN_FLAGS`, reusing m6's in-memory override; no data file changes). Film the Kerf take at slice-k 0.1 on the open-ground approach where the blink-behind lands (the crate-corner take or a simpler one), off and on, same seed and tick: 32 px/m, tilt 70, 1080p60, 15 to 20 s. Name it `kerf_blink_behind-alive.mp4` in `C:\Users\kazda\kiro\gtai-masters\n23\moves\`. On the on arm Kerf must stand behind the living carrier for at least 0.5 s; slow the landing section (half or quarter speed) as m5 did.
2. Stills: a 64 px/m off/on pair at the same frame a few ticks after the landing (`kerf_blink_behind-alive-{off,on}-64-f<frame>.png`), and one 32 px/m on/off pair. Put the 64 px/m on-still into `frames.json` as the Kerf entry (title "Kerf behind a living carrier"; note: "probe-only slice scale 0.1, so the carrier survives; shipped slice still one-shots"); drop the entry `kerf_blink_behind-on-32-f0655.png` and delete its two PNGs (it shows byte-identical frames). Keep 8 to 15 entries. Look at your stills before you finish: does the on arm show Kerf behind the carrier, body turned toward its back, with the shield still raised and facing away from Kerf? Say what you see.
3. Optional, only if it is a view-only change of 15 lines or fewer in `project/features/souls/kerf_spectral.gd`, with no sim, replay or hashed state touched: when the landing came from blink-behind, the cut pose takes the bearing toward the target rather than the travel bearing (`kerf_spectral.gd` `live`, near the `trail_from`/`trail_to` bearing). If that needs new sim state, skip it and say why. If you do it: `node tools/tests/run_unit.mjs --changed` green, the scenario `ghost_attacks` green (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=ghost_attacks`), and the replay check `--only=replay_60s` green, all quoted.
4. Add a short paragraph to `evidence/moves/film.md` on the new clip.

## Checks before the commit

`node tools/lint/lint.mjs` green (a `dev_loc` rise is authorised: `node tools/debt/debt.mjs --update --accept-regression="move_film slice-k for n23 moves"`, stage `tools/debt/baseline.json`), `node tools/gate/quick.mjs` green. One commit (two if you did item 3: the view change on its own), staged per path.

## Report

Commit sha(s), the clip and still names, what you saw in the stills, the lint line.

## Law

Allowlist: `project/dev/moves/move_film*.gd` (+ `.uid` of new files), `project/dev/moves/move_ttk*.gd` only to reuse the override, `project/features/souls/kerf_spectral.gd` (item 3 only), `evidence/moves/film.md`, `evidence/moves/capture.mjs`, `tools/debt/baseline.json` (through the debt tool), files under `C:\Users\kazda\kiro\gtai-masters\n23\moves\`. Any other path: stop and report a NEED. Forbidden: other lanes' files (`project/features/gauntlet/**`, `project/features/player/**`, `project/boot/prologue/**`, `tools/gauntlet/**`), every data table. Typed GDScript, files under 200 lines (300 hard), functions 40 lines or fewer, 5 parameters max. No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push. Fix lint and format findings in your own edit and go on. If you change `kerf_spectral.gd`, run `node tools/mutate/mutate.mjs --file=features/souls/kerf_spectral.gd --max=20 --lines=<changed>` only if time is left before 07:42; otherwise say it was not run.
