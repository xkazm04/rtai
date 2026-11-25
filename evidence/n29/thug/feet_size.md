# Robot thug A card (n29): measured feet and size, row still off

Row `robot_thug` in `project/data/tables/cast_cards.json` stays `enabled: false`; every number below is
from a dev process that forces the row on (`GTAI_CAST_PREVIEW=robot_thug` through `cast_feet.gd`, or
`CastMulroneyPreview.enable` in `cast_thug_beside.gd`). Walk = `robot_thug_planted8_armed_walk.png`
placed by `CastThugAnchors` (`tools/art/cast_thug_soles.py`), `body_scale` 1.45, step 0.2841 m per
drawing (measured 0.1959 m at 1.7 m, times body_scale), his `enemies.json` walk 2.4 m/s.
Screen px at 32 px/m unless stated.

| Point | Number | Bar | Verdict |
|---|---|---|---|
| Support sole travel over a contact, walk, 70 right / down-right | 0.00 / 0.00 px (4 contacts each) | <= 2 px | PASS |
| Support sole travel, walk, 55 right / down-right | 0.00 / 0.00 px | <= 2 px | PASS |
| Body jump between consecutive rendered frames, walk, 70 right / down-right | 9.60 / 9.45 px | <= 12 px | PASS |
| Body jump, walk, 55 right / down-right | 9.60 / 8.66 px | <= 12 px | PASS |
| Body jump, stop (walk then halt), 70 right / down-right; 55 right / down-right | 9.60 / 9.45; 9.60 / 8.66 px | <= 12 px | PASS |
| Body jump, turn (90 deg over 20 ticks while walking), 70; 55 | 9.60 / 9.45; 9.60 / 8.80 px | <= 12 px | PASS |
| Body jump, reversal (aim one way, step the other), 70; 55 | 9.60 / 9.45; 9.60 / 9.07 px | <= 12 px | PASS |
| Drawings per second, walk 2.4 m/s (both pitches, both facings) | 8.45 expected, 8.44 observed | 5 to 10 | PASS (12.25 before the step was scaled by body_scale: FAIL) |
| Height at 64 px/m, 70 deg, front three-quarter, standing, in the delivered beside frame (silhouette, shadow hidden) | thug 144, Rivet 154, spawned rig patrol cop 86 (its build variety 0.85) | 0.90 to 1.00 of Rivet, never taller | PASS (0.935) |
| Height at 32 px/m, 70 deg, same frame set | thug 72, Rivet 77, patrol cop 43 | 0.90 to 1.00 of Rivet, never taller | PASS (0.935) |

Notes
- The silhouette height runs from the head (row 421) to the claw tip (~row 562 at 64 px/m; the tool's run
  ends at 564): in the down and down-right facings his big claw hangs in front of his feet, ~22 px below his
  ground point (row 540). The shoes end roughly 15 to 20 px higher than the claw tip (read off the frame by
  eye, not a tool number), so head to shoe is roughly 0.8 of Rivet. The claw is drawn nearer the camera
  than the shoes, so in the still it reads as held low in front of him, not as sinking into the street.
- The cut sheets anchor the lowest opaque point (the claw tip) on the cell's foot line at 70 deg, so the
  shoes sit 10 to 30 texels above it in the down / down-right cells. The anchored walk plants the measured
  shoe (claw cut out of the sole search in `cast_thug_soles.py`), so the walk is unaffected; the padded
  attack / hit sheets stand on the cell foot line and so on the claw tip. Not measured here (shipped PNGs are
  out of scope this call).
- Not covered: speeds other than his 2.4 m/s walk (he has no run), ink, rim, shadow, palette, the attack tell /
  hit / fall films.

Reproduce (APPDATA and GODOT_BIN as in the n28 thug brief):
- feet: `GTAI_CAST_PREVIEW=robot_thug node tools/art/cast_feet.mjs build/look/n29-thug/feet32 32 robot_thug`
- stop / turn / reversal: `res://dev/cast/cast_thug_turns.tscn` per pitch with `GTAI_CAST_PREVIEW=robot_thug
  GTAI_CAST_SUBJECT=robot_thug GTAI_CAST_PPM=32 GTAI_CAST_PITCH=<70|55> GTAI_CAST_OUT=<abs dir>`, then
  `python tools/art/cast_gunner_transitions.py <dir>`
- size: `res://dev/cast/cast_thug_beside.tscn` (windowed, 1920x1080), then
  `python tools/art/cast_size_measure.py build/look/n29-thug/size`
- still: `C:\Users\kazda\kiro\gtai-masters\n29\cast\thug_beside_64ppm_tilt70.png` (= `build/look/n29-thug/size/robot_thug_64.png`)
