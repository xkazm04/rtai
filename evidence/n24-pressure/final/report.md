# Gauntlet run report

15 of 15 runs accepted. Average-profile waves 3 (19.23 s), 5 (17.27 s), 6 (18.13 s), 7 (26.72 s), 8 (27.77 s), 9 (34.24 s), 10 (23.95 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ a02dbf26cfe9 · 2026-11-22T22:56:50.470Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

Baseline detached @ b3f4727c0910 · 2026-11-22T16:24:58.200Z · 15 accepted runs.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 5 | 5–5 | 5–6 | 5 / 0 |
| average | 12 | 8 | 6–11 | 5–11 | 5 / 0 |
| expert | 20 | 23 | 10–33 | 5–40 | 4 / 1 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 3 | 3 / 5 | 60% | 0 | below target |
| novice → expert | 18 | 4 / 5 | 80% | 0 | separated |
| average → expert | 15 | 3 / 5 | 60% | 0 | below target |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 5 | 0 | 1 |
| novice | 2 | died on 5 | 0 | 1 |
| novice | 3 | died on 5 | 0 | 1 |
| novice | 4 | died on 6 | 0 | 1 |
| novice | 5 | died on 5 | 0 | 1 |
| average | 1 | died on 11 | 0 | 1 |
| average | 2 | died on 5 | 0 | 1 |
| average | 3 | died on 11 | 1 | 2 |
| average | 4 | died on 6 | 0 | 1 |
| average | 5 | died on 8 | 0 | 1 |
| expert | 1 | died on 33 | 1 | 2 |
| expert | 2 | censored at the wave limit 40 (≥ 40) | 2 | — |
| expert | 3 | died on 10 | 0 | 1 |
| expert | 4 | died on 5 | 0 | 1 |
| expert | 5 | died on 23 | 1 | 2 |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Before s (n) | After s | Change s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 5 / 5 | 11.32 (5) | 12.98 | 1.67 | 12.88…13.08 | 10.85…17.12 | — |
| novice | 2 | 5 / 5 | 11.37 (5) | 17.22 | 5.85 | 11.53…17.27 | 9.28…19.02 | — |
| novice | 3 | 5 / 5 | 15.93 (5) | 15.93 | 0 | 13…18.5 | 11.22…20.48 | — |
| novice | 4 | 5 / 5 | 12.23 (5) | 12.83 | 0.6 | 11.63…13.02 | 9.63…24.43 | — |
| novice | 5 | 1 / 5 | 18.43 (5) | 11.38 | -7.05 | 11.38…11.38 | 11.38…11.38 | — |
| novice | 6 | 0 / 1 | 23.52 (5) | not measured | not measured | not measured | not measured | — |
| novice | 7 | 0 / 0 | 19.38 (5) | not measured | not measured | not measured | not measured | — |
| novice | 8 | 0 / 0 | 24.47 (5) | not measured | not measured | not measured | not measured | — |
| novice | 9 | 0 / 0 | 30.46 (4) | not measured | not measured | not measured | not measured | — |
| novice | 10 | 0 / 0 | 25.13 (4) | not measured | not measured | not measured | not measured | — |
| novice | 11 | 0 / 0 | 21.22 (3) | not measured | not measured | not measured | not measured | — |
| novice | 12 | 0 / 0 | 27.08 (3) | not measured | not measured | not measured | not measured | — |
| novice | 13 | 0 / 0 | 28.73 (2) | not measured | not measured | not measured | not measured | — |
| novice | 14 | 0 / 0 | 38.59 (2) | not measured | not measured | not measured | not measured | — |
| novice | 15 | 0 / 0 | 31.93 (2) | not measured | not measured | not measured | not measured | — |
| novice | 16 | 0 / 0 | 34.63 (2) | not measured | not measured | not measured | not measured | — |
| novice | 17 | 0 / 0 | 32.19 (2) | not measured | not measured | not measured | not measured | — |
| novice | 18 | 0 / 0 | 37.64 (2) | not measured | not measured | not measured | not measured | — |
| novice | 19 | 0 / 0 | 44.41 (2) | not measured | not measured | not measured | not measured | — |
| novice | 20 | 0 / 0 | 33.65 (1) | not measured | not measured | not measured | not measured | — |
| novice | 21 | 0 / 0 | 46.13 (1) | not measured | not measured | not measured | not measured | — |
| novice | 22 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | — |
| average | 1 | 5 / 5 | 10.35 (5) | 14.05 | 3.7 | 12.87…17.45 | 10.07…21.42 | within target |
| average | 2 | 5 / 5 | 11.42 (5) | 13.98 | 2.57 | 11.78…15.93 | 8.72…23.3 | within target |
| average | 3 | 5 / 5 | 15.37 (5) | 19.23 | 3.87 | 16.58…26.33 | 12.57…27.9 | miss |
| average | 4 | 5 / 5 | 11.97 (5) | 15.87 | 3.9 | 11.23…16.12 | 9.08…16.65 | within target |
| average | 5 | 4 / 5 | 14.78 (5) | 17.27 | 2.49 | 11.35…25.85 | 11.17…25.85 | miss |
| average | 6 | 3 / 4 | 17.22 (5) | 18.13 | 0.92 | 13.92…21.05 | 13.92…21.05 | miss |
| average | 7 | 3 / 3 | 20.63 (5) | 26.72 | 6.08 | 18.3…40.43 | 18.3…40.43 | miss |
| average | 8 | 2 / 3 | 22.27 (5) | 27.77 | 5.5 | 22.45…33.08 | 22.45…33.08 | miss |
| average | 9 | 2 / 2 | 25.95 (5) | 34.24 | 8.29 | 28.53…39.95 | 28.53…39.95 | miss |
| average | 10 | 1 / 2 | 18.88 (5) | 23.95 | 5.07 | 23.95…23.95 | 23.95…23.95 | miss |
| average | 11 | 0 / 2 | 28.97 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 12 | 0 / 0 | 35.72 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 13 | 0 / 0 | 31.48 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 14 | 0 / 0 | 24.57 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 15 | 0 / 0 | 26.35 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 16 | 0 / 0 | 21.5 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 17 | 0 / 0 | 30.32 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 18 | 0 / 0 | 23.67 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 19 | 0 / 0 | 25.75 (5) | not measured | not measured | not measured | not measured | not measured |
| average | 20 | 0 / 0 | 24.56 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 21 | 0 / 0 | 29.92 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 22 | 0 / 0 | 33.23 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 23 | 0 / 0 | 33.33 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 24 | 0 / 0 | 33.92 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 25 | 0 / 0 | 26.51 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 26 | 0 / 0 | 30.44 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 27 | 0 / 0 | 27.14 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 28 | 0 / 0 | 35.95 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 29 | 0 / 0 | 35.95 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 30 | 0 / 0 | 24.99 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 31 | 0 / 0 | 37.42 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 32 | 0 / 0 | 35.45 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 33 | 0 / 0 | 35.6 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 34 | 0 / 0 | 29.18 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 35 | 0 / 0 | 32.02 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 36 | 0 / 0 | 39.78 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 37 | 0 / 0 | 37.54 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 38 | 0 / 0 | 46.2 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 39 | 0 / 0 | 45.78 (4) | not measured | not measured | not measured | not measured | not measured |
| average | 40 | 0 / 0 | 38.04 (4) | not measured | not measured | not measured | not measured | not measured |
| expert | 1 | 5 / 5 | 10.35 (5) | 14.63 | 4.28 | 12.28…19.68 | 11.5…42.62 | — |
| expert | 2 | 5 / 5 | 13.3 (5) | 18.82 | 5.52 | 18.23…22.17 | 17.72…26.45 | — |
| expert | 3 | 5 / 5 | 11.13 (5) | 19.42 | 8.28 | 14.22…26.58 | 6.25…35.15 | — |
| expert | 4 | 5 / 5 | 11.33 (5) | 12.45 | 1.12 | 12.15…17.07 | 9.8…17.33 | — |
| expert | 5 | 4 / 5 | 22.75 (5) | 25.47 | 2.72 | 23.52…28.65 | 10.82…28.65 | — |
| expert | 6 | 4 / 4 | 17.52 (5) | 22.34 | 4.82 | 16.88…36.77 | 12.3…36.77 | — |
| expert | 7 | 4 / 4 | 13.4 (5) | 16.38 | 2.98 | 14.37…31.27 | 10.65…31.27 | — |
| expert | 8 | 4 / 4 | 19.97 (5) | 21.67 | 1.7 | 19.33…30.77 | 16.95…30.77 | — |
| expert | 9 | 4 / 4 | 24.73 (5) | 24.84 | 0.11 | 21.2…32.73 | 14.27…32.73 | — |
| expert | 10 | 3 / 4 | 23.47 (5) | 17.73 | -5.73 | 12.45…24.87 | 12.45…24.87 | — |
| expert | 11 | 3 / 3 | 23 (5) | 18.02 | -4.98 | 12.97…26.3 | 12.97…26.3 | — |
| expert | 12 | 3 / 3 | 26.28 (5) | 25.7 | -0.58 | 17.98…30.93 | 17.98…30.93 | — |
| expert | 13 | 3 / 3 | 24.4 (5) | 22.9 | -1.5 | 14.8…29.58 | 14.8…29.58 | — |
| expert | 14 | 3 / 3 | 18.35 (5) | 28.03 | 9.68 | 19.88…34.15 | 19.88…34.15 | — |
| expert | 15 | 3 / 3 | 28.05 (5) | 16.07 | -11.98 | 11.58…17.28 | 11.58…17.28 | — |
| expert | 16 | 3 / 3 | 27.17 (5) | 29.23 | 2.07 | 18.85…31.43 | 18.85…31.43 | — |
| expert | 17 | 3 / 3 | 28.62 (5) | 20.6 | -8.02 | 19.72…32.28 | 19.72…32.28 | — |
| expert | 18 | 3 / 3 | 23.02 (5) | 26.98 | 3.97 | 17.97…31.6 | 17.97…31.6 | — |
| expert | 19 | 3 / 3 | 30.69 (4) | 33.25 | 2.56 | 23.32…34.22 | 23.32…34.22 | — |
| expert | 20 | 3 / 3 | 31.79 (4) | 30.43 | -1.36 | 14.5…42.87 | 14.5…42.87 | — |
| expert | 21 | 3 / 3 | 30.25 (4) | 25.72 | -4.53 | 23.18…28.75 | 23.18…28.75 | — |
| expert | 22 | 2 / 3 | 33.27 (4) | 36.94 | 3.67 | 31.23…42.65 | 31.23…42.65 | — |
| expert | 23 | 2 / 3 | 29.49 (4) | 25.61 | -3.88 | 19.77…31.45 | 19.77…31.45 | — |
| expert | 24 | 2 / 2 | 27.38 (4) | 29.73 | 2.35 | 26.5…32.97 | 26.5…32.97 | — |
| expert | 25 | 2 / 2 | 18.61 (4) | 28.52 | 9.91 | 17.85…39.18 | 17.85…39.18 | — |
| expert | 26 | 2 / 2 | 24.7 (4) | 25.35 | 0.65 | 25.32…25.38 | 25.32…25.38 | — |
| expert | 27 | 2 / 2 | 29.02 (4) | 33.05 | 4.02 | 28.85…37.25 | 28.85…37.25 | — |
| expert | 28 | 2 / 2 | 31.77 (4) | 38.38 | 6.6 | 34.25…42.5 | 34.25…42.5 | — |
| expert | 29 | 2 / 2 | 35.72 (4) | 35.63 | -0.09 | 33.45…37.8 | 33.45…37.8 | — |
| expert | 30 | 2 / 2 | 25.32 (4) | 32.09 | 6.77 | 24.05…40.13 | 24.05…40.13 | — |
| expert | 31 | 2 / 2 | 32.53 (4) | 37.73 | 5.21 | 31…44.47 | 31…44.47 | — |
| expert | 32 | 1 / 2 | 28.82 (4) | 46.02 | 17.2 | 46.02…46.02 | 46.02…46.02 | — |
| expert | 33 | 1 / 2 | 32.51 (4) | 35.27 | 2.76 | 35.27…35.27 | 35.27…35.27 | — |
| expert | 34 | 1 / 1 | 32.14 (4) | 34.38 | 2.24 | 34.38…34.38 | 34.38…34.38 | — |
| expert | 35 | 1 / 1 | 25.32 (4) | 29.73 | 4.42 | 29.73…29.73 | 29.73…29.73 | — |
| expert | 36 | 1 / 1 | 38.08 (4) | 33.13 | -4.95 | 33.13…33.13 | 33.13…33.13 | — |
| expert | 37 | 1 / 1 | 32.61 (4) | 44.42 | 11.81 | 44.42…44.42 | 44.42…44.42 | — |
| expert | 38 | 1 / 1 | 33.55 (4) | 41 | 7.45 | 41…41 | 41…41 | — |
| expert | 39 | 1 / 1 | 31.43 (4) | 83.03 | 51.6 | 83.03…83.03 | 83.03…83.03 | — |
| expert | 40 | 1 / 1 | 32.95 (4) | 40.32 | 7.37 | 40.32…40.32 | 40.32…40.32 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 5 | 5 | 0 | 0 | 0 | 5 × 4, 6 × 1 | stomp × 4, sentry_turret × 1 | 0 |
| average | 5 | 5 | 0 | 0 | 0 | 5 × 1, 6 × 1, 8 × 1, 11 × 2 | sentry_turret × 3, patrol_cop × 1, riot_cop × 1 | 0 |
| expert | 5 | 4 | 0 | 0 | 1 | 5 × 1, 10 × 1, 23 × 1, 33 × 1 | shield_robot × 2, rocket × 1, war_cannon × 1 | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 26 / 26 | 16.2 | 0.96 | 10 | 67.51 | 0 | 0 | 7 | 0 | 2 | 1 | 1 | 1 | 1 | 1 |
| novice | 11–20 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 39 / 39 | 15.6 | 0.83 | 10 | 77.71 | 0 | 0 | 5 | 4 | 3 | 1.1 | 1 | 1 | 1 | 1 |
| average | 11–20 | 2 / 2 | 47.53 | not measured | 10.5 | 0 | 0 | 0 | 3.5 | 0 | 7.5 | 1.1 | 1.05 | 1.1 | 1.05 | 1.05 |
| average | 21–30 | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| expert | 1–10 | 45 / 45 | 15.6 | 0.86 | 10 | 85.6 | 0 | 0 | 4 | 40 | 7 | 1.1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 30 / 30 | 25.31 | 1.05 | 11 | 76.99 | 0 | 0 | 4 | 61.5 | 9 | 1.1 | 1.1 | 1.1 | 1.1 | 1.1 |
| expert | 21–30 | 23 / 23 | 47.2 | 1.18 | 13.75 | 65.67 | 0 | 0 | 6 | 53 | 10 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 31+ | 13 / 13 | 46.8 | 1.17 | 13.75 | 62.14 | 0 | 0 | 11 | 55 | 21 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 74.8% | 24.88 (112) | 17.72 (49) |
| patrol_cop | 1 | — | 85.47% | 19.38 (142) | 30.43 (19) |
| riot_cop | 1 | — | 72.84% | 23.32 (111) | 17.73 (50) |
| robot_gunner | 0 | — | 61.05% | 27.92 (80) | 16.58 (81) |
| robot_thug | 0 | — | 60% | 27.8 (79) | 16.62 (82) |
| rocket_trooper | 1 | rocket × 1 | 77.19% | 23.98 (114) | 17.12 (47) |
| sentry_turret | 4 | — | 55.49% | 28.75 (71) | 16.98 (90) |
| shield_robot | 2 | — | 48.99% | 30.08 (60) | 17.22 (101) |
| swat | 0 | — | 69.54% | 24 (103) | 17.58 (58) |
| war_machine | 5 | stomp × 4, war_cannon × 1 | 15.56% | 23.52 (25) | 19.83 (136) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 26 | 0 | — | 13 (21) |
| novice | All | tonnage_armour_crack | war_machine | 0 | 26 | 0 | 11.38 (1) | 13.01 (20) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 26 | 0 | — | 13 (21) |
| novice | All | overkill_carry | all waves | 0 | 26 | 0 | 13 (21) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.98 (5) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.98 (5) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.98 (5) |
| novice | 1 | overkill_carry | all waves | 0 | 5 | 0 | 12.98 (5) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 17.22 (5) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 17.22 (5) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 17.22 (5) |
| novice | 2 | overkill_carry | all waves | 0 | 5 | 0 | 17.22 (5) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.93 (5) |
| novice | 3 | overkill_carry | all waves | 0 | 5 | 0 | 15.93 (5) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.83 (5) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.83 (5) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.83 (5) |
| novice | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.83 (5) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 11.38 (1) |
| novice | 5 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | 11.38 (1) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 11.38 (1) |
| novice | 5 | overkill_carry | all waves | 0 | 5 | 0 | 11.38 (1) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | — | — |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | — |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 1 | 0 | — | — |
| novice | 6 | overkill_carry | all waves | 0 | 1 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 6 | 41 | 0.15 | 26.72 (7) | 16.35 (28) |
| average | All | tonnage_armour_crack | war_machine | 1 | 41 | 0.02 | 23.2 (5) | 17.05 (30) |
| average | All | kerf_blink_behind | shield_robot | 4 | 41 | 0.1 | 34.24 (2) | 16.65 (33) |
| average | All | overkill_carry | all waves | 0 | 41 | 0 | 17.45 (35) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 14.05 (5) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 14.05 (5) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 14.05 (5) |
| average | 1 | overkill_carry | all waves | 0 | 5 | 0 | 14.05 (5) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 13.98 (5) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 13.98 (5) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 13.98 (5) |
| average | 2 | overkill_carry | all waves | 0 | 5 | 0 | 13.98 (5) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 19.23 (5) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 19.23 (5) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 19.23 (5) |
| average | 3 | overkill_carry | all waves | 0 | 5 | 0 | 19.23 (5) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 15.87 (5) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 15.87 (5) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 15.87 (5) |
| average | 4 | overkill_carry | all waves | 0 | 5 | 0 | 15.87 (5) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 1 | 5 | 0.2 | — | 17.27 (4) |
| average | 5 | tonnage_armour_crack | war_machine | 1 | 5 | 0.2 | 17.27 (4) | — |
| average | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 17.27 (4) |
| average | 5 | overkill_carry | all waves | 0 | 5 | 0 | 17.27 (4) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 13.92 (1) | 19.59 (2) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 18.13 (3) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 18.13 (3) |
| average | 6 | overkill_carry | all waves | 0 | 4 | 0 | 18.13 (3) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 33.58 (2) | 18.3 (1) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 26.72 (3) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 26.72 (3) |
| average | 7 | overkill_carry | all waves | 0 | 3 | 0 | 26.72 (3) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 27.77 (2) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 27.77 (2) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | — | 27.77 (2) |
| average | 8 | overkill_carry | all waves | 0 | 3 | 0 | 27.77 (2) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 39.95 (1) | 28.53 (1) |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 34.24 (2) |
| average | 9 | kerf_blink_behind | shield_robot | 1 | 2 | 0.5 | 34.24 (2) | — |
| average | 9 | overkill_carry | all waves | 0 | 2 | 0 | 34.24 (2) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 23.95 (1) | — |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 23.95 (1) | — |
| average | 10 | kerf_blink_behind | shield_robot | 2 | 2 | 1 | — | 23.95 (1) |
| average | 10 | overkill_carry | all waves | 0 | 2 | 0 | 23.95 (1) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | — |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | — |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | — |
| average | 11 | overkill_carry | all waves | 0 | 2 | 0 | — | — |
| expert | All | ohm_short_circuit | sentry_turret | 75 | 111 | 0.68 | 28.8 (64) | 19.42 (41) |
| expert | All | tonnage_armour_crack | war_machine | 2 | 111 | 0.02 | 24.05 (19) | 26.01 (86) |
| expert | All | kerf_blink_behind | shield_robot | 158 | 111 | 1.42 | 30.08 (58) | 18.4 (47) |
| expert | All | overkill_carry | all waves | 372 | 111 | 3.35 | 25.7 (105) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 14.63 (5) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 14.63 (5) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 14.63 (5) |
| expert | 1 | overkill_carry | all waves | 0 | 5 | 0 | 14.63 (5) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 18.82 (5) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 18.82 (5) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 18.82 (5) |
| expert | 2 | overkill_carry | all waves | 0 | 5 | 0 | 18.82 (5) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 19.42 (5) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 19.42 (5) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 19.42 (5) |
| expert | 3 | overkill_carry | all waves | 0 | 5 | 0 | 19.42 (5) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | — | 12.45 (5) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 12.45 (5) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | — | 12.45 (5) |
| expert | 4 | overkill_carry | all waves | 0 | 5 | 0 | 12.45 (5) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 2 | 5 | 0.4 | — | 25.47 (4) |
| expert | 5 | tonnage_armour_crack | war_machine | 2 | 5 | 0.4 | 25.47 (4) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 1 | 5 | 0.2 | — | 25.47 (4) |
| expert | 5 | overkill_carry | all waves | 0 | 5 | 0 | 25.47 (4) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 1 | 4 | 0.25 | 24.53 (2) | 22.34 (2) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 22.34 (4) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | — | 22.34 (4) |
| expert | 6 | overkill_carry | all waves | 0 | 4 | 0 | 22.34 (4) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 24.83 (2) | 12.51 (2) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 16.38 (4) |
| expert | 7 | kerf_blink_behind | shield_robot | 1 | 4 | 0.25 | — | 16.38 (4) |
| expert | 7 | overkill_carry | all waves | 0 | 4 | 0 | 16.38 (4) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 2 | 4 | 0.5 | 21.67 (4) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 21.67 (4) |
| expert | 8 | kerf_blink_behind | shield_robot | 1 | 4 | 0.25 | — | 21.67 (4) |
| expert | 8 | overkill_carry | all waves | 0 | 4 | 0 | 21.67 (4) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 23.5 (2) | 24.84 (2) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 24.84 (4) |
| expert | 9 | kerf_blink_behind | shield_robot | 3 | 4 | 0.75 | 28.48 (3) | 14.27 (1) |
| expert | 9 | overkill_carry | all waves | 0 | 4 | 0 | 24.84 (4) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 6 | 4 | 1.5 | 17.73 (3) | — |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 17.73 (3) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 2 | 4 | 0.5 | — | 17.73 (3) |
| expert | 10 | overkill_carry | all waves | 0 | 4 | 0 | 17.73 (3) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 15.49 (2) | 26.3 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 18.02 (3) |
| expert | 11 | kerf_blink_behind | shield_robot | 1 | 3 | 0.33 | 18.02 (1) | 19.63 (2) |
| expert | 11 | overkill_carry | all waves | 0 | 3 | 0 | 18.02 (3) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 25.7 (3) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 25.7 (3) |
| expert | 12 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 25.7 (3) | — |
| expert | 12 | overkill_carry | all waves | 0 | 3 | 0 | 25.7 (3) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | — | 22.9 (3) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 22.9 (3) |
| expert | 13 | kerf_blink_behind | shield_robot | 7 | 3 | 2.33 | 22.9 (3) | — |
| expert | 13 | overkill_carry | all waves | 0 | 3 | 0 | 22.9 (3) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 28.03 (3) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 28.03 (3) |
| expert | 14 | kerf_blink_behind | shield_robot | 5 | 3 | 1.67 | 28.03 (3) | — |
| expert | 14 | overkill_carry | all waves | 0 | 3 | 0 | 28.03 (3) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 17.28 (1) | 13.82 (2) |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | 16.07 (3) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 5 | 3 | 1.67 | 13.82 (2) | 17.28 (1) |
| expert | 15 | overkill_carry | all waves | 0 | 3 | 0 | 16.07 (3) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 24.04 (2) | 31.43 (1) |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 29.23 (3) |
| expert | 16 | kerf_blink_behind | shield_robot | 5 | 3 | 1.67 | 29.23 (3) | — |
| expert | 16 | overkill_carry | all waves | 8 | 3 | 2.67 | 29.23 (3) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 1 | 3 | 0.33 | 20.6 (3) | — |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 20.6 (3) |
| expert | 17 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 19.72 (1) | 26.44 (2) |
| expert | 17 | overkill_carry | all waves | 10 | 3 | 3.33 | 20.6 (3) | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 22.48 (2) | 31.6 (1) |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 26.98 (3) |
| expert | 18 | kerf_blink_behind | shield_robot | 7 | 3 | 2.33 | 26.98 (3) | — |
| expert | 18 | overkill_carry | all waves | 7 | 3 | 2.33 | 26.98 (3) | — |
| expert | 19 | ohm_short_circuit | sentry_turret | 5 | 3 | 1.67 | 33.25 (3) | — |
| expert | 19 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 33.25 (3) |
| expert | 19 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 33.25 (3) | — |
| expert | 19 | overkill_carry | all waves | 11 | 3 | 3.67 | 33.25 (3) | — |
| expert | 20 | ohm_short_circuit | sentry_turret | 4 | 3 | 1.33 | 30.43 (3) | — |
| expert | 20 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | 30.43 (3) | — |
| expert | 20 | kerf_blink_behind | shield_robot | 6 | 3 | 2 | 22.47 (2) | 42.87 (1) |
| expert | 20 | overkill_carry | all waves | 5 | 3 | 1.67 | 30.43 (3) | — |
| expert | 21 | ohm_short_circuit | sentry_turret | 2 | 3 | 0.67 | 25.72 (3) | — |
| expert | 21 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 25.72 (3) |
| expert | 21 | kerf_blink_behind | shield_robot | 4 | 3 | 1.33 | 25.72 (3) | — |
| expert | 21 | overkill_carry | all waves | 22 | 3 | 7.33 | 25.72 (3) | — |
| expert | 22 | ohm_short_circuit | sentry_turret | 4 | 3 | 1.33 | 36.94 (2) | — |
| expert | 22 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 36.94 (2) |
| expert | 22 | kerf_blink_behind | shield_robot | 8 | 3 | 2.67 | 36.94 (2) | — |
| expert | 22 | overkill_carry | all waves | 12 | 3 | 4 | 36.94 (2) | — |
| expert | 23 | ohm_short_circuit | sentry_turret | 3 | 3 | 1 | 25.61 (2) | — |
| expert | 23 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 25.61 (2) |
| expert | 23 | kerf_blink_behind | shield_robot | 10 | 3 | 3.33 | 25.61 (2) | — |
| expert | 23 | overkill_carry | all waves | 18 | 3 | 6 | 25.61 (2) | — |
| expert | 24 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 29.73 (2) | — |
| expert | 24 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 29.73 (2) |
| expert | 24 | kerf_blink_behind | shield_robot | 5 | 2 | 2.5 | 29.73 (2) | — |
| expert | 24 | overkill_carry | all waves | 16 | 2 | 8 | 29.73 (2) | — |
| expert | 25 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 28.52 (2) | — |
| expert | 25 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 28.52 (2) | — |
| expert | 25 | kerf_blink_behind | shield_robot | 5 | 2 | 2.5 | 28.52 (2) | — |
| expert | 25 | overkill_carry | all waves | 9 | 2 | 4.5 | 28.52 (2) | — |
| expert | 26 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 25.35 (2) | — |
| expert | 26 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 25.35 (2) |
| expert | 26 | kerf_blink_behind | shield_robot | 7 | 2 | 3.5 | 25.35 (2) | — |
| expert | 26 | overkill_carry | all waves | 15 | 2 | 7.5 | 25.35 (2) | — |
| expert | 27 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 33.05 (2) | — |
| expert | 27 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 33.05 (2) |
| expert | 27 | kerf_blink_behind | shield_robot | 3 | 2 | 1.5 | 37.25 (1) | 28.85 (1) |
| expert | 27 | overkill_carry | all waves | 21 | 2 | 10.5 | 33.05 (2) | — |
| expert | 28 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 38.38 (2) | — |
| expert | 28 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 38.38 (2) |
| expert | 28 | kerf_blink_behind | shield_robot | 6 | 2 | 3 | 38.38 (2) | — |
| expert | 28 | overkill_carry | all waves | 21 | 2 | 10.5 | 38.38 (2) | — |
| expert | 29 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 37.8 (1) | 33.45 (1) |
| expert | 29 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 35.63 (2) |
| expert | 29 | kerf_blink_behind | shield_robot | 3 | 2 | 1.5 | 35.63 (2) | — |
| expert | 29 | overkill_carry | all waves | 20 | 2 | 10 | 35.63 (2) | — |
| expert | 30 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 32.09 (2) | — |
| expert | 30 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 32.09 (2) | — |
| expert | 30 | kerf_blink_behind | shield_robot | 9 | 2 | 4.5 | 32.09 (2) | — |
| expert | 30 | overkill_carry | all waves | 10 | 2 | 5 | 32.09 (2) | — |
| expert | 31 | ohm_short_circuit | sentry_turret | 3 | 2 | 1.5 | 37.73 (2) | — |
| expert | 31 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 37.73 (2) |
| expert | 31 | kerf_blink_behind | shield_robot | 6 | 2 | 3 | 37.73 (2) | — |
| expert | 31 | overkill_carry | all waves | 26 | 2 | 13 | 37.73 (2) | — |
| expert | 32 | ohm_short_circuit | sentry_turret | 1 | 2 | 0.5 | 46.02 (1) | — |
| expert | 32 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 46.02 (1) |
| expert | 32 | kerf_blink_behind | shield_robot | 3 | 2 | 1.5 | 46.02 (1) | — |
| expert | 32 | overkill_carry | all waves | 18 | 2 | 9 | 46.02 (1) | — |
| expert | 33 | ohm_short_circuit | sentry_turret | 2 | 2 | 1 | 35.27 (1) | — |
| expert | 33 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 35.27 (1) |
| expert | 33 | kerf_blink_behind | shield_robot | 6 | 2 | 3 | 35.27 (1) | — |
| expert | 33 | overkill_carry | all waves | 30 | 2 | 15 | 35.27 (1) | — |
| expert | 34 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 34.38 (1) |
| expert | 34 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 34.38 (1) |
| expert | 34 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 34.38 (1) | — |
| expert | 34 | overkill_carry | all waves | 11 | 1 | 11 | 34.38 (1) | — |
| expert | 35 | ohm_short_circuit | sentry_turret | 1 | 1 | 1 | — | 29.73 (1) |
| expert | 35 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 29.73 (1) | — |
| expert | 35 | kerf_blink_behind | shield_robot | 3 | 1 | 3 | 29.73 (1) | — |
| expert | 35 | overkill_carry | all waves | 5 | 1 | 5 | 29.73 (1) | — |
| expert | 36 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 33.13 (1) | — |
| expert | 36 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 33.13 (1) |
| expert | 36 | kerf_blink_behind | shield_robot | 5 | 1 | 5 | 33.13 (1) | — |
| expert | 36 | overkill_carry | all waves | 10 | 1 | 10 | 33.13 (1) | — |
| expert | 37 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 44.42 (1) | — |
| expert | 37 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 44.42 (1) |
| expert | 37 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 44.42 (1) | — |
| expert | 37 | overkill_carry | all waves | 14 | 1 | 14 | 44.42 (1) | — |
| expert | 38 | ohm_short_circuit | sentry_turret | 2 | 1 | 2 | 41 (1) | — |
| expert | 38 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 41 (1) |
| expert | 38 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 41 (1) | — |
| expert | 38 | overkill_carry | all waves | 19 | 1 | 19 | 41 (1) | — |
| expert | 39 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 83.03 (1) | — |
| expert | 39 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | — | 83.03 (1) |
| expert | 39 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 83.03 (1) | — |
| expert | 39 | overkill_carry | all waves | 17 | 1 | 17 | 83.03 (1) | — |
| expert | 40 | ohm_short_circuit | sentry_turret | 0 | 1 | 0 | 40.32 (1) | — |
| expert | 40 | tonnage_armour_crack | war_machine | 0 | 1 | 0 | 40.32 (1) | — |
| expert | 40 | kerf_blink_behind | shield_robot | 4 | 1 | 4 | 40.32 (1) | — |
| expert | 40 | overkill_carry | all waves | 17 | 1 | 17 | 40.32 (1) | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| effect_overkill_carry | waves survived | 17 (3) | 2 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry | wave s | 31.6 (3) | 22.58 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | waves survived | 15 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| effect_overkill_carry_2 | wave s | 31.45 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | waves survived | 7 (5) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_dent | wave s | 29.63 (4) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_kerf | waves survived | 10.5 (6) | 1.5 (2) | 2 | 11.5 | 0…23 | not measured (0, all offered) | too few pairs |
| ghost_kerf | wave s | 26.24 (5) | 36.34 (2) | 2 | -8 | -13.71…-2.3 | not measured (0, all offered) | too few pairs |
| ghost_ohm | waves survived | 2 (8) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 27.64 (8) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 4 (9) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| ghost_tonnage | wave s | 22.45 (9) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_10 | waves survived | 4 (13) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_10 | wave s | 17.58 (13) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | waves survived | 3.5 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_damage_25 | wave s | 24.32 (6) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 5.5 (8) | 3.5 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_10 | wave s | 19.42 (7) | 15.74 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_guard_meter_25 | waves survived | 2 (6) | 4 (5) | 3 | -5 | -5…1 | not measured (3, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 32.18 (5) | 17.63 (4) | 1 | 4.9 | not measured | not measured (1, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 8 (10) | 2 (5) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | wave s | 21.5 (8) | 15.02 (5) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_25 | waves survived | 20 (2) | 4 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 31.34 (2) | 22.45 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_10 | waves survived | 5 (7) | 2 (5) | 1 | 5 | not measured | not measured (1, all offered) | too few pairs |
| stat_regen_10 | wave s | 20.38 (7) | 15.67 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | waves survived | 11 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 32.97 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 3 (9) | 0 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | wave s | 18.23 (8) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | waves survived | 15 (2) | 2 (8) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_25 | wave s | 33.35 (2) | 16.73 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 5 (3) | 4.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_chainsaw | wave s | 36.86 (2) | 17.57 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 16.5 (2) | 2 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_electro_baton | wave s | 33.17 (2) | 20.32 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 12 (4) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_flamethrower | wave s | 29.44 (4) | 19.7 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | waves survived | 19.5 (4) | 1 (3) | 1 | 3 | not measured | not measured (0, all offered) | too few pairs |
| weapon_gatling | wave s | 30.08 (4) | 32.73 (3) | 1 | 4.09 | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | waves survived | 3.5 (4) | 3 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_gloria | wave s | 32.79 (4) | 14.18 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 6 (3) | 1 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 34.25 (3) | 24.02 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | waves survived | 12 (3) | 6 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_katana | wave s | 29.64 (3) | 17.51 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 20 (2) | 5 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 31.48 (2) | 20.38 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | waves survived | 7.5 (8) | 2.5 (6) | 3 | 5 | -1…5 | not measured (3, all offered) | too few pairs |
| weapon_pistol | wave s | 21.88 (8) | 15.28 (4) | 3 | 0.73 | -1.1…3.55 | not measured (3, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 16.5 (2) | 6.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 33.39 (2) | 17.57 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 16.5 (4) | 3 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 31.43 (3) | 27.19 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 1 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 31.44 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 5 (3) | 4.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| chainsaw | wave s | 36.86 (2) | 17.57 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | waves survived | 16.5 (2) | 2 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| electro_baton | wave s | 33.17 (2) | 20.32 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | waves survived | 12 (4) | 3 (3) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| flamethrower | wave s | 29.44 (4) | 19.7 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gatling | waves survived | 19.5 (4) | 1 (3) | 1 | 3 | not measured | not measured (0, all offered) | too few pairs |
| gatling | wave s | 30.08 (4) | 32.73 (3) | 1 | 4.09 | not measured | not measured (0, all offered) | too few pairs |
| gloria | waves survived | 3.5 (4) | 3 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| gloria | wave s | 32.79 (4) | 14.18 (10) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | waves survived | 6 (3) | 1 (7) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| hand_cannon | wave s | 34.25 (3) | 24.02 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | waves survived | 12 (3) | 6 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| katana | wave s | 29.64 (3) | 17.51 (6) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | waves survived | 20 (2) | 5 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| machine_pistol | wave s | 31.48 (2) | 20.38 (5) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | waves survived | 7.5 (8) | 2.5 (6) | 3 | 5 | -1…5 | not measured (3, all offered) | too few pairs |
| pistol | wave s | 21.88 (8) | 15.28 (4) | 3 | 0.73 | -1.1…3.55 | not measured (3, all offered) | too few pairs |
| plasma_rifle | waves survived | 16.5 (2) | 6.5 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | wave s | 33.39 (2) | 17.57 (4) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | waves survived | 16.5 (4) | 3 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_sword | wave s | 31.43 (3) | 27.19 (1) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | waves survived | 1 (7) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| rocket_launcher | wave s | 31.44 (3) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 8 (5) | 2 (5) | 0 (5) | 13 (5) | not measured | not measured | 12.98 (5) | not measured |
| novice | 2 | 8 (5) | 2 (5) | 0 (5) | 14 (5) | not measured | not measured | 17.22 (5) | not measured |
| novice | 3 | 7 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | not measured | 13 (5) | 7.1 (1) |
| novice | 4 | 5 (5) | 2 (5) | 0 (5) | 12 (5) | not measured | 6.78 (1) | 12.83 (5) | not measured |
| novice | 5 | 1 (5) | 0 (5) | 0 (5) | 15 (5) | not measured | not measured | 9.73 (5) | not measured |
| novice | 6 | 7 (1) | 2 (1) | 5 (1) | 36 (1) | not measured | not measured | 22.8 (1) | not measured |
| average | 1 | 7 (5) | 3 (5) | 0 (5) | 13 (5) | not measured | not measured | 14.05 (5) | not measured |
| average | 2 | 7 (5) | 3 (5) | 0 (5) | 14 (5) | not measured | not measured | 13.98 (5) | not measured |
| average | 3 | 4 (5) | 4 (5) | 0 (5) | 12 (5) | not measured | not measured | 19.23 (5) | 7.1 (2) |
| average | 4 | 4 (5) | 3 (5) | 0 (5) | 12 (5) | not measured | 3.67 (1) | 11.23 (5) | 7.1 (1) |
| average | 5 | 1 (5) | 7 (5) | 0 (5) | 21 (5) | 5.5 (1) | 4.82 (1) | 11.35 (5) | 7.1 (1) |
| average | 6 | 11 (4) | 2.5 (4) | 32 (4) | 32 (4) | 3.13 (1) | not measured | 16.04 (4) | 7.1 (1) |
| average | 7 | 9 (3) | 5 (3) | 57 (3) | 31 (3) | 7.2 (1) | 0.03 (1) | 19.48 (3) | 7.1 (2) |
| average | 8 | 6 (3) | 6 (3) | 41 (3) | 30 (3) | 5.5 (1) | 0.03 (1) | 22.45 (3) | 7.1 (1) |
| average | 9 | 3 (2) | 8.5 (2) | 121.5 (2) | 1096.5 (2) | 6.03 (1) | 0.1 (1) | 24.07 (2) | 7.1 (2) |
| average | 10 | 1.5 (2) | 5.5 (2) | 77.5 (2) | 473 (2) | 6.4 (1) | 7.67 (1) | 21.96 (2) | 14.2 (1) |
| average | 11 | 3.5 (2) | 7.5 (2) | 17 (2) | 511.5 (2) | 3.12 (1) | not measured | 6.92 (2) | 7.1 (1) |
| expert | 1 | 11 (5) | 3 (5) | 0 (5) | 13 (5) | not measured | not measured | 14.63 (5) | not measured |
| expert | 2 | 5 (5) | 6 (5) | 0 (5) | 14 (5) | not measured | not measured | 18.82 (5) | not measured |
| expert | 3 | 7 (5) | 9 (5) | 0 (5) | 12 (5) | not measured | not measured | 19.42 (5) | 7.1 (2) |
| expert | 4 | 6 (5) | 4 (5) | 0 (5) | 12 (5) | not measured | 4.85 (1) | 12.45 (5) | not measured |
| expert | 5 | 1 (5) | 9 (5) | 0 (5) | 20 (5) | 5.5 (1) | 7.3 (1) | 16.03 (5) | 6.21 (2) |
| expert | 6 | 5.5 (4) | 7 (4) | 34 (4) | 33.5 (4) | 0.92 (1) | 0.03 (1) | 18.79 (4) | 7.1 (2) |
| expert | 7 | 3 (4) | 8.5 (4) | 53.5 (4) | 36 (4) | 6.43 (1) | 7.3 (1) | 8.96 (4) | 7.1 (2) |
| expert | 8 | 1.5 (4) | 6.5 (4) | 51.5 (4) | 63 (4) | 6.58 (1) | 3.68 (2) | 16.61 (4) | 7.1 (2) |
| expert | 9 | 2.5 (4) | 7.5 (4) | 57 (4) | 79.5 (4) | 6.33 (2) | 1.58 (3) | 12.73 (4) | 7.1 (3) |
| expert | 10 | 2 (4) | 10 (4) | 47 (4) | 66.5 (4) | 4.23 (2) | 0.55 (3) | 10.79 (4) | 5.54 (2) |
| expert | 11 | 4 (3) | 3 (3) | 51 (3) | 55 (3) | 5.5 (3) | 7.3 (1) | 12.52 (3) | not measured |
| expert | 12 | 10 (3) | 14 (3) | 111 (3) | 121 (3) | 5.5 (3) | 0.1 (2) | 17 (3) | 7.1 (1) |
| expert | 13 | 3 (3) | 13 (3) | 54 (3) | 395 (3) | 5.5 (3) | 2.02 (1) | 15.38 (3) | not measured |
| expert | 14 | 4 (3) | 11 (3) | 54 (3) | 54 (3) | 5.5 (3) | 4.13 (2) | 16.05 (3) | 7.1 (1) |
| expert | 15 | 3 (3) | 4 (3) | 64 (3) | 182 (3) | 5.5 (3) | 1.04 (2) | 10.57 (3) | not measured |
| expert | 16 | 4 (3) | 6 (3) | 166 (3) | 2153 (3) | 5.5 (3) | 0.03 (1) | 23.7 (3) | not measured |
| expert | 17 | 2 (3) | 9 (3) | 104 (3) | 818 (3) | 5.5 (3) | 0.17 (1) | 16.05 (3) | 7.1 (1) |
| expert | 18 | 4 (3) | 12 (3) | 69 (3) | 986 (3) | 5.5 (3) | 0.73 (3) | 18.63 (3) | not measured |
| expert | 19 | 5 (3) | 10 (3) | 80 (3) | 357 (3) | 5.5 (3) | 0.57 (3) | 27.18 (3) | not measured |
| expert | 20 | 2 (3) | 9 (3) | 88 (3) | 1055 (3) | 5.5 (3) | 0.22 (3) | 19.7 (3) | 7.1 (1) |
| expert | 21 | 7 (3) | 7 (3) | 124 (3) | 1310 (3) | 5.5 (3) | 0.4 (2) | 17.75 (3) | not measured |
| expert | 22 | 14 (3) | 12 (3) | 75 (3) | 303 (3) | 5.5 (3) | 0.2 (3) | 31.45 (3) | 7.1 (1) |
| expert | 23 | 6 (3) | 7 (3) | 54 (3) | 2195 (3) | 6.44 (2) | 0.03 (3) | 13.77 (3) | not measured |
| expert | 24 | 12.5 (2) | 13 (2) | 62.5 (2) | 637 (2) | 5.73 (2) | 3.72 (2) | 20.29 (2) | not measured |
| expert | 25 | 5 (2) | 19 (2) | 71 (2) | 162.5 (2) | 5.5 (2) | 7.47 (1) | 19.29 (2) | not measured |
| expert | 26 | 6.5 (2) | 14.5 (2) | 68 (2) | 2087.5 (2) | 8.25 (2) | 0.03 (1) | 17.09 (2) | not measured |
| expert | 27 | 3.5 (2) | 12 (2) | 115 (2) | 1807 (2) | 5.5 (2) | 3.81 (2) | 23.73 (2) | not measured |
| expert | 28 | 3.5 (2) | 14.5 (2) | 136 (2) | 1950.5 (2) | 7.13 (2) | 3.91 (2) | 27.34 (2) | not measured |
| expert | 29 | 9 (2) | 14.5 (2) | 110 (2) | 1728 (2) | 5.71 (2) | 3.08 (2) | 26.84 (2) | not measured |
| expert | 30 | 5 (2) | 15.5 (2) | 80.5 (2) | 1418.5 (2) | 10.84 (2) | 0.67 (1) | 20.93 (2) | not measured |
| expert | 31 | 10 (2) | 15 (2) | 160 (2) | 3702 (2) | 5.5 (2) | 0.66 (2) | 31.57 (2) | not measured |
| expert | 32 | 12.5 (2) | 28 (2) | 168 (2) | 2398 (2) | 13.75 (2) | 1.45 (2) | 39.44 (2) | not measured |
| expert | 33 | 15.5 (2) | 17 (2) | 68 (2) | 2427 (2) | 5.5 (2) | 0.03 (2) | 21.23 (2) | not measured |
| expert | 34 | 2 (1) | 21 (1) | 114 (1) | 2247 (1) | 11 (1) | 1.15 (1) | 22.23 (1) | not measured |
| expert | 35 | 11 (1) | 14 (1) | 45 (1) | 534 (1) | 5.5 (1) | 5.37 (1) | 18.87 (1) | not measured |
| expert | 36 | 9 (1) | 21 (1) | 88 (1) | 2986 (1) | 11 (1) | not measured | 22.13 (1) | not measured |
| expert | 37 | 22 (1) | 21 (1) | 140 (1) | 4273 (1) | 10.53 (1) | 0.2 (1) | 33.68 (1) | not measured |
| expert | 38 | 12 (1) | 21 (1) | 91 (1) | 1127 (1) | 6.83 (1) | 0.57 (1) | 33.6 (1) | not measured |
| expert | 39 | 12 (1) | 40 (1) | 231 (1) | 4181 (1) | 17.37 (1) | 0.2 (1) | 65.47 (1) | not measured |
| expert | 40 | 4 (1) | 26 (1) | 83 (1) | 1938 (1) | 12.18 (1) | not measured | 28.13 (1) | not measured |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 4 | 6 | 1.55 | stat_damage_10 → stat_speed_10 → stat_damage_25 → stat_guard_meter_25 → weapon_rocket_launcher | rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 1 | 11 | 1.55 | ghost_tonnage → stat_hp_max_10 → stat_damage_10 → ghost_dent → weapon_flamethrower → weapon_gatling → weapon_katana → ghost_kerf → weapon_pistol → stat_speed_10 | flamethrower, gatling, katana, pistol | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 3 | 11 | 1.55 | stat_hp_max_10 → weapon_pistol → stat_damage_10 → stat_guard_meter_10 → stat_regen_10 → ghost_tonnage → weapon_gloria → ghost_ohm → weapon_rocket_launcher | gloria, pistol, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 2 | 40 | 1.21 | ghost_tonnage → ghost_ohm → stat_regen_10 → stat_hp_max_10 → stat_guard_meter_10 → weapon_machine_pistol → weapon_gatling → stat_damage_25 → stat_speed_10 → ghost_kerf → stat_damage_10 → weapon_pistol → stat_hp_max_25 → stat_guard_meter_25 → weapon_electro_baton → ghost_dent → stat_speed_25 → weapon_plasma_rifle → weapon_gloria → weapon_plasma_sword → weapon_hand_cannon → effect_overkill_carry → weapon_rocket_launcher → effect_overkill_carry_2 → weapon_flamethrower → stat_regen_25 → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=expert --pick=greedy --controls=wheel --waves=40 |
