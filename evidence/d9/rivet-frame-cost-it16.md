# Rivet's frame cost, it16 (d9 rivet, 2026-11-07) - under the bench lock

`"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=<json> --view=tilt70` (F-09b rig
stress: N people around a walking, punching, rolling Rivet; whole CharacterRigs time per tick, 540 ticks per size).
Before = `RivetFrames.ENABLED = false` for that run only (the head card over the parts: today's main under tilt70);
after = HEAD (90c46dfc code). Held `gtai-n5/bench.lock` for all six runs (14:3x); interleaved after, before, before,
after. Debug build, headless, AMD Ryzen 7 7800X3D. Other lanes' non-bench work may still run on the machine.

| run | 50 people p50 / avg / p99 (ms) | 200 people p50 / avg / p99 (ms) |
|---|---|---|
| before 1 | 1.150 / 1.232 / 1.917 | 1.319 / 1.342 / 2.060 |
| before 2 | 0.943 / 1.037 / 1.909 | 1.234 / 1.264 / 1.988 |
| before 3 | 0.923 / 0.989 / 1.486 | 1.333 / 1.370 / 2.112 |
| after 1 | 0.776 / 0.839 / 1.397 | 1.179 / 1.226 / 1.944 |
| after 2 | 0.906 / 0.999 / 1.521 | 1.179 / 1.233 / 1.919 |
| after 3 | 0.746 / 0.797 / 1.181 | 1.097 / 1.070 / 1.849 |
| **median p50** | before 0.943 -> after 0.776 | before 1.319 -> after 1.179 |

Read: the drawn whole figure adds no rig cost; it is ~0.14-0.17 ms cheaper at p50 than the head card over parts
(the parts still pose but ~20 fewer canvas items draw), as it10's contended runs said. Every run exits 1 on the
bench's hard limit (rigHardMs 1.0 on the debug build), before and after alike: a machine/build state, not this
change. JSON: `rig-bench-it16-{before,before2,before3,after,after2,after3}_tilt70.json`.
