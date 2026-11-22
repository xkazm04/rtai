# Street brief 04

## Enemy rounds with hands equipped

Commit `29d3080e4` changes one line in `project/boot/collect_call/view/fx_view.gd`. The fallback draws hostile rounds with `ShotDraw.core(s)` and Rivet's own rounds with `Ink.INK`.

At tick 306 of seed 7, patrol cop 9 had an assault-rifle round in flight during wave 1. Rivet still had hands equipped. The 32 px/m before and after frames have the same state hash. The dash changed from vermilion to warm cream on the printed street. One interior pixel changed from RGB (223, 77, 40) to (237, 219, 196). [Before](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-hands-before-32.png>) · [After](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-hands-after-32.png>)

## Shield shove

`project/features/combat/squad/foe_shove_zone.gd` supplies the world-space polygon and the centre hit predicate. `foe_shield_view.gd` fills that polygon, runs vermilion rails along its inside edges, and draws a chevron inside the tip. `foe_shield.gd` calls the predicate on the final lunge tick. `project/tests/unit/test_foe_shove_zone.gd` exercises three headings, three speeds, two reaches, the rear plane, the far corner and a blocked lunge. Both new scripts have Godot-generated UIDs.

The strip starts at the planted tell. At the shipped speed it covers 0.40 m of travel plus 1.80 m of reach and is 0.64 m wide. It covers every possible stopping point if a wall cuts the lunge short. The hit uses Rivet's centre at the actual end of travel. The centre must be forward of or on that plane. The sides and far end each gain one body radius independently, so the hit region has square far corners. Exact circular contact would round those corners. The tests place Rivet's body 0.05 m clear of, and 0.05 m across, both rails and the tip.

For the shield stills, the capture placed one shield robot in the seed-7 gauntlet, let its AI lock the tell, then moved Rivet aside so the tip was visible. Each pair shows tick 10 at 70° on the secondary display. At 32 px/m the new rails stay parallel all the way to the arrow. At 64 px/m the ground between the rails is visible through the fill. The old arrow flared and ended sooner.

| Scale | Before | After |
|---|---|---|
| 32 px/m | [Original tell](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-before-32.png>) | [Full reach](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-after-32.png>) |
| 64 px/m | [Original tell](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-before-64.png>) | [Full reach](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-after-64.png>) |

The fixed-camera check also sampled tick 63, after the carrier travelled 0.347 m. The farthest solid vermilion pixel along the new strip was at (1031, 571) on both frames. On the original tell it moved from (1003, 568) to (1018, 583). A view first attached partway through a lunge reconstructs the plant from elapsed ticks. If a wall already stopped the carrier before that first draw, the reconstructed start can sit behind the original plant. It still covers every remaining step and the full reach.

## Checks

- Seed 7, average bot, ten waves. Separate runs at baseline, after the one-line round fix, and after the shove change all finished wave 10 at tick 11474. Both `cmp` comparisons against baseline exited 0. Each result is 7,372 bytes, SHA-256 `dd403c5e28824601477efd6d9e24fc6532317500c11a22ccbd482523da9f471e`.
- `node tools/gate/quick.mjs` passed on the one changed file in Part 0 and all four changed scripts in Part B. Both checks reported zero new merge conflicts.
- The two focused shield suites passed 12/12. `node tools/tests/run_unit.mjs --changed` selected the full fast suite and reported `3642 passed, 0 failed, 2 skipped`.
- The headless Godot import exited 0 and generated both UIDs. `node tools/debt/debt.mjs --check` reported `debt-ratchet: ok`.
- The baseline, Part 0 and final scenario suites each reported `run_scenarios: 65 ran, 0 failed`. All three 60-second replays finished 3,600 ticks, 184 events, 142 input changes and 60 checkpoints with final digest `cbeb734ff9b97c41`.

Capture drivers, logs, byte-comparison inputs and the two late-lunge validation frames are in `build/street/brief04/`. This report precedes the capped mutation run on the single changed hit-gate line.
