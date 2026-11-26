# Foes waiting (n31)

Measured at 89f6aab9a9a7559754ea798b306f41ddd6d569db, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.67 / 1.48 | 1.77 / 4.13 | 32 (32, 32) | 48 % (93 %, 91 %) | 59 % | 5.5 / 8.7 / 11.9 | | | | | |
| **1** | **all ranged** | 130 | 0.67 / 1.48 | 1.77 / 4.13 | 32 (32, 32) | 48 % (93 %, 91 %) | 59 % | 5.5 / 8.7 / 11.9 | 1.24 (7) | 7.3 | 78 % | 13.2 | 0 |
| 2 | patrol_cop | 140 | 0.63 / 1.55 | 1.68 / 3.75 | 48 (47, 45) | 49 % (93 %, 92 %) | 58 % | 5 / 8.6 / 12 | | | | | |
| **2** | **all ranged** | 140 | 0.63 / 1.55 | 1.68 / 3.75 | 48 (47, 45) | 49 % (93 %, 92 %) | 58 % | 5 / 8.6 / 12 | 1.17 (9) | 7.7 | 76 % | 9.6 | 0 |
| 3 | contractor | 25 | 0.5 / 2.03 | 1.8 / 4.98 | 3 (2, 2) | 47 % (94 %, 93 %) | 64 % | 6.2 / 9.1 / 11.3 | | | | | |
| 3 | patrol_cop | 21 | 0.7 / 2 | 2.6 / 7.7 | 4 (4, 4) | 52 % (92 %, 91 %) | 61 % | 4.4 / 8.3 / 11.1 | | | | | |
| 3 | rocket_trooper | 20 | 1.3 / 4.22 | 1.82 / 5.35 | 4 (4, 4) | 48 % (69 %, 69 %) | 68 % | 8.3 / 11.4 / 16.5 | | | | | |
| 3 | swat | 21 | 1.43 / 3.62 | 1.57 / 4.47 | 2 (1, 1) | 28 % (91 %, 90 %) | 88 % | 6.1 / 9.6 / 15.2 | | | | | |
| **3** | **all ranged** | 87 | 0.92 / 3.52 | 1.82 / 4.98 | 13 (11, 11) | 44 % (86 %, 84 %) | 69 % | 6.2 / 9.4 / 13 | 0.96 (8) | 5.3 | 72 % | 41 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.58 / 0.82 | 1.2 / 3.97 | 8 (7, 7) | 49 % (94 %, 93 %) | 71 % | 5.5 / 8.7 / 11.4 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.67 / 6.33 | 1.72 / 8.18 | 4 (4, 4) | 52 % (92 %, 91 %) | 77 % | 5.3 / 7.7 / 10.9 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 1.58 / 6.13 | 1.82 / 6.22 | 4 (3, 3) | 40 % (66 %, 64 %) | 42 % | 8.3 / 9.6 / 16.8 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.82 / 3.48 | 1.48 / 4.9 | 4 (3, 3) | 30 % (90 %, 89 %) | 89 % | 5.4 / 8.6 / 14.7 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.82 / 4.13 | 1.62 / 6.22 | 20 (17, 17) | 42 % (84 %, 83 %) | 67 % | 5.5 / 8.8 / 13.4 | 0.96 (7) | 5.5 | 76 % | 19.2 | 0 |
| 6 (reached 6/10) | contractor | 9 | 0.68 / 3.97 | 1.72 / 3.97 | 3 (3, 3) | 56 % (95 %, 95 %) | 61 % | 6.6 / 8.3 / 12.3 | | | | | |
| 6 (reached 6/10) | patrol_cop | 16 | 0.55 / 1.6 | 1.33 / 3.17 | 4 (4, 4) | 47 % (91 %, 89 %) | 77 % | 7.8 / 9.1 / 12.3 | | | | | |
| 6 (reached 6/10) | robot_gunner | 8 | 0.63 / 4.9 | 1.32 / 14.22 | 2 (2, 2) | 32 % (99 %, 99 %) | 51 % | 8.2 / 10.8 / 13.5 | | | | | |
| 6 (reached 6/10) | rocket_trooper | 10 | 2.17 / 6 | 2.42 / 6 | 2 (2, 2) | 60 % (74 %, 73 %) | 67 % | 8.7 / 13.1 / 16.3 | | | | | |
| 6 (reached 6/10) | sentry_turret | 6 | 3.92 / 7 | 6.88 / 21.95 | 0 (0, 0) | 10 % (36 %, 25 %) | 65 % | 1.1 / 6.6 / 17.3 | | | | | |
| 6 (reached 6/10) | swat | 4 | 0.92 / 1.58 | 0.92 / 1.58 | 0 (0, 0) | 16 % (86 %, 86 %) | 95 % | 7.6 / 11.9 / 13.6 | | | | | |
| **6** (reached 6/10) | **all ranged** | 53 | 0.92 / 4.3 | 1.72 / 6.88 | 11 (11, 11) | 41 % (78 %, 76 %) | 67 % | 1.3 / 9.6 / 15.6 | 0.96 (6) | 5.5 | 75 % | 63 | 2 |
| 7 (reached 4/10) | contractor | 8 | 0.47 / 6.85 | 3.42 / 6.85 | 4 (4, 3) | 43 % (96 %, 94 %) | 69 % | 6.2 / 10.8 / 14.1 | | | | | |
| 7 (reached 4/10) | patrol_cop | 3 | 0.53 / 1.78 | 1.78 / 3.47 | 0 (0, 0) | 47 % (89 %, 88 %) | 68 % | 6.9 / 9.6 / 12.7 | | | | | |
| 7 (reached 4/10) | robot_gunner | 8 | 0.67 / 1.25 | 1.23 / 1.97 | 1 (1, 1) | 36 % (99 %, 99 %) | 52 % | 5.9 / 10.1 / 12.6 | | | | | |
| 7 (reached 4/10) | rocket_trooper | 2 | 0.82 / 2.65 | 1.68 / 3.92 | 0 (0, 0) | 23 % (68 %, 64 %) | 48 % | 7.7 / 11.6 / 14.6 | | | | | |
| 7 (reached 4/10) | sentry_turret | 5 | 3.5 / 3.7 | 4.55 / 18.6 | 1 (1, 1) | 3 % (31 %, 17 %) | 54 % | 1.2 / 6.8 / 9.9 | | | | | |
| 7 (reached 4/10) | swat | 11 | 0.73 / 4.83 | 0.93 / 4.83 | 2 (2, 1) | 45 % (93 %, 92 %) | 86 % | 6.5 / 10.1 / 15.3 | | | | | |
| **7** (reached 4/10) | **all ranged** | 37 | 0.77 / 3.7 | 1.57 / 5.05 | 8 (8, 6) | 31 % (77 %, 73 %) | 65 % | 1.3 / 7.9 / 12.7 | 1 (5) | 5.3 | 77 % | 30.1 | 0 |
| **1-4, 6-7** | **all ranged** | 531 | 0.72 / 3.48 | 1.72 / 4.9 | 132 (126, 122) | 44 % (87 %, 84 %) | 64 % | 4.6 / 9 / 13.1 | 1.04 (9) | 6.3 | 75 % | 26.7 | 3 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 5 | 104 | 306.6 |
| 4 | riot_cop | 26 | 7 | 34 | 94.2 |
| 6 | riot_cop | 13 | 6 | 35 | 96.3 |
| 6 | robot_thug | 8 | 1 | 16 | 60.1 |
| 7 | riot_cop | 3 | 3 | 0 | 5.6 |
| 7 | robot_thug | 8 | 1 | 11 | 47.4 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 9/10, 6: 6/10, 7: 4/10. Rivet shots probe = run result on 58/58 wave rows.

