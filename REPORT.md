# REPORT lane yard, run n28 (2026-11-24): the fourth pass `arched_line` (tall arched belt, warmer floor, burning hall mouth)

DRAFT (session 4, 21:10): the gate, masters and the default decision are filled in by session 5/6.

Branch `n28-yard`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, cut from `main` `d0ab9d03a`. Director: Claude Opus. Builder: Claude Sonnet 5.5. One call ran through `gtai-n28/tools/builder.mjs` until the builder account hit its weekly limit at 17:44. Every call after that was an in-session Sonnet subagent working from the same brief files (see the Builder ledger). IMAGES 5/25.

**Gate:** TODO (`node tools/gate/run.mjs --rev=HEAD`).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. A darker warm floor (in part) | `46146133b`, `027bacffa`, `65ef46c3b`; `evidence/yard28/floor_sweep.txt` (TINT, CHROMA, ART, LIFT, IMPRESSION sweeps); `evidence/yard28/plate_vs_game_mid_32ppm.png` | Floor between pools L* 54.4, C* 13.0, hue 70 (plate 59.9 / 24.5 / 66; raised_line about 75 / low). Bars: Rivet luminance delta 0.191 (bar 0.19), Rivet dE2000 27.9 (bar 15), patrol 81.5 / 98.7 %, rifle 98.9 %, pellet 93.7 %, pool gain +6.2. raised_line: 42 dusk stills byte-identical |
| 2. A tall arched belt, appliances 1.5 to 1.8 m | `1434d17ae` (cut tool `tools/art/prologue_yard_arched.py`), `e52e4e050`, `d093e43ce`; `evidence/yard28/pass3_vs_pass4_mid_32ppm.png`, `belt_pass4_mid_64ppm.png`, `belt_lanes.txt` | Six non-blocking arch pieces at 0.011 m/px over unchanged cover boxes, lanes 32/32 at least 2.5 m (measured at the leg feet), five-seed pilots identical to raised_line, beam vs floor delta 0.206 |
| 3. A burning hall mouth | `75fc7650a` (cut tool `tools/art/prologue_yard_hall.py`), `24017962b`, `6374ab107`, `e13f8ebe8`; `evidence/yard28/plate_vs_game_front_32ppm.png`, `pass3_vs_pass4_front_32ppm.png`, `hall_mouth_64ppm.png`, `frame-cost.md` | Red share 3.54 / 2.87 % -> 0 (amber shift); light `yard_hall_mouth` (radius 4.5 m, floor glow feathered 1.5 m off the wall); bars patrol 81.3 / 89.4 %, rifle 103.4 %, pellet 97.8 %, Rivet 0.183 (bar 0.152); five seeds identical; frame cost p50 +0.006 ms, CI95 [-0.106, +0.118] (debug build, 3 paired rounds, CONTENDED) |

## What does not
- **The floor is not the plate's mid-brown.** It reads as pale warm concrete. Every lever was measured: tile tint, chroma, a new brown tile, a CIELAB lift, and a second impression over the print. The world print greys whatever lies under it, and any brown strong enough to reach C* 18 darkens the floor toward Rivet's copper, which fails his luminance bar (i55: 0.153 against a bar of 0.19).
- The cream appliance delta against the floor is 0.019 (bar 0.30). This was reported, not fixed.
- At 32 px/m the hall front is a thin dark band under a black void. The plate shows a tall lit brick wall with fire reaching into the roof.
- The belt reads as six staggered pieces, not the plate's single snaking line.
- The frame cost was measured on a debug build: the release export did not fit the time.
- Two front stills (`front_32`, `mouth_64`) came from a dev capture edit that was reverted, because it tripped the debt ratchet.

## What blocked or slowed you
- The builder account's weekly limit hit at 17:44 and ended `builder.mjs` for the night. About 15 minutes were lost moving to in-session subagents.
- mem-budget: 30 minutes of waiting at the first call, plus a foreign 20 GB process outside the cap.
- A stale png import made one sweep invalid: 10 minutes.

## Calls for the owner
- **Floor:** keep i20, the shipped one (Rivet delta 0.191, paler), or take i55 (browner, C* 18.3, Rivet delta 0.153, dE2000 24.7)? `evidence/yard28/floor_i20_vs_i55_mid_32ppm.png`. It is one tint value in the `arched_line` row.
- **Default:** switch from raised_line to arched_line? TODO: plate stills at the three cameras.

## Merge notes
- New row field `ground_impression` and new light kind `yard_hall_mouth`, both in `prologue_yard_dressings` (schema + table). New shader `project/boot/prologue/prologue_floor_glow.gdshader`. All are yard-owned paths.

## Next steps
TODO

## Builder ledger
TODO (see JOURNAL `BUILDER` lines)
