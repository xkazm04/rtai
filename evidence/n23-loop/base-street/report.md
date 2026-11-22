# Gauntlet run report

29 of 30 runs accepted. Average-profile waves 1 (10.35 s), 2 (11.87 s), 4 (11.97 s), 5 (14.92 s), 8 (23.62 s), 9 (31.72 s), 10 (20.65 s), 11 (29.67 s), 12 (35.95 s), 13 (33.58 s), 14 (37.35 s), 15 (38.8 s), 16 (37.62 s), 17 (35.97 s), 18 (39.48 s), 19 (35.28 s), 20 (30.55 s), 21 (39.4 s), 22 (38.98 s), 23 (35.63 s), 24 (39.25 s), 25 (34.65 s), 26 (40.63 s), 27 (44.81 s), 28 (43.33 s), 29 (39.13 s), 30 (39.16 s), 31 (48.96 s), 32 (50.9 s), 33 (52.51 s), 34 (49.7 s), 35 (39.36 s), 36 (48.48 s), 37 (48.59 s), 38 (52.76 s), 39 (48.8 s), 40 (46.38 s) fell outside 12–18 s for ordinary waves and 25–30 s for boss waves.

Live gauntlet batch · detached @ ccfc29df081a (dirty) · 2026-11-22T04:02:05.674Z.

Stalled runs by profile: novice 0, average 0, expert 0.

Capped alive by profile: novice 0, average 0, expert 0.

## Death-wave score

Censored runs contribute their last reached wave as a lower bound to the median and spread.

| Profile | Target | Median wave | P25–P75 | Min–max | Deaths / censored |
| --- | --- | --- | --- | --- | --- |
| novice | 6 | 14 | 11–24 | 10–29 | 10 / 0 |
| average | 12 | 40 | 40–40 | 22–40 | 1 / 8 |
| expert | 20 | 40 | 40–40 | 40–40 | 0 / 10 |

## Profile separation

Targets require a median gap of 3 waves and a later death on at least 75% of shared seeds with the same controls and pick policy. Unresolved censored pairs stay in the denominator.

| Profiles | Observed median gap | Later / shared seeds | Confirmed later share | Unresolved | Verdict |
| --- | --- | --- | --- | --- | --- |
| novice → average | 26 | 9 / 9 | 100% | 0 | separated |
| novice → expert | 26 | 10 / 10 | 100% | 0 | separated |
| average → expert | 0 | 1 / 9 | 11.11% | 8 | undetermined |

## Waves per run

A timed-out wave can clear later. Active counts include each started roster still fighting at death.

| Profile | Seed | Outcome | Timed-out waves | Active waves at death |
| --- | --- | --- | --- | --- |
| novice | 1 | died on 29 | 1 | 1 |
| novice | 2 | died on 10 | 0 | 1 |
| novice | 3 | died on 13 | 0 | 1 |
| novice | 4 | died on 15 | 0 | 1 |
| novice | 5 | died on 23 | 0 | 1 |
| novice | 6 | died on 24 | 0 | 1 |
| novice | 7 | died on 29 | 0 | 1 |
| novice | 8 | died on 10 | 0 | 1 |
| novice | 9 | died on 13 | 0 | 1 |
| novice | 10 | died on 11 | 0 | 1 |
| average | 1 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 2 | died on 22 | 0 | 1 |
| average | 3 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 4 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 5 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 7 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 8 | censored at the wave limit 40 (≥ 40) | 0 | — |
| average | 9 | censored at the wave limit 40 (≥ 40) | 0 | — |
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
| novice | 6 | 10 / 10 | 17.66 | 15.62…21.25 | 15.2…25.15 | — |
| novice | 7 | 10 / 10 | 19.65 | 16.08…21 | 13.28…27.22 | — |
| novice | 8 | 10 / 10 | 22.86 | 21.73…31.73 | 19.97…150.55 | — |
| novice | 9 | 10 / 10 | 28.02 | 25.58…37.53 | 24.63…58.9 | — |
| novice | 10 | 8 / 10 | 20.38 | 18.93…24.23 | 11.25…27.67 | — |
| novice | 11 | 7 / 8 | 31.9 | 25.6…33.05 | 24.1…38.37 | — |
| novice | 12 | 7 / 7 | 48.02 | 33.23…49.25 | 25.28…56.87 | — |
| novice | 13 | 5 / 7 | 48.83 | 42.13…53.85 | 25.12…53.85 | — |
| novice | 14 | 5 / 5 | 38.72 | 29.62…48.27 | 26.78…50.27 | — |
| novice | 15 | 4 / 5 | 28.39 | 27.98…41.2 | 23.52…41.2 | — |
| novice | 16 | 4 / 4 | 42.42 | 38.3…60.37 | 35.15…60.37 | — |
| novice | 17 | 4 / 4 | 41.2 | 30.37…55.48 | 28.58…55.48 | — |
| novice | 18 | 4 / 4 | 45.99 | 41.75…61.18 | 38.25…61.18 | — |
| novice | 19 | 4 / 4 | 44.27 | 33.92…67.72 | 31.67…67.72 | — |
| novice | 20 | 4 / 4 | 34.22 | 33.55…35.98 | 33.05…35.98 | — |
| novice | 21 | 4 / 4 | 30.09 | 25.08…44.65 | 23.03…44.65 | — |
| novice | 22 | 4 / 4 | 40.81 | 39.33…61.4 | 26.22…61.4 | — |
| novice | 23 | 3 / 4 | 50.05 | 45.42…54.27 | 45.42…54.27 | — |
| novice | 24 | 2 / 3 | 55.88 | 38.43…73.33 | 38.43…73.33 | — |
| novice | 25 | 2 / 2 | 33.38 | 30.78…35.98 | 30.78…35.98 | — |
| novice | 26 | 2 / 2 | 44.1 | 43.97…44.23 | 43.97…44.23 | — |
| novice | 27 | 2 / 2 | 40.96 | 35.08…46.83 | 35.08…46.83 | — |
| novice | 28 | 2 / 2 | 62.25 | 58.27…66.23 | 58.27…66.23 | — |
| novice | 29 | 0 / 2 | not measured | not measured | not measured | — |
| average | 1 | 9 / 9 | 10.35 | 9.93…10.5 | 9.07…10.9 | miss |
| average | 2 | 9 / 9 | 11.87 | 11.22…12.63 | 9.5…17.28 | miss |
| average | 3 | 9 / 9 | 15.37 | 12.17…15.85 | 8.83…23.53 | within target |
| average | 4 | 9 / 9 | 11.97 | 8.82…13.07 | 8.12…16.22 | miss |
| average | 5 | 9 / 9 | 14.92 | 11.32…21.92 | 9.88…24.27 | miss |
| average | 6 | 9 / 9 | 17.1 | 16.55…19.08 | 12.25…21.27 | within target |
| average | 7 | 9 / 9 | 16.43 | 12.35…18.15 | 9.8…27.87 | within target |
| average | 8 | 9 / 9 | 23.62 | 18.05…23.98 | 17.25…27.9 | miss |
| average | 9 | 9 / 9 | 31.72 | 30.95…32.82 | 19.05…37.97 | miss |
| average | 10 | 9 / 9 | 20.65 | 19.98…28.2 | 12.05…51.73 | miss |
| average | 11 | 9 / 9 | 29.67 | 21.13…32.7 | 13.18…42.78 | miss |
| average | 12 | 9 / 9 | 35.95 | 25.4…38.02 | 21.05…45.68 | miss |
| average | 13 | 9 / 9 | 33.58 | 29.72…38.23 | 27.03…50.07 | miss |
| average | 14 | 9 / 9 | 37.35 | 28.67…44.78 | 19.95…52.7 | miss |
| average | 15 | 9 / 9 | 38.8 | 27.95…43.98 | 19.88…51.32 | miss |
| average | 16 | 9 / 9 | 37.62 | 32.37…39.1 | 28…49.97 | miss |
| average | 17 | 9 / 9 | 35.97 | 32.73…41.35 | 19.1…46.15 | miss |
| average | 18 | 9 / 9 | 39.48 | 36.07…45.6 | 30.75…56.12 | miss |
| average | 19 | 9 / 9 | 35.28 | 33.17…39.93 | 28.55…54.17 | miss |
| average | 20 | 9 / 9 | 30.55 | 23.55…35.57 | 19.9…63.28 | miss |
| average | 21 | 9 / 9 | 39.4 | 26.87…41.42 | 23.4…65.13 | miss |
| average | 22 | 8 / 9 | 38.98 | 33.32…47.85 | 29.67…49.3 | miss |
| average | 23 | 8 / 8 | 35.63 | 31.77…42.67 | 28.93…47.37 | miss |
| average | 24 | 8 / 8 | 39.25 | 36.53…52.33 | 25.38…54.75 | miss |
| average | 25 | 8 / 8 | 34.65 | 30.03…42.98 | 26.3…44.2 | miss |
| average | 26 | 8 / 8 | 40.63 | 38.12…53.58 | 30.43…57.08 | miss |
| average | 27 | 8 / 8 | 44.81 | 41.13…59.37 | 37.05…64.15 | miss |
| average | 28 | 8 / 8 | 43.33 | 39.45…55.92 | 29.62…58.75 | miss |
| average | 29 | 8 / 8 | 39.13 | 36.68…44.63 | 26.95…55.67 | miss |
| average | 30 | 8 / 8 | 39.16 | 30.68…50.77 | 26.78…56.85 | miss |
| average | 31 | 8 / 8 | 48.96 | 43.68…60.58 | 28.22…69 | miss |
| average | 32 | 8 / 8 | 50.9 | 45.37…63.6 | 33.45…63.83 | miss |
| average | 33 | 8 / 8 | 52.51 | 44.22…58.77 | 38.95…59.15 | miss |
| average | 34 | 8 / 8 | 49.7 | 47.23…58.32 | 44.98…58.65 | miss |
| average | 35 | 8 / 8 | 39.36 | 36.47…45.52 | 33.33…50.53 | miss |
| average | 36 | 8 / 8 | 48.48 | 47.18…72.73 | 28.47…74.17 | miss |
| average | 37 | 8 / 8 | 48.59 | 44.42…52.93 | 34.35…59.05 | miss |
| average | 38 | 8 / 8 | 52.76 | 50.3…57.85 | 31.33…61.22 | miss |
| average | 39 | 8 / 8 | 48.8 | 45.5…60.65 | 38.6…70.37 | miss |
| average | 40 | 8 / 8 | 46.38 | 43.72…52.5 | 36.42…59.2 | miss |
| expert | 1 | 10 / 10 | 9.95 | 9.33…11.3 | 8.5…14.02 | — |
| expert | 2 | 10 / 10 | 12.34 | 10.23…16.97 | 8.88…20.95 | — |
| expert | 3 | 10 / 10 | 12.68 | 10.88…13.9 | 7.6…21.97 | — |
| expert | 4 | 10 / 10 | 12.04 | 9.08…14.35 | 6.95…23.18 | — |
| expert | 5 | 10 / 10 | 18.25 | 14.23…23.75 | 2.75…48.9 | — |
| expert | 6 | 10 / 10 | 18.38 | 15.22…20.67 | 7.62…24.78 | — |
| expert | 7 | 10 / 10 | 11.72 | 11.05…20.18 | 7.9…28.37 | — |
| expert | 8 | 10 / 10 | 17.98 | 14.22…21.9 | 13.02…29.5 | — |
| expert | 9 | 10 / 10 | 27.96 | 23…35.85 | 15.83…38.92 | — |
| expert | 10 | 10 / 10 | 25.95 | 20.97…33.65 | 10.93…47.25 | — |
| expert | 11 | 10 / 10 | 25.6 | 20.25…34.75 | 17.4…40.3 | — |
| expert | 12 | 10 / 10 | 35.02 | 30.3…42.58 | 25.18…45.5 | — |
| expert | 13 | 10 / 10 | 36.09 | 30.18…39.05 | 26.85…47.95 | — |
| expert | 14 | 10 / 10 | 30.09 | 23.4…34.93 | 14.8…55.22 | — |
| expert | 15 | 10 / 10 | 34.34 | 24.77…44.83 | 21.82…62.2 | — |
| expert | 16 | 10 / 10 | 36.23 | 28.93…46.13 | 26.55…53.33 | — |
| expert | 17 | 10 / 10 | 40.71 | 30.28…44.27 | 24.1…52.68 | — |
| expert | 18 | 10 / 10 | 30.33 | 28.2…41.1 | 24.02…60.7 | — |
| expert | 19 | 10 / 10 | 29.98 | 24.25…40.6 | 23.38…56.13 | — |
| expert | 20 | 10 / 10 | 36.32 | 30.83…39.5 | 19.32…42.13 | — |
| expert | 21 | 10 / 10 | 30.33 | 26.02…39.58 | 18.7…43.38 | — |
| expert | 22 | 10 / 10 | 39.92 | 37.2…54.32 | 27.83…61.87 | — |
| expert | 23 | 10 / 10 | 43.49 | 36.53…45.72 | 29.3…60.23 | — |
| expert | 24 | 10 / 10 | 38.5 | 31.88…44.75 | 20.32…46.23 | — |
| expert | 25 | 10 / 10 | 37.08 | 32.67…50.75 | 25.53…58.47 | — |
| expert | 26 | 10 / 10 | 33.42 | 29.57…37.35 | 25.02…62.42 | — |
| expert | 27 | 10 / 10 | 44.96 | 38.1…47.28 | 26.97…60.6 | — |
| expert | 28 | 10 / 10 | 43.52 | 38.95…49.17 | 34.95…62.75 | — |
| expert | 29 | 10 / 10 | 39.16 | 30.42…48.53 | 24.42…75.28 | — |
| expert | 30 | 10 / 10 | 37.35 | 33.33…48.92 | 28.98…58.87 | — |
| expert | 31 | 10 / 10 | 38.82 | 34.38…45.6 | 30.35…51.4 | — |
| expert | 32 | 10 / 10 | 41.06 | 40.28…43.03 | 30.27…47.8 | — |
| expert | 33 | 10 / 10 | 44.63 | 39.7…53.15 | 31.25…57.48 | — |
| expert | 34 | 10 / 10 | 50.12 | 37.32…52.52 | 25.9…59.8 | — |
| expert | 35 | 10 / 10 | 43.18 | 39.2…45 | 35.85…64.05 | — |
| expert | 36 | 10 / 10 | 53.41 | 39.12…56.8 | 29.32…67.75 | — |
| expert | 37 | 10 / 10 | 46.17 | 43.85…58.37 | 31.93…63.02 | — |
| expert | 38 | 10 / 10 | 51.77 | 44.52…53.95 | 36.2…63.07 | — |
| expert | 39 | 10 / 10 | 46.24 | 38.18…48.55 | 31.37…56.08 | — |
| expert | 40 | 10 / 10 | 49.98 | 42.63…59.48 | 34.18…67.93 | — |

