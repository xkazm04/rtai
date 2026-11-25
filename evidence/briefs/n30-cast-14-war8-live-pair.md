# n30-cast-14: pile-driver four | eight in the LIVE fight, 32 px/m clip + 64 px/m live still (tag `c14`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched ~15:05. First commit by 15:30. Hard stop 16:05 (report and END).

## Why
The owner judges the pile-driver's eight by film. What exists: `gtai-masters/n30/cast/war8_four_eight_32.mp4` (four | eight
on the grey feet harness `cast_feet.tscn`, not the game) and the eight live only incidentally in `flash_turret_war_32.mp4`.
Wanted: the SAME live fight, four | eight side by side at the same ticks, so he sees the change where he plays it.

## What you have
- `tools/film/cast_war_films.mjs` (~150 lines): staged copies of the project (never touches the tree); `four` = a copy
  with `FOUR_PATCH` (`cast_war_anchors.gd` `WALK = EIGHT` -> `FOUR`); `pair` mode already hstacks two 960x1080 centre crops.
- Live fight scene `project/dev/cast/cast_flash_fight.tscn` (+ `.gd`): env `GTAI_CAST_FLASH_FOES=turret_war` picks the
  sentry turret + war machine against Rivet. Read it first: how long it runs, how the camera is set (ppm, tilt), whether the
  war machine WALKS for at least 10 s of it (if it mostly stands, say so and pick the window where it walks; if it never
  walks more than 5 s, STOP and report: no film).

## Do
1. Add a mode `live` to `cast_war_films.mjs`: run `cast_flash_fight.tscn` (turret_war) in the staged four copy and in the
   eight copy (the committed tree, staged as the other modes do), windowed, `--fixed-fps 60`, 32 px/m tilt 70, the same
   ticks, movie out; crop each to a 960x1080 (or the true height) window around the war machine (or the scene centre if
   the camera follows it) and hstack four | eight -> `war8_live_four_eight_32.mp4`, 15-40 s. Reuse `pair`'s helpers; keep
   the file under 200 lines if you can (if not, put the new mode in a small sibling module `tools/film/cast_war_live.mjs`).
   Same fight: check that tick N shows Rivet at the same place in both halves.
   NOTE: builder c11 found windowed films on this machine get clamped (window 1422x800, movie 1280x800) and `compare.mjs`
   then exits UNVERIFIABLE. ffprobe the raw movie. If clamped, film at what you get, do NOT upscale: pad to 1920x1080 and
   state the true size in the report and the frames.json note. Check how `pair` mode got 1920x1080 and do the same if it can.
2. A 64 px/m still of the eight in the same live fight (`war8_live_64.png`, one tick where it is mid-stride, eight only;
   if the scene cannot take 64 px/m by an existing flag or env var, add one in the dev scene ONLY IF that is a few lines in
   `cast_flash_fight.gd`; else skip that part and say so).
3. Lane lock around every Godot run (the tool runs several Godot processes: hold it for the whole tool run). Builder c16
   shares the lane lock; it uses Godot only late (after ~15:40).
4. `ffprobe` the clip; extract 3 frames (5 s, 12 s, 20 s) to `build/look/n30-c14/`, READ them, say what you see: both
   halves the same fight; the left (four) legs change half as often as the right (eight).
5. `node tools/lint/lint.mjs`, `node tools/gate/quick.mjs`; commit with a pathspec:
   `film: cast_war_films live mode (pile-driver four | eight in the live fight, same ticks)` (+ the dev scene if touched).
6. Insert into `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` at the 2nd place (keep every entry, valid JSON,
   check with node JSON.parse): `war8_live_four_eight_32.mp4` "Pile-driver four | eight in the live fight, same ticks",
   ppm 32, before "left half", note with duration + true capture size; and `war8_live_64.png` ppm 64, before
   "war8_feet_before_after_64.png".

## Allowlist
`tools/film/cast_war_films.mjs`, a new `tools/film/cast_war_live.mjs`, `project/dev/cast/cast_flash_fight.gd` (+.tscn, only
step 2's few lines), `build/look/n30-c14/**`, `build/film/**`, masters files under `gtai-masters/n30/cast/`.
Do NOT touch door files, `tools/art/**`, `cast_door_*`, `gtai-art/**` (builder c16 works there). Anything else: NEED.

## Report
Commit hash, ffprobe line (and raw capture size), what you saw in the frames and the still, every command's result line.
