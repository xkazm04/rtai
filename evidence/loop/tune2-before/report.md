# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 1 (6.17 s), 2 (6.75 s), 3 (6.13 s), 4 (7.96 s), 5 (31.12 s), 9 (25.13 s), 10 (38.63 s), 11 (28.08 s), 12 (30.84 s), 13 (32.61 s), 14 (29.31 s), 15 (47.47 s), 16 (49.8 s), 17 (38 s), 18 (38.37 s), 19 (39.22 s), 20 (54.77 s), 21 (41.97 s), 22 (45.22 s), 23 (51.8 s), 24 (44.49 s), 25 (47.58 s), 26 (58.53 s), 27 (35.28 s), 28 (72.03 s), 29 (54.46 s), 30 (58.22 s), 31 (66.38 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ e04de550610b (dirty) · 2026-11-21T04:00:05.137Z.

Stalled runs by profile: average 0.

Capped alive by profile: average 1.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 30 / 30 | 6.17 | 5.57…6.5 | 3.68…13.42 | miss |
| average | 2 | 30 / 30 | 6.75 | 6.4…7.82 | 5.4…12.32 | miss |
| average | 3 | 30 / 30 | 6.13 | 4.58…8.07 | 2.58…11.88 | miss |
| average | 4 | 30 / 30 | 7.96 | 5.87…9.6 | 3.47…14.35 | miss |
| average | 5 | 30 / 30 | 31.12 | 25.67…37.87 | 9.02…78.25 | miss |
| average | 6 | 30 / 30 | 14.03 | 11.63…19.7 | 7.48…41.92 | within 20% |
| average | 7 | 30 / 30 | 13.77 | 9.42…16.62 | 7.15…46.62 | within 20% |
| average | 8 | 30 / 30 | 15.32 | 11.6…17.73 | 6.02…31.78 | within 20% |
| average | 9 | 29 / 30 | 25.13 | 18.97…30.95 | 11.32…46.58 | miss |
| average | 10 | 26 / 29 | 38.63 | 30.03…54.72 | 10.57…77.5 | miss |
| average | 11 | 26 / 26 | 28.08 | 21.2…40.62 | 9.9…89.28 | miss |
| average | 12 | 26 / 26 | 30.84 | 20.58…41.12 | 7.85…76.72 | miss |
| average | 13 | 26 / 26 | 32.61 | 23.72…42.75 | 13.28…58.25 | miss |
| average | 14 | 24 / 26 | 29.31 | 24.78…35.6 | 12.55…64.62 | miss |
| average | 15 | 23 / 24 | 47.47 | 37.38…70.45 | 24.02…88.22 | miss |
| average | 16 | 23 / 23 | 49.8 | 28.52…55.02 | 18.8…66.43 | miss |
| average | 17 | 22 / 23 | 38 | 35.2…43.93 | 21.37…74.08 | miss |
| average | 18 | 20 / 22 | 38.37 | 33.15…48.03 | 24.6…70.87 | miss |
| average | 19 | 20 / 20 | 39.22 | 29.22…56.37 | 17.85…69.72 | miss |
| average | 20 | 16 / 20 | 54.77 | 39.63…72.22 | 17.33…82.2 | miss |
| average | 21 | 16 / 16 | 41.97 | 35.08…52.2 | 29.42…77.77 | miss |
| average | 22 | 14 / 16 | 45.22 | 31.2…61.62 | 24.5…76.92 | miss |
| average | 23 | 13 / 14 | 51.8 | 44.4…65.4 | 24.18…83.18 | miss |
| average | 24 | 10 / 13 | 44.49 | 39.03…55.2 | 18.43…83.22 | miss |
| average | 25 | 6 / 10 | 47.58 | 38.43…58.72 | 38.08…77.92 | miss |
| average | 26 | 5 / 6 | 58.53 | 49.03…65.1 | 32.03…80.93 | miss |
| average | 27 | 4 / 5 | 35.28 | 31.47…78.58 | 23.85…78.58 | miss |
| average | 28 | 2 / 4 | 72.03 | 70.67…73.4 | 70.67…73.4 | miss |
| average | 29 | 2 / 2 | 54.46 | 51.65…57.27 | 51.65…57.27 | miss |
| average | 30 | 1 / 2 | 58.22 | 58.22…58.22 | 58.22…58.22 | miss |
| average | 31 | 1 / 1 | 66.38 | 66.38…66.38 | 66.38…66.38 | miss |
| average | 32 | 0 / 1 | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 30 | 29 | 0 | 1 | 0 | 9 × 1, 10 × 3, 14 × 2, 15 × 1, 17 × 1, 18 × 2, 20 × 4, 22 × 2, 23 × 1, 24 × 3, 25 × 4, 26 × 1, 27 × 1, 28 × 2, 30 × 1 | sentry_turret × 6, war_machine × 4, shield_robot × 2 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 17 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 72.44% | 31.88 (380) | 16.4 (215) |
| patrol_cop | 0 | — | 88.64% | 28.8 (510) | 16.78 (85) |
| riot_cop | 0 | — | 73.35% | 30.87 (395) | 13.82 (200) |
| robot_gunner | 0 | — | 70.56% | 34.62 (336) | 11.78 (259) |
| robot_thug | 0 | — | 68.87% | 33.17 (334) | 11.63 (261) |
| rocket_trooper | 0 | — | 74.32% | 32.13 (384) | 14.48 (211) |
| sentry_turret | 6 | — | 68.92% | 36.57 (317) | 11.64 (278) |
| shield_robot | 2 | — | 67.24% | 41.73 (265) | 13.42 (330) |
| swat | 0 | — | 72.75% | 30.77 (392) | 16.15 (203) |
| war_machine | 4 | — | 25.44% | 39.77 (102) | 23.72 (493) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 10 (27) | 6 (1) | 1 | 0 | not measured | not measured (5, all offered) | too few pairs |
| ghost_dent | wave s | 37.82 (23) | 18.18 (1) | 1 | -5.14 | not measured | not measured (3, all offered) | too few pairs |
| ghost_kerf | waves survived | 7.5 (24) | 2 (1) | 1 | 6 | not measured | not measured (4, all offered) | too few pairs |
| ghost_kerf | wave s | 39.15 (23) | 51.12 (1) | 1 | -10.87 | not measured | not measured (4, all offered) | too few pairs |
| ghost_ohm | waves survived | 16 (26) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_ohm | wave s | 37.31 (26) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | waves survived | 12 (28) | not measured | 0 | not measured | not measured | 17 (6, all offered) | insufficient data |
| ghost_tonnage | wave s | 35.35 (27) | not measured | 0 | not measured | not measured | 21.07 (6, all offered) | insufficient data |
| stat_damage_10 | waves survived | 16 (29) | not measured | 0 | not measured | not measured | 10 (8, all offered) | insufficient data |
| stat_damage_10 | wave s | 32.26 (29) | not measured | 0 | not measured | not measured | 13 (8, all offered) | insufficient data |
| stat_damage_25 | waves survived | 13 (22) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_damage_25 | wave s | 38.8 (22) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 14 (28) | 4 (2) | 2 | 17 | 16…18 | 6 (10, all offered) | higher |
| stat_guard_meter_10 | wave s | 34.75 (28) | 14.99 (2) | 2 | 23.29 | 22.37…24.22 | 9.16 (10, all offered) | higher |
| stat_guard_meter_25 | waves survived | 5.5 (24) | 8.5 (4) | 3 | -10 | -11…13 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 39.85 (23) | 32.13 (4) | 3 | -10.22 | -17.69…-3.38 | not measured (4, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 13 (29) | 5 (1) | 1 | 19 | not measured | 7 (7, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 34.21 (28) | 16.62 (1) | 1 | 18.57 | not measured | 21.37 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 9 (21) | 3 (5) | 4 | 8 | -6…15 | not measured (5, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 37.78 (21) | 31.54 (4) | 3 | -6.02 | -20.45…8.93 | not measured (4, all offered) | too few pairs |
| stat_regen_10 | waves survived | 11.5 (26) | 9.5 (4) | 2 | 9.5 | 5…14 | 11 (6, all offered) | noise |
| stat_regen_10 | wave s | 40.51 (24) | 19.48 (4) | 2 | 13.43 | 7…19.85 | 8.91 (6, all offered) | higher |
| stat_regen_25 | waves survived | 6.5 (22) | 8 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_25 | wave s | 41.63 (20) | 35.35 (1) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_speed_10 | waves survived | 13 (29) | 6 (1) | 1 | 18 | not measured | 7 (7, all offered) | insufficient data |
| stat_speed_10 | wave s | 36.57 (29) | 22.76 (1) | 1 | 21.79 | not measured | 11.79 (7, all offered) | insufficient data |
| stat_speed_25 | waves survived | 8.5 (22) | 5 (4) | 2 | -0.5 | -3…2 | not measured (3, all offered) | too few pairs |
| stat_speed_25 | wave s | 37.31 (20) | 33.53 (4) | 1 | -8.9 | not measured | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 4 (18) | 14 (11) | 1 | 4 | not measured | 9 (7, all offered) | insufficient data |
| weapon_chainsaw | wave s | 43.85 (18) | 27.17 (11) | 1 | 9.57 | not measured | 7.18 (7, all offered) | insufficient data |
| weapon_electro_baton | waves survived | 8.5 (16) | 8 (13) | 1 | 10 | not measured | 13 (6, all offered) | insufficient data |
| weapon_electro_baton | wave s | 43.38 (14) | 30.16 (12) | 0 | not measured | not measured | 15.83 (6, all offered) | insufficient data |
| weapon_flamethrower | waves survived | 4 (19) | 12 (9) | 2 | -3.5 | -11…4 | not measured (5, all offered) | too few pairs |
| weapon_flamethrower | wave s | 39.79 (18) | 33.32 (9) | 2 | -7.78 | -21.07…5.52 | not measured (5, all offered) | too few pairs |
| weapon_gatling | waves survived | 12 (26) | not measured | 0 | not measured | not measured | 10 (8, all offered) | insufficient data |
| weapon_gatling | wave s | 38.94 (26) | not measured | 0 | not measured | not measured | 9.79 (8, all offered) | insufficient data |
| weapon_gloria | waves survived | 5 (17) | 12 (13) | 1 | 2 | not measured | not measured (4, all offered) | too few pairs |
| weapon_gloria | wave s | 42.56 (14) | 25.51 (13) | 1 | 5.8 | not measured | not measured (4, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 8 (15) | 11 (15) | 2 | 4 | 1…7 | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 46.79 (14) | 28.5 (15) | 2 | 8.13 | 2.35…13.92 | not measured (5, all offered) | too few pairs |
| weapon_katana | waves survived | 4 (17) | 17 (13) | 4 | 1 | -8…3 | not measured (5, all offered) | too few pairs |
| weapon_katana | wave s | 45.39 (16) | 30.23 (13) | 4 | 0.08 | -7.98…12.75 | not measured (5, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 8 (16) | 9 (13) | 2 | -0.5 | -5…4 | not measured (4, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 41.29 (16) | 32.9 (13) | 2 | 11.22 | 1.42…21.01 | not measured (4, all offered) | too few pairs |
| weapon_pistol | waves survived | 9 (25) | 12 (3) | 1 | -2 | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 39.19 (22) | 31.48 (3) | 1 | -6.55 | not measured | not measured (4, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 6 (17) | 7 (13) | 2 | 0 | -8…8 | 9 (6, all offered) | noise |
| weapon_plasma_rifle | wave s | 38.97 (16) | 36.68 (13) | 2 | -7.92 | -19.72…3.87 | 20.62 (6, all offered) | noise |
| weapon_plasma_sword | waves survived | 7.5 (18) | 10 (10) | 4 | 4 | -7…11 | 12 (6, all offered) | noise |
| weapon_plasma_sword | wave s | 41.8 (18) | 29 (10) | 4 | 4.21 | -13.55…8.27 | 16.55 (6, all offered) | noise |
| weapon_rocket_launcher | waves survived | 10.5 (24) | 2 (3) | 3 | 12 | 1…14 | not measured (5, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 41.87 (24) | 20.5 (3) | 3 | 17.18 | -0.93…18.64 | not measured (5, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 4 (18) | 14 (11) | 1 | 4 | not measured | 9 (7, all offered) | insufficient data |
| chainsaw | wave s | 43.85 (18) | 27.17 (11) | 1 | 9.57 | not measured | 7.18 (7, all offered) | insufficient data |
| electro_baton | waves survived | 8.5 (16) | 8 (13) | 1 | 10 | not measured | 13 (6, all offered) | insufficient data |
| electro_baton | wave s | 43.38 (14) | 30.16 (12) | 0 | not measured | not measured | 15.83 (6, all offered) | insufficient data |
| flamethrower | waves survived | 4 (19) | 12 (9) | 2 | -3.5 | -11…4 | not measured (5, all offered) | too few pairs |
| flamethrower | wave s | 39.79 (18) | 33.32 (9) | 2 | -7.78 | -21.07…5.52 | not measured (5, all offered) | too few pairs |
| gatling | waves survived | 12 (26) | not measured | 0 | not measured | not measured | 10 (8, all offered) | insufficient data |
| gatling | wave s | 38.94 (26) | not measured | 0 | not measured | not measured | 9.79 (8, all offered) | insufficient data |
| gloria | waves survived | 5 (17) | 12 (13) | 1 | 2 | not measured | not measured (4, all offered) | too few pairs |
| gloria | wave s | 42.56 (14) | 25.51 (13) | 1 | 5.8 | not measured | not measured (4, all offered) | too few pairs |
| hand_cannon | waves survived | 8 (15) | 11 (15) | 2 | 4 | 1…7 | not measured (5, all offered) | too few pairs |
| hand_cannon | wave s | 46.79 (14) | 28.5 (15) | 2 | 8.13 | 2.35…13.92 | not measured (5, all offered) | too few pairs |
| katana | waves survived | 4 (17) | 17 (13) | 4 | 1 | -8…3 | not measured (5, all offered) | too few pairs |
| katana | wave s | 45.39 (16) | 30.23 (13) | 4 | 0.08 | -7.98…12.75 | not measured (5, all offered) | too few pairs |
| machine_pistol | waves survived | 8 (16) | 9 (13) | 2 | -0.5 | -5…4 | not measured (4, all offered) | too few pairs |
| machine_pistol | wave s | 41.29 (16) | 32.9 (13) | 2 | 11.22 | 1.42…21.01 | not measured (4, all offered) | too few pairs |
| pistol | waves survived | 9 (25) | 12 (3) | 1 | -2 | not measured | not measured (5, all offered) | too few pairs |
| pistol | wave s | 39.19 (22) | 31.48 (3) | 1 | -6.55 | not measured | not measured (4, all offered) | too few pairs |
| plasma_rifle | waves survived | 6 (17) | 7 (13) | 2 | 0 | -8…8 | 9 (6, all offered) | noise |
| plasma_rifle | wave s | 38.97 (16) | 36.68 (13) | 2 | -7.92 | -19.72…3.87 | 20.62 (6, all offered) | noise |
| plasma_sword | waves survived | 7.5 (18) | 10 (10) | 4 | 4 | -7…11 | 12 (6, all offered) | noise |
| plasma_sword | wave s | 41.8 (18) | 29 (10) | 4 | 4.21 | -13.55…8.27 | 16.55 (6, all offered) | noise |
| rocket_launcher | waves survived | 10.5 (24) | 2 (3) | 3 | 12 | 1…14 | not measured (5, all offered) | too few pairs |
| rocket_launcher | wave s | 41.87 (24) | 20.5 (3) | 3 | 17.18 | -0.93…18.64 | not measured (5, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | not measured | 0 (30) | 0 (30) | 4 (30) | not measured | not measured | not measured | 6.17 (30) | not measured |
| average | 2 | not measured | 0 (30) | 0 (30) | 6 (30) | not measured | 0.35 (1) | not measured | 6.75 (30) | not measured |
| average | 3 | not measured | 0 (30) | 0 (30) | 5 (30) | not measured | 1.37 (3) | 4.42 (1) | 5.5 (30) | 5.95 (2) |
| average | 4 | not measured | 1 (30) | 0 (30) | 6 (30) | not measured | 3.65 (3) | not measured | 6.77 (29) | 1.72 (3) |
| average | 5 | not measured | 4 (30) | 0 (30) | 47.5 (30) | not measured | 1.1 (3) | 7.3 (9) | 25.96 (30) | 7.1 (6) |
| average | 6 | not measured | 2.5 (30) | 0 (30) | 26 (30) | not measured | 3.38 (2) | 4.3 (4) | 12.54 (30) | 7.1 (10) |
| average | 7 | not measured | 2 (30) | 6 (30) | 27 (30) | not measured | 5.5 (2) | 7.3 (5) | 11.07 (30) | 7.1 (4) |
| average | 8 | not measured | 3.5 (30) | 25.5 (30) | 33.5 (30) | not measured | 3.25 (7) | 7.3 (6) | 10.24 (30) | 7.1 (8) |
| average | 9 | not measured | 5.5 (30) | 40.5 (30) | 68.5 (30) | not measured | 1.42 (7) | 7.3 (12) | 18.82 (30) | 7.1 (11) |
| average | 10 | not measured | 9 (29) | 52 (29) | 96 (29) | not measured | 5.51 (6) | 7.3 (16) | 28.42 (29) | 14.2 (15) |
| average | 11 | not measured | 7 (26) | 51.5 (26) | 67 (26) | not measured | 1.59 (8) | 7.3 (9) | 21.79 (26) | 7.1 (14) |
| average | 12 | not measured | 6.5 (26) | 60 (26) | 101 (26) | not measured | 5.47 (9) | 7.3 (10) | 22.8 (26) | 7.1 (16) |
| average | 13 | not measured | 9 (26) | 56.5 (26) | 99 (26) | not measured | 4.97 (9) | 7.3 (14) | 22.73 (26) | 7.1 (16) |
| average | 14 | not measured | 10 (26) | 46 (26) | 78.5 (26) | not measured | 4.31 (10) | 7.3 (14) | 21.65 (26) | 7.1 (16) |
| average | 15 | not measured | 15 (24) | 66.5 (24) | 122.5 (24) | not measured | 5.13 (8) | 7.3 (21) | 31.54 (24) | 7.1 (19) |
| average | 16 | not measured | 11 (23) | 86 (23) | 126 (23) | not measured | 3.78 (9) | 7.3 (17) | 30.7 (23) | 7.1 (15) |
| average | 17 | not measured | 12 (23) | 79 (23) | 118 (23) | not measured | 5.5 (13) | 7.3 (14) | 25.73 (23) | 7.1 (18) |
| average | 18 | not measured | 13.5 (22) | 49 (22) | 103.5 (22) | not measured | 5.5 (11) | 7.3 (17) | 23.27 (22) | 7.1 (17) |
| average | 19 | not measured | 13 (20) | 52 (20) | 108 (20) | not measured | 5.5 (13) | 7.3 (15) | 22.52 (20) | 7.1 (15) |
| average | 20 | not measured | 19 (20) | 61.5 (20) | 144.5 (20) | not measured | 5.5 (13) | 9.48 (18) | 33.1 (20) | 7.1 (15) |
| average | 21 | not measured | 18 (16) | 88.5 (16) | 135.5 (16) | not measured | 5.5 (12) | 7.3 (13) | 24.49 (16) | 7.1 (12) |
| average | 22 | not measured | 13.5 (16) | 70 (16) | 166.5 (16) | not measured | 5 (12) | 7.3 (14) | 25.3 (16) | 7.1 (12) |
| average | 23 | not measured | 16.5 (14) | 85 (14) | 174 (14) | not measured | 5.68 (9) | 7.3 (13) | 34.25 (14) | 7.1 (12) |
| average | 24 | not measured | 18 (13) | 104 (13) | 133 (13) | not measured | 5.5 (12) | 7.3 (12) | 29.3 (13) | 7.1 (11) |
| average | 25 | not measured | 16.5 (10) | 76 (10) | 124.5 (10) | not measured | 5.5 (8) | 7.3 (10) | 28.67 (10) | 7.1 (9) |
| average | 26 | not measured | 24 (6) | 223.5 (6) | 3940.5 (6) | not measured | 3.94 (6) | 7.3 (6) | 43.02 (6) | 10.65 (4) |
| average | 27 | not measured | 14 (5) | 72 (5) | 227 (5) | not measured | 6.22 (5) | 10.95 (4) | 25.58 (5) | 7.1 (3) |
| average | 28 | not measured | 23.5 (4) | 104.5 (4) | 221 (4) | not measured | 7.12 (3) | 18.25 (4) | 54.02 (4) | 7.1 (2) |
| average | 29 | not measured | 23 (2) | 82.5 (2) | 143.5 (2) | not measured | 2.24 (2) | 7.3 (2) | 37.81 (2) | 7.1 (2) |
| average | 30 | not measured | 19.5 (2) | 47.5 (2) | 149 (2) | not measured | 10.08 (1) | 12.22 (2) | 31.33 (2) | 7.1 (1) |
| average | 31 | not measured | 19 (1) | 113 (1) | 171 (1) | not measured | 4.82 (1) | 14.6 (1) | 39.87 (1) | 7.1 (1) |
| average | 32 | not measured | not measured | not measured | not measured | 0 (1) | 0 (1) | 14.6 (1) | not measured | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 32 | 2.5 | stat_damage_10 → stat_hp_max_10 → stat_guard_meter_10 → stat_regen_25 → stat_damage_25 → ghost_ohm → stat_speed_10 → stat_hp_max_25 → weapon_pistol → ghost_tonnage → weapon_katana → stat_speed_25 → stat_guard_meter_25 → ghost_dent → weapon_machine_pistol → weapon_rocket_launcher → weapon_gatling → weapon_plasma_sword → weapon_gloria → ghost_kerf → weapon_electro_baton → stat_regen_10 → weapon_hand_cannon → weapon_flamethrower → weapon_plasma_rifle → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=10 --bot=average --pick=greedy --controls=wheel |