## Deaths by profile

Each wave and killer is followed by its recorded death count. Killers are ordered by frequency.

| Profile | Runs | Deaths | Stalled | Capped alive | Other accepted without death | Death wave × count | Top killers × count | Unattributed deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 10 | 10 | 0 | 0 | 0 | 10 × 2, 11 × 1, 13 × 2, 15 × 1, 23 × 1, 24 × 1, 29 × 2 | shield_robot × 5, rocket × 3, stomp × 2 | 0 |
| average | 10 | 1 | 0 | 0 | 8 | 22 × 1 | shield_robot × 1 | 0 |
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
| novice | 1–10 | 100 / 100 | 8.41 | 0.38 | 10 | 90.08 | 5.34 | 100 | 7 | 0 | 2 | 1.1 | 1 | 1.1 | 1 | 1 |
| novice | 11–20 | 52 / 52 | 58.56 | 1.44 | 11 | 64.21 | 52.06 | 100 | 10 | 0 | 6 | 1.375 | 1.1 | 1.375 | 1.1 | 1.1 |
| novice | 21–30 | 25 / 25 | 84.6 | 1.65 | 13.75 | 54.06 | 74.51 | 100 | 14 | 0 | 7 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| novice | 31+ | 0 / 0 | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured | not measured |
| average | 1–10 | 90 / 90 | 3.33 | 0.18 | 10 | 97.26 | 2.94 | 100 | 6 | 2 | 3 | 1.1 | 1 | 1.1 | 1 | 1 |
| average | 11–20 | 90 / 90 | 34.68 | 1 | 11 | 79.82 | 29.55 | 100 | 9 | 19 | 10 | 1.25 | 1.1 | 1.375 | 1.1 | 1.1 |
| average | 21–30 | 82 / 82 | 32.25 | 0.84 | 13.75 | 82.41 | 29.78 | 100 | 13 | 29.5 | 10.5 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| average | 31+ | 80 / 80 | 54.98 | 1.14 | 13.75 | 73.29 | 52.12 | 100 | 15.5 | 45.5 | 14.5 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 1–10 | 100 / 100 | 2.7 | 0.16 | 10 | 97.76 | 2.4 | 100 | 5 | 14.5 | 4 | 1.1 | 1 | 1.1 | 1 | 1 |
| expert | 11–20 | 100 / 100 | 23.96 | 0.75 | 11 | 87.84 | 21.7 | 100 | 8 | 110 | 11 | 1.375 | 1.1 | 1.375 | 1.1 | 1.1 |
| expert | 21–30 | 100 / 100 | 23.93 | 0.66 | 13.75 | 88.54 | 23.51 | 100 | 13 | 128 | 15 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |
| expert | 31+ | 100 / 100 | 43.52 | 0.86 | 13.75 | 78.61 | 43.52 | 100 | 14 | 157 | 18 | 1.375 | 1.375 | 1.375 | 1.375 | 1.375 |

## Enemy presence and wave time

Confirmed kills count only named death records. Time share divides seconds in waves containing the enemy by all timed waves with a measured roster. Several enemies can share a wave. Parentheses give the timed wave count.

| Enemy | Confirmed kills | Killer weapon × count | Share of wave time | Present median s (n) | Absent median s (n) |
| --- | --- | --- | --- | --- | --- |
| contractor | 0 | — | 86.96% | 35.9 (748) | 19.81 (160) |
| patrol_cop | 0 | — | 89.7% | 34.22 (810) | 31.23 (98) |
| riot_cop | 0 | — | 85.6% | 36.2 (727) | 19.88 (181) |
| robot_gunner | 0 | — | 83.65% | 38.3 (661) | 15.75 (247) |
| robot_thug | 0 | — | 81.92% | 37.41 (656) | 16.21 (252) |
| rocket_trooper | 3 | rocket × 3 | 84.71% | 35.27 (727) | 19.9 (181) |
| sentry_turret | 0 | — | 82.72% | 37.53 (659) | 15.68 (249) |
| shield_robot | 6 | — | 78.66% | 40.12 (584) | 17.55 (324) |
| swat | 0 | — | 83.64% | 36.47 (706) | 19.98 (202) |
| war_machine | 2 | stomp × 2 | 19.19% | 33.33 (176) | 34 (732) |

## Moves

Uses count recorded activations by profile and wave number. The game omits zero counts. Times are medians in seconds, with timed wave counts in parentheses. Carry applies to all waves.

