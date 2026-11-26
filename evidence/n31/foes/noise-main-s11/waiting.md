# Foes waiting (n31)

Measured at ba8e470b0fdfc796c4eb8d256bd086d4d7cfa969, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.98 / 3.75 | 3.77 / 10.07 | 37 (35, 32) | 71 % (93 %, 90 %) | 19 % | 3.6 / 8.7 / 12.4 | | | | | |
| **1** | **all ranged** | 130 | 0.98 / 3.75 | 3.77 / 10.07 | 37 (35, 32) | 71 % (93 %, 90 %) | 19 % | 3.6 / 8.7 / 12.4 | 0.96 (4) | 7.8 | 68 % | 10.3 | 0 |
| 2 | patrol_cop | 140 | 0.98 / 3.53 | 3.92 / 7.42 | 42 (39, 33) | 72 % (94 %, 91 %) | 18 % | 4.5 / 8.8 / 11.6 | | | | | |
| **2** | **all ranged** | 140 | 0.98 / 3.53 | 3.92 / 7.42 | 42 (39, 33) | 72 % (94 %, 91 %) | 18 % | 4.5 / 8.8 / 11.6 | 1.15 (4) | 7.9 | 63 % | 12.2 | 0 |
| 3 | contractor | 17 | 0.57 / 4.07 | 2.98 / 7.03 | 2 (2, 2) | 48 % (84 %, 81 %) | 44 % | 3.5 / 8.1 / 10.2 | | | | | |
| 3 | patrol_cop | 25 | 0.73 / 3.92 | 3.1 / 7.28 | 4 (4, 4) | 62 % (88 %, 85 %) | 28 % | 3.1 / 7.4 / 10.9 | | | | | |
| 3 | rocket_trooper | 18 | 2.2 / 5.1 | 3.17 / 5.1 | 13 (13, 13) | 85 % (92 %, 92 %) | 22 % | 7 / 8.7 / 14.4 | | | | | |
| 3 | swat | 28 | 1.78 / 6.9 | 2.02 / 6.9 | 9 (6, 6) | 51 % (82 %, 81 %) | 42 % | 3.9 / 7.4 / 12.1 | | | | | |
| **3** | **all ranged** | 88 | 1.27 / 4.07 | 2.63 / 6.9 | 28 (25, 25) | 62 % (87 %, 85 %) | 35 % | 3.6 / 7.7 / 11 | 0.94 (3) | 4.9 | 61 % | 24.8 | 0 |
| 4 | contractor | 20 | 0.6 / 5.5 | 2.28 / 7.3 | 4 (4, 4) | 59 % (88 %, 86 %) | 31 % | 3.1 / 8.3 / 12.6 | | | | | |
| 4 | patrol_cop | 28 | 0.8 / 9.78 | 4.85 / 11.85 | 7 (6, 4) | 68 % (91 %, 88 %) | 27 % | 3.4 / 7.1 / 11.1 | | | | | |
| 4 | rocket_trooper | 25 | 2.05 / 4.48 | 2.05 / 4.48 | 21 (18, 18) | 88 % (93 %, 93 %) | 21 % | 8.2 / 8.2 / 11.9 | | | | | |
| 4 | swat | 28 | 0.55 / 2.95 | 1.72 / 3.85 | 7 (6, 6) | 54 % (83 %, 81 %) | 41 % | 4.5 / 10.1 / 14.5 | | | | | |
| **4** | **all ranged** | 101 | 1 / 4.48 | 2.58 / 8.57 | 39 (34, 32) | 67 % (89 %, 87 %) | 30 % | 3.8 / 8.7 / 12.6 | 1.02 (4) | 5.4 | 70 % | 17.5 | 0 |
| 6 (reached 4/10) | contractor | 5 | 0.52 / 2.37 | 1.17 / 3.62 | 1 (1, 1) | 64 % (89 %, 88 %) | 25 % | 5.1 / 9.1 / 12.8 | | | | | |
| 6 (reached 4/10) | patrol_cop | 10 | 2.65 / 10.73 | 4.45 / 15.45 | 1 (1, 1) | 71 % (93 %, 90 %) | 29 % | 6.6 / 9.8 / 12.8 | | | | | |
| 6 (reached 4/10) | robot_gunner | 6 | 1.02 / 3.53 | 1.02 / 6.32 | 0 (0, 0) | 49 % (76 %, 74 %) | 31 % | 2.5 / 9.6 / 13.4 | | | | | |
| 6 (reached 4/10) | rocket_trooper | 7 | 4.13 / 10 | 5.58 / 10 | 5 (5, 5) | 68 % (83 %, 82 %) | 21 % | 9.5 / 10.4 / 13 | | | | | |
| 6 (reached 4/10) | sentry_turret | 5 | 3.97 / 8.57 | 5.1 / 9.82 | 1 (1, 1) | 32 % (50 %, 46 %) | 45 % | 1.1 / 2.6 / 7.8 | | | | | |
| 6 (reached 4/10) | swat | 2 | 1.93 / 4.02 | 2.2 / 8.78 | 0 (0, 0) | 45 % (79 %, 78 %) | 40 % | 4 / 9.6 / 11.8 | | | | | |
| **6** (reached 4/10) | **all ranged** | 35 | 3.12 / 8.57 | 4.45 / 10 | 8 (8, 8) | 54 % (77 %, 74 %) | 32 % | 1.4 / 7.7 / 12.7 | 1.14 (4) | 5.6 | 79 % | 65.2 | 1 |
| 7 (reached 3/10) | contractor | 3 | 0.35 / 0.55 | 0.55 / 0.97 | 1 (1, 1) | 58 % (87 %, 83 %) | 49 % | 6.3 / 7.3 / 10 | | | | | |
| 7 (reached 3/10) | patrol_cop | 3 | 0.4 / 4.8 | 0.8 / 4.8 | 0 (0, 0) | 50 % (78 %, 72 %) | 34 % | 6 / 9.3 / 11.4 | | | | | |
| 7 (reached 3/10) | robot_gunner | 4 | 1.75 / 2 | 2.18 / 3.97 | 1 (0, 0) | 45 % (77 %, 76 %) | 49 % | 5.1 / 9.7 / 11.4 | | | | | |
| 7 (reached 3/10) | rocket_trooper | 6 | 8.12 / 10.18 | 8.55 / 10.18 | 3 (3, 2) | 50 % (77 %, 75 %) | 36 % | 8.6 / 12.2 / 14.1 | | | | | |
| 7 (reached 3/10) | sentry_turret | 2 | 4.17 / 4.17 | 4.17 / 4.17 | 0 (0, 0) | 13 % (30 %, 30 %) | 40 % | 6.5 / 8.7 / 9.5 | | | | | |
| 7 (reached 3/10) | swat | 6 | 0.22 / 1.58 | 0.28 / 6.22 | 0 (0, 0) | 45 % (80 %, 77 %) | 45 % | 6.3 / 10.9 / 17.3 | | | | | |
| **7** (reached 3/10) | **all ranged** | 24 | 1.12 / 8.12 | 2.47 / 8.55 | 5 (4, 3) | 41 % (69 %, 67 %) | 42 % | 6.3 / 9.2 / 11.5 | 0.93 (3) | 3.4 | 52 % | 50 | 1 |
| **1-4, 6-7** | **all ranged** | 518 | 1.08 / 4.35 | 3.35 / 8.57 | 159 (145, 133) | 64 % (88 %, 85 %) | 26 % | 3.4 / 8.6 / 12.1 | 1.02 (4) | 6.2 | 66 % | 22.5 | 2 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 28 | 5 | 47 | 141 |
| 4 | riot_cop | 25 | 13 | 14 | 72.3 |
| 6 | riot_cop | 5 | 4 | 1 | 8.9 |
| 6 | robot_thug | 8 | 2 | 8 | 56 |
| 7 | riot_cop | 8 | 5 | 6 | 35.3 |
| 7 | robot_thug | 6 | 1 | 15 | 57.6 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 4/10, 7: 3/10. Rivet shots probe = run result on 57/57 wave rows.

