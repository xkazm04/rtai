# Gauntlet run report

30 of 30 runs accepted. Average-profile waves 1 (10.25 s), 2 (11.88 s), 4 (11.68 s), 5 (16.23 s), 8 (18.05 s), 9 (30.68 s), 11 (29.56 s), 12 (34.33 s), 13 (30.8 s), 14 (33.88 s), 15 (37.92 s), 16 (36.67 s), 17 (37.2 s), 18 (41.33 s), 19 (31.55 s), 21 (32 s), 22 (40.02 s), 23 (41.75 s), 24 (35.02 s), 25 (30.67 s), 26 (40.8 s), 27 (46.15 s), 28 (56.75 s), 29 (44.55 s), 30 (43.59 s), 31 (61.58 s), 32 (49.22 s), 33 (39.38 s), 34 (42.15 s), 35 (42.65 s), 36 (53.47 s), 37 (50.63 s), 38 (50.4 s), 39 (60.62 s), 40 (47.15 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ ccfc29df081a (dirty) · 2026-11-22T04:58:04.279Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 1, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 16 | 12–23 | 10–28 | 10 / 0 |
| average | 12 | 40 | 33–40 | 15–40 | 2 / 8 |
| expert | 20 | 40 | 40–40 | 40–40 | 0 / 10 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 24 | 9 / 10 | 90% | 0 | separated |
| novice → expert | 24 | 10 / 10 | 100% | 0 | separated |
| average → expert | 0 | 2 / 10 | 20% | 8 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 28 | 1 | 1 |
| novice | 2 | died on 10 | 0 | 1 |
| novice | 3 | died on 12 | 0 | 1 |
| novice | 4 | died on 11 | 0 | 1 |
| novice | 5 | died on 23 | 0 | 1 |
| novice | 6 | died on 24 | 0 | 1 |
| novice | 7 | died on 18 | 0 | 1 |
| novice | 8 | died on 17 | 0 | 1 |
| novice | 9 | died on 13 | 0 | 1 |
| novice | 10 | died on 15 | 0 | 1 |
| average | 1 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 2 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 3 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 4 | died on 15 | 0 | 1 |
| average | 5 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 6 | died on 23 | 14 | 13 |
| average | 7 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 8 | censored at the tick cap (≥ 33) | 3 | — |
| average | 9 | censored at the wave limit 40 (≥ 40) | 1 | — |
| average | 10 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 1 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 2 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 3 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 4 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 5 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 6 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 7 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 8 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 9 | censored at the wave limit 40 (≥ 40) | 0 | — |
| expert | 10 | censored at the wave limit 40 (≥ 40) | 0 | — |

## Wave time

Seconds per observed wave. The target is 15 s ±20% for ordinary average-profile waves. Every 5th wave targets 25–30 s. Timed / observed shows the coverage of the seconds field. Quartiles use the repository’s quantile function.

| Profile | Wave | Timed / observed | Median s | P25…P75 s | Min…max s | Target |
| --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 10 / 10 | 9.48 | 9.1…11.32 | 8.2…22.28 | — |
| novice | 2 | 10 / 10 | 12.63 | 10.37…14.73 | 8.2…17.85 | — |
| novice | 3 | 10 / 10 | 15.14 | 13.37…18.35 | 9.48…21.18 | — |
| novice | 4 | 10 / 10 | 11.81 | 11.27…12.4 | 9.4…14.57 | — |
| novice | 5 | 10 / 10 | 13.05 | 10.32…16.9 | 2.85…18.18 | — |
| novice | 6 | 10 / 10 | 18.01 | 15.92…21.25 | 15.2…24.3 | — |
| novice | 7 | 10 / 10 | 20.59 | 15.92…27.08 | 13.28…33.8 | — |
| novice | 8 | 10 / 10 | 22.86 | 22.25…29.35 | 19.97…150.55 | — |
| novice | 9 | 10 / 10 | 33.76 | 25.78…46.63 | 24.93…58.9 | — |
| novice | 10 | 9 / 10 | 19.33 | 17.9…24.23 | 7.87…34.6 | — |
| novice | 11 | 8 / 9 | 33.39 | 31.9…38.37 | 24.1…40.92 | — |
| novice | 12 | 7 / 8 | 44.08 | 34.48…49.25 | 25.28…56.87 | — |
| novice | 13 | 6 / 7 | 41.8 | 28.08…53.85 | 25.12…53.85 | — |
| novice | 14 | 6 / 6 | 36.06 | 30.92…48.27 | 29.62…50.27 | — |
| novice | 15 | 5 / 6 | 28.8 | 28.38…34.77 | 27.98…41.2 | — |
| novice | 16 | 5 / 5 | 46.53 | 37.55…50.22 | 35.15…60.37 | — |
| novice | 17 | 4 / 5 | 32.34 | 30.37…55.48 | 28.58…55.48 | — |
| novice | 18 | 3 / 4 | 50.23 | 41.75…61.18 | 41.75…61.18 | — |
| novice | 19 | 3 / 3 | 54.63 | 33.92…67.72 | 33.92…67.72 | — |
| novice | 20 | 3 / 3 | 33.55 | 33.05…35.98 | 33.05…35.98 | — |
| novice | 21 | 3 / 3 | 41.68 | 35.1…44.65 | 35.1…44.65 | — |
| novice | 22 | 3 / 3 | 39.33 | 26.22…39.4 | 26.22…39.4 | — |
| novice | 23 | 2 / 3 | 51.67 | 50.05…53.28 | 50.05…53.28 | — |
| novice | 24 | 1 / 2 | 64.18 | 64.18…64.18 | 64.18…64.18 | — |
| novice | 25 | 1 / 1 | 41.63 | 41.63…41.63 | 41.63…41.63 | — |
| novice | 26 | 1 / 1 | 46.43 | 46.43…46.43 | 46.43…46.43 | — |
| novice | 27 | 1 / 1 | 47.35 | 47.35…47.35 | 47.35…47.35 | — |
| novice | 28 | 0 / 1 | not measured | not measured | not measured | — |
| average | 1 | 10 / 10 | 10.25 | 9.93…10.5 | 9.07…10.9 | miss |
| average | 2 | 10 / 10 | 11.88 | 11.22…12.63 | 9.5…17.28 | miss |
| average | 3 | 10 / 10 | 15.47 | 12.17…15.85 | 8.83…23.53 | within target |
| average | 4 | 10 / 10 | 11.68 | 8.82…13.07 | 8.12…16.22 | miss |
| average | 5 | 10 / 10 | 16.23 | 11.32…24.18 | 9.88…27 | miss |
| average | 6 | 10 / 10 | 17.41 | 16.33…19.08 | 12.25…21.27 | within target |
| average | 7 | 9 / 10 | 16.43 | 14.55…18.15 | 11.2…27.87 | within target |
| average | 8 | 9 / 10 | 18.05 | 17.25…20.07 | 11.55…27.9 | miss |
| average | 9 | 10 / 10 | 30.68 | 24.4…34.7 | 19.05…37.97 | miss |
| average | 10 | 9 / 10 | 26.58 | 20.43…30.43 | 15.85…47.35 | within target |
| average | 11 | 10 / 10 | 29.56 | 25.47…34.35 | 18.22…117.08 | miss |
| average | 12 | 10 / 10 | 34.33 | 26.05…40.87 | 21.05…58.87 | miss |
| average | 13 | 10 / 10 | 30.8 | 27.03…37.65 | 19.65…385.3 | miss |
| average | 14 | 9 / 10 | 33.88 | 26.73…44.65 | 13.68…55.8 | miss |
| average | 15 | 8 / 10 | 37.92 | 27.63…45.07 | 20.38…51.68 | miss |
| average | 16 | 8 / 9 | 36.67 | 32.58…42.65 | 26.42…58.32 | miss |
| average | 17 | 8 / 9 | 37.2 | 31.78…38.83 | 27.18…49.72 | miss |
| average | 18 | 8 / 9 | 41.33 | 35.28…50.48 | 23.48…51.6 | miss |
| average | 19 | 8 / 9 | 31.55 | 29.97…37.12 | 25.02…39.75 | miss |
| average | 20 | 8 / 9 | 27.37 | 25.02…34.73 | 23.8…51.57 | within target |
| average | 21 | 8 / 9 | 32 | 26.42…50.6 | 21.05…54.27 | miss |
| average | 22 | 8 / 9 | 40.02 | 33.33…51.83 | 29.58…54.35 | miss |
| average | 23 | 8 / 9 | 41.75 | 31.85…53.92 | 24.03…63.65 | miss |
| average | 24 | 8 / 8 | 35.02 | 34.93…58.45 | 29.95…62.83 | miss |
| average | 25 | 8 / 8 | 30.67 | 30.15…38.6 | 25.95…59.22 | miss |
| average | 26 | 8 / 8 | 40.8 | 38.8…57.38 | 36.6…70.98 | miss |
| average | 27 | 8 / 8 | 46.15 | 34.93…60.12 | 29.78…66.98 | miss |
| average | 28 | 8 / 8 | 56.75 | 38.93…60.63 | 37.72…68 | miss |
| average | 29 | 8 / 8 | 44.55 | 43.8…51.42 | 28.8…64.3 | miss |
| average | 30 | 8 / 8 | 43.59 | 41.62…57.77 | 37.9…63 | miss |
| average | 31 | 7 / 8 | 61.58 | 51.27…62.25 | 43.5…62.95 | miss |
| average | 32 | 7 / 8 | 49.22 | 46.97…55.87 | 41.45…60.6 | miss |
| average | 33 | 7 / 8 | 39.38 | 33.83…43.98 | 32.43…51.33 | miss |
| average | 34 | 7 / 7 | 42.15 | 40.62…47.75 | 38.25…58.23 | miss |
| average | 35 | 7 / 7 | 42.65 | 34.7…64.23 | 30.55…64.38 | miss |
| average | 36 | 7 / 7 | 53.47 | 40.78…68.03 | 38.72…78.23 | miss |
| average | 37 | 7 / 7 | 50.63 | 43.88…51.42 | 41.63…59.42 | miss |
| average | 38 | 7 / 7 | 50.4 | 41.88…57.45 | 41…149.82 | miss |
| average | 39 | 7 / 7 | 60.62 | 54.95…61.58 | 48.78…68.98 | miss |
| average | 40 | 7 / 7 | 47.15 | 43.92…51.93 | 43.62…61.08 | miss |
| expert | 1 | 10 / 10 | 9.95 | 9.33…11.3 | 8.5…14.02 | — |
| expert | 2 | 10 / 10 | 12.34 | 10.23…16.97 | 8.88…20.95 | — |
| expert | 3 | 10 / 10 | 12.68 | 10.88…13.9 | 7.6…21.97 | — |
| expert | 4 | 10 / 10 | 12.04 | 9.08…14.35 | 6.95…23.18 | — |
| expert | 5 | 10 / 10 | 18.25 | 14.23…23.75 | 2.75…48.83 | — |
| expert | 6 | 10 / 10 | 17.93 | 15.22…19.33 | 7.62…23.05 | — |
| expert | 7 | 10 / 10 | 14.31 | 10.52…20.18 | 7.9…40.03 | — |
| expert | 8 | 10 / 10 | 17.27 | 14.72…20.67 | 13.02…37 | — |
| expert | 9 | 10 / 10 | 27.65 | 24.1…34.37 | 15.83…36.27 | — |
| expert | 10 | 10 / 10 | 21.72 | 18.85…31.03 | 7.65…41.58 | — |
| expert | 11 | 10 / 10 | 23.68 | 17.28…29.12 | 14.2…39.23 | — |
| expert | 12 | 10 / 10 | 31.95 | 27.62…34.72 | 24.53…48.67 | — |
| expert | 13 | 10 / 10 | 39.19 | 30.87…45.37 | 23.52…55.38 | — |
| expert | 14 | 10 / 10 | 32.23 | 22.13…37.12 | 11.6…51.3 | — |
| expert | 15 | 10 / 10 | 29.17 | 21.82…42.2 | 19.17…50.8 | — |
| expert | 16 | 10 / 10 | 37.67 | 30.28…44 | 26.78…51.88 | — |
| expert | 17 | 10 / 10 | 40.58 | 37.73…44.57 | 16.15…49.43 | — |
| expert | 18 | 10 / 10 | 31.64 | 24.73…36.77 | 22.88…48.28 | — |
| expert | 19 | 10 / 10 | 40.93 | 35.7…48.67 | 23.43…61 | — |
| expert | 20 | 10 / 10 | 28.03 | 21.42…42.98 | 9.93…64.43 | — |
| expert | 21 | 10 / 10 | 27.65 | 24.82…32.95 | 21.35…64.58 | — |
| expert | 22 | 10 / 10 | 36.95 | 32.68…44.95 | 28.38…57.85 | — |
| expert | 23 | 10 / 10 | 37.79 | 29.73…53.93 | 14.82…72.95 | — |
| expert | 24 | 10 / 10 | 43.97 | 32.17…48.9 | 25.13…54.78 | — |
| expert | 25 | 10 / 10 | 36.13 | 27.3…40.12 | 22.92…47.47 | — |
| expert | 26 | 10 / 10 | 32.02 | 29.6…43.2 | 25.75…57.03 | — |
| expert | 27 | 10 / 10 | 38.64 | 31.08…43.25 | 25.03…49.7 | — |
| expert | 28 | 10 / 10 | 44.1 | 37.5…46.97 | 33.78…71.22 | — |
| expert | 29 | 10 / 10 | 37.75 | 32.48…40.85 | 30.13…51.78 | — |
| expert | 30 | 10 / 10 | 37.19 | 32.93…48.88 | 27.75…62.42 | — |
| expert | 31 | 10 / 10 | 41.95 | 39.8…47.1 | 23.13…59.6 | — |
| expert | 32 | 10 / 10 | 44.95 | 39.37…47.92 | 36.15…53.57 | — |
| expert | 33 | 10 / 10 | 49.38 | 39.15…51.42 | 32.93…61.03 | — |
| expert | 34 | 10 / 10 | 39.91 | 35.63…42.38 | 29.85…58.45 | — |
| expert | 35 | 10 / 10 | 35.17 | 29.68…43.1 | 20.62…64.68 | — |
| expert | 36 | 10 / 10 | 46.03 | 43.82…48.77 | 29.23…49.52 | — |
| expert | 37 | 10 / 10 | 41.66 | 36.62…45.2 | 25.98…49.47 | — |
| expert | 38 | 10 / 10 | 51.2 | 46.05…56.25 | 33.93…72.55 | — |
| expert | 39 | 10 / 10 | 51.35 | 39.8…54.48 | 31.17…73.87 | — |
| expert | 40 | 10 / 10 | 45.57 | 38.95…54.52 | 28.63…72.73 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 10 × 1, 11 × 1, 12 × 1, 13 × 1, 15 × 1, 17 × 1, 18 × 1, 23 × 1, 24 × 1, 28 × 1 | shield_robot × 4, rocket × 2, stomp × 2, robot_gunner × 1, swat × 1 | 0 |
| average | 10 | 2 | 0 | 1 | 7 | 15 × 1, 23 × 1 | shield_robot × 1, war_cannon × 1 | 0 |
| expert | 10 | 0 | 0 | 0 | 10 | — | — | 0 |

## Timeouts

Runs that reached the wave time limit.

| Outcome | novice | average | expert |
| --- | --- | --- | --- |
| timeout | 0 | 0 | 0 |

## Survival by wave band

Each wave contributes once to each available median. Damage/s needs a timed wave. Repair/s is the configured rate when repair is active. HP coverage counts waves sampled by the bot. Repaired HP sums positive HP steps. The share undone uses waves with positive damage. Multipliers include stat cards taken before the wave.

| Profile | Waves | HP rows / observed | Damage | Damage/s | Repair/s | Minimum HP (% of capacity) | Repaired HP | Damage undone (%) | Guard deflects | Cover ticks | Rolls | damage × | guard_meter × | hp_max × | regen × | speed × |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1–10 | 100 / 100 | 6.71 | 0.34 | 8 | 92.15 | 4.7 | 100 | 7 | 0 | 2 | 1.1 | 1 | 1.1 | 1 | 1 |
| novice | 11–20 | 56 / 56 | 63.91 | 1.49 | 8.8 | 55.39 | 52.5 | 100 | 9.5 | 0 | 5 | 1.375 | 1.1 | 1.375 | 1.1 | 1.1 |
| novice | 21–30 | 15 / 15 | 95.4 | 1.55 | 11 | 41.05 | 59.55 | 95.81 | 11 | 0 | 7 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 100 / 100 | 3.6 | 0.19 | 8 | 97.09 | 2.94 | 100 | 6 | 2 | 3 | 1.1 | 1 | 1.1 | 1 | 1 |
| average | 11–20 | 95 / 95 | 36.83 | 0.83 | 8.8 | 79.88 | 28.87 | 100 | 10 | 23 | 9 | 1.25 | 1.1 | 1.375 | 1.1 | 1.1 |
| average | 21–30 | 83 / 83 | 40.58 | 0.89 | 11 | 77.88 | 38.98 | 100 | 13 | 30 | 12 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| average | 31+ | 73 / 73 | 44.88 | 0.88 | 11 | 79.82 | 40.87 | 100 | 13.5 | 38 | 15.5 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 1–10 | 100 / 100 | 2.7 | 0.17 | 8 | 97.6 | 2.4 | 100 | 6 | 12.5 | 3 | 1.1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 100 / 100 | 18.55 | 0.53 | 8.8 | 89.82 | 16.93 | 100 | 8 | 89.5 | 11 | 1.375 | 1.1 | 1.375 | 1.1 | 1.1 |
| expert | 21–30 | 100 / 100 | 28.79 | 0.68 | 11 | 87.6 | 25.18 | 100 | 12 | 98.5 | 14 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 31+ | 100 / 100 | 29.5 | 0.73 | 11 | 85.61 | 26.51 | 100 | 17 | 142.5 | 17.5 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 86.87% | 34.72 (735) | 17.88 (160) |
| patrol_cop | 0 | — | 90.18% | 33.03 (796) | 31.1 (99) |
| riot_cop | 0 | — | 85.44% | 35.1 (711) | 18.97 (184) |
| robot_gunner | 1 | — | 81.49% | 37.6 (645) | 15.72 (250) |
| robot_thug | 0 | — | 81.69% | 37.12 (637) | 16.21 (258) |
| rocket_trooper | 2 | rocket × 2 | 83.15% | 34.44 (710) | 20.18 (185) |
| sentry_turret | 0 | — | 82.61% | 37.07 (642) | 15.68 (253) |
| shield_robot | 5 | — | 79.08% | 39.8 (571) | 17.01 (324) |
| swat | 1 | — | 83.55% | 35.13 (692) | 19.03 (203) |
| war_machine | 3 | stomp × 2, war_cannon × 1 | 18.58% | 31.03 (173) | 33.37 (722) |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 19.5 (24) | 19 (1) | 1 | -13 | not measured | not measured (3, all offered) | too few pairs |
| ghost_dent | wave s | 41.89 (22) | 31.73 (1) | 1 | -12.67 | not measured | not measured (3, all offered) | too few pairs |
| ghost_kerf | waves survived | 22 (24) | 12 (1) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_kerf | wave s | 41.52 (24) | 19.65 (1) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| ghost_ohm | waves survived | 28 (27) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 36.91 (26) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 29 (28) | not measured | 0 | not measured | not measured | 2 (6, all offered) | insufficient data |
| ghost_tonnage | wave s | 36.22 (28) | not measured | 0 | not measured | not measured | 5.53 (6, all offered) | insufficient data |
| stat_damage_10 | waves survived | 25 (28) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_damage_10 | wave s | 35.28 (27) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_damage_25 | waves survived | 20 (25) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_damage_25 | wave s | 38.9 (25) | not measured | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 24 (30) | not measured | 0 | not measured | not measured | 13 (9, all offered) | insufficient data |
| stat_guard_meter_10 | wave s | 36.83 (30) | not measured | 0 | not measured | not measured | 17.31 (9, all offered) | insufficient data |
| stat_guard_meter_25 | waves survived | 20 (22) | 4.5 (4) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 42.2 (22) | 35.15 (4) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 31.5 (30) | not measured | 0 | not measured | not measured | 5 (6, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 35.98 (30) | not measured | 0 | not measured | not measured | 13.63 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 26 (25) | 1 (2) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 40.25 (25) | 36.67 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_regen_10 | waves survived | 23 (27) | 8 (3) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_10 | wave s | 39.87 (27) | 17.57 (3) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_25 | waves survived | 19 (23) | 1 (5) | 2 | 7.5 | 4…11 | not measured (1, all offered) | too few pairs |
| stat_regen_25 | wave s | 41.75 (23) | 36.33 (5) | 2 | -4.09 | -14.48…6.31 | not measured (1, all offered) | too few pairs |
| stat_speed_10 | waves survived | 29 (28) | 8 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 36.99 (28) | 34.08 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_speed_25 | waves survived | 18.5 (26) | 7 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_speed_25 | wave s | 40.52 (25) | 34.32 (1) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 17 (24) | 7 (6) | 1 | 6 | not measured | 6 (6, all offered) | insufficient data |
| weapon_chainsaw | wave s | 42.15 (23) | 30.1 (6) | 1 | 8.63 | not measured | 8.63 (6, all offered) | insufficient data |
| weapon_electro_baton | waves survived | 18 (23) | 9 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| weapon_electro_baton | wave s | 41.4 (23) | 23.63 (6) | 1 | 10.02 | not measured | not measured (1, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 16 (21) | 6.5 (8) | 1 | 10 | not measured | not measured (3, all offered) | too few pairs |
| weapon_flamethrower | wave s | 42.4 (21) | 30.47 (8) | 1 | 14.26 | not measured | not measured (3, all offered) | too few pairs |
| weapon_gatling | waves survived | 22 (27) | 4 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gatling | wave s | 40.07 (26) | 34.21 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gloria | waves survived | 17 (21) | 10.5 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_gloria | wave s | 43.88 (21) | 23.39 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 16 (24) | 5 (5) | 1 | 10 | not measured | not measured (5, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 42.19 (23) | 27.78 (4) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| weapon_katana | waves survived | 16 (22) | 9 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | wave s | 41.81 (22) | 25.8 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 20 (21) | 8 (8) | 1 | -3 | not measured | not measured (5, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 39.8 (21) | 24.41 (8) | 1 | 1.62 | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 24 (27) | 11.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 38.46 (26) | 47.51 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 14 (21) | 11 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 42.75 (21) | 32.91 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 21 (24) | 11 (5) | 2 | -9 | -12…-6 | not measured (3, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 40.08 (23) | 33.93 (5) | 1 | -6.13 | not measured | not measured (2, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 24 (26) | 0 (1) | 1 | 3 | not measured | not measured (4, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 39.67 (26) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 17 (24) | 7 (6) | 1 | 6 | not measured | 6 (6, all offered) | insufficient data |
| chainsaw | wave s | 42.15 (23) | 30.1 (6) | 1 | 8.63 | not measured | 8.63 (6, all offered) | insufficient data |
| electro_baton | waves survived | 18 (23) | 9 (6) | 1 | 2 | not measured | not measured (1, all offered) | too few pairs |
| electro_baton | wave s | 41.4 (23) | 23.63 (6) | 1 | 10.02 | not measured | not measured (1, all offered) | too few pairs |
| flamethrower | waves survived | 16 (21) | 6.5 (8) | 1 | 10 | not measured | not measured (3, all offered) | too few pairs |
| flamethrower | wave s | 42.4 (21) | 30.47 (8) | 1 | 14.26 | not measured | not measured (3, all offered) | too few pairs |
| gatling | waves survived | 22 (27) | 4 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gatling | wave s | 40.07 (26) | 34.21 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gloria | waves survived | 17 (21) | 10.5 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| gloria | wave s | 43.88 (21) | 23.39 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| hand_cannon | waves survived | 16 (24) | 5 (5) | 1 | 10 | not measured | not measured (5, all offered) | too few pairs |
| hand_cannon | wave s | 42.19 (23) | 27.78 (4) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| katana | waves survived | 16 (22) | 9 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | wave s | 41.81 (22) | 25.8 (8) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| machine_pistol | waves survived | 20 (21) | 8 (8) | 1 | -3 | not measured | not measured (5, all offered) | too few pairs |
| machine_pistol | wave s | 39.8 (21) | 24.41 (8) | 1 | 1.62 | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 24 (27) | 11.5 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 38.46 (26) | 47.51 (2) | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | 14 (21) | 11 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_rifle | wave s | 42.75 (21) | 32.91 (7) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| plasma_sword | waves survived | 21 (24) | 11 (5) | 2 | -9 | -12…-6 | not measured (3, all offered) | too few pairs |
| plasma_sword | wave s | 40.08 (23) | 33.93 (5) | 1 | -6.13 | not measured | not measured (2, all offered) | too few pairs |
| rocket_launcher | waves survived | 24 (26) | 0 (1) | 1 | 3 | not measured | not measured (4, all offered) | too few pairs |
| rocket_launcher | wave s | 39.67 (26) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | dent s (n) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 7.5 (10) | 0.5 (10) | 0 (10) | 13 (10) | not measured | not measured | not measured | 9.48 (10) | not measured |
| novice | 2 | 7.5 (10) | 1 (10) | 0 (10) | 14 (10) | not measured | 5.5 (1) | not measured | 11.23 (10) | not measured |
| novice | 3 | 6.5 (10) | 1.5 (10) | 0 (10) | 12 (10) | not measured | 5.5 (1) | not measured | 14.4 (10) | 3.78 (1) |
| novice | 4 | 6.5 (10) | 1 (10) | 0 (10) | 12 (10) | not measured | not measured | 7.3 (1) | 11.8 (10) | not measured |
| novice | 5 | 1.5 (10) | 0.5 (10) | 0 (10) | 22 (10) | not measured | 2.37 (1) | not measured | 10.46 (10) | 7.1 (3) |
| novice | 6 | 6 (10) | 2 (10) | 0 (10) | 34 (10) | not measured | 2.5 (1) | 7.3 (2) | 15.68 (10) | 7.1 (2) |
| novice | 7 | 10 (10) | 2 (10) | 21.5 (10) | 42.5 (10) | not measured | 1.5 (1) | 7.3 (2) | 17.2 (10) | 7.1 (1) |
| novice | 8 | 6.5 (10) | 2.5 (10) | 77.5 (10) | 37.5 (10) | not measured | 5.28 (1) | 4.03 (2) | 22.25 (10) | 7.1 (4) |
| novice | 9 | 10.5 (10) | 6 (10) | 54.5 (10) | 97.5 (10) | not measured | 2.08 (1) | 7.3 (4) | 26.33 (10) | 7.1 (6) |
| novice | 10 | 6.5 (10) | 5 (10) | 39 (10) | 50.5 (10) | not measured | 4.49 (2) | 7.3 (3) | 11.83 (10) | 7.1 (5) |
| novice | 11 | 10 (9) | 4 (9) | 43 (9) | 79 (9) | not measured | 2.77 (2) | 7.3 (4) | 23.08 (9) | 7.1 (7) |
| novice | 12 | 13.5 (8) | 5 (8) | 84 (8) | 130.5 (8) | not measured | 6 (2) | 7.3 (6) | 32.78 (8) | 7.1 (6) |
| novice | 13 | 6 (7) | 4 (7) | 92 (7) | 133 (7) | not measured | 3.37 (1) | 5.43 (5) | 22.23 (7) | 7.1 (7) |
| novice | 14 | 10.5 (6) | 8 (6) | 65.5 (6) | 98 (6) | not measured | 7.12 (1) | 7.3 (6) | 21.75 (6) | 7.1 (6) |
| novice | 15 | 4.5 (6) | 5.5 (6) | 49 (6) | 77 (6) | not measured | 5.5 (2) | 7.17 (4) | 21.29 (6) | 7.1 (5) |
| novice | 16 | 12 (5) | 7 (5) | 47 (5) | 146 (5) | not measured | 3.47 (1) | 7.3 (5) | 25.05 (5) | 7.1 (5) |
| novice | 17 | 7 (5) | 6 (5) | 59 (5) | 139 (5) | not measured | 4.17 (3) | 7.3 (4) | 18.95 (5) | 7.1 (4) |
| novice | 18 | 11 (4) | 5.5 (4) | 74 (4) | 288.5 (4) | not measured | 2.69 (2) | 4.28 (4) | 32.7 (4) | 7.1 (3) |
| novice | 19 | 8 (3) | 8 (3) | 102 (3) | 120 (3) | not measured | 5.5 (2) | 10.95 (3) | 27.97 (3) | 7.1 (3) |
| novice | 20 | 10 (3) | 4 (3) | 36 (3) | 115 (3) | not measured | 5.5 (1) | 7.3 (3) | 18.63 (3) | 7.1 (3) |
| novice | 21 | 11 (3) | 6 (3) | 90 (3) | 120 (3) | not measured | 9.17 (1) | 7.3 (2) | 27.28 (3) | 7.1 (3) |
| novice | 22 | 10 (3) | 7 (3) | 34 (3) | 163 (3) | not measured | 5.48 (3) | 7.3 (3) | 24.97 (3) | 7.1 (2) |
| novice | 23 | 29 (3) | 8 (3) | 27 (3) | 135 (3) | not measured | 1.65 (2) | 7.3 (3) | 34.92 (3) | 7.1 (2) |
| novice | 24 | 32 (2) | 11.5 (2) | 37.5 (2) | 148 (2) | not measured | 3.69 (2) | 7.3 (2) | 29.9 (2) | 14.2 (1) |
| novice | 25 | 15 (1) | 8 (1) | 49 (1) | 2074 (1) | not measured | not measured | 11.35 (1) | 23.18 (1) | 7.1 (1) |
| novice | 26 | 23 (1) | 5 (1) | 220 (1) | 3844 (1) | not measured | not measured | 2 (1) | 37.33 (1) | 7.1 (1) |
| novice | 27 | 10 (1) | 4 (1) | 105 (1) | 1656 (1) | not measured | 5.5 (1) | 7.3 (1) | 27.45 (1) | 7.1 (1) |
| novice | 28 | 7 (1) | 4 (1) | 32 (1) | 1024 (1) | not measured | not measured | 7.3 (1) | 16.87 (1) | 7.1 (1) |
| average | 1 | 9.5 (10) | 0.5 (10) | 0 (10) | 13 (10) | not measured | not measured | not measured | 10.25 (10) | not measured |
| average | 2 | 9 (10) | 1 (10) | 0 (10) | 14 (10) | not measured | 5.5 (1) | not measured | 11.82 (10) | not measured |
| average | 3 | 8 (10) | 3 (10) | 0 (10) | 12 (10) | not measured | 0.55 (1) | not measured | 13.54 (10) | 7.1 (3) |
| average | 4 | 4.5 (10) | 1 (10) | 0 (10) | 12 (10) | not measured | 2.78 (1) | 7.3 (2) | 8.73 (10) | not measured |
| average | 5 | 2.5 (10) | 2.5 (10) | 0 (10) | 24 (10) | not measured | 1.65 (1) | not measured | 14.87 (10) | 7.1 (3) |
| average | 6 | 9 (10) | 2.5 (10) | 0 (10) | 29 (10) | not measured | 2.35 (1) | 7.3 (1) | 13.97 (10) | 7.1 (4) |
| average | 7 | 5 (10) | 3.5 (10) | 18 (10) | 37 (10) | not measured | 0.1 (1) | 7.3 (4) | 13.3 (10) | 7.1 (1) |
| average | 8 | 7 (10) | 4.5 (10) | 26.5 (10) | 47 (10) | not measured | 4.42 (1) | 7.3 (5) | 12.75 (10) | 7.1 (3) |
| average | 9 | 10.5 (10) | 7.5 (10) | 49 (10) | 90.5 (10) | not measured | not measured | 7.3 (7) | 20.45 (10) | 7.1 (5) |
| average | 10 | 5 (10) | 7.5 (10) | 56 (10) | 63 (10) | not measured | 4.77 (2) | 7.3 (5) | 16.93 (10) | 7.1 (6) |
| average | 11 | 11.5 (10) | 7 (10) | 45.5 (10) | 72 (10) | not measured | 1.28 (3) | 6.13 (6) | 20.47 (10) | 7.1 (6) |
| average | 12 | 7.5 (10) | 5.5 (10) | 81.5 (10) | 116.5 (10) | not measured | 4.77 (3) | 7.3 (6) | 19.9 (10) | 7.1 (7) |
| average | 13 | 12 (10) | 8.5 (10) | 60 (10) | 138 (10) | not measured | 4.75 (3) | 7.56 (6) | 19.2 (10) | 7.1 (7) |
| average | 14 | 14.5 (10) | 8.5 (10) | 82 (10) | 125.5 (10) | not measured | 5.63 (2) | 7.3 (7) | 21.6 (10) | 7.1 (5) |
| average | 15 | 7 (10) | 12 (10) | 68.5 (10) | 80.5 (10) | not measured | 5.15 (4) | 7.3 (7) | 21.36 (10) | 7.1 (7) |
| average | 16 | 23 (9) | 12 (9) | 109 (9) | 179 (9) | not measured | 4.01 (4) | 7.3 (8) | 21.33 (9) | 7.1 (5) |
| average | 17 | 12 (9) | 9 (9) | 96 (9) | 153 (9) | not measured | 5.5 (5) | 7.3 (8) | 22.72 (9) | 7.1 (4) |
| average | 18 | 13 (9) | 9 (9) | 114 (9) | 168 (9) | not measured | 5.08 (5) | 7.3 (8) | 26 (9) | 7.1 (6) |
| average | 19 | 10 (9) | 9 (9) | 70 (9) | 170 (9) | not measured | 5.5 (6) | 7.3 (7) | 19.07 (9) | 7.1 (4) |
| average | 20 | 4 (9) | 10 (9) | 46 (9) | 375 (9) | not measured | 5.5 (5) | 7.3 (6) | 15.18 (9) | 7.1 (5) |
| average | 21 | 13 (9) | 8 (9) | 74 (9) | 562 (9) | not measured | 3.07 (5) | 7.3 (8) | 22.22 (9) | 7.1 (3) |
| average | 22 | 15 (9) | 9 (9) | 86 (9) | 1238 (9) | not measured | 6.65 (7) | 7.3 (6) | 22.58 (9) | 7.1 (4) |
| average | 23 | 13 (9) | 10 (9) | 70 (9) | 1086 (9) | not measured | 5.5 (7) | 10.95 (6) | 26.48 (9) | 7.1 (5) |
| average | 24 | 15 (8) | 11.5 (8) | 79.5 (8) | 1315 (8) | not measured | 4.12 (7) | 7.3 (7) | 25.4 (8) | 7.1 (3) |
| average | 25 | 8 (8) | 7.5 (8) | 125 (8) | 1295 (8) | not measured | 5.5 (7) | 7.3 (6) | 22.31 (8) | 7.1 (1) |
| average | 26 | 11.5 (8) | 11 (8) | 125.5 (8) | 2339 (8) | not measured | 4.75 (8) | 10.83 (7) | 26.75 (8) | 7.1 (4) |
| average | 27 | 11.5 (8) | 14 (8) | 146 (8) | 2873.5 (8) | not measured | 5.5 (7) | 7.3 (7) | 31.37 (8) | 14.2 (3) |
| average | 28 | 14.5 (8) | 15 (8) | 147.5 (8) | 3045 (8) | not measured | 5.5 (7) | 10.95 (6) | 36.75 (8) | 7.1 (4) |
| average | 29 | 15.5 (8) | 15 (8) | 84.5 (8) | 1554 (8) | not measured | 5.5 (5) | 7.3 (7) | 26.13 (8) | 7.1 (6) |
| average | 30 | 13 (8) | 20 (8) | 117.5 (8) | 2208.5 (8) | not measured | 4.97 (6) | 7.3 (7) | 29.96 (8) | 7.1 (6) |
| average | 31 | 13 (7) | 12 (7) | 177 (7) | 4248 (7) | 0 (1) | 6.17 (5) | 11.96 (8) | 34.83 (7) | 7.1 (7) |
| average | 32 | 10 (7) | 16 (7) | 148 (7) | 2289 (7) | 0 (1) | 3.42 (7) | 7.3 (7) | 33.38 (7) | 7.1 (6) |
| average | 33 | 10 (7) | 12 (7) | 115 (7) | 2314 (7) | 0 (1) | 5.61 (6) | 7.3 (6) | 25.23 (7) | 7.1 (6) |
| average | 34 | 18 (7) | 11 (7) | 172 (7) | 2806 (7) | not measured | 5.5 (7) | 7.3 (5) | 29.3 (7) | 7.1 (5) |
| average | 35 | 13 (7) | 20 (7) | 112 (7) | 1164 (7) | not measured | 3.7 (6) | 7.3 (7) | 27.18 (7) | 7.1 (4) |
| average | 36 | 17 (7) | 18 (7) | 116 (7) | 2288 (7) | not measured | 5.75 (6) | 7.3 (7) | 32.87 (7) | 7.1 (4) |
| average | 37 | 12 (7) | 16 (7) | 129 (7) | 3062 (7) | not measured | 5.58 (7) | 7.3 (7) | 30.65 (7) | 7.1 (5) |
| average | 38 | 21 (7) | 18 (7) | 153 (7) | 3433 (7) | not measured | 5.61 (6) | 7.3 (7) | 33.95 (7) | 7.1 (6) |
| average | 39 | 11 (7) | 18 (7) | 127 (7) | 2136 (7) | not measured | 8.11 (6) | 14.6 (7) | 35.98 (7) | 7.1 (4) |
| average | 40 | 15 (7) | 12 (7) | 81 (7) | 1877 (7) | not measured | 5.5 (6) | 7.3 (7) | 31.12 (7) | 7.1 (3) |
| expert | 1 | 7.5 (10) | 1 (10) | 0 (10) | 13 (10) | not measured | not measured | not measured | 9.95 (10) | not measured |
| expert | 2 | 7.5 (10) | 1 (10) | 0 (10) | 14 (10) | not measured | 5.5 (1) | not measured | 11.58 (10) | not measured |
| expert | 3 | 6 (10) | 1.5 (10) | 0 (10) | 12 (10) | not measured | 4.03 (1) | 6.08 (1) | 12.68 (10) | 7.1 (1) |
| expert | 4 | 5.5 (10) | 2 (10) | 0 (10) | 12 (10) | not measured | 0.23 (1) | 7.3 (1) | 11.98 (10) | 7.1 (1) |
| expert | 5 | 2 (10) | 5 (10) | 0 (10) | 25 (10) | not measured | 2.27 (1) | 8.22 (2) | 16.79 (10) | 10.65 (2) |
| expert | 6 | 6 (10) | 5 (10) | 0 (10) | 32 (10) | not measured | 3.27 (1) | 7.3 (3) | 12.61 (10) | 7.1 (3) |
| expert | 7 | 5 (10) | 2.5 (10) | 18 (10) | 39.5 (10) | not measured | 2.72 (1) | 7.3 (3) | 11.27 (10) | 7.1 (2) |
| expert | 8 | 6 (10) | 5 (10) | 32 (10) | 42.5 (10) | not measured | 2.97 (1) | 7.3 (4) | 14.14 (10) | 7.1 (3) |
| expert | 9 | 9.5 (10) | 10 (10) | 39.5 (10) | 95 (10) | not measured | 1.38 (1) | 7.3 (6) | 17.38 (10) | 7.1 (6) |
| expert | 10 | 4 (10) | 12.5 (10) | 54.5 (10) | 70 (10) | not measured | 4.35 (2) | 7.3 (6) | 13.8 (10) | 7.1 (5) |
| expert | 11 | 8 (10) | 6 (10) | 48.5 (10) | 72.5 (10) | not measured | 4.25 (3) | 7.3 (6) | 16.23 (10) | 7.1 (6) |
| expert | 12 | 10.5 (10) | 7.5 (10) | 99.5 (10) | 148.5 (10) | not measured | 3.58 (3) | 7.3 (8) | 17.73 (10) | 7.1 (8) |
| expert | 13 | 11 (10) | 13.5 (10) | 125 (10) | 169 (10) | not measured | 0.83 (3) | 14.6 (7) | 23.72 (10) | 7.1 (7) |
| expert | 14 | 6 (10) | 8 (10) | 101 (10) | 106.5 (10) | not measured | 3.78 (3) | 7.3 (8) | 20.8 (10) | 7.1 (4) |
| expert | 15 | 6 (10) | 13.5 (10) | 60 (10) | 117 (10) | not measured | 5.1 (3) | 7.3 (9) | 15.88 (10) | 7.1 (8) |
| expert | 16 | 10.5 (10) | 11.5 (10) | 106.5 (10) | 180.5 (10) | not measured | 5.5 (3) | 7.3 (10) | 22.5 (10) | 7.1 (8) |
| expert | 17 | 7 (10) | 15.5 (10) | 102 (10) | 192 (10) | not measured | 5.52 (6) | 14.6 (9) | 19.91 (10) | 7.1 (5) |
| expert | 18 | 9 (10) | 7 (10) | 119.5 (10) | 180.5 (10) | not measured | 4.15 (6) | 7.3 (8) | 18.66 (10) | 7.1 (4) |
| expert | 19 | 10 (10) | 13.5 (10) | 88.5 (10) | 565.5 (10) | not measured | 5.22 (8) | 7.3 (10) | 24.49 (10) | 7.1 (5) |
| expert | 20 | 5.5 (10) | 12.5 (10) | 86 (10) | 461.5 (10) | not measured | 4.23 (7) | 7.3 (8) | 17 (10) | 7.1 (6) |
| expert | 21 | 12 (10) | 10 (10) | 75 (10) | 1184 (10) | not measured | 4.15 (9) | 7.3 (8) | 17.66 (10) | 10.65 (2) |
| expert | 22 | 15.5 (10) | 11.5 (10) | 118 (10) | 1796.5 (10) | not measured | 3.67 (10) | 7.3 (8) | 27.72 (10) | 7.1 (3) |
| expert | 23 | 9.5 (10) | 14.5 (10) | 109 (10) | 2371 (10) | not measured | 4.6 (9) | 7.3 (9) | 23.17 (10) | 7.1 (5) |
| expert | 24 | 14 (10) | 19.5 (10) | 115.5 (10) | 1358 (10) | not measured | 5.5 (10) | 7.3 (9) | 28.4 (10) | 7.1 (5) |
| expert | 25 | 11 (10) | 18 (10) | 90.5 (10) | 1574 (10) | not measured | 5.12 (9) | 7.3 (9) | 21.1 (10) | 7.1 (6) |
| expert | 26 | 10 (10) | 14 (10) | 107.5 (10) | 2354 (10) | not measured | 5.5 (10) | 7.3 (9) | 19.8 (10) | 7.1 (1) |
| expert | 27 | 15.5 (10) | 16.5 (10) | 101.5 (10) | 2686 (10) | not measured | 5.5 (9) | 7.3 (10) | 24.99 (10) | 7.1 (3) |
| expert | 28 | 13.5 (10) | 17 (10) | 178 (10) | 3292 (10) | not measured | 5.5 (9) | 7.3 (10) | 28.27 (10) | 7.1 (4) |
| expert | 29 | 12.5 (10) | 13.5 (10) | 121 (10) | 2425.5 (10) | not measured | 5.5 (9) | 7.3 (8) | 23.77 (10) | 7.1 (5) |
| expert | 30 | 9 (10) | 16 (10) | 77 (10) | 2074 (10) | not measured | 5.5 (7) | 7.3 (10) | 22.55 (10) | 7.1 (6) |
| expert | 31 | 16 (10) | 14 (10) | 136 (10) | 3061 (10) | not measured | 5.79 (8) | 7.3 (9) | 27.34 (10) | 7.1 (3) |
| expert | 32 | 21 (10) | 17.5 (10) | 153 (10) | 3918.5 (10) | not measured | 5.5 (10) | 7.3 (10) | 28.45 (10) | 7.1 (3) |
| expert | 33 | 12 (10) | 16.5 (10) | 154 (10) | 3392.5 (10) | not measured | 5.52 (8) | 7.3 (10) | 29.75 (10) | 7.1 (4) |
| expert | 34 | 15 (10) | 15 (10) | 129.5 (10) | 3771.5 (10) | not measured | 5.06 (8) | 7.3 (9) | 22.08 (10) | 7.1 (7) |
| expert | 35 | 14 (10) | 19.5 (10) | 88.5 (10) | 2030.5 (10) | not measured | 5.9 (10) | 7.3 (8) | 21.62 (10) | 7.1 (1) |
| expert | 36 | 18.5 (10) | 15.5 (10) | 143 (10) | 3767 (10) | not measured | 1.42 (9) | 7.3 (10) | 31.65 (10) | 7.1 (5) |
| expert | 37 | 17 (10) | 20 (10) | 116 (10) | 2978.5 (10) | not measured | 6.68 (10) | 7.3 (9) | 25.13 (10) | 7.1 (2) |
| expert | 38 | 19 (10) | 22.5 (10) | 146 (10) | 2394.5 (10) | not measured | 6.03 (10) | 7.3 (9) | 32.92 (10) | 7.1 (5) |
| expert | 39 | 13 (10) | 19 (10) | 123 (10) | 3089.5 (10) | not measured | 5.52 (10) | 14.6 (9) | 31.2 (10) | 7.1 (4) |
| expert | 40 | 17.5 (10) | 24 (10) | 115.5 (10) | 2497 (10) | not measured | 5.5 (10) | 7.3 (8) | 29.66 (10) | 7.1 (4) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 28 | 2.21 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 1 | 40 | 1.21 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 2 | 40 | 1.21 | ghost_tonnage → ghost_ohm → ghost_dent → stat_speed_10 → stat_hp_max_10 → weapon_machine_pistol → weapon_gatling → stat_guard_meter_10 → weapon_pistol → weapon_katana → weapon_plasma_sword → stat_damage_10 → stat_hp_max_25 → ghost_kerf → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → weapon_flamethrower → weapon_rocket_launcher → weapon_chainsaw → weapon_gloria → stat_damage_25 → stat_regen_10 → weapon_electro_baton → weapon_plasma_rifle → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 3 | 40 | 1.21 | stat_hp_max_10 → weapon_pistol → weapon_electro_baton → stat_speed_10 → stat_guard_meter_10 → weapon_plasma_sword → weapon_gatling → stat_speed_25 → ghost_kerf → weapon_rocket_launcher → ghost_ohm → stat_regen_10 → stat_hp_max_25 → weapon_flamethrower → stat_regen_25 → stat_damage_10 → weapon_chainsaw → ghost_dent → ghost_tonnage → stat_guard_meter_25 → weapon_katana → stat_damage_25 → weapon_machine_pistol → weapon_plasma_rifle → weapon_gloria → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 1 | 40 | 1.11 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 2 | 40 | 1.11 | ghost_tonnage → ghost_ohm → ghost_dent → stat_speed_10 → stat_hp_max_10 → weapon_machine_pistol → weapon_gatling → stat_guard_meter_10 → weapon_pistol → weapon_katana → weapon_plasma_sword → stat_damage_10 → stat_hp_max_25 → ghost_kerf → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → weapon_flamethrower → weapon_rocket_launcher → weapon_chainsaw → weapon_gloria → stat_damage_25 → stat_regen_10 → weapon_electro_baton → weapon_plasma_rifle → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 3 | 40 | 1.11 | stat_hp_max_10 → weapon_pistol → weapon_electro_baton → stat_speed_10 → stat_guard_meter_10 → weapon_plasma_sword → weapon_gatling → stat_speed_25 → ghost_kerf → weapon_rocket_launcher → ghost_ohm → stat_regen_10 → stat_hp_max_25 → weapon_flamethrower → stat_regen_25 → stat_damage_10 → weapon_chainsaw → ghost_dent → ghost_tonnage → stat_guard_meter_25 → weapon_katana → stat_damage_25 → weapon_machine_pistol → weapon_plasma_rifle → weapon_gloria → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=expert --pick=greedy --controls=wheel --waves=40 |