| Profile | Wave | Move | Enemy | Recorded uses | Observed waves | Uses per wave | With enemy s (n) | Without enemy s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | All | ohm_short_circuit | sentry_turret | 0 | 177 | 0 | 33.05 (93) | 14.6 (74) |
| novice | All | tonnage_armour_crack | war_machine | 0 | 177 | 0 | 20.38 (28) | 25.15 (139) |
| novice | All | kerf_blink_behind | shield_robot | 0 | 177 | 0 | 38.72 (69) | 16.41 (98) |
| novice | All | overkill_carry | all waves | 0 | 177 | 0 | 24.63 (167) | — |
| novice | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 9.48 (10) |
| novice | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 9.48 (10) |
| novice | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 9.48 (10) |
| novice | 1 | overkill_carry | all waves | 0 | 10 | 0 | 9.48 (10) | — |
| novice | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 12.63 (10) |
| novice | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 12.63 (10) |
| novice | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 12.63 (10) |
| novice | 2 | overkill_carry | all waves | 0 | 10 | 0 | 12.63 (10) | — |
| novice | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 15.14 (10) |
| novice | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 15.14 (10) |
| novice | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 15.14 (10) |
| novice | 3 | overkill_carry | all waves | 0 | 10 | 0 | 15.14 (10) | — |
| novice | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 11.81 (10) |
| novice | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 11.81 (10) |
| novice | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 11.81 (10) |
| novice | 4 | overkill_carry | all waves | 0 | 10 | 0 | 11.81 (10) | — |
| novice | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 13.05 (10) |
| novice | 5 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 13.05 (10) | — |
| novice | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 13.05 (10) |
| novice | 5 | overkill_carry | all waves | 0 | 10 | 0 | 13.05 (10) | — |
| novice | 6 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 15.92 (7) | 19.03 (3) |
| novice | 6 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.66 (10) |
| novice | 6 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.66 (10) |
| novice | 6 | overkill_carry | all waves | 0 | 10 | 0 | 17.66 (10) | — |
| novice | 7 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 20.56 (6) | 17.5 (4) |
| novice | 7 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 19.65 (10) |
| novice | 7 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 19.65 (10) |
| novice | 7 | overkill_carry | all waves | 0 | 10 | 0 | 19.65 (10) | — |
| novice | 8 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 22.86 (10) | — |
| novice | 8 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 22.86 (10) |
| novice | 8 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 22.86 (10) |
| novice | 8 | overkill_carry | all waves | 0 | 10 | 0 | 22.86 (10) | — |
| novice | 9 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 29.93 (7) | 26.12 (3) |
| novice | 9 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 28.02 (10) |
| novice | 9 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 31.22 (8) | 27.28 (2) |
| novice | 9 | overkill_carry | all waves | 0 | 10 | 0 | 28.02 (10) | — |
| novice | 10 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 20.65 (4) | 20.18 (4) |
| novice | 10 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 20.38 (8) | — |
| novice | 10 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 21.43 (5) | 19.33 (3) |
| novice | 10 | overkill_carry | all waves | 0 | 10 | 0 | 20.38 (8) | — |
| novice | 11 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 31.34 (6) | 38.37 (1) |
| novice | 11 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 31.9 (7) |
| novice | 11 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 31.34 (4) | 33.05 (3) |
| novice | 11 | overkill_carry | all waves | 0 | 8 | 0 | 31.9 (7) | — |
| novice | 12 | ohm_short_circuit | sentry_turret | 0 | 7 | 0 | 48.02 (7) | — |
| novice | 12 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 48.02 (7) |
| novice | 12 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | 48.02 (7) | — |
| novice | 12 | overkill_carry | all waves | 0 | 7 | 0 | 48.02 (7) | — |
| novice | 13 | ohm_short_circuit | sentry_turret | 0 | 7 | 0 | 53.85 (1) | 45.48 (4) |
| novice | 13 | tonnage_armour_crack | war_machine | 0 | 7 | 0 | — | 48.83 (5) |
| novice | 13 | kerf_blink_behind | shield_robot | 0 | 7 | 0 | 48.83 (5) | — |
| novice | 13 | overkill_carry | all waves | 0 | 7 | 0 | 48.83 (5) | — |
| novice | 14 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | 38.72 (5) | — |
| novice | 14 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | — | 38.72 (5) |
| novice | 14 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 43.49 (4) | 26.78 (1) |
| novice | 14 | overkill_carry | all waves | 0 | 5 | 0 | 38.72 (5) | — |
| novice | 15 | ohm_short_circuit | sentry_turret | 0 | 5 | 0 | 26.16 (2) | 34.59 (2) |
| novice | 15 | tonnage_armour_crack | war_machine | 0 | 5 | 0 | 28.39 (4) | — |
| novice | 15 | kerf_blink_behind | shield_robot | 0 | 5 | 0 | 27.98 (3) | 28.8 (1) |
| novice | 15 | overkill_carry | all waves | 0 | 5 | 0 | 28.39 (4) | — |
| novice | 16 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 46.53 (3) | 35.15 (1) |
| novice | 16 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 42.42 (4) |
| novice | 16 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 42.42 (4) | — |
| novice | 16 | overkill_carry | all waves | 0 | 4 | 0 | 42.42 (4) | — |
| novice | 17 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 41.2 (4) | — |
| novice | 17 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 41.2 (4) |
| novice | 17 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 53.76 (2) | 29.48 (2) |
| novice | 17 | overkill_carry | all waves | 0 | 4 | 0 | 41.2 (4) | — |
| novice | 18 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 45.99 (2) | 49.72 (2) |
| novice | 18 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 45.99 (4) |
| novice | 18 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 50.23 (3) | 41.75 (1) |
| novice | 18 | overkill_carry | all waves | 0 | 4 | 0 | 45.99 (4) | — |
| novice | 19 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 44.27 (4) | — |
| novice | 19 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 44.27 (4) |
| novice | 19 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 54.63 (3) | 31.67 (1) |
| novice | 19 | overkill_carry | all waves | 0 | 4 | 0 | 44.27 (4) | — |
| novice | 20 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 34.22 (4) | — |
| novice | 20 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | 34.22 (4) | — |
| novice | 20 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 33.55 (3) | 35.98 (1) |
| novice | 20 | overkill_carry | all waves | 0 | 4 | 0 | 34.22 (4) | — |
| novice | 21 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 30.09 (4) | — |
| novice | 21 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 30.09 (4) |
| novice | 21 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 35.1 (3) | 23.03 (1) |
| novice | 21 | overkill_carry | all waves | 0 | 4 | 0 | 30.09 (4) | — |
| novice | 22 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 40.81 (4) | — |
| novice | 22 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 40.81 (4) |
| novice | 22 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 40.81 (4) | — |
| novice | 22 | overkill_carry | all waves | 0 | 4 | 0 | 40.81 (4) | — |
| novice | 23 | ohm_short_circuit | sentry_turret | 0 | 4 | 0 | 50.05 (3) | — |
| novice | 23 | tonnage_armour_crack | war_machine | 0 | 4 | 0 | — | 50.05 (3) |
| novice | 23 | kerf_blink_behind | shield_robot | 0 | 4 | 0 | 50.05 (3) | — |
| novice | 23 | overkill_carry | all waves | 0 | 4 | 0 | 50.05 (3) | — |
| novice | 24 | ohm_short_circuit | sentry_turret | 0 | 3 | 0 | 55.88 (2) | — |
| novice | 24 | tonnage_armour_crack | war_machine | 0 | 3 | 0 | — | 55.88 (2) |
| novice | 24 | kerf_blink_behind | shield_robot | 0 | 3 | 0 | 55.88 (2) | — |
| novice | 24 | overkill_carry | all waves | 0 | 3 | 0 | 55.88 (2) | — |
| novice | 25 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 33.38 (2) | — |
| novice | 25 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | 33.38 (2) | — |
| novice | 25 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 33.38 (2) | — |
| novice | 25 | overkill_carry | all waves | 0 | 2 | 0 | 33.38 (2) | — |
| novice | 26 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 44.1 (2) | — |
| novice | 26 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 44.1 (2) |
| novice | 26 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 43.97 (1) | 44.23 (1) |
| novice | 26 | overkill_carry | all waves | 0 | 2 | 0 | 44.1 (2) | — |
| novice | 27 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 40.96 (2) | — |
| novice | 27 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 40.96 (2) |
| novice | 27 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 46.83 (1) | 35.08 (1) |
| novice | 27 | overkill_carry | all waves | 0 | 2 | 0 | 40.96 (2) | — |
| novice | 28 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | 62.25 (2) | — |
| novice | 28 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | 62.25 (2) |
| novice | 28 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | 62.25 (2) | — |
| novice | 28 | overkill_carry | all waves | 0 | 2 | 0 | 62.25 (2) | — |
| novice | 29 | ohm_short_circuit | sentry_turret | 0 | 2 | 0 | — | — |
| novice | 29 | tonnage_armour_crack | war_machine | 0 | 2 | 0 | — | — |
| novice | 29 | kerf_blink_behind | shield_robot | 0 | 2 | 0 | — | — |
| novice | 29 | overkill_carry | all waves | 0 | 2 | 0 | — | — |
| average | All | ohm_short_circuit | sentry_turret | 0 | 342 | 0 | 38.6 (259) | 15.8 (82) |
| average | All | tonnage_armour_crack | war_machine | 0 | 342 | 0 | 32.77 (68) | 36.68 (273) |
| average | All | kerf_blink_behind | shield_robot | 0 | 342 | 0 | 40.7 (233) | 17.81 (108) |
| average | All | overkill_carry | all waves | 0 | 342 | 0 | 36.07 (341) | — |
| average | 1 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 10.35 (9) |
| average | 1 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 10.35 (9) |
| average | 1 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 10.35 (9) |
| average | 1 | overkill_carry | all waves | 0 | 9 | 0 | 10.35 (9) | — |
| average | 2 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 11.87 (9) |
| average | 2 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 11.87 (9) |
| average | 2 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 11.87 (9) |
| average | 2 | overkill_carry | all waves | 0 | 9 | 0 | 11.87 (9) | — |
| average | 3 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 15.37 (9) |
| average | 3 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 15.37 (9) |
| average | 3 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 15.37 (9) |
| average | 3 | overkill_carry | all waves | 0 | 9 | 0 | 15.37 (9) | — |
| average | 4 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 11.97 (9) |
| average | 4 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 11.97 (9) |
| average | 4 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 11.97 (9) |
| average | 4 | overkill_carry | all waves | 0 | 9 | 0 | 11.97 (9) | — |
| average | 5 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | — | 14.92 (9) |
| average | 5 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | 14.92 (9) | — |
| average | 5 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 14.92 (9) |
| average | 5 | overkill_carry | all waves | 0 | 9 | 0 | 14.92 (9) | — |
| average | 6 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 18.71 (6) | 13.43 (3) |
| average | 6 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 17.1 (9) |
| average | 6 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 17.1 (9) |
| average | 6 | overkill_carry | all waves | 0 | 9 | 0 | 17.1 (9) | — |
| average | 7 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 18.15 (5) | 14.39 (4) |
| average | 7 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 16.43 (9) |
| average | 7 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 16.43 (9) |
| average | 7 | overkill_carry | all waves | 0 | 9 | 0 | 16.43 (9) | — |
| average | 8 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 23.62 (9) | — |
| average | 8 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 23.62 (9) |
| average | 8 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | — | 23.62 (9) |
| average | 8 | overkill_carry | all waves | 0 | 9 | 0 | 23.62 (9) | — |
| average | 9 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 31.72 (7) | 31.87 (2) |
| average | 9 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 31.72 (9) |
| average | 9 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 32.75 (7) | 25.38 (2) |
| average | 9 | overkill_carry | all waves | 0 | 9 | 0 | 31.72 (9) | — |
| average | 10 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 23.62 (6) | 20.43 (3) |
| average | 10 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | 20.65 (9) | — |
| average | 10 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 28.2 (5) | 20.32 (4) |
| average | 10 | overkill_carry | all waves | 0 | 9 | 0 | 20.65 (9) | — |
| average | 11 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 30.65 (8) | 28.08 (1) |
| average | 11 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 29.67 (9) |
| average | 11 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 31.63 (5) | 24.61 (4) |
| average | 11 | overkill_carry | all waves | 0 | 9 | 0 | 29.67 (9) | — |
| average | 12 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 35.95 (9) | — |
| average | 12 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 35.95 (9) |
| average | 12 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 35.95 (9) | — |
| average | 12 | overkill_carry | all waves | 0 | 9 | 0 | 35.95 (9) | — |
| average | 13 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 31.65 (4) | 35.07 (5) |
| average | 13 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 33.58 (9) |
| average | 13 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 33.58 (9) | — |
| average | 13 | overkill_carry | all waves | 0 | 9 | 0 | 33.58 (9) | — |
| average | 14 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 37.35 (9) | — |
| average | 14 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 37.35 (9) |
| average | 14 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 38.42 (7) | 20.77 (2) |
| average | 14 | overkill_carry | all waves | 0 | 9 | 0 | 37.35 (9) | — |
| average | 15 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 38.8 (5) | 36.84 (4) |
| average | 15 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | 38.8 (9) | — |
| average | 15 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 42.95 (7) | 29.34 (2) |
| average | 15 | overkill_carry | all waves | 0 | 9 | 0 | 38.8 (9) | — |
| average | 16 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 37.39 (8) | 38.48 (1) |
| average | 16 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 37.62 (9) |
| average | 16 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 38.05 (8) | 28 (1) |
| average | 16 | overkill_carry | all waves | 0 | 9 | 0 | 37.62 (9) | — |
| average | 17 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 38.65 (8) | 34.23 (1) |
| average | 17 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 35.97 (9) |
| average | 17 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 37.78 (6) | 35.97 (3) |
| average | 17 | overkill_carry | all waves | 0 | 9 | 0 | 35.97 (9) | — |
| average | 18 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 36.63 (6) | 45.6 (3) |
| average | 18 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 39.48 (9) |
| average | 18 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 39.48 (9) | — |
| average | 18 | overkill_carry | all waves | 0 | 9 | 0 | 39.48 (9) | — |
| average | 19 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 35.28 (9) | — |
| average | 19 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 35.28 (9) |
| average | 19 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 35.28 (7) | 32.35 (2) |
| average | 19 | overkill_carry | all waves | 0 | 9 | 0 | 35.28 (9) | — |
| average | 20 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 33.06 (6) | 23.55 (3) |
| average | 20 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | 30.55 (9) | — |
| average | 20 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 31.52 (6) | 23.95 (3) |
| average | 20 | overkill_carry | all waves | 0 | 9 | 0 | 30.55 (9) | — |
| average | 21 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 39.4 (9) | — |
| average | 21 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 39.4 (9) |
| average | 21 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 41.15 (5) | 28.08 (4) |
| average | 21 | overkill_carry | all waves | 0 | 9 | 0 | 39.4 (9) | — |
| average | 22 | ohm_short_circuit | sentry_turret | 0 | 9 | 0 | 40.7 (7) | 37.25 (1) |
| average | 22 | tonnage_armour_crack | war_machine | 0 | 9 | 0 | — | 38.98 (8) |
| average | 22 | kerf_blink_behind | shield_robot | 0 | 9 | 0 | 38.98 (8) | — |
| average | 22 | overkill_carry | all waves | 0 | 9 | 0 | 38.98 (8) | — |
| average | 23 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 35.63 (8) | — |
| average | 23 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 35.63 (8) |
| average | 23 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 35.63 (8) | — |
| average | 23 | overkill_carry | all waves | 0 | 8 | 0 | 35.63 (8) | — |
| average | 24 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 39.25 (8) | — |
| average | 24 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 39.25 (8) |
| average | 24 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 39.25 (8) | — |
| average | 24 | overkill_carry | all waves | 0 | 8 | 0 | 39.25 (8) | — |
| average | 25 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 34.65 (8) | — |
| average | 25 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | 34.65 (8) | — |
| average | 25 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 34.65 (8) | — |
| average | 25 | overkill_carry | all waves | 0 | 8 | 0 | 34.65 (8) | — |
| average | 26 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 40.63 (8) | — |
| average | 26 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 40.63 (8) |
| average | 26 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 38.17 (7) | 46.7 (1) |
| average | 26 | overkill_carry | all waves | 0 | 8 | 0 | 40.63 (8) | — |
| average | 27 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 41.42 (7) | 52.32 (1) |
| average | 27 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 44.81 (8) |
| average | 27 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 50.26 (6) | 37.35 (2) |
| average | 27 | overkill_carry | all waves | 0 | 8 | 0 | 44.81 (8) | — |
| average | 28 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 43.33 (8) | — |
| average | 28 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 43.33 (8) |
| average | 28 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 43.33 (8) | — |
| average | 28 | overkill_carry | all waves | 0 | 8 | 0 | 43.33 (8) | — |
| average | 29 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 36.97 (7) | 44.63 (1) |
| average | 29 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 39.13 (8) |
| average | 29 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 39.13 (8) | — |
| average | 29 | overkill_carry | all waves | 0 | 8 | 0 | 39.13 (8) | — |
| average | 30 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 45.27 (7) | 33.05 (1) |
| average | 30 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | 39.16 (8) | — |
| average | 30 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 41.11 (6) | 37.51 (2) |
| average | 30 | overkill_carry | all waves | 0 | 8 | 0 | 39.16 (8) | — |
| average | 31 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 48.3 (7) | 49.62 (1) |
| average | 31 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 48.96 (8) |
| average | 31 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 48.96 (8) | — |
| average | 31 | overkill_carry | all waves | 0 | 8 | 0 | 48.96 (8) | — |
| average | 32 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 50.9 (8) | — |
| average | 32 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 50.9 (8) |
| average | 32 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 55.57 (7) | 45.37 (1) |
| average | 32 | overkill_carry | all waves | 0 | 8 | 0 | 50.9 (8) | — |
| average | 33 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 51.4 (7) | 59.15 (1) |
| average | 33 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 52.51 (8) |
| average | 33 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 52.51 (8) | — |
| average | 33 | overkill_carry | all waves | 0 | 8 | 0 | 52.51 (8) | — |
| average | 34 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 48.47 (7) | 58.32 (1) |
| average | 34 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 49.7 (8) |
| average | 34 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 49.7 (8) | — |
| average | 34 | overkill_carry | all waves | 0 | 8 | 0 | 49.7 (8) | — |
| average | 35 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 39.36 (8) | — |
| average | 35 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | 39.36 (8) | — |
| average | 35 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 39.36 (8) | — |
| average | 35 | overkill_carry | all waves | 0 | 8 | 0 | 39.36 (8) | — |
| average | 36 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 48.48 (8) | — |
| average | 36 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 48.48 (8) |
| average | 36 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 48.48 (8) | — |
| average | 36 | overkill_carry | all waves | 0 | 8 | 0 | 48.48 (8) | — |
| average | 37 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 48.59 (8) | — |
| average | 37 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 48.59 (8) |
| average | 37 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 46.13 (7) | 52.93 (1) |
| average | 37 | overkill_carry | all waves | 0 | 8 | 0 | 48.59 (8) | — |
| average | 38 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 52.76 (8) | — |
| average | 38 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 52.76 (8) |
| average | 38 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 52.76 (8) | — |
| average | 38 | overkill_carry | all waves | 0 | 8 | 0 | 52.76 (8) | — |
| average | 39 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 48.8 (8) | — |
| average | 39 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | — | 48.8 (8) |
| average | 39 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 50.47 (7) | 38.6 (1) |
| average | 39 | overkill_carry | all waves | 0 | 8 | 0 | 48.8 (8) | — |
| average | 40 | ohm_short_circuit | sentry_turret | 0 | 8 | 0 | 46.38 (8) | — |
| average | 40 | tonnage_armour_crack | war_machine | 0 | 8 | 0 | 46.38 (8) | — |
| average | 40 | kerf_blink_behind | shield_robot | 0 | 8 | 0 | 47.27 (7) | 36.42 (1) |
| average | 40 | overkill_carry | all waves | 0 | 8 | 0 | 46.38 (8) | — |
| expert | All | ohm_short_circuit | sentry_turret | 0 | 400 | 0 | 37.37 (307) | 16.97 (93) |
| expert | All | tonnage_armour_crack | war_machine | 0 | 400 | 0 | 36.32 (80) | 34.94 (320) |
| expert | All | kerf_blink_behind | shield_robot | 0 | 400 | 0 | 39.72 (282) | 17.98 (118) |
| expert | All | overkill_carry | all waves | 0 | 400 | 0 | 35.27 (400) | — |
| expert | 1 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 9.95 (10) |
| expert | 1 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 9.95 (10) |
| expert | 1 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 9.95 (10) |
| expert | 1 | overkill_carry | all waves | 0 | 10 | 0 | 9.95 (10) | — |
| expert | 2 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 12.34 (10) |
| expert | 2 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 12.34 (10) |
| expert | 2 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 12.34 (10) |
| expert | 2 | overkill_carry | all waves | 0 | 10 | 0 | 12.34 (10) | — |
| expert | 3 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 12.68 (10) |
| expert | 3 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 12.68 (10) |
| expert | 3 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 12.68 (10) |
| expert | 3 | overkill_carry | all waves | 0 | 10 | 0 | 12.68 (10) | — |
| expert | 4 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 12.04 (10) |
| expert | 4 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 12.04 (10) |
| expert | 4 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 12.04 (10) |
| expert | 4 | overkill_carry | all waves | 0 | 10 | 0 | 12.04 (10) | — |
| expert | 5 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | — | 18.25 (10) |
| expert | 5 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 18.25 (10) | — |
| expert | 5 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 18.25 (10) |
| expert | 5 | overkill_carry | all waves | 0 | 10 | 0 | 18.25 (10) | — |
| expert | 6 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 19.02 (7) | 13.77 (3) |
| expert | 6 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 18.38 (10) |
| expert | 6 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 18.38 (10) |
| expert | 6 | overkill_carry | all waves | 0 | 10 | 0 | 18.38 (10) | — |
| expert | 7 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 18.43 (6) | 11.32 (4) |
| expert | 7 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 11.72 (10) |
| expert | 7 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 11.72 (10) |
| expert | 7 | overkill_carry | all waves | 0 | 10 | 0 | 11.72 (10) | — |
| expert | 8 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 17.98 (10) | — |
| expert | 8 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 17.98 (10) |
| expert | 8 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | — | 17.98 (10) |
| expert | 8 | overkill_carry | all waves | 0 | 10 | 0 | 17.98 (10) | — |
| expert | 9 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 32.82 (7) | 23.43 (3) |
| expert | 9 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 27.96 (10) |
| expert | 9 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 27.63 (8) | 28.46 (2) |
| expert | 9 | overkill_carry | all waves | 0 | 10 | 0 | 27.96 (10) | — |
| expert | 10 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 28.43 (6) | 20.49 (4) |
| expert | 10 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 25.95 (10) | — |
| expert | 10 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 27.92 (6) | 25.95 (4) |
| expert | 10 | overkill_carry | all waves | 0 | 10 | 0 | 25.95 (10) | — |
| expert | 11 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 27.5 (9) | 20.65 (1) |
| expert | 11 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 25.6 (10) |
| expert | 11 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 29.2 (6) | 19.52 (4) |
| expert | 11 | overkill_carry | all waves | 0 | 10 | 0 | 25.6 (10) | — |
| expert | 12 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 35.02 (10) | — |
| expert | 12 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 35.02 (10) |
| expert | 12 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 35.02 (10) | — |
| expert | 12 | overkill_carry | all waves | 0 | 10 | 0 | 35.02 (10) | — |
| expert | 13 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 35.27 (5) | 36.92 (5) |
| expert | 13 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 36.09 (10) |
| expert | 13 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 36.09 (10) | — |
| expert | 13 | overkill_carry | all waves | 0 | 10 | 0 | 36.09 (10) | — |
| expert | 14 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 30.09 (10) | — |
| expert | 14 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 30.09 (10) |
| expert | 14 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 33.52 (8) | 17.57 (2) |
| expert | 14 | overkill_carry | all waves | 0 | 10 | 0 | 30.09 (10) | — |
| expert | 15 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 30.43 (6) | 40.77 (4) |
| expert | 15 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 34.34 (10) | — |
| expert | 15 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 34.93 (7) | 24.42 (3) |
| expert | 15 | overkill_carry | all waves | 0 | 10 | 0 | 34.34 (10) | — |
| expert | 16 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 37.25 (9) | 28.15 (1) |
| expert | 16 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 36.23 (10) |
| expert | 16 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 37.25 (9) | 28.93 (1) |
| expert | 16 | overkill_carry | all waves | 0 | 10 | 0 | 36.23 (10) | — |
| expert | 17 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 41.65 (9) | 39.77 (1) |
| expert | 17 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 40.71 (10) |
| expert | 17 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 41.65 (7) | 30.28 (3) |
| expert | 17 | overkill_carry | all waves | 0 | 10 | 0 | 40.71 (10) | — |
| expert | 18 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 28.52 (7) | 41.1 (3) |
| expert | 18 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 30.33 (10) |
| expert | 18 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 30.38 (9) | 25.62 (1) |
| expert | 18 | overkill_carry | all waves | 0 | 10 | 0 | 30.33 (10) | — |
| expert | 19 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 29.98 (10) | — |
| expert | 19 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 29.98 (10) |
| expert | 19 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 29.98 (8) | 35.89 (2) |
| expert | 19 | overkill_carry | all waves | 0 | 10 | 0 | 29.98 (10) | — |
| expert | 20 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 36.47 (7) | 32.52 (3) |
| expert | 20 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 36.32 (10) | — |
| expert | 20 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 36.17 (7) | 36.47 (3) |
| expert | 20 | overkill_carry | all waves | 0 | 10 | 0 | 36.32 (10) | — |
| expert | 21 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 30.33 (10) | — |
| expert | 21 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 30.33 (10) |
| expert | 21 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 32.39 (6) | 29.72 (4) |
| expert | 21 | overkill_carry | all waves | 0 | 10 | 0 | 30.33 (10) | — |
| expert | 22 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 40.1 (9) | 38.68 (1) |
| expert | 22 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 39.92 (10) |
| expert | 22 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 39.92 (10) | — |
| expert | 22 | overkill_carry | all waves | 0 | 10 | 0 | 39.92 (10) | — |
| expert | 23 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 43.49 (10) | — |
| expert | 23 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 43.49 (10) |
| expert | 23 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 43.49 (10) | — |
| expert | 23 | overkill_carry | all waves | 0 | 10 | 0 | 43.49 (10) | — |
| expert | 24 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 36.2 (9) | 46.23 (1) |
| expert | 24 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 38.5 (10) |
| expert | 24 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 38.5 (10) | — |
| expert | 24 | overkill_carry | all waves | 0 | 10 | 0 | 38.5 (10) | — |
| expert | 25 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 37.08 (10) | — |
| expert | 25 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 37.08 (10) | — |
| expert | 25 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 37.08 (10) | — |
| expert | 25 | overkill_carry | all waves | 0 | 10 | 0 | 37.08 (10) | — |
| expert | 26 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 33.42 (10) | — |
| expert | 26 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 33.42 (10) |
| expert | 26 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 34.43 (9) | 29.57 (1) |
| expert | 26 | overkill_carry | all waves | 0 | 10 | 0 | 33.42 (10) | — |
| expert | 27 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 44.77 (9) | 45.15 (1) |
| expert | 27 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 44.96 (10) |
| expert | 27 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 45.26 (8) | 27.93 (2) |
| expert | 27 | overkill_carry | all waves | 0 | 10 | 0 | 44.96 (10) | — |
| expert | 28 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 43.52 (10) | — |
| expert | 28 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 43.52 (10) |
| expert | 28 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 43.52 (10) | — |
| expert | 28 | overkill_carry | all waves | 0 | 10 | 0 | 43.52 (10) | — |
| expert | 29 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 38.85 (9) | 39.47 (1) |
| expert | 29 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 39.16 (10) |
| expert | 29 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 39.16 (10) | — |
| expert | 29 | overkill_carry | all waves | 0 | 10 | 0 | 39.16 (10) | — |
| expert | 30 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 39.43 (9) | 29.3 (1) |
| expert | 30 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 37.35 (10) | — |
| expert | 30 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 41.64 (8) | 34.21 (2) |
| expert | 30 | overkill_carry | all waves | 0 | 10 | 0 | 37.35 (10) | — |
| expert | 31 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 35.43 (9) | 49.88 (1) |
| expert | 31 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 38.82 (10) |
| expert | 31 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 38.82 (10) | — |
| expert | 31 | overkill_carry | all waves | 0 | 10 | 0 | 38.82 (10) | — |
| expert | 32 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 41.06 (10) | — |
| expert | 32 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 41.06 (10) |
| expert | 32 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 41.05 (9) | 43.95 (1) |
| expert | 32 | overkill_carry | all waves | 0 | 10 | 0 | 41.06 (10) | — |
| expert | 33 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 43.47 (9) | 57.48 (1) |
| expert | 33 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 44.63 (10) |
| expert | 33 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 44.63 (10) | — |
| expert | 33 | overkill_carry | all waves | 0 | 10 | 0 | 44.63 (10) | — |
| expert | 34 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 48.78 (8) | 51.64 (2) |
| expert | 34 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 50.12 (10) |
| expert | 34 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 50.12 (10) | — |
| expert | 34 | overkill_carry | all waves | 0 | 10 | 0 | 50.12 (10) | — |
| expert | 35 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 44.27 (9) | 39.68 (1) |
| expert | 35 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 43.18 (10) | — |
| expert | 35 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 43.18 (10) | — |
| expert | 35 | overkill_carry | all waves | 0 | 10 | 0 | 43.18 (10) | — |
| expert | 36 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 53.41 (10) | — |
| expert | 36 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 53.41 (10) |
| expert | 36 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 53.41 (10) | — |
| expert | 36 | overkill_carry | all waves | 0 | 10 | 0 | 53.41 (10) | — |
| expert | 37 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 45.88 (9) | 60.18 (1) |
| expert | 37 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 46.17 (10) |
| expert | 37 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 46.45 (9) | 31.93 (1) |
| expert | 37 | overkill_carry | all waves | 0 | 10 | 0 | 46.17 (10) | — |
| expert | 38 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 51.77 (10) | — |
| expert | 38 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 51.77 (10) |
| expert | 38 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 51.77 (10) | — |
| expert | 38 | overkill_carry | all waves | 0 | 10 | 0 | 51.77 (10) | — |
| expert | 39 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 46.24 (10) | — |
| expert | 39 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | — | 46.24 (10) |
| expert | 39 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 45.33 (9) | 47.95 (1) |
| expert | 39 | overkill_carry | all waves | 0 | 10 | 0 | 46.24 (10) | — |
| expert | 40 | ohm_short_circuit | sentry_turret | 0 | 10 | 0 | 49.98 (10) | — |
| expert | 40 | tonnage_armour_crack | war_machine | 0 | 10 | 0 | 49.98 (10) | — |
| expert | 40 | kerf_blink_behind | shield_robot | 0 | 10 | 0 | 51.42 (9) | 42.63 (1) |
| expert | 40 | overkill_carry | all waves | 0 | 10 | 0 | 49.98 (10) | — |

