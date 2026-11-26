# Foes waiting (n31)

Measured at b4302590639fc80867b52d8d1d81e379fc19ca17, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.63 / 2.07 | 1.7 / 5.42 | 45 (45, 45) | 59 % (96 %, 95 %) | 41 % | 5.7 / 9.2 / 12.3 | | | | | |
| **1** | **all ranged** | 130 | 0.63 / 2.07 | 1.7 / 5.42 | 45 (45, 45) | 59 % (96 %, 95 %) | 41 % | 5.7 / 9.2 / 12.3 | 0.86 (6) | 7.5 | 75 % | 12.9 | 0 |
| 2 | patrol_cop | 140 | 0.6 / 1.25 | 1.5 / 4.5 | 58 (57, 56) | 57 % (96 %, 95 %) | 42 % | 5.2 / 9 / 11.3 | | | | | |
| **2** | **all ranged** | 140 | 0.6 / 1.25 | 1.5 / 4.5 | 58 (57, 56) | 57 % (96 %, 95 %) | 42 % | 5.2 / 9 / 11.3 | 0.83 (7) | 8 | 76 % | 9.3 | 0 |
| 3 | contractor | 25 | 0.5 / 1.72 | 1.38 / 4.63 | 4 (4, 4) | 50 % (95 %, 94 %) | 55 % | 5.1 / 8.3 / 12.4 | | | | | |
| 3 | patrol_cop | 21 | 1.03 / 4.7 | 2.28 / 9.12 | 6 (4, 4) | 58 % (95 %, 94 %) | 48 % | 6.4 / 8.6 / 11 | | | | | |
| 3 | rocket_trooper | 20 | 2.33 / 3.75 | 2.6 / 4.53 | 4 (4, 4) | 48 % (75 %, 75 %) | 43 % | 7.6 / 12 / 18.1 | | | | | |
| 3 | swat | 21 | 1.22 / 2.42 | 1.45 / 3.13 | 5 (5, 4) | 43 % (94 %, 93 %) | 60 % | 6 / 10.6 / 15.2 | | | | | |
| **3** | **all ranged** | 87 | 1.02 / 3.7 | 2.28 / 6.12 | 19 (17, 16) | 50 % (90 %, 89 %) | 52 % | 5.4 / 9.3 / 13.6 | 0.73 (6) | 5 | 75 % | 24.1 | 0 |
| 4 | contractor | 25 | 0.88 / 4.42 | 2.22 / 7.95 | 9 (8, 8) | 59 % (97 %, 96 %) | 46 % | 5.1 / 10.1 / 12.5 | | | | | |
| 4 | patrol_cop | 22 | 0.53 / 1.82 | 1.45 / 2.38 | 8 (8, 7) | 68 % (96 %, 96 %) | 47 % | 4.6 / 8.5 / 11.8 | | | | | |
| 4 | rocket_trooper | 22 | 1.3 / 3.97 | 1.88 / 3.97 | 11 (10, 10) | 59 % (76 %, 75 %) | 48 % | 8.2 / 10.4 / 15 | | | | | |
| 4 | swat | 25 | 0.78 / 1.85 | 1.13 / 3.25 | 5 (5, 5) | 44 % (93 %, 92 %) | 64 % | 6.5 / 10.4 / 14.2 | | | | | |
| **4** | **all ranged** | 94 | 0.82 / 3.05 | 1.53 / 5.42 | 33 (31, 30) | 57 % (89 %, 88 %) | 51 % | 6.2 / 10.3 / 13.6 | 0.67 (5) | 5.5 | 74 % | 24.4 | 0 |
| 6 (reached 4/10) | contractor | 6 | 0.85 / 1.97 | 1.97 / 7.42 | 0 (0, 0) | 34 % (93 %, 91 %) | 72 % | 4.9 / 6.7 / 12.5 | | | | | |
| 6 (reached 4/10) | patrol_cop | 10 | 0.67 / 1.28 | 1.57 / 2.85 | 3 (3, 3) | 57 % (94 %, 92 %) | 62 % | 5.2 / 8.9 / 13.3 | | | | | |
| 6 (reached 4/10) | robot_gunner | 3 | 0.43 / 0.85 | 2.28 / 5.05 | 1 (1, 1) | 49 % (99 %, 99 %) | 19 % | 8.2 / 8.3 / 17.5 | | | | | |
| 6 (reached 4/10) | rocket_trooper | 9 | 0.85 / 1.28 | 1.28 / 1.73 | 4 (4, 4) | 49 % (74 %, 72 %) | 40 % | 8.1 / 8.8 / 14.2 | | | | | |
| 6 (reached 4/10) | sentry_turret | 4 | 4.75 / 6.97 | 11.47 / 16.45 | 1 (1, 1) | 18 % (44 %, 27 %) | 58 % | 1 / 3.7 / 10.4 | | | | | |
| 6 (reached 4/10) | swat | 2 | 0.58 / 1.43 | 0.58 / 1.43 | 0 (0, 0) | 21 % (87 %, 87 %) | 89 % | 6.6 / 11.6 / 14.6 | | | | | |
| **6** (reached 4/10) | **all ranged** | 34 | 0.85 / 4.4 | 1.73 / 8.78 | 9 (9, 9) | 40 % (77 %, 74 %) | 54 % | 1.1 / 7.5 / 12.4 | 0.77 (4) | 5.4 | 79 % | 57.8 | 1 |
| 7 (reached 3/10) | contractor | 6 | 2.08 / 11.4 | 2.87 / 11.4 | 3 (3, 3) | 49 % (96 %, 95 %) | 65 % | 6.4 / 7.4 / 10.9 | | | | | |
| 7 (reached 3/10) | patrol_cop | 2 | - / - | - / - | 2 (2, 2) | 92 % (100 %, 100 %) | 48 % | - / - / - | | | | | |
| 7 (reached 3/10) | robot_gunner | 9 | 0.77 / 2.17 | 1.08 / 2.2 | 1 (1, 1) | 32 % (99 %, 99 %) | 50 % | 5.1 / 8.9 / 12.5 | | | | | |
| 7 (reached 3/10) | rocket_trooper | 5 | 0.8 / 1.22 | 1.22 / 4.35 | 3 (3, 3) | 60 % (80 %, 75 %) | 31 % | 11 / 11 / 19.3 | | | | | |
| 7 (reached 3/10) | sentry_turret | 4 | 3.7 / 3.8 | 6.2 / 23.07 | 1 (1, 1) | 23 % (56 %, 36 %) | 38 % | 1.2 / 6 / 7.8 | | | | | |
| 7 (reached 3/10) | swat | 6 | 0.42 / 7.62 | 1.5 / 9.17 | 0 (0, 0) | 47 % (93 %, 92 %) | 64 % | 6.1 / 11.8 / 15.3 | | | | | |
| **7** (reached 3/10) | **all ranged** | 32 | 0.8 / 3.8 | 2.17 / 9.17 | 10 (10, 10) | 43 % (87 %, 85 %) | 52 % | 2.8 / 7.2 / 14.3 | 0.72 (4) | 6.2 | 82 % | 22.6 | 0 |
| **1-4, 6-7** | **all ranged** | 517 | 0.72 / 2.6 | 1.7 / 5.47 | 174 (169, 166) | 54 % (91 %, 90 %) | 47 % | 4.9 / 9.1 / 13 | 0.76 (7) | 6.4 | 76 % | 21.4 | 1 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 7 | 33 | 167.6 |
| 4 | riot_cop | 28 | 7 | 58 | 160.6 |
| 6 | riot_cop | 9 | 4 | 13 | 38.1 |
| 6 | robot_thug | 7 | 1 | 14 | 39.6 |
| 7 | riot_cop | 1 | 1 | 0 | 5.5 |
| 7 | robot_thug | 3 | 0 | 5 | 18.2 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 4/10, 7: 3/10. Rivet shots probe = run result on 57/57 wave rows.

