# Gauntlet run report

8 of 15 runs accepted. Average-profile waves 1 (8.01 s), 2 (7.81 s), 3 (7.17 s), 4 (9.47 s), 5 (31.82 s), 6 (10.19 s), 7 (11.36 s), 9 (20.43 s), 10 (47.72 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ 0e4bebafea5e (dirty) · 2026-11-21T00:53:06.124Z.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 3 / 3 | 5.32 | 4.92…11.82 | 4.92…11.82 | — |
| novice | 2 | 3 / 3 | 6.78 | 6.32…8.18 | 6.32…8.18 | — |
| novice | 3 | 3 / 3 | 8.1 | 6.43…9.38 | 6.43…9.38 | — |
| novice | 4 | 3 / 3 | 7.02 | 5.93…11.47 | 5.93…11.47 | — |
| novice | 5 | 2 / 3 | 43.21 | 18.78…67.63 | 18.78…67.63 | — |
| novice | 6 | 0 / 2 | not measured | not measured | not measured | — |
| average | 1 | 4 / 4 | 8.01 | 6.13…13.98 | 5.22…13.98 | miss |
| average | 2 | 4 / 4 | 7.81 | 7.27…9.18 | 6.62…9.18 | miss |
| average | 3 | 4 / 4 | 7.17 | 6.92…7.75 | 5.78…7.75 | miss |
| average | 4 | 4 / 4 | 9.47 | 8.68…11.92 | 5.85…11.92 | miss |
| average | 5 | 3 / 4 | 31.82 | 31.13…40.7 | 31.13…40.7 | miss |
| average | 6 | 2 / 3 | 10.19 | 5.77…14.62 | 5.77…14.62 | miss |
| average | 7 | 2 / 2 | 11.36 | 8.6…14.12 | 8.6…14.12 | miss |
| average | 8 | 2 / 2 | 13.48 | 10.7…16.27 | 10.7…16.27 | within 20% |
| average | 9 | 1 / 2 | 20.43 | 20.43…20.43 | 20.43…20.43 | miss |
| average | 10 | 1 / 1 | 47.72 | 47.72…47.72 | 47.72…47.72 | miss |
| average | 11 | 0 / 1 | not measured | not measured | not measured | not measured |
| expert | 1 | 1 / 1 | 12.87 | 12.87…12.87 | 12.87…12.87 | — |
| expert | 2 | 1 / 1 | 7.12 | 7.12…7.12 | 7.12…7.12 | — |
| expert | 3 | 1 / 1 | 14.28 | 14.28…14.28 | 14.28…14.28 | — |
| expert | 4 | 1 / 1 | 5.17 | 5.17…5.17 | 5.17…5.17 | — |
| expert | 5 | 1 / 1 | 82.52 | 82.52…82.52 | 82.52…82.52 | — |
| expert | 6 | 1 / 1 | 22.02 | 22.02…22.02 | 22.02…22.02 | — |
| expert | 7 | 1 / 1 | 6.92 | 6.92…6.92 | 6.92…6.92 | — |
| expert | 8 | 1 / 1 | 21.43 | 21.43…21.43 | 21.43…21.43 | — |
| expert | 9 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | No death recorded | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 3 | 3 | 0 | 5 × 1, 6 × 2 | turret_gun × 2, timeout × 1 | 0 |
| average | 4 | 4 | 0 | 5 × 1, 6 × 1, 9 × 1, 11 × 1 | turret_gun × 2, war_cannon × 1 | 1 |
| expert | 1 | 1 | 0 | 9 × 1 | turret_gun × 1 | 0 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- |
| contractor | 0 | 53.21% | 14.12 (17) | 8.14 (32) |
| patrol_cop | 0 | 82.24% | 9.88 (39) | 8.18 (10) |
| riot_cop | 0 | 50.97% | 9.38 (23) | 8.27 (26) |
| robot_gunner | 0 | 17.33% | 15.44 (8) | 8.18 (41) |
| robot_thug | 0 | 23.32% | 16.27 (9) | 8.14 (40) |
| rocket_trooper | 0 | 50.75% | 11.47 (17) | 7.8 (32) |
| sentry_turret | 0 | 5.06% | 18.32 (2) | 8.6 (47) |
| shield_robot | 0 | 9.42% | 34.08 (2) | 8.6 (47) |
| swat | 0 | 31.07% | 8.39 (18) | 9.18 (31) |
| timeout | 1 | 0% | not measured | 8.68 (49) |
| turret_gun | 5 | 0% | not measured | 8.68 (49) |
| war_cannon | 1 | 0% | not measured | 8.68 (49) |
| war_machine | 0 | 44.27% | 40.7 (7) | 8.14 (42) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. At least two pairs are needed for each interval. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | not measured | 3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| ghost_dent | wave s | not measured | 9.35 (2) | 0 | not measured | not measured | not measured | insufficient data |
| ghost_kerf | waves survived | 4 (5) | 2.5 (2) | 2 | 0.5 | 0…1 | 1 (2, all offered) | noise |
| ghost_kerf | wave s | 15.44 (5) | 8.06 (2) | 2 | 0.51 | -0.27…1.28 | 1.28 (2, all offered) | noise |
| ghost_ohm | waves survived | 4.5 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_ohm | wave s | 12.96 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_tonnage | waves survived | 3.5 (4) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_tonnage | wave s | 7.7 (4) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_10 | waves survived | 2 (1) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_10 | wave s | 34.08 (1) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_25 | waves survived | 3 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_25 | wave s | 16.7 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_10 | waves survived | not measured | 2 (6) | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_10 | wave s | not measured | 12.41 (4) | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_25 | waves survived | 3 (2) | 0.5 (2) | 2 | 2.5 | -1…6 | not measured | noise |
| stat_guard_meter_25 | wave s | 17.27 (1) | 67.63 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_10 | waves survived | 4 (2) | 7 (3) | 1 | -3 | not measured | not measured | insufficient data |
| stat_hp_max_10 | wave s | 7.69 (2) | 14.28 (3) | 1 | -1.5 | not measured | not measured | insufficient data |
| stat_hp_max_25 | waves survived | 0 (3) | 3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_25 | wave s | 67.63 (1) | 14.62 (3) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_10 | waves survived | 1.5 (2) | 2.5 (6) | 0 | not measured | not measured | 2 (2, decliners) | insufficient data |
| stat_regen_10 | wave s | 23.52 (2) | 18.78 (5) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_25 | waves survived | not measured | 1 (3) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_25 | wave s | not measured | 21.43 (3) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_10 | waves survived | not measured | 3.5 (2) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_10 | wave s | not measured | 7.7 (2) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_25 | waves survived | 1 (2) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_25 | wave s | 18.85 (2) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_chainsaw | waves survived | not measured | 1 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_chainsaw | wave s | not measured | 20.43 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_electro_baton | waves survived | not measured | 3 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_electro_baton | wave s | not measured | 14.75 (2) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | waves survived | not measured | 3 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | wave s | not measured | 17.14 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gloria | waves survived | not measured | 5 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gloria | wave s | not measured | 11.65 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_hand_cannon | waves survived | not measured | 2 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_hand_cannon | wave s | not measured | 11.34 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_katana | waves survived | not measured | 4.5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_katana | wave s | not measured | 10.98 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_machine_pistol | waves survived | not measured | 3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_machine_pistol | wave s | not measured | 9.38 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_pistol | waves survived | 6 (2) | 4 (5) | 1 | 4 | not measured | not measured | insufficient data |
| weapon_pistol | wave s | 14.75 (2) | 8.1 (5) | 1 | 3.63 | not measured | not measured | insufficient data |
| weapon_plasma_rifle | waves survived | not measured | 3 (1) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_rifle | wave s | not measured | 20.43 (1) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_sword | waves survived | not measured | 0.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_sword | wave s | not measured | 42.45 (2) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_rocket_launcher | waves survived | 0 (5) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_rocket_launcher | wave s | 18.02 (2) | not measured | 0 | not measured | not measured | not measured | insufficient data |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | not measured | 1 (5) | 0 | not measured | not measured | not measured | insufficient data |
| chainsaw | wave s | not measured | 20.43 (3) | 0 | not measured | not measured | not measured | insufficient data |
| electro_baton | waves survived | not measured | 3 (4) | 0 | not measured | not measured | not measured | insufficient data |
| electro_baton | wave s | not measured | 14.75 (2) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | waves survived | not measured | 3 (4) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | wave s | not measured | 17.14 (4) | 0 | not measured | not measured | not measured | insufficient data |
| gloria | waves survived | not measured | 5 (5) | 0 | not measured | not measured | not measured | insufficient data |
| gloria | wave s | not measured | 11.65 (5) | 0 | not measured | not measured | not measured | insufficient data |
| hand_cannon | waves survived | not measured | 2 (6) | 0 | not measured | not measured | not measured | insufficient data |
| hand_cannon | wave s | not measured | 11.34 (6) | 0 | not measured | not measured | not measured | insufficient data |
| katana | waves survived | not measured | 4.5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| katana | wave s | not measured | 10.98 (6) | 0 | not measured | not measured | not measured | insufficient data |
| machine_pistol | waves survived | not measured | 3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| machine_pistol | wave s | not measured | 9.38 (3) | 0 | not measured | not measured | not measured | insufficient data |
| pistol | waves survived | 6 (2) | 4 (5) | 1 | 4 | not measured | not measured | insufficient data |
| pistol | wave s | 14.75 (2) | 8.1 (5) | 1 | 3.63 | not measured | not measured | insufficient data |
| plasma_rifle | waves survived | not measured | 3 (1) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_rifle | wave s | not measured | 20.43 (1) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_sword | waves survived | not measured | 0.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_sword | wave s | not measured | 42.45 (2) | 0 | not measured | not measured | not measured | insufficient data |
| rocket_launcher | waves survived | 0 (5) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| rocket_launcher | wave s | 18.02 (2) | not measured | 0 | not measured | not measured | not measured | insufficient data |

## Combat telemetry

Deflects, rolls, shots and seconds in each form are medians. Parentheses count observations. Hit rate pools hits and shots only across rows measuring both. A zero denominator has no rate.

| Profile | Wave | Guard deflects (n) | Rolls (n) | Shots (n) | Hit rate (shots) | Ghost form s (n) |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | not measured | 0 (3) | 0 (3) | not measured | not measured |
| novice | 2 | not measured | 0 (3) | 0 (3) | not measured | not measured |
| novice | 3 | not measured | 0 (3) | 0 (3) | not measured | not measured |
| novice | 4 | not measured | 1 (3) | 0 (3) | not measured | not measured |
| novice | 5 | not measured | 5 (3) | 0 (3) | not measured | not measured |
| novice | 6 | not measured | 2 (2) | 0 (2) | not measured | not measured |
| average | 1 | not measured | 0.5 (4) | 0 (4) | not measured | not measured |
| average | 2 | not measured | 0 (4) | 0 (4) | not measured | not measured |
| average | 3 | not measured | 0 (4) | 0 (4) | not measured | not measured |
| average | 4 | not measured | 0.5 (4) | 0 (4) | not measured | not measured |
| average | 5 | not measured | 6 (4) | 0 (4) | not measured | not measured |
| average | 6 | not measured | 1 (3) | 0 (3) | not measured | not measured |
| average | 7 | not measured | 1 (2) | 0 (2) | not measured | not measured |
| average | 8 | not measured | 0.5 (2) | 0 (2) | not measured | not measured |
| average | 9 | not measured | 0.5 (2) | 0 (2) | not measured | not measured |
| average | 10 | not measured | 8 (1) | 0 (1) | not measured | not measured |
| average | 11 | not measured | 6 (1) | 0 (1) | not measured | not measured |
| expert | 1 | not measured | 2 (1) | 0 (1) | not measured | not measured |
| expert | 2 | not measured | 0 (1) | 0 (1) | not measured | not measured |
| expert | 3 | not measured | 2 (1) | 0 (1) | not measured | not measured |
| expert | 4 | not measured | 0 (1) | 0 (1) | not measured | not measured |
| expert | 5 | not measured | 53 (1) | 0 (1) | not measured | not measured |
| expert | 6 | not measured | 5 (1) | 0 (1) | not measured | not measured |
| expert | 7 | not measured | 0 (1) | 0 (1) | not measured | not measured |
| expert | 8 | not measured | 4 (1) | 0 (1) | not measured | not measured |
| expert | 9 | not measured | 0 (1) | 0 (1) | not measured | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 6 | 1.08 | stat_hp_max_10 → ghost_kerf → ghost_ohm → stat_damage_25 → weapon_rocket_launcher | rocket_launcher | not measured | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --controls=wheel |
| novice | 5 | 6 | 1.08 | ghost_tonnage → ghost_tonnage → stat_regen_10 → stat_hp_max_25 → weapon_rocket_launcher | rocket_launcher | not measured | node tools/dev/run.mjs gauntlet --seed=5 --bot=novice --pick=greedy --controls=wheel |
| average | 3 | 11 | 1.5 | ghost_tonnage → ghost_ohm → stat_damage_25 → stat_guard_meter_25 → stat_guard_meter_25 → ghost_kerf → ghost_ohm → stat_damage_10 → ghost_tonnage → stat_hp_max_25 | none | not measured | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel |

## Excluded runs

These inputs are retained in the batch manifest.

| File | Profile | Seed | Reason |
| --- | --- | --- | --- |
| runs/novice-1.json | novice | 1 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/novice-4.json | novice | 4 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/average-1.json | average | 1 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/expert-1.json | expert | 1 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/expert-2.json | expert | 2 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/expert-3.json | expert | 3 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
| runs/expert-5.json | expert | 5 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