## Offered bonuses

Each run contributes once per item. Takers start at their first take and never-takers at their first offer. Post-pick seconds are a median within each run. Waves survived count confirmed completions. The final wave counts only with a recorded clear or post-wave offer and no death. Within the same profile, controls and pick wave, pair runs by seed rank without replacement. The difference is the median of take minus decline across matched pairs. CI95 uses 4,000 paired bootstrap resamples. The A/A floor is the larger absolute CI endpoint for even versus odd decliner seeds, falling back to all offered runs. A CI touching zero or a difference within the floor earns “noise”. The effect needs two matched pairs and the floor needs six A/A pairs. These observational comparisons can reflect the rest of the loadout.

| Bonus | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ghost_dent | waves survived | 19 (23) | 10.5 (2) | 1 | -13 | not measured | not measured (3, all offered) | too few pairs |
| ghost_dent | wave s | 42.28 (23) | 27.1 (2) | 1 | -13.27 | not measured | not measured (3, all offered) | too few pairs |
| ghost_kerf | waves survived | 22 (24) | 8 (2) | 1 | 19 | not measured | not measured (3, all offered) | too few pairs |
| ghost_kerf | wave s | 40.94 (24) | 16.18 (2) | 1 | 15.06 | not measured | not measured (3, all offered) | too few pairs |
| ghost_ohm | waves survived | 28 (28) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_ohm | wave s | 37.5 (28) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| ghost_tonnage | waves survived | 29 (28) | not measured | 0 | not measured | not measured | 18 (6, all offered) | insufficient data |
| ghost_tonnage | wave s | 37.05 (27) | not measured | 0 | not measured | not measured | 9.86 (6, all offered) | insufficient data |
| stat_damage_10 | waves survived | 27.5 (26) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_damage_10 | wave s | 36.02 (26) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| stat_damage_25 | waves survived | 20 (25) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_damage_25 | wave s | 38.02 (25) | not measured | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_guard_meter_10 | waves survived | 28 (28) | 7 (1) | 1 | 14 | not measured | 13 (7, all offered) | insufficient data |
| stat_guard_meter_10 | wave s | 36.92 (28) | 17.6 (1) | 1 | 15.45 | not measured | 13.23 (7, all offered) | insufficient data |
| stat_guard_meter_25 | waves survived | 20 (22) | 3 (3) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_guard_meter_25 | wave s | 42.14 (22) | 33.05 (3) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_hp_max_10 | waves survived | 32 (29) | not measured | 0 | not measured | not measured | 2 (6, all offered) | insufficient data |
| stat_hp_max_10 | wave s | 37 (29) | not measured | 0 | not measured | not measured | 4.69 (6, all offered) | insufficient data |
| stat_hp_max_25 | waves survived | 26 (25) | 1 (2) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_hp_max_25 | wave s | 38.81 (25) | 36.67 (1) | 0 | not measured | not measured | not measured (4, all offered) | too few pairs |
| stat_regen_10 | waves survived | 26.5 (26) | 8 (3) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_10 | wave s | 39.9 (24) | 19.97 (3) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_regen_25 | waves survived | 18.5 (24) | 2 (3) | 1 | 10 | not measured | not measured (0, all offered) | too few pairs |
| stat_regen_25 | wave s | 41.54 (24) | 40.53 (3) | 1 | 2.11 | not measured | not measured (0, all offered) | too few pairs |
| stat_speed_10 | waves survived | 29 (28) | 1 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_speed_10 | wave s | 37.04 (28) | 24.63 (1) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| stat_speed_25 | waves survived | 18.5 (26) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| stat_speed_25 | wave s | 41.35 (25) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_chainsaw | waves survived | 17 (25) | 4 (4) | 1 | 14 | not measured | not measured (5, all offered) | too few pairs |
| weapon_chainsaw | wave s | 42.35 (24) | 21.69 (4) | 1 | 15.02 | not measured | not measured (5, all offered) | too few pairs |
| weapon_electro_baton | waves survived | 18 (24) | 8 (5) | 1 | -1 | not measured | not measured (2, all offered) | too few pairs |
| weapon_electro_baton | wave s | 40.05 (24) | 17.85 (5) | 1 | 2.81 | not measured | not measured (2, all offered) | too few pairs |
| weapon_flamethrower | waves survived | 18.5 (22) | 7 (5) | 1 | 10 | not measured | not measured (3, all offered) | too few pairs |
| weapon_flamethrower | wave s | 41.96 (22) | 22.92 (5) | 1 | 14.26 | not measured | not measured (3, all offered) | too few pairs |
| weapon_gatling | waves survived | 22 (28) | 0 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gatling | wave s | 39.47 (27) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| weapon_gloria | waves survived | 17 (23) | 6 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_gloria | wave s | 44.04 (22) | 24.52 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_hand_cannon | waves survived | 16 (23) | 5.5 (6) | 1 | 10 | not measured | not measured (4, all offered) | too few pairs |
| weapon_hand_cannon | wave s | 42.85 (22) | 26.12 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| weapon_katana | waves survived | 17 (22) | 8 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_katana | wave s | 42.63 (22) | 25.02 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_machine_pistol | waves survived | 19 (23) | 7 (5) | 1 | -3 | not measured | not measured (5, all offered) | too few pairs |
| weapon_machine_pistol | wave s | 39.63 (23) | 27.24 (5) | 1 | -2.2 | not measured | not measured (5, all offered) | too few pairs |
| weapon_pistol | waves survived | 24 (27) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_pistol | wave s | 38.68 (26) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| weapon_plasma_rifle | waves survived | 14 (22) | 6.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_plasma_rifle | wave s | 43.92 (22) | 23.42 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| weapon_plasma_sword | waves survived | 21 (25) | 8 (3) | 1 | -8 | not measured | not measured (3, all offered) | too few pairs |
| weapon_plasma_sword | wave s | 40.23 (25) | 21.37 (3) | 1 | -10.63 | not measured | not measured (3, all offered) | too few pairs |
| weapon_rocket_launcher | waves survived | 25 (26) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| weapon_rocket_launcher | wave s | 40.26 (26) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |

