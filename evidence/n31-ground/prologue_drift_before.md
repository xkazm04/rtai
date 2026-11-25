# n31-07 prologue drift, before (item 3 part A): the print slides over the floor with the player

Owner: "Prologue - surface layer moves with player". Measured on the prologue yard (pilot bot,
`--fixed-fps 60`, tilt 70, d3d12, secondary screen, 1920x1080 requested) at worktree HEAD
`e3393e180` (no game code changed). Numbers: `prologue_drift_before.json`.

## Tool

- `project/dev/ground_n31/drift_probe.gd` (+ `.tscn`): the prologue on `--bot`, one sim tick per
  frame; logs the camera transform, `PrintStage.world_px`, the canvas origin and the window stretch
  (`get_final_transform()`) every frame; from tick 1140 (the pilot stands through the opening lines
  until then) it saves the centre crop at every tick `t % 30 in {0, 1}` twice: as played (`_a`) and on
  the same held tick with the look `off` (`_b`: the floor geometry without the print).
  `--clip=play` keeps the project stretch (`canvas_items`, what a player gets); without it the probe
  does what `prologue_film.gd:37` and every film tool do (`CONTENT_SCALE_MODE_DISABLED`).
  `--clip=play64`: also 64 px/m.
- `tools/ground/drift/run_probe.mjs`: launches it through `runGodot` holding `build/n31-godot.lock`.
- `tools/ground/drift/drift.py`: sub-pixel phase correlation on the crop (Rivet masked), per pair
  (t, t+k): floor = `_b` frames, print = `_a - _b`; compared with the logged camera shift in render
  px; a screen-locked layer shows as a peak at (0, 0) (`print_zero_peak`); `--pan` integrates the
  per-tick log over the sprint; `--strip` cuts a world-anchored strip. Tests: `test_drift.py`,
  `run_probe.test.mjs`.

## Result (sprint pan, ticks 2370..2700 = 5.5 s, Rivet 22.7 -> 55.8 m east)

| take | stretch | floor moved (px) | print moved (px) | print drift vs floor, per frame max / mean | per 30 ticks max / mean | over the pan |
|---|---|---|---|---|---|---|
| film path (`CONTENT_SCALE_MODE_DISABLED`, 32 px/m) | 1.0 | -1060.9, -361.1 | -1061, -361 | 0.77 / 0.51 px (images), 1.05 / 0.61 (log) | 1.09 / 0.54 px | **0.12 px** (bounded: rounding only) |
| play path (project `canvas_items`, 32 px/m) | 1.35 | -1432.4, -487.4 | -1061, -361 | 1.97 / 1.32 px (images), 2.06 / 1.30 (log) | 46.4 / 23.1 px | **392 px** (371.4, 126.4) |
| play path, 64 px/m | 1.35 | -2864.9, -974.9 | -2121, -722 | 3.33 / 2.25 px (images), 3.34 / 2.45 (log) | 75.6 / 47.3 px | **786 px** (743.9, 252.9) |

- Floor (`_b`, look off) follows the logged camera to within 0.2 px in every take: the floor, the
  yard paint, the ochre second impression and the over-print layers move with the world.
