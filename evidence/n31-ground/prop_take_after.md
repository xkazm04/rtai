# Prop take after (n31-24, item 4): Rivet walks at the props, main `ba8e470b0` -> HEAD `c46b88ccc`

Driver `node tools/ground/prop_take.mjs --rev=<rev> --arena=yard|gauntlet --out=<dir>` (plus `--ppm=64 --only=<probe index>` for the 64 px/m stills), table by `node tools/ground/prop_take_report.mjs --arena=<a> --before=<dir> --after=<dir>`. Same probes, same tool, both revs: Rivet walks at each prop with the real move actions, tilt 70, 1920x1080, 32 px/m, holds a second against what stopped him, then walks back. Probes are placed from the rev's OWN solid rects (the arena walls): the solid nearest the dressing box within 2 m plus every solid touching it (legs, supports), lane slid clear of other solids; the probe prints which. Rivet radius is read from the sim body in each take: 0.6 m on both revs (the earlier header's 0.45 was wrong).

Bar: |m - radius| <= 0.25 m, where m = base_m (stop to the visible PropBase pad = the collision box edge) for the gauntlet on HEAD, stop_m (stop to the drawn art edge) elsewhere; on main the gauntlet has no pad, so it is judged on stop_m. A pass probe passes when he walks through. The two fixtures sit behind the building wall (unreachable, `n/a`, decision n31-19: not built).

