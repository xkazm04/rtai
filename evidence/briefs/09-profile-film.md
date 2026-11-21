# Brief 09 (lane loop, n22): film the novice and the expert on the same seed

Wall-clock: you start about 06:24. **Commit deadline 07:02, hard stop 07:08.** Films and evidence only: no change to any file under `project/`, `tools/`, `docs/`. Never amend, never rebase. If a commit hook reports a finding in your own files, fix it and go on.

## Goal
The owner judges the loop lane by films. Tonight's claim "the novice dies early, the expert late" is shown only as a chart. Film it on one shared seed, so the owner sees the same street and the same wave played by two profiles.

- Seed **11**, greedy picks, wheel controls (measured tonight, `evidence/loop/profiles-20/runs/novice-11.json` and `expert-11.json`): the **novice dies in wave 7** (`death.by` sentry_turret, wave_reached 7); the **expert clears wave 7** (45.8 s) and reaches wave 12.
- Use your own capture path from brief 06: `evidence/loop/film.json` records it exactly (`flags`, `capture_project`: scratch copy of project.godot with junctions and an override.cfg for a 1920x1080 viewport; `res://dev/test_player/gauntlet_bot_film.tscn`; Movie Maker AVI; FFmpeg libx264 fast, **CRF 23** this time (last night's clips came out at 98-140 Mbit/s), yuv420p). 32 px/m, the scene's default tilt, 1080p60, `--fixed-fps 60`, `--windowed --position 0,1440` (secondary screen, never the main display), `--rendering-driver d3d12`.
- Run 1: `--bot=novice --pick=greedy --controls=wheel --seed=11 --waves=7 --pick-view`. Run 2: the same with `--bot=expert`. If the expert run with `--waves=7` would be too long to capture, it is fine: wave 7 ends with its clear.
- Cut two clips, each **15 to 40 s**: `novice-11-wave-7.mp4` (the end of wave 7 up to and including the death and its end screen) and `expert-11-wave-7.mp4` (the same wave 7 on the same street block, ending with the clear and the pick screen; if wave 7 is longer than 40 s, take the last 40 s). Plus two stills at 32 px/m: `novice-11-death-32.png` (the frame of the death or the hit that kills, health visible) and `expert-11-wave-7-32.png` (the expert in the same block fighting the sentry turret, guarding or in cover, health visible). Look at every still and at frames from both clips yourself; describe only what is visible.
- Determinism: the filmed result of each run must be byte-identical to the headless batch result named above (`cmp`); say so, or say which differs.
- Write `C:\Users\kazda\kiro\gtai-masters\n22\loop\` files only for those four outputs; **do not edit `frames.json`** there (the director curates it); delete your AVI sources and any scratch renders and the scratch capture project when done.
- Write `evidence/loop/film-profiles.json`: seed, flags per run, clip files with source frame ranges, seconds, sha256, stills with what each shows, the cmp result, the CRF, and the wave-7 start tick of each run. Commit it alone (`git add evidence/loop/film-profiles.json`).

## Files (allowlist; any other path: stop and report)
Create: `evidence/loop/film-profiles.json` (commit), the four media files in `C:\Users\kazda\kiro\gtai-masters\n22\loop\`, scratch under `build/` or your temp dir (delete when done). Read anything. Forbidden: any edit under `project/`, `tools/`, `docs/`, `REPORT.md`, `JOURNAL.md`, the masters `frames.json`, other worktrees. Do not switch branches or merge.

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` before every Godot run; `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. One Godot at a time (the director runs none while you work). Free your own processes by PID, never by name.
- Stage per path. No `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push. `git status --short` before the commit.
- At 07:02 commit whatever is evidenced; at 07:08 stop. A missing clip is reported plainly, never faked.

## Acceptance (quote)
Both `cmp` results; `ffprobe` duration, resolution, fps and bitrate of each clip; the commit SHA; one sentence per still on what is visible. End with what you could not do.
