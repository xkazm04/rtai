# fatality proof table

Average bot, greedy picks, waves 1..4, seeds 1..5, one melee weapon held, the signature-kill feed installed (as `--kill-feed`). Every kill of the run is listed, including the ones by allies and deploys (their weapon id). `generic` = the standard death.

chainsaw kill on a shieldless human = chainsaw_grind: 138/138 (100.0 %; bar 100 %)

| weapon | victim kind | what plays (count) |
|---|---|---|
| assault-rifle | contractor | generic: 30 |
| assault-rifle | patrol_cop | generic: 228 |
| assault-rifle | riot_cop (shield front) | generic: 28 |
| assault-rifle | rocket_trooper | generic: 19 |
| assault-rifle | swat | generic: 28 |
| chainsaw | contractor | chainsaw_grind_contractor: 13 |
| chainsaw | patrol_cop | chainsaw_grind_patrol_cop: 91 |
| chainsaw | riot_cop (shield front) | chainsaw_grind_riot_cop: 21 |
| chainsaw | rocket_trooper | chainsaw_grind_rocket_trooper: 21 |
| chainsaw | swat | chainsaw_grind_swat: 13 |
| claw | contractor | claw_rake_kill_contractor: 11 |
| claw | patrol_cop | claw_rake_kill_patrol_cop: 106 |
| claw | riot_cop (shield flank) | claw_rake_kill_riot_cop: 1 |
| claw | riot_cop (shield front) | claw_rake_kill_riot_cop: 16 |
| claw | rocket_trooper | claw_rake_kill_rocket_trooper: 15 |
| claw | swat | claw_rake_kill_swat: 14 |
| deploy_dent | contractor | generic: 1 |
| deploy_dent | patrol_cop | generic: 6 |
| deploy_dent | riot_cop (shield front) | generic: 6 |
| deploy_dent | rocket_trooper | generic: 3 |
| deploy_dent | swat | generic: 3 |
| deploy_tonnage | contractor | generic: 13 |
| deploy_tonnage | patrol_cop | generic: 40 |
| deploy_tonnage | riot_cop (shield flank) | generic: 2 |
| deploy_tonnage | riot_cop (shield front) | generic: 11 |
| deploy_tonnage | rocket_trooper | generic: 11 |
| deploy_tonnage | swat | generic: 10 |
| electro_baton | contractor | baton_overload_contractor: 17 |
| electro_baton | patrol_cop | baton_overload_patrol_cop: 111 |
| electro_baton | riot_cop (shield flank) | baton_overload_riot_cop: 1 |
| electro_baton | riot_cop (shield front) | baton_overload_riot_cop: 20 |
| electro_baton | rocket_trooper | baton_overload_rocket_trooper: 24 |
| electro_baton | swat | baton_overload_swat: 11 |
| katana | contractor | katana_split_contractor: 15 |
| katana | patrol_cop | katana_split_patrol_cop: 101 |
| katana | riot_cop (shield front) | katana_split_riot_cop: 16 |
| katana | rocket_trooper | katana_split_rocket_trooper: 19 |
| katana | swat | katana_split_swat: 13 |
| plasma_sword | contractor | plasma_sword_split_contractor: 15 |
| plasma_sword | patrol_cop | plasma_sword_split_patrol_cop: 102 |
| plasma_sword | riot_cop (shield flank) | plasma_sword_split_riot_cop: 2 |
| plasma_sword | riot_cop (shield front) | plasma_sword_split_riot_cop: 16 |
| plasma_sword | rocket_trooper | plasma_sword_split_rocket_trooper: 18 |
| plasma_sword | swat | plasma_sword_split_swat: 8 |

Every melee kill in these runs, on every victim kind that came (patrol, riot, SWAT, contractor, rocket trooper), plays its weapon's signature row (own variant): 0 generic. Waves 1..4 sent no Mulroney, warden or robot (none in the records); the gun and deploy rows above are kills by allies and ghost deploys (no signature row: generic). `shield front` = the killing blow came into the shield's face (FoeShield arc from the roster's `shield_arc_deg`), `flank` = round it.

## Card foes: what each gets from a melee kill

Read from `project/data/tables/signature_kills.json` (rows and `variants`), `project/data/tables/cast_cards.json`
(the card sheets), `project/data/tables/enemies.json` (`body`, `machine`), `KillEvent.of_fighter` (`human` = not a
boss, not a machine, `body_class` empty or `human`), `ArenaSquad` (robots get `body_class = robot`) and
`KillCardFall` (a whole-body kill on a card foe falls on his own `fall` sheet unless the style has `*` cells).

| foe | body | melee rows (chainsaw / katana / plasma sword / baton / claw) | drawn as |
|---|---|---|---|
| contractor | human | own variant in all five (`chainsaw_grind_contractor`, ...) | claw and baton: own drawn cells + fall; splits: the variant's halves |
| rocket_trooper | human | own variant in all five | as the contractor |
| sergeant_mulroney | human | no variant: the BASE row of each weapon (`chainsaw_grind`, `katana_split`, `plasma_sword_split`, `baton_overload`, `claw_rake_kill`) when he dies as a GUARD fighter; nothing when he is a boss or brain-owned (`KillEvent.human` false) | whole-body styles (baton, claw): his own `sergeant_mulroney_fall.png` via `KillCardFall`; splits: his card cut in halves (`GibCardCut` regions) |
| appliance_warden | human | as Mulroney: base rows | own `appliance_warden_fall.png` via `KillCardFall`; splits cut his card |
| robot_thug, robot_gunner | robot (`body_class = robot`) | none of the human rows; the baton's shutdown (`e.shutdown`) plays `electric_shutdown:<id>` (own variant) | `RobotShutdownFx` chassis; other weapons: the standard robot death (sparks, oil) |
| sentry_turret, shield_robot | robot, machine | as the robots: `electric_shutdown:<id>` on a baton shutdown, else none | as the robots |
| war_machine | robot, machine, `never_finish` | no human row; a baton shutdown would take the base `electric_shutdown` (no variant) | standard machine death |

Riot cop (the shielded human): every chainsaw kill in the table came into the shield's face (`shield front`: the
saw went through it, `vs_shield: through`) and plays `chainsaw_grind_riot_cop`, his own variant (the halves with the
shield plates). No riot cop died to the saw round his shield (`flank`) in these runs.
