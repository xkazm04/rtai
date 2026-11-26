# Foes waiting (n31)

Measured at live tree, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.63 / 2.1 | 2.13 / 5.03 | 57 (55, 52) | 71 % (95 %, 93 %) | 32 % | 6 / 8.6 / 11.8 | | | | | |
| **1** | **all ranged** | 130 | 0.63 / 2.1 | 2.13 / 5.03 | 57 (55, 52) | 71 % (95 %, 93 %) | 32 % | 6 / 8.6 / 11.8 | 0.88 (6) | 7.6 | 68 % | 8.2 | 0 |
| 2 | patrol_cop | 140 | 0.58 / 1.75 | 2.28 / 6.27 | 59 (57, 54) | 67 % (94 %, 92 %) | 34 % | 5.6 / 9 / 11.8 | | | | | |
| **2** | **all ranged** | 140 | 0.58 / 1.75 | 2.28 / 6.27 | 59 (57, 54) | 67 % (94 %, 92 %) | 34 % | 5.6 / 9 / 11.8 | 0.93 (5) | 8.2 | 73 % | 8.3 | 0 |
| 3 | contractor | 25 | 0.55 / 0.83 | 1.67 / 6.58 | 4 (4, 4) | 40 % (86 %, 82 %) | 51 % | 5.9 / 8.9 / 11.3 | | | | | |
| 3 | patrol_cop | 21 | 1.1 / 6.13 | 1.7 / 8.33 | 10 (9, 7) | 74 % (95 %, 94 %) | 37 % | 4.6 / 8.9 / 10.9 | | | | | |
| 3 | rocket_trooper | 20 | 3.68 / 5.37 | 4.25 / 5.37 | 5 (4, 4) | 57 % (78 %, 77 %) | 44 % | 7.5 / 10 / 13 | | | | | |
| 3 | swat | 21 | 1.82 / 3.05 | 2.15 / 3.33 | 4 (3, 3) | 39 % (82 %, 81 %) | 59 % | 6 / 11.5 / 15.8 | | | | | |
| **3** | **all ranged** | 87 | 0.87 / 4.13 | 2.23 / 6.28 | 23 (20, 18) | 52 % (84 %, 82 %) | 47 % | 5.9 / 9.4 / 14.5 | 0.97 (5) | 4.9 | 67 % | 31.7 | 0 |
| 4 | contractor | 25 | 0.78 / 3.65 | 1.62 / 6.1 | 7 (6, 4) | 60 % (90 %, 88 %) | 46 % | 5.2 / 8.5 / 11.7 | | | | | |
| 4 | patrol_cop | 22 | 0.77 / 6.2 | 1.92 / 8.18 | 5 (5, 5) | 66 % (93 %, 92 %) | 42 % | 4.3 / 8.2 / 11.2 | | | | | |
| 4 | rocket_trooper | 22 | 1.5 / 5.15 | 2.57 / 5.15 | 10 (10, 10) | 74 % (83 %, 83 %) | 50 % | 7.6 / 9.7 / 13.1 | | | | | |
| 4 | swat | 25 | 0.67 / 4.55 | 1.33 / 5.68 | 7 (7, 7) | 45 % (84 %, 83 %) | 58 % | 7 / 11 / 14.5 | | | | | |
| **4** | **all ranged** | 94 | 0.83 / 5.05 | 1.73 / 5.68 | 29 (28, 26) | 63 % (86 %, 85 %) | 49 % | 6.1 / 10 / 13.5 | 0.83 (4) | 5.3 | 56 % | 29.2 | 0 |
| 6 (reached 6/10) | contractor | 7 | 0.57 / 7.58 | 4.48 / 14.77 | 2 (2, 2) | 67 % (94 %, 92 %) | 37 % | 8.2 / 9.8 / 13.2 | | | | | |
| 6 (reached 6/10) | patrol_cop | 14 | 0.63 / 8.65 | 1.97 / 12.47 | 2 (1, 1) | 62 % (92 %, 89 %) | 43 % | 5.7 / 9.3 / 12.8 | | | | | |
| 6 (reached 6/10) | robot_gunner | 7 | 0.87 / 9.53 | 2.77 / 10.12 | 0 (0, 0) | 36 % (81 %, 78 %) | 52 % | 5.3 / 10.1 / 13.4 | | | | | |
| 6 (reached 6/10) | rocket_trooper | 9 | 2.43 / 25.55 | 3.33 / 25.55 | 3 (3, 3) | 78 % (84 %, 83 %) | 58 % | 8 / 8.9 / 13.6 | | | | | |
| 6 (reached 6/10) | sentry_turret | 8 | 4.83 / 7.45 | 6.9 / 7.45 | 2 (2, 2) | 15 % (47 %, 27 %) | 48 % | 1.1 / 2.8 / 14.4 | | | | | |
| 6 (reached 6/10) | swat | 6 | 0.78 / 6.07 | 0.78 / 13.38 | 0 (0, 0) | 37 % (84 %, 78 %) | 72 % | 5.7 / 8.9 / 11.8 | | | | | |
| **6** (reached 6/10) | **all ranged** | 51 | 1.35 / 8.65 | 3.33 / 13.38 | 9 (8, 8) | 55 % (78 %, 74 %) | 49 % | 1.3 / 9 / 13.4 | 0.88 (4) | 5.5 | 57 % | 62.9 | 1 |
| 7 (reached 5/10) | contractor | 10 | 0.62 / 1.65 | 0.92 / 4.32 | 4 (2, 2) | 70 % (94 %, 89 %) | 51 % | 4.9 / 8.9 / 13.9 | | | | | |
| 7 (reached 5/10) | patrol_cop | 7 | 0.45 / 0.97 | 1.1 / 2.33 | 2 (1, 1) | 24 % (88 %, 72 %) | 39 % | 4.6 / 8.6 / 12.7 | | | | | |
| 7 (reached 5/10) | robot_gunner | 11 | 1.03 / 2.38 | 1.37 / 3.38 | 2 (2, 2) | 39 % (79 %, 79 %) | 45 % | 7.4 / 10.9 / 12.7 | | | | | |
| 7 (reached 5/10) | rocket_trooper | 8 | 0.82 / 1.23 | 1.97 / 3.02 | 6 (6, 6) | 74 % (87 %, 85 %) | 32 % | 14.8 / 14.8 / 15.7 | | | | | |
| 7 (reached 5/10) | sentry_turret | 5 | 3.72 / 6.05 | 5.03 / 6.05 | 2 (1, 1) | 24 % (36 %, 33 %) | 36 % | 1 / 3.9 / 10.1 | | | | | |
| 7 (reached 5/10) | swat | 11 | 0.87 / 4.08 | 1.88 / 4.13 | 1 (1, 1) | 52 % (87 %, 86 %) | 51 % | 5.6 / 8.9 / 17.5 | | | | | |
| **7** (reached 5/10) | **all ranged** | 52 | 0.87 / 3.72 | 1.77 / 4.32 | 17 (13, 13) | 46 % (79 %, 75 %) | 45 % | 3.6 / 9.8 / 12.7 | 1.45 (5) | 6.9 | 79 % | 38 | 2 |
| **1-4, 6-7** | **all ranged** | 554 | 0.75 / 4.13 | 2.13 / 6.5 | 194 (181, 171) | 60 % (88 %, 85 %) | 42 % | 4.9 / 9.2 / 13 | 0.94 (6) | 6.4 | 65 % | 26.3 | 3 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 5 | 72 | 214.7 |
| 4 | riot_cop | 28 | 4 | 81 | 194.7 |
| 6 | riot_cop | 12 | 5 | 30 | 89.4 |
| 6 | robot_thug | 9 | 0 | 32 | 106.8 |
| 7 | riot_cop | 2 | 2 | 0 | 5.4 |
| 7 | robot_thug | 8 | 2 | 11 | 42.4 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 6/10, 7: 5/10. Rivet shots probe = run result on 61/61 wave rows.

