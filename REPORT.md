# REPORT lane yard, run n27 (2026-11-24): rails, warm light, the third pass by large drawn set pieces

Branch `n27-yard`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, cut from `main` `a3b3f1466`. Director: Claude Opus; builder: Claude Sonnet 5.5 (high) through `gtai-n27/tools/builder.mjs`. IMAGES 5/15.

**Gate:** TBD (`node tools/gate/run.mjs --rev=HEAD`).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Mulroney's card plays the pump in the prologue | `8eb4d24c2` (`--cast-card=off` dev flag for the before); masters `pump_card_32ppm_before_after.mp4`, `pump_card_32ppm.mp4`, `pump_card_64ppm_t6229.png`, `pump_card_64ppm_t6205_discharge.png` | One Mulroney on screen (the card), the vermilion pump marker above him at full size, vector figure only in the before half. Clips h264 1920x1080 60/1 20.0 s |
| 2. Heavy rails where the conveyor blocks | `df8508959`; `evidence/yard27/rails_read_32ppm.png`, `evidence/yard27/rails_read_64ppm.png`; masters `rails_32ppm_before_after.mp4` | Six chunky rails on their unchanged collision boxes, faint belt only in the gaps. Rail contrast 0.16-0.22 against the floor (Rivet 0.02: his copper is carried by hue, not luminance). All 15 pilot runs (plain, torn_line, line_fire x seeds 7/3/11/21/42) byte-identical to the n26 pin; line_fire deaths 0/1/0/0/1, min hp 36/0/44/28/0 |
| 3. Warmer, larger fire and lamp light at shade 0.81 | `31da0882a` (actor light), `2c00e03e2` (floor glow `PrologueFloorGlow`), `89ffb605c` (mid-yard fires 0.15), `94abcae77` frame cost; `evidence/yard27/dusk_contrast_glow3.txt`; masters `light_mid_32ppm_before_after.mp4`, `light_front_32ppm_before_after.png`, `light_front_64ppm.png` | Against daylight contrast: patrol blue 82.1 % outside / 99.2 % inside a pool (hue 223), rifle 96.5 %, pellet 92.0 %. Frame cost of the actor light p50 -0.040 ms CI95 [-0.184, +0.105] (bench lock, debug build). Floor warmth, n26 to HEAD (`5c0edce51`, `evidence/yard27/floor_warmth.txt`): within 3 m of a fire the floor gains L* +4.8 (mid) / +8.9 (front) and chroma +4.5 / +1.6; between the pools it is unchanged (0.0). The warmth is local to the fires, not a yard-wide mood |
| 4. Third pass: raised belt with hanging appliances, strapped pallets, warm stained floor | `f8515646c` (row `raised_line`, 16 pieces cut by `tools/art/prologue_yard_raised.py` from `tools/art/prologue_yard_sources/n27/`), `a012af5e4` (two west stacks), `311a5a19a` stills `evidence/yard27/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`, `evidence/yard27/pass2_vs_pass3_{gate,mid,front}_32ppm.png`; masters `pass2_vs_pass3_mid_32ppm.mp4`, `plate_vs_game_mid_32ppm.png`, `raised_line_mid_64ppm.png` | Rivet's delta on the new floor 100.6 % of line_fire's; blue 82.0 / 98.5 %, rifle 98.7 %, pellet 92.6 %. Pilots: seeds 7/11/21/42 identical to line_fire, seed 3 11958 ticks (was 13014), same deaths and lowest health; seven other stack placements rejected on the numbers (`evidence/yard27/prologue-yard-pilots-raised.json`). Pallets and hanging appliances drawn over the world print (`ec4634b7c`, `PrologueYardOverprint`): render/art luminance 0.39 -> 0.93 (floor 0.97), line_fire pixel-identical. **Ships as the default** (`54083d91f`, decision `a9aa3d452`): scenario pilot re-pinned (seed 3 11958), scenarios 68 ran 0 failed. Frame cost of raised_line over line_fire, bench lock, debug build, 3 paired rounds: p50 +0.088 ms CI95 [+0.002, +0.173] (bar: upper < 0.5 ms), p99 +0.144 ms [-0.521, +0.809] (`772ae7f8b`, `evidence/yard27/frame-cost.md`) |
| 5. Command view tests (bar 14/20 NOT met) | `5835bbfa0`, `a60eb3a93`: pure static helpers (card switch, sound cues, marker kind, slide and arc, disc, shield, rifle, plate, chevron, plate edge, stem lap) and `project/tests/unit/test_prologue_command_view.gd`; commander stills at 64 px/m pixel-identical after the refactor | mutate 4/20 at the start of the call (last night 5/20), 9/20 at `5835bbfa0`, **9/19 at `a60eb3a93`** (1 invalid). The 10 survivors are draw calls and draw literals (a deleted stem line and cream slide rect, line widths, font size, arc start) that only a render can catch |
| The whole prologue on the new yard, menu Start into quest 1's first line | master `prologue_menu_to_quest1.mp4` (`newgame_pilot.gd --bot --seed=7`) | h264 1920x1080 60/1 189.3 s. The menu, the raised_line yard fight, Mulroney's card with the pump marker, Don Fax, then the city with quest 1's HUD and Rivet's first line (handover tick 10792, first line tick 10793) |

