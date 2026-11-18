# Mixed squad probe

Five seeds per encounter, 20261103–20261107, at 60 Hz in headless Godot 4.7.2. City and pit clear times cover the first three waves and their gaps. Damage and deaths cover all 2,400 ticks. Quest 1 ends after the five-wave Dock 9 objective. All 15 runs reached their objective.

| Encounter | A1 clear (s) | Squad clear (s) | Change | A1 damage (HP) | Squad damage (HP) | Change | Mean deaths A1 → squad |
|---|---:|---:|---:|---:|---:|---:|---:|
| city | 17.58 | 24.86 | +41.4% | 3.60 | 2.64 | -26.7% | 0 → 0 |
| pit | 14.53 | 21.03 | +44.7% | 7.32 | 7.32 | +0.0% | 0 → 0 |
| quest1 | 35.36 | 35.36 | +0.0% | 4.68 | 4.68 | +0.0% | 0 → 0 |

Both arena clear times rose more than 25%. City damage fell 26.7%. Pit damage and all three death means matched A1. The mixed squads used two ranged tokens and the original combat weapon numbers. Neither melee row completed a swing against the moving bot. The city thug spent 45 ticks in windup. The close-range production test separately verifies a landed swing and a two-metre dodge.

## Production settings

Preferred and attack distances are in metres. A non-token guard holds a ring interpolated from attack to preferred as aggression rises. The rifle retains its own 16 m projectile range. The rotating pit list brings all five original archetypes into the street fight by wave three.

| Archetype | HP | Cover bias | Preferred / attack | Aggression | Peek (s) | Attack and rig |
|---|---:|---:|---:|---:|---:|---|
| patrol_cop | 1 | 1 | 9 / 14 | 0.5 | 0.8 | Assault rifle, patrol rig. Seeks cover at every eligible plan and never flanks. |
| riot_cop | 1 | 0 | 1.2 / 1.5 | 0.9 | 0 | Baton, 1.2 HP after 0.55 s. Shield rig closes for a locked swing. |
| swat | 1 | 0.18 | 12 / 20 | 0.7 | 1 | Assault rifle, helmet and plate carrier. Usually flanks while waiting. |
| robot_thug | 6 | 0 | 1.5 / 1.8 | 1 | 0 | Claw, 1.8 HP after 0.8 s. Gunmetal thug rig winds up its claw. |
| robot_gunner | 4 | 0 | 11 / 18 | 0.6 | 0 | Assault rifle, gunmetal thug rig with an aiming pose. Holds a ranged ring. |
| contractor | 1 | 0.65 | 9.5 / 15 | 0.7 | 1.25 | Assault rifle, patrol rig. Alternates cover and flank. |

All six rows declare assault-rifle. The four ranged rows use that combat weapon through GuardBrain.trigger. Melee uses the baton or claw reach (1.6 or 2 m, plus Rivet’s collision radius), row windup and weapon cooldown. With every swing landing, windup plus cooldown caps output at 0.69 and 0.75 HP/s respectively. The rifle produces four 0.6 HP rounds approximately every 1.8 s. Production humans have 1 HP before the existing --riot armor multiplier on the first guard from wave two.

## Observed states by archetype

Each cell counts hostile-ticks over five seeds. Cover and flank here are movement states. The separate positional cover and firing-bearing metrics remain in the JSON. The legacy Quest 1 guard appears under the default contractor id.

| city | engage | cover | flank | windup | fire | recover | panic |
|---|---:|---:|---:|---:|---:|---:|---:|
| contractor | 2696 | 340 | 216 | 6 | 74 | 280 | 52 |
| patrol_cop | 2660 | 617 | 0 | 2 | 39 | 77 | 234 |
| riot_cop | 2701 | 0 | 0 | 0 | 0 | 0 | 0 |
| robot_gunner | 3866 | 0 | 0 | 6 | 139 | 458 | 0 |
| robot_thug | 5175 | 0 | 0 | 45 | 0 | 0 | 0 |
| swat | 4318 | 246 | 522 | 8 | 156 | 497 | 0 |

| pit | engage | cover | flank | windup | fire | recover | panic |
|---|---:|---:|---:|---:|---:|---:|---:|
| contractor | 573 | 150 | 130 | 5 | 63 | 336 | 0 |
| patrol_cop | 2281 | 975 | 0 | 6 | 70 | 470 | 561 |
| riot_cop | 2356 | 0 | 0 | 0 | 0 | 0 | 0 |
| robot_gunner | 2881 | 0 | 0 | 14 | 321 | 1259 | 0 |
| robot_thug | 4213 | 0 | 0 | 0 | 0 | 0 | 0 |
| swat | 1712 | 475 | 266 | 24 | 559 | 1987 | 0 |

| quest1 | approach | burst | cooldown |
|---|---:|---:|---:|
| contractor | 25576 | 744 | 3610 |

## Determinism

The projectile extraction matched every non-timing field in all 15 original A1 guard and 15 A2 squad runs. The final guard sweep reproduced all original A1 non-timing fields. The final squad results matched the independent repeat, including the state histograms.

- A1 and final guard SHA-256 3debe07fc9fefda57340f150f89a9a99c154849f336dc8a35e916f800c60fa2b.
- Final squad SHA-256 694ded059d9df020a05571249bfc44a0ce11f7f81ce36c2a3a2eeb9e1fe08d0b.

The 15 final guard digest lines matched A1.

