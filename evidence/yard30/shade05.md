# n30-01 shade05: `over_print_shade` 0.5 in `arched_line`

Change: one key in `project/data/tables/prologue_yard_dressings.json` (`"over_print_shade": 0.5`, owner's n29 pick), commit `31838bbae`; its two pins updated (`test_prologue_yard_overprint.gd`: the arched_line plan reads 0.5 and wrecks draw in grey 0.5; `test_prologue_raised_line.gd`: arched_line alone carries the key). Pilots seeds 7, 3, 11, 21, 42 in one Godot process: ticks, deaths, min_hp, stuck and sha256 IDENTICAL to `evidence/yard29/prologue-yard-pilots-props.json` (`evidence/yard30/prologue-yard-pilots-shade05.json`).

Method: `evidence/yard30/prop_contrast30.py` (n29's `prop_contrast.py`: row `at`/`size_m` boxes, art alpha pixels, 1 m ring, Rec.709 linear luminance) on mid camera, 32 px/m, tick 300, seed 7. Looks: i20 = `c649a15d6` (n29's own i20 still, reproduced to 4 digits), today = `5114a4441` (shade 1.0), after = HEAD with 0.5. Forklift colour: mean CIELAB (D65) of the forklift's alpha pixels.

| prop | i20 | today (1.0) | 0.5 | today / i20 | 0.5 / i20 |
|---|---|---|---|---|---|
| forklift (burnt_pickup) | 0.1544 | 0.0851 | 0.1705 | 55 % | 110 % |
| scrap_skip | 0.2257 | 0.1050 | 0.2117 | 47 % | 94 % |
| fallen_fridges | 0.1451 | 0.0426 | 0.1446 | 29 % | 100 % |

| forklift look | L* | a* | b* | C* | hue deg |
|---|---|---|---|---|---|
| i20 | 31.0 | 9.0 | 19.4 | 21.4 | 65.1 |
| today (1.0) | 40.3 | 9.0 | 24.3 | 25.9 | 69.6 |
| 0.5 | 26.1 | 6.9 | 19.1 | 20.3 | 70.1 |

Hue barely moves (69.6 -> 70.1 deg; the plate's forklift is yellow at 80 to 95 deg, so both sit about 10 to 25 deg toward orange, the over-print sampling mixes the dark linework in). What 0.5 changes is lightness and chroma: L* 40 -> 26 (darker than i20's 31) and C* 26 -> 20 (about i20's 21). The forklift reads as dark ochre, near i20 in chroma, a little darker in lightness.

Seen: the forklift is dark ochre with its yellow still recognisable at 64 px/m; the skip's rust frame is deep orange and its white appliances go grey; the fridge bank is a grey readable bank with the same linework (no longer pale-on-pale); the belt spans above stay bright. In the 23 s film (tick 1757..3136) the three props keep the shade the whole way; the luminance contrast of forklift is 110 % of i20, so slightly over i20 (the forklift sits on the lighter floor).

Stills: `shade05_before_after_mid_32ppm.png` (today | 0.5, full frames), `shade05_before_after_64ppm.png` (top: mid camera, forklift and skip; bottom: front camera, fridge bank; the two cannot share one 64 px/m camera, 21 m apart). Film: `gtai-masters/n30/yard/shade05_before_after_mid_32ppm.mp4`.
