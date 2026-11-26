# Foes waiting (n31)

Measured at c825715e8c205e64f70fd8f6bf18a6eb19628fd1, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.62 / 0.98 | 1.65 / 3.98 | 30 (29, 28) | 46 % (93 %, 91 %) | 56 % | 5.6 / 8.7 / 12 | | | | | |
| **1** | **all ranged** | 130 | 0.62 / 0.98 | 1.65 / 3.98 | 30 (29, 28) | 46 % (93 %, 91 %) | 56 % | 5.6 / 8.7 / 12 | 1.21 (7) | 7.5 | 75 % | 9.5 | 0 |
| 2 | patrol_cop | 140 | 0.58 / 1.05 | 1.62 / 3.37 | 39 (39, 37) | 49 % (93 %, 91 %) | 59 % | 5.9 / 9.5 / 12.4 | | | | | |
| **2** | **all ranged** | 140 | 0.58 / 1.05 | 1.62 / 3.37 | 39 (39, 37) | 49 % (93 %, 91 %) | 59 % | 5.9 / 9.5 / 12.4 | 1.23 (8) | 7.4 | 78 % | 9.9 | 0 |
| 3 | contractor | 17 | 0.62 / 0.88 | 1.83 / 3.55 | 2 (2, 2) | 46 % (94 %, 92 %) | 73 % | 7.5 / 10.3 / 13.1 | | | | | |
| 3 | patrol_cop | 25 | 0.57 / 4.12 | 1.28 / 6.3 | 3 (3, 3) | 52 % (92 %, 91 %) | 69 % | 5.4 / 8.7 / 11.1 | | | | | |
| 3 | rocket_trooper | 18 | 1.07 / 7.05 | 1.63 / 7.05 | 2 (2, 2) | 32 % (62 %, 61 %) | 55 % | 8.6 / 11.4 / 15.2 | | | | | |
| 3 | swat | 28 | 0.72 / 1.83 | 1.25 / 2.87 | 7 (7, 7) | 38 % (92 %, 91 %) | 88 % | 6 / 9.6 / 14.3 | | | | | |
| **3** | **all ranged** | 88 | 0.75 / 2.7 | 1.48 / 4.08 | 14 (14, 14) | 40 % (81 %, 79 %) | 70 % | 6.3 / 9.9 / 13.9 | 1.15 (6) | 5.8 | 80 % | 24.6 | 0 |
| 4 | contractor | 20 | 0.55 / 2.05 | 1.48 / 3.72 | 4 (4, 4) | 56 % (94 %, 94 %) | 71 % | 5.8 / 9.6 / 12.7 | | | | | |
| 4 | patrol_cop | 28 | 0.65 / 1.25 | 1.6 / 3.85 | 3 (3, 3) | 55 % (93 %, 92 %) | 63 % | 6.2 / 9.3 / 11.2 | | | | | |
| 4 | rocket_trooper | 25 | 1.43 / 8.95 | 1.9 / 8.95 | 4 (4, 4) | 50 % (70 %, 69 %) | 62 % | 7.6 / 9.9 / 16.2 | | | | | |
| 4 | swat | 28 | 0.72 / 3.02 | 1.42 / 4.08 | 6 (6, 6) | 40 % (92 %, 91 %) | 85 % | 6.4 / 11.5 / 15.5 | | | | | |
| **4** | **all ranged** | 101 | 0.82 / 3.77 | 1.62 / 4.05 | 17 (17, 17) | 51 % (85 %, 84 %) | 68 % | 6.4 / 10.2 / 14 | 0.91 (8) | 5.9 | 72 % | 30.6 | 1 |
| 6 (reached 5/10) | contractor | 7 | 0.88 / 2.02 | 1.68 / 5.98 | 0 (0, 0) | 41 % (91 %, 90 %) | 91 % | 4.9 / 8.2 / 10.3 | | | | | |
| 6 (reached 5/10) | patrol_cop | 13 | 0.72 / 2.18 | 2.18 / 6.38 | 2 (2, 2) | 62 % (94 %, 93 %) | 60 % | 5.4 / 8.9 / 11.5 | | | | | |
| 6 (reached 5/10) | robot_gunner | 6 | 0.62 / 1.82 | 1.63 / 2.63 | 0 (0, 0) | 36 % (99 %, 99 %) | 68 % | 5 / 9 / 14.7 | | | | | |
| 6 (reached 5/10) | rocket_trooper | 8 | 0.83 / 5.98 | 2.5 / 5.98 | 2 (1, 1) | 24 % (63 %, 60 %) | 40 % | 8.7 / 10.1 / 16 | | | | | |
| 6 (reached 5/10) | sentry_turret | 7 | 3.82 / 6.47 | 5.18 / 6.47 | 1 (1, 1) | 3 % (24 %, 18 %) | 61 % | 1.1 / 5.2 / 20.7 | | | | | |
| 6 (reached 5/10) | swat | 7 | 0.42 / 0.8 | 0.43 / 1.15 | 3 (1, 1) | 34 % (88 %, 87 %) | 88 % | 6.3 / 8 / 14.7 | | | | | |
| **6** (reached 5/10) | **all ranged** | 48 | 0.82 / 4.02 | 2.02 / 5.98 | 8 (5, 5) | 37 % (78 %, 76 %) | 66 % | 1.1 / 7.2 / 13.4 | 1.15 (8) | 5.6 | 77 % | 59.2 | 1 |
| 7 (reached 4/10) | contractor | 2 | 0.4 / 0.77 | 0.97 / 1.5 | 0 (0, 0) | 37 % (90 %, 89 %) | 91 % | 6.2 / 8.5 / 10.5 | | | | | |
| 7 (reached 4/10) | patrol_cop | 7 | 0.6 / 4.45 | 1.6 / 9.27 | 1 (1, 1) | 35 % (90 %, 86 %) | 66 % | 6.7 / 8.9 / 13 | | | | | |
| 7 (reached 4/10) | robot_gunner | 7 | 0.78 / 2.45 | 1.07 / 2.62 | 1 (1, 1) | 54 % (99 %, 99 %) | 45 % | 6.4 / 10.9 / 16 | | | | | |
| 7 (reached 4/10) | rocket_trooper | 5 | 2.18 / 3.1 | 3.33 / 3.7 | 0 (0, 0) | 35 % (66 %, 65 %) | 52 % | 7.5 / 11.5 / 17.8 | | | | | |
| 7 (reached 4/10) | sentry_turret | 8 | 3.75 / 7.07 | 4.7 / 14 | 1 (1, 1) | 4 % (24 %, 13 %) | 55 % | 1.1 / 8.3 / 13.4 | | | | | |
| 7 (reached 4/10) | swat | 6 | 0.58 / 1.05 | 0.95 / 2.12 | 0 (0, 0) | 36 % (90 %, 90 %) | 89 % | 7.3 / 11.8 / 16 | | | | | |
| **7** (reached 4/10) | **all ranged** | 35 | 0.82 / 3.95 | 2.07 / 5.93 | 3 (3, 3) | 33 % (73 %, 70 %) | 61 % | 1.2 / 8.8 / 14.7 | 1.15 (5) | 5.8 | 83 % | 59.5 | 1 |
| **1-4, 6-7** | **all ranged** | 542 | 0.7 / 2.42 | 1.67 / 4.1 | 111 (107, 104) | 44 % (85 %, 83 %) | 64 % | 4.5 / 9 / 13.3 | 1.12 (8) | 6.5 | 77 % | 26.1 | 3 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 28 | 4 | 51 | 176.9 |
| 4 | riot_cop | 25 | 14 | 58 | 158.8 |
| 6 | riot_cop | 2 | 2 | 0 | 9.3 |
| 6 | robot_thug | 10 | 0 | 25 | 105.5 |
| 7 | riot_cop | 10 | 5 | 18 | 65.7 |
| 7 | robot_thug | 4 | 2 | 5 | 33.6 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 9/10, 6: 5/10, 7: 4/10. Rivet shots probe = run result on 58/58 wave rows.