- The print (`_a - _b`: halftone, grime, paper tooth, the D5 overlay, the actors' item print) follows
  `-world_px` exactly (0.00-0.06 px), never the floor when the window is stretched.
- No layer is screen-locked: `print_zero_peak` during camera motion stays <= 0.031 (noise; a locked
  layer gives 0.3-1.0). LookOverlay's vignette/grain is world-locked too (`look_overlay.gd:102`).
- No zoom ease happens in the prologue take (camera zoom (1.0, 0.9397) on every tick), so suspect 2
  (`_print_px` scalar zoom during an ease) is not exercised here. Suspect 3 (actors' print) is the
  same `world_px` lock (`print_stage.gd:113`), so the dots on Rivet slide with the same 26 %.

## The layer and the cause

The **print pass** (the D4 halftone/grime/paper-tooth over the yard floor, `look_d4.gdshader:106`
`w = FRAGCOORD.xy + world_px`, and every other `FRAGCOORD + world_px` shader: D5 overlay, item print,
light hatch, fx dither). `FRAGCOORD` is in render-target px, but `world_px` is computed in the
viewport's logical px:

- `project/core/render/print_stage.gd:157` `return (camera.position * camera.zoom + _print_off).round()`
  and `:112` `world_px = _print_px() - get_viewport_rect().size * 0.5` ignore the window's stretch
  transform (`project/project.godot:48-50`: 1280x800, `canvas_items`, `expand`;
  `device_profile.gd:182` applies it in play). With stretch s the floor moves s x the camera while the
  print moves 1 x: the print travels WITH the player at (1 - 1/s) of the floor's speed (26 % at
  s = 1.35 here; 44 % at a 2560x1440 fullscreen, s = 1.8).
- Every film and take hides it: `prologue_film.gd:37` (and the film tools) set
  `CONTENT_SCALE_MODE_DISABLED`, s = 1, where the only error left is the 0.5 px rounding swim
  (`print_stage.gd:107` sets the camera unsnapped while `world_px` is rounded).

Gauntlet, measured (log only, `drift_log_probe.gd`, `res://dev/gauntlet/gauntlet.tscn -- --bot=average`
WITHOUT `--pick-view`, because `--pick-view` is its film path and sets `CONTENT_SCALE_MODE_DISABLED`,
`gauntlet.gd:102`): stretch 1.35, 900 frames, the floor moved (-2108.4, -143.3) px, the print
(-1562, -106): **548 px** of print drift with the player over 15 s, per frame max 3.29 / mean 0.92 px.
Same cause. (Log only: in the prologue the log and the images agreed within 0.1 px.)

Quest 1's city: NOT measured. `CityView` builds `world_px` the same way
(`project/features/city/view/city_view.gd:167-171`: snapped in LOGICAL px, `- get_viewport_rect().size * 0.5`),
so by code it shares the cause.

## Proposed fix (next call)

In `PrintStage.place()` (and `CityView`), lock in render px: take `var s: Transform2D =
get_viewport().get_final_transform()`, snap the camera so `camera.position * camera.zoom * s.get_scale()`
is whole, and set `world_px = ((camera.position * camera.zoom + _print_off) * s.get_scale()).round()
- Vector2(get_viewport().get_texture().get_size()) * 0.5`. Bar: 0 px phase drift between print and
floor while the camera moves, at s = 1 and at the play stretch (`drift.py --pan`: drift < 0.5 px over
the 5.5 s pan, per-frame max < 0.5 px), measured with `--clip=play`, not the film path.

## Strip

`C:\Users\kazda\kiro\gtai-masters\n31\ground\item3\prologue_drift_before_play64.png` (ticks 2400, 2401,
2430, 2431, one world box x2 nearest, play stretch; `_play32` and `_film32` beside it). The floor holds
still across the four tiles (rocks, the cable, the blood, the dead worker); the print's grime blotches
and the pale diagonal grime streaks do not: between 2401 and 2430 they shift across the stationary
floor, east, the way Rivet runs (the json: +744 px east over the pan at 64 px/m).

# n31-12 after (item 3 part B): the print lock in render px

Fix `fbe6abf03`: `PrintStage.place()` and `CityView._place_camera()` snap the camera to whole render
px (`PrintStage.snap_cam`: `camera.zoom * get_final_transform().get_scale()`) and set
`world_px = round(cam * zoom * s) - (half * s + origin)` (`PrintStage.lock_px`), so FRAGCOORD +
world_px is one value per world point at any window stretch. Every `world_px` consumer is a
`FRAGCOORD.xy + world_px` phase (no logical-px position use), so no consumer changed.
`PrintStage.PRINT_IN_RENDER_PX = false` is the old logical lock; headless (no render target, the
dummy window's stretch is about 0.05) keeps the old lock too (`PrintStage.in_render_px`).
Same probes, same flags, worktree `fbe6abf03`. Numbers: `prologue_drift_after.json`.

| take | stretch | print drift vs floor over the pan, before -> after | per frame, print vs camera (images, k=1) max, before -> after | per 30 ticks, print vs floor max, before -> after |
|---|---|---|---|---|
| prologue play path, 32 px/m (`--bot --clip=play`) | 1.35 | 392 px -> **0.0001 px** (log, per tick max 0.0002) | 1.97 -> **0.002 px** | 109 -> **0.004 px** (80 pairs with a confident floor peak) |
| prologue play path, 64 px/m (`--clip=play64`) | 1.35 | 786 px -> **0.0003 px** (per tick max 0.0003) | 3.33 -> **0.0015 px** | 277 -> **0.001 px** (70 confident pairs) |
| prologue film path, 32 px/m (stretch off) | 1.0 | 0.12 px -> **0.00002 px** (the 0.5 px rounding swim is gone: the camera is snapped now) | 0.77 -> **0.001 px** | 1.29 -> **0.003 px** |
| gauntlet play path log (`--bot=average`, 900 frames) | 1.35 | 548 px -> **0.0002 px** (per tick max 0.0002) | (log only) | (log only) |

- Bar (< 0.5 px per frame and < 0.5 px over the pan, stretch ON): met in all three play takes.
  Film path: not worse (better).
- Caveat on the per-frame floor figure: the k=1 *floor* correlation in the play takes reads about
  (0, 0) on some pairs (low floor peak, 0.33-0.5), giving a false 4.9 / 9.9 px "print vs floor"
  at k=1; it did the same on every k=1 play pair of the before take. The print follows the logged
  camera to 0.002 px on every k=1 pair and the floor follows the camera at k=30, so the per-frame
  figure above is print vs camera. Large k=30 shifts at 64 px/m also break the floor peak on some
  pairs (0.12-0.23), as before; those are left out of the k=30 column (the json keeps them all).
- Quest 1's city (CityView): same code path, not measured.
- Strip: `C:\Users\kazda\kiro\gtai-masters\n31\ground\item3\prologue_drift_after_play64.png`
  (before row above, after row below; ticks 2400, 2401, 2430, 2431, same world box).
- Scenarios at `fbe6abf03`: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`
  -> `run_scenarios: 68 ran, 0 failed`, exit 0 (render-side change; headless keeps the old lock).
- Strip, by eye: in the after row the grime blotches and pale streaks sit at the same place against
  the rock and the hook between 2400/2401 and between 2430/2431; the 2401 -> 2430 step is partly
  covered by Rivet in the crop, so the hold across it rests on the phase numbers above.
