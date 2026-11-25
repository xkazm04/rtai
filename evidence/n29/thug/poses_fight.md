# Robot thug A (n29): poses still at 64 px/m and the 32 px/m fight, after the shoe foot-line fix

Row `robot_thug` stays `enabled: false`; both dev scenes force it on in their own process
(`CastMulroneyPreview.enable`). Cutter fix: commit `588c7b706` (`footline.md`).

## Still: `C:\Users\kazda\kiro\gtai-masters\n29\cast\thug_poses_64ppm_tilt70.png`
`project/dev/cast/cast_thug_poses.tscn` (windowed 1920x1080, d3d12): patrol cop (rig), Rivet, then five
thugs facing down-right, each held by the live card path for 40 ticks: wind-up (`tell_left` above the
lock), lunge (`tell_left` = the game's enemy lock, `GuardTell.from_table`), snap (claw shot tick = now),
hit (`hurt_tick` 8 ticks back: hit row, flash over), fall rest (hp 0). Logged rows: attack/0, attack/1,
attack/2, hit/0, fall/2, facing column 1 (down-right) each: `thug poses pass true`.
Looked at (2x crops of the feet): wind-up, lunge and snap: both shoes stand on the upper half of the
contact shadow, the claw (lunge tips, snap fist) reaches below / in front of the shoes as drawn; hit: the
support shoe on the shadow; fall rest: the body lies on its ground point, the boots' lower edge on the
shadow. No pose floats.

## Clip: `C:\Users\kazda\kiro\gtai-masters\n29\cast\thug_fight_32.mp4`
`node tools/film/cast_thug_films.mjs C:/Users/kazda/kiro/gtai-masters/n29/cast` (scratch project, viewport
1920x1080, `project/dev/cast/cast_thug_fight.tscn`). ffprobe: h264, 1920x1080, 60/1, 1201 frames,
20.017 s. Rivet (pistol, hp 999) against three thugs (hp 3) walking in to spots around him; each gets
two claw rounds 300 ticks apart, scripted like the gunner film (tell for `telegraph_ticks`, then the claw's
shot tick = the snap, the first harmful tick); Rivet's pistol answers each, then kills.
Frame n shows tick n + 1 (the snap logged at tick 218 is first drawn in frame 217).

| Point | Ticks (frames) | Verdict |
|---|---|---|
| Tell before the first harmful tick, thugs 1/2/3 | 48 / 48 / 48 ticks (= `telegraph_s` 0.8) | PASS |
| Thug 1 round 1 | wind-up 170-206 (169-205), lunge 207-217 (206-216), snap 218 (217), recover 219-224 (218-223) | reads in order |
| Hit hold, all six hits | 12 ticks each (0.20 s), then back to the stand | PASS |
| Hit flash (the sonnet builder's live-path fix `c0a1b816e` landed first) | thug 1 hit at tick 289: frame 288 the washed-out flash + the pistol spark, frame 296 the hit drawing in colour, frame 300 standing | shows |
| Fall reaches rest | thug 1 fall/0 617, fall/1 627, rest 639 (frame 638) and stays; thug 2 rest 765; thug 3 rest 891 | PASS |

Ten frames looked at (crops at 2x, `build/look/n29-thug/frames/`): 140 (walk in), 190 (thug 1 wind-up,
claw far back), 212 (lunge, claw at full reach), 217 (snap, claw closed at Rivet's gun), 218 (recover),
288 (hit flash), 296 (hit), 300 (back to stand), 640 (thug 1 at rest, power-down smoke), 1000 (all three
at rest). Shoes against the shadow at 32 px/m: wind-up, lunge, snap (right facing) stand on it; hit: the
shadow is faint under the hit drawing at this size, no visible gap; fall rest: the boots end on the
shadow's upper half. By eye, not a tool number: thug 3 standing in the down facing after its walk-in
(frame 640, the planted8 stand held by `_hold_stop`) shows its shoes about 8 to 10 px above the shadow
centre, under its low claw; the walk placement is not this call's scope (feet audit in `feet_size.md`).

Reproduce: APPDATA / GODOT_BIN as in the brief; still: `runGodot(['--rendering-driver','d3d12',
'--windowed','--position','0,1440','--resolution','1920x1080','res://dev/cast/cast_thug_poses.tscn'])`
(writes `build/look/n29-thug/poses/`); clip: the film tool above.
