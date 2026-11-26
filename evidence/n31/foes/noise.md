# Foes noise: main | final | B on seeds 1-10, 11-20 and pooled (n31 b4o)

Average bot, `--controls=wheel --pick=greedy --waves=7`, seeds 11-20 measured now (`noise-main-s11`, `noise-final-s11`, `noise-b-s11`); seeds 1-10 from `waiting-main`, `waiting-final`, `waiting-more-guns-b`. main = ba8e470b0, final = 9b3730e36, B = c825715e8. Damage w1-4 = per seed, the sum of damage taken in waves 1-4 (waves not reached count nothing), then the mean over seeds; the s1-20 columns pool the 20 runs (rate rows re-aggregated by `waiting.mjs --from` over the 20 run files). sd = per-seed standard deviation; interval = mean +- t(0.975, n-1) * sd / sqrt(n). Main's s11-20 probe is the one before a4224e310 (the newer travel-cause probe does not compile on main: no FoeGait), via `GTAI_PROBE_REV=a4224e310^`.


Three lines:
