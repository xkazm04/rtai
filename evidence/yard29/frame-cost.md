# n29 hall finish frame cost: arched_line at HEAD against n28's arched_line (n29-05, item 4)

Method of `evidence/yard28/frame-cost.md`: `project/dev/prologue_yard/yard_frame_probe.tscn` (arm whitelist gained the measuring-only id `arched_n28`), seed 7, 1920 x 1080 window at `--position 0,1440`, D3D12, RTX 4090, Ryzen 7 7800X3D, Godot 4.7.2 editor binary (`debug_build=true`), vsync off, 60 s per sample, launched through `tools/dev/run.mjs` (`build/n29-05/probe.mjs` adds the display args as `tools/art/prologue_yard_stills.mjs` does), one build (working tree = commit d8dd15d98 + the roof glow / mouth-pool change). After = `arched_line` (tall hall, collapsed tall bay, `roof_glow`, `yard_hall_mouth_wall` pools). Before = a TEMPORARY row `arched_n28` holding `git show c649a15d6:project/data/tables/prologue_yard_dressings.json`'s `arched_line`, removed afterwards (the table holds no `arched_n28`; never committed). The run held `gtai-n29/bench.lock` for all six samples (created with `noclobber` by `build/n29-05/frame.sh`, removed by its EXIT trap; gone afterwards). Order: before/after, after/before, before/after (02:58 to 03:09). Raw: `build/frame29/r{1,2,3}_{before,after}.json`.

| Round | n28 p50 | n28 p99 | n29 p50 | n29 p99 | frames n28/n29 |
|---|---:|---:|---:|---:|---|
| 1 | 4.563 | 8.128 | 4.660 | 8.341 | 12539/12449 |
| 2 | 3.997 | 8.245 | 3.888 | 7.995 | 13436/14359 |
| 3 | 3.827 | 7.933 | 3.718 | 7.606 | 14259/14825 |

Paired differences (n29 - n28), Student-t 95% interval over three rounds:

| | mean | 95% CI |
|---|---:|---:|
| p50 | -0.040 ms | [-0.336, +0.255] |
| p99 | -0.121 ms | [-0.847, +0.604] |

Verdict: bar p50 upper CI95 < 0.5 ms: PASS (+0.255 ms; mean -0.040 ms). The p99 interval is wider than 0.5 ms over three rounds (mean -0.121 ms): noise, not proven either way. No halving of the glow was needed.

Machine load: `GTAI_CAP_STATUS` (n29 cap 16384 MB): used 4896 MB, 118 procs at the start; 4659 MB, 135 procs at the end. Whole-machine CPU (3 one-second samples right after each sample): 100, 100, 95, 99, 95, 100 % (r1 before, r1 after, r2 after, r2 before, r3 before, r3 after). Other lanes (commit hooks, mutation, builds) kept the machine saturated, so frames read 3.7 to 4.7 ms against n28's 2.1 ms; the paired difference is inside that noise. Not CONTENDED by the lock, but the machine was not quiet.

NOTE (03:18): the frame cost, the stills and the measures above were taken with two extra `yard_hall_mouth_wall` pools (a new kind, no floor glow, at y -2.9). Lint refused the new kind id (the schema enumerates kind ids), so the commit d838f9e66 instead MOVES the existing burst_door / collapsed_wall `yard_hall_mouth` pools from y -0.8 to -2.9 (two fewer lights than measured, so the cost is at most the measured one). The stills show the measured variant, not d838f9e66's; re-shoot owed.
