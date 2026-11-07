# Rivet's frame cost, it25 (d9 rivet, 2026-11-07 17:58-18:00) - under the bench lock

Same command as it16 (`evidence/d9/rivet-frame-cost-it16.md`):
`"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=<json> --view=tilt70`,
on HEAD 0f8bc386 (every strip swap through it22, incl. the drawn walk code). Held `gtai-n5/bench.lock` for all three
runs. Debug build, headless, AMD Ryzen 7 7800X3D. After-only (no before run this time: it16's interleaved before
stands, 0.943 / 1.319 ms median p50).

| run | 50 people p50 / avg / p99 (ms) | 200 people p50 / avg / p99 (ms) |
|---|---|---|
| after 1 | 0.811 / 0.934 / 1.596 | 1.003 / 1.043 / 2.037 |
| after 2 | 0.792 / 0.897 / 1.509 | 1.079 / 1.094 / 1.911 |
| after 3 | 1.164 / 1.237 / 2.772 | 1.106 / 1.104 / 1.820 |
| **median p50** | 0.811 (it16 after 0.776, before 0.943) | 1.079 (it16 after 1.179, before 1.319) |

Read: the strips added since it16 (the p55 swaps, the baton/plasma sword redraws, the walk) left the rig cost where
it16 measured it: inside the it16 after band and under the it16 before (head card over parts). The bench's Rivet is
armed, so the drawn bare-claw walk grid is NOT exercised here: its cost stays unmeasured (by code a texture swap at
walk start/stop and a `.frame` set per tick, like the facings). Every run exits 1 on the debug build's hard limit
(rigHardMs 1.0), as in it16 before and after alike. JSON: `rig-bench-it25-after{1,2,3}_tilt70.json`.
