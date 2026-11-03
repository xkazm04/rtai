# 21 D5 overlay cost at gameplay zoom, d5-city iteration 4, 2026-11-03 13:03 - CONTENDED

`dev/selftest/overlay_cost.tscn -- --ppm=<p>` (selftest junction, real CityView + crowd, 16 interleaved
blocks of 30 frames: `d4` (overlay hidden) vs `auto` (overlay at the amount_ppm ramp: 0.5 at 32, 0.75
at 48, 1 at 64)). bench.lock taken 13:03, released 13:04. Seven lanes share the RTX 4090: one run per
zoom, not repeated idle.

| px/m | GPU ms overlay off | on | delta | CPU render delta |
|---|---|---|---|---|
| 32 | 1.499 | 2.399 | +0.900 | -0.07 |
| 48 | 0.565 | 0.985 | +0.420 | -0.01 |
| 64 | 0.662 | 1.060 | +0.398 | +0.05 |

The pass is a full-screen BackBufferCopy + ColorRect, so its cost should not depend on the amount;
the 32 px/m delta (2x the others, on a baseline 2.7x the 48 px/m one) is likely contention noise or
the larger crowd on screen: re-measure idle. Even at +0.9 ms it is 5 % of the 16.7 ms frame. The
earlier d5_cost tier figure (+0.18 ms at 64 px/m, 13-bench) used a dev showcase ground, not the city.
