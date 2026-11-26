# Foes waiting (n31)

Measured at c825715e8c205e64f70fd8f6bf18a6eb19628fd1, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.67 / 1.48 | 1.77 / 4.13 | 32 (32, 32) | 48 % (93 %, 91 %) | 59 % | 5.5 / 8.7 / 11.9 | | | | | |
| **1** | **all ranged** | 130 | 0.67 / 1.48 | 1.77 / 4.13 | 32 (32, 32) | 48 % (93 %, 91 %) | 59 % | 5.5 / 8.7 / 11.9 | 1.24 (7) | 7.3 | 78 % | 9.9 | 0 |
| 2 | patrol_cop | 140 | 0.62 / 1.55 | 1.68 / 3.88 | 48 (47, 45) | 50 % (93 %, 92 %) | 58 % | 5 / 8.7 / 12.2 | | | | | |
| **2** | **all ranged** | 140 | 0.62 / 1.55 | 1.68 / 3.88 | 48 (47, 45) | 50 % (93 %, 92 %) | 58 % | 5 / 8.7 / 12.2 | 1.17 (9) | 7.8 | 76 % | 7.8 | 0 |
| 3 | contractor | 25 | 0.5 / 1.97 | 1.8 / 4.98 | 3 (2, 2) | 43 % (93 %, 92 %) | 67 % | 6.2 / 9.1 / 11.3 | | | | | |
| 3 | patrol_cop | 21 | 0.77 / 2 | 2.6 / 7.7 | 4 (4, 4) | 50 % (92 %, 90 %) | 63 % | 4.7 / 8.9 / 11.4 | | | | | |
| 3 | rocket_trooper | 20 | 1.3 / 4.22 | 1.82 / 5.35 | 4 (4, 4) | 55 % (74 %, 73 %) | 64 % | 8.2 / 10.9 / 17.4 | | | | | |
| 3 | swat | 21 | 1.43 / 3.62 | 1.87 / 4.47 | 2 (1, 1) | 27 % (91 %, 90 %) | 88 % | 6.1 / 9.5 / 16 | | | | | |
| **3** | **all ranged** | 87 | 0.95 / 3.62 | 1.9 / 4.98 | 13 (11, 11) | 44 % (87 %, 86 %) | 70 % | 6.1 / 9.3 / 13.6 | 1.02 (8) | 5.3 | 71 % | 40.4 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.67 / 1.67 | 1.2 / 4.65 | 7 (6, 6) | 41 % (93 %, 92 %) | 77 % | 6.8 / 8.7 / 11.3 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.43 / 4 | 1.48 / 7.35 | 8 (8, 8) | 45 % (91 %, 89 %) | 74 % | 5.6 / 7.4 / 10.9 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 2.1 / 6.22 | 3.02 / 6.22 | 4 (3, 3) | 40 % (65 %, 64 %) | 42 % | 8.5 / 11.5 / 16.8 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.78 / 2.53 | 1.48 / 4.9 | 4 (3, 3) | 29 % (90 %, 89 %) | 87 % | 5.7 / 9.5 / 14.8 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.82 / 4.23 | 1.67 / 5.35 | 23 (20, 20) | 38 % (85 %, 83 %) | 69 % | 6.2 / 9 / 13.6 | 1.07 (7) | 5.5 | 80 % | 17 | 0 |
| 6 (reached 7/10) | contractor | 7 | 0.7 / 0.9 | 1.3 / 3.88 | 3 (3, 3) | 52 % (95 %, 93 %) | 76 % | 7.4 / 9 / 12.4 | | | | | |
| 6 (reached 7/10) | patrol_cop | 15 | 0.57 / 3.17 | 1.53 / 7.22 | 2 (2, 2) | 52 % (92 %, 91 %) | 65 % | 5.2 / 8 / 10.4 | | | | | |
| 6 (reached 7/10) | robot_gunner | 12 | 0.7 / 4.9 | 1.47 / 10.63 | 1 (1, 1) | 39 % (99 %, 99 %) | 55 % | 4 / 9.4 / 13.4 | | | | | |
| 6 (reached 7/10) | rocket_trooper | 6 | 1.67 / 2.17 | 1.67 / 4.32 | 4 (4, 4) | 39 % (62 %, 60 %) | 44 % | 8.7 / 12 / 14.1 | | | | | |
| 6 (reached 7/10) | sentry_turret | 11 | 3.75 / 7.07 | 5.77 / 16.98 | 2 (1, 1) | 5 % (28 %, 18 %) | 54 % | 1.1 / 13.6 / 15.8 | | | | | |
| 6 (reached 7/10) | swat | 6 | 0.92 / 2.95 | 1.53 / 3.48 | 0 (0, 0) | 26 % (89 %, 88 %) | 92 % | 7.1 / 11.2 / 15.6 | | | | | |
| **6** (reached 7/10) | **all ranged** | 57 | 0.85 / 4.65 | 1.67 / 9.52 | 12 (11, 11) | 35 % (78 %, 75 %) | 61 % | 1.3 / 11.6 / 15.6 | 0.82 (6) | 4.9 | 80 % | 56.4 | 2 |
| 7 (reached 5/10) | contractor | 9 | 0.4 / 7.38 | 3.22 / 7.38 | 4 (4, 1) | 49 % (95 %, 93 %) | 75 % | 4.9 / 11.4 / 14.4 | | | | | |
| 7 (reached 5/10) | patrol_cop | 5 | 1.67 / 12.02 | 1.88 / 14.17 | 1 (1, 1) | 41 % (93 %, 89 %) | 67 % | 6.8 / 8.9 / 12.7 | | | | | |
| 7 (reached 5/10) | robot_gunner | 10 | 0.67 / 2.78 | 1.08 / 4.4 | 1 (1, 1) | 32 % (99 %, 99 %) | 60 % | 5.8 / 10.4 / 12.6 | | | | | |
| 7 (reached 5/10) | rocket_trooper | 5 | 0.82 / 2.65 | 2.62 / 3.92 | 3 (3, 3) | 13 % (53 %, 47 %) | 49 % | 12 / 12.5 / 22.5 | | | | | |
| 7 (reached 5/10) | sentry_turret | 6 | 3.35 / 3.7 | 5.05 / 18.6 | 1 (1, 1) | 4 % (34 %, 14 %) | 50 % | 0.9 / 7 / 9 | | | | | |
| 7 (reached 5/10) | swat | 14 | 0.42 / 5.77 | 1.22 / 6.67 | 6 (6, 5) | 45 % (94 %, 92 %) | 86 % | 6.1 / 11.9 / 18.4 | | | | | |
| **7** (reached 5/10) | **all ranged** | 49 | 0.7 / 3.7 | 1.97 / 7.38 | 16 (16, 12) | 32 % (82 %, 77 %) | 66 % | 1.1 / 8.7 / 14 | 0.81 (5) | 5 | 79 % | 22.7 | 1 |
| **1-4, 6-7** | **all ranged** | 547 | 0.7 / 3.55 | 1.77 / 5.05 | 144 (137, 131) | 43 % (87 %, 85 %) | 64 % | 4.9 / 9.1 / 14.4 | 1.02 (9) | 6.1 | 77 % | 24.3 | 4 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 5 | 83 | 255.5 |
| 4 | riot_cop | 26 | 7 | 34 | 104.7 |
| 6 | riot_cop | 13 | 5 | 23 | 67.9 |
| 6 | robot_thug | 11 | 1 | 21 | 72 |
| 7 | riot_cop | 3 | 3 | 0 | 3.2 |
| 7 | robot_thug | 9 | 2 | 9 | 43.8 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 9/10, 6: 7/10, 7: 5/10. Rivet shots probe = run result on 60/60 wave rows.

