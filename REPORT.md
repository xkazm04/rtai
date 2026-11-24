# REPORT lane yard, run n28 (2026-11-24): the fourth pass `arched_line` (tall arched belt, warmer floor, burning hall mouth)

Branch `n28-yard`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, cut from `main` `d0ab9d03a`. Director: Claude Opus. Builder: Claude Sonnet 5.5. One call ran through `gtai-n28/tools/builder.mjs` until the builder account hit its weekly limit at 17:44. Every call after that was an in-session Sonnet subagent working from the same brief files (see the Builder ledger). IMAGES 5/25.

**Gate:** `node tools/gate/run.mjs --rev=HEAD` on `cabb1ece8` -> `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n25-yard\build\gate\cabb1ece8d8a\gate.json`. Lint 19/19, unit 4203 passed / 0 failed / 2 skipped, scenarios 68 passed, parity bit for bit, selftest, export-audit 995 loaded / 0 failed.

Reels: `node tools/gate/run.mjs --rev=5519b3e11 --reels` -> `PASS reels: exit 0` (top, tilt70, combo; `build/gate/5519b3e118ce/reels.log`). That gate as a whole failed on one unit test that the default switch broke (`test_prologue_yard_lights.gd:75` checked the default yard against `line_fire`'s row), fixed in `cabb1ece8` (a test-only change, so the reels were not re-run), plus two tool timing tests under machine load (`tools/merge/step_guard.break.test.mjs`, 17 s and 43 s against millisecond budgets).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. A darker warm floor (in part) | `46146133b`, `027bacffa`, `65ef46c3b`; `evidence/yard28/floor_sweep.txt` (TINT, CHROMA, ART, LIFT, IMPRESSION sweeps); `evidence/yard28/plate_vs_game_mid_32ppm.png` | Floor between pools L* 54.4, C* 13.0, hue 70 (plate 59.9 / 24.5 / 66; raised_line about 75 / low). Bars: Rivet luminance delta 0.191 (bar 0.19), Rivet dE2000 27.9 (bar 15), patrol 81.5 / 98.7 %, rifle 98.9 %, pellet 93.7 %, pool gain +6.2. raised_line: 42 dusk stills byte-identical |
| 2. A tall arched belt, appliances 1.5 to 1.8 m | `1434d17ae` (cut tool `tools/art/prologue_yard_arched.py`), `e52e4e050`, `d093e43ce`; `evidence/yard28/pass3_vs_pass4_mid_32ppm.png`, `belt_pass4_mid_64ppm.png`, `belt_lanes.txt` | Six non-blocking arch pieces at 0.011 m/px over unchanged cover boxes, lanes 32/32 at least 2.5 m (measured at the leg feet), five-seed pilots identical to raised_line, beam vs floor delta 0.206 |
| 3. A burning hall mouth | `75fc7650a` (cut tool `tools/art/prologue_yard_hall.py`), `24017962b`, `6374ab107`, `e13f8ebe8`; `evidence/yard28/plate_vs_game_front_32ppm.png`, `pass3_vs_pass4_front_32ppm.png`, `hall_mouth_64ppm.png`, `frame-cost.md` | Red share 3.54 / 2.87 % -> 0 (amber shift); light `yard_hall_mouth` (radius 4.5 m, floor glow feathered 1.5 m off the wall); bars patrol 81.3 / 89.4 %, rifle 103.4 %, pellet 97.8 %, Rivet 0.183 (bar 0.152); five seeds identical; frame cost p50 +0.006 ms, CI95 [-0.106, +0.118] (debug build, 3 paired rounds, CONTENDED) |
| 4. The default is now the fourth pass | `5519b3e11`; `docs/decisions.md` `DECISION n28 yard default` | `prologue_stage.json` `dressing` -> `arched_line` (raised_line one flag away). The pilot re-pin needed no new numbers: arched_line finishes in raised_line's ticks on all five seeds (11701 / 11958 / 10392 / 12158 / 13278), and the seed-7 cover bytes are equal. `prologue_pilot ok, 399.7 s`, unit 22/22 |
| 5. Plate beside game, pass 3 beside pass 4, films | `16ff2d218`; `evidence/yard28/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`, `evidence/yard28/pass3_vs_pass4_{gate,mid,front}_32ppm.png`, `evidence/yard28/plate_judgement.md`; masters in `C:\Users\kazda\kiro\gtai-masters\n28\yard\` (`frames.json`, 13 entries) | Three clips, h264 yuv420p 1920x1080 60 fps (ffprobe): `pass3_vs_pass4_mid_32ppm.mp4` 23.0 s, `pass3_vs_pass4_front_32ppm.mp4` 23.0 s, `pass4_gate_32ppm.mp4` 20.0 s. I judged by eye that the fourth pass is closer to the plate at gate, mid and front |

## What does not
- **The floor is not the plate's mid-brown.** It reads as pale warm concrete. Every lever was measured: tile tint, chroma, a new brown tile, a CIELAB lift, and a second impression over the print. The world print greys whatever lies under it, and any brown strong enough to reach C* 18 darkens the floor toward Rivet's copper, which fails his luminance bar (i55: 0.153 against a bar of 0.19).
- The cream appliance delta against the floor is 0.019 (bar 0.30). This was reported, not fixed.
- At 32 px/m the hall front is a thin dark band under a black void. The plate shows a tall lit brick wall with fire reaching into the roof.
- The belt reads as six staggered pieces, not the plate's single snaking line.
- The frame cost was measured on a debug build: the release export did not fit the time.
- Two front stills (`front_32`, `mouth_64`) came from a dev capture edit that was reverted, because it tripped the debt ratchet. The film call re-rendered `plate_vs_game_front_{32,64}ppm.png` at HEAD with the committed tool; `hall_mouth_64ppm.png` is still the old render.
- `tools/art/prologue_yard_film.mjs --movie` refuses at the project's 1280x800 size, so the clips were filmed through a `build/prologue-film` override (not committed).
- Not filmed: `floor_pass4_64ppm.png` and a fresh 64 px/m belt still. The belt still in masters is from the belt-place call.
- No mutate score for the code changes (`ground_impression` in `PrologueYardDressing`, the floor glow feather). They were skipped for time, so there is no "planted faults caught" claim.
- Brief item 5 was not reached: the gate lamp pool and the command-view render-hash test.
- **Not filmed: the whole prologue from the menu's Start into quest 1's first line on the new default.** The brief for it is ready (`evidence/briefs/n28-06-prologue-film.md`), but the gate fix and re-gate took the last hour (one Godot per lane). The five-seed pilot on arched_line finishes in raised_line's ticks, so the handover should not have moved, but this is unfilmed and unmeasured tonight.
- My default switch broke one unit test, and I only caught it at the gate (see the Gate line). The switch brief listed the tests that pin the default's id, not the ones that compare the default yard against a named row.

## What blocked or slowed you
- The builder account's weekly limit hit at 17:44 and ended `builder.mjs` for the night. About 15 minutes were lost moving to in-session subagents.
- mem-budget: 30 minutes of waiting at the first call, plus a foreign 20 GB process outside the cap.
- A stale png import made one sweep invalid: 10 minutes.

## Calls for the owner
- **Floor:** keep i20, the shipped one (Rivet delta 0.191, paler), or take i55 (browner, C* 18.3, Rivet delta 0.153, dE2000 24.7)? `evidence/yard28/floor_i20_vs_i55_mid_32ppm.png`. It is one tint value in the `arched_line` row.
- **Default (decided by the lane, reversible by one value):** I judged the stills by eye. The fourth pass is closer to plate A on all three cameras. At the gate, the arched belt and the cream appliances are in frame and the floor is a touch warmer. In the mid yard, the belt matches the plate's subject and size. At the hall front, both mouths burn. The floor is a tie: it is pale in both. See `evidence/yard28/pass3_vs_pass4_{gate,mid,front}_32ppm.png`, `evidence/yard28/plate_vs_game_{gate,mid,front}_32ppm.png` and `evidence/yard28/plate_judgement.md`. The default-switch result is in What works. To go back: `prologue_stage.json` `"dressing": "raised_line"`, or `--yard-dressing=raised_line`.
- **The hall front's mass:** at 32 px/m the hall is a thin dark band under a black void. The plate shows a tall lit brick facade with fire into the roof. The next pass would be a taller front strip and a roof glow.

## Merge notes
- New row field `ground_impression` and new light kind `yard_hall_mouth`, both in `prologue_yard_dressings` (schema + table). New shader `project/boot/prologue/prologue_floor_glow.gdshader`. All are yard-owned paths.
- The default switch (`5519b3e11`) touches `prologue_stage.json` (one value), `scenario_prologue_pilot.gd` (arched_line pinned on raised_line's ticks, raised_line added to the loop: the pilot scenario now runs 25 seed runs, about 400 s) and the default-id asserts in `test_prologue_raised_line.gd` and `test_prologue_yard_dressing.gd`. Another lane that pins the default yard id would conflict there. `cabb1ece8` makes `test_prologue_yard_lights.gd` read the stage's default dressing (arched_line: 1 `yard_fire` pool and 2 `yard_hall_mouth` pools).
- Two `docs/decisions.md` lines: `DECISION n28 yard` (the fourth pass) and `DECISION n28 yard default`.

## Next steps
1. The hall front's mass: a taller facade strip and a roof glow (the biggest gap left at the front camera).
2. The belt as one snaking line: overhead beam spans (non-blocking, under actors) bridging neighbouring sections.
3. The floor: the owner picks i20 or i55. A real mid-brown needs the world print (core, not yard) to leave the ground's chroma alone.
4. Fix `prologue_yard_film.mjs --movie` for the 1080p capture profile, so films come from a committed tool.
5. Mutate `prologue_yard_dressing.gd` (impression) and `prologue_floor_glow.gd` (skipped tonight for time).
6. The gate lamp pool and the command-view render-hash test (brief item 5, not reached).
7. Film the whole prologue on arched_line (`evidence/briefs/n28-06-prologue-film.md`, ready to run), plus `floor_pass4_64ppm.png` and a fresh `belt_pass4_64ppm.png`.

## Builder ledger
17 calls. One ran through `builder.mjs` (dark-floor: 43 min, $2.90, abandoned-partial when the weekly limit hit). The other 16 were in-session Sonnet subagents, so no dollar figure is reported for them (token counts are in JOURNAL).

| Call | Min | Result |
|---|---|---|
| dark-floor (builder.mjs) | 43 | abandoned-partial ($2.90) |
| floor-commit-belt-cut | 22 | accepted |
| belt-cut | 12 | accepted |
| floor-chroma | 11 | finding only |
| belt-place | 20 | accepted |
| floor-art | 20 | finding only (tool + tile) |
| floor-lift | 11 | bounced (stale import) |
| floor-reimport | 10 | finding only |
| hall-cut | 4 | accepted |
| floor-impression | 20 | accepted |
| hall-partA | 14 | accepted |
| hall-partB | 29 | accepted |
| films | 33 | accepted (clip 2 done; floor and fresh belt 64 px/m stills not done) |
| default-switch | 9 | accepted (missed one test, caught by the gate) |
| lights-test | 31 | bounced: the edit was verified, but the commit stalled on mem-budget after the reels |
| lights-commit | 1 | accepted `cabb1ece8` |

What I would brief differently: I would measure what greys the floor (the world print over the ground) before any floor art. Five floor calls chased tint, art, lift and chroma before the 19:52 finding pointed at the print. I would also put "re-import every changed png before you render" in every art brief from the first call. And a default-switch brief should say "run every test that names the yard's tables" (`node tools/tests/test_map.mjs project/data/tables/prologue_stage.json`), not grep for the old id.
