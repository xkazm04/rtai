# Foes waiting (n31)

Measured at f1dfc7492 (live tree; game code as 19cb2decd, item 2 FoeGait split), gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.98 / 3.47 | 2.98 / 6.7 | 76 (74, 72) | 77 % (97 %, 95 %) | 18 % | 5.5 / 8.1 / 10.5 | | | | | |
| **1** | **all ranged** | 130 | 0.98 / 3.47 | 2.98 / 6.7 | 76 (74, 72) | 77 % (97 %, 95 %) | 18 % | 5.5 / 8.1 / 10.5 | 0.59 (3) | 7.8 | 53 % | 6 | 0 |
| 2 | patrol_cop | 140 | 0.7 / 3.95 | 2.97 / 7.78 | 90 (88, 85) | 76 % (96 %, 94 %) | 21 % | 5.1 / 7.5 / 10.5 | | | | | |
| **2** | **all ranged** | 140 | 0.7 / 3.95 | 2.97 / 7.78 | 90 (88, 85) | 76 % (96 %, 94 %) | 21 % | 5.1 / 7.5 / 10.5 | 0.58 (5) | 7.5 | 65 % | 4 | 0 |
| 3 | contractor | 25 | 0.57 / 2.75 | 1.57 / 7.8 | 7 (6, 6) | 58 % (91 %, 90 %) | 38 % | 5.9 / 9.1 / 11.9 | | | | | |
| 3 | patrol_cop | 21 | 0.87 / 3.22 | 4.67 / 11.85 | 9 (8, 8) | 69 % (94 %, 92 %) | 27 % | 6.6 / 8.9 / 11.2 | | | | | |
| 3 | rocket_trooper | 20 | 3.25 / 4.6 | 4.15 / 4.82 | 13 (13, 13) | 69 % (83 %, 82 %) | 31 % | 7.8 / 10.5 / 12.3 | | | | | |
| 3 | swat | 21 | 2 / 5.73 | 3 / 7.17 | 10 (9, 9) | 68 % (93 %, 91 %) | 34 % | 5.6 / 10.4 / 15.6 | | | | | |
| **3** | **all ranged** | 87 | 1.02 / 4.3 | 3 / 7.8 | 39 (36, 36) | 66 % (90 %, 89 %) | 32 % | 6.3 / 9.1 / 12.5 | 0.67 (3) | 5.1 | 65 % | 15.3 | 0 |
| 4 | contractor | 25 | 0.92 / 3.68 | 3.1 / 9.83 | 8 (7, 5) | 67 % (92 %, 90 %) | 29 % | 4.9 / 9.1 / 12.5 | | | | | |
| 4 | patrol_cop | 22 | 0.68 / 14.8 | 1.6 / 17.72 | 9 (9, 9) | 71 % (93 %, 92 %) | 28 % | 5.2 / 8.4 / 10.5 | | | | | |
| 4 | rocket_trooper | 22 | 3.22 / 8.38 | 3.88 / 8.38 | 16 (16, 16) | 87 % (91 %, 91 %) | 22 % | 9.1 / 10.3 / 13.9 | | | | | |
| 4 | swat | 25 | 2.35 / 5.85 | 2.35 / 9.47 | 9 (9, 9) | 57 % (88 %, 87 %) | 41 % | 5.7 / 9.3 / 11.9 | | | | | |
| **4** | **all ranged** | 94 | 1.43 / 8.17 | 2.92 / 9.83 | 42 (41, 39) | 70 % (91 %, 90 %) | 30 % | 5.5 / 8.8 / 11.8 | 0.73 (3) | 5.7 | 68 % | 13.7 | 0 |
| 6 (reached 6/10) | contractor | 8 | 6.25 / 10 | 8.3 / 10 | 3 (3, 3) | 78 % (96 %, 96 %) | 27 % | 4.8 / 7.6 / 10.4 | | | | | |
| 6 (reached 6/10) | patrol_cop | 14 | 7.78 / 21.32 | 9.67 / 21.32 | 8 (8, 7) | 79 % (96 %, 95 %) | 24 % | 4.2 / 6.1 / 8 | | | | | |
| 6 (reached 6/10) | robot_gunner | 7 | 1.65 / 7.27 | 4.82 / 8.45 | 0 (0, 0) | 42 % (81 %, 79 %) | 43 % | 8 / 11 / 13.3 | | | | | |
| 6 (reached 6/10) | rocket_trooper | 11 | 2.77 / 11.85 | 2.77 / 12.55 | 8 (7, 7) | 83 % (90 %, 90 %) | 24 % | 8.7 / 10.2 / 10.7 | | | | | |
| 6 (reached 6/10) | sentry_turret | 7 | 5.73 / 7.33 | 6.32 / 16.55 | 2 (2, 2) | 25 % (43 %, 36 %) | 40 % | 0.9 / 1.5 / 11.3 | | | | | |
| 6 (reached 6/10) | swat | 6 | 0.4 / 5.52 | 0.4 / 7.18 | 1 (1, 1) | 48 % (84 %, 84 %) | 50 % | 5.4 / 9.5 / 12.5 | | | | | |
| **6** (reached 6/10) | **all ranged** | 53 | 3.55 / 9.9 | 4.92 / 10.17 | 22 (21, 20) | 61 % (82 %, 80 %) | 32 % | 1.2 / 8.8 / 12.6 | 0.74 (2) | 5.6 | 57 % | 48.8 | 0 |
| 7 (reached 6/10) | contractor | 14 | 0.85 / 8.93 | 5.17 / 8.93 | 10 (10, 8) | 75 % (96 %, 95 %) | 32 % | 5.6 / 8.2 / 12.4 | | | | | |
| 7 (reached 6/10) | patrol_cop | 11 | 0.55 / 3.32 | 3.32 / 11.1 | 6 (6, 6) | 74 % (96 %, 95 %) | 23 % | 4.8 / 7.7 / 12 | | | | | |
| 7 (reached 6/10) | robot_gunner | 12 | 0.72 / 6.42 | 1.32 / 6.83 | 7 (6, 6) | 53 % (86 %, 85 %) | 31 % | 6.4 / 10.6 / 12 | | | | | |
| 7 (reached 6/10) | rocket_trooper | 11 | 4.88 / 5.03 | 5.7 / 5.98 | 9 (9, 9) | 84 % (93 %, 92 %) | 18 % | 8.6 / 8.6 / 8.7 | | | | | |
| 7 (reached 6/10) | sentry_turret | 3 | 2.9 / 2.9 | 2.9 / 2.9 | 2 (2, 2) | 59 % (65 %, 60 %) | 17 % | 1 / 1.3 / 1.6 | | | | | |
| 7 (reached 6/10) | swat | 15 | 0.92 / 3.57 | 2.52 / 4.27 | 5 (5, 5) | 60 % (89 %, 87 %) | 41 % | 4.9 / 8.6 / 14.4 | | | | | |
| **7** (reached 6/10) | **all ranged** | 66 | 0.92 / 5.03 | 2.9 / 7.77 | 39 (38, 36) | 67 % (90 %, 89 %) | 29 % | 4.8 / 8.8 / 12.2 | 0.61 (2) | 5.6 | 62 % | 14.4 | 0 |
| **1-4, 6-7** | **all ranged** | 570 | 1.13 / 6.32 | 3.13 / 9.07 | 308 (298, 288) | 70 % (92 %, 90 %) | 26 % | 4.9 / 8.6 / 11.9 | 0.66 (5) | 6.3 | 62 % | 14.8 | 0 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 7 | 43 | 157 |
| 4 | riot_cop | 28 | 9 | 33 | 114.8 |
| 6 | riot_cop | 11 | 4 | 17 | 52.9 |
| 6 | robot_thug | 9 | 0 | 14 | 48.3 |
| 7 | riot_cop | 4 | 2 | 5 | 17.2 |
| 7 | robot_thug | 8 | 3 | 10 | 37.7 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 6/10, 7: 6/10. Rivet shots probe = run result on 62/62 wave rows.