## Offered weapons by ref

Weapon refs combine offers of any bonus for that weapon. The same matching and noise rules apply.

| Weapon ref | After pick | Took median (n) | Declined median (n) | Pairs | Paired Δ | CI95 | A/A floor (pairs, source) | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| chainsaw | waves survived | 17 (25) | 4 (4) | 1 | 14 | not measured | not measured (5, all offered) | too few pairs |
| chainsaw | wave s | 42.35 (24) | 21.69 (4) | 1 | 15.02 | not measured | not measured (5, all offered) | too few pairs |
| electro_baton | waves survived | 18 (24) | 8 (5) | 1 | -1 | not measured | not measured (2, all offered) | too few pairs |
| electro_baton | wave s | 40.05 (24) | 17.85 (5) | 1 | 2.81 | not measured | not measured (2, all offered) | too few pairs |
| flamethrower | waves survived | 18.5 (22) | 7 (5) | 1 | 10 | not measured | not measured (3, all offered) | too few pairs |
| flamethrower | wave s | 41.96 (22) | 22.92 (5) | 1 | 14.26 | not measured | not measured (3, all offered) | too few pairs |
| gatling | waves survived | 22 (28) | 0 (1) | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gatling | wave s | 39.47 (27) | not measured | 0 | not measured | not measured | not measured (5, all offered) | too few pairs |
| gloria | waves survived | 17 (23) | 6 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| gloria | wave s | 44.04 (22) | 24.52 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| hand_cannon | waves survived | 16 (23) | 5.5 (6) | 1 | 10 | not measured | not measured (4, all offered) | too few pairs |
| hand_cannon | wave s | 42.85 (22) | 26.12 (5) | 0 | not measured | not measured | not measured (3, all offered) | too few pairs |
| katana | waves survived | 17 (22) | 8 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| katana | wave s | 42.63 (22) | 25.02 (6) | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| machine_pistol | waves survived | 19 (23) | 7 (5) | 1 | -3 | not measured | not measured (5, all offered) | too few pairs |
| machine_pistol | wave s | 39.63 (23) | 27.24 (5) | 1 | -2.2 | not measured | not measured (5, all offered) | too few pairs |
| pistol | waves survived | 24 (27) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| pistol | wave s | 38.68 (26) | not measured | 0 | not measured | not measured | not measured (0, all offered) | too few pairs |
| plasma_rifle | waves survived | 14 (22) | 6.5 (6) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| plasma_rifle | wave s | 43.92 (22) | 23.42 (5) | 0 | not measured | not measured | not measured (1, all offered) | too few pairs |
| plasma_sword | waves survived | 21 (25) | 8 (3) | 1 | -8 | not measured | not measured (3, all offered) | too few pairs |
| plasma_sword | wave s | 40.23 (25) | 21.37 (3) | 1 | -10.63 | not measured | not measured (3, all offered) | too few pairs |
| rocket_launcher | waves survived | 25 (26) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |
| rocket_launcher | wave s | 40.26 (26) | not measured | 0 | not measured | not measured | not measured (2, all offered) | too few pairs |

