# Foes waiting (n31)

Measured at 9b3730e3652b93af8aacc147034f8cc9576a2e23, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.55 / 1.03 | 1.75 / 4.47 | 44 (43, 43) | 55 % (95 %, 94 %) | 42 % | 6.1 / 9.1 / 11.7 | | | | | |
| **1** | **all ranged** | 130 | 0.55 / 1.03 | 1.75 / 4.47 | 44 (43, 43) | 55 % (95 %, 94 %) | 42 % | 6.1 / 9.1 / 11.7 | 0.87 (7) | 7.6 | 75 % | 11.7 | 0 |
| 2 | patrol_cop | 140 | 0.57 / 1.17 | 1.8 / 4.15 | 47 (46, 45) | 59 % (96 %, 95 %) | 40 % | 6.6 / 9.8 / 11.9 | | | | | |
| **2** | **all ranged** | 140 | 0.57 / 1.17 | 1.8 / 4.15 | 47 (46, 45) | 59 % (96 %, 95 %) | 40 % | 6.6 / 9.8 / 11.9 | 0.85 (6) | 7.5 | 74 % | 10.5 | 0 |
| 3 | contractor | 17 | 0.82 / 2.98 | 1.65 / 5.48 | 3 (3, 3) | 54 % (94 %, 93 %) | 62 % | 5.1 / 9.7 / 12.1 | | | | | |
| 3 | patrol_cop | 25 | 0.57 / 4.17 | 1.63 / 4.17 | 5 (5, 4) | 60 % (95 %, 94 %) | 43 % | 5 / 8.9 / 11.4 | | | | | |
| 3 | rocket_trooper | 18 | 2.27 / 6.6 | 2.27 / 7.15 | 4 (4, 4) | 59 % (78 %, 77 %) | 50 % | 7.2 / 10.5 / 16.9 | | | | | |
| 3 | swat | 28 | 0.83 / 2.28 | 1.2 / 3.17 | 6 (6, 6) | 41 % (93 %, 93 %) | 71 % | 5 / 8.9 / 13.9 | | | | | |
| **3** | **all ranged** | 88 | 0.83 / 3.67 | 1.65 / 5.15 | 18 (18, 17) | 53 % (90 %, 89 %) | 56 % | 5.1 / 9.1 / 13.4 | 0.76 (6) | 5.3 | 68 % | 24.9 | 0 |
| 4 | contractor | 20 | 0.67 / 2.73 | 1.78 / 4.9 | 5 (3, 3) | 50 % (94 %, 93 %) | 52 % | 6.2 / 9.5 / 12 | | | | | |
| 4 | patrol_cop | 28 | 0.62 / 3.37 | 2.08 / 3.37 | 8 (7, 7) | 56 % (95 %, 93 %) | 46 % | 6.3 / 9 / 12.3 | | | | | |
| 4 | rocket_trooper | 25 | 1.75 / 5.23 | 2.13 / 5.23 | 10 (9, 9) | 60 % (79 %, 78 %) | 40 % | 7.6 / 10.6 / 15.2 | | | | | |
| 4 | swat | 28 | 0.92 / 3.83 | 1.33 / 3.85 | 8 (7, 7) | 37 % (92 %, 91 %) | 71 % | 6 / 10.2 / 14.2 | | | | | |
| **4** | **all ranged** | 101 | 0.83 / 3.83 | 1.78 / 4.57 | 31 (26, 26) | 50 % (90 %, 89 %) | 53 % | 6.2 / 9.7 / 13.3 | 0.87 (6) | 5.4 | 70 % | 23.1 | 0 |
| 6 (reached 4/10) | contractor | 3 | 0.37 / 0.53 | 1.3 / 4.4 | 0 (0, 0) | 59 % (96 %, 96 %) | 35 % | 5.9 / 6.6 / 10.9 | | | | | |
| 6 (reached 4/10) | patrol_cop | 8 | 0.57 / 0.77 | 0.97 / 13.03 | 4 (4, 4) | 50 % (94 %, 92 %) | 49 % | 7.2 / 11.2 / 13.7 | | | | | |
| 6 (reached 4/10) | robot_gunner | 5 | 2.23 / 5.52 | 4.18 / 5.52 | 0 (0, 0) | 49 % (99 %, 99 %) | 58 % | 3.9 / 9.1 / 13.2 | | | | | |
| 6 (reached 4/10) | rocket_trooper | 5 | 2.87 / 5.88 | 5.92 / 7.07 | 2 (2, 2) | 55 % (75 %, 73 %) | 39 % | 6.7 / 10.3 / 19.2 | | | | | |
| 6 (reached 4/10) | sentry_turret | 7 | 6.28 / 9.87 | 7.18 / 11.62 | 0 (0, 0) | 22 % (37 %, 33 %) | 56 % | 1 / 4.8 / 11.1 | | | | | |
| 6 (reached 4/10) | swat | 6 | 0.43 / 0.75 | 0.75 / 2.68 | 1 (1, 1) | 34 % (90 %, 90 %) | 80 % | 6.6 / 10.9 / 15.8 | | | | | |
| **6** (reached 4/10) | **all ranged** | 34 | 0.92 / 6.87 | 3.68 / 10.03 | 7 (7, 7) | 38 % (71 %, 68 %) | 54 % | 1.1 / 6.9 / 13.7 | 0.74 (3) | 4.5 | 69 % | 51.7 | 2 |
| 7 (reached 2/10) | patrol_cop | 5 | 0.62 / 10.13 | 2.12 / 17.33 | 0 (0, 0) | 58 % (94 %, 93 %) | 45 % | 7.2 / 8.6 / 10.4 | | | | | |
| 7 (reached 2/10) | robot_gunner | 2 | 0.07 / 2.37 | 0.07 / 2.37 | 0 (0, 0) | 34 % (99 %, 99 %) | 52 % | 4.5 / 4.5 / 7.5 | | | | | |
| 7 (reached 2/10) | rocket_trooper | 2 | 0.82 / 1.07 | 1.28 / 4.22 | 0 (0, 0) | 36 % (76 %, 71 %) | 30 % | 10.7 / 11.6 / 17.7 | | | | | |
| 7 (reached 2/10) | sentry_turret | 7 | 3.8 / 5.12 | 5.47 / 8.23 | 0 (0, 0) | 12 % (30 %, 23 %) | 57 % | 4.1 / 8.5 / 15.4 | | | | | |
| 7 (reached 2/10) | swat | 3 | 2.82 / 5.2 | 2.82 / 5.2 | 1 (1, 1) | 50 % (96 %, 95 %) | 80 % | 4.6 / 5.1 / 7.6 | | | | | |
| **7** (reached 2/10) | **all ranged** | 19 | 2.82 / 5.2 | 4.22 / 8.23 | 1 (1, 1) | 33 % (63 %, 59 %) | 53 % | 4.5 / 8.5 / 15.1 | 0.98 (5) | 6 | 77 % | 32 | 0 |
| **1-4, 6-7** | **all ranged** | 512 | 0.67 / 3.67 | 1.82 / 5.05 | 148 (141, 139) | 51 % (89 %, 87 %) | 48 % | 4.7 / 8.9 / 13.1 | 0.83 (7) | 6.3 | 72 % | 21.1 | 2 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 28 | 6 | 34 | 140.8 |
| 4 | riot_cop | 25 | 12 | 28 | 93.8 |
| 6 | riot_cop | 1 | 0 | 2 | 8.1 |
| 6 | robot_thug | 10 | 0 | 21 | 65.9 |
| 7 | riot_cop | 3 | 0 | 3 | 7.7 |
| 7 | robot_thug | 2 | 0 | 2 | 9.6 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 4/10, 7: 2/10. Rivet shots probe = run result on 56/56 wave rows.