## What does not
- **The plate is still far away.** Pass 3 brings the floor close: warm slabs, joints and big oil stains. But the raised belt is a flat 1.2 m strip, where the plate has a tall arched run. The hanging appliances and the pallets are small cream shapes with little contrast on the pale floor; the plate's big white appliances are its strongest landmark. The hall front has no burning interior. The gate has no lamp pool and no depth. Stills: `evidence/yard27/plate_vs_game_gate_32ppm.png`, `evidence/yard27/plate_vs_game_mid_32ppm.png`, `evidence/yard27/plate_vs_game_front_32ppm.png`.
- **The overall warmth is modest.** The amber reads as floor pools at the burnt pickup, the scrap skip, the NW fire and the mid-yard fires, not as the plate's warm mood. Colour readability set the limit: the cops' blue, the rifle round and the shotgun pellet, measured against daylight.
- **Item 5 missed its bar.** Mutate went from 4/20 (baseline at the start of the call; last night's figure was 5/20) to 9/20 at `5835bbfa0`, against a bar of 14. The survivors are draw-call literals (line widths, the stem length, font size, arc start). `a60eb3a93` pinned the chevron, the plate edge and the stem lap afterwards: 9/19 at HEAD, with no gain.
- **The menu film has no pump close-up.** That is in the pump clips. It is also `yuvj420p`, not `yuv420p`, because the capture is MJPEG.
- **Not measured:** floor_glow mutate. The floor glow's own frame cost: switching it off needs a data change, so call 05 measured raised_line (glow on) against line_fire (glow on) instead.

## What blocked or slowed you
- **The first warm light was too timid (about 35 min).** The light layer tints the actors, and amber at 0.18 turned the cops purple (hue 287-311). Call 02 had to stay at weak values, and the floor glow layer (02b) came as a second call.
- **The world print darkened the cream art (about 20 min).** The pallets and hanging appliances rendered as dark boxes until the over-print layer (`ec4634b7c`).
- **The pilot pin held up the default switch (about 15 min).** Call 03's allowlist did not include the pilot scenario, so the switch to raised_line moved into call 04 Part 0.
- **Builder 01 cleaned Temp it did not own (no time lost here, a risk to the other lanes).** After its mutate timed out it ran `rm -rf` on `gtai-precommit-*` in Temp, which may have removed another lane's pre-commit snapshot. Every later brief forbids it.
- **Mutate is slow on prologue files (about 20 min per run).** It runs 18-19 test files per mutant, about 35 s each.

## Calls for the owner
- **The gate lamp has no floor pool.** Any floor glow at the gate pushes the shotgun pellet under 90 % of its daylight contrast, so its pool is weaker than n26's. Still: `evidence/yard27/pass2_vs_pass3_gate_32ppm.png`.
- **The rifle-round bar was relaxed from 100 % to 95 %** so the mid-yard fires show as pools (96.5 % at 0.15). Decision line `DECISION n27 yard light`.
- **raised_line is the default now**, line_fire one value away (`prologue_stage.json` `dressing`). The pallets and appliances read as cardboard and cream since `ec4634b7c`, but at 32 px/m they are small and low-contrast on the pale floor: still far from the plate's big white appliances. `evidence/yard27/pass2_vs_pass3_mid_32ppm.png`, `evidence/yard27/plate_vs_game_mid_64ppm.png`.
- **Three raised belt sections are below Rivet's capture delta** against the floor (door 0.099, turn 0.119, bend 0.206 vs 0.24); above it by call 01's disc method. They read by shape and shadow.
- **Mulroney's card reads close to a patrol cop in size at 32 px/m**; only the marker sets him apart (cast's art). `pump_card_32ppm.mp4`.

