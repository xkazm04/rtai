# Foes waiting (n31)

Measured at 9b3730e3652b93af8aacc147034f8cc9576a2e23, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.63 / 1.88 | 1.7 / 5.42 | 46 (46, 45) | 59 % (96 %, 95 %) | 41 % | 5.8 / 9.3 / 12.2 | | | | | |
| **1** | **all ranged** | 130 | 0.63 / 1.88 | 1.7 / 5.42 | 46 (46, 45) | 59 % (96 %, 95 %) | 41 % | 5.8 / 9.3 / 12.2 | 0.86 (6) | 7.5 | 72 % | 11.7 | 0 |
| 2 | patrol_cop | 140 | 0.57 / 1.22 | 1.65 / 4.52 | 53 (53, 53) | 59 % (96 %, 94 %) | 41 % | 5 / 9.1 / 11.4 | | | | | |
| **2** | **all ranged** | 140 | 0.57 / 1.22 | 1.65 / 4.52 | 53 (53, 53) | 59 % (96 %, 94 %) | 41 % | 5 / 9.1 / 11.4 | 0.86 (7) | 8 | 73 % | 13.8 | 0 |
| 3 | contractor | 25 | 0.48 / 0.8 | 1.15 / 4.18 | 3 (2, 2) | 47 % (94 %, 93 %) | 56 % | 5 / 8.6 / 11.6 | | | | | |
| 3 | patrol_cop | 21 | 0.78 / 5.13 | 2.82 / 8.32 | 7 (6, 5) | 64 % (96 %, 95 %) | 46 % | 5.7 / 8.3 / 10.9 | | | | | |
| 3 | rocket_trooper | 20 | 2.32 / 5.67 | 3.27 / 6.17 | 4 (3, 3) | 50 % (75 %, 74 %) | 46 % | 7.6 / 9.7 / 14.5 | | | | | |
| 3 | swat | 21 | 1.53 / 3.82 | 1.93 / 5 | 5 (5, 5) | 50 % (94 %, 94 %) | 59 % | 5.5 / 9.8 / 15.3 | | | | | |
| **3** | **all ranged** | 87 | 0.95 / 3.77 | 2.37 / 5.42 | 19 (16, 15) | 52 % (89 %, 88 %) | 52 % | 5.6 / 9.1 / 13.2 | 0.76 (6) | 5.2 | 74 % | 29.6 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.8 / 2.18 | 1.42 / 5.23 | 7 (6, 6) | 62 % (96 %, 95 %) | 51 % | 5 / 9.6 / 11.4 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.62 / 19.35 | 1.52 / 22.45 | 4 (4, 4) | 59 % (95 %, 94 %) | 52 % | 5.7 / 8.4 / 10.8 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 0.97 / 7.33 | 1.7 / 7.33 | 11 (9, 9) | 63 % (76 %, 75 %) | 40 % | 8 / 11.2 / 18.3 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.67 / 2.02 | 0.85 / 2.9 | 4 (4, 4) | 31 % (91 %, 90 %) | 65 % | 5.9 / 10.2 / 15.8 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.77 / 5.5 | 1.4 / 6.1 | 26 (23, 23) | 55 % (89 %, 88 %) | 51 % | 5.8 / 9.6 / 14.9 | 0.78 (5) | 5.9 | 76 % | 16.2 | 0 |
| 6 (reached 3/10) | contractor | 3 | 0.7 / 9.23 | 1.58 / 9.23 | 1 (1, 1) | 58 % (96 %, 96 %) | 37 % | 4.7 / 8.3 / 9.8 | | | | | |
| 6 (reached 3/10) | patrol_cop | 8 | 0.52 / 13.67 | 1.42 / 13.67 | 0 (0, 0) | 42 % (90 %, 89 %) | 52 % | 6.2 / 9.3 / 11.8 | | | | | |
| 6 (reached 3/10) | robot_gunner | 5 | 1.22 / 3.95 | 4 / 10.37 | 2 (2, 2) | 39 % (99 %, 99 %) | 50 % | 7.4 / 11.5 / 12.9 | | | | | |
| 6 (reached 3/10) | rocket_trooper | 7 | 0.82 / 8.27 | 1.77 / 8.27 | 2 (2, 2) | 68 % (82 %, 82 %) | 53 % | 8.2 / 10.8 / 18 | | | | | |
| 6 (reached 3/10) | sentry_turret | 1 | 3.77 / 3.77 | 8.45 / 8.45 | 0 (0, 0) | 0 % (34 %, 14 %) | 74 % | 7.5 / 10.9 / 12.2 | | | | | |
| 6 (reached 3/10) | swat | 3 | 0.58 / 0.67 | 0.58 / 0.67 | 1 (1, 1) | 20 % (89 %, 89 %) | 81 % | 7.8 / 11.6 / 12.9 | | | | | |
| **6** (reached 3/10) | **all ranged** | 27 | 0.8 / 8.27 | 1.67 / 9.23 | 6 (6, 6) | 46 % (87 %, 86 %) | 54 % | 7.5 / 10.4 / 12.2 | 1 (4) | 5.6 | 72 % | 19.6 | 0 |
| 7 (reached 3/10) | contractor | 7 | 0.98 / 6.02 | 3.87 / 9.87 | 4 (4, 3) | 69 % (98 %, 97 %) | 44 % | 7.7 / 8.3 / 12.7 | | | | | |
| 7 (reached 3/10) | patrol_cop | 5 | 0.73 / 13.78 | 1.1 / 13.78 | 1 (1, 1) | 72 % (98 %, 98 %) | 30 % | 7 / 10.6 / 13.5 | | | | | |
| 7 (reached 3/10) | robot_gunner | 7 | 0.82 / 1.1 | 1.3 / 2.17 | 2 (1, 1) | 38 % (99 %, 99 %) | 57 % | 5.4 / 8.2 / 12.3 | | | | | |
| 7 (reached 3/10) | rocket_trooper | 2 | 0.85 / 0.87 | 1.67 / 1.67 | 0 (0, 0) | 43 % (71 %, 69 %) | 59 % | 8.7 / 9 / 17.5 | | | | | |
| 7 (reached 3/10) | sentry_turret | 1 | 3.7 / 3.7 | 5.05 / 5.05 | 0 (0, 0) | 1 % (21 %, 11 %) | 73 % | 1.2 / 1.5 / 10.2 | | | | | |
| 7 (reached 3/10) | swat | 9 | 0.57 / 3.07 | 1.22 / 3.07 | 3 (3, 3) | 49 % (93 %, 93 %) | 70 % | 5.2 / 11.7 / 14.8 | | | | | |
| **7** (reached 3/10) | **all ranged** | 31 | 0.85 / 3.7 | 1.48 / 5.05 | 10 (9, 8) | 51 % (89 %, 88 %) | 53 % | 1.3 / 9.9 / 14.1 | 0.83 (4) | 6.1 | 86 % | 15.2 | 0 |
| **1-4, 6-7** | **all ranged** | 499 | 0.68 / 2.58 | 1.67 / 5.47 | 160 (153, 150) | 55 % (92 %, 90 %) | 47 % | 5.5 / 9.3 / 12.7 | 0.83 (7) | 6.6 | 75 % | 17.8 | 1 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 7 | 58 | 182.7 |
| 4 | riot_cop | 26 | 6 | 27 | 84.7 |
| 6 | riot_cop | 8 | 3 | 24 | 64 |
| 6 | robot_thug | 3 | 0 | 5 | 24 |
| 7 | riot_cop | 2 | 1 | 3 | 12 |
| 7 | robot_thug | 5 | 3 | 2 | 14.4 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 9/10, 6: 3/10, 7: 3/10. Rivet shots probe = run result on 54/54 wave rows.

## novice (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.62 / 1.27 | 1.8 / 6.02 | 43 (43, 42) | 60 % (96 %, 95 %) | 39 % | 5.9 / 9.3 / 11.9 | | | | | |
| **1** | **all ranged** | 130 | 0.62 / 1.27 | 1.8 / 6.02 | 43 (43, 42) | 60 % (96 %, 95 %) | 39 % | 5.9 / 9.3 / 11.9 | 0.78 (6) | 7.4 | 69 % | 11.4 | 0 |
| 2 | patrol_cop | 140 | 0.62 / 1.5 | 1.67 / 5.15 | 52 (52, 50) | 60 % (96 %, 95 %) | 40 % | 5.3 / 9.3 / 11.6 | | | | | |
| **2** | **all ranged** | 140 | 0.62 / 1.5 | 1.67 / 5.15 | 52 (52, 50) | 60 % (96 %, 95 %) | 40 % | 5.3 / 9.3 / 11.6 | 0.8 (7) | 7.8 | 72 % | 11.4 | 0 |
| 3 | contractor | 25 | 0.5 / 1.88 | 1.37 / 4.12 | 4 (3, 2) | 48 % (94 %, 93 %) | 50 % | 5.7 / 8.5 / 11.4 | | | | | |
| 3 | patrol_cop | 21 | 0.72 / 1.62 | 1.68 / 7.18 | 7 (6, 6) | 63 % (97 %, 96 %) | 45 % | 7.7 / 9.3 / 11.4 | | | | | |
| 3 | rocket_trooper | 20 | 1.67 / 4.43 | 2.37 / 4.63 | 6 (6, 6) | 67 % (83 %, 82 %) | 45 % | 7.2 / 9.6 / 15.2 | | | | | |
| 3 | swat | 21 | 1.15 / 4.35 | 1.62 / 5.28 | 6 (6, 6) | 34 % (92 %, 91 %) | 69 % | 6.4 / 8.7 / 14.1 | | | | | |
| **3** | **all ranged** | 87 | 0.82 / 3.38 | 1.72 / 5.28 | 23 (21, 20) | 53 % (91 %, 89 %) | 52 % | 6.2 / 8.9 / 13.6 | 0.88 (5) | 5.4 | 66 % | 37.5 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.67 / 2.22 | 1.05 / 3.37 | 7 (7, 7) | 64 % (97 %, 96 %) | 44 % | 4.9 / 8 / 11 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.48 / 1.75 | 1.58 / 2.33 | 6 (5, 5) | 59 % (94 %, 93 %) | 49 % | 5.4 / 8.3 / 11 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 1.23 / 3.3 | 2.03 / 3.3 | 14 (14, 14) | 67 % (81 %, 80 %) | 41 % | 8.1 / 12 / 14 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.85 / 4.15 | 1.5 / 5.28 | 3 (2, 2) | 42 % (93 %, 92 %) | 65 % | 5.8 / 9.6 / 16.6 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.77 / 2.22 | 1.7 / 3.37 | 30 (28, 28) | 58 % (91 %, 90 %) | 50 % | 5.5 / 8.9 / 14 | 0.7 (5) | 5.7 | 57 % | 31.7 | 1 |
| 6 | not reached (0/10 seeds) | | | | | | | | | | | | |
| 7 | not reached (0/10 seeds) | | | | | | | | | | | | |
| **1-4, 6-7** | **all ranged** | 441 | 0.67 / 2.07 | 1.75 / 5.15 | 148 (144, 140) | 58 % (94 %, 93 %) | 44 % | 5.7 / 9.1 / 12.4 | 0.79 (7) | 6.6 | 66 % | 22.8 | 2 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 7 | 58 | 175 |
| 4 | riot_cop | 26 | 2 | 52 | 145.9 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 8/10, 6: 0/10, 7: 0/10. Rivet shots probe = run result on 47/47 wave rows.

