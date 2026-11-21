# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 1 (6.27 s), 2 (7.8 s), 3 (5.52 s), 4 (7.87 s), 5 (33.15 s), 9 (29.95 s), 10 (45.47 s), 11 (35.63 s), 12 (37.48 s), 13 (39.97 s), 14 (33.48 s), 15 (57.27 s), 16 (33.69 s), 17 (31.22 s), 18 (43.02 s), 19 (39.28 s), 20 (60.92 s), 21 (43.18 s), 22 (61.62 s), 23 (83.18 s), 24 (83.22 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ 5c5d2ebc44b2 (dirty) · 2026-11-21T02:14:17.165Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Baseline n22-loop @ a52766c27c78 (dirty) · 2026-11-21T01:52:54.784Z · 15 accepted runs.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Before s (n) | After s | Change s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 6.23 (5) | 6.23 | 0 | 5.65…6.28 | 5.37…6.32 | — |
| novice | 2 | 5 / 5 | 8.4 (5) | 8.4 | 0 | 7.8…10.22 | 7.25…10.82 | — |
| novice | 3 | 5 / 5 | 5.8 (5) | 5.8 | 0 | 5.7…7.02 | 5.22…7.17 | — |
| novice | 4 | 5 / 5 | 6.87 (5) | 6.87 | 0 | 6.03…7.32 | 5.48…10.95 | — |
| novice | 5 | 5 / 5 | 27.82 (2) | 21.73 | -6.08 | 20.58…29.33 | 17.6…29.67 | — |
| novice | 6 | 4 / 5 | 9.92 (2) | 12.2 | 2.28 | 8.38…18.95 | 6.62…18.95 | — |
| novice | 7 | 4 / 4 | 10.91 (2) | 14.47 | 3.56 | 12.4…18.48 | 9.38…18.48 | — |
| novice | 8 | 4 / 4 | 14.3 (2) | 16.18 | 1.88 | 16.13…17.42 | 11.37…17.42 | — |
| novice | 9 | 4 / 4 | 25.76 (2) | 30.14 | 4.38 | 29.5…39.57 | 20.83…39.57 | — |
| novice | 10 | 1 / 4 | not measured | 40.6 | not measured | 40.6…40.6 | 40.6…40.6 | — |
| novice | 11 | 1 / 1 | not measured | 23.4 | not measured | 23.4…23.4 | 23.4…23.4 | — |
| novice | 12 | 1 / 1 | not measured | 19.97 | not measured | 19.97…19.97 | 19.97…19.97 | — |
| novice | 13 | 0 / 1 | not measured | not measured | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 6.27 (5) | 6.27 | 0 | 5.83…6.72 | 5.12…8.1 | miss |
| average | 2 | 5 / 5 | 7.8 (5) | 7.8 | 0 | 6.5…8.23 | 5.57…8.33 | miss |
| average | 3 | 5 / 5 | 5.52 (5) | 5.52 | 0 | 3.52…6.78 | 2.58…7.53 | miss |
| average | 4 | 5 / 5 | 6.5 (5) | 7.87 | 1.37 | 6.5…9.6 | 4…10.47 | miss |
| average | 5 | 5 / 5 | 54.65 (5) | 33.15 | -21.5 | 27.75…35.02 | 18.22…42.28 | miss |
| average | 6 | 5 / 5 | 24.67 (5) | 12.67 | -12 | 11.98…16.67 | 10.73…41.92 | within 20% |
| average | 7 | 5 / 5 | 13.33 (5) | 13.63 | 0.3 | 7.52…13.9 | 7.15…14.62 | within 20% |
| average | 8 | 5 / 5 | 15.15 (5) | 16.15 | 1 | 10.25…17.4 | 9.4…20.87 | within 20% |
| average | 9 | 5 / 5 | 25.88 (5) | 29.95 | 4.07 | 18.97…34.53 | 17.37…42.05 | miss |
| average | 10 | 4 / 5 | 64.3 (5) | 45.47 | -18.83 | 37.33…58.1 | 10.57…58.1 | miss |
| average | 11 | 4 / 4 | 28.87 (5) | 35.63 | 6.77 | 30.3…41.28 | 13.48…41.28 | miss |
| average | 12 | 4 / 4 | 60.12 (5) | 37.48 | -22.63 | 35.47…48.35 | 30.27…48.35 | miss |
| average | 13 | 4 / 4 | 34.17 (5) | 39.97 | 5.8 | 26.02…54.52 | 13.28…54.52 | miss |
| average | 14 | 4 / 4 | 35.68 (5) | 33.48 | -2.2 | 28.93…53.78 | 23…53.78 | miss |
| average | 15 | 4 / 4 | 32.58 (3) | 57.27 | 24.69 | 43.83…72.68 | 37.38…72.68 | miss |
| average | 16 | 4 / 4 | 34.07 (2) | 33.69 | -0.37 | 28.52…61.83 | 27.78…61.83 | miss |
| average | 17 | 4 / 4 | 46.75 (2) | 31.22 | -15.53 | 23.82…40.4 | 21.37…40.4 | miss |
| average | 18 | 3 / 4 | 52.76 (2) | 43.02 | -9.74 | 33.15…58.12 | 33.15…58.12 | miss |
| average | 19 | 3 / 3 | 40.65 (1) | 39.28 | -1.37 | 38.22…69.17 | 38.22…69.17 | miss |
| average | 20 | 2 / 3 | not measured | 60.92 | not measured | 39.63…82.2 | 39.63…82.2 | miss |
| average | 21 | 2 / 2 | not measured | 43.18 | not measured | 38.3…48.07 | 38.3…48.07 | miss |
| average | 22 | 1 / 2 | not measured | 61.62 | not measured | 61.62…61.62 | 61.62…61.62 | miss |
| average | 23 | 1 / 1 | not measured | 83.18 | not measured | 83.18…83.18 | 83.18…83.18 | miss |
| average | 24 | 1 / 1 | not measured | 83.22 | not measured | 83.22…83.22 | 83.22…83.22 | miss |
| average | 25 | 0 / 1 | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1 | 5 / 5 | 6.18 (5) | 6.18 | 0 | 6.13…6.38 | 5.35…7.8 | — |
| expert | 2 | 5 / 5 | 9.47 (5) | 9.47 | 0 | 8.73…10.03 | 6.83…10.93 | — |
| expert | 3 | 5 / 5 | 6.08 (5) | 6.08 | 0 | 5.67…6.35 | 3.22…6.53 | — |
| expert | 4 | 5 / 5 | 6.13 (5) | 6.13 | 0 | 5.98…11.38 | 2.85…18.53 | — |
| expert | 5 | 5 / 5 | 39.4 (4) | 35.1 | -4.3 | 34.75…51.58 | 18.43…81.37 | — |
| expert | 6 | 5 / 5 | 15.47 (4) | 14.8 | -0.67 | 11.83…16.33 | 10.97…24.18 | — |
| expert | 7 | 5 / 5 | 12.8 (4) | 10.67 | -2.13 | 6.47…11.25 | 6.42…18.63 | — |
| expert | 8 | 5 / 5 | 17.53 (4) | 11.32 | -6.22 | 8.83…20.18 | 7.92…23.53 | — |
| expert | 9 | 5 / 5 | 27.41 (4) | 25 | -2.41 | 15.95…34.62 | 15.13…40.12 | — |
| expert | 10 | 5 / 5 | 37.52 (4) | 42.77 | 5.25 | 36.68…48.95 | 30.98…61.62 | — |
| expert | 11 | 4 / 5 | 23.19 (4) | 21.5 | -1.69 | 13.33…38.08 | 13.12…38.08 | — |
| expert | 12 | 4 / 4 | 49.45 (4) | 43.42 | -6.03 | 43.18…52.08 | 23.82…52.08 | — |
| expert | 13 | 4 / 4 | 30.85 (4) | 29.26 | -1.59 | 24.95…69.38 | 12.57…69.38 | — |
| expert | 14 | 4 / 4 | 34.94 (4) | 25.26 | -9.68 | 19.25…47.2 | 17.92…47.2 | — |
| expert | 15 | 4 / 4 | 36.48 (3) | 55.88 | 19.39 | 41.37…73.95 | 37.25…73.95 | — |
| expert | 16 | 4 / 4 | 34.97 (2) | 46.16 | 11.19 | 43.08…49.93 | 24.05…49.93 | — |
| expert | 17 | 4 / 4 | 51.18 (2) | 18.04 | -33.13 | 17.98…49.1 | 13.6…49.1 | — |
| expert | 18 | 4 / 4 | 63.38 (2) | 45.83 | -17.55 | 39.12…78.65 | 35.08…78.65 | — |
| expert | 19 | 4 / 4 | 45.09 (2) | 39.58 | -5.51 | 34.57…67.97 | 24.33…67.97 | — |
| expert | 20 | 4 / 4 | 44.93 (2) | 52.65 | 7.72 | 46.37…64.28 | 45.53…64.28 | — |
| expert | 21 | 4 / 4 | 21.1 (1) | 44.48 | 23.38 | 34.35…56.15 | 17.07…56.15 | — |
| expert | 22 | 4 / 4 | not measured | 77.23 | not measured | 77.02…80.12 | 58.35…80.12 | — |
| expert | 23 | 4 / 4 | not measured | 53.83 | not measured | 39.03…70.68 | 36.1…70.68 | — |
| expert | 24 | 4 / 4 | not measured | 53.41 | not measured | 50.32…74.72 | 27.98…74.72 | — |
| expert | 25 | 1 / 4 | not measured | 44.35 | not measured | 44.35…44.35 | 44.35…44.35 | — |
| expert | 26 | 1 / 1 | not measured | 78.02 | not measured | 78.02…78.02 | 78.02…78.02 | — |
| expert | 27 | 1 / 1 | not measured | 41.62 | not measured | 41.62…41.62 | 41.62…41.62 | — |
| expert | 28 | 0 / 1 | not measured | not measured | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 6 × 1, 10 × 3, 13 × 1 | war_cannon × 2, turret_gun × 1 | 1 |
| average | 5 | 5 | 0 | 0 | 10 × 1, 18 × 1, 20 × 1, 22 × 1, 25 × 1 | war_cannon × 1 | 0 |
| expert | 5 | 5 | 0 | 0 | 11 × 1, 25 × 3, 28 × 1 | not measured | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 1 | 4 | 5 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 76.54% | 29.73 (160) | 10.73 (83) |
| patrol_cop | 0 | — | 87.26% | 24.05 (201) | 15.58 (42) |
| riot_cop | 0 | — | 72.35% | 24.98 (164) | 12.67 (79) |
| robot_gunner | 0 | — | 66.34% | 37.38 (119) | 10.69 (124) |
| robot_thug | 0 | — | 63.87% | 29.95 (127) | 10.57 (116) |
| rocket_trooper | 0 | — | 74.94% | 31.02 (150) | 9.4 (93) |
| sentry_turret | 1 | turret_gun × 1 | 64.69% | 39.2 (110) | 10.57 (133) |
| shield_robot | 0 | — | 63.84% | 43.02 (93) | 11.38 (150) |
| swat | 0 | — | 68.47% | 30.64 (142) | 16.23 (101) |
| war_machine | 3 | war_cannon × 3 | 25.66% | 40.98 (40) | 17.4 (203) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. At least two pairs are needed for each interval. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 3 (9) | 2 (1) | 1 | 7 | not measured | not measured | insufficient data |
| ghost_dent | wave s | 44.8 (8) | 14.3 (1) | 1 | 5.67 | not measured | not measured | insufficient data |
| ghost_kerf | waves survived | 7 (9) | 2 (1) | 1 | 4 | not measured | not measured | insufficient data |
| ghost_kerf | wave s | 43.54 (8) | 51.12 (1) | 1 | -10.46 | not measured | not measured | insufficient data |
| ghost_ohm | waves survived | 11 (12) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_ohm | wave s | 37.71 (11) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| ghost_tonnage | waves survived | 11 (13) | not measured | 0 | not measured | not measured | 12 (3, all offered) | insufficient data |
| ghost_tonnage | wave s | 32.94 (12) | not measured | 0 | not measured | not measured | 25.91 (3, all offered) | insufficient data |
| stat_damage_10 | waves survived | 12 (11) | 1 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_10 | wave s | 38.88 (10) | 30.78 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_25 | waves survived | 5 (7) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_damage_25 | wave s | 48.31 (7) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_10 | waves survived | 11 (15) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_10 | wave s | 30.3 (15) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_25 | waves survived | 3.5 (6) | 4 (5) | 0 | not measured | not measured | not measured | insufficient data |
| stat_guard_meter_25 | wave s | 47.98 (4) | 26.45 (5) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_10 | waves survived | 15 (14) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_10 | wave s | 30.37 (14) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_25 | waves survived | 11 (7) | 3 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_hp_max_25 | wave s | 40.66 (7) | 61.83 (1) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_10 | waves survived | 8 (9) | 8 (6) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_10 | wave s | 40.4 (9) | 12.99 (6) | 0 | not measured | not measured | not measured | insufficient data |
| stat_regen_25 | waves survived | 4 (7) | 2 (4) | 1 | 14 | not measured | not measured | insufficient data |
| stat_regen_25 | wave s | 44.35 (7) | 26.35 (2) | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_10 | waves survived | 15 (15) | not measured | 0 | not measured | not measured | 14 (3, all offered) | insufficient data |
| stat_speed_10 | wave s | 26.02 (15) | not measured | 0 | not measured | not measured | 21.02 (3, all offered) | insufficient data |
| stat_speed_25 | waves survived | 3 (11) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| stat_speed_25 | wave s | 47.26 (10) | not measured | 0 | not measured | not measured | not measured | insufficient data |
| weapon_chainsaw | waves survived | 3 (6) | 5 (9) | 0 | not measured | not measured | 3 (2, decliners) | insufficient data |
| weapon_chainsaw | wave s | 55.75 (6) | 19.4 (8) | 0 | not measured | not measured | 4.27 (2, decliners) | insufficient data |
| weapon_electro_baton | waves survived | 11 (9) | 8.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_electro_baton | wave s | 40.35 (8) | 17.26 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | waves survived | 6 (7) | 6 (5) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_flamethrower | wave s | 40.77 (6) | 21.49 (4) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_gatling | waves survived | 6 (12) | not measured | 0 | not measured | not measured | 14 (3, all offered) | insufficient data |
| weapon_gatling | wave s | 37.77 (12) | not measured | 0 | not measured | not measured | 19.43 (3, all offered) | insufficient data |
| weapon_gloria | waves survived | 5 (5) | 6.5 (10) | 0 | not measured | not measured | 10 (2, decliners) | insufficient data |
| weapon_gloria | wave s | 54.84 (5) | 16.98 (10) | 0 | not measured | not measured | 26.07 (2, decliners) | insufficient data |
| weapon_hand_cannon | waves survived | 12 (6) | 4 (8) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_hand_cannon | wave s | 47.04 (6) | 28.2 (8) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_katana | waves survived | 4 (6) | 7.5 (8) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_katana | wave s | 50.48 (5) | 23.1 (8) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_machine_pistol | waves survived | 6 (7) | 8.5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_machine_pistol | wave s | 36.59 (6) | 35.4 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_pistol | waves survived | 9 (14) | 4 (1) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_pistol | wave s | 33.15 (13) | 7.13 (1) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_rifle | waves survived | 8 (6) | 5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_rifle | wave s | 45.38 (6) | 21.54 (6) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_plasma_sword | waves survived | 10 (10) | 14 (3) | 2 | -2 | -7…3 | 7 (2, all offered) | noise |
| weapon_plasma_sword | wave s | 32.88 (10) | 43.85 (3) | 2 | -9.1 | -13.55…-4.64 | 13.55 (2, all offered) | noise |
| weapon_rocket_launcher | waves survived | 9 (9) | 1 (2) | 0 | not measured | not measured | not measured | insufficient data |
| weapon_rocket_launcher | wave s | 50.14 (8) | 19.13 (1) | 0 | not measured | not measured | not measured | insufficient data |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 3 (6) | 5 (9) | 0 | not measured | not measured | 3 (2, decliners) | insufficient data |
| chainsaw | wave s | 55.75 (6) | 19.4 (8) | 0 | not measured | not measured | 4.27 (2, decliners) | insufficient data |
| electro_baton | waves survived | 11 (9) | 8.5 (4) | 0 | not measured | not measured | not measured | insufficient data |
| electro_baton | wave s | 40.35 (8) | 17.26 (4) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | waves survived | 6 (7) | 6 (5) | 0 | not measured | not measured | not measured | insufficient data |
| flamethrower | wave s | 40.77 (6) | 21.49 (4) | 0 | not measured | not measured | not measured | insufficient data |
| gatling | waves survived | 6 (12) | not measured | 0 | not measured | not measured | 14 (3, all offered) | insufficient data |
| gatling | wave s | 37.77 (12) | not measured | 0 | not measured | not measured | 19.43 (3, all offered) | insufficient data |
| gloria | waves survived | 5 (5) | 6.5 (10) | 0 | not measured | not measured | 10 (2, decliners) | insufficient data |
| gloria | wave s | 54.84 (5) | 16.98 (10) | 0 | not measured | not measured | 26.07 (2, decliners) | insufficient data |
| hand_cannon | waves survived | 12 (6) | 4 (8) | 0 | not measured | not measured | not measured | insufficient data |
| hand_cannon | wave s | 47.04 (6) | 28.2 (8) | 0 | not measured | not measured | not measured | insufficient data |
| katana | waves survived | 4 (6) | 7.5 (8) | 0 | not measured | not measured | not measured | insufficient data |
| katana | wave s | 50.48 (5) | 23.1 (8) | 0 | not measured | not measured | not measured | insufficient data |
| machine_pistol | waves survived | 6 (7) | 8.5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| machine_pistol | wave s | 36.59 (6) | 35.4 (6) | 0 | not measured | not measured | not measured | insufficient data |
| pistol | waves survived | 9 (14) | 4 (1) | 0 | not measured | not measured | not measured | insufficient data |
| pistol | wave s | 33.15 (13) | 7.13 (1) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_rifle | waves survived | 8 (6) | 5 (6) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_rifle | wave s | 45.38 (6) | 21.54 (6) | 0 | not measured | not measured | not measured | insufficient data |
| plasma_sword | waves survived | 10 (10) | 14 (3) | 2 | -2 | -7…3 | 7 (2, all offered) | noise |
| plasma_sword | wave s | 32.88 (10) | 43.85 (3) | 2 | -9.1 | -13.55…-4.64 | 13.55 (2, all offered) | noise |
| rocket_launcher | waves survived | 9 (9) | 1 (2) | 0 | not measured | not measured | not measured | insufficient data |
| rocket_launcher | wave s | 50.14 (8) | 19.13 (1) | 0 | not measured | not measured | not measured | insufficient data |