## Combat telemetry

Values are per-wave medians, with measured observations in parentheses. There is no rate because rounds count gunfire while contacts include claws, melee and blasts and count a killing wound again.

| Profile | Wave | Guard deflects (n) | Rolls (n) | gun rounds | damaging contacts (all sources) | kerf s (n) | ohm s (n) | rivet s (n) | tonnage s (n) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 7.5 (10) | 0.5 (10) | 0 (10) | 13 (10) | not measured | not measured | 9.48 (10) | not measured |
| novice | 2 | 7.5 (10) | 1 (10) | 0 (10) | 14 (10) | 5.5 (1) | not measured | 11.23 (10) | not measured |
| novice | 3 | 6.5 (10) | 1.5 (10) | 0 (10) | 12 (10) | 5.5 (1) | not measured | 14.4 (10) | 3.78 (1) |
| novice | 4 | 6.5 (10) | 1 (10) | 0 (10) | 12 (10) | not measured | 7.3 (1) | 11.8 (10) | not measured |
| novice | 5 | 1.5 (10) | 0.5 (10) | 0 (10) | 22 (10) | 2.37 (1) | not measured | 10.46 (10) | 7.1 (3) |
| novice | 6 | 6.5 (10) | 2 (10) | 0 (10) | 34 (10) | 2.5 (1) | 7.3 (2) | 15.52 (10) | 7.1 (2) |
| novice | 7 | 7.5 (10) | 2 (10) | 21.5 (10) | 42.5 (10) | 1.5 (1) | 7.3 (2) | 17.5 (10) | 7.1 (1) |
| novice | 8 | 7.5 (10) | 3 (10) | 64.5 (10) | 37.5 (10) | 5.28 (1) | 4.03 (2) | 22 (10) | 7.1 (4) |
| novice | 9 | 11.5 (10) | 5.5 (10) | 54.5 (10) | 92 (10) | 2.08 (1) | 7.3 (4) | 25.36 (10) | 7.1 (6) |
| novice | 10 | 6.5 (10) | 3 (10) | 30 (10) | 50 (10) | 5.5 (2) | 6.63 (3) | 11.83 (10) | 7.1 (5) |
| novice | 11 | 8.5 (8) | 4 (8) | 32 (8) | 76.5 (8) | 2.77 (2) | 8.08 (3) | 23.38 (8) | 7.1 (6) |
| novice | 12 | 15 (7) | 9 (7) | 96 (7) | 133 (7) | 5.4 (2) | 7.3 (4) | 35.05 (7) | 7.1 (5) |
| novice | 13 | 20 (7) | 6 (7) | 104 (7) | 133 (7) | not measured | 7.3 (4) | 34.43 (7) | 7.1 (6) |
| novice | 14 | 11 (5) | 7 (5) | 64 (5) | 107 (5) | not measured | 7.3 (4) | 24.32 (5) | 7.1 (5) |
| novice | 15 | 3 (5) | 6 (5) | 69 (5) | 107 (5) | 5.5 (1) | 3.98 (2) | 20.88 (5) | 7.1 (5) |
| novice | 16 | 9.5 (4) | 7.5 (4) | 73 (4) | 601 (4) | 6.58 (1) | 7.3 (3) | 31.56 (4) | 7.1 (4) |
| novice | 17 | 9.5 (4) | 12 (4) | 71.5 (4) | 321 (4) | 3.78 (3) | 7.3 (4) | 23.62 (4) | 7.1 (4) |
| novice | 18 | 11 (4) | 5.5 (4) | 83 (4) | 826.5 (4) | 2.79 (2) | 4.28 (4) | 32.7 (4) | 7.1 (4) |
| novice | 19 | 9.5 (4) | 6.5 (4) | 111 (4) | 443 (4) | 5.5 (3) | 10.95 (3) | 26.13 (4) | 7.1 (3) |
| novice | 20 | 9 (4) | 4.5 (4) | 38 (4) | 197.5 (4) | 4.08 (2) | 7.3 (4) | 18.23 (4) | 7.1 (4) |
| novice | 21 | 9 (4) | 3 (4) | 104 (4) | 887 (4) | 8.58 (3) | 7.3 (1) | 17.66 (4) | 7.1 (2) |
| novice | 22 | 12.5 (4) | 7 (4) | 82.5 (4) | 429 (4) | 5.48 (3) | 7.3 (4) | 27.07 (4) | 7.1 (3) |
| novice | 23 | 22 (4) | 7 (4) | 33.5 (4) | 433 (4) | 0.73 (3) | 7.3 (4) | 31.64 (4) | 7.1 (4) |
| novice | 24 | 13 (3) | 6 (3) | 21 (3) | 175 (3) | 3.75 (1) | 12.05 (2) | 21.07 (3) | 10.65 (2) |
| novice | 25 | 13 (2) | 5.5 (2) | 89.5 (2) | 1037.5 (2) | 6.78 (1) | 7.3 (2) | 19.14 (2) | 7.1 (1) |
| novice | 26 | 20 (2) | 10.5 (2) | 67 (2) | 1078.5 (2) | 7.88 (1) | 7.42 (2) | 29.19 (2) | 7.1 (1) |
| novice | 27 | 15 (2) | 7 (2) | 49 (2) | 1343.5 (2) | 4.63 (2) | 7.3 (2) | 21.93 (2) | 7.1 (2) |
| novice | 28 | 26.5 (2) | 14 (2) | 164.5 (2) | 2450.5 (2) | 5.5 (1) | 10.95 (2) | 41.45 (2) | 7.1 (2) |
| novice | 29 | 9.5 (2) | 8 (2) | 23 (2) | 840 (2) | not measured | 7.3 (2) | 22.25 (2) | 7.1 (2) |
| average | 1 | 10 (9) | 0 (9) | 0 (9) | 13 (9) | not measured | not measured | 10.35 (9) | not measured |
| average | 2 | 10 (9) | 1 (9) | 0 (9) | 14 (9) | 5.5 (1) | not measured | 11.78 (9) | not measured |
| average | 3 | 8 (9) | 3 (9) | 0 (9) | 12 (9) | 0.55 (1) | not measured | 12.17 (9) | 7.1 (3) |
| average | 4 | 4 (9) | 1 (9) | 0 (9) | 12 (9) | 2.78 (1) | 7.3 (2) | 8.63 (9) | not measured |
| average | 5 | 2 (9) | 2 (9) | 0 (9) | 24 (9) | 1.65 (1) | not measured | 14.82 (9) | 7.1 (3) |
| average | 6 | 10 (9) | 2 (9) | 0 (9) | 27 (9) | 2.53 (1) | 7.3 (1) | 12.7 (9) | 7.1 (4) |
| average | 7 | 4 (9) | 3 (9) | 14 (9) | 39 (9) | 2.7 (1) | 7.3 (4) | 12.35 (9) | 7.1 (1) |
| average | 8 | 6 (9) | 6 (9) | 47 (9) | 47 (9) | 2.23 (1) | 7.3 (5) | 14.17 (9) | 7.1 (5) |
| average | 9 | 10 (9) | 7 (9) | 42 (9) | 104 (9) | not measured | 7.3 (7) | 18.42 (9) | 7.1 (5) |
| average | 10 | 4 (9) | 7 (9) | 56 (9) | 66 (9) | 5.79 (2) | 7.3 (4) | 14.37 (9) | 7.1 (5) |
| average | 11 | 9 (9) | 11 (9) | 50 (9) | 64 (9) | 5.5 (3) | 7.3 (7) | 15.27 (9) | 7.1 (6) |
| average | 12 | 10 (9) | 7 (9) | 87 (9) | 142 (9) | 4.09 (2) | 7.3 (5) | 21.55 (9) | 7.1 (7) |
| average | 13 | 9 (9) | 9 (9) | 132 (9) | 147 (9) | 3.52 (2) | 7.3 (7) | 22.27 (9) | 7.1 (6) |
| average | 14 | 9 (9) | 10 (9) | 83 (9) | 133 (9) | 3.05 (2) | 7.3 (8) | 22.52 (9) | 7.1 (7) |
| average | 15 | 7 (9) | 13 (9) | 90 (9) | 110 (9) | 7.48 (3) | 7.3 (7) | 18.9 (9) | 7.1 (8) |
| average | 16 | 11 (9) | 9 (9) | 71 (9) | 162 (9) | 5.5 (5) | 7.3 (9) | 20.57 (9) | 7.1 (6) |
| average | 17 | 12 (9) | 14 (9) | 98 (9) | 200 (9) | 6.63 (4) | 7.3 (8) | 24.45 (9) | 7.1 (4) |
| average | 18 | 13 (9) | 12 (9) | 118 (9) | 200 (9) | 5.5 (4) | 7.3 (8) | 26.68 (9) | 7.1 (6) |
| average | 19 | 11 (9) | 10 (9) | 90 (9) | 839 (9) | 5.5 (7) | 7.3 (9) | 20.88 (9) | 7.1 (5) |
| average | 20 | 3 (9) | 12 (9) | 81 (9) | 754 (9) | 3 (6) | 7.3 (9) | 16.25 (9) | 7.1 (6) |
| average | 21 | 8 (9) | 10 (9) | 95 (9) | 878 (9) | 4.77 (8) | 7.3 (7) | 20.23 (9) | 7.1 (5) |
| average | 22 | 12 (9) | 11 (9) | 73 (9) | 817 (9) | 2.27 (7) | 7.3 (9) | 22.95 (9) | 7.1 (5) |
| average | 23 | 15 (8) | 9 (8) | 97.5 (8) | 993.5 (8) | 5.5 (7) | 7.3 (5) | 25.34 (8) | 7.1 (5) |
| average | 24 | 15 (8) | 8.5 (8) | 100.5 (8) | 1646 (8) | 5.5 (7) | 7.3 (8) | 25.42 (8) | 7.1 (3) |
| average | 25 | 10 (8) | 10 (8) | 86.5 (8) | 1536.5 (8) | 4.87 (7) | 7.3 (6) | 20.08 (8) | 7.1 (4) |
| average | 26 | 15 (8) | 9.5 (8) | 157.5 (8) | 3361 (8) | 8.22 (7) | 7.3 (7) | 28.79 (8) | 7.1 (3) |
| average | 27 | 14 (8) | 13 (8) | 147.5 (8) | 2126.5 (8) | 5.06 (6) | 7.3 (8) | 29.04 (8) | 7.1 (6) |
| average | 28 | 15 (8) | 9.5 (8) | 131.5 (8) | 2990 (8) | 5.5 (7) | 7.3 (7) | 26.98 (8) | 7.1 (6) |
| average | 29 | 16.5 (8) | 10.5 (8) | 116.5 (8) | 2623.5 (8) | 5.5 (7) | 7.3 (6) | 24.27 (8) | 7.1 (5) |
| average | 30 | 8 (8) | 15 (8) | 81.5 (8) | 1690.5 (8) | 5.5 (6) | 7.3 (8) | 24.37 (8) | 7.1 (3) |
| average | 31 | 11 (8) | 14.5 (8) | 103 (8) | 2268 (8) | 3.32 (7) | 7.3 (8) | 31.21 (8) | 7.1 (3) |
| average | 32 | 14 (8) | 18.5 (8) | 100.5 (8) | 1730 (8) | 5.5 (8) | 7.79 (8) | 31.7 (8) | 7.1 (5) |
| average | 33 | 20 (8) | 15 (8) | 135.5 (8) | 2710.5 (8) | 6.16 (6) | 7.3 (8) | 34.02 (8) | 7.1 (4) |
| average | 34 | 12.5 (8) | 13 (8) | 132 (8) | 2540.5 (8) | 6.29 (8) | 7.3 (8) | 32.79 (8) | 7.1 (3) |
| average | 35 | 9.5 (8) | 14.5 (8) | 82.5 (8) | 1968.5 (8) | 5.5 (5) | 7.3 (8) | 22.95 (8) | 7.1 (5) |
| average | 36 | 24.5 (8) | 14 (8) | 166 (8) | 3975.5 (8) | 6.35 (6) | 7.3 (6) | 32.33 (8) | 7.1 (4) |
| average | 37 | 9.5 (8) | 11.5 (8) | 115.5 (8) | 2881.5 (8) | 5.62 (8) | 7.3 (7) | 28.59 (8) | 7.1 (5) |
| average | 38 | 21 (8) | 16.5 (8) | 154 (8) | 3779.5 (8) | 5.5 (8) | 7.3 (7) | 33.64 (8) | 7.1 (5) |
| average | 39 | 17 (8) | 14 (8) | 162 (8) | 2994 (8) | 6.62 (7) | 7.3 (8) | 31.61 (8) | 7.1 (4) |
| average | 40 | 14.5 (8) | 15.5 (8) | 109.5 (8) | 2289 (8) | 5.5 (7) | 7.3 (8) | 29 (8) | 7.1 (4) |
| expert | 1 | 7.5 (10) | 1 (10) | 0 (10) | 13 (10) | not measured | not measured | 9.95 (10) | not measured |
| expert | 2 | 7.5 (10) | 1 (10) | 0 (10) | 14 (10) | 5.5 (1) | not measured | 11.58 (10) | not measured |
| expert | 3 | 6 (10) | 1.5 (10) | 0 (10) | 12 (10) | 4.03 (1) | 6.08 (1) | 12.68 (10) | 7.1 (1) |
| expert | 4 | 5.5 (10) | 2 (10) | 0 (10) | 12 (10) | 0.23 (1) | 7.3 (1) | 11.98 (10) | 7.1 (1) |
| expert | 5 | 2 (10) | 5 (10) | 0 (10) | 25 (10) | 2.27 (1) | 8.22 (2) | 16.79 (10) | 10.65 (2) |
| expert | 6 | 4 (10) | 5.5 (10) | 0 (10) | 30 (10) | 3.27 (1) | 7.3 (3) | 13.28 (10) | 7.1 (4) |
| expert | 7 | 4.5 (10) | 2.5 (10) | 17.5 (10) | 33.5 (10) | 2.87 (1) | 7.3 (4) | 11.71 (10) | 7.1 (1) |
| expert | 8 | 5.5 (10) | 7.5 (10) | 21 (10) | 48 (10) | 5.5 (1) | 7.3 (5) | 13.95 (10) | 7.1 (2) |
| expert | 9 | 9.5 (10) | 8 (10) | 41.5 (10) | 104.5 (10) | not measured | 7.3 (7) | 16.87 (10) | 7.1 (6) |
| expert | 10 | 3.5 (10) | 12 (10) | 44.5 (10) | 71 (10) | 3.28 (1) | 7.3 (7) | 15.48 (10) | 7.1 (6) |
| expert | 11 | 7 (10) | 7.5 (10) | 45.5 (10) | 79.5 (10) | 5.5 (3) | 7.3 (5) | 18.48 (10) | 7.1 (6) |
| expert | 12 | 11.5 (10) | 10.5 (10) | 104.5 (10) | 165.5 (10) | 1.8 (2) | 7.3 (7) | 22.04 (10) | 7.1 (9) |
| expert | 13 | 8.5 (10) | 10.5 (10) | 131 (10) | 177 (10) | 1.64 (2) | 7.3 (8) | 22.8 (10) | 7.1 (8) |
| expert | 14 | 9.5 (10) | 11 (10) | 55.5 (10) | 97.5 (10) | 6.23 (3) | 7.3 (9) | 16.82 (10) | 7.1 (6) |
| expert | 15 | 6 (10) | 13.5 (10) | 80 (10) | 116.5 (10) | 6.6 (3) | 7.3 (8) | 20.19 (10) | 7.1 (6) |
| expert | 16 | 5.5 (10) | 11.5 (10) | 101 (10) | 194 (10) | 5.5 (3) | 7.3 (9) | 21.95 (10) | 7.1 (7) |
| expert | 17 | 10 (10) | 10 (10) | 105 (10) | 237 (10) | 3.01 (6) | 7.3 (10) | 25.12 (10) | 7.1 (4) |
| expert | 18 | 9.5 (10) | 10 (10) | 81.5 (10) | 165.5 (10) | 5.5 (7) | 7.3 (9) | 18.15 (10) | 7.1 (5) |
| expert | 19 | 9 (10) | 10.5 (10) | 109.5 (10) | 338.5 (10) | 5.5 (7) | 7.3 (8) | 17.01 (10) | 7.1 (5) |
| expert | 20 | 8 (10) | 17 (10) | 77 (10) | 554.5 (10) | 5.5 (6) | 7.3 (9) | 18.09 (10) | 7.1 (6) |
| expert | 21 | 9.5 (10) | 10.5 (10) | 99 (10) | 1057.5 (10) | 5.5 (9) | 7.3 (6) | 18.3 (10) | 7.1 (3) |
| expert | 22 | 13 (10) | 13.5 (10) | 132.5 (10) | 2564.5 (10) | 5.64 (10) | 7.3 (10) | 26.09 (10) | 7.1 (2) |
| expert | 23 | 14 (10) | 15 (10) | 107.5 (10) | 2155.5 (10) | 4.07 (9) | 7.3 (10) | 27.06 (10) | 7.1 (2) |
| expert | 24 | 15 (10) | 16 (10) | 97.5 (10) | 2292 (10) | 5.21 (10) | 7.3 (8) | 23.69 (10) | 7.1 (4) |
| expert | 25 | 8.5 (10) | 16 (10) | 150 (10) | 1640 (10) | 4.94 (10) | 7.3 (10) | 24.27 (10) | 7.1 (2) |
| expert | 26 | 9.5 (10) | 11 (10) | 106 (10) | 2321.5 (10) | 5.52 (10) | 7.3 (7) | 19.31 (10) | 7.1 (2) |
| expert | 27 | 13 (10) | 17.5 (10) | 148.5 (10) | 3149 (10) | 5.5 (9) | 7.3 (9) | 27.18 (10) | 7.1 (4) |
| expert | 28 | 11.5 (10) | 13.5 (10) | 182.5 (10) | 3228.5 (10) | 5.5 (10) | 7.3 (9) | 25.98 (10) | 7.1 (5) |
| expert | 29 | 16.5 (10) | 15 (10) | 116.5 (10) | 2203 (10) | 5.21 (10) | 7.3 (10) | 24.34 (10) | 7.1 (5) |
| expert | 30 | 12 (10) | 21.5 (10) | 86 (10) | 1858 (10) | 5.74 (8) | 7.3 (10) | 23.93 (10) | 7.1 (2) |
| expert | 31 | 14 (10) | 15.5 (10) | 120 (10) | 3079.5 (10) | 6.13 (10) | 7.3 (8) | 24.63 (10) | 7.1 (3) |
| expert | 32 | 17 (10) | 14 (10) | 141.5 (10) | 3288.5 (10) | 5.73 (10) | 7.3 (10) | 27.88 (10) | not measured |
| expert | 33 | 12 (10) | 17.5 (10) | 109.5 (10) | 3118.5 (10) | 5.5 (8) | 7.3 (10) | 25.95 (10) | 7.1 (3) |
| expert | 34 | 14 (10) | 20 (10) | 148 (10) | 2836 (10) | 5.68 (9) | 7.3 (8) | 30.12 (10) | 7.1 (6) |
| expert | 35 | 14.5 (10) | 17.5 (10) | 103 (10) | 2036.5 (10) | 5.5 (7) | 7.3 (9) | 25.45 (10) | 7.1 (5) |
| expert | 36 | 18 (10) | 20.5 (10) | 192.5 (10) | 3312.5 (10) | 3.6 (9) | 11.65 (10) | 34.2 (10) | 7.1 (5) |
| expert | 37 | 14 (10) | 20.5 (10) | 152.5 (10) | 3307.5 (10) | 5.5 (9) | 7.3 (10) | 31.33 (10) | 7.1 (6) |
| expert | 38 | 15 (10) | 19 (10) | 148.5 (10) | 2872.5 (10) | 5.5 (8) | 7.3 (10) | 32.99 (10) | 7.1 (5) |
| expert | 39 | 11.5 (10) | 18 (10) | 141 (10) | 3658 (10) | 5.5 (7) | 7.83 (10) | 25.61 (10) | 7.1 (6) |
| expert | 40 | 11.5 (10) | 24.5 (10) | 128 (10) | 2393 (10) | 5.5 (10) | 7.3 (10) | 30.88 (10) | 7.1 (4) |

