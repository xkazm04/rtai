# Hall roof frame cost, n30c re-measure (4 paired rounds, 45 s each)

Ochre TRUE, no product change. Before = temporary row `arched_noroof` (98cd845b2's `arched_line`) plus a temporary whitelist id in the frame probe; after = `arched_line`. Both temporaries restored byte-for-byte (`git diff --quiet` clean). The after arm also holds the mouth span (e4797b637), so the delta is an upper bound for the roof. Order: r1 before/after, r2 after/before, r3 before/after, r4 after/before. 1920x1080 d3d12, vsync off, debug build. Bench lock held (not CONTENDED); load below is from the machine, other lanes were running.

| round | before p50 / p99 ms | after p50 / p99 ms | p50 delta ms |
|---|---|---|---|
| 1 | 2.223 / 5.380 | 3.492 / 6.567 | +1.269 |
| 2 | 3.071 / 5.943 | 3.158 / 6.042 | +0.087 |
| 3 | 2.553 / 5.389 | 2.687 / 5.448 | +0.134 |
| 4 | 3.005 / 8.021 | 2.602 / 5.336 | -0.403 |

Paired p50 delta mean +0.272 ms, sd 0.708, Student-t CI95 (n = 4, t = 3.182) [-0.711, +1.254] ms.

Verdict: NOT PROVEN under the bar (upper CI95 < 0.5 ms fails: 1.254). The interval is dominated by round 1 (the first sample, +1.27 ms, with a before arm unusually fast at 2.22 ms and an after arm with 12.2k frames against 15-17k elsewhere); rounds 2-4 are +0.087, +0.134, -0.403 (mean -0.06). Machine noise between rounds (before p50 2.22 to 3.07) exceeds the effect, so the roof's cost is not separable at n = 4; the point estimate is small, and a longer run on a quiet machine would be needed to meet the bar.

Load per sample (GTAI_CAP_STATUS used MB / procs, CPU % after the run): r1 before 3911/66, 63.9; r1 after 5015/90, 58.2; r2 after 4207/60, 37.9; r2 before 4987/71, 37.8; r3 before 4751/79, 50.6; r3 after 4227/67, 41.0; r4 after 5219/79, 45.0; r4 before 6803/103, 60.5. Raw: `evidence/yard30/roof_frame/n30c_*`.

---

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
