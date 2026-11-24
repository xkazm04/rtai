# pair_dash: what hits Rivet after 10 seconds

Tool: `project/dev/gauntlet/pressure_dash_trace.gd` (`node tools/dev/run.mjs pressure_dash_trace -- --out=<abs file> [--seeds=3,5,1]`), the same `pair_dash` take (`PressureTake`, seeds 1 to 10), headless. It logs every HP drop after tick 600 with the source split of `PressurePair` (direct / splash / other), Rivet's motion phase, where he stood against the 10 m circle and each trooper, the dash cooldown, and every dash press the game refused. Raw output: `dash_late_trace.md` (seeds 3, 5, 1, the table below) and `dash_late_trace_all.md` (seeds 1 to 10).

## Cause, in plain words

**The dash saves him from the first rocket of each volley and from nothing else.** The two troopers fire in a volley of two rockets, but not at the same moment: in seed 1 they leave one tick apart, so one dash covers both; in every other seed the second rocket leaves 8 to 49 ticks after the first (seed 3: 26, then 23, then 49 ticks; seed 5: 19, then 36). A dash takes 10 ticks and the game then refuses another for 40 more (a new dash only every 50 ticks), so the press for the second rocket is always refused, in cooldown (seed 3: 1 tick short; seed 5: 13 ticks short), and Rivet keeps running his circle. Most of those second rockets burst 3 to 3.5 m away and only graze him (1 to 2 HP). After 10 s in seeds 3 and 5 the troopers drift (their midpoint moved 1.4 to 3.4 m from where they started) and the second rocket leaves 36 to 49 ticks after the first, when Rivet is back in his steady run, and it bursts 0.6 to 2.2 m from him: 9 to 20 HP a time. All late losses are splash or a single direct burst, none is "other", and in every row of seeds 3 and 5 he is on the circle (within 0.7 m of it) in his normal free run, not mid-dash.

So: not a fault in the bot or the game. It is the dash cooldown (50 ticks) being longer than the gap between the two rockets. In 10 seeds over 25 s he loses 3.3 to 7.8 HP in 8 seeds and 48.4 and 40.4 HP in seeds 3 and 5 (the pooled rocket count is unchanged: 13 dashes in every seed). "Dash across each line = safe" holds for the first rocket of a volley only; the second is safe only when it leaves within a tick of the first (seed 1) or lands wide.

I did not change the take. A retry of the refused press would rescue seed 3 (1 tick short) but not seed 5 (13 ticks short), and it would change what the bot profile `average` (`dash_read_ticks`) does, so the existing film would no longer show the shipped behaviour.

## Seeds 1 to 10: gap between the two rockets of a volley, and what it cost

| seed | gap between the two rockets of a volley (ticks, as launched) | late drops | HP lost after 10 s |
|---:|---|---:|---:|
| 1 | 1 throughout | 3 | 3.3 |
| 2 | 13 throughout | 3 | 3.9 |
| 3 | 26 (6 volleys), 23 (2), then 49 (3) | 4 | 48.4 |
| 4 | 26 (6 volleys), 24 (2), then 38 (3) | 3 | 7.8 |
| 5 | 19, then 36 | 6 | 40.4 |
| 6 | 19, 16, then 8 | 2 | 4.1 |
| 7 | 10 throughout | 3 | 4.1 |
| 8 | 23, 14, then 12 | 2 | 3.3 |
| 9 | 14 throughout | 3 | 4.7 |
| 10 | 13 throughout | 3 | 3.4 |

Gaps are read off the launch ticks in `dash_late_trace_all.md` (the within-volley gaps; the 88 to 98 tick gaps are between volleys). Seed 4's gap also grows to 38 after tick 1100 but costs only 7.8 HP (its drops were not traced one by one; the burst distances were not compared). Seeds 6 and 8 end on gaps of 8 to 12; the others stay at one short gap.

## Per-drop table (seeds 3 and 5 lose the most, seed 1 for contrast)

## seed 3

HP at 10 s 97.6, HP at end 49.1; 2 drops up to 10 s, 4 after.

| tick | HP lost | source | phase | dash cooldown | off circle (m) | trooper A (m) | trooper B (m) | circle centre moved (m) | burst from Rivet (m) | rocket launched | presses refused so far |
|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 680 | 1.7 | splash | FREE | 5 | +0.1 | 9.4 | 10.9 | 1.4 | 3.3 | tick 646 | 6 |
| 1186 | 17.4 | splash | FREE | 0 | +0.1 | 11.7 | 8.6 | 3.0 | 1.0 | tick 1151 | 9 |
| 1316 | 9.3 | splash | FREE | 0 | +0.0 | 8.4 | 11.7 | 3.3 | 2.2 | tick 1265 | 10 |
| 1409 | 20.0 | direct | FREE | 0 | +0.1 | 12.4 | 7.9 | 3.4 | 0.6 | tick 1379 | 11 |

