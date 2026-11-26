# Foes waiting (n31)

Measured at 1d3c89804426284f8545474742ac27a0ca20812d, gauntlet --controls=wheel --pick=greedy --waves=7.

react = seconds from a first clear line to Rivet (inside the weapon range, or at any distance) to the first round; idle share = enemy-seconds with a clear line inside the weapon range and not engaged / those enemy-seconds, where engaged = a round within the last burst + cooldown + 0.1 s of the weapon it fires, a wind-up, a burst or the FoeGait settle window; strict = the old rule (no round, wind-up or burst this tick), over every clear-line second and inside the range; pressing share = wave seconds with >= 3 ranged alive where engaged + advancing (TRAVEL or legacy, > 0.5 m/s toward Rivet, or walking to a spot inside attack_m with a clear line) >= max(3, ceil(ranged alive / 3)); token share = enemy-seconds holding a squad shooting token / enemy-seconds alive. Wave 5 (the stomp) is measured in waiting.json but left out of this table and the totals.

## average (10 seeds: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

| wave | archetype | n | react in range p50 / p90 s | react any dist p50 / p90 s | never fired (clear line, in range) | idle share (strict: any, in range) | token share | shot dist p10 / p50 / p90 m | firing / s mean (max) | ranged alive | pressing share | dmg taken mean | deaths |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | patrol_cop | 130 | 0.72 / 2.42 | 1.8 / 4.3 | 36 (36, 35) | 51 % (94 %, 92 %) | 46 % | 5.1 / 8.6 / 11.7 | | | | | |
| **1** | **all ranged** | 130 | 0.72 / 2.42 | 1.8 / 4.3 | 36 (36, 35) | 51 % (94 %, 92 %) | 46 % | 5.1 / 8.6 / 11.7 | 1.1 (6) | 7.2 | 72 % | 18.6 | 0 |
| 2 | patrol_cop | 140 | 0.62 / 2.02 | 1.73 / 4 | 56 (56, 56) | 53 % (94 %, 93 %) | 45 % | 5.7 / 9.1 / 12 | | | | | |
| **2** | **all ranged** | 140 | 0.62 / 2.02 | 1.73 / 4 | 56 (56, 56) | 53 % (94 %, 93 %) | 45 % | 5.7 / 9.1 / 12 | 1 (7) | 8 | 73 % | 12.9 | 0 |
| 3 | contractor | 25 | 0.5 / 1.97 | 1.35 / 6.18 | 6 (6, 6) | 61 % (96 %, 95 %) | 48 % | 5.7 / 9.6 / 13.3 | | | | | |
| 3 | patrol_cop | 21 | 0.85 / 13.07 | 3.13 / 13.58 | 4 (3, 3) | 54 % (95 %, 94 %) | 45 % | 6.7 / 8.5 / 11.2 | | | | | |
| 3 | rocket_trooper | 20 | 2.37 / 4.2 | 3.17 / 4.38 | 5 (4, 4) | 56 % (77 %, 76 %) | 51 % | 8.3 / 11.1 / 16.8 | | | | | |
| 3 | swat | 21 | 1.72 / 3.53 | 2.37 / 4.3 | 3 (3, 3) | 39 % (92 %, 91 %) | 66 % | 7.1 / 10.5 / 15.3 | | | | | |
| **3** | **all ranged** | 87 | 1.18 / 4.02 | 2.58 / 5.38 | 18 (16, 16) | 53 % (89 %, 87 %) | 52 % | 6.6 / 10 / 14.4 | 0.75 (5) | 5.6 | 73 % | 31.9 | 1 |
| 4 (reached 9/10) | contractor | 22 | 0.92 / 2.2 | 1.62 / 4.38 | 9 (8, 8) | 56 % (96 %, 96 %) | 48 % | 4.4 / 8.8 / 12.1 | | | | | |
| 4 (reached 9/10) | patrol_cop | 20 | 0.68 / 5.25 | 1.52 / 6.22 | 3 (2, 1) | 57 % (94 %, 94 %) | 51 % | 4.9 / 8.3 / 11.7 | | | | | |
| 4 (reached 9/10) | rocket_trooper | 21 | 2.17 / 5.45 | 2.72 / 5.45 | 8 (8, 8) | 48 % (73 %, 72 %) | 41 % | 8.6 / 10.6 / 14.3 | | | | | |
| 4 (reached 9/10) | swat | 21 | 0.9 / 3.67 | 1.4 / 6.38 | 4 (4, 4) | 45 % (93 %, 93 %) | 69 % | 4.8 / 9.3 / 14 | | | | | |
| **4** (reached 9/10) | **all ranged** | 84 | 0.92 / 4.22 | 1.6 / 5.48 | 24 (22, 21) | 51 % (89 %, 88 %) | 52 % | 4.8 / 9.5 / 13 | 0.63 (5) | 5 | 76 % | 18.3 | 0 |
| 6 (reached 3/10) | contractor | 4 | 0.82 / 3.27 | 2.52 / 3.27 | 1 (1, 1) | 74 % (98 %, 98 %) | 50 % | 5.9 / 9.7 / 10.9 | | | | | |
| 6 (reached 3/10) | patrol_cop | 9 | 0.75 / 1.65 | 1.95 / 4.2 | 3 (3, 3) | 45 % (92 %, 89 %) | 61 % | 8.2 / 10.4 / 12.1 | | | | | |
| 6 (reached 3/10) | robot_gunner | 6 | 0.45 / 10.32 | 3.03 / 13.4 | 1 (1, 1) | 38 % (99 %, 99 %) | 31 % | 8.9 / 10.5 / 15.9 | | | | | |
| 6 (reached 3/10) | rocket_trooper | 8 | 1.52 / 2.62 | 1.52 / 3.53 | 2 (1, 1) | 70 % (81 %, 81 %) | 48 % | 7.8 / 9.1 / 11.5 | | | | | |
| 6 (reached 3/10) | swat | 1 | 0.53 / 0.53 | 0.53 / 0.53 | 0 (0, 0) | 22 % (89 %, 89 %) | 100 % | 14.4 / 15.2 / 16 | | | | | |
| **6** (reached 3/10) | **all ranged** | 28 | 0.92 / 3.27 | 1.95 / 4.2 | 7 (6, 6) | 57 % (91 %, 90 %) | 48 % | 7.8 / 10.4 / 12.7 | 0.75 (5) | 6.6 | 60 % | 39.4 | 1 |
| 7 (reached 2/10) | contractor | 5 | 0.48 / 0.88 | 2.78 / 9.13 | 0 (0, 0) | 55 % (96 %, 95 %) | 63 % | 4.7 / 9.4 / 14.2 | | | | | |
| 7 (reached 2/10) | patrol_cop | 2 | 0.3 / 1.3 | 5.53 / 5.7 | 0 (0, 0) | 40 % (97 %, 94 %) | 38 % | 12.2 / 12.2 / 12.9 | | | | | |
| 7 (reached 2/10) | robot_gunner | 3 | 0.13 / 7 | 0.13 / 11.52 | 1 (0, 0) | 57 % (99 %, 99 %) | 22 % | 5.6 / 9.7 / 11.8 | | | | | |
| 7 (reached 2/10) | rocket_trooper | 1 | - / - | - / - | 1 (1, 1) | 98 % (98 %, 98 %) | 14 % | - / - / - | | | | | |
| 7 (reached 2/10) | sentry_turret | 2 | 3.3 / 3.3 | 9.12 / 9.12 | 1 (1, 1) | 25 % (46 %, 31 %) | 31 % | 5.6 / 6 / 6.3 | | | | | |
| 7 (reached 2/10) | swat | 6 | 0.58 / 0.83 | 0.83 / 4.75 | 2 (2, 2) | 35 % (93 %, 92 %) | 63 % | 11.2 / 12.4 / 18.7 | | | | | |
| **7** (reached 2/10) | **all ranged** | 19 | 0.58 / 3.3 | 2.78 / 9.13 | 5 (4, 4) | 47 % (89 %, 86 %) | 48 % | 5.7 / 11.4 / 15.6 | 0.53 (2) | 5.3 | 85 % | 1 | 0 |
| **1-4, 6-7** | **all ranged** | 488 | 0.78 / 3.32 | 1.83 / 5.38 | 146 (140, 138) | 52 % (91 %, 90 %) | 49 % | 5.6 / 9.4 / 12.7 | 0.81 (7) | 6.4 | 73 % | 20.9 | 2 |

Melee (reported apart):

| wave | archetype | n | never swung | swings | clear-line s |
| --- | --- | --- | --- | --- | --- |
| 3 | riot_cop | 29 | 7 | 70 | 221.5 |
| 4 | riot_cop | 26 | 4 | 39 | 118.9 |
| 6 | riot_cop | 9 | 4 | 20 | 63.8 |
| 6 | robot_thug | 2 | 0 | 5 | 25.2 |
| 7 | riot_cop | 2 | 2 | 0 | 7.4 |
| 7 | robot_thug | 4 | 4 | 0 | 15.5 |

Waves reached: 1: 10/10, 2: 10/10, 3: 10/10, 4: 9/10, 5: 8/10, 6: 3/10, 7: 2/10. Rivet shots probe = run result on 51/52 wave rows.

