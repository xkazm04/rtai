# Brief g6-deploy-linger (lane `ghost`, n24): the ghost stays long enough to be seen

Hard stop: 00:12 wall clock (check `date`), because the Director runs the snapshot gate at 00:15 and the lane allows one Godot at a time. Last CODE commit by 23:58. Then films in this order until the hard stop: (a) deploy_kerf-64 close-up (keep the old one as before-linger), (b) deploy_all.mp4 at 32 px/m, (c) the other three close-ups, (d) stills. Whatever is not filmed by 00:12: stop, say so, leave no Godot running. Commit each part as it goes green; fix lint and format findings in your own edit and go on.

## What the Director saw
A 10 fps strip of `C:/Users/kazda/kiro/gtai-masters/n24/ghost/deploy_kerf-64.mp4` (real speed): Kerf is on screen for 2 frames (~0.2 s), a teal slash streak, then gone. In the 32 px/m `deploy_all.mp4` at 4 fps he shows in one sample. The cause is the table: `ghost_attacks.json` `deploy.<form>.life_ticks` = kerf 15, dent 18, ohm 24, tonnage 30 (0.25-0.5 s), and `GhostDeployBody._wash_body` fades over the last third of that. The owner's words: "ghost is deployed, performs signature attack and disappears": the player must SEE a ghost, not a streak.

## What to build
1. **Longer presence, same strike.** Raise `life_ticks`: kerf 45, dent 42, ohm 48, tonnage 54 (0.7-0.9 s). The strike still lands on the release tick (`GhostDeploy` -> `strike.land` once): kills, stuns, cooldowns and the worth numbers do not change; only the ACTIVE phase is longer. Check nothing else reads `ticks_left` for gameplay (grep `project/features/souls/**`); one ghost out at a time stays true (every cooldown >= 480 > life). Update the `doc` string if its wording needs it.
2. **Appear, hold, fade.** In `ghost_deploy_body.gd` (view only, reads sim state, never writes it): the first 6 ticks of ACTIVE fade the ghost IN with the same apparition/fade material run backwards (`fade_from` from 1.0 down to 0.25, alpha ramping up), then hold the signature pose fully washed at 0.95 alpha, then fade out over the last third as today. Kerf holds his slice follow-through pose, Ohm his staff with the bolts' afterglow, Tonnage his stomp, Dent his ram end pose: whatever the attack views already show at their last attack frame; do not draw new art.
3. **Tests**: `test_ghost_deploy.gd` / `test_ghost_deploy_view.gd` still green (they read the row value); add one view test: alpha at ACTIVE age 0 < alpha at age 8 > alpha at the last tick.
4. **Checks**: lint, `node tools/tests/run_unit.mjs --changed`, the FULL scenario suite with `replay_60s` final `cbeb734ff9b97c41` and no tape digest moved (shipped tapes carry no deploy; if one moves, stop and report it by name). `node tools/gate/quick.mjs` before the commit. Commit by 00:00.
5. **After the commit (films, allowed after 00:00 until the hard stop)**: re-shoot the four 64 px/m real-speed close-ups and `deploy_all.mp4` at 32 px/m with the same entry and seed as g4 (`ghost_deploy_film`), crf 23 encoding as g4, replace in place; re-shoot each `deploy_<form>-64-fNNNN.png` attack still at the tick where the ghost is fully washed (about 10 ticks after release). Keep the g4 Kerf close-up as `deploy_kerf-64-before-linger.mp4` for a before/after. ffprobe each clip (1920x1080, 60 fps, frame count). Say what you see in each still.

## Checks binding every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/ghost` and `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12` for renders; windowed runs only with `--position 0,1440`; one Godot at a time; free your processes by PID, never by name.

## Files you may edit
`project/data/tables/ghost_attacks.json` (the `deploy` block only), `project/features/souls/ghost_deploy_body.gd` (and other `project/features/souls/ghost_deploy_*` view files if needed), `project/tests/unit/test_ghost_deploy*.gd`, `project/dev/ghost-forms/**`, `C:/Users/kazda/kiro/gtai-masters/n24/ghost/**`. Any other path: stop that part and report a NEED. Forbidden: everything of `project/features/gauntlet/**`, `enemies.json`, `weapons.json`, `input_actions.json`, `project/features/player/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/`.

## Repo law
Typed GDScript, warnings are errors; ~200 lines per file (hard 300), functions <= 40 lines, <= 5 parameters; `Log` not print; render reads sim state, never writes it. Stage per path, one commit per change, no `git add -A/./-u`, no stash, no `reset --hard`, no amend, no rebase, never push. Cap mutate at `--max=20` on changed lines only if time is left before 00:00 (skip otherwise, say so).

## Report
Commit sha + subject, check lines (lint, unit, scenarios with replay_60s), film paths with ffprobe, what you saw in each still, how long each ghost is visible now (ticks fully washed).
