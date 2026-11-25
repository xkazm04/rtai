# n30-04b hall roof frame cost: arched_line at 7fd323782 (+ mouth span 65183a395) against 98cd845b2's arched_line (no roof)

Method of `evidence/yard29/frame-cost.md`: `project/dev/prologue_yard/yard_frame_probe.tscn` (its arm whitelist gained the measuring-only id `arched_noroof` for the batch, restored byte-for-byte afterwards), seed 7, 1920 x 1080 window at `--position 0,1440`, D3D12, RTX 4090, Ryzen 7 7800X3D, Godot 4.7.2 editor binary (`debug_build=true`), vsync off, 60 s per sample, launched through `tools/dev/run.mjs` (`build/roof/probe.mjs` adds the display args). After = `arched_line` (five slabs tinted a0a0acff + seven plumes, and the sixth belt span out of the burst mouth that landed in 65183a395 before the batch). Before = a TEMPORARY row `arched_noroof` holding `git show 98cd845b2:project/data/tables/prologue_yard_dressings.json`'s `arched_line` (no roof, no mouth span), removed afterwards (never committed). So the after arm carries one extra span stamp beyond the roof: the measured cost is an upper bound for the roof alone. The batch held `C:/Users/kazda/kiro/gtai-n30/bench.lock` for all six samples (taken at once, not CONTENDED) and the lane Godot slot. Order: before/after, after/before, before/after (14:48 to 14:55). Raw: `evidence/yard30/roof_frame/r{1,2,3}_{before,after}.json`.

| Round | before p50 | before p99 | after p50 | after p99 | frames before/after |
|---|---:|---:|---:|---:|---|
| 1 | 2.364 | 5.240 | 3.201 | 6.849 | 22538/17818 |
| 2 | 3.010 | 286.213 | 3.265 | 277.666 | 2993/3431 |
| 3 | 3.051 | 6.705 | 3.291 | 7.529 | 18525/16723 |

Paired differences (after - before), Student-t 95% interval over three rounds:

| | mean | 95% CI |
|---|---:|---:|
| p50 | +0.444 ms | [-0.402, +1.290] |
| p99 | -2.038 ms | [-16.076, +12.000] |

Verdict: bar p50 upper CI95 < 0.5 ms: **FAIL / not proven** (upper +1.290 ms; mean +0.444 ms). Per-round p50 deltas +0.837, +0.255, +0.240 ms: round 1 drives the width. Round 2 is hitched in BOTH arms (only 1164..1320 sim ticks in 60 s against ~3550, 171..180 frames over 16.7 ms, worst 0.5 / 2.5 s; a machine stall), so its p99 is meaningless; its p50 delta is still paired. A replacement round 4 was scripted (`build/roof/batch2.sh`) but the lane Godot slot was held by another builder (`prologue-film`, 14:58 to past 15:07), so it was not run.

Reading: the roof adds 12 large alpha stamps to `factory_front` (five 15.45 x 5.5 m slabs, seven plumes), and every `ochre` piece is drawn a second time by the ochre overprint (`PrologueYardPaint.attach_ochre`): the five slabs are `ochre: true`. A cost of about 0.25 ms p50 (rounds 2 and 3) is plausible for that fill; round 1 suggests up to 0.8 ms on a busy machine. Levers if the owner wants the bar met: `ochre: false` on the five slabs (halves their fill), or smaller slab textures.

Machine load: `GTAI_CAP_STATUS` (n30 cap 16384 MB): used 5540 MB, 62 procs at the start; 4004 MB, 93 procs at the end. Whole-machine CPU (3 one-second samples right after each sample): 77, 70, 37, 59, 94, 56 % (r1 before, r1 after, r2 after, r2 before, r3 before, r3 after). Other lanes were running; not quiet.