- tick 92: dash press refused, cooldown 23 ticks left
- tick 206: dash press refused, cooldown 23 ticks left
- tick 320: dash press refused, cooldown 23 ticks left
- tick 434: dash press refused, cooldown 23 ticks left
- tick 548: dash press refused, cooldown 23 ticks left
- tick 662: dash press refused, cooldown 23 ticks left
- tick 776: dash press refused, cooldown 26 ticks left
- tick 890: dash press refused, cooldown 26 ticks left
- tick 1167: dash press refused, cooldown 0 ticks left
- tick 1281: dash press refused, cooldown 0 ticks left
- tick 1395: dash press refused, cooldown 0 ticks left

Rocket launches: 50, 76, 164, 190, 278, 304, 392, 418, 506, 532, 620, 646, 737, 760, 851, 874, 988, 1102, 1151, 1216, 1265, 1330, 1379, 1444

Dashes started: 66, 180, 294, 408, 522, 636, 753, 867, 1004, 1118, 1232, 1346, 1460

## seed 5

HP at 10 s 99.9, HP at end 59.4; 1 drops up to 10 s, 6 after.

| tick | HP lost | source | phase | dash cooldown | off circle (m) | trooper A (m) | trooper B (m) | circle centre moved (m) | burst from Rivet (m) | rocket launched | presses refused so far |
|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 893 | 1.3 | splash | FREE | 28 | +0.6 | 12.3 | 9.0 | 1.2 | 3.4 | tick 856 | 7 |
| 1134 | 14.6 | splash | FREE | 1 | +0.2 | 9.0 | 11.5 | 1.8 | 1.4 | tick 1106 | 8 |
| 1259 | 11.2 | splash | FREE | 0 | -0.1 | 10.5 | 9.7 | 1.9 | 1.9 | tick 1220 | 9 |
| 1332 | 1.0 | splash | FREE | 31 | +0.4 | 12.2 | 8.7 | 1.9 | 3.5 | tick 1298 | 9 |
| 1447 | 0.6 | splash | FREE | 30 | -0.7 | 9.6 | 9.3 | 1.6 | 3.5 | tick 1412 | 10 |
| 1481 | 11.7 | splash | FREE | 0 | -0.0 | 9.6 | 10.4 | 1.8 | 1.8 | tick 1448 | 11 |

- tick 93: dash press refused, cooldown 30 ticks left
- tick 207: dash press refused, cooldown 30 ticks left
- tick 321: dash press refused, cooldown 30 ticks left
- tick 435: dash press refused, cooldown 30 ticks left
- tick 663: dash press refused, cooldown 30 ticks left
- tick 777: dash press refused, cooldown 30 ticks left
- tick 891: dash press refused, cooldown 30 ticks left
- tick 1122: dash press refused, cooldown 13 ticks left
- tick 1236: dash press refused, cooldown 13 ticks left
- tick 1350: dash press refused, cooldown 13 ticks left
- tick 1464: dash press refused, cooldown 13 ticks left

Rocket launches: 58, 77, 172, 191, 286, 305, 400, 419, 533, 628, 647, 742, 761, 856, 875, 992, 1070, 1106, 1184, 1220, 1298, 1334, 1412, 1448

Dashes started: 74, 188, 302, 416, 549, 644, 758, 872, 1008, 1086, 1200, 1314, 1428

## seed 1

HP at 10 s 98.9, HP at end 95.5; 1 drops up to 10 s, 3 after.

| tick | HP lost | source | phase | dash cooldown | off circle (m) | trooper A (m) | trooper B (m) | circle centre moved (m) | burst from Rivet (m) | rocket launched | presses refused so far |
|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 686 | 1.6 | splash | FREE | 30 | +1.1 | 10.2 | 12.0 | 0.7 | 3.4 | tick 651 | 6 |
| 1143 | 0.7 | splash | FREE | 29 | +0.8 | 10.4 | 11.2 | 1.2 | 3.5 | tick 1107 | 10 |
| 1373 | 1.0 | splash | FREE | 27 | +1.0 | 10.6 | 11.4 | 1.2 | 3.4 | tick 1335 | 12 |

- tick 98: dash press refused, already mid-dash
- tick 212: dash press refused, already mid-dash
- tick 326: dash press refused, already mid-dash
- tick 440: dash press refused, already mid-dash
- tick 554: dash press refused, already mid-dash
- tick 668: dash press refused, already mid-dash
- tick 782: dash press refused, already mid-dash
- tick 896: dash press refused, already mid-dash
- tick 1010: dash press refused, already mid-dash
- tick 1124: dash press refused, already mid-dash
- tick 1238: dash press refused, already mid-dash
- tick 1352: dash press refused, already mid-dash
- tick 1466: dash press refused, already mid-dash

Rocket launches: 81, 82, 195, 196, 309, 310, 423, 424, 537, 538, 651, 652, 765, 766, 879, 880, 993, 994, 1107, 1108, 1221, 1222, 1335, 1336, 1449, 1450

Dashes started: 97, 211, 325, 439, 553, 667, 781, 895, 1009, 1123, 1237, 1351, 1465

