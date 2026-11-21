# Gauntlet run report

9 of 10 runs accepted. Average-profile waves 1 (5.97 s), 2 (7.8 s), 3 (5.52 s), 4 (8.17 s), 5 (35.02 s), 9 (30.95 s), 10 (47.81 s), 11 (31.32 s), 12 (37.48 s), 13 (43.71 s), 14 (27.69 s), 15 (54.25 s), 16 (39.37 s), 17 (38 s), 18 (43.02 s), 19 (39.28 s), 20 (62.32 s), 21 (36.69 s), 22 (41.02 s), 23 (62.43 s), 24 (46.37 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ 50f0e6ae3cf3 · 2026-11-21T02:42:46.441Z.

Stalled runs by profile: average 1.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 9 / 9 | 5.97 | 5.83…6.58 | 5.12…8.1 | miss |
| average | 2 | 9 / 9 | 7.8 | 6.5…8.23 | 5.57…12.32 | miss |
| average | 3 | 9 / 9 | 5.52 | 4.38…7.53 | 2.58…10.72 | miss |
| average | 4 | 9 / 9 | 8.17 | 6.5…10.03 | 4…11.65 | miss |
| average | 5 | 9 / 9 | 35.02 | 27.75…38.62 | 15.97…56.55 | miss |
| average | 6 | 9 / 9 | 16.67 | 12.62…25.15 | 10.73…41.92 | within 20% |
| average | 7 | 9 / 9 | 13.12 | 8.55…13.9 | 7.15…20.32 | within 20% |
| average | 8 | 9 / 9 | 14.28 | 12.42…17.4 | 9.4…20.87 | within 20% |
| average | 9 | 9 / 9 | 30.95 | 21.13…37.12 | 17.37…42.05 | miss |
| average | 10 | 8 / 9 | 47.81 | 37.33…64.18 | 10.57…77.5 | miss |
| average | 11 | 8 / 8 | 31.32 | 20.75…41.28 | 9.9…53.83 | miss |
| average | 12 | 8 / 8 | 37.48 | 34.05…43.62 | 10.18…48.35 | miss |
| average | 13 | 8 / 8 | 43.71 | 29.6…53.92 | 13.28…54.52 | miss |
| average | 14 | 8 / 8 | 27.69 | 26.23…38.03 | 12.55…53.78 | miss |
| average | 15 | 8 / 8 | 54.25 | 43.83…72.68 | 37.38…83.52 | miss |
| average | 16 | 8 / 8 | 39.37 | 28.52…57.98 | 19.07…61.83 | miss |
| average | 17 | 8 / 8 | 38 | 36.68…40.4 | 21.37…51.25 | miss |
| average | 18 | 7 / 8 | 43.02 | 34.98…43.97 | 33.15…58.12 | miss |
| average | 19 | 7 / 7 | 39.28 | 29.47…56.37 | 27.25…69.17 | miss |
| average | 20 | 6 / 7 | 62.32 | 50.4…79.07 | 39.63…82.2 | miss |
| average | 21 | 6 / 6 | 36.69 | 33.2…42.38 | 32.82…48.07 | miss |
| average | 22 | 4 / 6 | 41.02 | 28.67…61.62 | 24.5…61.62 | miss |
| average | 23 | 4 / 4 | 62.43 | 51.8…83.18 | 36.38…83.18 | miss |
| average | 24 | 3 / 4 | 46.37 | 42.62…83.22 | 42.62…83.22 | miss |
| average | 25 | 0 / 3 | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 9 | 1 | 0 | 10 × 1, 18 × 1, 20 × 1, 22 × 2, 24 × 1, 25 × 3 | turret_gun × 2, war_cannon × 2 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 5 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 75.95% | 33.15 (125) | 14.28 (57) |
| patrol_cop | 0 | — | 88.57% | 32.28 (154) | 17.82 (28) |
| riot_cop | 0 | — | 72.03% | 34.05 (121) | 17 (61) |
| robot_gunner | 0 | — | 67.31% | 38 (98) | 12.37 (84) |
| robot_thug | 0 | — | 62.15% | 36.38 (95) | 13.12 (87) |
| rocket_trooper | 0 | — | 72.37% | 34.98 (117) | 13.63 (65) |
| sentry_turret | 2 | turret_gun × 2 | 71.27% | 38.3 (99) | 10.73 (83) |
| shield_robot | 0 | — | 67.7% | 41.23 (83) | 12.67 (99) |
| swat | 0 | — | 70.12% | 34.14 (116) | 19.68 (66) |
| war_machine | 2 | war_cannon × 2 | 27.15% | 43.83 (31) | 26.02 (151) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. At least two pairs are needed for each interval. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 3.5 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_dent | wave s | 40.68 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_kerf | waves survived | 7 (7) | 2 (1) | 1 | 4 | not measured | not measured | insufficient data |
| ghost_kerf | wave s | 40.66 (7) | 51.12 (1) | 1 | -10.46 | not measured | not measured | insufficient data |
| ghost_ohm | waves survived | 16 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_ohm | wave s | 39.5 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_tonnage | waves survived | 14 (9) | not measured | 0 | not measured | not measured | 12 (2, all offered) | insufficient data |
| ghost_tonnage | wave s | 36.22 (8) | not measured | 0 | not measured | not measured | 25.91 (2, all offered) | insufficient data |
| stat_damage_10 | waves survived | 18 (8) | not measured | 0 | not measured | not measured | 5 (2, all offered) | insufficient data |
| stat_damage_10 | wave s | 38.3 (8) | not measured | 0 | not measured | not measured | 6.33 (2, all offered) | insufficient data |
| stat_damage_25 | waves survived | 14 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_25 | wave s | 40.53 (6) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_10 | waves survived | 14 (9) | not measured | 0 | not measured | not measured | 3 (2, all offered) | insufficient data |
| stat_guard_meter_10 | wave s | 36.66 (9) | not measured | 0 | not measured | not measured | 9.16 (2, all offered) | insufficient data |
| stat_guard_meter_25 | waves survived | 4 (6) | 7.5 (2) | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_25 | wave s | 43.55 (5) | 32.13 (2) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_10 | waves survived | 17 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_10 | wave s | 35.02 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_25 | waves survived | 15 (7) | 3 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_25 | wave s | 37.78 (7) | 61.83 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_10 | waves survived | 14 (8) | 8 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_10 | wave s | 40.51 (8) | 8.87 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_25 | waves survived | 4 (7) | 8 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_25 | wave s | 40.62 (7) | 35.35 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_10 | waves survived | 15 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_10 | wave s | 38.22 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_25 | waves survived | 3 (7) | 11 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_25 | wave s | 41.53 (6) | 39.87 (1) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_chainsaw | waves survived | 3.5 (6) | 18 (3) | 1 | -2 | not measured | 2 (2, all offered) | insufficient data |
| weapon_chainsaw | wave s | 41.51 (6) | 35.73 (3) | 1 | -0.37 | not measured | 23.48 (2, all offered) | insufficient data |
| weapon_electro_baton | waves survived | 11 (6) | 11 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_electro_baton | wave s | 38.66 (6) | 30.3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | waves survived | 5 (6) | 15 (2) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | wave s | 39.79 (6) | 39.4 (2) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gatling | waves survived | 12 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gatling | wave s | 39.57 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gloria | waves survived | 3 (5) | 14 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gloria | wave s | 46.37 (3) | 30.4 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_hand_cannon | waves survived | 10 (5) | 11.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_hand_cannon | wave s | 46.37 (5) | 37.37 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_katana | waves survived | 4 (3) | 17 (6) | 1 | 2 | not measured | not measured | insufficient data |
| weapon_katana | wave s | 55.22 (2) | 33.63 (6) | 1 | -4.98 | not measured | not measured | insufficient data |
| weapon_machine_pistol | waves survived | 4 (6) | 11 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_machine_pistol | wave s | 41.19 (6) | 35.47 (3) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_pistol | waves survived | 12 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_pistol | wave s | 39.53 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_rifle | waves survived | 6.5 (4) | 17 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_rifle | wave s | 39.7 (4) | 36.68 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_sword | waves survived | 11.5 (6) | 15.5 (2) | 2 | -5.5 | -7…-4 | not measured | insufficient data |
| weapon_plasma_sword | wave s | 37.37 (6) | 40.82 (2) | 2 | -7.93 | -13.55…-2.32 | not measured | insufficient data |
| weapon_rocket_launcher | waves survived | 9.5 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_rocket_launcher | wave s | 42.07 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 3.5 (6) | 18 (3) | 1 | -2 | not measured | 2 (2, all offered) | insufficient data |
| chainsaw | wave s | 41.51 (6) | 35.73 (3) | 1 | -0.37 | not measured | 23.48 (2, all offered) | insufficient data |
| electro_baton | waves survived | 11 (6) | 11 (3) | 0 | not measured | not measured | not measured | insufficient data |
| electro_baton | wave s | 38.66 (6) | 30.3 (3) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | waves survived | 5 (6) | 15 (2) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | wave s | 39.79 (6) | 39.4 (2) | 0 | not measured | not measured | not measured | insufficient data |
| gatling | waves survived | 12 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| gatling | wave s | 39.57 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| gloria | waves survived | 3 (5) | 14 (4) | 0 | not measured | not measured | not measured | insufficient data |
| gloria | wave s | 46.37 (3) | 30.4 (4) | 0 | not measured | not measured | not measured | insufficient data |
| hand_cannon | waves survived | 10 (5) | 11.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| hand_cannon | wave s | 46.37 (5) | 37.37 (4) | 0 | not measured | not measured | not measured | insufficient data |
| katana | waves survived | 4 (3) | 17 (6) | 1 | 2 | not measured | not measured | insufficient data |
| katana | wave s | 55.22 (2) | 33.63 (6) | 1 | -4.98 | not measured | not measured | insufficient data |
| machine_pistol | waves survived | 4 (6) | 11 (3) | 0 | not measured | not measured | not measured | insufficient data |
| machine_pistol | wave s | 41.19 (6) | 35.47 (3) | 0 | not measured | not measured | not measured | insufficient data |
| pistol | waves survived | 12 (9) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| pistol | wave s | 39.53 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| plasma_rifle | waves survived | 6.5 (4) | 17 (5) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_rifle | wave s | 39.7 (4) | 36.68 (5) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_sword | waves survived | 11.5 (6) | 15.5 (2) | 2 | -5.5 | -7…-4 | not measured | insufficient data |
| plasma_sword | wave s | 37.37 (6) | 40.82 (2) | 2 | -7.93 | -13.55…-2.32 | not measured | insufficient data |
| rocket_launcher | waves survived | 9.5 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| rocket_launcher | wave s | 42.07 (8) | not measured | 0 | not measured | not measured | not measured | insufficient data |

## Combat telemetry

Deflects, rolls, shots and seconds in each form are medians. Parentheses count observations. Hit rate pools hits and shots only across rows measuring both. A zero denominator has no rate.

| Profile | Wave | Guard deflects (n) | Rolls (n) | Shots (n) | Hit rate (shots) | dent s (n) | kerf s (n) | ohm s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | not measured | 1 (9) | 0 (9) | not measured | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 2 | not measured | 0 (9) | 0 (9) | not measured | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 3 | not measured | 0 (9) | 0 (9) | 500% (8) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 4 | not measured | 1 (9) | 0 (9) | 453.33% (15) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 5 | not measured | 7 (9) | 0 (9) | 1164.71% (51) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 6 | not measured | 3 (9) | 0 (9) | 715.15% (33) | 0 (9) | 0 (9) | 0 (9) | 7.1 (9) |
| average | 7 | not measured | 1 (9) | 8 (9) | 284.91% (212) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 8 | not measured | 3 (9) | 23 (9) | 353.94% (343) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 9 | not measured | 4 (9) | 37 (9) | 103.83% (653) | 0 (9) | 0 (9) | 0 (9) | 0 (9) |
| average | 10 | not measured | 9 (9) | 67 (9) | 101.49% (939) | 0 (9) | 0 (9) | 0.23 (9) | 7.1 (9) |
| average | 11 | not measured | 9 (8) | 36.5 (8) | 121.96% (510) | 0 (8) | 0 (8) | 0 (8) | 7.1 (8) |
| average | 12 | not measured | 8 (8) | 64 (8) | 433.13% (670) | 0 (8) | 0 (8) | 0 (8) | 7.1 (8) |
| average | 13 | not measured | 6.5 (8) | 43 (8) | 484.35% (671) | 0 (8) | 0 (8) | 6.37 (8) | 7.1 (8) |
| average | 14 | not measured | 9 (8) | 25.5 (8) | 262.95% (440) | 0 (8) | 0 (8) | 3.65 (8) | 3.55 (8) |
| average | 15 | not measured | 12 (8) | 94.5 (8) | 242.98% (1019) | 0 (8) | 0 (8) | 7.3 (8) | 7.1 (8) |
| average | 16 | not measured | 14 (8) | 58.5 (8) | 264.18% (765) | 0 (8) | 0 (8) | 7.3 (8) | 7.1 (8) |
| average | 17 | not measured | 11.5 (8) | 43 (8) | 836.89% (534) | 0 (8) | 1.02 (8) | 5.01 (8) | 7.1 (8) |
| average | 18 | not measured | 13 (8) | 61.5 (8) | 769.35% (682) | 0 (8) | 4.91 (8) | 7.3 (8) | 7.1 (8) |
| average | 19 | not measured | 13 (7) | 55 (7) | 214.73% (353) | 0 (7) | 9.13 (7) | 7.3 (7) | 7.1 (7) |
| average | 20 | not measured | 19 (7) | 165 (7) | 389.86% (1617) | 0 (7) | 0.72 (7) | 14.58 (7) | 7.1 (7) |
| average | 21 | not measured | 19.5 (6) | 71 (6) | 578.19% (454) | 0 (6) | 5.5 (6) | 7.3 (6) | 7.1 (6) |
| average | 22 | not measured | 12 (6) | 64 (6) | 334.59% (555) | 0 (6) | 3.7 (6) | 7.3 (6) | 7.1 (6) |
| average | 23 | not measured | 23 (4) | 80.5 (4) | 189.83% (354) | 0 (4) | 8.25 (4) | 7.3 (4) | 7.1 (4) |
| average | 24 | not measured | 26 (4) | 86.5 (4) | 660.66% (333) | 0 (4) | 9.84 (4) | 7.3 (4) | 7.1 (4) |
| average | 25 | not measured | 18 (3) | 7 (3) | 652.38% (84) | 0 (3) | 3.85 (3) | 7.3 (3) | 1.98 (3) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 5 | 25 | 2.4 | stat_speed_10 → stat_guard_meter_10 → ghost_tonnage → stat_damage_10 → ghost_ohm → weapon_flamethrower → stat_hp_max_10 → weapon_gatling → stat_hp_max_25 → stat_regen_25 → stat_regen_10 → weapon_hand_cannon → weapon_electro_baton → weapon_rocket_launcher → weapon_pistol → weapon_plasma_rifle → ghost_kerf → weapon_gloria → stat_damage_25 → weapon_katana → stat_speed_25 → weapon_chainsaw → ghost_dent → stat_guard_meter_25 | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, pistol, plasma_rifle, rocket_launcher | tonnage | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel |
| average | 8 | 25 | 2.31 | stat_hp_max_10 → ghost_tonnage → stat_hp_max_25 → weapon_electro_baton → stat_damage_25 → weapon_gatling → weapon_plasma_sword → ghost_ohm → stat_regen_10 → ghost_kerf → stat_regen_25 → ghost_dent → stat_guard_meter_25 → weapon_rocket_launcher → stat_guard_meter_10 → stat_damage_10 → stat_speed_10 → weapon_pistol → weapon_flamethrower → weapon_machine_pistol → weapon_gloria → weapon_chainsaw → weapon_hand_cannon → stat_speed_25 | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, machine_pistol, pistol, plasma_sword, rocket_launcher | ohm | node tools/dev/run.mjs gauntlet --seed=8 --bot=average --pick=greedy --controls=wheel |
| average | 9 | 25 | 2.31 | stat_damage_10 → stat_hp_max_10 → ghost_ohm → stat_guard_meter_10 → weapon_rocket_launcher → stat_speed_10 → stat_damage_25 → stat_regen_10 → weapon_chainsaw → ghost_tonnage → weapon_gatling → stat_speed_25 → ghost_dent → weapon_hand_cannon → weapon_machine_pistol → stat_hp_max_25 → weapon_electro_baton → weapon_plasma_sword → stat_guard_meter_25 → ghost_kerf → weapon_pistol → stat_regen_25 → weapon_flamethrower → weapon_gloria | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, machine_pistol, pistol, plasma_sword, rocket_launcher | ohm | node tools/dev/run.mjs gauntlet --seed=9 --bot=average --pick=greedy --controls=wheel |

## Excluded runs

These inputs are retained in the batch manifest.

| File | Profile | Seed | Reason |
| --- | --- | --- | --- |
| runs/average-10.json | average | 10 | FAIL exit 1 (fail); SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
