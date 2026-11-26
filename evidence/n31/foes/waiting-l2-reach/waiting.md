# Foes waiting (n31)

Measured at live tree, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.93 / 3.08 | 1.45 / 5.2 | 53 (53, 53) | 75 % (96 %, 95 %) | 31 % | 6 / 10.6 / 15.8 | | | | | |
| **1** | **all ranged** | 130 | 0.93 / 3.08 | 1.45 / 5.2 | 53 (53, 53) | 75 % (96 %, 95 %) | 31 % | 6 / 10.6 / 15.8 | 0.84 (6) | 7.9 | 76 % | 10.8 | 0 |
| 2 | patrol_cop | 140 | 0.85 / 2.5 | 1.45 / 5.35 | 63 (61, 61) | 73 % (96 %, 96 %) | 32 % | 5.5 / 9.3 / 14.9 | | | | | |
| **2** | **all ranged** | 140 | 0.85 / 2.5 | 1.45 / 5.35 | 63 (61, 61) | 73 % (96 %, 96 %) | 32 % | 5.5 / 9.3 / 14.9 | 0.78 (5) | 7.7 | 68 % | 8.4 | 0 |
| 3 | contractor | 25 | 0.8 / 2.42 | 1.38 / 4.2 | 4 (4, 4) | 63 % (93 %, 93 %) | 47 % | 6.2 / 9.5 / 15.2 | | | | | |
| 3 | patrol_cop | 21 | 0.77 / 5.72 | 2.8 / 9.83 | 6 (4, 4) | 70 % (95 %, 95 %) | 36 % | 5 / 8.7 / 14.3 | | | | | |
| 3 | rocket_trooper | 20 | 2.63 / 3.7 | 3.33 / 3.83 | 9 (9, 9) | 55 % (77 %, 77 %) | 39 % | 7.9 / 10.3 / 18.1 | | | | | |
| 3 | swat | 21 | 1.17 / 6.82 | 1.37 / 6.82 | 5 (5, 5) | 64 % (93 %, 93 %) | 54 % | 5.5 / 9.6 / 17.9 | | | | | |
| **3** | **all ranged** | 87 | 0.97 / 5.02 | 1.75 / 6.52 | 24 (22, 22) | 63 % (90 %, 90 %) | 44 % | 6 / 9.5 / 16.3 | 0.8 (5) | 5.3 | 67 % | 19.5 | 0 |
| 4 | contractor | 25 | 0.83 / 2.53 | 1.25 / 3.32 | 11 (11, 11) | 77 % (96 %, 96 %) | 38 % | 4.8 / 11.3 / 16.7 | | | | | |
| 4 | patrol_cop | 22 | 0.83 / 12 | 1.38 / 12 | 5 (5, 5) | 72 % (95 %, 95 %) | 35 % | 5.5 / 10.5 / 14.6 | | | | | |
| 4 | rocket_trooper | 22 | 1.53 / 6.75 | 1.9 / 7.35 | 11 (11, 11) | 72 % (83 %, 82 %) | 38 % | 7.8 / 9.9 / 16.1 | | | | | |
| 4 | swat | 25 | 0.93 / 5.37 | 0.93 / 5.37 | 8 (8, 8) | 60 % (93 %, 92 %) | 58 % | 6.2 / 11.7 / 17 | | | | | |
| **4** | **all ranged** | 94 | 1.07 / 5.37 | 1.48 / 6.68 | 35 (35, 35) | 71 % (91 %, 91 %) | 40 % | 5.5 / 11.2 / 16 | 0.58 (4) | 6.1 | 68 % | 18.4 | 0 |
| 6 (reached 6/10) | contractor | 9 | 0.83 / 4.3 | 1.92 / 7.92 | 3 (2, 2) | 83 % (98 %, 98 %) | 38 % | 4.9 / 9.4 / 15.5 | | | | | |
| 6 (reached 6/10) | patrol_cop | 15 | 0.83 / 10.1 | 1.85 / 10.1 | 3 (2, 2) | 61 % (92 %, 92 %) | 51 % | 6.2 / 10.1 / 15.4 | | | | | |
| 6 (reached 6/10) | robot_gunner | 8 | 0.9 / 6.18 | 1.72 / 6.88 | 2 (2, 2) | 62 % (99 %, 99 %) | 37 % | 7.1 / 10.8 / 12.9 | | | | | |
| 6 (reached 6/10) | rocket_trooper | 12 | 1.75 / 7.07 | 1.75 / 7.3 | 4 (4, 4) | 58 % (77 %, 76 %) | 36 % | 7.8 / 10.3 / 13.5 | | | | | |
| 6 (reached 6/10) | sentry_turret | 6 | 4.6 / 7.3 | 4.6 / 15.47 | 2 (2, 2) | 18 % (33 %, 28 %) | 47 % | 1 / 3.9 / 7.3 | | | | | |
| 6 (reached 6/10) | swat | 4 | 0.77 / 1.53 | 0.77 / 1.58 | 0 (0, 0) | 50 % (89 %, 89 %) | 65 % | 9.9 / 15 / 25.1 | | | | | |
| **6** (reached 6/10) | **all ranged** | 54 | 1.27 / 7.03 | 1.92 / 7.92 | 14 (12, 12) | 59 % (83 %, 83 %) | 43 % | 1.1 / 8.2 / 15 | 0.72 (4) | 5.4 | 63 % | 30.1 | 0 |
| 7 (reached 6/10) | contractor | 15 | 1.65 / 8.7 | 2.47 / 9.32 | 6 (6, 6) | 76 % (96 %, 96 %) | 42 % | 6.4 / 10.1 / 13.7 | | | | | |
| 7 (reached 6/10) | patrol_cop | 11 | 1.27 / 14.8 | 1.27 / 14.8 | 3 (3, 3) | 73 % (97 %, 96 %) | 33 % | 5.4 / 6.8 / 10.8 | | | | | |
| 7 (reached 6/10) | robot_gunner | 10 | 0.78 / 4.12 | 0.8 / 4.12 | 2 (2, 2) | 64 % (99 %, 99 %) | 53 % | 6.5 / 10 / 13.9 | | | | | |
| 7 (reached 6/10) | rocket_trooper | 12 | 1.48 / 4.2 | 3.4 / 5.02 | 7 (7, 7) | 51 % (74 %, 73 %) | 42 % | 8.4 / 10.4 / 12.3 | | | | | |
| 7 (reached 6/10) | sentry_turret | 4 | 5.12 / 5.58 | 6.63 / 9.92 | 1 (1, 1) | 12 % (38 %, 26 %) | 48 % | 1.3 / 7 / 11.8 | | | | | |
| 7 (reached 6/10) | swat | 15 | 0.82 / 2.65 | 1.48 / 2.65 | 1 (1, 1) | 61 % (93 %, 92 %) | 58 % | 5 / 10.9 / 23.4 | | | | | |
| **7** (reached 6/10) | **all ranged** | 67 | 1.2 / 5.95 | 1.72 / 9.32 | 20 (20, 20) | 59 % (85 %, 84 %) | 45 % | 4.5 / 9.1 / 13.8 | 0.92 (4) | 6.2 | 72 % | 38.6 | 1 |
| **1-4, 6-7** | **all ranged** | 572 | 1.02 / 4.6 | 1.65 / 6.27 | 209 (203, 203) | 67 % (91 %, 90 %) | 39 % | 4.9 / 9.7 / 15.5 | 0.77 (6) | 6.5 | 69 % | 18.9 | 1 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 6 | 34 | 153.7 |
| 4 | riot_cop | 28 | 5 | 46 | 119.3 |
| 6 | riot_cop | 12 | 4 | 25 | 73.4 |
| 6 | robot_thug | 8 | 0 | 14 | 38.6 |
| 7 | riot_cop | 5 | 2 | 11 | 32.1 |
| 7 | robot_thug | 7 | 4 | 7 | 37.3 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 6/10, 7: 6/10. Rivet shots probe = run result on 62/62 wave rows.

