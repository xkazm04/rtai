# arched_line frame cost against raised_line (n28-03, Part B item 1)

Method of `evidence/yard27/frame-cost.md`: `project/dev/prologue_yard/yard_frame_probe.tscn` (the probe's arm whitelist gained `arched_line`), seed 7, 1920 x 1080 window at `--position 0,1440`, D3D12, RTX 4090, Ryzen 7 7800X3D, Godot 4.7.2 editor binary (`debug_build=true`), vsync off, 60 s per sample, the dressing chosen by `--yard-dressing` on one build at git HEAD `6374ab107` (the fixed row: light radius 4.5 m, feathered floor glow). Release not tried: n27 found the release template refuses `--path`, and an export did not fit the call's budget; this is the debug build. The run held `gtai-n28/bench.lock` for all six samples (created exclusively by `build/frame28/run.sh`, removed by its EXIT trap; it was gone afterwards). Order: raised/arched, arched/raised, raised/arched (20:43 to 20:50). Before = `raised_line`, after = `arched_line`.

| Round | raised p50 | raised p99 | arched p50 | arched p99 | frames raised/arched |
|---|---:|---:|---:|---:|---|
| 1 | 2.158 | 4.230 | 2.118 | 3.769 | 26281/27402 |
| 2 | 2.122 | 3.486 | 2.131 | 3.751 | 27583/27015 |
| 3 | 2.138 | 4.929 | 2.188 | 4.416 | 25865/25684 |

Paired differences (arched - raised), Student-t 95% interval over three rounds:

| | mean | 95% CI |
|---|---:|---:|
| p50 | +0.006 ms | [-0.106, +0.118] |
| p99 | -0.236 ms | [-1.317, +0.844] |

Verdict: bar p50 upper CI95 < 0.5 ms: PASS (+0.118 ms). The p99 interval (three rounds) is wider than 0.5 ms and does not prove p99 by itself; its mean is -0.236 ms (noise).

Machine load: `GTAI_CAP_STATUS` (n28 cap 8192 MB): used 3732 MB, 48 procs at the start, 4047 MB, 53 procs at the end. Whole-machine CPU (3 one-second samples taken right after each sample): 40 %, 11 %, 18 %, 16 %, 29 %, 35 % (r1 raised, r1 arched, r2 arched, r2 raised, r3 raised, r3 arched). Other lanes were running, so the machine was not quiet; the frames are about 2.1 ms (the n27 probe read 3.5 to 3.7 ms on a different load), and the paired difference is inside the noise. Not CONTENDED by the lock, but I did not exclude stray load.
