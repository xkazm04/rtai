# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 1 (10.35 s), 2 (11.42 s), 4 (11.97 s), 5 (14.78 s), 7 (20.63 s), 8 (22.27 s), 9 (25.95 s), 10 (18.88 s), 11 (28.97 s), 12 (35.72 s), 13 (31.48 s), 14 (24.57 s), 16 (21.5 s), 17 (30.32 s), 18 (23.67 s), 19 (25.75 s), 20 (24.56 s), 21 (29.92 s), 22 (33.23 s), 23 (33.33 s), 24 (33.92 s), 26 (30.44 s), 27 (27.14 s), 28 (35.95 s), 29 (35.95 s), 30 (24.99 s), 31 (37.42 s), 32 (35.45 s), 33 (35.6 s), 34 (29.18 s), 35 (32.02 s), 36 (39.78 s), 37 (37.54 s), 38 (46.2 s), 39 (45.78 s), 40 (38.04 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ b3f4727c0910 · 2026-11-22T16:24:58.200Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 1.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 13 | 11–20 | 9–22 | 5 / 0 |
| average | 12 | 40 | 40–40 | 20–40 | 1 / 4 |
| expert | 20 | 40 | 40–40 | 21–40 | 0 / 5 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 27 | 4 / 5 | 80% | 0 | separated |
| novice → expert | 27 | 4 / 5 | 80% | 1 | separated |
| average → expert | 0 | 1 / 5 | 20% | 4 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 9 | 0 | 1 |
| novice | 2 | died on 22 | 0 | 1 |
| novice | 3 | died on 20 | 0 | 1 |
| novice | 4 | died on 11 | 0 | 1 |
| novice | 5 | died on 13 | 0 | 1 |
| average | 1 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 2 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 3 | died on 20 | 0 | 1 |
| average | 4 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 5 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 1 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 2 | censored at the tick cap (≥ 21) | 3 | — |
| expert | 3 | censored at the wave limit 40 (≥ 40) | 4 | — |
| expert | 4 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 5 | censored at the wave limit 40 (≥ 40) | 0 | — |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 11.32 | 9.23…14.75 | 8.2…22.28 | — |
| novice | 2 | 5 / 5 | 11.37 | 11.07…13.9 | 10.37…14.73 | — |
| novice | 3 | 5 / 5 | 15.93 | 14.2…18.35 | 9.48…21.18 | — |
| novice | 4 | 5 / 5 | 12.23 | 10.1…13.45 | 9.98…14.57 | — |
| novice | 5 | 5 / 5 | 18.43 | 11.33…19.03 | 10.2…19.43 | — |
| novice | 6 | 5 / 5 | 23.52 | 23.33…24.02 | 20.07…26.28 | — |
| novice | 7 | 5 / 5 | 19.38 | 19.27…24.05 | 19…42.22 | — |
| novice | 8 | 5 / 5 | 24.47 | 20.55…24.58 | 12.73…25.45 | — |
| novice | 9 | 4 / 5 | 30.46 | 24.9…37.42 | 22.02…37.42 | — |
| novice | 10 | 4 / 4 | 25.13 | 21.32…71.42 | 10.97…71.42 | — |
| novice | 11 | 3 / 4 | 21.22 | 16.45…32.28 | 16.45…32.28 | — |
| novice | 12 | 3 / 3 | 27.08 | 16.42…51.77 | 16.42…51.77 | — |
| novice | 13 | 2 / 3 | 28.73 | 26.43…31.03 | 26.43…31.03 | — |
| novice | 14 | 2 / 2 | 38.59 | 34.03…43.15 | 34.03…43.15 | — |
| novice | 15 | 2 / 2 | 31.93 | 15.35…48.52 | 15.35…48.52 | — |
| novice | 16 | 2 / 2 | 34.63 | 31.37…37.9 | 31.37…37.9 | — |
| novice | 17 | 2 / 2 | 32.19 | 25.6…38.78 | 25.6…38.78 | — |
| novice | 18 | 2 / 2 | 37.64 | 29.9…45.38 | 29.9…45.38 | — |
| novice | 19 | 2 / 2 | 44.41 | 41.82…47 | 41.82…47 | — |
| novice | 20 | 1 / 2 | 33.65 | 33.65…33.65 | 33.65…33.65 | — |
| novice | 21 | 1 / 1 | 46.13 | 46.13…46.13 | 46.13…46.13 | — |
| novice | 22 | 0 / 1 | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 10.35 | 9.4…10.7 | 9.07…10.9 | miss |
| average | 2 | 5 / 5 | 11.42 | 10.2…11.87 | 9.5…14.83 | miss |
| average | 3 | 5 / 5 | 15.37 | 14.9…15.75 | 8.83…18.4 | within target |
| average | 4 | 5 / 5 | 11.97 | 9.63…12.87 | 8.63…16.22 | miss |
| average | 5 | 5 / 5 | 14.78 | 14.03…23.63 | 5.72…42.23 | miss |
| average | 6 | 5 / 5 | 17.22 | 15.67…20.45 | 12.08…24.53 | within target |
| average | 7 | 5 / 5 | 20.63 | 19.32…21.83 | 10.57…28.08 | miss |
| average | 8 | 5 / 5 | 22.27 | 21.17…23.97 | 16.48…29.13 | miss |
| average | 9 | 5 / 5 | 25.95 | 23.07…26.53 | 18.97…37.4 | miss |
| average | 10 | 5 / 5 | 18.88 | 16.35…30.3 | 8.8…35.88 | miss |
| average | 11 | 5 / 5 | 28.97 | 19.02…31.48 | 15.42…33.1 | miss |
| average | 12 | 5 / 5 | 35.72 | 27.43…37.83 | 22.3…39.88 | miss |
| average | 13 | 5 / 5 | 31.48 | 24.7…38.73 | 22.7…50.93 | miss |
| average | 14 | 5 / 5 | 24.57 | 22.77…24.95 | 20.73…25.23 | miss |
| average | 15 | 5 / 5 | 26.35 | 22.12…32.37 | 10.93…32.57 | within target |
| average | 16 | 5 / 5 | 21.5 | 20.13…31.72 | 19.12…32.23 | miss |
| average | 17 | 5 / 5 | 30.32 | 29.28…31.12 | 13.9…35.27 | miss |
| average | 18 | 5 / 5 | 23.67 | 21.95…33.38 | 16.2…43.38 | miss |
| average | 19 | 5 / 5 | 25.75 | 25.15…28.45 | 18.07…33.3 | miss |
| average | 20 | 4 / 5 | 24.56 | 23.92…31.83 | 10.98…31.83 | miss |
| average | 21 | 4 / 4 | 29.92 | 29.77…35.17 | 24.2…35.17 | miss |
| average | 22 | 4 / 4 | 33.23 | 32.5…46.68 | 25.95…46.68 | miss |
| average | 23 | 4 / 4 | 33.33 | 31.05…40.77 | 24.07…40.77 | miss |
| average | 24 | 4 / 4 | 33.92 | 33.77…34.58 | 33.58…34.58 | miss |
| average | 25 | 4 / 4 | 26.51 | 26.12…38.23 | 21.42…38.23 | within target |
| average | 26 | 4 / 4 | 30.44 | 25.02…44.07 | 23.87…44.07 | miss |
| average | 27 | 4 / 4 | 27.14 | 25.33…33.77 | 24.95…33.77 | miss |
| average | 28 | 4 / 4 | 35.95 | 34.45…40.87 | 27.72…40.87 | miss |
| average | 29 | 4 / 4 | 35.95 | 32.75…52.28 | 28.15…52.28 | miss |
| average | 30 | 4 / 4 | 24.99 | 24.87…28.75 | 23.13…28.75 | miss |
| average | 31 | 4 / 4 | 37.42 | 34.45…55.2 | 29.55…55.2 | miss |
| average | 32 | 4 / 4 | 35.45 | 33.67…44.87 | 31.43…44.87 | miss |
| average | 33 | 4 / 4 | 35.6 | 34.37…37.85 | 31.47…37.85 | miss |
| average | 34 | 4 / 4 | 29.18 | 28.35…38.6 | 28.08…38.6 | miss |
| average | 35 | 4 / 4 | 32.02 | 27.93…36.2 | 27.3…36.2 | miss |
| average | 36 | 4 / 4 | 39.78 | 38.32…42.2 | 38.15…42.2 | miss |
| average | 37 | 4 / 4 | 37.54 | 36.72…38.8 | 34.62…38.8 | miss |
| average | 38 | 4 / 4 | 46.2 | 45.9…52.73 | 40.57…52.73 | miss |
| average | 39 | 4 / 4 | 45.78 | 43.53…62.82 | 28.7…62.82 | miss |
| average | 40 | 4 / 4 | 38.04 | 31.03…47.75 | 29.32…47.75 | miss |
| expert | 1 | 5 / 5 | 10.35 | 9.33…10.67 | 9.33…14.02 | — |
| expert | 2 | 5 / 5 | 13.3 | 10.67…13.37 | 8.88…16.97 | — |
| expert | 3 | 5 / 5 | 11.13 | 10.88…13.9 | 7.6…21.97 | — |
| expert | 4 | 5 / 5 | 11.33 | 9.88…12.37 | 9.08…14.35 | — |
| expert | 5 | 5 / 5 | 22.75 | 11.57…23.8 | 5.08…56.48 | — |
| expert | 6 | 5 / 5 | 17.52 | 11.33…21.97 | 10.68…27.12 | — |
| expert | 7 | 5 / 5 | 13.4 | 11.9…17.73 | 10.87…26.08 | — |
| expert | 8 | 5 / 5 | 19.97 | 15.07…24 | 12.2…31.4 | — |
| expert | 9 | 5 / 5 | 24.73 | 19.48…25.05 | 15.03…32.42 | — |
| expert | 10 | 5 / 5 | 23.47 | 16.75…27.78 | 9.9…29.73 | — |
| expert | 11 | 5 / 5 | 23 | 22.55…28.05 | 10.18…69.22 | — |
| expert | 12 | 5 / 5 | 26.28 | 23.2…27.2 | 21.03…48.18 | — |
| expert | 13 | 5 / 5 | 24.4 | 24.07…32.93 | 18.15…555.8 | — |
| expert | 14 | 5 / 5 | 18.35 | 17.82…19.22 | 15.22…128.77 | — |
| expert | 15 | 5 / 5 | 28.05 | 15.42…50.72 | 9…51.22 | — |
| expert | 16 | 5 / 5 | 27.17 | 25.2…30.35 | 18…35.75 | — |
| expert | 17 | 5 / 5 | 28.62 | 27.3…33.05 | 27.08…219.23 | — |
| expert | 18 | 5 / 5 | 23.02 | 20.6…27.08 | 20.53…105.8 | — |
| expert | 19 | 4 / 5 | 30.69 | 30.6…42.57 | 20.78…42.57 | — |
| expert | 20 | 4 / 5 | 31.79 | 30.08…33.52 | 15.72…33.52 | — |
| expert | 21 | 4 / 5 | 30.25 | 27.85…37.03 | 14.68…37.03 | — |
| expert | 22 | 4 / 4 | 33.27 | 32.75…33.85 | 26.73…33.85 | — |
| expert | 23 | 4 / 4 | 29.49 | 25.6…43.77 | 24.67…43.77 | — |
| expert | 24 | 4 / 4 | 27.38 | 25.98…33.37 | 18.38…33.37 | — |
| expert | 25 | 4 / 4 | 18.61 | 16.28…22.25 | 13.9…22.25 | — |
| expert | 26 | 4 / 4 | 24.7 | 20.85…28.65 | 17.7…28.65 | — |
| expert | 27 | 4 / 4 | 29.02 | 26.25…33.45 | 25.23…33.45 | — |
| expert | 28 | 4 / 4 | 31.77 | 31.55…32.2 | 26.58…32.2 | — |
| expert | 29 | 4 / 4 | 35.72 | 35.23…42.17 | 30.42…42.17 | — |
| expert | 30 | 4 / 4 | 25.32 | 21.82…34.77 | 19.73…34.77 | — |
| expert | 31 | 4 / 4 | 32.53 | 32.45…39.57 | 29.68…39.57 | — |
| expert | 32 | 4 / 4 | 28.82 | 28.2…42.02 | 21.72…42.02 | — |
| expert | 33 | 4 / 4 | 32.51 | 30.75…37.5 | 28.08…37.5 | — |
| expert | 34 | 4 / 4 | 32.14 | 30.85…46.33 | 24.77…46.33 | — |
| expert | 35 | 4 / 4 | 25.32 | 23.7…41.85 | 23.02…41.85 | — |
| expert | 36 | 4 / 4 | 38.08 | 37…39.48 | 31.22…39.48 | — |
| expert | 37 | 4 / 4 | 32.61 | 32.4…41.15 | 29.3…41.15 | — |
| expert | 38 | 4 / 4 | 33.55 | 33.23…43.83 | 29.08…43.83 | — |
| expert | 39 | 4 / 4 | 31.43 | 30.58…37.48 | 25.25…37.48 | — |
| expert | 40 | 4 / 4 | 32.95 | 32.75…38.67 | 30.1…38.67 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 0 | 9 × 1, 11 × 1, 13 × 1, 20 × 1, 22 × 1 | rocket × 3, shield_robot × 1, stomp × 1 | 0 |
| average | 5 | 1 | 0 | 0 | 4 | 20 × 1 | stomp × 1 | 0 |
| expert | 5 | 0 | 0 | 1 | 4 | — | — | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 49 / 49 | 11.8 | 0.64 | 10 | 86.27 | 3 | 100 | 7 | 0 | 1 | 1.1 | 1.1 | 1.1 | 1 | 1 |
| novice | 11–20 | 24 / 24 | 59.97 | 1.6 | 11 | 69.83 | 47.78 | 91.22 | 12 | 0 | 5 | 1.175 | 1.1 | 1.375 | 1.1 | 1.1 |
| novice | 21–30 | 2 / 2 | 127.58 | 2.55 | 11 | 14.91 | 91.5 | 76.18 | 28 | 0 | 7 | 1.375 | 1.375 | 1.375 | 1.1 | 1.375 |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 50 / 50 | 1.8 | 0.13 | 10 | 98.28 | 1.8 | 100 | 6 | 0.5 | 2 | 1.1 | 1.05 | 1.1 | 1 | 1 |
| average | 11–20 | 50 / 50 | 17.12 | 0.66 | 11 | 87.4 | 12.22 | 100 | 11 | 20 | 6 | 1.375 | 1.1 | 1.1 | 1.1 | 1.1 |
| average | 21–30 | 40 / 40 | 18.73 | 0.64 | 13.75 | 88.33 | 20.12 | 100 | 16.5 | 12 | 7 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| average | 31+ | 40 / 40 | 32.3 | 0.85 | 13.75 | 85.68 | 31.33 | 100 | 14.5 | 25.5 | 9 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 1–10 | 50 / 50 | 1.44 | 0.12 | 10 | 98.8 | 1.44 | 100 | 4.5 | 11.5 | 3 | 1.1 | 1.05 | 1.1 | 1 | 1 |
| expert | 11–20 | 50 / 50 | 12.81 | 0.59 | 11 | 92.73 | 11.78 | 100 | 8 | 58.5 | 7 | 1.375 | 1.1 | 1.1 | 1.1 | 1.1 |
| expert | 21–30 | 41 / 41 | 9.33 | 0.37 | 13.75 | 95.2 | 8.4 | 100 | 12.5 | 45 | 8.5 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 31+ | 40 / 40 | 21.92 | 0.63 | 13.75 | 92.07 | 20.43 | 100 | 14 | 86.5 | 10 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 85.12% | 28.08 (340) | 18 (87) |
| patrol_cop | 0 | — | 85.14% | 26.18 (368) | 27.78 (59) |
| riot_cop | 0 | — | 85.96% | 28.05 (344) | 16.48 (83) |
| robot_gunner | 0 | — | 82.23% | 29.89 (304) | 14.75 (123) |
| robot_thug | 0 | — | 83.34% | 29.38 (314) | 14.73 (113) |
| rocket_trooper | 3 | rocket × 3 | 84.4% | 28.12 (340) | 19.27 (87) |
| sentry_turret | 0 | — | 78.77% | 29.31 (300) | 15.67 (127) |
| shield_robot | 1 | — | 75.58% | 31.22 (265) | 16.4 (162) |
| swat | 0 | — | 77.24% | 28.65 (319) | 19.94 (108) |
| war_machine | 2 | stomp × 2 | 17.61% | 25.16 (82) | 26.53 (345) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 46 | 75 | 0.61 | 28.02 (36) | 14.74 (34) |
| novice | All | tonnage_armour_crack | war_machine | 5 | 75 | 0.07 | 19.23 (12) | 22.15 (58) |
| novice | All | kerf_blink_behind | shield_robot | 18 | 75 | 0.24 | 35.73 (22) | 18.39 (48) |
| novice | All | overkill_carry | all waves | 30 | 75 | 0.4 | 21.27 (70) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.32 (5) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.32 (5) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.32 (5) |
| novice | 1 | overkill_carry | all waves | 0 | 5 | 0 | 11.32 (5) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.37 (5) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.37 (5) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.37 (5) |
| novice | 2 | overkill_carry | all waves | 0 | 5 | 0 | 11.37 (5) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | overkill_carry | all waves | 0 | 5 | 0 | 15.93 (5) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.23 (5) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.23 (5) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.23 (5) |
| novice | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.23 (5) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | — | 18.43 (5) |
| novice | 5 | tonnage_armour_crack | war_machine | 3 | 5 | 0.6 | 18.43 (5) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 18.43 (5) |
| novice | 5 | overkill_carry | all waves | 0 | 5 | 0 | 18.43 (5) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | 23.52 (3) | 23.68 (2) |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 23.52 (5) |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 23.52 (5) |
| novice | 6 | overkill_carry | all waves | 0 | 5 | 0 | 23.52 (5) | — |
| novice | 7 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | 24.05 (3) | 19.13 (2) |
| novice | 7 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 19.38 (5) |
| novice | 7 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 19.38 (5) |
| novice | 7 | overkill_carry | all waves | 0 | 5 | 0 | 19.38 (5) | — |
| novice | 8 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 24.47 (5) | — |
| novice | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 24.47 (5) |
| novice | 8 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 24.47 (5) |
| novice | 8 | overkill_carry | all waves | 0 | 5 | 0 | 24.47 (5) | — |
| novice | 9 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 36.02 (3) | 22.02 (1) |
| novice | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 30.46 (4) |
| novice | 9 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | 24.9 (3) | 36.02 (1) |
| novice | 9 | overkill_carry | all waves | 0 | 5 | 0 | 30.46 (4) | — |
| novice | 10 | ohm_short_circuit | sentry_turret | 8 | 4 | 2 | 21.32 (3) | 71.42 (1) |
| novice | 10 | tonnage_armour_crack | war_machine | 2 | 4 | 0.5 | 25.13 (4) | — |
| novice | 10 | kerf_blink_behind | shield_robot | 1 | 4 | 0.25 | 50.18 (2) | 16.14 (2) |
| novice | 10 | overkill_carry | all waves | 0 | 4 | 0 | 25.13 (4) | — |
| novice | 11 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | 24.37 (2) | 21.22 (1) |
| novice | 11 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 21.22 (3) |
| novice | 11 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 21.22 (3) |
| novice | 11 | overkill_carry | all waves | 0 | 4 | 0 | 21.22 (3) | — |
| novice | 12 | ohm_short_circuit | sentry_turret | 4 | 3 | 1.33 | 27.08 (3) | — |
| novice | 12 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 27.08 (3) |
| novice | 12 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 27.08 (3) | — |
| novice | 12 | overkill_carry | all waves | 0 | 3 | 0 | 27.08 (3) | — |
| novice | 13 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 31.03 (1) | 26.43 (1) |
| novice | 13 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 28.73 (2) |
| novice | 13 | kerf_blink_behind | shield_robot | 1 | 3 | 0.33 | 28.73 (2) | — |
| novice | 13 | overkill_carry | all waves | 0 | 3 | 0 | 28.73 (2) | — |
| novice | 14 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 38.59 (2) | — |
| novice | 14 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 38.59 (2) |
| novice | 14 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 38.59 (2) | — |
| novice | 14 | overkill_carry | all waves | 0 | 2 | 0 | 38.59 (2) | — |
| novice | 15 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 31.93 (2) | — |
| novice | 15 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 31.93 (2) | — |
| novice | 15 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 48.52 (1) | 15.35 (1) |
| novice | 15 | overkill_carry | all waves | 0 | 2 | 0 | 31.93 (2) | — |
| novice | 16 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 34.63 (2) | — |
| novice | 16 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 34.63 (2) |
| novice | 16 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 37.9 (1) | 31.37 (1) |
| novice | 16 | overkill_carry | all waves | 3 | 2 | 1.5 | 34.63 (2) | — |
| novice | 17 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 32.19 (2) | — |
| novice | 17 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 32.19 (2) |
| novice | 17 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | 32.19 (2) | — |
| novice | 17 | overkill_carry | all waves | 6 | 2 | 3 | 32.19 (2) | — |
| novice | 18 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 29.9 (1) | 45.38 (1) |
| novice | 18 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 37.64 (2) |
| novice | 18 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 37.64 (2) | — |
| novice | 18 | overkill_carry | all waves | 7 | 2 | 3.5 | 37.64 (2) | — |
| novice | 19 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 44.41 (2) | — |
| novice | 19 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 44.41 (2) |
| novice | 19 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 44.41 (2) | — |
| novice | 19 | overkill_carry | all waves | 12 | 2 | 6 | 44.41 (2) | — |
| novice | 20 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 33.65 (1) | — |
| novice | 20 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 33.65 (1) | — |
| novice | 20 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 33.65 (1) | — |
| novice | 20 | overkill_carry | all waves | 2 | 2 | 1 | 33.65 (1) | — |
| novice | 21 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | 46.13 (1) | — |
| novice | 21 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 46.13 (1) |
| novice | 21 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | 46.13 (1) | — |
| novice | 21 | overkill_carry | all waves | 0 | 1 | 0 | 46.13 (1) | — |
| novice | 22 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | — |
| novice | 22 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| novice | 22 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | — | — |
| novice | 22 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 149 | 180 | 0.83 | 30.07 (133) | 15.98 (46) |
| average | All | tonnage_armour_crack | war_machine | 5 | 180 | 0.03 | 26.35 (35) | 28.82 (144) |
| average | All | kerf_blink_behind | shield_robot | 273 | 180 | 1.52 | 32.37 (123) | 16.42 (56) |
| average | All | overkill_carry | all waves | 980 | 180 | 5.44 | 28.15 (179) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 10.35 (5) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 10.35 (5) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 10.35 (5) |
| average | 1 | overkill_carry | all waves | 0 | 5 | 0 | 10.35 (5) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.42 (5) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.42 (5) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.42 (5) |
| average | 2 | overkill_carry | all waves | 0 | 5 | 0 | 11.42 (5) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.37 (5) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.37 (5) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.37 (5) |
| average | 3 | overkill_carry | all waves | 0 | 5 | 0 | 15.37 (5) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.97 (5) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.97 (5) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.97 (5) |
| average | 4 | overkill_carry | all waves | 0 | 5 | 0 | 11.97 (5) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | — | 14.78 (5) |
| average | 5 | tonnage_armour_crack | war_machine | 4 | 5 | 0.8 | 14.78 (5) | — |
| average | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 14.78 (5) |
| average | 5 | overkill_carry | all waves | 0 | 5 | 0 | 14.78 (5) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 17.22 (3) | 18.06 (2) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 17.22 (5) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 17.22 (5) |
| average | 6 | overkill_carry | all waves | 0 | 5 | 0 | 17.22 (5) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 21.83 (3) | 15.6 (2) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 20.63 (5) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 20.63 (5) |
| average | 7 | overkill_carry | all waves | 0 | 5 | 0 | 20.63 (5) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | 22.27 (5) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 22.27 (5) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 22.27 (5) |
| average | 8 | overkill_carry | all waves | 0 | 5 | 0 | 22.27 (5) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 26.53 (3) | 24.51 (2) |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 25.95 (5) |
| average | 9 | kerf_blink_behind | shield_robot | 2 | 5 | 0.4 | 26.24 (4) | 18.97 (1) |
| average | 9 | overkill_carry | all waves | 0 | 5 | 0 | 25.95 (5) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 17.62 (4) | 35.88 (1) |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | 18.88 (5) | — |
| average | 10 | kerf_blink_behind | shield_robot | 3 | 5 | 0.6 | 33.09 (2) | 16.35 (3) |
| average | 10 | overkill_carry | all waves | 0 | 5 | 0 | 18.88 (5) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | 25.25 (4) | 28.97 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 28.97 (5) |
| average | 11 | kerf_blink_behind | shield_robot | 2 | 5 | 0.4 | 24.26 (2) | 28.97 (3) |
| average | 11 | overkill_carry | all waves | 0 | 5 | 0 | 28.97 (5) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 35.72 (5) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 35.72 (5) |
| average | 12 | kerf_blink_behind | shield_robot | 4 | 5 | 0.8 | 35.72 (5) | — |
| average | 12 | overkill_carry | all waves | 4 | 5 | 0.8 | 35.72 (5) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 50.93 (1) | 28.09 (4) |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 31.48 (5) |
| average | 13 | kerf_blink_behind | shield_robot | 4 | 5 | 0.8 | 31.48 (5) | — |
| average | 13 | overkill_carry | all waves | 2 | 5 | 0.4 | 31.48 (5) | — |
| average | 14 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 24.57 (5) | — |
| average | 14 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 24.57 (5) |
| average | 14 | kerf_blink_behind | shield_robot | 5 | 5 | 1 | 23.67 (4) | 24.95 (1) |
| average | 14 | overkill_carry | all waves | 4 | 5 | 0.8 | 24.57 (5) | — |
| average | 15 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 21.65 (2) | 26.35 (3) |
| average | 15 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | 26.35 (5) | — |
| average | 15 | kerf_blink_behind | shield_robot | 4 | 5 | 0.8 | 29.36 (4) | 10.93 (1) |
| average | 15 | overkill_carry | all waves | 3 | 5 | 0.6 | 26.35 (5) | — |
| average | 16 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | 20.82 (4) | 32.23 (1) |
| average | 16 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 21.5 (5) |
| average | 16 | kerf_blink_behind | shield_robot | 7 | 5 | 1.4 | 26.61 (4) | 19.12 (1) |
| average | 16 | overkill_carry | all waves | 12 | 5 | 2.4 | 21.5 (5) | — |
| average | 17 | ohm_short_circuit | sentry_turret | 3 | 5 | 0.6 | 30.32 (5) | — |
| average | 17 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 30.32 (5) |
| average | 17 | kerf_blink_behind | shield_robot | 5 | 5 | 1 | 24.58 (2) | 30.32 (3) |
| average | 17 | overkill_carry | all waves | 14 | 5 | 2.8 | 30.32 (5) | — |
| average | 18 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 21.95 (3) | 38.38 (2) |
| average | 18 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 23.67 (5) |
| average | 18 | kerf_blink_behind | shield_robot | 8 | 5 | 1.6 | 23.67 (5) | — |
| average | 18 | overkill_carry | all waves | 11 | 5 | 2.2 | 23.67 (5) | — |
| average | 19 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 25.75 (5) | — |
| average | 19 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 25.75 (5) |
| average | 19 | kerf_blink_behind | shield_robot | 11 | 5 | 2.2 | 25.75 (5) | — |
| average | 19 | overkill_carry | all waves | 24 | 5 | 4.8 | 25.75 (5) | — |
| average | 20 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 24.56 (4) | — |
| average | 20 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 24.56 (4) | — |
| average | 20 | kerf_blink_behind | shield_robot | 6 | 5 | 1.2 | 25.2 (3) | 23.92 (1) |
| average | 20 | overkill_carry | all waves | 5 | 5 | 1 | 24.56 (4) | — |
| average | 21 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 29.92 (4) | — |
| average | 21 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 29.92 (4) |
| average | 21 | kerf_blink_behind | shield_robot | 3 | 4 | 0.75 | 29.77 (3) | 35.17 (1) |
| average | 21 | overkill_carry | all waves | 22 | 4 | 5.5 | 29.92 (4) | — |
| average | 22 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | 33.23 (4) | — |
| average | 22 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 33.23 (4) |
| average | 22 | kerf_blink_behind | shield_robot | 9 | 4 | 2.25 | 33.23 (4) | — |
| average | 22 | overkill_carry | all waves | 22 | 4 | 5.5 | 33.23 (4) | — |
| average | 23 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 33.33 (4) | — |
| average | 23 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 33.33 (4) |
| average | 23 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 33.33 (4) | — |
| average | 23 | overkill_carry | all waves | 33 | 4 | 8.25 | 33.33 (4) | — |
| average | 24 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 33.92 (4) | — |
| average | 24 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 33.92 (4) |
| average | 24 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 33.92 (4) | — |
| average | 24 | overkill_carry | all waves | 44 | 4 | 11 | 33.92 (4) | — |
| average | 25 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 26.51 (4) | — |
| average | 25 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 26.51 (4) | — |
| average | 25 | kerf_blink_behind | shield_robot | 9 | 4 | 2.25 | 26.51 (4) | — |
| average | 25 | overkill_carry | all waves | 29 | 4 | 7.25 | 26.51 (4) | — |
| average | 26 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 30.44 (4) | — |
| average | 26 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 30.44 (4) |
| average | 26 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 30.44 (4) | — |
| average | 26 | overkill_carry | all waves | 35 | 4 | 8.75 | 30.44 (4) | — |
| average | 27 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 27.14 (4) | — |
| average | 27 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 27.14 (4) |
| average | 27 | kerf_blink_behind | shield_robot | 6 | 4 | 1.5 | 28.95 (3) | 24.95 (1) |
| average | 27 | overkill_carry | all waves | 41 | 4 | 10.25 | 27.14 (4) | — |
| average | 28 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 35.95 (4) | — |
| average | 28 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 35.95 (4) |
| average | 28 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 35.95 (4) | — |
| average | 28 | overkill_carry | all waves | 43 | 4 | 10.75 | 35.95 (4) | — |
| average | 29 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 32.75 (3) | 39.15 (1) |
| average | 29 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 35.95 (4) |
| average | 29 | kerf_blink_behind | shield_robot | 8 | 4 | 2 | 35.95 (4) | — |
| average | 29 | overkill_carry | all waves | 48 | 4 | 12 | 35.95 (4) | — |
| average | 30 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 24.99 (4) | — |
| average | 30 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 24.99 (4) | — |
| average | 30 | kerf_blink_behind | shield_robot | 14 | 4 | 3.5 | 24.99 (4) | — |
| average | 30 | overkill_carry | all waves | 30 | 4 | 7.5 | 24.99 (4) | — |
| average | 31 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 37.42 (4) | — |
| average | 31 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 37.42 (4) |
| average | 31 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 37.42 (4) | — |
| average | 31 | overkill_carry | all waves | 41 | 4 | 10.25 | 37.42 (4) | — |
| average | 32 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 35.45 (4) | — |
| average | 32 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 35.45 (4) |
| average | 32 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 35.45 (4) | — |
| average | 32 | overkill_carry | all waves | 57 | 4 | 14.25 | 35.45 (4) | — |
| average | 33 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 35.6 (4) | — |
| average | 33 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 35.6 (4) |
| average | 33 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 35.6 (4) | — |
| average | 33 | overkill_carry | all waves | 52 | 4 | 13 | 35.6 (4) | — |
| average | 34 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 30.02 (3) | 28.08 (1) |
| average | 34 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 29.18 (4) |
| average | 34 | kerf_blink_behind | shield_robot | 13 | 4 | 3.25 | 29.18 (4) | — |
| average | 34 | overkill_carry | all waves | 53 | 4 | 13.25 | 29.18 (4) | — |
| average | 35 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 27.93 (3) | 36.1 (1) |
| average | 35 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 32.02 (4) | — |
| average | 35 | kerf_blink_behind | shield_robot | 9 | 4 | 2.25 | 32.02 (4) | — |
| average | 35 | overkill_carry | all waves | 40 | 4 | 10 | 32.02 (4) | — |
| average | 36 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 39.78 (4) | — |
| average | 36 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 39.78 (4) |
| average | 36 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 39.78 (4) | — |
| average | 36 | overkill_carry | all waves | 56 | 4 | 14 | 39.78 (4) | — |
| average | 37 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 37.54 (4) | — |
| average | 37 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 37.54 (4) |
| average | 37 | kerf_blink_behind | shield_robot | 16 | 4 | 4 | 37.54 (4) | — |
| average | 37 | overkill_carry | all waves | 64 | 4 | 16 | 37.54 (4) | — |
| average | 38 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 46.2 (4) | — |
| average | 38 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 46.2 (4) |
| average | 38 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 46.2 (4) | — |
| average | 38 | overkill_carry | all waves | 71 | 4 | 17.75 | 46.2 (4) | — |
| average | 39 | ohm_short_circuit | sentry_turret | 8 | 4 | 2 | 45.78 (4) | — |
| average | 39 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 45.78 (4) |
| average | 39 | kerf_blink_behind | shield_robot | 13 | 4 | 3.25 | 45.78 (4) | — |
| average | 39 | overkill_carry | all waves | 74 | 4 | 18.5 | 45.78 (4) | — |
| average | 40 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 38.04 (4) | — |
| average | 40 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 38.04 (4) | — |
| average | 40 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 38.04 (4) | — |
| average | 40 | overkill_carry | all waves | 46 | 4 | 11.5 | 38.04 (4) | — |
| expert | All | ohm_short_circuit | sentry_turret | 162 | 181 | 0.9 | 28.78 (131) | 15.42 (47) |
| expert | All | tonnage_armour_crack | war_machine | 3 | 181 | 0.02 | 23.8 (35) | 27.08 (143) |
| expert | All | kerf_blink_behind | shield_robot | 290 | 181 | 1.6 | 30.09 (120) | 14.69 (58) |
| expert | All | overkill_carry | all waves | 1085 | 181 | 5.99 | 27.01 (178) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 10.35 (5) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 10.35 (5) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 10.35 (5) |
| expert | 1 | overkill_carry | all waves | 0 | 5 | 0 | 10.35 (5) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.3 (5) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.3 (5) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.3 (5) |
| expert | 2 | overkill_carry | all waves | 0 | 5 | 0 | 13.3 (5) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.13 (5) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.13 (5) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.13 (5) |
| expert | 3 | overkill_carry | all waves | 0 | 5 | 0 | 11.13 (5) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.33 (5) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 11.33 (5) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.33 (5) |
| expert | 4 | overkill_carry | all waves | 0 | 5 | 0 | 11.33 (5) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | — | 22.75 (5) |
| expert | 5 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 22.75 (5) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 22.75 (5) |
| expert | 5 | overkill_carry | all waves | 0 | 5 | 0 | 22.75 (5) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 17.52 (3) | 19.23 (2) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 17.52 (5) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 17.52 (5) |
| expert | 6 | overkill_carry | all waves | 0 | 5 | 0 | 17.52 (5) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | 17.73 (3) | 12.65 (2) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.4 (5) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.4 (5) |
| expert | 7 | overkill_carry | all waves | 0 | 5 | 0 | 13.4 (5) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | 19.97 (5) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 19.97 (5) |
| expert | 8 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 19.97 (5) |
| expert | 8 | overkill_carry | all waves | 0 | 5 | 0 | 19.97 (5) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 24.73 (3) | 22.27 (2) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 24.73 (5) |
| expert | 9 | kerf_blink_behind | shield_robot | 2 | 5 | 0.4 | 24.89 (4) | 15.03 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 5 | 0 | 24.73 (5) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 20.11 (4) | 27.78 (1) |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | 23.47 (5) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 3 | 5 | 0.6 | 28.76 (2) | 16.75 (3) |
| expert | 10 | overkill_carry | all waves | 0 | 5 | 0 | 23.47 (5) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | 22.77 (4) | 69.22 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 23 (5) |
| expert | 11 | kerf_blink_behind | shield_robot | 2 | 5 | 0.4 | 22.77 (2) | 28.05 (3) |
| expert | 11 | overkill_carry | all waves | 0 | 5 | 0 | 23 (5) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 26.28 (5) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 26.28 (5) |
| expert | 12 | kerf_blink_behind | shield_robot | 6 | 5 | 1.2 | 26.28 (5) | — |
| expert | 12 | overkill_carry | all waves | 4 | 5 | 0.8 | 26.28 (5) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 555.8 (1) | 24.23 (4) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 24.4 (5) |
| expert | 13 | kerf_blink_behind | shield_robot | 3 | 5 | 0.6 | 24.4 (5) | — |
| expert | 13 | overkill_carry | all waves | 4 | 5 | 0.8 | 24.4 (5) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 7 | 5 | 1.4 | 18.35 (5) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 18.35 (5) |
| expert | 14 | kerf_blink_behind | shield_robot | 5 | 5 | 1 | 18.78 (4) | 17.82 (1) |
| expert | 14 | overkill_carry | all waves | 8 | 5 | 1.6 | 18.35 (5) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 10 | 5 | 2 | 30.11 (2) | 28.05 (3) |
| expert | 15 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 28.05 (5) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 6 | 5 | 1.2 | 39.38 (4) | 9 (1) |
| expert | 15 | overkill_carry | all waves | 3 | 5 | 0.6 | 28.05 (5) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 4 | 5 | 0.8 | 28.76 (4) | 25.2 (1) |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 27.17 (5) |
| expert | 16 | kerf_blink_behind | shield_robot | 6 | 5 | 1.2 | 26.18 (4) | 35.75 (1) |
| expert | 16 | overkill_carry | all waves | 17 | 5 | 3.4 | 27.17 (5) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 28.62 (5) | — |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 28.62 (5) |
| expert | 17 | kerf_blink_behind | shield_robot | 2 | 5 | 0.4 | 123.27 (2) | 28.62 (3) |
| expert | 17 | overkill_carry | all waves | 38 | 5 | 7.6 | 28.62 (5) | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 6 | 5 | 1.2 | 20.6 (3) | 64.41 (2) |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 23.02 (5) |
| expert | 18 | kerf_blink_behind | shield_robot | 5 | 5 | 1 | 23.02 (5) | — |
| expert | 18 | overkill_carry | all waves | 22 | 5 | 4.4 | 23.02 (5) | — |
| expert | 19 | ohm_short_circuit | sentry_turret | 9 | 5 | 1.8 | 30.69 (4) | — |
| expert | 19 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 30.69 (4) |
| expert | 19 | kerf_blink_behind | shield_robot | 4 | 5 | 0.8 | 30.69 (4) | — |
| expert | 19 | overkill_carry | all waves | 33 | 5 | 6.6 | 30.69 (4) | — |
| expert | 20 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 30.08 (3) | 33.5 (1) |
| expert | 20 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 31.79 (4) | — |
| expert | 20 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | 30.08 (3) | 33.52 (1) |
| expert | 20 | overkill_carry | all waves | 19 | 5 | 3.8 | 31.79 (4) | — |
| expert | 21 | ohm_short_circuit | sentry_turret | 5 | 5 | 1 | 30.25 (4) | — |
| expert | 21 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 30.25 (4) |
| expert | 21 | kerf_blink_behind | shield_robot | 3 | 5 | 0.6 | 32.65 (3) | 27.85 (1) |
| expert | 21 | overkill_carry | all waves | 41 | 5 | 8.2 | 30.25 (4) | — |
| expert | 22 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 33.27 (4) | — |
| expert | 22 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 33.27 (4) |
| expert | 22 | kerf_blink_behind | shield_robot | 6 | 4 | 1.5 | 33.27 (4) | — |
| expert | 22 | overkill_carry | all waves | 39 | 4 | 9.75 | 33.27 (4) | — |
| expert | 23 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 29.49 (4) | — |
| expert | 23 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 29.49 (4) |
| expert | 23 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 29.49 (4) | — |
| expert | 23 | overkill_carry | all waves | 42 | 4 | 10.5 | 29.49 (4) | — |
| expert | 24 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 27.38 (4) | — |
| expert | 24 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 27.38 (4) |
| expert | 24 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 27.38 (4) | — |
| expert | 24 | overkill_carry | all waves | 41 | 4 | 10.25 | 27.38 (4) | — |
| expert | 25 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 18.61 (4) | — |
| expert | 25 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 18.61 (4) | — |
| expert | 25 | kerf_blink_behind | shield_robot | 15 | 4 | 3.75 | 18.61 (4) | — |
| expert | 25 | overkill_carry | all waves | 24 | 4 | 6 | 18.61 (4) | — |
| expert | 26 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 24.7 (4) | — |
| expert | 26 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 24.7 (4) |
| expert | 26 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 24.7 (4) | — |
| expert | 26 | overkill_carry | all waves | 54 | 4 | 13.5 | 24.7 (4) | — |
| expert | 27 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | 31.8 (3) | 25.23 (1) |
| expert | 27 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 29.02 (4) |
| expert | 27 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 31.8 (3) | 26.25 (1) |
| expert | 27 | overkill_carry | all waves | 31 | 4 | 7.75 | 29.02 (4) | — |
| expert | 28 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 31.77 (4) | — |
| expert | 28 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 31.77 (4) |
| expert | 28 | kerf_blink_behind | shield_robot | 18 | 4 | 4.5 | 31.77 (4) | — |
| expert | 28 | overkill_carry | all waves | 45 | 4 | 11.25 | 31.77 (4) | — |
| expert | 29 | ohm_short_circuit | sentry_turret | 7 | 4 | 1.75 | 35.23 (3) | 42.17 (1) |
| expert | 29 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 35.72 (4) |
| expert | 29 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 35.72 (4) | — |
| expert | 29 | overkill_carry | all waves | 48 | 4 | 12 | 35.72 (4) | — |
| expert | 30 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 25.32 (4) | — |
| expert | 30 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 25.32 (4) | — |
| expert | 30 | kerf_blink_behind | shield_robot | 12 | 4 | 3 | 28.83 (3) | 19.73 (1) |
| expert | 30 | overkill_carry | all waves | 32 | 4 | 8 | 25.32 (4) | — |
| expert | 31 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 32.6 (3) | 32.45 (1) |
| expert | 31 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 32.53 (4) |
| expert | 31 | kerf_blink_behind | shield_robot | 17 | 4 | 4.25 | 32.53 (4) | — |
| expert | 31 | overkill_carry | all waves | 47 | 4 | 11.75 | 32.53 (4) | — |
| expert | 32 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 28.82 (4) | — |
| expert | 32 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 28.82 (4) |
| expert | 32 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 29.43 (3) | 28.2 (1) |
| expert | 32 | overkill_carry | all waves | 51 | 4 | 12.75 | 28.82 (4) | — |
| expert | 33 | ohm_short_circuit | sentry_turret | 5 | 4 | 1.25 | 32.51 (4) | — |
| expert | 33 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 32.51 (4) |
| expert | 33 | kerf_blink_behind | shield_robot | 11 | 4 | 2.75 | 32.51 (4) | — |
| expert | 33 | overkill_carry | all waves | 49 | 4 | 12.25 | 32.51 (4) | — |
| expert | 34 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 32.14 (4) | — |
| expert | 34 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 32.14 (4) |
| expert | 34 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 32.14 (4) | — |
| expert | 34 | overkill_carry | all waves | 65 | 4 | 16.25 | 32.14 (4) | — |
| expert | 35 | ohm_short_circuit | sentry_turret | 4 | 4 | 1 | 25.32 (4) | — |
| expert | 35 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 25.32 (4) | — |
| expert | 35 | kerf_blink_behind | shield_robot | 16 | 4 | 4 | 25.32 (4) | — |
| expert | 35 | overkill_carry | all waves | 43 | 4 | 10.75 | 25.32 (4) | — |
| expert | 36 | ohm_short_circuit | sentry_turret | 7 | 4 | 1.75 | 38.08 (4) | — |
| expert | 36 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 38.08 (4) |
| expert | 36 | kerf_blink_behind | shield_robot | 15 | 4 | 3.75 | 38.08 (4) | — |
| expert | 36 | overkill_carry | all waves | 59 | 4 | 14.75 | 38.08 (4) | — |
| expert | 37 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 32.61 (4) | — |
| expert | 37 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 32.61 (4) |
| expert | 37 | kerf_blink_behind | shield_robot | 15 | 4 | 3.75 | 32.61 (4) | — |
| expert | 37 | overkill_carry | all waves | 56 | 4 | 14 | 32.61 (4) | — |
| expert | 38 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 33.55 (4) | — |
| expert | 38 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 33.55 (4) |
| expert | 38 | kerf_blink_behind | shield_robot | 15 | 4 | 3.75 | 33.55 (4) | — |
| expert | 38 | overkill_carry | all waves | 61 | 4 | 15.25 | 33.55 (4) | — |
| expert | 39 | ohm_short_circuit | sentry_turret | 3 | 4 | 0.75 | 31.43 (4) | — |
| expert | 39 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 31.43 (4) |
| expert | 39 | kerf_blink_behind | shield_robot | 10 | 4 | 2.5 | 31.43 (4) | — |
| expert | 39 | overkill_carry | all waves | 71 | 4 | 17.75 | 31.43 (4) | — |
| expert | 40 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | 32.95 (4) | — |
| expert | 40 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 32.95 (4) | — |
| expert | 40 | kerf_blink_behind | shield_robot | 15 | 4 | 3.75 | 32.95 (4) | — |
| expert | 40 | overkill_carry | all waves | 38 | 4 | 9.5 | 32.95 (4) | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 22 (10) | 12 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | 33.89 (10) | 23.41 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | waves survived | 19 (9) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | wave s | 32.75 (9) | 41.82 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 23 (13) | 4 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 31.97 (13) | 24.15 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 20.5 (12) | 11 (2) | 2 | 4.5 | -11…20 | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 29.43 (11) | 38.54 (2) | 1 | -6.03 | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 22 (13) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 29.88 (13) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 20.5 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 29.26 (14) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 28 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 29.08 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 20 (13) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 29.95 (12) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 28 (14) | 2 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 29.13 (13) | 33.83 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 18 (12) | 12 (2) | 1 | 20 | not measured | not measured (1, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 31.28 (12) | 26.79 (2) | 1 | -1.28 | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 31 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 28.22 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 21 (11) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 32.45 (11) | 24.9 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 26 (12) | 5.5 (2) | 1 | 9 | not measured | not measured (2, all offered) | too few pairs |
| stat_regen_10 | wave s | 30.33 (12) | 23.58 (2) | 1 | 13.2 | not measured | not measured (2, all offered) | too few pairs |
| stat_regen_25 | waves survived | 17 (11) | 3 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 32.82 (11) | 24.9 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 27.5 (14) | 0 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 29.08 (14) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | 15 (11) | 6 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 32.23 (11) | 23.51 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 16 (8) | 13.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_chainsaw | wave s | 33.08 (8) | 26.02 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 17 (11) | 4.5 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | wave s | 31.45 (10) | 30.38 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 19 (11) | 4 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 32.15 (10) | 38.78 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 27 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 29.68 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 12 (11) | 9.5 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_gloria | wave s | 34.28 (11) | 19.64 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 13.5 (10) | 6 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 33.17 (9) | 22.14 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 14 (9) | 15.5 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | wave s | 31.61 (9) | 23.35 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 14 (10) | 10 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 31.52 (10) | 30.89 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_pistol | waves survived | 28.5 (14) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 29.92 (14) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 16 (12) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 33.02 (11) | 27.08 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 17.5 (10) | 4 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 31.28 (10) | 29.83 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 25 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 31.12 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 16 (8) | 13.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| chainsaw | wave s | 33.08 (8) | 26.02 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | waves survived | 17 (11) | 4.5 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | wave s | 31.45 (10) | 30.38 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 19 (11) | 4 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 32.15 (10) | 38.78 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 27 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 29.68 (15) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 12 (11) | 9.5 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| gloria | wave s | 34.28 (11) | 19.64 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| hand_cannon | waves survived | 13.5 (10) | 6 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 33.17 (9) | 22.14 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 14 (9) | 15.5 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | wave s | 31.61 (9) | 23.35 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| machine_pistol | waves survived | 14 (10) | 10 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| machine_pistol | wave s | 31.52 (10) | 30.89 (4) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| pistol | waves survived | 28.5 (14) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 29.92 (14) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | 16 (12) | 1 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 33.02 (11) | 27.08 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 17.5 (10) | 4 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 31.28 (10) | 29.83 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 25 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 31.12 (11) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (5) | 0 (5) | 0 (5) | 13 (5) | not measured | not measured | not measured | 11.32 (5) | not measured |
| novice | 2 | 7 (5) | 1 (5) | 0 (5) | 14 (5) | not measured | not measured | not measured | 11.37 (5) | not measured |
| novice | 3 | 6 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | not measured | 15.93 (5) | 3.78 (1) |
| novice | 4 | 8 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | not measured | 12.23 (5) | not measured |
| novice | 5 | 0 (5) | 1 (5) | 0 (5) | 22 (5) | not measured | 5.5 (1) | 5.48 (1) | 11.33 (5) | 7.1 (2) |
| novice | 6 | 13 (5) | 1 (5) | 37 (5) | 39 (5) | not measured | not measured | not measured | 23.33 (5) | 7.1 (1) |
| novice | 7 | 8 (5) | 2 (5) | 38 (5) | 38 (5) | not measured | 5.5 (1) | 7.3 (1) | 18.55 (5) | 7.1 (2) |
| novice | 8 | 12 (5) | 1 (5) | 62 (5) | 57 (5) | not measured | 5.5 (1) | 0.03 (1) | 19.05 (5) | 7.1 (1) |
| novice | 9 | 13 (5) | 5 (5) | 55 (5) | 63 (5) | not measured | 11 (1) | 1.58 (3) | 23.43 (5) | 7.1 (3) |
| novice | 10 | 1.5 (4) | 2 (4) | 65.5 (4) | 66 (4) | not measured | 5.05 (1) | 0.85 (3) | 25.11 (4) | 5.33 (2) |
| novice | 11 | 9 (4) | 3 (4) | 35 (4) | 50.5 (4) | not measured | 5.5 (1) | 3.69 (2) | 19.43 (4) | not measured |
| novice | 12 | 19 (3) | 4 (3) | 56 (3) | 71 (3) | not measured | 5.5 (2) | 0.03 (3) | 21.55 (3) | 3.81 (2) |
| novice | 13 | 7 (3) | 5 (3) | 40 (3) | 100 (3) | not measured | 5.5 (1) | 1.07 (2) | 23.87 (3) | 7.1 (2) |
| novice | 14 | 13 (2) | 9 (2) | 66 (2) | 106 (2) | not measured | not measured | 5.94 (2) | 29.1 (2) | 7.1 (1) |
| novice | 15 | 7 (2) | 4 (2) | 56.5 (2) | 66.5 (2) | not measured | 5.5 (1) | 0.62 (1) | 25.32 (2) | 7.1 (1) |
| novice | 16 | 11 (2) | 8 (2) | 49.5 (2) | 60.5 (2) | not measured | 11 (1) | 4.1 (2) | 21.48 (2) | 7.1 (1) |
| novice | 17 | 19.5 (2) | 6.5 (2) | 53.5 (2) | 101.5 (2) | not measured | 5.5 (1) | 1.24 (2) | 24.65 (2) | 7.1 (1) |
| novice | 18 | 27.5 (2) | 6 (2) | 80.5 (2) | 106 (2) | not measured | 5.5 (1) | 0.3 (2) | 31.05 (2) | 7.1 (1) |
| novice | 19 | 26 (2) | 4 (2) | 105.5 (2) | 116 (2) | not measured | 5.5 (1) | 0.05 (2) | 38 (2) | 3.61 (2) |
| novice | 20 | 8 (2) | 4 (2) | 21 (2) | 69.5 (2) | not measured | not measured | 0.38 (2) | 19.07 (2) | 7.1 (2) |
| novice | 21 | 30 (1) | 11 (1) | 31 (1) | 114 (1) | not measured | 5.5 (1) | 0.03 (1) | 33.5 (1) | 7.1 (1) |
| novice | 22 | 26 (1) | 3 (1) | 23 (1) | 100 (1) | not measured | 5.5 (1) | 1.17 (1) | 21 (1) | not measured |
| average | 1 | 11 (5) | 0 (5) | 0 (5) | 13 (5) | not measured | not measured | not measured | 10.35 (5) | not measured |
| average | 2 | 10 (5) | 1 (5) | 0 (5) | 14 (5) | not measured | not measured | not measured | 11.42 (5) | not measured |
| average | 3 | 6 (5) | 2 (5) | 0 (5) | 12 (5) | not measured | not measured | not measured | 11.3 (5) | 7.1 (2) |
| average | 4 | 3 (5) | 1 (5) | 0 (5) | 12 (5) | not measured | not measured | 7.05 (1) | 9.63 (5) | not measured |
| average | 5 | 1 (5) | 2 (5) | 0 (5) | 19 (5) | not measured | 2.28 (1) | 9.63 (1) | 14.78 (5) | 9.09 (2) |
| average | 6 | 10 (5) | 1 (5) | 25 (5) | 42 (5) | not measured | 2.4 (1) | 0.03 (1) | 15.67 (5) | 7.1 (1) |
| average | 7 | 6 (5) | 2 (5) | 52 (5) | 35 (5) | not measured | 7.85 (1) | 0.03 (1) | 13.95 (5) | 7.1 (1) |
| average | 8 | 8 (5) | 5 (5) | 62 (5) | 57 (5) | not measured | 6.15 (1) | 0.38 (2) | 17.78 (5) | 7.1 (2) |
| average | 9 | 12 (5) | 4 (5) | 44 (5) | 83 (5) | not measured | 4.38 (2) | 0.1 (3) | 18.32 (5) | 7.1 (3) |
| average | 10 | 1 (5) | 5 (5) | 45 (5) | 57 (5) | not measured | 3.81 (2) | 3.63 (3) | 9.35 (5) | 6.3 (3) |
| average | 11 | 13 (5) | 7 (5) | 85 (5) | 69 (5) | not measured | 0.3 (3) | 3.95 (2) | 21.75 (5) | 3.56 (2) |
| average | 12 | 10 (5) | 11 (5) | 68 (5) | 83 (5) | not measured | 4.05 (3) | 0.03 (3) | 24.57 (5) | 7.1 (3) |
| average | 13 | 13 (5) | 9 (5) | 121 (5) | 116 (5) | not measured | 7.1 (3) | 0.37 (3) | 21.98 (5) | 7.1 (2) |
| average | 14 | 15 (5) | 4 (5) | 69 (5) | 87 (5) | not measured | 5.5 (3) | 0.16 (4) | 19.43 (5) | 7.1 (1) |
| average | 15 | 6 (5) | 8 (5) | 61 (5) | 158 (5) | not measured | 1.57 (3) | 0.18 (4) | 20.82 (5) | 7.1 (2) |
| average | 16 | 10 (5) | 6 (5) | 50 (5) | 517 (5) | not measured | 6.71 (4) | 6.25 (4) | 15.13 (5) | not measured |
| average | 17 | 7 (5) | 4 (5) | 169 (5) | 1457 (5) | not measured | 5.5 (4) | 0.33 (2) | 24.82 (5) | 7.1 (1) |
| average | 18 | 4 (5) | 5 (5) | 89 (5) | 910 (5) | not measured | 5.5 (4) | 0.05 (5) | 18.13 (5) | 14.2 (1) |
| average | 19 | 15 (5) | 4 (5) | 74 (5) | 331 (5) | not measured | 5.51 (4) | 0.88 (4) | 19.08 (5) | 7.1 (1) |
| average | 20 | 5 (5) | 6 (5) | 35 (5) | 341 (5) | not measured | 5.5 (4) | 0.3 (5) | 15.83 (5) | 0.02 (1) |
| average | 21 | 15 (4) | 8 (4) | 60 (4) | 793.5 (4) | not measured | 5.5 (3) | 7.31 (4) | 19.9 (4) | not measured |
| average | 22 | 14 (4) | 6 (4) | 145.5 (4) | 2318.5 (4) | not measured | 6.48 (4) | 0.3 (3) | 26.45 (4) | 7.1 (1) |
| average | 23 | 23.5 (4) | 5 (4) | 97.5 (4) | 1766 (4) | not measured | 6.13 (4) | 0.46 (4) | 24.93 (4) | not measured |
| average | 24 | 20 (4) | 9.5 (4) | 118 (4) | 1350.5 (4) | not measured | 8.97 (4) | 0.44 (2) | 25.05 (4) | not measured |
| average | 25 | 14 (4) | 5.5 (4) | 83 (4) | 1403 (4) | not measured | 4.58 (4) | 0.3 (4) | 22.06 (4) | not measured |
| average | 26 | 16 (4) | 7 (4) | 97 (4) | 1400.5 (4) | not measured | 5.5 (4) | 1.27 (4) | 24 (4) | not measured |
| average | 27 | 13 (4) | 7.5 (4) | 91.5 (4) | 1232.5 (4) | not measured | 5.5 (4) | 0.68 (4) | 21.1 (4) | not measured |
| average | 28 | 20.5 (4) | 4.5 (4) | 109 (4) | 2386 (4) | not measured | 5.52 (4) | 0.18 (4) | 29.27 (4) | not measured |
| average | 29 | 15 (4) | 10 (4) | 119 (4) | 1731 (4) | not measured | 4.86 (4) | 0.85 (4) | 25.65 (4) | 7.1 (1) |
| average | 30 | 8 (4) | 7 (4) | 78 (4) | 910.5 (4) | not measured | 5.5 (4) | 0.33 (4) | 19.15 (4) | not measured |
| average | 31 | 15.5 (4) | 10.5 (4) | 92.5 (4) | 1624 (4) | not measured | 8.11 (4) | 0.64 (4) | 25.36 (4) | 7.1 (1) |
| average | 32 | 14.5 (4) | 7 (4) | 108.5 (4) | 2142 (4) | not measured | 7.81 (4) | 0.43 (4) | 27.8 (4) | not measured |
| average | 33 | 13.5 (4) | 8.5 (4) | 91.5 (4) | 1615.5 (4) | not measured | 7.16 (4) | 0.3 (3) | 27.17 (4) | 7.1 (1) |
| average | 34 | 14.5 (4) | 7 (4) | 86 (4) | 1888.5 (4) | not measured | 5.99 (4) | 0.03 (3) | 23.63 (4) | not measured |
| average | 35 | 14 (4) | 7 (4) | 97 (4) | 1753 (4) | not measured | 5.8 (4) | 0.33 (4) | 25.79 (4) | not measured |
| average | 36 | 11.5 (4) | 12.5 (4) | 141 (4) | 3485.5 (4) | not measured | 9.57 (4) | 0.84 (4) | 29.53 (4) | not measured |
| average | 37 | 17 (4) | 10.5 (4) | 99.5 (4) | 2179 (4) | not measured | 6.54 (4) | 1.65 (4) | 27.95 (4) | not measured |
| average | 38 | 24 (4) | 14 (4) | 112 (4) | 2209 (4) | not measured | 10.96 (4) | 0.33 (4) | 33.95 (4) | 7.1 (1) |
| average | 39 | 20 (4) | 11 (4) | 130.5 (4) | 2301.5 (4) | not measured | 5.9 (3) | 0.33 (4) | 39.02 (4) | 7.1 (1) |
| average | 40 | 11 (4) | 10.5 (4) | 99 (4) | 1540.5 (4) | not measured | 5.62 (4) | 0.16 (4) | 28.71 (4) | 7.1 (1) |
| expert | 1 | 7 (5) | 1 (5) | 0 (5) | 13 (5) | not measured | not measured | not measured | 10.35 (5) | not measured |
| expert | 2 | 8 (5) | 1 (5) | 0 (5) | 14 (5) | not measured | not measured | not measured | 13.3 (5) | not measured |
| expert | 3 | 4 (5) | 5 (5) | 0 (5) | 12 (5) | not measured | not measured | 6.08 (1) | 10.88 (5) | 7.1 (1) |
| expert | 4 | 6 (5) | 2 (5) | 0 (5) | 12 (5) | not measured | not measured | not measured | 11.33 (5) | not measured |
| expert | 5 | 3 (5) | 8 (5) | 0 (5) | 29 (5) | not measured | 0.95 (1) | 20.42 (1) | 16.7 (5) | 7.32 (2) |
| expert | 6 | 10 (5) | 1 (5) | 25 (5) | 34 (5) | not measured | 0.93 (1) | 0.03 (1) | 13.8 (5) | 5.39 (2) |
| expert | 7 | 5 (5) | 2 (5) | 35 (5) | 38 (5) | not measured | 3.02 (1) | 0.03 (1) | 13.4 (5) | not measured |
| expert | 8 | 6 (5) | 4 (5) | 75 (5) | 67 (5) | not measured | 5.5 (1) | 1.81 (2) | 14.43 (5) | 7.1 (2) |
| expert | 9 | 4 (5) | 5 (5) | 56 (5) | 91 (5) | not measured | 5.48 (2) | 0.07 (3) | 17.88 (5) | 7.1 (3) |
| expert | 10 | 2 (5) | 8 (5) | 39 (5) | 76 (5) | not measured | 4.04 (2) | 0.07 (3) | 13.17 (5) | 7.1 (2) |
| expert | 11 | 9 (5) | 5 (5) | 91 (5) | 60 (5) | not measured | 5.91 (2) | 3.69 (2) | 20.88 (5) | 7.1 (1) |
| expert | 12 | 6 (5) | 9 (5) | 80 (5) | 124 (5) | not measured | 3.53 (3) | 0.53 (3) | 19.13 (5) | 7.1 (3) |
| expert | 13 | 19 (5) | 7 (5) | 107 (5) | 129 (5) | not measured | 5.5 (3) | 0.07 (3) | 21.85 (5) | 21.66 (2) |
| expert | 14 | 11 (5) | 4 (5) | 66 (5) | 117 (5) | not measured | 5.5 (3) | 0.71 (4) | 16.45 (5) | 10.47 (1) |
| expert | 15 | 3 (5) | 8 (5) | 59 (5) | 77 (5) | not measured | 5.5 (3) | 1.33 (3) | 22.52 (5) | 7.26 (2) |
| expert | 16 | 8 (5) | 9 (5) | 77 (5) | 145 (5) | not measured | 5.5 (3) | 0.07 (3) | 21.67 (5) | 4.7 (1) |
| expert | 17 | 6 (5) | 10 (5) | 130 (5) | 155 (5) | not measured | 5.5 (3) | 7.3 (4) | 22.5 (5) | 9.18 (1) |
| expert | 18 | 22 (5) | 6 (5) | 85 (5) | 142 (5) | not measured | 5.5 (3) | 0.22 (5) | 19.9 (5) | 4.8 (1) |
| expert | 19 | 9 (4) | 10 (4) | 78 (4) | 384 (4) | 0 (1) | 5.5 (3) | 0.2 (5) | 24.26 (4) | 7.1 (3) |
| expert | 20 | 7.5 (4) | 6 (4) | 110 (4) | 1190 (4) | 0 (1) | 5.5 (3) | 1.18 (3) | 23.05 (4) | 5.97 (4) |
| expert | 21 | 6.5 (4) | 11 (4) | 80 (4) | 456.5 (4) | 0 (1) | 5.5 (3) | 0.27 (4) | 22.02 (4) | 7.1 (3) |
| expert | 22 | 14 (4) | 7.5 (4) | 134.5 (4) | 2117.5 (4) | not measured | 7.2 (2) | 0.12 (4) | 24.48 (4) | 7.1 (2) |
| expert | 23 | 9.5 (4) | 8.5 (4) | 111.5 (4) | 2879.5 (4) | not measured | 5.8 (3) | 0.55 (3) | 23.25 (4) | 7.1 (1) |
| expert | 24 | 14 (4) | 6.5 (4) | 85.5 (4) | 1218.5 (4) | not measured | 5.5 (3) | 0.52 (3) | 21.17 (4) | 7.1 (1) |
| expert | 25 | 5 (4) | 5 (4) | 71 (4) | 508.5 (4) | not measured | 5.5 (4) | 0.17 (3) | 12.97 (4) | not measured |
| expert | 26 | 14 (4) | 6.5 (4) | 58 (4) | 1334.5 (4) | not measured | 5.5 (4) | 0.17 (4) | 19.03 (4) | not measured |
| expert | 27 | 17.5 (4) | 12 (4) | 75.5 (4) | 1320 (4) | not measured | 7.33 (4) | 0.32 (3) | 21.37 (4) | not measured |
| expert | 28 | 15 (4) | 8 (4) | 141.5 (4) | 2385.5 (4) | not measured | 5.5 (4) | 0.36 (4) | 23.94 (4) | not measured |
| expert | 29 | 13 (4) | 10.5 (4) | 121.5 (4) | 2353 (4) | not measured | 5.5 (3) | 2.26 (4) | 27.56 (4) | 7.1 (1) |
| expert | 30 | 5.5 (4) | 10.5 (4) | 70.5 (4) | 1080.5 (4) | not measured | 5.71 (4) | 0.45 (3) | 18.84 (4) | not measured |
| expert | 31 | 10.5 (4) | 13.5 (4) | 94.5 (4) | 2003.5 (4) | not measured | 9 (4) | 0.17 (4) | 21.77 (4) | not measured |
| expert | 32 | 16.5 (4) | 7.5 (4) | 84.5 (4) | 1574 (4) | not measured | 5.15 (4) | 0.36 (4) | 20.48 (4) | not measured |
| expert | 33 | 15.5 (4) | 11.5 (4) | 108.5 (4) | 2075.5 (4) | not measured | 7.57 (4) | 0.13 (4) | 24.84 (4) | not measured |
| expert | 34 | 22 (4) | 7.5 (4) | 93.5 (4) | 2620.5 (4) | not measured | 5.6 (4) | 0.17 (4) | 26.27 (4) | not measured |
| expert | 35 | 8.5 (4) | 11.5 (4) | 45 (4) | 632.5 (4) | not measured | 5.5 (4) | 0.14 (4) | 19.76 (4) | not measured |
| expert | 36 | 12 (4) | 10.5 (4) | 158 (4) | 3661 (4) | not measured | 5.5 (4) | 0.57 (4) | 31.85 (4) | not measured |
| expert | 37 | 13.5 (4) | 12 (4) | 93 (4) | 1780 (4) | not measured | 8.34 (4) | 0.3 (4) | 23.7 (4) | not measured |
| expert | 38 | 14 (4) | 13 (4) | 107 (4) | 1923 (4) | not measured | 5.98 (4) | 0.72 (3) | 24.8 (4) | not measured |
| expert | 39 | 15.5 (4) | 12.5 (4) | 77 (4) | 1715 (4) | not measured | 8.25 (4) | 0.55 (3) | 22.75 (4) | not measured |
| expert | 40 | 8 (4) | 11.5 (4) | 126.5 (4) | 1952.5 (4) | not measured | 6.88 (4) | 2.65 (3) | 23.42 (4) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 2 | 22 | 1.55 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton → ghost_dent → stat_speed_25 → weapon_plasma_rifle → weapon_gloria → weapon_plasma_sword → weapon_hand_cannon | electro_baton, gatling, gloria, hand_cannon, machine_pistol, pistol, plasma_rifle, plasma_sword | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 1 | 40 | 0.88 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 → stat_guard_meter_10 → stat_regen_10 → weapon_rocket_launcher → weapon_plasma_sword → effect_overkill_carry → effect_overkill_carry_2 → ghost_ohm → stat_hp_max_25 → stat_damage_25 → weapon_plasma_rifle → stat_guard_meter_25 → stat_regen_25 → weapon_electro_baton → stat_speed_25 → weapon_machine_pistol → weapon_hand_cannon → weapon_chainsaw → weapon_gloria | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 2 | 40 | 0.88 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton → ghost_dent → stat_speed_25 → weapon_plasma_rifle → weapon_gloria → weapon_plasma_sword → weapon_hand_cannon → effect_overkill_carry → weapon_rocket_launcher → stat_regen_25 → effect_overkill_carry_2 → weapon_katana → weapon_flamethrower → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 4 | 40 | 0.88 | stat_damage_10 → stat_speed_10 → stat_damage_25 → stat_guard_meter_25 → weapon_rocket_launcher → stat_hp_max_10 → weapon_gatling → weapon_pistol → stat_speed_25 → stat_guard_meter_10 → weapon_chainsaw → ghost_ohm → stat_regen_10 → weapon_hand_cannon → ghost_kerf → stat_hp_max_25 → weapon_plasma_rifle → weapon_machine_pistol → weapon_electro_baton → weapon_flamethrower → effect_overkill_carry → ghost_dent → effect_overkill_carry_2 → ghost_tonnage → stat_regen_25 → weapon_plasma_sword → weapon_gloria → weapon_katana | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 1 | 40 | 0.99 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 → stat_guard_meter_10 → stat_regen_10 → weapon_rocket_launcher → weapon_plasma_sword → effect_overkill_carry → effect_overkill_carry_2 → ghost_ohm → stat_hp_max_25 → stat_damage_25 → weapon_plasma_rifle → stat_guard_meter_25 → stat_regen_25 → weapon_electro_baton → stat_speed_25 → weapon_machine_pistol → weapon_hand_cannon → weapon_chainsaw → weapon_gloria | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 3 | 40 | 0.99 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher → ghost_dent → effect_overkill_carry → weapon_gatling → stat_speed_10 → stat_damage_25 → weapon_flamethrower → weapon_plasma_rifle → stat_regen_25 → effect_overkill_carry_2 → weapon_electro_baton → stat_guard_meter_25 → stat_hp_max_25 → stat_speed_25 → ghost_kerf → weapon_katana → weapon_chainsaw → weapon_hand_cannon → weapon_machine_pistol → weapon_plasma_sword | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 4 | 40 | 0.99 | stat_damage_10 → stat_speed_10 → stat_damage_25 → stat_guard_meter_25 → weapon_rocket_launcher → stat_hp_max_10 → weapon_gatling → weapon_pistol → stat_speed_25 → stat_guard_meter_10 → weapon_chainsaw → ghost_ohm → effect_overkill_carry → weapon_electro_baton → stat_hp_max_25 → ghost_dent → stat_regen_10 → ghost_tonnage → effect_overkill_carry_2 → stat_regen_25 → weapon_hand_cannon → ghost_kerf → weapon_plasma_sword → weapon_gloria → weapon_katana → weapon_plasma_rifle → weapon_flamethrower → weapon_machine_pistol | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=expert --pick=greedy --controls=wheel --waves=40 |
