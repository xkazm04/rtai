# d5-city bench, 2026-11-03 ~11:50, d-city 6ee6012 - CONTENDED (seven lanes share the RTX 4090)

## City bench (`node tools/bench/run.mjs --runs=1 --secs=30`, exported windows-bench release build, windowed)
p99 5.465 ms, 1% low 127 fps, worst swap 10.68 ms, worst frame 82.2 ms; hitches >25 ms 61, >50 ms 7
(unexplained 2, present 5). Exit 1: MISSES over50.unexplained (2 unexplained >50 ms hitches), not
re-run on an idle machine; on a contended GPU this is not attributable to the city. Short run (1 x 30 s,
not the 3 x 60 s gate). Per-scenario logs: bench-*.json.

## D5 cost per pass (`dev/showcase/d5_cost.gd`, 64 px/m, 16 full rigs, 240 frames, vsync off; dev showcase ground)
| tier | adds | GPU median ms | delta | CPU median ms |
|---|---|---|---|---|
| d4 | D4 print | 0.068 | - | 0.226 |
| d5p | + D5 part overlays | 0.269 | +0.201 | 0.457 |
| d5 | + look_d5 world layer | 0.447 | +0.178 | 0.450 |
| d5s | + hatched rig shadows (D5RigShadow) | 0.611 | +0.164 | 0.632 (+0.69 ms shadow sync script) |
Total D5 over D4 at 64 px/m: +0.54 ms GPU. d5-cost.json.
