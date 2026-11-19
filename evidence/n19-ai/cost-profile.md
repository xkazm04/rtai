# Squad tick cost on the fixed pit workloads

Starting simulation commit `91644f6cf`. Five seeds (20261103-20261107), 600 active ticks per seed and workload. Headless Godot 4.7.2, **CONTENDED**, without the bench lock. The cost probe runs normal production steps first and replays the fixed workload with section timers. It checks the replay's search and sight counts against the production run.

All columns are pooled mean microseconds per tick, except the final column, which is microseconds per stepped hostile. Assign includes queued routes and token allocation. Sight covers initial perception. Plan includes velocity and path/cover work. Motor covers steering and pose writes. Swing includes the ranged trigger and its confirmation sight check. The two rightmost columns come from the ordinary run and exclude section timers. Tick includes the squad pre-loop.

| Run | Guards | Assign | Sight | Plan | Motor | Neighbour | Swing | Tick | Per hostile |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Before | 10 | 83.48 | 35.26 | 61.02 | 32.90 | 127.96 | 20.44 | 361.96 | 28.21 |
| Before | 40 | 398.38 | 135.06 | 310.32 | 133.53 | 1827.22 | 70.04 | 2992.86 | 64.91 |

The 40-guard neighbour scan alone took 1.83 ms/tick. Assignment and planning were the next largest sections. Reproduce with `node tools/dev/run.mjs squad_cost --enemy-brain=squad --seeds=5 --timeout=300 --out=<absolute.json>`. The starting five-seed city, pit and quest1 digests for squad, mixed and guard are in `evidence/n19-ai/cost-digests.json`.
