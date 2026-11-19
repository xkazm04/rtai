# Squad tick cost on the fixed pit workloads

Starting simulation commit `91644f6cf`. Five seeds (20261103-20261107), 600 active ticks per seed and workload. Headless Godot 4.7.2, **CONTENDED**, without the bench lock. The cost probe runs normal production steps first and replays the fixed workload with section timers. It checks the replay's search and sight counts against the production run.

All columns are pooled mean microseconds per tick, except the final column, which is microseconds per stepped hostile. Assign includes queued routes and token allocation. Sight covers initial perception. Plan includes velocity and path/cover work. Motor covers steering and pose writes. Swing includes the ranged trigger and its confirmation sight check. The two rightmost columns come from the ordinary run and exclude section timers. Tick includes the squad pre-loop.

| Run | Guards | Assign | Sight | Plan | Motor | Neighbour | Swing | Tick | Per hostile |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Before | 10 | 83.48 | 35.26 | 61.02 | 32.90 | 127.96 | 20.44 | 361.96 | 28.21 |
| Before | 40 | 398.38 | 135.06 | 310.32 | 133.53 | 1827.22 | 70.04 | 2992.86 | 64.91 |
| After neighbour, assignment and geometry cuts | 10 | 61.75 | 22.69 | 44.53 | 20.91 | 27.79 | 15.98 | 208.78 | 14.66 |
| After neighbour, assignment and geometry cuts | 40 | 230.14 | 79.99 | 207.73 | 78.32 | 226.05 | 52.16 | 982.36 | 16.85 |
| Final | 10 | 70.03 | 25.62 | 47.90 | 23.33 | 31.82 | 18.74 | 202.79 | 14.21 |
| Final | 40 | 269.67 | 106.56 | 239.28 | 94.11 | 267.09 | 62.67 | 1069.95 | 20.27 |

The 40-guard neighbour scan alone took 1.83 ms/tick. Assignment and planning were the next largest sections. Reproduce with `node tools/dev/run.mjs squad_cost --enemy-brain=squad --seeds=5 --timeout=300 --out=<absolute.json>`. The starting five-seed city, pit and quest1 digests for squad, mixed and guard are in `evidence/n19-ai/cost-digests.json`.

The neighbour scan still visits agents in simulation order and reads their current positions, including moves earlier in the tick. A squared-distance rejection skips state, archetype and contact calculations for distant bodies. In the first isolated cut, seed 20261103 fell from 27.91 to 13.51 us per hostile at 10 and from 61.47 to 16.03 at 40. The assignment cut sorts waiters only when at least one can receive a token. The route map caches the static slabs crossed by a sector rectangle, with a 256-entry ceiling. Each sight test still uses the actual segment and the original corner rule.

Across all 45 five-seed fights at `a2113162a`, every digest, fight field and AI statistic matched the starting commit. Commit hooks ran during that intermediate cost sweep.

The final production sweep at `ab12bb094` cut mean hostile time by 49.6% at 10 guards and 68.8% at 40. The 10-guard result exceeded the 12 us target by 2.21 us. The 40-guard result met the 25 us target with 4.73 us to spare. Individual seed means ranged from 10.32 to 17.33 us at 10 and from 17.52 to 23.62 us at 40. The different clock times across these unlocked runs do not isolate the effect of the final small cut. The fixed workloads retained identical counts of hostile steps, route searches, cover queries and sight checks for each seed, with zero budget violations.

`node tools/tests/run_unit.mjs --changed` selected the full suite and reported 2,985 passed, zero failed and two skipped. All five requested scenarios passed (`arena_squad`, `arena_pit`, `arena_city`, `enemy_pit` and `enemy_waves`).