Films (masters `item4\`): `prop_walk_yard_32.mp4` 24.0 s, `prop_walk_gauntlet_32.mp4` 22.6 s (main left, HEAD right, ffprobe). Stills `prop_walk_{yard,gauntlet}_64_stop.png` (main | HEAD, 64 px/m, conveyor_return from E and market_stalls#3 from W).

## yard

| probe | before stop_m | before base_m | before bar | after stop_m | after base_m | after bar (judged on) | radius before / after | placed from (after) |
|---|---|---|---|---|---|---|---|---|
| conveyor_door from S | 0.04 |  | FAIL | 0.6 |  | pass (stop_m) | 0.6 / 0.6 | own rect #8, centre 0.00 m from the dressing box, joined by 2 touching solids (legs, supports) |
| conveyor_turn from W | -1.051 |  | FAIL | 0.314 |  | FAIL (stop_m) | 0.6 / 0.6 | own rect #10, centre 0.00 m from the dressing box, joined by 2 touching solids (legs, supports) |
| conveyor_return from E | -0.924 |  | FAIL | 0.371 |  | pass (stop_m) | 0.6 / 0.6 | own rect #11, centre 0.00 m from the dressing box, joined by 2 touching solids (legs, supports) |
| fuel_vessel from N | 1.068 |  | FAIL | 0.611 |  | pass (stop_m) | 0.6 / 0.6 | own rect #15, centre 0.00 m from the dressing box |
| arch_feed walk under at x 34.3 | -0.03 |  | pass | -0.03 |  | pass (walked through) | 0.6 / 0.6 | start as given |
| span_door_feed walk under at x 35.275 | -0.021 |  | pass | -0.021 |  | pass (walked through) | 0.6 / 0.6 | start as given |
| drag_door walk along | -0.081 |  | pass | -0.081 |  | pass (walked through) | 0.6 / 0.6 | start as given |
| belt_feed walk along | -0.028 |  | pass | 0.52 |  | FAIL (blocked) | 0.6 / 0.6 | start as given |

Bar passes: before 4/8, after 6/8 (n/a = fixture behind the building wall, not counted).

## gauntlet

| probe | before stop_m | before base_m | before bar | after stop_m | after base_m | after bar (judged on) | radius before / after | placed from (after) |
|---|---|---|---|---|---|---|---|---|
| kiosk_plaza#2:cover_high from W | 1.478 |  | FAIL | 1.475 | 0.6 | pass (base_m) | 0.6 / 0.6 | own rect #13, centre 0.00 m from the dressing box |
| kiosk_plaza#2:cover_high from E | 2.055 |  | FAIL | 2.054 | 0.6 | pass (base_m) | 0.6 / 0.6 | own rect #8, centre 0.00 m from the dressing box |
| market_stalls#3:cover_low from W | 1.201 |  | FAIL | 1.613 | 0.6 | pass (base_m) | 0.6 / 0.6 | own rect #14, centre 0.00 m from the dressing box |
| market_stalls#6:cover_low from E | 1.224 |  | FAIL | 1.636 | 0.6 | pass (base_m) | 0.6 / 0.6 | own rect #11, centre 0.00 m from the dressing box |
| plain_block#3:cover_low from W | 0.712 |  | pass | 0.64 | 0.6 | pass (base_m) | 0.6 / 0.6 | own rect #13, centre 0.00 m from the dressing box |
| plain_block:payphone@11,-6.7 walk at it | 1.3 |  | n/a | 1.3 |  | n/a (behind the building wall) | 0.6 / 0.6 | start as given |
| plain_block:street_sign@22,-6.6 walk at it | 1.2 |  | n/a | 1.2 |  | n/a (behind the building wall) | 0.6 / 0.6 | start as given |

Bar passes: before 1/5, after 5/5 (n/a = fixture behind the building wall, not counted).

## Reading
- Yard: the three conveyor stops and the fuel vessel were 1.05 / 0.92 INSIDE the art, 0.04 and 1.07 short; on HEAD conveyor_door 0.60, conveyor_return 0.37, fuel_vessel 0.61 sit at the drawn edge (3 of 4 inside the bar, from 0 of 4). conveyor_turn from W reads 0.314 (0.286 off the radius, 0.04 outside the bar): he stops at the first solid on his lane (the conveyor's leg, group of 3 solids); the 0.29 m gap to the radius is not investigated further. Left as a FAIL, not tuned.
- Yard belt_feed "walk along" was a pass on main and now stops (0.52): one of the arch supports n31-19 made solid stands on that debris lane. That is the rule working (a support is a thing), but a lane that used to be open is now blocked; reported, not changed.
- Gauntlet: collision did not move (stop distances are the same on both revs except the stalls, whose stop_m grew 0.41 because the drawn edge moved: the stall cards now stand on their boxes); the visible cue changed: the dark PropBase pad IS the box, so on HEAD all 5 covers stop at the pad's edge (base_m 0.6 each) where main stopped 0.7-2.1 m short of the drawn base. Against the art itself (the post/wheels of kiosk and stalls) he still stops 1.5-2.05 m short: the art did not move to the collision, the collision got drawn.
- The opening line box of the yard encounter is now hidden in the take (probe swaps the view's HUD feed; no prologue edit).

## Soft base re-shoot (n31-31)

HEAD `88bc88996` (base_soft; the gauntlet take ran at `ef1b356f8`, only JOURNAL/REPORT newer, no product change). The n31-24 stills and film showed the old hard PropBase pad; re-shot with the same tool and flags on the softened base, main halves reused from the n31-24 takes (`ba8e470b0`, same probes and stop tick).
- Re-shot: `prop_walk_yard_64_stop.png` (conveyor_return from E, `--ppm=64 --only=2`), `prop_walk_gauntlet_64_stop.png` (market_stalls#3 from W), `prop_walk_yard_32.mp4` (24.0 s, 1920x1080 60 fps, ffprobe). `prop_walk_gauntlet_32.mp4` NOT re-shot (kept the old hard-base film).
- stop_m on HEAD, equal to the n31-24 HEAD numbers (collision did not change): conveyor_return 0.371; market_stalls#3 stop_m 1.613, base_m 0.6. Yard 32 px/m, all 8 probes identical to n31-24: conveyor_door 0.6, conveyor_turn 0.314, conveyor_return 0.371, fuel_vessel 0.611, arch_feed -0.03, span_door_feed -0.021, drag_door -0.081, belt_feed 0.52.
- Looked at both stills: Rivet's feet at the pad edge, soft contact shade visible on HEAD.
