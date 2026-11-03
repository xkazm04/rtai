# 24 - end-of-day bench, d-city 61e9222 (GENERATOR 11, 2 x 2 roofs), 2026-11-03 15:59-16:02 - CONTENDED

bench.lock taken 15:59:40 (free; d5-combat had held it from 15:42), released 16:02:41.
Seven lanes share the RTX 4090; other lanes' agents were running. Not an idle run.

## City bench (`node tools/bench/run.mjs --runs=1 --secs=30`, exported windows-bench release build)
PASS (exit 0): p99 3.164 ms, 1% low 266 fps, worst swap 4.388 ms, worst frame 25.5 ms; hitches >25 ms 1,
>50 ms 0; vsync-on drive >25 ms 0; rigs p99 0.645 ms/frame (riot, up to 16).
11:50 run (13-bench, d-city 6ee6012, before the 2 x 2 plates): p99 5.465 ms, 1% low 127 fps, exit 1 on
2 unexplained >50 ms hitches. Both short (1 x 30 s per scenario, not the 3 x 60 s gate); the difference
is contention, not a speed-up from this lane. The two 1312 px roof plates did not add a hitch.
Logs: bench.log, bench-{drive,drive48,drive48vsync,riot}.json.

## D5 overlay cost per pass at gameplay zoom (`dev/selftest/overlay_cost.tscn -- --ppm=<p>`)
Selftest junction, real CityView + crowd, 16 interleaved blocks of 30 frames, `d4` vs `auto`.

| px/m | GPU off | on | delta (now) | delta (13:03, 21-overlay-cost) |
|---|---|---|---|---|
| 32 | 1.901 | 2.776 | +0.875 | +0.900 |
| 48 | 0.530 | 0.804 | +0.275 | +0.420 |
| 64 | 4.494 | 5.645 | +1.152 | +0.398 |

The 64 px/m row is contaminated (its overlay-off baseline is 6.8x the 13:03 one: another lane's GPU
load landed in that window); read it as unmeasured. The 32 px/m delta repeated (+0.9 ms twice) so it
is not noise: the pass costs ~2-3x more at 32 than at 48 on this site. Open question for an idle
re-measure (suspects: more crowd/rigs on screen under the BackBufferCopy at the wider view).
At +0.9 ms it is 5 % of a 16.7 ms frame.
