# Electric robot contacts

Both sources use the baton's overload timer. A direct electro bolt qualifies at either charge. Only the full claw discharge qualifies, and only on its first body. Robot thugs and gunners shut down immediately. Shield robots and sentry turrets overload for 150 ticks and shut down on a second qualifying contact inside that window. War machines take ordinary damage and a 30-tick stun. Bosses, brain-owned fighters, humans, hops and partial discharges retain the ordinary source behavior.

The bolt forks out through the joints and pushes plates clear of the toppling chassis. The clamp lifts the robot, breaks the core and drops a smoking wreck beside Rivet. Both draw from the kill clock. The shield wreck carries the visible sprite frame at its live scale.

## Review frames

Each PNG is a native viewport crop from the live arena, captured on contact and 10, 30 and 60 simulation ticks later. The sheets arrange the four ticks for each target. The shield has separate prime and execute rows. [Electro gun at 32 px/m](frames/electro_gun-32.jpg) ? [Full claw at 32 px/m](frames/claw_shock-32.jpg) ? [Electro gun at 64 px/m](frames/electro_gun-64.jpg) ? [Full claw at 64 px/m](frames/claw_shock-64.jpg)

To reproduce a set, set `GTAI_MELEE_TAKE` to an existing output directory and launch `tools/film/electric_stills.tscn` as an absolute external scene. Use D3D12, a 1920 ? 1080 window at 0,1440 and fixed 60 fps. Pass `--view=tilt70 --ppm=32 --rigs --clean --silent --feel=off --enemy-brain=squad --seed=20261109` alongside `--victim=shield_robot` and either `--loadout=electro_gun --sig-gun=electro_gun` or `--loadout=hands --sig-gun=claw_shock`. The scene exits after it verifies the frame count and contact type.

## Verification

All seven focused scenarios and all 68 scenarios in the full suite passed their existing expectations after the gameplay changes. The 60-second replay ended at `cbeb734ff9b97c41`. Quest 1 reached all five checkpoints on their prior ticks, resumed the dock checkpoint and paid 1,500. The arena rake digest stayed `043cbe54ae78122b5937855f3957363b1c5669368357023144da7052750053ca`. No scenario was re-pinned. [Individual scenario and checkpoint results](verification.json)

The changed-unit run passed 3,999 tests with two skips. The full run passed 4,015, failed one new fixture and skipped two. The fixture lacked the name present on a live shield card. Naming it fixed the failure, and the failed-test rerun passed.

The standalone Godot parse check reported dependency cascades from missing project autoloads and an allocator shutdown message. The normal project loader, live captures and GUT loaded the scripts. Formatting, lint and the quick gate with the standalone parse step disabled passed.

Native and GDScript snapshots matched exactly over 1,200 steps and 40 checkpoints, ending at `94b2865f7f17d778`. The parity probe detected its planted fault at step 629. All seven archived it14/it15 replay files reproduced their previously recorded state-hash failure at tick 60. None was re-pinned.
