# Riso layer frame cost (n5-look iteration 2, 2026-11-04 17:5x) - CONTENDED

`"$GODOT_BIN" --rendering-driver d3d12 --path project -s res://dev/showcase/riso_cost.gd -- --out=<dir>`
(RisoCostRun = D5CostRun's frame: 16 full rigs walking at 64 px/m, vsync off, 240 frames after 30 warm, viewport
GPU render time). Run under `gtai-n5/bench.lock`, but another lane's Godot (not ours) was rendering at the
same time: **CONTENDED**, RTX 4090.

| tier | what | GPU median ms | p95 |
|---|---|---|---|
| d4 | look_d5 world layer off | 0.230 | 0.274 |
| d5 | look_d5 `world` (riso 0, the old print) | 0.188 | 0.225 |
| riso | look_d5 `world_riso` (shipped middle ground) | 0.148 | 0.162 |
| d5b | d5 again | 0.138 | 0.141 |
| risob | riso again | 0.176 | 0.214 |

Reading: the tier order does not hold (d4 measured slowest), so the contention noise (~0.1 ms between repeats
of one tier) is larger than the riso layer's delta. Unmeasured is not zero: the riso delta is **below 0.05 ms at
this resolution on this GPU, unresolved**. Static cost of the layer per pixel (all in the D5 overlay's existing
pass, no extra BackBufferCopy): +2 screen fetches (the colour plate), +4 lattice fetches (fibre), +3 lattice
fetches (stains, only where d < 0.5), the halftone is ALU only. Budget (shader-budget-authoring): the frame budget
is 16.6 ms (STANDARDS section 20) with no separate post budget; the whole frame here is 0.15-0.19 ms GPU, so
the layer's share is well under 1 % of the frame and the headroom is the rest. Cheaper substitutes and what they
give up: drop the plate's sliver fetch (-1 fetch, loses the paper sliver opposite the ghost); reuse the tooth's
mottle for the stains (-3 fetches, the stains then sit at the grain's frequency and read as grain, not as blots).
Not run: an iGPU (the d5-city lane's low-end card), an uncontended repeat.