## Unusual winning runs

At the deepest observed wave per profile, rank up to three runs with positive rarity. Rarity is the mean of log₂(measured runs / runs sharing the signature) for the ordered picks, set of acquired weapons and dominant measured ghost form. Missing signatures are skipped. Ties use ascending seed. Commands use the recorded controls and batch settings. Replaying a human trajectory also requires its recorded inputs.

| Profile | Seed | Wave | Rarity (bits) | Picks in order | Weapon refs | Dominant form | Replay command |
| --- | --- | --- | --- | --- | --- | --- | --- |
| novice | 1 | 29 | 1.88 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| novice | 7 | 29 | 1.88 | ghost_kerf → stat_regen_10 → stat_damage_10 → weapon_pistol → ghost_tonnage → stat_hp_max_25 → ghost_ohm → stat_damage_25 → weapon_gatling → stat_speed_10 → weapon_flamethrower → weapon_katana → stat_hp_max_10 → weapon_rocket_launcher → stat_guard_meter_10 → weapon_hand_cannon → ghost_dent → stat_guard_meter_25 → weapon_machine_pistol → stat_speed_25 → stat_regen_25 → weapon_plasma_rifle → weapon_gloria → weapon_chainsaw → weapon_plasma_sword → weapon_electro_baton | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=7 --bot=novice --pick=greedy --controls=wheel --waves=40 |
| average | 1 | 40 | 1.11 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 3 | 40 | 1.11 | stat_hp_max_10 → weapon_pistol → weapon_electro_baton → stat_speed_10 → stat_guard_meter_10 → weapon_plasma_sword → weapon_gatling → stat_speed_25 → ghost_kerf → weapon_rocket_launcher → ghost_ohm → stat_regen_10 → stat_hp_max_25 → weapon_flamethrower → stat_regen_25 → stat_damage_10 → weapon_chainsaw → ghost_dent → ghost_tonnage → stat_guard_meter_25 → weapon_katana → stat_damage_25 → weapon_machine_pistol → weapon_plasma_rifle → weapon_gloria → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --controls=wheel --waves=40 |
| average | 4 | 40 | 1.11 | stat_damage_10 → stat_speed_10 → weapon_pistol → stat_hp_max_10 → weapon_hand_cannon → stat_guard_meter_10 → ghost_tonnage → stat_regen_10 → stat_speed_25 → weapon_plasma_sword → weapon_plasma_rifle → weapon_chainsaw → weapon_rocket_launcher → weapon_gatling → ghost_ohm → weapon_flamethrower → weapon_katana → ghost_kerf → stat_hp_max_25 → ghost_dent → stat_damage_25 → weapon_gloria → stat_guard_meter_25 → stat_regen_25 → weapon_machine_pistol → weapon_electro_baton | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=4 --bot=average --pick=greedy --controls=wheel --waves=40 |
| expert | 1 | 40 | 1.11 | ghost_tonnage → stat_hp_max_10 → stat_guard_meter_10 → stat_speed_10 → ghost_ohm → weapon_plasma_sword → weapon_pistol → stat_damage_25 → weapon_machine_pistol → weapon_electro_baton → stat_damage_10 → weapon_rocket_launcher → stat_hp_max_25 → weapon_plasma_rifle → ghost_kerf → stat_regen_10 → weapon_gatling → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → ghost_dent → weapon_gloria → weapon_hand_cannon → weapon_flamethrower → weapon_katana → weapon_chainsaw | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=1 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 2 | 40 | 1.11 | ghost_tonnage → ghost_ohm → ghost_dent → stat_speed_10 → stat_hp_max_10 → weapon_machine_pistol → weapon_gatling → stat_guard_meter_10 → weapon_pistol → weapon_katana → weapon_plasma_sword → stat_damage_10 → stat_hp_max_25 → ghost_kerf → stat_guard_meter_25 → stat_speed_25 → stat_regen_25 → weapon_flamethrower → weapon_rocket_launcher → weapon_chainsaw → weapon_gloria → stat_damage_25 → stat_regen_10 → weapon_electro_baton → weapon_plasma_rifle → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=2 --bot=expert --pick=greedy --controls=wheel --waves=40 |
| expert | 3 | 40 | 1.11 | stat_hp_max_10 → weapon_pistol → weapon_electro_baton → stat_speed_10 → stat_guard_meter_10 → weapon_plasma_sword → weapon_gatling → stat_speed_25 → ghost_kerf → weapon_rocket_launcher → ghost_ohm → stat_regen_10 → stat_hp_max_25 → weapon_flamethrower → stat_regen_25 → stat_damage_10 → weapon_chainsaw → ghost_dent → ghost_tonnage → stat_guard_meter_25 → weapon_katana → stat_damage_25 → weapon_machine_pistol → weapon_plasma_rifle → weapon_gloria → weapon_hand_cannon | chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher | rivet | node tools/dev/run.mjs gauntlet --seed=3 --bot=expert --pick=greedy --controls=wheel --waves=40 |

## Excluded runs

These inputs are retained in the batch manifest.

| File | Profile | Seed | Reason |
| --- | --- | --- | --- |
| runs/average-6.json | average | 6 | FAIL timeout after 602 s; SCRIPT ERROR 0; unknown arg 0; result missing; flags checked: 5 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd) |
