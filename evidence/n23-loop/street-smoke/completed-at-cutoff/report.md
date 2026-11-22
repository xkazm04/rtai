# Gauntlet run report

This checkpoint contains 6 of the nine requested runs. The serial smoke was still running at capture time.

6 of 6 runs accepted. Average-profile waves 1 (10.7 s), 2 (11.87 s), 4 (11.97 s), 5 (21.92 s), 8 (23.98 s), 9 (32.75 s), 10 (19.98 s), 11 (31.63 s), 12 (26.08 s), 13 (38.23 s), 14 (38.42 s), 15 (38.8 s), 16 (32.37 s), 17 (28.6 s), 18 (39.48 s), 19 (33.17 s), 20 (30.55 s), 21 (41.42 s), 22 (45.09 s), 23 (36.08 s), 24 (38.36 s), 26 (37.31 s), 27 (44.68 s), 28 (39.75 s), 29 (42.96 s), 30 (39.46 s), 31 (48.96 s), 32 (50.55 s), 33 (46.28 s), 34 (46.11 s), 35 (44.54 s), 36 (47.67 s), 37 (49.72 s), 38 (54.52 s), 39 (50.04 s), 40 (42.83 s), 41 (67.1 s), 42 (47.44 s), 43 (57.92 s), 44 (57.63 s), 45 (56.37 s), 46 (58.66 s), 47 (57.29 s), 48 (76.58 s), 49 (60.82 s), 50 (64 s), 51 (55.55 s), 52 (69.5 s), 53 (63.5 s), 54 (75.82 s), 55 (76.02 s), 56 (63 s), 57 (42.65 s), 58 (58.18 s), 59 (71.17 s), 60 (48.88 s), 61 (56.4 s), 62 (68.12 s), 63 (73.72 s), 64 (61.7 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Imported files · n23-loop @ 4206c0f2ec14 (dirty) · 2026-11-22T03:27:15.721Z.

Stalled runs by profile: average 0, novice 0.

Capped alive by profile: average 1, novice 0.

## Death-wave score

Capped runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / capped |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 13 | 10–29 | 10–29 | 3 / 0 |
| average | 12 | 50 | 22–66 | 22–66 | 2 / 1 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 37 | 3 / 3 | 100% | 0 | separated |
| novice → expert | not measured | 0 / 0 | — | 0 | undetermined |
| average → expert | not measured | 0 / 0 | — | 0 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| average | 1 | capped ≥ 66 | 2 | — |
| average | 2 | died on 22 | 0 | 1 |
| average | 3 | died on 50 | 0 | 1 |
| novice | 1 | died on 29 | 1 | 1 |
| novice | 2 | died on 10 | 0 | 1 |
| novice | 3 | died on 13 | 0 | 1 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 3 / 3 | 10.7 | 9.4…10.9 | 9.4…10.9 | miss |
| average | 2 | 3 / 3 | 11.87 | 11.42…14.83 | 11.42…14.83 | miss |
| average | 3 | 3 / 3 | 15.37 | 8.83…18.4 | 8.83…18.4 | within target |
| average | 4 | 3 / 3 | 11.97 | 8.63…15.13 | 8.63…15.13 | miss |
| average | 5 | 3 / 3 | 21.92 | 11.32…24.18 | 11.32…24.18 | miss |
| average | 6 | 3 / 3 | 16.55 | 12.25…19.8 | 12.25…19.8 | within target |
| average | 7 | 3 / 3 | 16.43 | 12.35…26.47 | 12.35…26.47 | within target |
| average | 8 | 3 / 3 | 23.98 | 17.42…24.48 | 17.42…24.48 | miss |
| average | 9 | 3 / 3 | 32.75 | 30.98…37.97 | 30.98…37.97 | miss |
| average | 10 | 3 / 3 | 19.98 | 19.23…20.43 | 19.23…20.43 | miss |
| average | 11 | 3 / 3 | 31.63 | 21.13…34.35 | 21.13…34.35 | miss |
| average | 12 | 3 / 3 | 26.08 | 21.05…35.95 | 21.05…35.95 | miss |
| average | 13 | 3 / 3 | 38.23 | 29.72…46.95 | 29.72…46.95 | miss |
| average | 14 | 3 / 3 | 38.42 | 29.47…52.08 | 29.47…52.08 | miss |
| average | 15 | 3 / 3 | 38.8 | 27.95…42.95 | 27.95…42.95 | miss |
| average | 16 | 3 / 3 | 32.37 | 28…38.48 | 28…38.48 | miss |
| average | 17 | 3 / 3 | 28.6 | 19.1…41.35 | 19.1…41.35 | miss |
| average | 18 | 3 / 3 | 39.48 | 34.42…39.87 | 34.42…39.87 | miss |
| average | 19 | 3 / 3 | 33.17 | 30.97…54.17 | 30.97…54.17 | miss |
| average | 20 | 3 / 3 | 30.55 | 19.9…40.6 | 19.9…40.6 | miss |
| average | 21 | 3 / 3 | 41.42 | 24.72…65.13 | 24.72…65.13 | miss |
| average | 22 | 2 / 3 | 45.09 | 42.33…47.85 | 42.33…47.85 | miss |
| average | 23 | 2 / 2 | 36.08 | 31.77…40.38 | 31.77…40.38 | miss |
| average | 24 | 2 / 2 | 38.36 | 31.55…45.17 | 31.55…45.17 | miss |
| average | 25 | 2 / 2 | 29.9 | 27.62…32.18 | 27.62…32.18 | within target |
| average | 26 | 2 / 2 | 37.31 | 36.5…38.12 | 36.5…38.12 | miss |
| average | 27 | 2 / 2 | 44.68 | 37.05…52.32 | 37.05…52.32 | miss |
| average | 28 | 2 / 2 | 39.75 | 38.13…41.37 | 38.13…41.37 | miss |
| average | 29 | 2 / 2 | 42.96 | 41.28…44.63 | 41.28…44.63 | miss |
| average | 30 | 2 / 2 | 39.46 | 29.75…49.17 | 29.75…49.17 | miss |
| average | 31 | 2 / 2 | 48.96 | 48.3…49.62 | 48.3…49.62 | miss |
| average | 32 | 2 / 2 | 50.55 | 45.37…55.73 | 45.37…55.73 | miss |
| average | 33 | 2 / 2 | 46.28 | 38.95…53.62 | 38.95…53.62 | miss |
| average | 34 | 2 / 2 | 46.11 | 44.98…47.23 | 44.98…47.23 | miss |
| average | 35 | 2 / 2 | 44.54 | 43.57…45.52 | 43.57…45.52 | miss |
| average | 36 | 2 / 2 | 47.67 | 47.18…48.15 | 47.18…48.15 | miss |
| average | 37 | 2 / 2 | 49.72 | 40.38…59.05 | 40.38…59.05 | miss |
| average | 38 | 2 / 2 | 54.52 | 53.8…55.23 | 53.8…55.23 | miss |
| average | 39 | 2 / 2 | 50.04 | 45.5…54.58 | 45.5…54.58 | miss |
| average | 40 | 2 / 2 | 42.83 | 38.4…47.27 | 38.4…47.27 | miss |
| average | 41 | 2 / 2 | 67.1 | 64.05…70.15 | 64.05…70.15 | miss |
| average | 42 | 2 / 2 | 47.44 | 46.1…48.78 | 46.1…48.78 | miss |
| average | 43 | 2 / 2 | 57.92 | 55.4…60.43 | 55.4…60.43 | miss |
| average | 44 | 2 / 2 | 57.63 | 53.63…61.62 | 53.63…61.62 | miss |
| average | 45 | 2 / 2 | 56.37 | 52.45…60.28 | 52.45…60.28 | miss |
| average | 46 | 2 / 2 | 58.66 | 53.23…64.08 | 53.23…64.08 | miss |
| average | 47 | 2 / 2 | 57.29 | 56.35…58.23 | 56.35…58.23 | miss |
| average | 48 | 2 / 2 | 76.58 | 72…81.17 | 72…81.17 | miss |
| average | 49 | 2 / 2 | 60.82 | 56.47…65.17 | 56.47…65.17 | miss |
| average | 50 | 1 / 2 | 64 | 64…64 | 64…64 | miss |
| average | 51 | 1 / 1 | 55.55 | 55.55…55.55 | 55.55…55.55 | miss |
| average | 52 | 1 / 1 | 69.5 | 69.5…69.5 | 69.5…69.5 | miss |
| average | 53 | 1 / 1 | 63.5 | 63.5…63.5 | 63.5…63.5 | miss |
| average | 54 | 1 / 1 | 75.82 | 75.82…75.82 | 75.82…75.82 | miss |
| average | 55 | 1 / 1 | 76.02 | 76.02…76.02 | 76.02…76.02 | miss |
| average | 56 | 1 / 1 | 63 | 63…63 | 63…63 | miss |
| average | 57 | 1 / 1 | 42.65 | 42.65…42.65 | 42.65…42.65 | miss |
| average | 58 | 1 / 1 | 58.18 | 58.18…58.18 | 58.18…58.18 | miss |
| average | 59 | 1 / 1 | 71.17 | 71.17…71.17 | 71.17…71.17 | miss |
| average | 60 | 1 / 1 | 48.88 | 48.88…48.88 | 48.88…48.88 | miss |
| average | 61 | 1 / 1 | 56.4 | 56.4…56.4 | 56.4…56.4 | miss |
| average | 62 | 1 / 1 | 68.12 | 68.12…68.12 | 68.12…68.12 | miss |
| average | 63 | 1 / 1 | 73.72 | 73.72…73.72 | 73.72…73.72 | miss |
| average | 64 | 1 / 1 | 61.7 | 61.7…61.7 | 61.7…61.7 | miss |
| average | 65 | 0 / 1 | not measured | not measured | not measured | not measured |
| average | 66 | 0 / 1 | not measured | not measured | not measured | not measured |
| novice | 1 | 3 / 3 | 11.32 | 8.2…22.28 | 8.2…22.28 | — |
| novice | 2 | 3 / 3 | 11.37 | 10.37…13.9 | 10.37…13.9 | — |
| novice | 3 | 3 / 3 | 15.93 | 9.48…21.18 | 9.48…21.18 | — |
| novice | 4 | 3 / 3 | 13.45 | 9.98…14.57 | 9.98…14.57 | — |
| novice | 5 | 3 / 3 | 10.43 | 10.32…18.18 | 10.32…18.18 | — |
| novice | 6 | 3 / 3 | 21.3 | 18.13…25.15 | 18.13…25.15 | — |
| novice | 7 | 3 / 3 | 18.78 | 16.22…27.08 | 16.22…27.08 | — |
| novice | 8 | 3 / 3 | 33.92 | 20.72…150.55 | 20.72…150.55 | — |
| novice | 9 | 3 / 3 | 37.53 | 26.12…58.9 | 26.12…58.9 | — |
| novice | 10 | 2 / 3 | 19.67 | 17.9…21.43 | 17.9…21.43 | — |
| novice | 11 | 2 / 2 | 32.95 | 32.85…33.05 | 32.85…33.05 | — |
| novice | 12 | 2 / 2 | 48.4 | 48.02…48.78 | 48.02…48.78 | — |
| novice | 13 | 1 / 2 | 53.85 | 53.85…53.85 | 53.85…53.85 | — |
| novice | 14 | 1 / 1 | 29.62 | 29.62…29.62 | 29.62…29.62 | — |
| novice | 15 | 1 / 1 | 27.98 | 27.98…27.98 | 27.98…27.98 | — |
| novice | 16 | 1 / 1 | 35.15 | 35.15…35.15 | 35.15…35.15 | — |
| novice | 17 | 1 / 1 | 30.37 | 30.37…30.37 | 30.37…30.37 | — |
| novice | 18 | 1 / 1 | 50.23 | 50.23…50.23 | 50.23…50.23 | — |
| novice | 19 | 1 / 1 | 33.92 | 33.92…33.92 | 33.92…33.92 | — |
| novice | 20 | 1 / 1 | 33.55 | 33.55…33.55 | 33.55…33.55 | — |
| novice | 21 | 1 / 1 | 25.08 | 25.08…25.08 | 25.08…25.08 | — |
| novice | 22 | 1 / 1 | 61.4 | 61.4…61.4 | 61.4…61.4 | — |
| novice | 23 | 1 / 1 | 45.42 | 45.42…45.42 | 45.42…45.42 | — |
| novice | 24 | 1 / 1 | 38.43 | 38.43…38.43 | 38.43…38.43 | — |
| novice | 25 | 1 / 1 | 35.98 | 35.98…35.98 | 35.98…35.98 | — |
| novice | 26 | 1 / 1 | 43.97 | 43.97…43.97 | 43.97…43.97 | — |
| novice | 27 | 1 / 1 | 35.08 | 35.08…35.08 | 35.08…35.08 | — |
| novice | 28 | 1 / 1 | 58.27 | 58.27…58.27 | 58.27…58.27 | — |
| novice | 29 | 0 / 1 | not measured | not measured | not measured | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 3 | 2 | 0 | 1 | 0 | 22 × 1, 50 × 1 | shield_robot × 1, war_cannon × 1 | 0 |
| novice | 3 | 3 | 0 | 0 | 0 | 10 × 1, 13 × 1, 29 × 1 | rocket × 1, shield_robot × 1, stomp × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | average | novice |
| --- | --- | --- |
| timeout | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1–10 | 30 / 30 | 2.19 | 0.12 | 10 | 98.64 | 1.29 | 100 | 6 | 0 | 2 | 1 | 1 | 1.1 | 1 | 1.1 |
| average | 11–20 | 30 / 30 | 40.79 | 1.08 | 10.5 | 75.76 | 33.17 | 100 | 8 | 21 | 10 | 1.1 | 1.1 | 1.375 | 1.05 | 1.2375 |
| average | 21–30 | 22 / 22 | 45.26 | 0.96 | 13.75 | 80.4 | 30.91 | 100 | 14.5 | 51.5 | 11 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| average | 31+ | 56 / 56 | 74.1 | 1.23 | 13.75 | 68.45 | 69.7 | 100 | 17 | 64 | 17 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| novice | 1–10 | 30 / 30 | 9.31 | 0.3 | 10 | 84.56 | 4.2 | 100 | 7 | 0 | 2 | 1 | 1 | 1.1 | 1 | 1.1 |
| novice | 11–20 | 13 / 13 | 64.22 | 1.56 | 10 | 52.69 | 51.67 | 100 | 12 | 0 | 5 | 1.375 | 1.1 | 1.375 | 1 | 1.1 |
| novice | 21–30 | 9 / 9 | 84.6 | 1.94 | 13.75 | 44.15 | 83.48 | 100 | 18 | 0 | 6 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 87.18% | 38.64 (150) | 19.23 (33) |
| patrol_cop | 0 | — | 89.68% | 38.23 (161) | 30.13 (22) |
| riot_cop | 0 | — | 87.69% | 38.42 (151) | 19.83 (32) |
| robot_gunner | 0 | — | 84.98% | 42.33 (133) | 16.07 (50) |
| robot_thug | 0 | — | 86.79% | 40.6 (139) | 14.98 (44) |
| rocket_trooper | 1 | rocket × 1 | 85.74% | 38.42 (146) | 21.92 (37) |
| sentry_turret | 0 | — | 82.53% | 42.65 (127) | 16.49 (56) |
| shield_robot | 2 | — | 80.88% | 45.42 (121) | 18.02 (62) |
| swat | 0 | — | 86.93% | 41.39 (142) | 19.9 (41) |
| war_machine | 2 | stomp × 1, war_cannon × 1 | 16.1% | 30.55 (33) | 38.13 (150) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 18 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 43.97 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 13 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 38.8 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 21 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 40.63 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 27 (5) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_tonnage | wave s | 33.92 (5) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_damage_10 | waves survived | 25 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 43.03 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 27 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 47.52 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 19 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 34.75 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 19.5 (4) | 4 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 43.33 (4) | 29.58 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 21 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 33.09 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 25.5 (4) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 42.93 (4) | not measured | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | waves survived | 24.5 (4) | 14 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | wave s | 47.23 (3) | 22.2 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | waves survived | 21 (4) | 2 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 44.23 (4) | 40.53 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 20.5 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_speed_10 | wave s | 33.05 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_speed_25 | waves survived | 9 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 41.35 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 17 (4) | 3.5 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | 47.19 (4) | 28.67 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 32 (4) | 13 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 38.69 (4) | 23.38 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 19.5 (4) | 9 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 44.33 (4) | 21.43 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 12.5 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gatling | wave s | 36.17 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gloria | waves survived | 15 (4) | 4.5 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 50.97 (3) | 27.1 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 23 (3) | 6 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 52.32 (3) | 33.48 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 19.5 (4) | 7 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | 46.22 (4) | 22.15 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 19 (5) | 8 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 35.15 (5) | 27.24 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 16.5 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 36.42 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 25 (3) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 49.02 (3) | 28.4 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 22 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 38.61 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 16 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 40.53 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 17 (4) | 3.5 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | 47.19 (4) | 28.67 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 32 (4) | 13 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 38.69 (4) | 23.38 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 19.5 (4) | 9 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 44.33 (4) | 21.43 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 12.5 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gatling | wave s | 36.17 (6) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gloria | waves survived | 15 (4) | 4.5 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 50.97 (3) | 27.1 (2) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | 23 (3) | 6 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 52.32 (3) | 33.48 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 19.5 (4) | 7 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | 46.22 (4) | 22.15 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | 19 (5) | 8 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | 35.15 (5) | 27.24 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 16.5 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 36.42 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | 25 (3) | 2 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 49.02 (3) | 28.4 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 22 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 38.61 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 16 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 40.53 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 11 (3) | 1 (3) | 0 (3) | 13 (3) | not measured | not measured | not measured | 10.7 (3) | not measured |
| average | 2 | 8 (3) | 1 (3) | 0 (3) | 14 (3) | not measured | not measured | not measured | 11.87 (3) | not measured |
| average | 3 | 4 (3) | 4 (3) | 0 (3) | 11 (3) | not measured | not measured | not measured | 8.83 (3) | 7.1 (2) |
| average | 4 | 5 (3) | 1 (3) | 0 (3) | 12 (3) | not measured | not measured | 7.3 (1) | 8.63 (3) | not measured |
| average | 5 | 2 (3) | 6 (3) | 0 (3) | 25 (3) | not measured | not measured | not measured | 14.82 (3) | 7.1 (2) |
| average | 6 | 10 (3) | 1 (3) | 0 (3) | 39 (3) | not measured | not measured | 7.3 (1) | 12.25 (3) | 7.1 (1) |
| average | 7 | 4 (3) | 3 (3) | 28 (3) | 38 (3) | not measured | not measured | 7.3 (1) | 12.35 (3) | 7.1 (1) |
| average | 8 | 6 (3) | 6 (3) | 97 (3) | 54 (3) | not measured | not measured | 2.58 (1) | 17.38 (3) | 7.1 (2) |
| average | 9 | 11 (3) | 8 (3) | 98 (3) | 122 (3) | not measured | not measured | 4.81 (2) | 21.55 (3) | 7.1 (2) |
| average | 10 | 5 (3) | 4 (3) | 65 (3) | 66 (3) | not measured | 6.07 (1) | 0.25 (1) | 12.63 (3) | 7.1 (2) |
| average | 11 | 7 (3) | 6 (3) | 58 (3) | 64 (3) | not measured | 8.27 (1) | 3.84 (2) | 24.15 (3) | 7.1 (1) |
| average | 12 | 9 (3) | 7 (3) | 87 (3) | 122 (3) | not measured | 5.5 (1) | 7.3 (1) | 18.98 (3) | 7.1 (2) |
| average | 13 | 24 (3) | 10 (3) | 76 (3) | 169 (3) | not measured | 1.55 (1) | 7.4 (3) | 23.7 (3) | 10.65 (2) |
| average | 14 | 16 (3) | 12 (3) | 83 (3) | 133 (3) | not measured | 0.6 (1) | 7.3 (3) | 24.02 (3) | 7.1 (2) |
| average | 15 | 4 (3) | 12 (3) | 90 (3) | 105 (3) | not measured | 7.65 (2) | 6.08 (3) | 17.8 (3) | 7.1 (2) |
| average | 16 | 10 (3) | 12 (3) | 60 (3) | 162 (3) | not measured | 5.5 (3) | 6.05 (3) | 20.57 (3) | 7.1 (1) |
| average | 17 | 3 (3) | 6 (3) | 102 (3) | 164 (3) | not measured | 9.07 (3) | 7.3 (2) | 17.6 (3) | not measured |
| average | 18 | 7 (3) | 8 (3) | 130 (3) | 200 (3) | not measured | 6.04 (2) | 7.3 (3) | 26.68 (3) | not measured |
| average | 19 | 17 (3) | 9 (3) | 90 (3) | 1426 (3) | not measured | 5.5 (3) | 7.3 (3) | 21.62 (3) | 7.1 (1) |
| average | 20 | 3 (3) | 7 (3) | 41 (3) | 606 (3) | not measured | 1.77 (2) | 7.3 (3) | 13.42 (3) | 7.1 (3) |
| average | 21 | 18 (3) | 9 (3) | 172 (3) | 3283 (3) | not measured | 1.57 (3) | 7.3 (3) | 30.08 (3) | 7.1 (1) |
| average | 22 | 7 (3) | 16 (3) | 66 (3) | 779 (3) | not measured | 4.57 (2) | 7.3 (3) | 20.37 (3) | 7.1 (3) |
| average | 23 | 15.5 (2) | 7 (2) | 127 (2) | 1640.5 (2) | not measured | 4.86 (2) | 7.3 (2) | 23.92 (2) | not measured |
| average | 24 | 17 (2) | 12 (2) | 51.5 (2) | 378.5 (2) | not measured | 5.5 (1) | 7.59 (2) | 20.92 (2) | 7.1 (2) |
| average | 25 | 14.5 (2) | 12 (2) | 60.5 (2) | 1448 (2) | not measured | 6.17 (2) | 7.3 (1) | 20.08 (2) | not measured |
| average | 26 | 16 (2) | 11.5 (2) | 124 (2) | 3144.5 (2) | not measured | 8.32 (1) | 5.97 (2) | 23.63 (2) | 7.1 (1) |
| average | 27 | 27.5 (2) | 9 (2) | 193 (2) | 3301 (2) | not measured | 4.62 (1) | 3.76 (2) | 31.52 (2) | 7.1 (2) |
| average | 28 | 15.5 (2) | 12 (2) | 99.5 (2) | 2466 (2) | not measured | 5.5 (1) | 9.32 (2) | 24.13 (2) | 7.1 (1) |
| average | 29 | 14.5 (2) | 15 (2) | 141.5 (2) | 3253 (2) | not measured | 5.5 (1) | 7.3 (2) | 25.8 (2) | 7.1 (2) |
| average | 30 | 5.5 (2) | 19.5 (2) | 71 (2) | 1655.5 (2) | not measured | 4.9 (2) | 7.31 (2) | 23.69 (2) | 7.1 (1) |
| average | 31 | 21.5 (2) | 17.5 (2) | 121 (2) | 2754.5 (2) | not measured | 5.5 (2) | 7.3 (2) | 32.61 (2) | 7.1 (1) |
| average | 32 | 15.5 (2) | 19.5 (2) | 146.5 (2) | 1949.5 (2) | not measured | 8.25 (2) | 7.04 (2) | 31.7 (2) | 7.1 (1) |
| average | 33 | 12.5 (2) | 14.5 (2) | 162.5 (2) | 2372.5 (2) | not measured | 4.48 (1) | 7.3 (2) | 29.64 (2) | 7.1 (2) |
| average | 34 | 19 (2) | 16.5 (2) | 104 (2) | 3319.5 (2) | not measured | 7.04 (2) | 7.3 (2) | 28.23 (2) | 7.1 (1) |
| average | 35 | 4 (2) | 14 (2) | 93.5 (2) | 2169 (2) | not measured | 1.35 (1) | 10.95 (2) | 25.82 (2) | 7.1 (2) |
| average | 36 | 19.5 (2) | 14 (2) | 121.5 (2) | 3260 (2) | not measured | 5.49 (2) | 14.6 (1) | 31.32 (2) | 7.1 (1) |
| average | 37 | 15 (2) | 13.5 (2) | 189.5 (2) | 3670 (2) | not measured | 5.5 (2) | 7.3 (2) | 29.81 (2) | 7.1 (2) |
| average | 38 | 21 (2) | 16.5 (2) | 163 (2) | 3819 (2) | not measured | 5.5 (2) | 10.95 (2) | 34.52 (2) | 7.1 (1) |
| average | 39 | 10.5 (2) | 11.5 (2) | 119.5 (2) | 2744 (2) | not measured | 5.5 (2) | 7.3 (2) | 30.14 (2) | 7.1 (2) |
| average | 40 | 15 (2) | 8 (2) | 125.5 (2) | 3239 (2) | not measured | 5.5 (1) | 7.3 (2) | 29.23 (2) | 7.1 (1) |
| average | 41 | 20 (2) | 18.5 (2) | 91.5 (2) | 2108 (2) | not measured | 5.5 (1) | 18.25 (2) | 39 (2) | 7.1 (2) |
| average | 42 | 15.5 (2) | 14.5 (2) | 138 (2) | 4006.5 (2) | not measured | 11 (2) | 7.3 (1) | 29.24 (2) | 7.1 (1) |
| average | 43 | 35.5 (2) | 19 (2) | 108 (2) | 2183 (2) | not measured | 5.5 (1) | 14.6 (2) | 37.02 (2) | 7.1 (1) |
| average | 44 | 20.5 (2) | 15.5 (2) | 95 (2) | 2637 (2) | not measured | 5.5 (1) | 7.3 (2) | 36.92 (2) | 10.65 (2) |
| average | 45 | 14 (2) | 18.5 (2) | 85 (2) | 2806 (2) | not measured | 3.16 (2) | 10.95 (2) | 35.16 (2) | 7.1 (2) |
| average | 46 | 24.5 (2) | 20.5 (2) | 136 (2) | 4547.5 (2) | not measured | 3.58 (2) | 14.6 (2) | 36.92 (2) | 7.1 (1) |
| average | 47 | 18.5 (2) | 14.5 (2) | 205 (2) | 4181 (2) | not measured | 2.27 (2) | 10.95 (2) | 40.52 (2) | 7.1 (1) |
| average | 48 | 15.5 (2) | 27.5 (2) | 239.5 (2) | 4986 (2) | not measured | 7.43 (2) | 14.6 (2) | 47.45 (2) | 7.1 (2) |
| average | 49 | 18.5 (2) | 21.5 (2) | 119.5 (2) | 3152.5 (2) | not measured | 9.18 (2) | 7.3 (2) | 37.25 (2) | 7.1 (2) |
| average | 50 | 17 (2) | 24.5 (2) | 79.5 (2) | 2598 (2) | not measured | 1.46 (2) | 14.6 (2) | 32.73 (2) | 7.1 (1) |
| average | 51 | 17 (1) | 12 (1) | 160 (1) | 3714 (1) | not measured | 5.72 (1) | 12.48 (1) | 30.25 (1) | 7.1 (1) |
| average | 52 | 15 (1) | 14 (1) | 214 (1) | 6392 (1) | not measured | 5.5 (1) | 7.63 (1) | 49.27 (1) | 7.1 (1) |
| average | 53 | 22 (1) | 29 (1) | 112 (1) | 2844 (1) | not measured | not measured | 14.6 (1) | 34.7 (1) | 14.2 (1) |
| average | 54 | 32 (1) | 28 (1) | 166 (1) | 6387 (1) | not measured | 0.63 (1) | 14.6 (1) | 53.48 (1) | 7.1 (1) |
| average | 55 | 23 (1) | 30 (1) | 177 (1) | 2068 (1) | not measured | 3.68 (1) | 21.9 (1) | 43.33 (1) | 7.1 (1) |
| average | 56 | 20 (1) | 23 (1) | 236 (1) | 4588 (1) | not measured | 5.5 (1) | 7.3 (1) | 43.1 (1) | 7.1 (1) |
| average | 57 | 15 (1) | 16 (1) | 110 (1) | 2741 (1) | not measured | 5.5 (1) | 0.43 (1) | 29.62 (1) | 7.1 (1) |
| average | 58 | 13 (1) | 20 (1) | 135 (1) | 3345 (1) | not measured | 5.5 (1) | 7.3 (1) | 38.28 (1) | 7.1 (1) |
| average | 59 | 32 (1) | 22 (1) | 203 (1) | 6378 (1) | not measured | 0.63 (1) | 14.6 (1) | 48.83 (1) | 7.1 (1) |
| average | 60 | 10 (1) | 21 (1) | 195 (1) | 3969 (1) | not measured | 8.97 (1) | 7.3 (1) | 25.52 (1) | 7.1 (1) |
| average | 61 | 30 (1) | 17 (1) | 194 (1) | 4286 (1) | not measured | 8 (1) | 7.3 (1) | 34 (1) | 7.1 (1) |
| average | 62 | 27 (1) | 19 (1) | 165 (1) | 7485 (1) | not measured | not measured | 14.6 (1) | 46.42 (1) | 7.1 (1) |
| average | 63 | 23 (1) | 26 (1) | 164 (1) | 5087 (1) | not measured | 5.5 (1) | 14.6 (1) | 46.52 (1) | 7.1 (1) |
| average | 64 | 16 (1) | 26 (1) | 190 (1) | 3719 (1) | not measured | 11 (1) | 7.3 (1) | 36.3 (1) | 7.1 (1) |
| average | 65 | not measured | not measured | not measured | not measured | 0 (1) | 5.5 (1) | 21.28 (1) | not measured | 7.1 (1) |
| average | 66 | not measured | not measured | not measured | not measured | 0 (1) | 0 (1) | 161.22 (1) | not measured | 7.1 (1) |
| novice | 1 | 8 (3) | 2 (3) | 0 (3) | 13 (3) | not measured | not measured | not measured | 11.32 (3) | not measured |
| novice | 2 | 7 (3) | 1 (3) | 0 (3) | 14 (3) | not measured | not measured | not measured | 11.37 (3) | not measured |
| novice | 3 | 5 (3) | 1 (3) | 0 (3) | 11 (3) | not measured | not measured | not measured | 15.93 (3) | 3.78 (1) |
| novice | 4 | 4 (3) | 1 (3) | 0 (3) | 12 (3) | not measured | not measured | not measured | 13.45 (3) | not measured |
| novice | 5 | 2 (3) | 1 (3) | 0 (3) | 24 (3) | not measured | not measured | not measured | 10.43 (3) | 7.1 (1) |
| novice | 6 | 11 (3) | 2 (3) | 0 (3) | 37 (3) | not measured | not measured | 7.3 (2) | 10.83 (3) | 7.1 (1) |
| novice | 7 | 7 (3) | 1 (3) | 42 (3) | 35 (3) | not measured | not measured | not measured | 18.78 (3) | 7.1 (1) |
| novice | 8 | 12 (3) | 3 (3) | 94 (3) | 39 (3) | not measured | not measured | 7.3 (1) | 33.92 (3) | 21.3 (1) |
| novice | 9 | 25 (3) | 6 (3) | 74 (3) | 111 (3) | not measured | not measured | 3.66 (2) | 37.4 (3) | 10.65 (2) |
| novice | 10 | 3 (3) | 3 (3) | 31 (3) | 47 (3) | not measured | 5.5 (1) | 2.68 (1) | 10.8 (3) | 7.1 (2) |
| novice | 11 | 16.5 (2) | 4 (2) | 96 (2) | 92.5 (2) | not measured | 5.5 (1) | not measured | 30.2 (2) | not measured |
| novice | 12 | 19 (2) | 9.5 (2) | 101.5 (2) | 125.5 (2) | not measured | 5.5 (1) | 7.3 (2) | 34.8 (2) | 7.1 (1) |
| novice | 13 | 26 (2) | 5.5 (2) | 127 (2) | 153 (2) | not measured | not measured | 7.3 (1) | 32.36 (2) | 14.2 (1) |
| novice | 14 | 10 (1) | 7 (1) | 55 (1) | 107 (1) | not measured | not measured | 7.3 (1) | 15.22 (1) | 7.1 (1) |
| novice | 15 | 4 (1) | 4 (1) | 82 (1) | 91 (1) | not measured | not measured | not measured | 20.88 (1) | 7.1 (1) |
| novice | 16 | 12 (1) | 6 (1) | 58 (1) | 107 (1) | not measured | not measured | 10.48 (1) | 17.57 (1) | 7.1 (1) |
| novice | 17 | 2 (1) | 2 (1) | 75 (1) | 79 (1) | not measured | 0.42 (1) | 7.3 (1) | 15.55 (1) | 7.1 (1) |
| novice | 18 | 12 (1) | 5 (1) | 98 (1) | 138 (1) | not measured | 4.55 (1) | 7.3 (1) | 31.28 (1) | 7.1 (1) |
| novice | 19 | 8 (1) | 5 (1) | 102 (1) | 120 (1) | not measured | not measured | 7.3 (1) | 19.52 (1) | 7.1 (1) |
| novice | 20 | 10 (1) | 5 (1) | 40 (1) | 115 (1) | not measured | not measured | 7.3 (1) | 19.15 (1) | 7.1 (1) |
| novice | 21 | 9 (1) | 2 (1) | 86 (1) | 62 (1) | not measured | 8.58 (1) | not measured | 16.5 (1) | not measured |
| novice | 22 | 29 (1) | 10 (1) | 131 (1) | 223 (1) | not measured | 1.42 (1) | 7.3 (1) | 45.58 (1) | 7.1 (1) |
| novice | 23 | 18 (1) | 5 (1) | 28 (1) | 131 (1) | not measured | 0.52 (1) | 7.3 (1) | 30.5 (1) | 7.1 (1) |
| novice | 24 | 13 (1) | 6 (1) | 21 (1) | 126 (1) | not measured | not measured | 11.53 (1) | 19.8 (1) | 7.1 (1) |
| novice | 25 | 25 (1) | 2 (1) | 160 (1) | 1690 (1) | not measured | not measured | 7.3 (1) | 28.68 (1) | not measured |
| novice | 26 | 23 (1) | 13 (1) | 79 (1) | 1958 (1) | not measured | not measured | 7.55 (1) | 29.32 (1) | 7.1 (1) |
| novice | 27 | 14 (1) | 4 (1) | 18 (1) | 488 (1) | not measured | 5.5 (1) | 7.3 (1) | 15.18 (1) | 7.1 (1) |
| novice | 28 | 33 (1) | 14 (1) | 220 (1) | 3221 (1) | not measured | 5.5 (1) | 7.3 (1) | 38.37 (1) | 7.1 (1) |
| novice | 29 | 16 (1) | 7 (1) | 44 (1) | 1591 (1) | not measured | not measured | 7.3 (1) | 33.03 (1) | 7.1 (1) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| average | 1 | 66 | 0.72 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel |
| novice | 1 | 29 | 1.06 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel |
