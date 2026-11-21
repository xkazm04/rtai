# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 1 (6.17 s), 2 (6.85 s), 3 (6.28 s), 4 (6.28 s), 5 (22.23 s), 9 (19.87 s), 10 (34.58 s), 11 (26.07 s), 12 (31.02 s), 13 (37.02 s), 14 (33 s), 15 (53.55 s), 16 (40.77 s), 17 (41.67 s), 18 (38.32 s), 19 (27.38 s), 20 (50.49 s), 21 (35.52 s), 22 (47.54 s), 23 (41.54 s), 24 (38.37 s), 25 (65 s), 26 (67.79 s), 27 (49.2 s), 28 (40.52 s), 29 (38.35 s) fell outside 12–18 s.

Live gauntlet batch · n22-loop @ 83cfff3c4522 (dirty) · 2026-11-21T03:50:45.508Z.

Stalled runs by profile: average 0.

Capped alive by profile: average 1.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 30 / 30 | 6.17 | 5.57…6.5 | 3.68…13.42 | miss |
| average | 2 | 30 / 30 | 6.85 | 6.45…7.8 | 3.82…12.47 | miss |
| average | 3 | 30 / 30 | 6.28 | 4.87…8.48 | 2.38…17.18 | miss |
| average | 4 | 30 / 30 | 6.28 | 5.4…9.32 | 3.57…15.43 | miss |
| average | 5 | 30 / 30 | 22.23 | 18.03…35.1 | 8.4…48.37 | miss |
| average | 6 | 29 / 30 | 14.18 | 9.85…16.45 | 4.73…29.48 | within 20% |
| average | 7 | 29 / 29 | 12.2 | 10.07…19.58 | 4.82…29.95 | within 20% |
| average | 8 | 28 / 29 | 17.83 | 10.1…20.83 | 6.37…33.03 | within 20% |
| average | 9 | 27 / 28 | 19.87 | 12.25…34.55 | 5.73…73.1 | miss |
| average | 10 | 26 / 27 | 34.58 | 27.07…53.6 | 12.05…89.73 | miss |
| average | 11 | 26 / 26 | 26.07 | 19.9…44.42 | 10.88…65.8 | miss |
| average | 12 | 24 / 26 | 31.02 | 26.13…52.37 | 8.85…86.15 | miss |
| average | 13 | 22 / 24 | 37.02 | 23.88…45.13 | 10…86.47 | miss |
| average | 14 | 21 / 22 | 33 | 25.77…40.72 | 12.45…81.98 | miss |
| average | 15 | 11 / 21 | 53.55 | 28.55…71.85 | 15.63…73.2 | miss |
| average | 16 | 9 / 11 | 40.77 | 25.32…50.3 | 15.93…57.7 | miss |
| average | 17 | 9 / 9 | 41.67 | 26.08…45.18 | 16.28…85.95 | miss |
| average | 18 | 9 / 9 | 38.32 | 32.57…41.77 | 20.07…49.3 | miss |
| average | 19 | 9 / 9 | 27.38 | 19.78…37.27 | 14.8…63.45 | miss |
| average | 20 | 8 / 9 | 50.49 | 46.22…59.13 | 18.1…77.45 | miss |
| average | 21 | 8 / 8 | 35.52 | 33.83…58.93 | 21.47…89.3 | miss |
| average | 22 | 6 / 8 | 47.54 | 32.72…51.23 | 32.05…75.03 | miss |
| average | 23 | 6 / 6 | 41.54 | 36.25…58.55 | 25.02…66.43 | miss |
| average | 24 | 6 / 6 | 38.37 | 33.53…43.48 | 30.28…55.62 | miss |
| average | 25 | 4 / 6 | 65 | 62.17…86.57 | 55.73…86.57 | miss |
| average | 26 | 4 / 4 | 67.79 | 57.88…80.55 | 38.37…80.55 | miss |
| average | 27 | 3 / 4 | 49.2 | 21.68…65.78 | 21.68…65.78 | miss |
| average | 28 | 3 / 3 | 40.52 | 36.03…57.88 | 36.03…57.88 | miss |
| average | 29 | 1 / 3 | 38.35 | 38.35…38.35 | 38.35…38.35 | miss |
| average | 30 | 0 / 1 | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 30 | 29 | 0 | 1 | 0 | 6 × 1, 8 × 1, 9 × 1, 10 × 1, 12 × 2, 13 × 2, 14 × 1, 15 × 10, 16 × 2, 20 × 1, 22 × 2, 25 × 2, 27 × 1, 29 × 1, 30 × 1 | sentry_turret × 8, war_machine × 3, shield_robot × 2 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 16 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 67.95% | 25.32 (285) | 12.27 (193) |
| patrol_cop | 0 | — | 88.7% | 20.96 (410) | 12.32 (68) |
| riot_cop | 0 | — | 72.39% | 25.02 (299) | 10.95 (179) |
| robot_gunner | 0 | — | 68.06% | 28.9 (249) | 9.75 (229) |
| robot_thug | 0 | — | 61.41% | 27.27 (233) | 10.27 (245) |
| rocket_trooper | 0 | — | 70.2% | 25.32 (289) | 12.25 (189) |
| sentry_turret | 8 | — | 62.54% | 31.13 (221) | 9.9 (257) |
| shield_robot | 2 | — | 59.77% | 41.24 (170) | 11.85 (308) |
| swat | 0 | — | 72.81% | 25.52 (299) | 11.52 (179) |
| war_machine | 3 | — | 24.93% | 35.1 (79) | 17.63 (399) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 10 (16) | 3.5 (6) | 5 | 4 | -3…10 | not measured (5, all offered) | too few pairs |
| ghost_dent | wave s | 27.64 (14) | 27.14 (6) | 5 | 1.28 | -4.05…4.91 | not measured (4, all offered) | too few pairs |
| ghost_kerf | waves survived | 10 (12) | 2 (12) | 4 | 14.5 | 14…15 | not measured (4, all offered) | too few pairs |
| ghost_kerf | wave s | 26.76 (12) | 28.82 (10) | 4 | 0.42 | -38.18…10.72 | not measured (4, all offered) | too few pairs |
| ghost_ohm | waves survived | 7.5 (16) | 8.5 (8) | 4 | 2.5 | -13…13 | not measured (2, all offered) | too few pairs |
| ghost_ohm | wave s | 35.8 (15) | 25.95 (8) | 4 | 3.6 | -6.78…13.32 | not measured (2, all offered) | too few pairs |
| ghost_tonnage | waves survived | 7.5 (18) | 9 (7) | 4 | 2.5 | -12…13 | not measured (1, all offered) | too few pairs |
| ghost_tonnage | wave s | 39.5 (18) | 22.2 (7) | 4 | 4.5 | -6.25…21.91 | not measured (1, all offered) | too few pairs |
| stat_damage_10 | waves survived | 11 (21) | 9.5 (6) | 4 | 0 | -1…7 | 3 (7, all offered) | noise |
| stat_damage_10 | wave s | 27.31 (20) | 22.16 (6) | 4 | -0.53 | -4.29…3.93 | 6.64 (6, all offered) | noise |
| stat_damage_25 | waves survived | 7 (12) | 5.5 (6) | 2 | 4.5 | -5…14 | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 34.83 (11) | 39.23 (6) | 2 | 1.54 | -15.61…18.68 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 8 (23) | 8 (6) | 6 | 8.5 | 3…14 | 12 (8, all offered) | noise |
| stat_guard_meter_10 | wave s | 29.85 (22) | 19.34 (6) | 6 | 11.61 | 5.72…18.58 | 14.35 (8, all offered) | noise |
| stat_guard_meter_25 | waves survived | 4.5 (18) | 7 (4) | 2 | 7.5 | 2…13 | not measured (4, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 36.25 (13) | 25.83 (3) | 1 | -1.8 | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 10 (19) | 7.5 (10) | 8 | 4 | -3…22 | 7 (7, all offered) | noise |
| stat_hp_max_10 | wave s | 28.8 (19) | 20.52 (9) | 8 | 3.98 | -18.58…24.26 | 18.58 (7, all offered) | noise |
| stat_hp_max_25 | waves survived | 8 (10) | 4 (10) | 2 | 15 | 10…20 | not measured (4, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 41.77 (9) | 39.25 (8) | 1 | 2 | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_10 | waves survived | 10.5 (24) | 11 (5) | 5 | 2 | 0…17 | 17 (7, all offered) | noise |
| stat_regen_10 | wave s | 25.96 (23) | 19.51 (5) | 5 | 6.23 | -6.24…29.6 | 11.53 (7, all offered) | noise |
| stat_regen_25 | waves survived | 6 (12) | 6 (12) | 2 | -3 | -10…4 | not measured (4, all offered) | too few pairs |
| stat_regen_25 | wave s | 38.15 (12) | 29.41 (11) | 2 | 3.87 | -1.66…9.4 | not measured (4, all offered) | too few pairs |
| stat_speed_10 | waves survived | 8 (25) | 10.5 (4) | 4 | 0 | -5…10 | not measured (5, all offered) | too few pairs |
| stat_speed_10 | wave s | 30.3 (22) | 17.69 (4) | 3 | -1.31 | -4.6…11.97 | not measured (5, all offered) | too few pairs |
| stat_speed_25 | waves survived | 3.5 (12) | 7 (11) | 3 | 10 | -3…12 | not measured (3, all offered) | too few pairs |
| stat_speed_25 | wave s | 39.83 (8) | 25.83 (11) | 2 | 3.5 | -0.16…7.17 | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 7 (21) | 6.5 (8) | 5 | 1 | -10…14 | 16 (6, all offered) | noise |
| weapon_chainsaw | wave s | 32 (21) | 25.45 (8) | 5 | -1.59 | -13.08…20.03 | 20.28 (6, all offered) | noise |
| weapon_electro_baton | waves survived | 6 (17) | 7 (11) | 7 | 7 | -1…14 | 10 (7, all offered) | noise |
| weapon_electro_baton | wave s | 36.14 (16) | 20.48 (11) | 7 | 1.42 | -2.85…17.95 | 17.95 (7, all offered) | noise |
| weapon_flamethrower | waves survived | 7 (22) | 9.5 (6) | 4 | 1 | -5…7 | 10 (6, all offered) | noise |
| weapon_flamethrower | wave s | 41.74 (22) | 23.97 (6) | 4 | 5.33 | -3.96…32.25 | 12.5 (6, all offered) | noise |
| weapon_gatling | waves survived | 6 (13) | 2 (9) | 4 | 1.5 | -2…15 | 17 (6, all offered) | noise |
| weapon_gatling | wave s | 38.37 (13) | 46.67 (8) | 4 | -13.32 | -26.82…0.4 | 26.82 (6, all offered) | noise |
| weapon_gloria | waves survived | 7 (25) | 6 (5) | 4 | 4 | 2…8 | 7 (6, all offered) | noise |
| weapon_gloria | wave s | 24.07 (23) | 18.53 (5) | 4 | 1.24 | -3.38…5.23 | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 5 (23) | 10 (5) | 3 | -2 | -4…13 | 7 (6, all offered) | noise |
| weapon_hand_cannon | wave s | 30.13 (22) | 25.16 (5) | 3 | -5.68 | -13.32…-4.69 | 5.68 (6, all offered) | noise |
| weapon_katana | waves survived | 9 (17) | 6 (13) | 7 | 3 | 1…7 | 3 (8, all offered) | noise |
| weapon_katana | wave s | 38.27 (17) | 24.2 (12) | 6 | 2.82 | -1.62…21.53 | 21.64 (8, all offered) | noise |
| weapon_machine_pistol | waves survived | 9 (22) | 7 (7) | 6 | -1.5 | -4…10 | not measured (5, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 34.81 (22) | 22.99 (7) | 6 | -4.15 | -15.14…6.22 | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 8 (19) | 3.5 (10) | 5 | 4 | 2…7 | not measured (4, all offered) | too few pairs |
| weapon_pistol | wave s | 33.45 (19) | 23.56 (10) | 5 | 4.17 | -17.68…9.44 | not measured (4, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 9 (19) | 7 (7) | 5 | 2 | -3…5 | 5 (7, all offered) | noise |
| weapon_plasma_rifle | wave s | 36.06 (18) | 25.83 (7) | 5 | 5.38 | -20.77…22.79 | 6.98 (7, all offered) | noise |
| weapon_plasma_sword | waves survived | 10 (16) | 6 (10) | 5 | 8 | 1…14 | 10 (8, all offered) | noise |
| weapon_plasma_sword | wave s | 35.65 (14) | 25.87 (10) | 5 | 3.58 | -5.44…30 | 7.83 (7, all offered) | noise |
| weapon_rocket_launcher | waves survived | 7 (19) | 4 (8) | 2 | 9 | 1…17 | 10 (7, all offered) | noise |
| weapon_rocket_launcher | wave s | 35.35 (19) | 31.72 (8) | 2 | 6.13 | -12.39…24.65 | 9.33 (7, all offered) | noise |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 7 (21) | 6.5 (8) | 5 | 1 | -10…14 | 16 (6, all offered) | noise |
| chainsaw | wave s | 32 (21) | 25.45 (8) | 5 | -1.59 | -13.08…20.03 | 20.28 (6, all offered) | noise |
| electro_baton | waves survived | 6 (17) | 7 (11) | 7 | 7 | -1…14 | 10 (7, all offered) | noise |
| electro_baton | wave s | 36.14 (16) | 20.48 (11) | 7 | 1.42 | -2.85…17.95 | 17.95 (7, all offered) | noise |
| flamethrower | waves survived | 7 (22) | 9.5 (6) | 4 | 1 | -5…7 | 10 (6, all offered) | noise |
| flamethrower | wave s | 41.74 (22) | 23.97 (6) | 4 | 5.33 | -3.96…32.25 | 12.5 (6, all offered) | noise |
| gatling | waves survived | 6 (13) | 2 (9) | 4 | 1.5 | -2…15 | 17 (6, all offered) | noise |
| gatling | wave s | 38.37 (13) | 46.67 (8) | 4 | -13.32 | -26.82…0.4 | 26.82 (6, all offered) | noise |
| gloria | waves survived | 7 (25) | 6 (5) | 4 | 4 | 2…8 | 7 (6, all offered) | noise |
| gloria | wave s | 24.07 (23) | 18.53 (5) | 4 | 1.24 | -3.38…5.23 | not measured (5, all offered) | too few pairs |
| hand_cannon | waves survived | 5 (23) | 10 (5) | 3 | -2 | -4…13 | 7 (6, all offered) | noise |
| hand_cannon | wave s | 30.13 (22) | 25.16 (5) | 3 | -5.68 | -13.32…-4.69 | 5.68 (6, all offered) | noise |
| katana | waves survived | 9 (17) | 6 (13) | 7 | 3 | 1…7 | 3 (8, all offered) | noise |
| katana | wave s | 38.27 (17) | 24.2 (12) | 6 | 2.82 | -1.62…21.53 | 21.64 (8, all offered) | noise |
| machine_pistol | waves survived | 9 (22) | 7 (7) | 6 | -1.5 | -4…10 | not measured (5, all offered) | too few pairs |
| machine_pistol | wave s | 34.81 (22) | 22.99 (7) | 6 | -4.15 | -15.14…6.22 | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 8 (19) | 3.5 (10) | 5 | 4 | 2…7 | not measured (4, all offered) | too few pairs |
| pistol | wave s | 33.45 (19) | 23.56 (10) | 5 | 4.17 | -17.68…9.44 | not measured (4, all offered) | too few pairs |
| plasma_rifle | waves survived | 9 (19) | 7 (7) | 5 | 2 | -3…5 | 5 (7, all offered) | noise |
| plasma_rifle | wave s | 36.06 (18) | 25.83 (7) | 5 | 5.38 | -20.77…22.79 | 6.98 (7, all offered) | noise |
| plasma_sword | waves survived | 10 (16) | 6 (10) | 5 | 8 | 1…14 | 10 (8, all offered) | noise |
| plasma_sword | wave s | 35.65 (14) | 25.87 (10) | 5 | 3.58 | -5.44…30 | 7.83 (7, all offered) | noise |
| rocket_launcher | waves survived | 7 (19) | 4 (8) | 2 | 9 | 1…17 | 10 (7, all offered) | noise |
| rocket_launcher | wave s | 35.35 (19) | 31.72 (8) | 2 | 6.13 | -12.39…24.65 | 9.33 (7, all offered) | noise |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | not measured | 0 (30) | 0 (30) | 4 (30) | not measured | not measured | not measured | 6.17 (30) | not measured |
| average | 2 | not measured | 0 (30) | 0 (30) | 6 (30) | not measured | 5.5 (1) | not measured | 6.76 (30) | not measured |
| average | 3 | not measured | 0 (30) | 5.5 (30) | 5 (30) | not measured | 0.03 (1) | not measured | 6.28 (30) | not measured |
| average | 4 | not measured | 0 (30) | 8 (30) | 6 (30) | not measured | 4.08 (1) | 2.57 (1) | 6.3 (29) | 7.1 (1) |
| average | 5 | not measured | 3 (30) | 12.5 (30) | 50.5 (30) | not measured | 2.38 (2) | 8.05 (2) | 22.08 (30) | 7.1 (2) |
| average | 6 | not measured | 1 (30) | 18.5 (30) | 23.5 (30) | not measured | 2.27 (3) | 7.3 (1) | 13.03 (30) | 7.01 (2) |
| average | 7 | not measured | 2 (29) | 24 (29) | 35 (29) | not measured | 2.08 (2) | 7.3 (1) | 12.03 (29) | 7.1 (2) |
| average | 8 | not measured | 2 (29) | 39 (29) | 45 (29) | not measured | 4.54 (4) | 7.3 (1) | 14.47 (29) | 7.1 (4) |
| average | 9 | not measured | 2 (28) | 35 (28) | 59.5 (28) | not measured | 3.13 (6) | 7.3 (3) | 18.59 (28) | 7.1 (4) |
| average | 10 | not measured | 8 (27) | 59 (27) | 93 (27) | not measured | 5.5 (5) | 7.3 (8) | 32.72 (27) | 7.1 (10) |
| average | 11 | not measured | 6 (26) | 72 (26) | 102.5 (26) | not measured | 2.23 (7) | 7.3 (6) | 22.65 (26) | 7.1 (8) |
| average | 12 | not measured | 6.5 (26) | 69 (26) | 115.5 (26) | not measured | 2.25 (7) | 7.3 (5) | 28.52 (26) | 7.1 (10) |
| average | 13 | not measured | 8 (24) | 121.5 (24) | 182 (24) | not measured | 5.5 (7) | 7.3 (6) | 30.7 (24) | 7.1 (10) |
| average | 14 | not measured | 8.5 (22) | 93 (22) | 121.5 (22) | not measured | 3.48 (7) | 7.3 (6) | 25.41 (22) | 7.1 (10) |
| average | 15 | not measured | 13 (21) | 71 (21) | 81 (21) | not measured | 6.47 (8) | 14.6 (7) | 31.85 (21) | 7.1 (13) |
| average | 16 | not measured | 10 (11) | 90 (11) | 129 (11) | not measured | 5.33 (6) | 7.3 (3) | 31.88 (11) | 7.1 (6) |
| average | 17 | not measured | 9 (9) | 104 (9) | 130 (9) | not measured | 4.92 (4) | 0.87 (1) | 31.62 (9) | 7.1 (6) |
| average | 18 | not measured | 12 (9) | 110 (9) | 143 (9) | not measured | 5.5 (6) | 7.3 (3) | 23.37 (9) | 7.1 (5) |
| average | 19 | not measured | 9 (9) | 72 (9) | 94 (9) | not measured | 5.5 (5) | 7.3 (1) | 21.18 (9) | 7.1 (4) |
| average | 20 | not measured | 25 (9) | 72 (9) | 142 (9) | not measured | 5.5 (7) | 14.6 (4) | 32.73 (9) | 7.1 (6) |
| average | 21 | not measured | 13.5 (8) | 93 (8) | 149 (8) | not measured | 5.92 (6) | 7.3 (3) | 29.05 (8) | 7.1 (4) |
| average | 22 | not measured | 14.5 (8) | 165.5 (8) | 239 (8) | not measured | 5.5 (4) | 7.3 (3) | 40.54 (8) | 7.1 (3) |
| average | 23 | not measured | 17 (6) | 96.5 (6) | 168 (6) | not measured | 5.5 (4) | 7.3 (3) | 32.77 (6) | 10.65 (4) |
| average | 24 | not measured | 16.5 (6) | 85 (6) | 111.5 (6) | not measured | 5.5 (5) | 7.3 (3) | 25.27 (6) | 7.1 (4) |
| average | 25 | not measured | 20 (6) | 125 (6) | 188.5 (6) | not measured | 3.54 (4) | 14.6 (5) | 41.33 (6) | 14.2 (4) |
| average | 26 | not measured | 25 (4) | 93 (4) | 151 (4) | not measured | 8.46 (4) | 7.3 (3) | 42.12 (4) | 7.1 (4) |
| average | 27 | not measured | 13.5 (4) | 92.5 (4) | 182 (4) | not measured | 9.12 (3) | 14.62 (3) | 35.83 (4) | 7.1 (3) |
| average | 28 | not measured | 13 (3) | 50 (3) | 116 (3) | not measured | 6.08 (3) | 10.95 (2) | 27.33 (3) | 7.1 (2) |
| average | 29 | not measured | 37 (2) | 59.5 (2) | 163.5 (2) | 0 (1) | 6.45 (3) | 7.3 (3) | 41.77 (2) | 10.65 (2) |
| average | 30 | not measured | 26 (1) | 36 (1) | 99 (1) | not measured | not measured | 10.98 (1) | 25.55 (1) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 27 | 30 | 2.6 | stat_hp_max_10 → weapon_hand_cannon → stat_regen_10 → stat_damage_10 → stat_guard_meter_10 → stat_speed_10 → weapon_plasma_rifle → ghost_ohm → weapon_rocket_launcher → ghost_tonnage → weapon_katana → stat_speed_25 → ghost_kerf → weapon_gatling → weapon_electro_baton → weapon_machine_pistol → weapon_flamethrower → weapon_chainsaw → weapon_plasma_sword → stat_guard_meter_25 → stat_damage_25 → ghost_dent → stat_hp_max_25 → stat_regen_25 → weapon_pistol → weapon_gloria | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=27 --bot=average --pick=random --controls=wheel |