~~~text
fight_probe city 20261103 waves 6 digest 7a61766c8e50d05869f4a60992ece5cd79d11b15266ef2384afa28e5a372d0c2
fight_probe city 20261104 waves 6 digest 6c453d01df988d826d259f2f8a2ad11ad20cb3ddf5fe2f3ed8c7a32c0b17322f
fight_probe city 20261105 waves 6 digest 638eac3e621c0a7da3dafacb33764f94ad0ea1ca068f86c7928de71ca962eee9
fight_probe city 20261106 waves 6 digest b98df35202c6ddff8796a87c6c240ef3c7b21ac3e418b475c617261527569df3
fight_probe city 20261107 waves 5 digest d91f383ea1078089179e1850067e5a680eb23cdbb947904a4310f826e84509fb
fight_probe pit 20261103 waves 7 digest 1efb05436029012bc6de1fb538e9ccf60a6713b0b8b6792bd658aa08e6cb88c1
fight_probe pit 20261104 waves 7 digest b69d9deefdf67c5a4af3771ff85e35c73b16c8d848d559a77d099eb1dca00c42
fight_probe pit 20261105 waves 7 digest cb2515acd326c937550d7022487cfbd433f42c261d61a47c7e1d383ca522082d
fight_probe pit 20261106 waves 7 digest 3976a3c2f3c61b5b8eced3af67440ab6f7c6009229782f0a8aba645c8a21afd1
fight_probe pit 20261107 waves 7 digest 99df41cff4ce66254ee09acec482624a23572c1d5f7157f87b4fd9b18cd9671d
fight_probe quest1 20261103 waves 5 digest 0e26748f40d64c51e27d2ac3fe8c9b81d7f1723d1f9d5e61cd686d39e1bb566f
fight_probe quest1 20261104 waves 5 digest 53d9556ea0e1315b4cebb25d94b1258d22608cbe47177e4a37e89ea942ce8cb6
fight_probe quest1 20261105 waves 5 digest 3e19499c28878dac78e27a9504f3f3c4bb6f6fa93f22f666b9a6f4ea5f07a082
fight_probe quest1 20261106 waves 5 digest 02f49b97b9ccf8d34409c4996f9d612675f25eff7a3a246e8995683825319334
fight_probe quest1 20261107 waves 5 digest 167aca0103c2f65c271bf819497699917a1f9068135b61854ff240fadc9119f3
~~~

## Gates

~~~text
run_scenarios: [1/13] arena_city ok, 2.2 s
run_scenarios: [2/13] arena_pit ok, 1.9 s
run_scenarios: [3/13] arena_squad ok, 8.8 s
run_scenarios: [4/13] enemy_pit ok, 1.1 s
run_scenarios: [5/13] enemy_waves ok, 1.7 s
run_scenarios: [6/13] quest1_dent ok, 0.5 s
run_scenarios: [7/13] quest1_dent_lock ok, 0.5 s
run_scenarios: [8/13] quest1_input ok, 11.9 s
run_scenarios: [9/13] quest1_kerf ok, 0.4 s
run_scenarios: [10/13] quest1_keys ok, 0.1 s
run_scenarios: [11/13] quest1_ohm ok, 0.6 s
run_scenarios: [12/13] quest1_tonnage ok, 0.5 s
run_scenarios: [13/13] quest_collect_call ok, 2.5 s
run_scenarios: 13 ran, 0 failed
res://tests/unit/test_enemy_ai.gd
6/6 passed.
unit-tests: 40 passed, 0 failed, 0 skipped (GUT, headless)
load_all: 1670 loaded, 0 failed
lint: all 19 checks pass over 1621 GDScript files
~~~

The city scenario cleared five waves in 3,022 ticks with 180 FLANK ticks, 2 distinct flanking shooters, 50.95% positional cover and 0.00% crowding. The replay matched. Disabling separation raised crowding to 7.67%, crossing the 2% rejection threshold.

Ten flag-off scenario telemetry files matched the pre-change files byte for byte. Quest 1 input also matched after replacing only its scratch process ID. Its final replay hash was 37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a. The keys scenario writes its verdict to the log. Enemy pit and waves retained c706f7c549ec2a9d and a2eca1619e189de6.

The standalone quick parse of the three rig scripts reported dependency cascades and a PagedAllocator shutdown error. Godot’s isolated --check-only mode reported missing autoloads. An initialized headless project loaded all resources, and the arena scenario checked look selection. This headless run did not inspect rendered frames.

The commit hook?s merge-tree preview flagged a shared launch_args.gd conflict with n19-move when the registry line landed.

## Reproduction

~~~powershell
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n19/appdata/ai'
$env:GODOT_BIN = 'C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=squad --out=C:/Users/kazda/kiro/gtai-wt/n19-ai/evidence/n19-ai/probe-archetypes.json
node tools/dev/run.mjs fight_probe --all --seeds=5 --out=C:/Users/kazda/kiro/gtai-wt/n19-ai/build/dev/a3-guard-final.json
node tools/tests/run_unit.mjs --select=test_arena_squad,test_enemy_ai,test_arena_rigs,test_arena_pit_riot,test_enemy_motor
node tools/tests/run_scenarios.mjs --only=arena_pit,arena_city,enemy_pit,enemy_waves,quest_collect_call,quest1_dent,quest1_dent_lock,quest1_input,quest1_kerf,quest1_keys,quest1_ohm,quest1_tonnage,arena_squad
~~~
