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

## Shipped yard (n27-05)

Same method and probe as above (`yard_frame_probe.tscn`, seed 7, 1920 x 1080 window at `--position 0,1440`, D3D12, RTX 4090, Ryzen 7 7800X3D, Godot 4.7.2 editor binary, vsync off, `debug_build=true`), measured at git HEAD `a60eb3a93` with the dressing chosen by `--yard-dressing` on one build; no data file was touched. The run held `gtai-n27/bench.lock` for all six samples (created exclusively at 07:23, removed by the script on exit). Samples are 60 s each, not 45 s: the probe's `WINDOW_US` is a constant and this call may not change code. Order: before/after, after/before, before/after (07:23 to 07:30). Two deviations from the brief: (1) arm before is plain `line_fire` as shipped, which already carries the floor glow (the glow is a per-kind row in the table, and switching it off needs a data change), so before = line_fire (glow on, no over-print layer, the old art) and after = `raised_line` (glow, over-print layer, new art, warm floor); the delta is the cost of the raised_line dressing over line_fire, not of the glow. (2) No other bench held the lock; I did not inspect other processes, so a stray load cannot be excluded, but no sample is an outlier.

| Round | Before p50 | Before p99 | After p50 | After p99 | frames before/after |
|---|---:|---:|---:|---:|---|
| 1 | 3.674 | 6.070 | 3.722 | 5.905 | 16491/16377 |
| 2 | 3.575 | 5.653 | 3.680 | 5.952 | 16943/16472 |
| 3 | 3.674 | 5.817 | 3.784 | 6.115 | 16535/15950 |

Paired differences (after - before), Student-t 95% interval over three rounds (`evidence/yard27/frame_stats.py` on `build/frame27b`):

| | mean | 95% CI |
|---|---:|---:|
| p50 | +0.088 ms | [+0.002, +0.173] |
| p99 | +0.144 ms | [-0.521, +0.809] |

Verdict: the bar is p50 CI upper < 0.5 ms; the upper bound is +0.173 ms, so it passes, with room. All three rounds are positive (+0.05 to +0.11 ms, about 2 to 3 % of a 3.7 ms frame): raised_line costs a little, measurably, and the interval just excludes zero. The p99 interval is wider than the bar (three rounds), so it does not prove p99 on its own; its mean is +0.144 ms.
