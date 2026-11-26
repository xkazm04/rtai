# Foes noise: main | final | B on seeds 1-10, 11-20 and pooled (n31 b4o)

Average bot, `--controls=wheel --pick=greedy --waves=7`, seeds 11-20 measured now (`noise-main-s11`, `noise-final-s11`, `noise-b-s11`); seeds 1-10 from `waiting-main`, `waiting-final`, `waiting-more-guns-b`. main = ba8e470b0, final = 9b3730e36, B = c825715e8. Damage w1-4 = per seed, the sum of damage taken in waves 1-4 (waves not reached count nothing), then the mean over seeds; the s1-20 columns pool the 20 runs (rate rows re-aggregated by `waiting.mjs --from` over the 20 run files). sd = per-seed standard deviation; interval = mean +- t(0.975, n-1) * sd / sqrt(n). Main's s11-20 probe is the one before a4224e310 (the newer travel-cause probe does not compile on main: no FoeGait), via `GTAI_PROBE_REV=a4224e310^`.


Three lines:
| metric | main s1-10 | main s11-20 | main s1-20 | final s1-10 | final s11-20 | final s1-20 | B s1-10 | B s11-20 | B s1-20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| damage w1-4 (mean per seed) | 62.8 | 64.8 | 63.8 | 69.8 | 70.2 | 70 | 73.4 | 74.6 | 74 |
| deaths (runs) | 5 (10) | 8 (10) | 13 (20) | 7 (10) | 8 (10) | 15 (20) | 6 (10) | 7 (10) | 13 (20) |
| waves 6 / 7 reached | 6 / 6 | 4 / 3 | 10 / 9 | 3 / 3 | 4 / 2 | 7 / 5 | 7 / 5 | 5 / 4 | 12 / 9 |
| idle share | 66 % | 64 % | 65 % | 55 % | 51 % | 53 % | 43 % | 44 % | 43 % |
| react in range p50 / p90 s | 1.05 / 6.15 | 1.08 / 4.35 | 1.05 / 5.1 | 0.68 / 2.58 | 0.67 / 3.67 | 0.67 / 3.05 | 0.7 / 3.55 | 0.7 / 2.42 | 0.7 / 3.07 |
| firing / s | 1.02 | 1.02 | 1.02 | 0.83 | 0.83 | 0.83 | 1.02 | 1.12 | 1.07 |
| never fired / ranged foes | 173 / 569 | 159 / 518 | 332 / 1087 | 160 / 499 | 148 / 512 | 308 / 1011 | 144 / 547 | 111 / 542 | 255 / 1089 |
| per-seed damage w1-4 sd | 19.5 | 23.8 | 21.2 | 29.8 | 30.2 | 29.2 | 31.7 | 43.6 | 37.1 |
| 95 % interval of the mean (t) | 48.9..76.7 | 47.8..81.8 | 53.9..73.7 | 48.4..91.1 | 48.6..91.8 | 56.3..83.7 | 50.7..96 | 43.4..105.7 | 56.6..91.3 |

Three lines:
1. B 74 vs main 63.8 (band 54.2..73.4): 15.9 %; outside +-15 %.
2. final 70 vs main 63.8: 9.7 %; inside +-15 %.
3. B - final = 4; Welch 95 % half-width 21.3 (se 10.6); inside the interval.