## novice (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.67 / 3.27 | 2.45 / 5.97 | 47 (47, 44) | 69 % (95 %, 93 %) | 30 % | 5.7 / 8.8 / 11.7 | | | | | |
| **1** | **all ranged** | 130 | 0.67 / 3.27 | 2.45 / 5.97 | 47 (47, 44) | 69 % (95 %, 93 %) | 30 % | 5.7 / 8.8 / 11.7 | 0.96 (7) | 7.5 | 61 % | 10.1 | 0 |
| 2 | patrol_cop | 140 | 0.63 / 2.65 | 1.92 / 6.8 | 54 (53, 53) | 67 % (94 %, 92 %) | 33 % | 5.1 / 8 / 11.3 | | | | | |
| **2** | **all ranged** | 140 | 0.63 / 2.65 | 1.92 / 6.8 | 54 (53, 53) | 67 % (94 %, 92 %) | 33 % | 5.1 / 8 / 11.3 | 0.97 (5) | 7.8 | 70 % | 10.4 | 0 |
| 3 | contractor | 25 | 0.52 / 1.68 | 1.38 / 5.03 | 4 (4, 4) | 48 % (87 %, 85 %) | 45 % | 6.6 / 9 / 11.3 | | | | | |
| 3 | patrol_cop | 21 | 1.1 / 3 | 3.05 / 7.23 | 8 (7, 7) | 63 % (94 %, 91 %) | 36 % | 6.3 / 8.7 / 12 | | | | | |
| 3 | rocket_trooper | 20 | 2.47 / 4.88 | 3.33 / 5.17 | 8 (8, 8) | 70 % (83 %, 82 %) | 48 % | 6.9 / 9.4 / 13.2 | | | | | |
| 3 | swat | 21 | 1.65 / 2.85 | 2.27 / 5.52 | 6 (6, 6) | 42 % (81 %, 80 %) | 63 % | 5.2 / 10.2 / 13.7 | | | | | |
| **3** | **all ranged** | 87 | 1.25 / 3.38 | 2.27 / 6.45 | 26 (25, 25) | 56 % (86 %, 84 %) | 47 % | 6 / 9.4 / 12.6 | 0.99 (5) | 5.4 | 70 % | 36.8 | 2 |
| 4 (reached 8/10) | contractor | 19 | 0.75 / 4.77 | 2.15 / 7.62 | 7 (7, 7) | 60 % (91 %, 90 %) | 40 % | 4.6 / 8.9 / 11 | | | | | |
| 4 (reached 8/10) | patrol_cop | 18 | 0.77 / 2.12 | 1.43 / 4.88 | 7 (7, 7) | 73 % (94 %, 94 %) | 38 % | 4.7 / 7.3 / 10.2 | | | | | |
| 4 (reached 8/10) | rocket_trooper | 19 | 1.38 / 3.87 | 1.83 / 4.43 | 9 (9, 9) | 58 % (78 %, 77 %) | 30 % | 7 / 12 / 16 | | | | | |
| 4 (reached 8/10) | swat | 19 | 0.93 / 4.77 | 1.67 / 4.77 | 4 (4, 4) | 44 % (83 %, 81 %) | 58 % | 6.2 / 9.8 / 13.5 | | | | | |
| **4** (reached 8/10) | **all ranged** | 75 | 0.97 / 4.77 | 1.8 / 6.82 | 27 (27, 27) | 58 % (86 %, 85 %) | 42 % | 5.5 / 9.2 / 12.7 | 1.05 (4) | 5.6 | 67 % | 22.2 | 0 |
| 6 (reached 1/10) | patrol_cop | 3 | 0.58 / 0.85 | 2.13 / 2.15 | 0 (0, 0) | 50 % (87 %, 82 %) | 37 % | 7.9 / 10.6 / 13.3 | | | | | |
| 6 (reached 1/10) | robot_gunner | 4 | 0.82 / 8.97 | 0.82 / 10.65 | 0 (0, 0) | 30 % (75 %, 75 %) | 51 % | 9.8 / 11 / 12.2 | | | | | |
| 6 (reached 1/10) | rocket_trooper | 1 | 2.32 / 2.32 | 2.32 / 2.32 | 0 (0, 0) | 46 % (76 %, 76 %) | 18 % | 12.2 / 12.2 / 12.2 | | | | | |
| 6 (reached 1/10) | swat | 1 | 0.57 / 0.57 | 0.57 / 0.57 | 0 (0, 0) | 22 % (70 %, 70 %) | 73 % | 8.3 / 11.2 / 12.1 | | | | | |
| **6** (reached 1/10) | **all ranged** | 9 | 0.82 / 8.97 | 2.08 / 10.65 | 0 (0, 0) | 33 % (77 %, 76 %) | 47 % | 9.5 / 11 / 12.2 | 2.48 (4) | 6.4 | 93 % | 59.1 | 1 |
| 7 | not reached (0/10 seeds) | | | | | | | | | | | | |
| **1-4, 6-7** | **all ranged** | 441 | 0.75 / 3.38 | 2.08 / 6.8 | 154 (152, 149) | 61 % (90 %, 88 %) | 38 % | 5.7 / 9.3 / 12.2 | 1.07 (7) | 6.6 | 69 % | 20.8 | 3 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 5 | 96 | 256.3 |
| 4 | riot_cop | 23 | 8 | 30 | 100 |
| 6 | riot_cop | 3 | 1 | 2 | 12.2 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 8/10, 5: 8/10, 6: 1/10, 7: 0/10. Rivet shots probe = run result on 47/47 wave rows.

