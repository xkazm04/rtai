# Prop take before (n31-21, item 4): Rivet walks at the props, main `ba8e470b0`

Probe scene `project/dev/ground_n31/prop_walk.gd`, driver `node tools/ground/prop_take.mjs --rev=ba8e470b0 --arena=yard|gauntlet --out=<dir>`. Rivet is placed 3-5 m from the prop and walks straight at it with the game's own input path (Input move_up/down/left/right pressed, sampled by LiveInput into TickInput), one sim tick per frame, tilt 70, 32 px/m, 1920x1080 60 fps. The gauntlet runs with the GauntletWaves hook removed (no foes, no hold). Per probe the stop is logged when he has not moved 4 mm for 14 ticks.

`stop_m` = metres from Rivet's ground point (his centre, collision radius 0.6 m) to the DRAWN base edge of the side he walked at, signed along his heading: negative = he stopped inside the drawing, positive = an invisible wall before the art. The drawn edge is the audit's (box side minus mismatch: yard `prop_audit_before.json` flat art, gauntlet `prop_audit_strip.json` tilt70 strip cards), so a gauntlet stall reads the base band the audit measures, not the card's roof. A perfect footprint reads +0.6 (his radius). Pass probes: stop_m is the distance short of the prop's centre line, "passed" means he crossed it.

Films (build/n31/n31-21, scratch): before_yard/take.mp4 (752 frames), before_gauntlet/take.mp4 (603 frames), one still per probe at its stop tick (still_NN_*.png), stops.json, walk.jsonl (tick, rivet_m, probe).

## Yard (prologue_yard_dressings arched_line)
| probe | arena | expect | verdict | stop_m | walked m | box edge | drawn edge | reading |
|---|---|---|---|---|---|---|---|---|
| conveyor_door from S | yard | stop | stopped | 0.04 | 3.9 | 1.2 | 1.76 | at the drawn edge |
| conveyor_turn from W | yard | stop | stopped | -1.051 | 3.4 | 31.4 | 29.749 | stopped INSIDE the drawing |
| conveyor_return from E | yard | stop | stopped | -0.924 | 4.715 | 32.1 | 33.624 | stopped INSIDE the drawing |
| fuel_vessel from N | yard | stop | stopped | 1.068 | 2.6 | 28.7 | 29.168 | invisible wall, short of the art |
| arch_feed walk under at x 34.3 | yard | pass | passed | -0.085 | 3.664 |  | 3.382 | passed through |
| span_door_feed walk under at x 35.275 | yard | pass | passed | -0.092 | 4.447 |  | 1.2 | passed through |
| drag_door walk along | yard | pass | passed | -0.081 | 6.581 |  | 29.75 | passed through |
| belt_feed walk along | yard | pass | passed | -0.095 | 7.227 |  | 32.18 | passed through |

## Gauntlet street (tilt70 strip card edges, seed 1, segments streamed in order)
| probe | arena | expect | verdict | stop_m | walked m | box edge | drawn edge | reading |
|---|---|---|---|---|---|---|---|---|
| kiosk_plaza#2:cover_high from W | gauntlet | stop | stopped | 1.478 | 2.9 | 16 | 16.878 | invisible wall, short of the art |
| kiosk_plaza#2:cover_high from E | gauntlet | stop | stopped | 2.055 | 3.212 | 20 | 18.545 | invisible wall, short of the art |
| market_stalls#3:cover_low from W | gauntlet | stop | stopped | 1.201 | 3.18 | 7.85 | 8.451 | invisible wall, short of the art |
| market_stalls#6:cover_low from E | gauntlet | stop | stopped | 1.224 | 3.212 | 24.15 | 23.526 | invisible wall, short of the art |
| plain_block#3:cover_low from W | gauntlet | stop | stopped | 0.712 | 2.9 | 6.75 | 6.862 | invisible wall, short of the art |
| plain_block:payphone@11,-6.7 walk at it | gauntlet | pass | stopped | 1.3 | 2.3 |  | -6.7 | invisible wall, short of the art |
| plain_block:street_sign@22,-6.6 walk at it | gauntlet | pass | stopped | 1.2 | 1.993 |  | -6.6 | invisible wall, short of the art |

## Reading
- Yard conveyors: from the west he stops 1.05 m and from the east 0.92 m INSIDE the belt/machine drawing (the art is 1.5-1.7 m wider than the box each side); from the south he stops at the drawn base (0.04 m short) because his 0.6 m radius makes up the 0.56 m the box sits north of the drawn base. Frames confirmed: still_01 and still_02 show Rivet standing against the belt art, his body overlapping it.
- Fuel vessel from the north: 1.07 m short of the drawn base (the drawing starts 0.47 m inside the box on the north).
- Arches and spans (arch_feed, span_door_feed) and both debris rows (drag_door, belt_feed): he walks through, as the audit said.
- Gauntlet: every cover he walks at stops him 0.7-2.1 m short of the drawn base edge (kiosk 1.48 W / 2.06 E, stalls 1.20 / 1.22, plain_block bench 0.71). The two standing fixtures (payphone, street_sign) sit in the building-front wall band (y -6.7 / -6.6): he is stopped by the wall at y -5.4, 1.2-1.3 m before them, so on this street a fixture is not a thing he can walk into at all. The yard top edge is y ~0.6 (span walk starts are clamped to 1.2).
- The yard film keeps the encounter's opening line box on screen (the encounter hook is dropped but the line view stays); the lower third of each yard still is covered by it.
