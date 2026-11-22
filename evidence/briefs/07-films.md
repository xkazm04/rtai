# Brief 07 (street lane, n23): two short films for the owner (no code)

Hard stop: 09:20 wall clock (check `date`). This call changes NO product file and makes NO commit except evidence notes under `evidence/street/`. Films and their notes only.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Anything that renders: `--rendering-driver d3d12`; every window `--position 0,1440` (secondary screen, never the main display). One Godot process at a time. Never kill processes by name; only a PID you started. Use the film kit where it fits (`tools/README.md`, `tools/film/film.mjs`); the stack film of call 4 (`evidence/street/stacking-seeds.md`: Movie Maker from the live gauntlet with `--pick-view`, a scripted seek, then a cut) is the proven route; its capture scripts are under `build/street/`.

## What the owner wants to SEE (32 px/m, tilt 70, 1920x1080, 60 fps, h264 mp4 at a sane bitrate (CRF 18-20), 15 to 30 s each)
1. `C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-32.mp4`: shield robots telegraphing and shoving at Rivet in the live gauntlet (a seed and wave where shield robots are present: find one from `evidence/street/` results, e.g. seed 7 wave 9 with `--wave-timeout=12`, or seed 2, which died to a shield robot on wave 9). At least two complete shoves: the mark appears at the tell, stays planted while the carrier lunges, the tip is where the slab stops. If one shove lands on Rivet and one misses because he is just outside the mark, even better (the bot plays; do not script Rivet unless the film kit already does).
2. `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-32.mp4`: enemy rounds in flight against blood and asphalt in the opening waves (Rivet on hands at the start, so the bare-hands path is in the film), with at least one rocket (large, ice blue) if a rocket trooper appears in an early wave of some seed within 30 s of film; otherwise say so and film small rounds only.
Plus a 64 px/m close-up still of one shove tell and one enemy round on hands taken from those runs: `wedge/shove-film-64.png`, `rounds/rounds-film-64.png`.

Look at every film yourself (extract 4 frames per film with ffmpeg into `build/street/film-check/` and read them) and describe what is visible at which second. A film where the subject is off-screen or too small is not done: re-cut it.

## Report
Write `evidence/street/films.md`: command lines, seed, wave, tick range, frame-by-frame description with seconds, file sizes. Commit only that file (`git add evidence/street/films.md`, message ends `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`). Never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push.

## Allowlist (edit only these)
`C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/**`, `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/**` (new files only: do not overwrite existing stills), `build/street/**` (scratch: capture scripts, logs, frame checks), `evidence/street/films.md`.
Forbidden: every file under `project/`, `tools/`, `docs/`, JOURNAL.md, REPORT.md, `frames.json`. If a film needs a code change, stop and report what and why.
