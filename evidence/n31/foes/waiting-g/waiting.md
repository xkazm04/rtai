# Foes waiting (n31)

Measured at a4224e310428d536de332ec48f57fa0a00a86560, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.63 / 1.88 | 1.7 / 5.42 | 46 (46, 46) | 58 % (96 %, 94 %) | 41 % | 5.5 / 9.2 / 12.4 | | | | | |
| **1** | **all ranged** | 130 | 0.63 / 1.88 | 1.7 / 5.42 | 46 (46, 46) | 58 % (96 %, 94 %) | 41 % | 5.5 / 9.2 / 12.4 | 0.81 (6) | 7.5 | 74 % | 12.3 | 0 |
| 2 | patrol_cop | 140 | 0.6 / 1.52 | 1.65 / 5.35 | 51 (50, 49) | 56 % (96 %, 94 %) | 43 % | 5.4 / 8.9 / 11.2 | | | | | |
| **2** | **all ranged** | 140 | 0.6 / 1.52 | 1.65 / 5.35 | 51 (50, 49) | 56 % (96 %, 94 %) | 43 % | 5.4 / 8.9 / 11.2 | 0.81 (7) | 7.6 | 77 % | 9.9 | 0 |
| 3 | contractor | 25 | 0.58 / 1.77 | 1.35 / 5.08 | 6 (6, 5) | 51 % (95 %, 94 %) | 48 % | 5.8 / 8.7 / 13.8 | | | | | |
| 3 | patrol_cop | 21 | 0.7 / 4.92 | 1.63 / 6.53 | 8 (6, 6) | 70 % (98 %, 97 %) | 43 % | 7.4 / 9.4 / 11.9 | | | | | |
| 3 | rocket_trooper | 20 | 2.35 / 3.7 | 3.18 / 4.38 | 7 (7, 7) | 49 % (74 %, 73 %) | 46 % | 7 / 11.9 / 18.3 | | | | | |
| 3 | swat | 21 | 1.57 / 2.4 | 2.1 / 3.23 | 4 (3, 3) | 40 % (92 %, 92 %) | 66 % | 7.7 / 10.3 / 14.3 | | | | | |
| **3** | **all ranged** | 87 | 0.9 / 3.3 | 2.1 / 4.53 | 25 (22, 21) | 53 % (91 %, 90 %) | 50 % | 6.3 / 9.8 / 14.4 | 0.72 (5) | 5.3 | 69 % | 19.6 | 0 |
| 4 | contractor | 25 | 0.82 / 5.15 | 1.48 / 6.1 | 10 (9, 8) | 57 % (96 %, 95 %) | 50 % | 5 / 7.2 / 12.4 | | | | | |
| 4 | patrol_cop | 22 | 0.67 / 13.48 | 1.57 / 13.48 | 5 (5, 5) | 66 % (96 %, 96 %) | 41 % | 5.3 / 8.5 / 11.2 | | | | | |
| 4 | rocket_trooper | 22 | 2.1 / 4.58 | 2.78 / 5.65 | 9 (8, 8) | 59 % (76 %, 75 %) | 50 % | 7.6 / 9.5 / 13.2 | | | | | |
| 4 | swat | 25 | 0.9 / 2.95 | 1.17 / 3.57 | 2 (2, 2) | 45 % (93 %, 92 %) | 67 % | 5.1 / 9.4 / 14 | | | | | |
| **4** | **all ranged** | 94 | 0.9 / 5.43 | 1.55 / 8.18 | 26 (24, 23) | 57 % (90 %, 89 %) | 51 % | 5.1 / 9 / 13 | 0.76 (5) | 5.7 | 75 % | 32.6 | 0 |
| 6 (reached 4/10) | contractor | 5 | 0.68 / 2.07 | 3.02 / 3.68 | 2 (2, 2) | 69 % (97 %, 97 %) | 66 % | 7.5 / 8.8 / 10.6 | | | | | |
| 6 (reached 4/10) | patrol_cop | 10 | 0.63 / 7.63 | 1.58 / 11.27 | 1 (1, 1) | 43 % (94 %, 92 %) | 56 % | 5.2 / 11.3 / 13.8 | | | | | |
| 6 (reached 4/10) | robot_gunner | 6 | 1.03 / 4.78 | 1.12 / 5.77 | 0 (0, 0) | 27 % (99 %, 99 %) | 62 % | 9.2 / 11.1 / 15.4 | | | | | |
| 6 (reached 4/10) | rocket_trooper | 3 | - / - | - / - | 3 (3, 3) | 100 % (100 %, 100 %) | 16 % | - / - / - | | | | | |
| 6 (reached 4/10) | sentry_turret | 6 | 4.48 / 6.88 | 7.48 / 16 | 1 (1, 1) | 15 % (37 %, 26 %) | 62 % | 1 / 2.5 / 11.6 | | | | | |
| 6 (reached 4/10) | swat | 4 | 0.55 / 0.58 | 0.55 / 0.58 | 2 (2, 2) | 22 % (88 %, 88 %) | 92 % | 7.8 / 12.3 / 15 | | | | | |
| **6** (reached 4/10) | **all ranged** | 34 | 1.1 / 4.88 | 1.7 / 10.77 | 9 (9, 9) | 35 % (77 %, 74 %) | 62 % | 1 / 9 / 12.4 | 0.63 (4) | 3.9 | 81 % | 40 | 0 |
| 7 (reached 4/10) | contractor | 9 | 0.58 / 0.92 | 0.92 / 2.85 | 3 (2, 2) | 53 % (94 %, 93 %) | 56 % | 5.9 / 9.2 / 13.2 | | | | | |
| 7 (reached 4/10) | patrol_cop | 5 | 3.23 / 10.58 | 3.23 / 12.57 | 3 (3, 3) | 74 % (98 %, 95 %) | 43 % | 8.5 / 11.5 / 11.9 | | | | | |
| 7 (reached 4/10) | robot_gunner | 9 | 0.75 / 7.67 | 1.05 / 7.67 | 2 (2, 2) | 32 % (99 %, 99 %) | 56 % | 6 / 10.6 / 12.7 | | | | | |
| 7 (reached 4/10) | rocket_trooper | 5 | 1.22 / 4.87 | 1.22 / 7.12 | 3 (2, 2) | 69 % (84 %, 83 %) | 39 % | 8.3 / 9.1 / 10.2 | | | | | |
| 7 (reached 4/10) | sentry_turret | 4 | 2.8 / 4.77 | 2.8 / 6.12 | 0 (0, 0) | 17 % (37 %, 32 %) | 65 % | 1.1 / 6.7 / 10.4 | | | | | |
| 7 (reached 4/10) | swat | 8 | 0.72 / 2.15 | 1.55 / 2.15 | 3 (1, 1) | 42 % (93 %, 93 %) | 61 % | 8.1 / 11.9 / 15.7 | | | | | |
| **7** (reached 4/10) | **all ranged** | 40 | 0.77 / 4.87 | 1.58 / 7.12 | 14 (10, 10) | 42 % (85 %, 83 %) | 54 % | 1.1 / 8.8 / 12.7 | 0.89 (5) | 5.5 | 77 % | 37.9 | 1 |
| **1-4, 6-7** | **all ranged** | 525 | 0.72 / 3.23 | 1.67 / 5.87 | 171 (161, 158) | 53 % (91 %, 90 %) | 48 % | 4.3 / 9.2 / 12.7 | 0.76 (7) | 6.2 | 75 % | 22 | 1 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 9 | 26 | 139.4 |
| 4 | riot_cop | 28 | 5 | 71 | 181.4 |
| 6 | riot_cop | 7 | 5 | 2 | 20.5 |
| 6 | robot_thug | 6 | 0 | 11 | 29.6 |
| 7 | riot_cop | 2 | 2 | 0 | 5.8 |
| 7 | robot_thug | 7 | 3 | 4 | 18.8 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 10/10, 5: 10/10, 6: 4/10, 7: 4/10. Rivet shots probe = run result on 58/58 wave rows.