## Combat telemetry

Deflects, rolls, shots and seconds in each form are medians. Parentheses count observations. Hit rate pools hits and shots only across rows measuring both. A zero denominator has no rate.

| Profile | Wave | Guard deflects (n) | Rolls (n) | Shots (n) | Hit rate (shots) | dent s (n) | kerf s (n) | ohm s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | not measured | 0 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 2 | not measured | 1 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 3 | not measured | 0 (5) | 0 (5) | 129.41% (17) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 4 | not measured | 0 (5) | 0 (5) | 168.42% (19) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 5 | not measured | 0 (5) | 0 (5) | 1300% (22) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 6 | not measured | 1 (5) | 0 (5) | 650% (18) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| novice | 7 | not measured | 1 (4) | 7.5 (4) | 97.53% (81) | 0 (4) | 0 (4) | 0 (4) | 0 (4) |
| novice | 8 | not measured | 0 (4) | 53.5 (4) | 47.47% (217) | 0 (4) | 0 (4) | 0 (4) | 0 (4) |
| novice | 9 | not measured | 2.5 (4) | 118 (4) | 84.77% (453) | 0 (4) | 0 (4) | 0 (4) | 7.1 (4) |
| novice | 10 | not measured | 7.5 (4) | 87.5 (4) | 89.11% (404) | 0 (4) | 0 (4) | 2.63 (4) | 7.1 (4) |
| novice | 11 | not measured | 3 (1) | 46 (1) | 160.87% (46) | 0 (1) | 0 (1) | 7.3 (1) | 0 (1) |
| novice | 12 | not measured | 3 (1) | 25 (1) | 180% (25) | 0 (1) | 0 (1) | 0 (1) | 7.1 (1) |
| novice | 13 | not measured | 7 (1) | 43 (1) | 141.86% (43) | 0 (1) | 0 (1) | 6.5 (1) | 7.1 (1) |
| average | 1 | not measured | 1 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 2 | not measured | 0 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 3 | not measured | 0 (5) | 0 (5) | 275% (8) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 4 | not measured | 1 (5) | 0 (5) | 213.33% (15) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 5 | not measured | 7 (5) | 0 (5) | 1048.28% (29) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 6 | not measured | 3 (5) | 0 (5) | 1662.5% (8) | 0 (5) | 0 (5) | 0 (5) | 7.1 (5) |
| average | 7 | not measured | 3 (5) | 8 (5) | 431.53% (111) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 8 | not measured | 3 (5) | 46 (5) | 465.95% (232) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| average | 9 | not measured | 2 (5) | 51 (5) | 87.5% (528) | 0 (5) | 0 (5) | 0 (5) | 7.1 (5) |
| average | 10 | not measured | 12 (5) | 44 (5) | 100% (394) | 0 (5) | 0 (5) | 0 (5) | 7.1 (5) |
| average | 11 | not measured | 14.5 (4) | 15 (4) | 255.67% (97) | 0 (4) | 0 (4) | 0 (4) | 3.55 (4) |
| average | 12 | not measured | 6.5 (4) | 48.5 (4) | 200.79% (253) | 0 (4) | 0 (4) | 1.86 (4) | 7.1 (4) |
| average | 13 | not measured | 6.5 (4) | 20 (4) | 327.84% (97) | 0 (4) | 0 (4) | 4.92 (4) | 7.1 (4) |
| average | 14 | not measured | 7.5 (4) | 30.5 (4) | 137.33% (300) | 0 (4) | 0 (4) | 0 (4) | 3.55 (4) |
| average | 15 | not measured | 8 (4) | 94.5 (4) | 408.05% (472) | 0 (4) | 0 (4) | 3.65 (4) | 10.65 (4) |
| average | 16 | not measured | 14 (4) | 71 (4) | 301.09% (550) | 0 (4) | 0 (4) | 5.33 (4) | 7.1 (4) |
| average | 17 | not measured | 8 (4) | 88 (4) | 1096.99% (366) | 0 (4) | 0 (4) | 5.01 (4) | 3.55 (4) |
| average | 18 | not measured | 14.5 (4) | 71.5 (4) | 1174.07% (405) | 0 (4) | 2.75 (4) | 9.13 (4) | 7.1 (4) |
| average | 19 | not measured | 23 (3) | 56 (3) | 231.21% (157) | 0 (3) | 11.05 (3) | 7.3 (3) | 7.1 (3) |
| average | 20 | not measured | 31 (3) | 42 (3) | 151.31% (419) | 0 (3) | 0.72 (3) | 14.58 (3) | 14.2 (3) |
| average | 21 | not measured | 17.5 (2) | 67 (2) | 142.54% (134) | 0 (2) | 4.74 (2) | 3.65 (2) | 7.1 (2) |
| average | 22 | not measured | 44.5 (2) | 103 (2) | 155.34% (206) | 0 (2) | 8.25 (2) | 7.3 (2) | 7.1 (2) |
| average | 23 | not measured | 23 (1) | 77 (1) | 253.25% (77) | 0 (1) | 5.5 (1) | 14.6 (1) | 7.1 (1) |
| average | 24 | not measured | 44 (1) | 69 (1) | 192.75% (69) | 0 (1) | 16.5 (1) | 0.48 (1) | 7.1 (1) |
| average | 25 | not measured | 18 (1) | 72 (1) | 313.89% (72) | 0 (1) | 5.5 (1) | 14.62 (1) | 14.2 (1) |
| expert | 1 | not measured | 0 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 2 | not measured | 1 (5) | 0 (5) | not measured | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 3 | not measured | 0 (5) | 0 (5) | 220% (10) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 4 | not measured | 1 (5) | 0 (5) | 344.44% (9) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 5 | not measured | 10 (5) | 0 (5) | 1139.29% (28) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 6 | not measured | 3 (5) | 0 (5) | 1555.56% (9) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 7 | not measured | 2 (5) | 7 (5) | 742.86% (140) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 8 | not measured | 1 (5) | 46 (5) | 655.98% (209) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 9 | not measured | 2 (5) | 77 (5) | 125.38% (394) | 0 (5) | 0 (5) | 0 (5) | 7.1 (5) |
| expert | 10 | not measured | 18 (5) | 112 (5) | 109.06% (629) | 0 (5) | 0 (5) | 7.3 (5) | 7.1 (5) |
| expert | 11 | not measured | 15 (5) | 22 (5) | 176.67% (180) | 0 (5) | 0 (5) | 0 (5) | 0 (5) |
| expert | 12 | not measured | 12 (4) | 78 (4) | 186.31% (263) | 0 (4) | 0 (4) | 2.14 (4) | 7.1 (4) |
| expert | 13 | not measured | 7 (4) | 48 (4) | 155.4% (213) | 0 (4) | 0 (4) | 7.12 (4) | 7.1 (4) |
| expert | 14 | not measured | 9.5 (4) | 66 (4) | 152.92% (291) | 0 (4) | 0 (4) | 3.65 (4) | 7.1 (4) |
| expert | 15 | not measured | 10.5 (4) | 34.5 (4) | 140.46% (482) | 0 (4) | 0 (4) | 9.38 (4) | 10.65 (4) |
| expert | 16 | not measured | 16 (4) | 66.5 (4) | 129.77% (393) | 0 (4) | 0 (4) | 7.3 (4) | 7.1 (4) |
| expert | 17 | not measured | 8 (4) | 61.5 (4) | 646.05% (354) | 0 (4) | 2.37 (4) | 1.73 (4) | 0.67 (4) |
| expert | 18 | not measured | 14.5 (4) | 206 (4) | 589.74% (1082) | 0 (4) | 5.5 (4) | 7.3 (4) | 7.1 (4) |
| expert | 19 | not measured | 19 (4) | 71.5 (4) | 1070.93% (375) | 0 (4) | 7.45 (4) | 5.94 (4) | 3.55 (4) |
| expert | 20 | not measured | 19.5 (4) | 76 (4) | 442.86% (483) | 0 (4) | 4.86 (4) | 7.3 (4) | 10.65 (4) |
| expert | 21 | not measured | 16 (4) | 66 (4) | 1140.34% (295) | 0 (4) | 7.38 (4) | 0 (4) | 3.55 (4) |
| expert | 22 | not measured | 38 (4) | 102.5 (4) | 1170.6% (500) | 0 (4) | 11 (4) | 8.2 (4) | 7.1 (4) |
| expert | 23 | not measured | 21 (4) | 59.5 (4) | 668.25% (274) | 0 (4) | 5.24 (4) | 10.95 (4) | 7.1 (4) |
| expert | 24 | not measured | 24 (4) | 76 (4) | 964.84% (455) | 0 (4) | 5.91 (4) | 7.3 (4) | 7.1 (4) |
| expert | 25 | not measured | 30 (4) | 67 (4) | 816.53% (877) | 0 (4) | 8.98 (4) | 14.6 (4) | 0 (4) |
| expert | 26 | not measured | 15 (1) | 394 (1) | 1037.56% (394) | 0 (1) | 0 (1) | 14.6 (1) | 7.1 (1) |
| expert | 27 | not measured | 18 (1) | 120 (1) | 2186.67% (120) | 0 (1) | 5.5 (1) | 11.2 (1) | 7.1 (1) |
| expert | 28 | not measured | 41 (1) | 385 (1) | 1949.61% (385) | 0 (1) | 5.5 (1) | 14.6 (1) | 14.2 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 13 | 1.79 | ghost_tonnage → ghost_ohm → ghost_dent → stat_speed_10 → stat_hp_max_10 → weapon_machine_pistol → weapon_gatling → stat_guard_meter_10 → weapon_pistol → weapon_katana → weapon_plasma_sword → stat_damage_10 | gatling, katana, machine_pistol, pistol, plasma_sword | tonnage | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --controls=wheel |
| average | 5 | 25 | 1.66 | stat_speed_10 → stat_guard_meter_10 → ghost_tonnage → stat_damage_10 → ghost_ohm → weapon_flamethrower → stat_hp_max_10 → weapon_gatling → stat_hp_max_25 → stat_regen_25 → stat_regen_10 → weapon_hand_cannon → weapon_electro_baton → weapon_rocket_launcher → weapon_pistol → weapon_plasma_rifle → ghost_kerf → weapon_gloria → stat_damage_25 → weapon_katana → stat_speed_25 → weapon_chainsaw → ghost_dent → stat_guard_meter_25 | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, pistol, plasma_rifle, rocket_launcher | tonnage | node tools/dev/run.mjs gauntlet --seed=5 --bot=average --pick=greedy --controls=wheel |
| expert | 4 | 28 | 1.99 | stat_damage_10 → stat_speed_10 → weapon_pistol → stat_hp_max_10 → weapon_hand_cannon → stat_guard_meter_10 → ghost_tonnage → stat_regen_10 → stat_speed_25 → weapon_plasma_sword → weapon_plasma_rifle → weapon_chainsaw → weapon_rocket_launcher → weapon_gatling → ghost_ohm → weapon_flamethrower → weapon_katana → ghost_kerf → stat_hp_max_25 → ghost_dent → stat_damage_25 → weapon_gloria → stat_guard_meter_25 → stat_regen_25 → weapon_machine_pistol → weapon_electro_baton | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | tonnage | node tools/dev/run.mjs gauntlet --seed=4 --bot=expert --pick=greedy --controls=wheel |