## Merge notes
- Warden catch wiring for cast's `FoeWardenCardView` (cast's NEED yard 03:46): the exact diffs for `prologue_stage.gd` `_move()` and the `prologue_props.gd` dye/dress loop are in `evidence/yard27/warden_catch_wiring.md` (`fe573d9ea`, `55b1d8d29`). They are not applied, because the class exists only on n27-cast and would not compile here. Apply after the cast merge with `git apply --check` first.
- The yard's own prologue unit tests now pin `line_fire` explicitly where they test that row (`test_prologue_yard_layout.gd`, `test_prologue_yard_rails.gd`, `test_prologue_yard_dressing.gd`), and `test_prologue_raised_line.gd` asserts the raised_line default.
- Debt baseline: `prologue_command_view.gd` is 255 lines and its test file 221 (files_past_soft_cap 65 -> 67, reasons in `tools/debt/baseline.json`). After a baseline conflict, use `node tools/debt/merge_baseline.mjs`.
- The dressings schema gained `floor_glow` and two light-kind enum values (`yard_fire_mid`, `yard_lamp_gate`).
- Decisions lines: `6c3c41b36` (rails, light), `a9aa3d452` (default raised_line). The scenario `scenario_prologue_pilot.gd` now pins `RAISED_LINE_TICKS` for the default and keeps a named line_fire row.

## Next steps
- **Bring the hanging appliances up to the plate's scale.** Plate A's strongest landmark is the white appliances hanging high off a tall arched belt. Ours are small cream shapes on a 1.2 m strip. Draw a taller belt (legs and arch) with appliances of about 1.5 to 2 m on screen, and give them a darker floor under the belt so cream reads against it.
- **Use a mid-brown floor tone, not pale concrete.** The plate's floor is darker and warmer. Re-measure Rivet's copper (hue carries him) and the amber fire against it before it ships.
- **Give the hall front a burning interior.** The plate shows a lit hall mouth. We have only the warm band at its base.
- **Win back the gate lamp pool without losing the shotgun pellet.** Try a lamp glow that stops short of the gate's fight lane, or a pellet outline, so the pellet keeps 90 % of its daylight contrast.
- **Measure the frame cost in a release build.** raised_line over line_fire measured +0.088 ms p50 in a debug build. The release template refuses `--path`, so it needs an export first. Also measure the floor glow alone, which needs a `--floor-glow=off` dev flag.
- **Kill the command view's draw survivors with a render test.** One headless capture of the commander at 64 px/m, hashed per marker state, would catch the deleted draw calls and literals that the unit tests cannot see.
- **Apply the warden catch patch** (`evidence/yard27/warden_catch_wiring.md`) at the merge with n27-cast and film her catch in the yard.

## Builder ledger
| call | tag | minutes | $ | verdict |
|---|---|---|---|---|
| 01 | card-rails | 53 | 3.39 | accepted |
| 02 | warm-light | 64 | 1.65 | accepted in part (light too timid; went on as 02b) |
| 03 | floor-glow (resume) | 34 | 2.90 | accepted in part (stills and cost owed, into 04) |
| 04 | set-pieces (resume) | 53 | 6.36 | accepted (default switch blocked by the pilot pin: went into 05 Part 0) |
| 05 | command-tests | 65 | 4.00 | accepted in part (mutate 9/20 under the bar of 14; light numbers and glow cost not done) |
| 06 | cost-mutate | 28 | 0.62 | accepted (measuring only: frame cost, mutate 9/19, floor warmth) |

Total: 6 calls, 297 min, $18.92. What I would brief differently:
- **Ask for the colour-readability bars in the first light brief, along with how the light layer tints actors.** Call 02 found by itself that amber on the actor layer turns cops purple. A floor-only glow from the start would have saved the 02b call.
- **Put every file a change drags along in the allowlist,** such as the pilot scenario and the tests that pin the default. The default switch slipped one call because the scenario was outside call 04's allowlist, and call 05 edited four tests outside its list to follow the switch.
- **Check a cut art piece rendered in game before placing many.** The world print darkened the cream pallets and appliances, and nobody saw it until the stills.
- **Give item 5 a render-hash test from the start.** Pure helpers took mutate from 4 to 9 of 20. The rest are draw calls.
