# 29 - stabilize re-bench, d-city 7a8c8b1 (code identical to 1e7caef), 17:00-17:09 - CONTENDED, PARTIAL

bench.lock was free at 17:00; taken 17:00:19, released 17:09:20 (slice-play took it at 17:09:29).
Six lanes were still live, so this is NOT the idle run owed by the 16:47 NEXT.

Command: `node tools/bench/run.mjs` (full gate: 3 passes x 4 scenarios x 60 s), wrapped in a 540 s
`timeout`. That was too short for the full gate (export + 12 min of scenarios): the wrapper killed
pass 3 during `drive` (the log's "drive exit 143 (exported, run 3)"). So there is NO combined
verdict line and pass 1's per-scenario JSON was overwritten by pass 2. Pass 3 did not complete.

## Pass 2, complete (all 4 scenarios, 60 s each; bench-*.json here, written 17:05:38-17:08:43)
| scenario | p99 CPU ms | 1% low fps | worst swap ms | worst frame ms | hitches >25 / >50 |
|---|---|---|---|---|---|
| drive | 4.538 | 132 | 14.36 | 27.2 | 1 / 0 |
| drive48 | 2.781 | 179 | 7.72 | 28.8 | 1 / 0 |
| riot | 2.055 | 339 | 5.89 | 10.4 | 0 / 0 |
| drive48vsync (vsync-paced, not judged on CPU) | 18.07 | 52 | 21.24 | 21.2 | 0 / 0 |

Against the section 20 limits (p99 CPU <= 7 ms, 1% low > 45 fps, worst swap <= 50 ms), judged on
the uncapped runs: worst p99 4.538 ms, 1% low 132 fps, worst swap 14.4 ms: **inside every limit**.

## Reading
The same code FAILED at 16:42 (28-bench-final: drive48 8.37, riot 8.71 ms p99) and now passes with
drive48 2.78 and riot 2.06 ms. Nothing changed on the CPU path in between (only evidence/ and
JOURNAL.md). So the 16:42 FAIL was machine load, not the plates C / 81. This is one complete pass,
not the 3-pass gate: the idle full-gate run is still owed before calling the branch "bench PASS".
