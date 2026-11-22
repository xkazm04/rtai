# Street lane · Brief 03

## Gauntlet tuning

- `c48fe5489` adds the optional unique `roster_exclude` list and handles a zero wave budget. The composer test exercises 50 waves with and without the exclusion.
- `cdacafe98` applies each optional repair setting to the gauntlet stage before its bonuses capture the base rate. The test sets the stage rate to 4 and reads 10 from a fresh combat tuning instance.
- Both commits update `project/data/tables/gauntlet.json` and `project/data/schemas/gauntlet.schema.json`. Their implementation and test pairs are `gauntlet_composer.gd` / `test_gauntlet_composer.gd` and `gauntlet_street.gd` / `test_gauntlet_bonus_apply.gd`.
- Seed 7, average bot, ten waves. `cmp seed7-base10.json seed7-0a.json` and `cmp seed7-0a.json seed7-0b.json` both exited 0. A third comparison, `cmp seed7-0b.json seed7-final.json`, also exited 0 after the colour changes. Each file is 7,372 bytes with SHA-256 `dd403c5e28824601477efd6d9e24fc6532317500c11a22ccbd482523da9f471e`.

## Enemy round rendering ? `90bad0b11`

| Files | What changed |
|---|---|
| `combat/enemy_round_look.gd`, `combat/shot_draw.gd` and their Godot-generated UIDs | Five shared colours, size selection, and a draw canvas that preserves the amber core and rim through the print shader. Unknown size uses small. |
| `combat/weapons/gun_fx_art.gd`, `combat/weapons/fight_areas_art.gd`, `combat/squad/foe_ordnance_view.gd` | Tracers, hostile muzzle stars, rocket body and fins, exhaust and smoke. The war cannon uses the same rocket drawing function. |
| `combat/weapons/arena_combat_lights.gd`, `fx/noir/muzzle_flash.gd` | Enemy muzzle light and noir muzzle star. |
| `dev/enemy_ai/enemy_fight_fx.gd`, `dev/enemy_ai/enemy_pit_view.gd`, `dev/gunplay/dodge_view.gd` | Enemy pit and dodge tracers and flashes. |
| `dev/noir/quest_fight.gd`, `dev/noir/showcase_fight.gd` | Supply the shooter's side to the noir flash. |
| `tools/debt/baseline.json` | Tightened with the debt tool. |

Small rounds use `#FFE6A8` over `#E08A1E`. Large rounds use `#E8F7FF` over `#92C9F5`. The rim is a pale blue at 207? hue, compared with 175? for soul teal `#1FB5A8`. The muzzle uses `#FFDC8C`.

Combat and FX paths above are under `project/features/`. Dev paths are under `project/`.

## Stills

All eight PNGs are in `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/`. The [comparison sheet](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds-review.jpg>) includes the full frame and an enlarged crop of each round.

Seed 7's first earned pick froze at tick 901. The capture staged a police pistol round and a rocket-trooper round in flight at the same positions in both builds. Rivet held a table pistol to exercise the gun-FX renderer. After positioning Rivet and the camera, both captures logged state hash `6ad942645a812bc844ca17c944801a2cd8488590e492cd9ea30ee6c2ff49d7cf`. Both renders used D3D12, 1920 × 1080, and 70° tilt. The paired views used 32 px/m and the two individual after shots used 64 px/m. The two capture scripts and their logs are alongside the image directory.

| View | Observation |
|---|---|
| Asphalt | Both old rounds had a red tracer. The new pistol tracer has an amber tail and a pale tip. The rocket has an ice-blue body and blue-grey exhaust. |
| Blood | The old small red tip blended into the blood. Its new pale tip and the rocket's blue rim are both distinct from the puddles. |
| Pick screen | The overlay dims both rounds substantially. The amber line on the left and the blue rocket on the right stay distinguishable beside the cards. Sampled pixels are dark amber `#534B3E` at the small tip and slate blue `#354352` at the large rim. |
| 64 px/m | The small round has a warm tip and narrow rim. The large round has a broad ice-blue case and trail. The existing tracer sits slightly above the rocket body at both resolutions. |

Both captures logged the same ghost-sheet warning and 63 ObjectDB instances at shutdown.

## Checks

The composer tests passed 10/10, the bonus tests passed 8/8, and nine schema cases passed. Godot import generated both UIDs. `node tools/tests/run_unit.mjs --changed` selected the full fast suite and reported **3,634 passed, 0 failed, 2 skipped**. `node tools/debt/debt.mjs --check` reported `debt-ratchet: ok` after tightening.

The direct post-colour scenario command and the full run on the final files both reported `run_scenarios: 65 ran, 0 failed`. The 60-second replay matched its original run at all 60 checkpoints, with 3,600 ticks, 184 events, 142 input changes and final digest `cbeb734ff9b97c41`.

The original and final drawing code emitted 50 scenario evidence JSONs each. All 75 compared hash/digest fields and replay fingerprints matched. The comparison is in [sim-digests.json](<C:/Users/kazda/kiro/gtai-masters/n23/street/sim-digests.json>). The first original-art comparison run had one wall-clock miss in rig stress, 1.049 ms against a 1.000 ms budget. Its isolated rerun on the original source passed at 0.908 ms. The final full suite passed at 0.975 ms. The separate complete original-art repeat is recorded in `scenarios-before-confirm.log` alongside the image directory. A separate runtime probe passed six checks for unknown, small, large and reflected shots, the friendly muzzle preset, and the two hostile muzzle colours.

The Part A commit hook reported `lint: all 19 checks pass over 1947 GDScript files`. The Part 0 quick gates passed. For Part A, all twelve drawing scripts passed the style and lint checks. The default quick gate failed the standalone parse check for `arena_combat_lights.gd`. Rechecking the exact original and final script produced byte-identical error logs (SHA-256 `850ab0d6e01a83246e9b9bd2c8483d2e7cf925e170e122212fc93d59a0a9155d`). Godot reports an allocator shutdown message after the autoload dependency cascade. The gate filter lives in `tools/godot/check.mjs`, outside this brief.

## NEED

The unarmed/melee fallback in `project/boot/collect_call/view/fx_view.gd` and the plate-clipped tracer in `project/features/souls/plate_sparks.gd` still draw vermilion. Both directories are explicitly forbidden in this brief.

Mutation scoring requires a separate Git worktree. The mutation tool rejects the current checkout as its scratch directory.
