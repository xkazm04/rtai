# Gauntlet run report

10 of 10 runs accepted. Average-profile waves 1 (6.08 s), 2 (7.75 s), 3 (5.1 s), 4 (8.02 s), 5 (34.08 s), 9 (30.45 s), 10 (42.02 s), 11 (30.3 s), 12 (35.47 s), 13 (38.68 s), 14 (28.93 s), 15 (52.42 s), 16 (38.87 s), 17 (37.97 s), 18 (43.28 s), 19 (40.26 s), 20 (59.13 s), 21 (38.3 s), 22 (52.9 s), 23 (51.8 s), 24 (57.78 s), 25 (58.72 s), 26 (32.03 s), 27 (31.47 s), 28 (73.4 s), 29 (57.27 s), 30 (58.22 s), 31 (66.38 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ 50f0e6ae3cf3 · 2026-11-21T02:42:46.441Z.

Stalled runs by profile: average 0.

Capped alive by profile: average 1.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 10 / 10 | 6.08 | 5.83…6.58 | 5.12…8.1 | miss |
| average | 2 | 10 / 10 | 7.75 | 6.5…8.23 | 5.57…12.32 | miss |
| average | 3 | 10 / 10 | 5.1 | 3.6…7.53 | 2.58…10.72 | miss |
| average | 4 | 10 / 10 | 8.02 | 6.5…10.03 | 4…11.65 | miss |
| average | 5 | 10 / 10 | 34.08 | 25.67…38.62 | 15.97…56.55 | miss |
| average | 6 | 10 / 10 | 16.15 | 12.62…25.15 | 10.73…41.92 | within 20% |
| average | 7 | 10 / 10 | 12.52 | 8.55…13.9 | 7.15…20.32 | within 20% |
| average | 8 | 10 / 10 | 15.22 | 12.42…19.85 | 9.4…21.18 | within 20% |
| average | 9 | 10 / 10 | 30.45 | 21.13…37.12 | 17.37…42.05 | miss |
| average | 10 | 9 / 10 | 42.02 | 31.73…58.1 | 10.57…77.5 | miss |
| average | 11 | 9 / 9 | 30.3 | 15.62…40.97 | 9.9…53.83 | miss |
| average | 12 | 9 / 9 | 35.47 | 30.27…41.12 | 10.18…48.35 | miss |
| average | 13 | 9 / 9 | 38.68 | 26.02…51.25 | 13.28…54.52 | miss |
| average | 14 | 9 / 9 | 28.93 | 26.23…31.97 | 12.55…53.78 | miss |
| average | 15 | 9 / 9 | 52.42 | 43.83…70.72 | 37.38…83.52 | miss |
| average | 16 | 9 / 9 | 38.87 | 27.78…53.48 | 19.07…61.83 | miss |
| average | 17 | 9 / 9 | 37.97 | 36.18…38.63 | 21.37…51.25 | miss |
| average | 18 | 8 / 9 | 43.28 | 38.23…48.03 | 33.15…58.12 | miss |
| average | 19 | 8 / 8 | 40.26 | 38.22…56.37 | 27.25…69.17 | miss |
| average | 20 | 7 / 8 | 59.13 | 48.28…79.07 | 39.63…82.2 | miss |
| average | 21 | 7 / 7 | 38.3 | 33.2…48.07 | 32.82…52.2 | miss |
| average | 22 | 5 / 7 | 52.9 | 28.67…53.38 | 24.5…61.62 | miss |
| average | 23 | 5 / 5 | 51.8 | 49.65…73.07 | 36.38…83.18 | miss |
| average | 24 | 4 / 5 | 57.78 | 46.37…83.22 | 42.62…83.22 | miss |
| average | 25 | 1 / 4 | 58.72 | 58.72…58.72 | 58.72…58.72 | miss |
| average | 26 | 1 / 1 | 32.03 | 32.03…32.03 | 32.03…32.03 | miss |
| average | 27 | 1 / 1 | 31.47 | 31.47…31.47 | 31.47…31.47 | miss |
| average | 28 | 1 / 1 | 73.4 | 73.4…73.4 | 73.4…73.4 | miss |
| average | 29 | 1 / 1 | 57.27 | 57.27…57.27 | 57.27…57.27 | miss |
| average | 30 | 1 / 1 | 58.22 | 58.22…58.22 | 58.22…58.22 | miss |
| average | 31 | 1 / 1 | 66.38 | 66.38…66.38 | 66.38…66.38 | miss |
| average | 32 | 0 / 1 | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 9 | 0 | 1 | 0 | 10 × 1, 18 × 1, 20 × 1, 22 × 2, 24 × 1, 25 × 3 | turret_gun × 2, war_cannon × 2 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 5 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 77.05% | 33.15 (149) | 13.47 (64) |
| patrol_cop | 0 | — | 89.25% | 32.33 (181) | 17.82 (32) |
| riot_cop | 0 | — | 74.1% | 34.53 (145) | 16.48 (68) |
| robot_gunner | 0 | — | 69% | 38.13 (118) | 12.62 (95) |
| robot_thug | 0 | — | 65.54% | 37.33 (116) | 13.12 (97) |
| rocket_trooper | 0 | — | 75.04% | 35.08 (141) | 13.15 (72) |
| sentry_turret | 2 | turret_gun × 2 | 72.51% | 38.63 (119) | 11.19 (94) |
| shield_robot | 0 | — | 68.97% | 42.33 (100) | 13.28 (113) |
| swat | 0 | — | 73.51% | 34.14 (142) | 18.22 (71) |
| war_machine | 2 | war_cannon × 2 | 26.76% | 47.47 (37) | 26.13 (176) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 6 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| ghost_dent | wave s | 42.08 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 8.5 (8) | 2 (1) | 1 | 4 | not measured | not measured (2, all offered) | too few pairs |
| ghost_kerf | wave s | 40.95 (8) | 51.12 (1) | 1 | -10.46 | not measured | not measured (2, all offered) | too few pairs |
| ghost_ohm | waves survived | 16 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 39.57 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 16 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_tonnage | wave s | 37.08 (9) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_damage_10 | waves survived | 20 (9) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_damage_10 | wave s | 37.97 (9) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_damage_25 | waves survived | 15 (7) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_damage_25 | wave s | 38.91 (7) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 16 (10) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 35.48 (10) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 5 (7) | 7.5 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 46.26 (6) | 32.13 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 17.5 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 33.53 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 15 (8) | 3 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 38.71 (8) | 61.83 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | waves survived | 13 (9) | 8 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | wave s | 40.62 (9) | 8.87 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_25 | waves survived | 5.5 (8) | 8 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 39.46 (8) | 35.35 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 15 (10) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_speed_10 | wave s | 38.26 (10) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_speed_25 | waves survived | 5.5 (8) | 11 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_speed_25 | wave s | 45.67 (7) | 39.87 (1) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 5 (7) | 18 (3) | 1 | -2 | not measured | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | wave s | 42.62 (7) | 35.73 (3) | 1 | -0.37 | not measured | not measured (2, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 11 (7) | 11 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 43.02 (7) | 30.3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 5 (7) | 15 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 40.4 (7) | 39.4 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 12.5 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gatling | wave s | 40.59 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gloria | waves survived | 4.5 (6) | 14 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 50.6 (4) | 30.4 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 9 (6) | 11.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 46.79 (6) | 37.37 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 7.5 (4) | 17 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_katana | wave s | 48.16 (3) | 33.63 (6) | 1 | -4.98 | not measured | not measured (1, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 4 (7) | 11 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 42.6 (7) | 35.47 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_pistol | waves survived | 13 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 39.78 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 6 (5) | 17 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 43.02 (5) | 36.68 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 13 (7) | 15.5 (2) | 2 | -5.5 | -7…-4 | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 39.28 (7) | 40.82 (2) | 2 | -7.93 | -13.55…-2.32 | not measured (2, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 10 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 43.02 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 5 (7) | 18 (3) | 1 | -2 | not measured | not measured (2, all offered) | too few pairs |
| chainsaw | wave s | 42.62 (7) | 35.73 (3) | 1 | -0.37 | not measured | not measured (2, all offered) | too few pairs |
| electro_baton | waves survived | 11 (7) | 11 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 43.02 (7) | 30.3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 5 (7) | 15 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 40.4 (7) | 39.4 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 12.5 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gatling | wave s | 40.59 (10) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gloria | waves survived | 4.5 (6) | 14 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 50.6 (4) | 30.4 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | 9 (6) | 11.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 46.79 (6) | 37.37 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 7.5 (4) | 17 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| katana | wave s | 48.16 (3) | 33.63 (6) | 1 | -4.98 | not measured | not measured (1, all offered) | too few pairs |
| machine_pistol | waves survived | 4 (7) | 11 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| machine_pistol | wave s | 42.6 (7) | 35.47 (3) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| pistol | waves survived | 13 (10) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 39.78 (9) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | 6 (5) | 17 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 43.02 (5) | 36.68 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 13 (7) | 15.5 (2) | 2 | -5.5 | -7…-4 | not measured (2, all offered) | too few pairs |
| plasma_sword | wave s | 39.28 (7) | 40.82 (2) | 2 | -7.93 | -13.55…-2.32 | not measured (2, all offered) | too few pairs |
| rocket_launcher | waves survived | 10 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| rocket_launcher | wave s | 43.02 (9) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | not measured | 0.5 (10) | 0 (10) | 4 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 2 | not measured | 0 (10) | 0 (10) | 6 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 3 | not measured | 0 (10) | 0 (10) | 4 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 4 | not measured | 1 (10) | 0 (10) | 6 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 5 | not measured | 6.5 (10) | 0 (10) | 55 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 6 | not measured | 3 (10) | 0 (10) | 26.5 (10) | 0 (10) | 0 (10) | 0 (10) | 3.55 (10) |
| average | 7 | not measured | 0.5 (10) | 5.5 (10) | 25 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 8 | not measured | 3.5 (10) | 22.5 (10) | 33.5 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 9 | not measured | 6 (10) | 37 (10) | 63 (10) | 0 (10) | 0 (10) | 0 (10) | 0 (10) |
| average | 10 | not measured | 10 (10) | 55.5 (10) | 105 (10) | 0 (10) | 0 (10) | 3.77 (10) | 7.1 (10) |
| average | 11 | not measured | 9 (9) | 20 (9) | 44 (9) | 0 (9) | 0 (9) | 0 (9) | 7.1 (9) |
| average | 12 | not measured | 9 (9) | 50 (9) | 108 (9) | 0 (9) | 0 (9) | 0 (9) | 7.1 (9) |
| average | 13 | not measured | 8 (9) | 41 (9) | 116 (9) | 0 (9) | 0 (9) | 7.3 (9) | 7.1 (9) |
| average | 14 | not measured | 10 (9) | 26 (9) | 63 (9) | 0 (9) | 0 (9) | 0 (9) | 7.1 (9) |
| average | 15 | not measured | 10 (9) | 76 (9) | 158 (9) | 0 (9) | 0 (9) | 7.3 (9) | 7.1 (9) |
| average | 16 | not measured | 13 (9) | 61 (9) | 99 (9) | 0 (9) | 0 (9) | 7.3 (9) | 7.1 (9) |
| average | 17 | not measured | 11 (9) | 48 (9) | 119 (9) | 0 (9) | 0 (9) | 7.3 (9) | 7.1 (9) |
| average | 18 | not measured | 13 (9) | 66 (9) | 139 (9) | 0 (9) | 4.43 (9) | 7.3 (9) | 7.1 (9) |
| average | 19 | not measured | 13 (8) | 55.5 (8) | 123 (8) | 0 (8) | 9.08 (8) | 6.07 (8) | 7.1 (8) |
| average | 20 | not measured | 19 (8) | 121.5 (8) | 208.5 (8) | 0 (8) | 0.37 (8) | 12.16 (8) | 10.65 (8) |
| average | 21 | not measured | 19 (7) | 76 (7) | 106 (7) | 0 (7) | 5.5 (7) | 7.3 (7) | 7.1 (7) |
| average | 22 | not measured | 12 (7) | 81 (7) | 167 (7) | 0 (7) | 4.48 (7) | 7.3 (7) | 7.1 (7) |
| average | 23 | not measured | 23 (5) | 84 (5) | 170 (5) | 0 (5) | 5.5 (5) | 7.3 (5) | 7.1 (5) |
| average | 24 | not measured | 23 (5) | 104 (5) | 155 (5) | 0 (5) | 9.78 (5) | 7.3 (5) | 7.1 (5) |
| average | 25 | not measured | 18 (4) | 39.5 (4) | 244.5 (4) | 0 (4) | 4.67 (4) | 7.9 (4) | 4.54 (4) |
| average | 26 | not measured | 7 (1) | 125 (1) | 2351 (1) | 0 (1) | 5 (1) | 7.3 (1) | 0 (1) |
| average | 27 | not measured | 9 (1) | 45 (1) | 116 (1) | 0 (1) | 0.18 (1) | 7.3 (1) | 0 (1) |
| average | 28 | not measured | 22 (1) | 108 (1) | 216 (1) | 0 (1) | 7.13 (1) | 14.6 (1) | 7.1 (1) |
| average | 29 | not measured | 20 (1) | 83 (1) | 134 (1) | 0 (1) | 0.02 (1) | 7.3 (1) | 7.1 (1) |
| average | 30 | not measured | 24 (1) | 62 (1) | 156 (1) | 0 (1) | 10.1 (1) | 14.6 (1) | 0 (1) |
| average | 31 | not measured | 19 (1) | 113 (1) | 171 (1) | 0 (1) | 4.8 (1) | 14.6 (1) | 7.1 (1) |
| average | 32 | not measured | not measured | not measured | not measured | 0 (1) | 0 (1) | 14.6 (1) | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 32 | 2.66 | stat_damage_10 → stat_hp_max_10 → stat_guard_meter_10 → stat_regen_25 → stat_damage_25 → ghost_ohm → stat_speed_10 → stat_hp_max_25 → weapon_pistol → ghost_tonnage → weapon_katana → stat_speed_25 → stat_guard_meter_25 → ghost_dent → weapon_machine_pistol → weapon_rocket_launcher → weapon_gatling → weapon_plasma_sword → weapon_gloria → ghost_kerf → weapon_electro_baton → stat_regen_10 → weapon_hand_cannon → weapon_flamethrower → weapon_plasma_rifle → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | ohm | node tools/dev/run.mjs gauntlet --seed=10 --bot=average --pick=greedy --controls=wheel |
