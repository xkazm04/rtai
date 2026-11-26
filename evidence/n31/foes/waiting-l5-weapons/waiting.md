# Foes waiting (n31)

Measured at live tree, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.6 / 2.92 | 2.07 / 5.77 | 52 (52, 52) | 71 % (97 %, 95 %) | 33 % | 5.8 / 9.4 / 12.1 | | | | | |
| **1** | **all ranged** | 130 | 0.6 / 2.92 | 2.07 / 5.77 | 52 (52, 52) | 71 % (97 %, 95 %) | 33 % | 5.8 / 9.4 / 12.1 | 0.74 (5) | 7.8 | 72 % | 11.7 | 0 |
| 2 | patrol_cop | 140 | 0.62 / 1.65 | 1.93 / 5.7 | 72 (71, 68) | 72 % (97 %, 95 %) | 32 % | 5.1 / 9 / 11.6 | | | | | |
| **2** | **all ranged** | 140 | 0.62 / 1.65 | 1.93 / 5.7 | 72 (71, 68) | 72 % (97 %, 95 %) | 32 % | 5.1 / 9 / 11.6 | 0.67 (5) | 8.3 | 70 % | 7.5 | 0 |
| 3 | contractor | 25 | 0.72 / 3.93 | 1.37 / 8.57 | 6 (6, 5) | 67 % (95 %, 94 %) | 44 % | 5.7 / 8.2 / 12.2 | | | | | |
| 3 | patrol_cop | 21 | 0.72 / 7.37 | 3.07 / 11.07 | 9 (8, 8) | 72 % (96 %, 94 %) | 40 % | 6.2 / 8.5 / 12.8 | | | | | |
| 3 | rocket_trooper | 20 | 2.33 / 18.48 | 3.37 / 20.48 | 11 (11, 11) | 71 % (83 %, 83 %) | 48 % | 7.4 / 9.2 / 12.1 | | | | | |
| 3 | swat | 21 | 1.7 / 3.37 | 1.82 / 4.28 | 6 (4, 4) | 62 % (93 %, 93 %) | 60 % | 6.4 / 10 / 15.9 | | | | | |
| **3** | **all ranged** | 87 | 1.18 / 4.67 | 2.6 / 8.57 | 32 (29, 28) | 68 % (91 %, 90 %) | 47 % | 6.3 / 9 / 13.7 | 0.64 (4) | 5.6 | 60 % | 27.9 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.8 / 2.48 | 1.87 / 3.68 | 13 (12, 12) | 72 % (97 %, 95 %) | 43 % | 4.6 / 8.4 / 11 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.62 / 1.8 | 1.42 / 3.52 | 7 (7, 7) | 70 % (96 %, 95 %) | 42 % | 6.6 / 8.8 / 11 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 1.07 / 2.28 | 1.67 / 2.68 | 15 (15, 15) | 77 % (85 %, 84 %) | 26 % | 7 / 12.3 / 18.3 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.85 / 2.63 | 1.82 / 3.33 | 4 (3, 3) | 67 % (95 %, 94 %) | 48 % | 7.4 / 11.1 / 14.8 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.8 / 2.28 | 1.72 / 3.52 | 39 (37, 37) | 70 % (94 %, 92 %) | 40 % | 7 / 9.7 / 13.4 | 0.52 (4) | 5.4 | 72 % | 7.9 | 0 |
| 6 (reached 4/10) | contractor | 8 | 0.8 / 10.1 | 1.75 / 10.1 | 2 (2, 2) | 81 % (97 %, 97 %) | 36 % | 5.4 / 9.1 / 11.6 | | | | | |
| 6 (reached 4/10) | patrol_cop | 11 | 0.58 / 19.38 | 1.67 / 19.38 | 5 (5, 5) | 70 % (95 %, 94 %) | 46 % | 5.3 / 8.2 / 11.7 | | | | | |
| 6 (reached 4/10) | robot_gunner | 3 | 0.68 / 0.77 | 1.23 / 2.72 | 1 (1, 1) | 83 % (99 %, 99 %) | 23 % | 3.1 / 7.9 / 15.4 | | | | | |
| 6 (reached 4/10) | rocket_trooper | 8 | 1.27 / 1.9 | 1.67 / 2.52 | 4 (4, 4) | 86 % (90 %, 90 %) | 50 % | 6.7 / 6.9 / 14 | | | | | |
| 6 (reached 4/10) | sentry_turret | 5 | 5.15 / 5.67 | 6.87 / 10.92 | 2 (2, 2) | 16 % (41 %, 31 %) | 58 % | 1 / 3.7 / 8.2 | | | | | |
| 6 (reached 4/10) | swat | 1 | 3.93 / 3.93 | 5.03 / 5.03 | 0 (0, 0) | 59 % (92 %, 91 %) | 64 % | 7 / 11.2 / 14.5 | | | | | |
| **6** (reached 4/10) | **all ranged** | 36 | 0.88 / 5.67 | 2.25 / 10.1 | 14 (14, 14) | 71 % (85 %, 84 %) | 45 % | 1.1 / 5.4 / 11.2 | 0.53 (4) | 5.9 | 52 % | 59.3 | 1 |
| 7 (reached 3/10) | contractor | 7 | 0.6 / 7.57 | 2.85 / 9.52 | 3 (3, 3) | 63 % (96 %, 94 %) | 45 % | 7.5 / 9.2 / 11.4 | | | | | |
| 7 (reached 3/10) | patrol_cop | 3 | 2.77 / 12.65 | 4.55 / 14.62 | 1 (1, 1) | 70 % (94 %, 93 %) | 43 % | 4.7 / 4.9 / 12.7 | | | | | |
| 7 (reached 3/10) | robot_gunner | 6 | 0.78 / 1.02 | 0.78 / 1.02 | 2 (2, 2) | 66 % (99 %, 99 %) | 45 % | 3.7 / 9.5 / 12.4 | | | | | |
| 7 (reached 3/10) | rocket_trooper | 6 | 1.22 / 2.43 | 1.67 / 4.65 | 3 (3, 3) | 58 % (79 %, 77 %) | 26 % | 8.7 / 10.4 / 18 | | | | | |
| 7 (reached 3/10) | sentry_turret | 5 | 3.83 / 4.38 | 6.7 / 13.23 | 0 (0, 0) | 18 % (41 %, 35 %) | 54 % | 2 / 6.9 / 15.5 | | | | | |
| 7 (reached 3/10) | swat | 5 | 0.77 / 3.67 | 1.88 / 7.03 | 1 (1, 0) | 71 % (96 %, 95 %) | 51 % | 6.3 / 11.3 / 16.3 | | | | | |
| **7** (reached 3/10) | **all ranged** | 32 | 1.02 / 4.38 | 3.57 / 10.9 | 10 (10, 9) | 52 % (78 %, 75 %) | 46 % | 2 / 7.4 / 15.5 | 0.86 (3) | 5.6 | 71 % | 45.9 | 1 |
| **1-4, 6-7** | **all ranged** | 509 | 0.72 / 3.57 | 1.95 / 6.37 | 219 (213, 208) | 69 % (92 %, 90 %) | 39 % | 3.9 / 8.6 / 12.7 | 0.65 (5) | 6.7 | 66 % | 19.9 | 3 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 3 | 97 | 248.6 |
| 4 | riot_cop | 26 | 9 | 22 | 75.6 |
| 6 | riot_cop | 8 | 1 | 46 | 98.8 |
| 6 | robot_thug | 6 | 1 | 9 | 31 |
| 7 | riot_cop | 2 | 2 | 0 | 4.9 |
| 7 | robot_thug | 3 | 0 | 5 | 15.7 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 9/10, 6: 4/10, 7: 3/10. Rivet shots probe = run result on 55/55 wave rows.

