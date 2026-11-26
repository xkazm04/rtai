# n31 contact ink: same-box re-measure (n31-25)

Takes (gauntlet, `--pick-view`, bot average, wheel, seed 7, 32 px/m, 1080p, tilt 70):
- main: `build/n31/n31-02/s7_32/take.mp4` (ba8e470b0, 2400 ticks)
- after: `build/n31/n31-25/final_32/take.mp4` (HEAD f1689bf31, 2150 ticks, `ContactInk.RINGS`, R_HIPS 0.62, slide 0.08)

Rule, identical for both takes (`tools/ground/contact_ink.py --free`): the darkest 6x3 px box in a 41x29 px window around Rivet's sole point (961, 546) that touches no sprite pixel (saturated or bright pixels dilated 6 px, so no outline, boots, body or blood decal). Floor = median of the same-size free boxes 36-44 px to each side on that row. Skirt step = largest luminance change per px along the row to the right of the core (3 rows, 5 px smoothed), as a share of the floor. `edge_step` = the largest smoothed gradient anywhere in the free window (includes floor dither and the ring of the sprite mask, so it is noisier).
The first re-measure rule (fixed pixel under the boots, 12 px boxes) was dropped: the 12 px boxes land on boots and the pixel moves off the shadow when Rivet lifts.

| tick | dark % main | dark % after | core main -> after | skirt step main -> after (%/px) | edge_step main -> after |
|---|---|---|---|---|---|
| 1330 (air) | 46.3 | 53.9 | 40.1 -> 34.2 | 8.58 -> 6.81 | 8.2 -> 6.9 |
| 1400 (air, higher) | 52.7 | 68.1 | 36.7 -> 24.2 | 7.13 -> 6.89 | 13.3 -> 9.6 |
| 1500 | 47.4 | 53.7 | 39.5 -> 34.3 | 10.74 -> 4.41 | 7.7 -> 7.3 |
| 1700 | 42.2 | 52.8 | 40.6 -> 34.5 | 7.40 -> 4.04 | 11.5 -> 9.0 |
| 1900 | 46.4 | 51.7 | 39.7 -> 34.4 | 5.67 -> 4.24 | 9.9 -> 6.2 |
| 2000 (corpse + blood in window) | 46.8 | 49.6 | 38.3 -> 36.9 | 2.04 -> 1.54 | 16.1 -> 17.0 |
| 2080 (corpse + blood) | 45.1 | 51.0 | 39.8 -> 35.4 | 3.12 -> 2.92 | 17.1 -> 7.8 |
| 2100 (blood) | 44.1 | 50.0 | 38.0 -> 34.2 | 7.68 -> 3.63 | 15.2 -> 12.1 |
| 2140 | 41.0 | 48.5 | 41.5 -> 35.5 | 6.72 -> 4.35 | 9.8 -> 9.0 |
| **median** | **46.3** | **51.7** | 39.7 -> 34.4 | **7.13 -> 4.24** | 11.5 -> 9.0 |

No tick was in a standing pose in this take; tick 1330 and 1400 are Rivet in the air (the lift answer: the shadow stays on the ground, shrinks and darkens less).
Disqualified for the edge bars: 2000, 2080, 2100 (a corpse and a red blood decal inside the window: the gradient is the decal, `edge_step` 12-17 % on both takes); 1330 and 1400 (airborne, the skirt is cut short by the lift). The clear-floor ticks are 1500, 1700, 1900, 2140.

Cop at tick 320 (old fixed-box rule, the same pixel (1445, 674) on both takes, `build/n31/n31-22/cop_{main,after}.json`): core darkening vs floor 40 px 41.5 % -> 51.6 %. Its edge step reads 97-108 % because the box sits on the cop's body edge: disqualified, not measured. No card foe was re-measured (the `a3_card` take was not re-read with the new rule).

## Bars
- Core darkening >= 35 % vs floor: PASS on both takes (median main 46.3 %, after 51.7 %). Main already read about 46 % darker on this rule: the brief's "barely visible" premise is not borne out in luminance. The change is +5.4 points at the median (+15 points in the air at tick 1400), the core 39.7 -> 34.4, and the shadow is wider (about 4 px lower and 10 px wider).
- Edge < 6 %/px: PASS on the skirt row profile on the clear-floor ticks (median 4.2, max 4.4 after; main 7.1, over at 3 of 4). The 2-D `edge_step` is above 6 % on all ticks but includes dither and sprite rim; it is not a clean measure.
- Not measured: the card foe; unit tests: `test_contact_ink`, `test_rig_cast_shadows`, `test_card_contact_shadow`, `--changed` (see the report).
