# Warm light frame cost (n27-02)

Seed 7, 1920 x 1080 window, 70-degree camera, D3D12, NVIDIA GeForce RTX 4090, Godot 4.7.2 editor binary, vsync off, 60 wall-clock seconds per sample, `yard_frame_probe.tscn` on `line_fire`. The yard held `gtai-n27/bench.lock` for all six samples. Before = the n26 row (git HEAD~1 of the light commit) copied into `project/data/tables` for the run; after = the new row. Order: before/after, after/before, before/after. The release template was tried once and refused to start: `--path was specified on the command line, but this Godot binary was compiled without support for path overrides`. The probe recorded `debug_build=true`. No other bench ran during the samples (not CONTENDED).

| Round | Before p50 | Before p99 | After p50 | After p99 | frames before/after |
|---|---:|---:|---:|---:|---|
| 1 | 3.596 | 6.386 | 3.500 | 6.094 | 16387/16749 |
| 2 | 3.567 | 6.045 | 3.524 | 6.266 | 16823/16644 |
| 3 | 3.490 | 5.845 | 3.510 | 6.078 | 17168/16866 |

Times are ms between presentation-loop frames. Paired differences (after - before), Student-t 95% interval over three rounds (`evidence/yard27/frame_stats.py`):

| | mean | 95% CI |
|---|---:|---:|
| p50 | -0.040 ms | [-0.184, +0.105] |
| p99 | +0.054 ms | [-0.691, +0.799] |

Verdict: the p50 upper bound +0.105 ms is under the 0.5 ms bar. The p99 interval is wider than 0.5 ms (three rounds), so it does not prove the limit at p99 by itself. The light layer already holds 11 of 64 pools (was 8); the cost per pool is the same quad.
