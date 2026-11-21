# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 1 (6.17 s), 2 (6.75 s), 3 (6.13 s), 4 (7.96 s), 5 (26.63 s), 9 (20.45 s), 10 (38.59 s), 11 (26.45 s), 12 (26.65 s), 13 (27.73 s), 14 (26.56 s), 15 (43.28 s), 16 (33.93 s), 17 (34.3 s), 18 (33.67 s), 19 (38.18 s), 20 (44.23 s), 21 (41.05 s), 22 (45.42 s), 23 (39.22 s), 24 (47.01 s), 25 (63.82 s), 26 (47.76 s), 27 (52.21 s), 28 (47.7 s), 29 (51.48 s), 30 (61.74 s), 31 (48.85 s), 32 (57.75 s), 33 (55.72 s) fell outside 12–18 s.

Live gauntlet batch · n22-tune-2 @ e945e1e39249 · 2026-11-21T04:18:40.612Z.

Stalled runs by profile: average 0.

Capped alive by profile: average 8.

Baseline n22-loop @ e04de550610b (dirty) · 2026-11-21T04:00:05.137Z · 30 accepted runs.

## Wave time

Seconds per observed wave. The target is 15 s. Average medians below 12 s or above 18 s are flagged. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Before s (n) | After s | Change s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 30 / 30 | 6.17 (30) | 6.17 | 0 | 5.57…6.5 | 3.68…13.42 | miss |
| average | 2 | 30 / 30 | 6.75 (30) | 6.75 | 0 | 6.4…7.82 | 5.4…12.32 | miss |
| average | 3 | 30 / 30 | 6.13 (30) | 6.13 | 0 | 4.58…8.07 | 2.58…11.88 | miss |
| average | 4 | 30 / 30 | 7.96 (30) | 7.96 | 0 | 5.87…9.6 | 3.47…14.35 | miss |
| average | 5 | 30 / 30 | 31.12 (30) | 26.63 | -4.49 | 21.77…32.35 | 9.02…60.25 | miss |
| average | 6 | 30 / 30 | 14.03 (30) | 13.34 | -0.68 | 9.9…16.48 | 2.82…23.97 | within 20% |
| average | 7 | 30 / 30 | 13.77 (30) | 13.27 | -0.49 | 9.83…17.47 | 6.03…30.42 | within 20% |
| average | 8 | 30 / 30 | 15.32 (30) | 13.91 | -1.42 | 9.55…16.12 | 6.53…24.85 | within 20% |
| average | 9 | 29 / 30 | 25.13 (29) | 20.45 | -4.68 | 17.18…24.68 | 10.6…40.68 | miss |
| average | 10 | 28 / 29 | 38.63 (26) | 38.59 | -0.03 | 28.17…45.73 | 9.05…74.17 | miss |
| average | 11 | 28 / 28 | 28.08 (26) | 26.45 | -1.63 | 18.82…35.93 | 8.62…80.75 | miss |
| average | 12 | 27 / 28 | 30.84 (26) | 26.65 | -4.19 | 21.82…36.6 | 10.65…55.93 | miss |
| average | 13 | 27 / 27 | 32.61 (26) | 27.73 | -4.88 | 24.08…36.97 | 14.42…74.37 | miss |
| average | 14 | 26 / 27 | 29.31 (24) | 26.56 | -2.75 | 19.97…34.83 | 13.05…55.73 | miss |
| average | 15 | 24 / 26 | 47.47 (23) | 43.28 | -4.19 | 31.55…53.02 | 18.93…75.72 | miss |
| average | 16 | 23 / 24 | 49.8 (23) | 33.93 | -15.87 | 21.57…40.03 | 13.1…54.78 | miss |
| average | 17 | 22 / 23 | 38 (22) | 34.3 | -3.7 | 27.95…39.3 | 18.43…68.5 | miss |
| average | 18 | 22 / 22 | 38.37 (20) | 33.67 | -4.7 | 23.22…39.4 | 19.67…78.45 | miss |
| average | 19 | 22 / 22 | 39.22 (20) | 38.18 | -1.03 | 29.93…56.05 | 21.05…81.23 | miss |
| average | 20 | 21 / 22 | 54.77 (16) | 44.23 | -10.53 | 35.12…57.17 | 14.62…77.68 | miss |
| average | 21 | 21 / 21 | 41.97 (16) | 41.05 | -0.92 | 31.62…47.52 | 22.18…69.07 | miss |
| average | 22 | 20 / 21 | 45.22 (14) | 45.42 | 0.2 | 32.03…70.42 | 21.3…86.18 | miss |
| average | 23 | 19 / 20 | 51.8 (13) | 39.22 | -12.58 | 35.1…63.58 | 30.08…79.58 | miss |
| average | 24 | 18 / 19 | 44.49 (10) | 47.01 | 2.52 | 31.87…57.82 | 23.28…88.85 | miss |
| average | 25 | 18 / 18 | 47.58 (6) | 63.82 | 16.24 | 47.68…68.37 | 29.12…87.75 | miss |
| average | 26 | 16 / 18 | 58.53 (5) | 47.76 | -10.77 | 42.4…59.42 | 29.85…68.92 | miss |
| average | 27 | 14 / 16 | 35.28 (4) | 52.21 | 16.92 | 44.85…57.75 | 27.92…87.4 | miss |
| average | 28 | 11 / 14 | 72.03 (2) | 47.7 | -24.33 | 37.22…55.28 | 29.58…64.55 | miss |
| average | 29 | 10 / 11 | 54.46 (2) | 51.48 | -2.98 | 32.63…68.13 | 24.28…87.58 | miss |
| average | 30 | 10 / 10 | 58.22 (1) | 61.74 | 3.52 | 53.62…66.78 | 35.62…71.48 | miss |
| average | 31 | 5 / 10 | 66.38 (1) | 48.85 | -17.53 | 44.22…54.32 | 29.68…71.05 | miss |
| average | 32 | 4 / 5 | not measured | 57.75 | not measured | 57.73…77.38 | 18.78…77.38 | miss |
| average | 33 | 3 / 4 | not measured | 55.72 | not measured | 55.72…59.23 | 55.72…59.23 | miss |
| average | 34 | 0 / 3 | not measured | not measured | not measured | not measured | not measured | not measured |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 30 | 22 | 0 | 8 | 0 | 9 × 1, 10 × 1, 12 × 1, 14 × 1, 15 × 2, 16 × 1, 17 × 1, 20 × 1, 22 × 1, 23 × 1, 24 × 1, 26 × 2, 27 × 2, 28 × 3, 29 × 1, 31 × 1, 33 × 1 | sentry_turret × 4, shield_robot × 2, war_machine × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average |
| --- | --- |
| timeout | 15 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 78.74% | 32.3 (490) | 14.6 (218) |
| patrol_cop | 0 | — | 90.72% | 28.69 (618) | 18.46 (90) |
| riot_cop | 0 | — | 78.12% | 31.43 (496) | 14.53 (212) |
| robot_gunner | 0 | — | 75.9% | 33.78 (441) | 11.78 (267) |
| robot_thug | 0 | — | 74.89% | 34.11 (440) | 11.83 (268) |
| rocket_trooper | 0 | — | 75.64% | 31.62 (473) | 16.77 (235) |
| sentry_turret | 4 | — | 72.2% | 34.99 (410) | 12.42 (298) |
| shield_robot | 2 | — | 74.15% | 39.52 (369) | 13.05 (339) |
| swat | 0 | — | 78.09% | 31.5 (495) | 14.58 (213) |
| war_machine | 1 | — | 25.83% | 40.7 (131) | 23.48 (577) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 16.5 (26) | 10 (2) | 2 | 6 | 0…12 | not measured (5, all offered) | too few pairs |
| ghost_dent | wave s | 36.78 (24) | 17.91 (2) | 2 | 10.65 | 8.62…12.68 | not measured (4, all offered) | too few pairs |
| ghost_kerf | waves survived | 12 (27) | 3 (1) | 0 | not measured | not measured | 9 (6, all offered) | insufficient data |
| ghost_kerf | wave s | 39.4 (25) | 16.18 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| ghost_ohm | waves survived | 18.5 (28) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| ghost_ohm | wave s | 33.87 (28) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| ghost_tonnage | waves survived | 17 (29) | not measured | 0 | not measured | not measured | 4 (6, all offered) | insufficient data |
| ghost_tonnage | wave s | 32.15 (29) | not measured | 0 | not measured | not measured | 6.44 (6, all offered) | insufficient data |
| stat_damage_10 | waves survived | 17.5 (30) | not measured | 0 | not measured | not measured | 6 (8, all offered) | insufficient data |
| stat_damage_10 | wave s | 31.98 (30) | not measured | 0 | not measured | not measured | 6.12 (8, all offered) | insufficient data |
| stat_damage_25 | waves survived | 12.5 (26) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 35.39 (26) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 19 (27) | 7 (3) | 3 | 13 | 8…19 | 13 (10, all offered) | noise |
| stat_guard_meter_10 | wave s | 34.83 (27) | 21.06 (3) | 3 | 12.99 | 6.43…21.78 | 12.99 (10, all offered) | noise |
| stat_guard_meter_25 | waves survived | 12 (26) | 3 (2) | 2 | 7.5 | 2…13 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 39.61 (26) | 28.03 (2) | 2 | 7.65 | -3.38…18.67 | not measured (3, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 21 (29) | 5 (1) | 1 | 18 | not measured | 17 (7, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 33.47 (28) | 10.27 (1) | 1 | 20.92 | not measured | 16.24 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 13 (25) | 3.5 (2) | 2 | 8 | 2…14 | 20 (6, all offered) | noise |
| stat_hp_max_25 | wave s | 37.48 (25) | 27.53 (1) | 1 | 10.77 | not measured | not measured (5, all offered) | too few pairs |
| stat_regen_10 | waves survived | 13 (28) | 4 (2) | 2 | 7.5 | 4…11 | not measured (5, all offered) | too few pairs |
| stat_regen_10 | wave s | 37.22 (25) | 16.32 (2) | 2 | 5.76 | -2.38…13.91 | not measured (5, all offered) | too few pairs |
| stat_regen_25 | waves survived | 9 (25) | 5 (2) | 1 | 8 | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_25 | wave s | 43.13 (25) | 18.87 (2) | 1 | 17.35 | not measured | not measured (4, all offered) | too few pairs |
| stat_speed_10 | waves survived | 17 (30) | not measured | 0 | not measured | not measured | 19 (6, all offered) | insufficient data |
| stat_speed_10 | wave s | 34.15 (30) | not measured | 0 | not measured | not measured | 14.62 (6, all offered) | insufficient data |
| stat_speed_25 | waves survived | 11 (25) | 2.5 (2) | 1 | 20 | not measured | not measured (4, all offered) | too few pairs |
| stat_speed_25 | wave s | 41.58 (24) | 19.86 (2) | 1 | 15.23 | not measured | not measured (4, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 10 (21) | 9.5 (8) | 2 | 9 | 1…17 | not measured (4, all offered) | too few pairs |
| weapon_chainsaw | wave s | 45.89 (20) | 26.39 (8) | 2 | 4.73 | -13.14…22.59 | not measured (4, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 9 (19) | 12.5 (10) | 1 | -7 | not measured | 6 (8, all offered) | insufficient data |
| weapon_electro_baton | wave s | 43.97 (19) | 25.21 (10) | 1 | -14.5 | not measured | 14.5 (8, all offered) | insufficient data |
| weapon_flamethrower | waves survived | 6 (23) | 10 (7) | 2 | 9 | -6…24 | 8 (6, all offered) | noise |
| weapon_flamethrower | wave s | 47.86 (23) | 26.07 (7) | 2 | -0.25 | -16.62…16.12 | 23.1 (6, all offered) | noise |
| weapon_gatling | waves survived | 14.5 (28) | not measured | 0 | not measured | not measured | 12 (8, all offered) | insufficient data |
| weapon_gatling | wave s | 35.91 (28) | not measured | 0 | not measured | not measured | 11.34 (8, all offered) | insufficient data |
| weapon_gloria | waves survived | 8.5 (20) | 10.5 (10) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gloria | wave s | 48.24 (20) | 17.22 (10) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 7.5 (20) | 10 (10) | 2 | 14 | 12…16 | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 48.74 (18) | 20.47 (10) | 2 | 20.72 | 16.68…24.75 | not measured (4, all offered) | too few pairs |
| weapon_katana | waves survived | 4 (25) | 9 (5) | 2 | -5 | -8…-2 | 11 (6, all offered) | noise |
| weapon_katana | wave s | 53.38 (23) | 16.82 (5) | 2 | 40.5 | 33.9…47.1 | 17.25 (6, all offered) | higher |
| weapon_machine_pistol | waves survived | 11 (21) | 11 (8) | 1 | 14 | not measured | 8 (7, all offered) | insufficient data |
| weapon_machine_pistol | wave s | 46.26 (20) | 19.8 (8) | 1 | -2.67 | not measured | 23.75 (6, all offered) | insufficient data |
| weapon_pistol | waves survived | 13.5 (26) | 10.5 (2) | 1 | 11 | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | wave s | 38.02 (26) | 21 (2) | 1 | 11.88 | not measured | not measured (5, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 7 (21) | 7 (9) | 2 | 12 | 12…12 | 12 (6, all offered) | noise |
| weapon_plasma_rifle | wave s | 44.05 (20) | 21.15 (9) | 2 | 11.75 | 9.65…13.86 | 13.86 (6, all offered) | noise |
| weapon_plasma_sword | waves survived | 12 (21) | 7 (8) | 3 | 16 | 14…19 | not measured (4, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 44.33 (21) | 20.58 (8) | 3 | 15.76 | -0.57…36.97 | not measured (4, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 15 (25) | 4 (5) | 5 | 18 | 14…21 | 12 (6, all offered) | higher |
| weapon_rocket_launcher | wave s | 38.98 (25) | 20.25 (5) | 5 | 18.55 | 11.67…26.92 | 47.7 (6, all offered) | noise |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 10 (21) | 9.5 (8) | 2 | 9 | 1…17 | not measured (4, all offered) | too few pairs |
| chainsaw | wave s | 45.89 (20) | 26.39 (8) | 2 | 4.73 | -13.14…22.59 | not measured (4, all offered) | too few pairs |
| electro_baton | waves survived | 9 (19) | 12.5 (10) | 1 | -7 | not measured | 6 (8, all offered) | insufficient data |
| electro_baton | wave s | 43.97 (19) | 25.21 (10) | 1 | -14.5 | not measured | 14.5 (8, all offered) | insufficient data |
| flamethrower | waves survived | 6 (23) | 10 (7) | 2 | 9 | -6…24 | 8 (6, all offered) | noise |
| flamethrower | wave s | 47.86 (23) | 26.07 (7) | 2 | -0.25 | -16.62…16.12 | 23.1 (6, all offered) | noise |
| gatling | waves survived | 14.5 (28) | not measured | 0 | not measured | not measured | 12 (8, all offered) | insufficient data |
| gatling | wave s | 35.91 (28) | not measured | 0 | not measured | not measured | 11.34 (8, all offered) | insufficient data |
| gloria | waves survived | 8.5 (20) | 10.5 (10) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gloria | wave s | 48.24 (20) | 17.22 (10) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| hand_cannon | waves survived | 7.5 (20) | 10 (10) | 2 | 14 | 12…16 | not measured (5, all offered) | too few pairs |
| hand_cannon | wave s | 48.74 (18) | 20.47 (10) | 2 | 20.72 | 16.68…24.75 | not measured (4, all offered) | too few pairs |
| katana | waves survived | 4 (25) | 9 (5) | 2 | -5 | -8…-2 | 11 (6, all offered) | noise |
| katana | wave s | 53.38 (23) | 16.82 (5) | 2 | 40.5 | 33.9…47.1 | 17.25 (6, all offered) | higher |
| machine_pistol | waves survived | 11 (21) | 11 (8) | 1 | 14 | not measured | 8 (7, all offered) | insufficient data |
| machine_pistol | wave s | 46.26 (20) | 19.8 (8) | 1 | -2.67 | not measured | 23.75 (6, all offered) | insufficient data |
| pistol | waves survived | 13.5 (26) | 10.5 (2) | 1 | 11 | not measured | not measured (5, all offered) | too few pairs |
| pistol | wave s | 38.02 (26) | 21 (2) | 1 | 11.88 | not measured | not measured (5, all offered) | too few pairs |
| plasma_rifle | waves survived | 7 (21) | 7 (9) | 2 | 12 | 12…12 | 12 (6, all offered) | noise |
| plasma_rifle | wave s | 44.05 (20) | 21.15 (9) | 2 | 11.75 | 9.65…13.86 | 13.86 (6, all offered) | noise |
| plasma_sword | waves survived | 12 (21) | 7 (8) | 3 | 16 | 14…19 | not measured (4, all offered) | too few pairs |
| plasma_sword | wave s | 44.33 (21) | 20.58 (8) | 3 | 15.76 | -0.57…36.97 | not measured (4, all offered) | too few pairs |
| rocket_launcher | waves survived | 15 (25) | 4 (5) | 5 | 18 | 14…21 | 12 (6, all offered) | higher |
| rocket_launcher | wave s | 38.98 (25) | 20.25 (5) | 5 | 18.55 | 11.67…26.92 | 47.7 (6, all offered) | noise |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | not measured | 0 (30) | 0 (30) | 4 (30) | not measured | not measured | not measured | 6.17 (30) | not measured |
| average | 2 | not measured | 0 (30) | 0 (30) | 6 (30) | not measured | 0.35 (1) | not measured | 6.75 (30) | not measured |
| average | 3 | not measured | 0 (30) | 0 (30) | 5 (30) | not measured | 1.37 (3) | 4.42 (1) | 5.5 (30) | 5.95 (2) |
| average | 4 | not measured | 1 (30) | 0 (30) | 6 (30) | not measured | 3.65 (3) | not measured | 6.77 (29) | 1.72 (3) |
| average | 5 | not measured | 4 (30) | 0 (30) | 40 (30) | not measured | 1.1 (3) | 7.3 (9) | 22.38 (30) | 7.1 (6) |
| average | 6 | not measured | 2 (30) | 0 (30) | 24 (30) | not measured | 3.83 (3) | 7.3 (4) | 11.82 (29) | 6.55 (1) |
| average | 7 | not measured | 2 (30) | 6.5 (30) | 25.5 (30) | not measured | 2.81 (4) | 5.58 (3) | 10.43 (30) | 7.1 (3) |
| average | 8 | not measured | 2 (30) | 23 (30) | 31.5 (30) | not measured | 4.57 (6) | 7.3 (9) | 10.91 (30) | 5.07 (2) |
| average | 9 | not measured | 4 (30) | 36 (30) | 57 (30) | not measured | 3.83 (6) | 7.3 (7) | 16.99 (30) | 7.1 (12) |
| average | 10 | not measured | 8 (29) | 62 (29) | 98 (29) | not measured | 4.78 (5) | 7.3 (18) | 23.97 (29) | 7.1 (14) |
| average | 11 | not measured | 6.5 (28) | 39.5 (28) | 63.5 (28) | not measured | 3.27 (8) | 7.3 (9) | 17.86 (28) | 7.1 (14) |
| average | 12 | not measured | 8.5 (28) | 56.5 (28) | 83 (28) | not measured | 5.5 (7) | 7.3 (16) | 20.34 (28) | 7.1 (17) |
| average | 13 | not measured | 9 (27) | 53 (27) | 89 (27) | not measured | 1.68 (7) | 7.3 (15) | 21.45 (27) | 7.1 (15) |
| average | 14 | not measured | 8 (27) | 55 (27) | 80 (27) | not measured | 5.14 (10) | 7.3 (16) | 17.97 (27) | 7.1 (15) |
| average | 15 | not measured | 13.5 (26) | 44.5 (26) | 99.5 (26) | not measured | 5.5 (11) | 7.3 (19) | 21.12 (26) | 7.1 (19) |
| average | 16 | not measured | 6.5 (24) | 56.5 (24) | 87 (24) | not measured | 5.5 (11) | 7.3 (13) | 22.16 (24) | 7.1 (15) |
| average | 17 | not measured | 11 (23) | 51 (23) | 98 (23) | not measured | 4.63 (13) | 7.3 (19) | 20.85 (23) | 7.1 (16) |
| average | 18 | not measured | 11 (22) | 48.5 (22) | 96 (22) | not measured | 4.13 (12) | 7.3 (15) | 22.99 (22) | 7.1 (9) |
| average | 19 | not measured | 13.5 (22) | 68 (22) | 118.5 (22) | not measured | 5.5 (10) | 7.3 (18) | 25.5 (22) | 7.1 (16) |
| average | 20 | not measured | 16 (22) | 69 (22) | 121.5 (22) | not measured | 5.5 (12) | 7.3 (20) | 30.13 (22) | 7.1 (17) |
| average | 21 | not measured | 11 (21) | 70 (21) | 124 (21) | not measured | 4.87 (16) | 7.3 (15) | 24.5 (21) | 7.1 (16) |
| average | 22 | not measured | 16 (21) | 82 (21) | 167 (21) | not measured | 5.5 (17) | 7.3 (18) | 25.82 (21) | 7.1 (13) |
| average | 23 | not measured | 14 (20) | 83.5 (20) | 162.5 (20) | not measured | 5.5 (13) | 7.3 (16) | 29.5 (20) | 7.1 (15) |
| average | 24 | not measured | 13 (19) | 64 (19) | 119 (19) | not measured | 5.5 (19) | 7.3 (16) | 29.2 (19) | 7.1 (10) |
| average | 25 | not measured | 23.5 (18) | 124 (18) | 198.5 (18) | not measured | 5.92 (18) | 7.33 (17) | 39.01 (18) | 7.1 (11) |
| average | 26 | not measured | 16 (18) | 176 (18) | 1804 (18) | not measured | 5.5 (17) | 7.3 (18) | 35.08 (18) | 7.1 (8) |
| average | 27 | not measured | 19.5 (16) | 97 (16) | 168 (16) | not measured | 5.5 (15) | 7.3 (14) | 33.68 (16) | 7.1 (13) |
| average | 28 | not measured | 16.5 (14) | 74.5 (14) | 131 (14) | not measured | 5.5 (11) | 7.3 (13) | 27.67 (14) | 7.1 (11) |
| average | 29 | not measured | 19 (11) | 78 (11) | 134 (11) | not measured | 5.5 (10) | 7.3 (10) | 37.27 (11) | 7.1 (8) |
| average | 30 | not measured | 27 (10) | 97 (10) | 172 (10) | not measured | 6.25 (8) | 9.66 (10) | 40.06 (10) | 7.1 (7) |
| average | 31 | not measured | 16 (6) | 55 (6) | 119.5 (6) | 0 (4) | 4.81 (10) | 7.3 (9) | 34.4 (6) | 7.1 (8) |
| average | 32 | not measured | 21 (4) | 43.5 (4) | 183 (4) | 0 (1) | 3.54 (4) | 14.6 (5) | 35.17 (4) | 7.1 (3) |
| average | 33 | not measured | 27.5 (4) | 37 (4) | 133 (4) | not measured | 1.43 (4) | 7.3 (4) | 34.27 (4) | 7.1 (3) |
| average | 34 | not measured | not measured | not measured | not measured | 0 (3) | 1.82 (3) | 7.05 (3) | not measured | 5.72 (3) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 10 | 34 | 1.94 | stat_damage_10 → stat_hp_max_10 → stat_guard_meter_10 → stat_regen_25 → stat_damage_25 → ghost_ohm → stat_speed_10 → stat_hp_max_25 → weapon_pistol → ghost_tonnage → weapon_katana → stat_speed_25 → stat_guard_meter_25 → ghost_dent → weapon_machine_pistol → weapon_rocket_launcher → weapon_gatling → weapon_plasma_sword → weapon_gloria → ghost_kerf → weapon_electro_baton → stat_regen_10 → weapon_hand_cannon → weapon_flamethrower → weapon_plasma_rifle → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=10 --bot=average --pick=greedy --controls=wheel |
| average | 25 | 34 | 1.94 | ghost_ohm → stat_damage_10 → stat_guard_meter_10 → weapon_katana → weapon_flamethrower → stat_speed_10 → weapon_pistol → stat_damage_25 → weapon_gloria → ghost_kerf → weapon_plasma_rifle → stat_hp_max_25 → stat_hp_max_10 → weapon_rocket_launcher → ghost_dent → stat_guard_meter_25 → weapon_chainsaw → stat_regen_25 → stat_regen_10 → ghost_tonnage → weapon_machine_pistol → weapon_gatling → weapon_plasma_sword → stat_speed_25 → weapon_hand_cannon → weapon_electro_baton | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=25 --bot=average --pick=greedy --controls=wheel |
| average | 26 | 34 | 1.94 | stat_speed_10 → stat_damage_10 → stat_regen_10 → ghost_dent → weapon_rocket_launcher → stat_hp_max_25 → ghost_kerf → weapon_plasma_rifle → stat_damage_25 → stat_speed_25 → ghost_ohm → stat_hp_max_10 → stat_guard_meter_10 → weapon_pistol → weapon_gatling → ghost_tonnage → stat_guard_meter_25 → weapon_machine_pistol → weapon_flamethrower → weapon_hand_cannon → weapon_plasma_sword → stat_regen_25 → weapon_electro_baton → weapon_gloria → weapon_chainsaw → weapon_katana | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=26 --bot=average --pick=greedy --controls=wheel |
