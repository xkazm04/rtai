# play_take: the owner's real gauntlet mode on film (n31-02)

Tool: `tools/ground/play_take.mjs` (+ `play_take_lib.mjs`, `play_take.test.mjs`, 6 tests pass). Wrapper scene for 64 px/m:
`project/dev/ground_n31/gauntlet_64.tscn` (instances `gauntlet.tscn`, `camera_ppm = 64`; a real 64 px/m render).

## Commands
```
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ground GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
node tools/ground/play_take.mjs --rev=ba8e470b0 --seed=7 --ticks=2400 --label="main ba8e470b0" --out=build/n31/n31-02/s7_32
node tools/ground/play_take.mjs --rev=ba8e470b0 --seed=7 --ticks=2400 --ppm=64 --label="main ba8e470b0" --out=build/n31/n31-02/s7_64
node tools/ground/play_take.mjs --side=<dirA>,<dirB> --out=<file.mp4> [--layout=h|v]   # h: two 960x1080 centre columns, v: two 1920x540 centre bands; real pixels, labelled from take.json
```
Godot line (via `runGodot`, from a snapshot `%TEMP%/gtai-film-<sha12>` of the commit, `--rev=HEAD` after the lane's commits for the after):
`--rendering-driver d3d12 --position 0,1440 --resolution 1920x1080 --fixed-fps 60 --disable-vsync --write-movie take.avi --quit-after 2400 <scene> -- --pick-view --bot=average --controls=wheel --seed=7`
ffmpeg: AVI -> libx264 crf 23 yuv420p 60 fps (`--from=<tick>` trims the start), 3 PNG stills at 25/50/75 % of the window, `take.json`.
The tool holds `build/n31-godot.lock` (create-exclusive, waits up to 15 min, releases only its own).

## Findings
- `--bot=human` is NOT accepted by `gauntlet.gd` (`--bot` takes novice|average|expert; no flag = the human profile, with nobody at the keys). The human-like bot used is `--bot=average`. `--controls=wheel` is the default and is passed explicitly.
- Resolution: `--resolution 1920x1080` alone gives a 1280x800 movie (the movie takes the project viewport). The tool writes `project/override.cfg` (viewport 1920x1080) into the throwaway snapshot only, and fails the take unless ffprobe says 1920x1080.
- 64 px/m: no launch flag; `camera_ppm` is an exported var, so the wrapper scene is used (copied into an older commit's snapshot). Never an upscale.
- Per-tick Rivet screen JSON: not done (gauntlet.gd is read-only; no probe in the scene).
- Pick screens: the sim pauses for ~90 frames at each pick, so 2400 frames = 40 s of film, about wave 2 mid-fight (seed 7: wave 1 cleared at ~13 s, pick screen at frame 1200, wave 2 with 8 police and Rivet in melee at frame 1800).
- mp4s are large (306 MB for 40 s at crf 23; the street texture is noisy).
- Run time: about 170 s per 2400-frame take (23 % of real time) plus waiting for the lane lock.

## Before takes (rev ba8e470b0, seed 7, frames 0-2400, bot average, wheel)
- `C:\Users\kazda\kiro\gtai-masters\n31\ground\before\gauntlet_s7_32.mp4`: h264 1920x1080, 60/1 fps, 2400 frames, 40.000 s (pix_fmt yuvj420p reported by ffprobe).
- `C:\Users\kazda\kiro\gtai-masters\n31\ground\before\gauntlet_s7_64.mp4`: h264 1920x1080, 60/1 fps, 2400 frames, 40.000 s.
- Looked at stills: 32 px/m frame 225 (Rivet running on an empty street, wave 0), 1200 (wave 1 cleared pick screen, dead police), 1800 (wave 2: Rivet in melee, 8 police around); 64 px/m frame 1800 (same moment, bodies and police at twice the size, Rivet on screen). Rivet is on screen, moving, enemies present from about 10 s.
- take.json of both: `evidence/n31-ground/play_take/s7_32_before.json`, `s7_64_before.json`.

## Determinism
Two takes of the same rev, seed 7 and 2400 frames (`s7_32` and `s7_32_b`): `cmp` of stills 600, 1200 and 1800 identical (3 of 3). `--side` of the two gives a 1920x1080 60 fps 2400-frame mp4. Caveat: the bot's pick timing is frame-driven (90 frames), so the film is stable; an after take at HEAD differs only where the code differs.
