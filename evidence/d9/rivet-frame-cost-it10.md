# Rivet's frame cost, it10 (d9 rivet, 2026-11-07) - CONTENDED

`"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=<json> --view=tilt70` (F-09b rig
stress: N people around a walking, punching, rolling Rivet; whole CharacterRigs time per tick). Before =
`RivetFrames.ENABLED = false` for that one run (the head card over the parts, today's main path under tilt70);
after = HEAD (61fbbdf8 code). **CONTENDED**: the bench lock was held by another lane (`perf`, from 12:35) for all
three runs; the hard-limit judge (exit 1) fails all three alike on this machine state.

| run | 50 people p50 / avg / p99 (ms) | 200 people p50 / avg / p99 (ms) |
|---|---|---|
| before (parts + head card) | 0.866 / 0.925 / 1.522 | 1.276 / 1.268 / 1.710 |
| after, run 1 | 0.774 / 0.844 / 1.398 | 1.147 / 1.148 / 1.573 |
| after, run 2 | 0.781 / 0.888 / 1.615 | 1.090 / 1.088 / 1.621 |

Read: the drawn figure adds no rig cost; both after runs sit ~0.1 ms under the before at p50 (the hidden parts
still pose, but ~20 fewer canvas items draw). Within contended noise: re-run under the lock for a number to quote.
JSON: `rig-bench-it10-{before,after,after2}_tilt70.json`.
