# 28 - final bench, d-city 1e7caef (GENERATOR 13: 2 x 2 plates A/B/C + long plate 81), 16:40-16:43 - CONTENDED

bench.lock taken 16:40:41 (d5-cast released it at ~16:40), released 16:43:08. Not idle.

## City bench (`node tools/bench/run.mjs --runs=1 --secs=30`): FAIL (exit 1, MISSES p99CpuMs)
p99 8.709 ms, 1% low 75 fps, worst swap 18.3 ms, worst frame 46.6 ms; hitches >25 ms 27, >50 ms 0;
vsync-on drive >25 ms 6; rigs p99 0.728 ms. The 16:00 run at 61e9222 (plates A/B only) PASSED with
p99 3.164 ms (24-bench-end). Between the two runs this lane added two 1312 px roof textures (C, 81)
and nothing on the CPU path (the generator runs at bake time; the chunk loader reads the same records).
Most likely contention (another lane released the lock seconds before), but NOT shown: an idle re-run
at 1e7caef is owed before the merge. If it still misses, first suspect = texture upload/streaming of
the new plates on chunk load (check the drive scenario's worst frames against chunk crossings).
Logs: bench.log, bench-*.json.

## D5 overlay cost at 32 px/m (overlay_cost.tscn --ppm=32)
+0.508 ms GPU (off 0.640, on 1.148). The two earlier runs (+0.900 at 13:03, +0.875 at 16:02) sat on
heavier baselines (1.50 / 1.90 ms): so the 32 px/m excess is at least partly contention after all,
which weakens the "repeats, so real" reading in 24-bench-end. Still above 48 px/m's +0.27-0.42.
