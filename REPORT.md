# REPORT lane foes (n22, 2026-11-21): four new enemies and a tier on every enemy

Branch `n22-foes`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-foes`. Interface tag `n22-foes-iface` = `245c0e6f1`.
Final gate (06:00, HEAD `90902c90e`): `node tools/gate/run.mjs --rev=HEAD` -> `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n22-foes\build\gate\90902c90e94e\gate.json` (lint 19/19 over 1854 files, unit 3448 passed / 0 failed / 2 skipped, scenarios 65 passed, parity bit for bit over 1200 steps with the planted mutation caught at step 629, selftest, export-audit 839 loaded / 0 failed).

Each enemy asks for a different answer: the **rocket trooper** for movement or a wall, the **sentry turret** for guarding through the sweep or getting behind it, the **shield robot** for a flank, a roll past it or a blast, and the **war machine** for reading two tells and hitting it during its pause. Every enemy row has a `tier`. Numbers on existing rows and weapons did not change.

## What works

| Item | Evidence | Number |
|---|---|---|
| `tier` 1..5 required on every `enemies.json` row, loaded into `EnemyRoster.Archetype.tier`; tier sanity test walks every row, every weapon row's `round`, every new tell >= 20 ticks | `245c0e6f1`, `project/data/schemas/enemies.schema.json`, `f617df7b5` `project/tests/unit/test_foe_tiers.gd` | 10 rows: patrol_cop 1, riot_cop 2, swat 2, contractor 2, rocket_trooper 2, robot_thug 3, robot_gunner 3, sentry_turret 3, shield_robot 4, war_machine 5 |
| **Rocket trooper** (human, one hit): keeps >= 8 m, 60-tick kneel tell with a vermilion aim line, one slow 9 m/s `large` rocket at the locked point (walls stop it), then relocates; striped launcher tube on the shoulder, visible brace | `8e522de76`, `0b29f2cb5`, `95ef7e82a`, `f1f8fc6f2`, `f326e45eb`, `evidence/foes/duel-rocket_trooper.json`, film `C:\Users\kazda\kiro\gtai-masters\n22\foes\rocket_trooper\arena.mp4` | duel 20 seeds: hurt perfect 0 % / average 70 % / novice 80 %; killed 100 % each; mutation `foe_rocket.gd` 18/19, relocation lines 12/19 -> 17/19 |
| **Sentry turret** (does not move): sweeps a lane in bursts of `small` rounds along an aim line, cools (amber), front plate, full damage from behind and from blasts; bolted steel mount with a hazard apron; `placement: "far"` for street's composer | `8bf86a60c`, `f42cbddd9`, `evidence/foes/duel-sentry_turret.json`, film `C:\Users\kazda\kiro\gtai-masters\n22\foes\sentry_turret\arena.mp4` | duel: hurt perfect 5 % / average 100 % / novice 100 %; turret killed 100 / 60 / 40 %; median kill 14.3 / 25.3 / 29.5 s; mutation `foe_turret.gd` 18/20 = 90 % on HEAD (survivors: the initial `_angle` and `_gap` values, overwritten before the first sweep) |
| **Shield robot** (heavy, slow): <= 1.6 m/s advance behind a front plate, 48-tick shove tell with a vermilion wedge along the locked 1.8 m path; full damage from behind and from blasts; `uses_cover` squad-mates walk behind it as moving cover; drawn bigger than Rivet | `dec85d2b4`, `812b763f0`, `95ef7e82a`, `evidence/foes/duel-shield_robot.json`, films `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\arena.mp4`, `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\squad\arena.mp4` | duel: hurt 0 / 75 / 100 %, mean damage 0 / 24.5 / 39.9, killed 100 % each, rear share of Rivet's damage 71 / 65 / 53 %; mutation `foe_shield.gd` 19/20 |
| **War machine** (mini-boss): walks to an 8-14 m band and turns slowly; cannon tell 72 ticks with a 5 m vermilion ring on Rivet, then a slow `large` shell (walls stop it); stomp tell 48 ticks with a growing ring, area damage around itself; then a 72-tick recover with no turn and no shot (amber rear vents); front 0.5x, rear 1.5x, blasts 1x; drawn about twice Rivet's footprint | `42a0e5632`, `0841836cf`, `95ef7e82a`, `evidence/foes/duel-war_machine.json`, film `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\arena.mp4` | duel: hurt 0 / 95 / 100 %, mean damage 0 / 53 / 100.4, machine killed 100 / 100 / 55 %, median kill 23.5 / 26.8 / 23.4 s; 41 / 45 / 51 % of Rivet's damage lands during recover; mutation `foe_walker.gd` 19/20 |
| Time to kill for each enemy and player weapon, front and rear, 10 seeds per cell | `2a1873199`, `90902c90e`, `evidence/foes/ttk.md`, `evidence/foes/ttk.json` | table below |
| `--foe-mix=<ids>` puts the chosen enemies in the arena pit (validated ids, falls back with `Log.error`) | `cb0aad246` | used by every film |
| `ArenaSquad.set_route_map(map)` for street's gauntlet (street's NEED) | `73df7e6c5`, `project/tests/unit/test_foe_squad_map.gd` | |

Stills, best first: `C:\Users\kazda\kiro\gtai-masters\n22\foes\frames.json` (15 entries, every one checked by eye: subject centred, inside the pit, at 32 or 64 px/m).

Before/after at the same seed, tick and camera (before = `f617df7b5`, the last commit before the looks polish, filmed by me at 06:01 in its snapshot; after = HEAD looks): war machine `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\before\t368.png` vs `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\t368.png` (Rivet-sized -> about twice his footprint), shield robot `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\before\t419.png` vs `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\t419.png` (adds the plate facing and the shove wedge; positions differ because `02fa4eae5` also changed the circle after a shove), rocket trooper at 64 px/m `C:\Users\kazda\kiro\gtai-masters\n22\foes\rocket_trooper\kneel64\before\t130.png` vs `C:\Users\kazda\kiro\gtai-masters\n22\foes\rocket_trooper\kneel64\t130.png` (standing swat pose -> kneeling with the striped launcher). Linked as `before` in frames.json.

### Time to kill (s, median of 10 seeds, guns at 8 m, claw at its reach 1.84 m, front / rear; one value = equal; `-` = over 30 s)

| Tier | Enemy | pistol | mach. pistol | flame | rocket | electro | molotov | gloria | plasma | hand cannon | ray | shard | mini-nuke | gatling | claw |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1-2 | patrol_cop, contractor, riot_cop, rocket_trooper, swat | 0.12 | 0.20 | 1.97 | 0.38 | 0.68 | 1.77 | 0.17 | 0.23 | 0.10 | 0.08 | 0.43 | 1.10 | 0.63 | 0.08 |
| 3 | robot_gunner | 0.87 | 0.60 | 6.27 | 2.18 | 3.18 | 6.41 | 1.37 | 0.57 | 0.10 | 0.38 | 0.84 | 1.10 | 0.93 | 0.53 |
| 3 | robot_thug | 1.37 | 0.87 | 10.09 | 2.18 | 5.77 | 8.92 | 2.17 | 0.73 | 0.93 | 0.58 | 1.11 | 1.10 | 1.13 | 1.20 |
| 3 | sentry_turret | 9.57 / 1.87 | 7.40 / 1.13 | - / 12.82 | 3.98 | - / 7.27 | 12.23 / - | 12.57 / 2.97 | 3.73 / 1.07 | 6.90 / 0.93 | 3.18 / 0.78 | 6.23 / 1.37 | 1.10 | 3.93 / 1.38 | 7.07 / 1.47 |
| 4 | shield_robot | 16.02 / 2.37 | 11.40 / 1.40 | - / 16.92 | 5.78 | - / 9.27 | 14.75 / 22.68 | 20.17 / 3.77 | 5.73 / 1.23 | 12.03 / 1.77 | 6.98 / 0.98 | 1.63 | 5.08 / 5.10 | 5.94 / 1.63 | 11.47 / 2.13 |
| 5 | war_machine | 16.27 / 5.22 | 11.60 / 3.93 | - / 28.74 | 14.78 | - / 16.93 | - | 20.57 / 6.97 | 5.90 / 2.07 | 12.03 / 3.43 | 7.08 / 1.78 | 5.43 | 9.09 | 6.08 / 2.42 | 11.73 / 4.00 |

Reading: the armour shows as intended (pistol on the shield robot 16.0 s from the front, 2.4 s from behind); blasts (rocket, shard, mini-nuke) are the same from both sides. The five human rows are identical: one hit kills (claw 0.08 s), the time is the weapon's travel and cadence. The claw shows the same armour: shield robot 11.47 s from the front, 2.13 s from behind. Molotov front/rear on the turret and the shield robot is noisy (ground fire against a plate), not a pattern.

Existing rows' and weapons' numbers are unchanged. After every brief: unit (last 3448 passed, 0 failed, 2 skipped), scenarios 65/65, and the 60 s replay (`cbeb734ff9b97c41`), quest 1 replay and checkpoint byte-identical (Astra's runs; the final gate's 65 scenarios, which include the 60 s replay, pass on HEAD `90902c90e`).

## What does not

- **Blast area damage on Rivet** is not dealt on this branch: a rocket or a cannon shell hurts Rivet only on a direct hit; its burst is drawn, not dealt. Guard's `RivetBlast.burst` (guard head `97352761e`) deals it once merged (the rows already carry `splash_radius_m` / `splash_damage`). The war machine's stomp deals its own area damage (foes code, line of sight on the route map).
- **War machine vs the 15 s wave target**: an average player needs about 27 s alone with it (plus its escort). See Calls.
- **Not every gun kills a human with its first hit**: machine pistol, gatling, electro, flamethrower and molotov do less than 1 human hp per round by their shipped `weapons.json` numbers (two pistol-class rounds per cop). The doctrine "humans die to one hit" holds per hit of a full round, not per pellet; nothing changed tonight (guard's file, existing numbers).
- The shield robot's shove mark is a short vermilion arrowhead at its feet (64 px/m close-up `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\shove64\t405.png`, tick 405): it shows the locked direction, and the reel bot reads it and steps clear with no damage, but it does not draw the 1.8 m reach. Drawing the reach is a view-only change in `foe_shield_view.gd` (next steps).
- At 32 px/m the bigger walker's hull nearly fills its own stomp ring (`C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\t368.png`): the ring still reads, but the visible margin between hull and ring edge is thin. A wider ring is one number (`splash_radius_m` on the stomp row) for the tuner or the owner.
- `combat_arena.gd:213` names `war_machine` by id (fight areas never hold it); a row flag would be cleaner.
- The held guard (right-click block) and the wheel are guard's and are not on this branch beyond `n22-guard-iface`: the duels use `PitDummy` profiles (perfect / average / novice dodging and aim), not the held guard, so "guard through the turret's sweep" is not measured here.

## What blocked or slowed me

- 00:12 first Astra call abandoned after 2 min: my brief named a foes-only blast key; guard's brief used `splash_radius_m` / `splash_damage`. About 3 min.
- Turret look bounced once (a thin white scribble at 32 px/m), fixed in `f42cbddd9`: about 20 min of a brief.
- Machines first drawn at Rivet's size (shield robot, war machine) and the launcher first hid the trooper's body: one more polish pass (`95ef7e82a`, `f1f8fc6f2`), about 25 min.
- My own final runs: the turret's whole-file mutation (349 s) and the gate (11 min) ran one after the other with no Astra in between: about 20 min of waiting, by design.

## Calls for the owner

1. **War machine length.** hp 26 with front 0.5x / rear 1.5x: an average player kills it in 26.8 s alone (`evidence/foes/duel-war_machine.json`), a pistol from the front takes 16.3 s, from behind 5.2 s (`evidence/foes/ttk.md`). The 15 s wave target is for normal waves; a boss wave every fifth wave at about 25-30 s is my pick (its pattern is the fight). The alternative, hp 14, is one number for the loop's tuner. Stills: `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\t368.png` (stomp), `C:\Users\kazda\kiro\gtai-masters\n22\foes\war_machine\t533.png` (rear hit).
2. **Shield robot cover for everyone?** Only squad-mates with `uses_cover` (swat, contractor) walk behind it today. Letting patrol and riot cops use it too is one check in `FoeShieldCover`. Still: `C:\Users\kazda\kiro\gtai-masters\n22\foes\shield_robot\squad\t230.png`.
3. **Looks are placeholders** built from existing rigs (swat body + a striped launcher; the thug rig scaled for the shield robot and the walker; a drawn turret mount). Final art needs your direction.

## Merge notes

- Call sites outside foes-owned folders (one line each): `project/features/arena/arena_squad_looks.gd:15`, `project/features/arena/arena_robot_rigs.gd:69`, `project/features/arena/arena_rigs.gd:75`, `project/features/arena/arena_rigs.gd:159`, `project/features/arena/arena_stage.gd:73`, `project/features/combat/combat_arena.gd:182` (`FoeArmor.impact`, 1.0 for the six original rows), `project/features/combat/combat_arena.gd:213` (fight areas never hold the war machine), `project/boot/launch_args.gd:115` (`--foe-mix`), `project/boot/launch_args.gd:125` (`--enemy`).
- Merged `n22-guard-iface` (`e3b115826`).
- After guard's head merges: rockets and cannon shells get guard's area damage automatically (their rows carry `splash_radius_m`); check the burst ring is not drawn twice (ours + guard's); route the war machine stomp through `RivetBlast.burst` (one line in `foe_walker.gd`).
- The four new rows carry `explicit_spawn: true`: they are not in `EnemyRoster.archetypes`; street's composer asks by id. Street can drop its `StreetSquad` adapter for `squad.set_route_map(map)`. The war machine wave placement is street's composer.
- `enemies.json` will conflict with loop's tuner branch `n22-tune`: take both sides' rows; the tuner's clamps apply to the first night's values, which for the four new rows are those on this branch.

## Next steps

- Merge guard's blast and re-run the four duels: the rocket and shell hurt shares should rise (today direct hits only).
- Run the gauntlet bot against tier 4-5 waves and let the tuner move war machine hp and tell lengths inside its clamp.
- A row flag (`holdable: false`) instead of the war machine id in `combat_arena.gd:213`.
- Draw the shield robot's shove mark out to its full 1.8 m reach, and widen the war machine's stomp ring read (both view-only).
- Final looks for the four (owner's direction first).

## Astra ledger

| Call | Minutes | Verdict | Landed |
|---|---:|---|---|
| iface-rocket | 2 | abandoned | brief key names fixed |
| iface-rocket-b | 63 | accepted | `245c0e6f1`, `8e522de76` |
| film-turret | 71 | accepted (look bounced into the next brief) | `e3b115826`, `cb0aad246`, `0b29f2cb5`, `8bf86a60c` |
| shield-robot | 59 | accepted | `f42cbddd9`, `73df7e6c5`, `dec85d2b4`, `812b763f0` |
| war-machine | 51 | accepted (size of the look sent on) | `42a0e5632`, `0841836cf`, `f617df7b5` |
| ttk-polish | 53 | accepted (claw column sent on) | `8d93e6b33`, `2a1873199`, `95ef7e82a`, `02fa4eae5`, `f1f8fc6f2`, `f326e45eb` |
| melee-ttk | 6 | accepted | `90902c90e` |

What I would brief differently: give the other lanes' contract key names verbatim in the first brief (cost one abandoned call); require a 32 px/m still checked against Rivet's size before any film (three looks came back too small or too thin); say the distance for melee when asking for a weapon table (the claw was measured at 8 m); ask for a whole-file mutation run in the same brief as the behaviour, not later (the turret's run was cut by a hard stop).
