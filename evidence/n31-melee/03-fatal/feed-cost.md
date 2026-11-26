# n31 melee 03p3 part 1: the signature-kill feed's frame cost (2026-11-26, 01:19-01:32)

## What was measured, and why not the fight gate
`tools/perf/fight_gate.mjs --scenes=horde,city` runs the arena pit (`--horde` / `--reel=pit --arena=city`,
an `ArenaSession`). Nothing there reads `--kill-feed`: only `GauntletSession.open_street` and
`Quest1Session.open` do. An `off:` / `on:--kill-feed` gate would have been an A/A, so it was not run.
The closest gauntlet measure (as the brief names it): `res://dev/melee_n31/play_baseline_take.tscn`
(the gauntlet street, seed 7, the average bot with the chainsaw, tilt 70 at 32 px/m) for 3600 ticks
(60 s) under `--fixed-fps 60` with vsync off, with the fight gate's own frame probe (`FightFrames`,
new `--frames=<json> --frames-ticks=N` on that scene). Tool: `node tools/melee/feed_cost.mjs`.
Arms: `off` = `--kill-feed=off`, `on` = the default (the 03p3 flip), alternating order per round.
Rounds: 2 (the director's addendum: 2 is enough for part 1).

## CONTENDED: the GPU run was not possible
The rendered run (d3d12, 1080p, `--position 0,1440`) was started first: every frame of the off arm
from tick 7 took ~270 ms in `draw` (median hitch 276 ms over 1557 frames to tick ~1730; process
~5 ms). Other lanes were writing movies on the same GPU at the time (n23-controls `play_film`
`--write-movie`, plus this lane's 02p4 takes) with two GUT runs and a ghost measure on the CPU. That
run was killed (own PID) and the measure re-run `--headless`: the frame is then the CPU side only
(sim, the hooks, the views' script and canvas work), no GPU raster. The render cost of the feed's
gib/mark drawing is NOT measured here: it needs a quiet GPU (NEED below).

## Numbers (headless, editor build, 16 logical cores; busy = machine cores busy in the run's first 20 s)

| arm | round | p50 ms | p99 ms | worst ms | frames > 25 ms | busy cores | signature kills |
|---|---|---|---|---|---|---|---|
| off | 0 | 4.45 | 7.98 | 59.6 | 3 | 8.2 | - |
| on | 0 | 4.89 | 16.93 | 69.7 | 10 | 12.3 | split 25 |
| on | 1 | 5.20 | 27.22 | 307.6 | 44 | 15.7 | split 25 |
| off | 1 | 4.87 | 37.42 | 139.4 | 94 | 16.0 | - |
| **median off** | | 4.66 | 22.70 | 99.5 | 48.5 | | |
| **median on** | | 5.05 | 22.08 | 188.7 | 27 | | |

25 chainsaw grinds (style `split`, the chainsaw_grind row) in 60 s with the feed on; the off arm's
deaths are the generic `death_melee`.

The sim loop (`World.frame_loop_ms`, where a grind pile-up would land): p50 0.79 / 0.92 (off) vs
0.92 / 0.96 (on); p99 1.80 / 8.61 (off) vs 3.57 / 6.79 (on); max 7.7 / 61.9 (off) vs 17.8 / 42.7 (on).
The worst frames of every run sit at the same ticks in both arms (t2572, t2759: the street's own
spikes, process time, not the feed). Frames over 25 ms follow the machine's load (off r1 at 16 busy
cores: 94), not the arm.

## Verdict
- Feed CPU cost: about +0.4 ms p50 per frame (4.66 -> 5.05), sim loop +0.1 ms p50.
- No grind pile-up: the sim loop never went past 17.8 ms with the feed (the off arm reached 61.9 ms
  under load), and no on-arm frame over 25 ms is in the sim. On r0 (12 busy cores) had 5 frames over
  25 ms at ticks no off run had (2964-3014, 3261), all in `process` (5-38 ms) with the loop at
  1.2-1.8 ms: machine noise at this load, not provably the feed.
- So no cap on simultaneous grinds (no `signature_kills.json` change, no decisions line).
- Bar "no NEW frame over 25 ms in the horde take": not judgeable on this machine tonight (CONTENDED);
  CPU side shows no feed-made stall.

Seen in passing: the headless on arm logs one engine `ERROR: Condition
"!actions.custom_samplers.has(...)"` from `KillCharFx._char` (kill_char_fx.gd:189) at view attach;
the same line is in earlier headless arena logs (build/dev/arena-2026-11-25T04-08-49-830Z.log): a
dummy-renderer shader compile, not new.

Raw: `evidence/n31-melee/03-fatal/feed-cost.json` (per run + medians); frame logs in
`build/n31/03p3/feed-cost/` (git-ignored).

## 03p4: the rendered measure (2026-11-26 02:15-02:19, bench lock held)

`node tools/melee/feed_cost.mjs --rounds=2 --tag=03p4 --out=build/n31/03p4/feed-cost` (rendered: d3d12,
editor build, vsync off, `--fixed-fps 60`, chainsaw, seed 7, 3600 ticks; arms off = `--kill-feed=off`,
on = HEAD default). `C:\Users\kazda\kiro\gtai-n31\bench.lock` created by 03p4 for the run, removed after.
GPU free: worst draw of a frame 23-31 ms (startup tick 2 only), draw p50 under 1.2 ms, so not CONTENDED.

| run | p50 ms | p99 ms | worst ms | frames > 25 ms | busy cores |
|---|---|---|---|---|---|
| off r0 | 4.36 | 8.53 | 70.6 | 3 | 3.8 |
| on r0 | 5.96 | 12.01 | 67.6 | 2 | 5.5 |
| on r1 | 6.31 | 12.17 | 83.9 | 1 | 8.3 |
| off r1 | 4.79 | 10.58 | 67.9 | 8 | 5.1 |
| median off / on | 4.57 / 6.14 | 9.56 / 12.09 | 69.3 / 75.7 | 5.5 / 1.5 | |

(The tool's `>25` column skips the startup ticks; the per-tick list below does not.)

Per component, p50 off -> on (both rounds alike): draw 0.65 -> 1.12 ms, flush 1.3 -> 2.4 ms, render GPU
0.35 -> 0.80 ms, render CPU 0.24 -> 0.50 ms, process 2.45 -> 2.5 ms, sim loop 0.66 -> 0.69 ms; draw calls
273 -> 918 p50 (416 -> 1328 p99): the fatality pieces left on the street are the cost, about +1.5 ms p50
per frame paired by round (r0 +1.6, r1 +1.5), not the sim.

Frames over 25 ms, by tick: off r0 t2, 5, 14, 1971, 2572, 3090; on r0 t2, 5, 14, 2572, 3251; on r1 t2,
5, 14, 273, 2572; off r1 t2, 14, 2293, 2300 x2, 2489 x2, 2572, 3090, 3251. Every on-arm tick is also an
off-arm tick (t2/5/14 = startup, t2572 = the wave turn, 64-79 ms of process in all four runs, t3251 off r1)
except on r1 t273: 30.5 ms there, but t273 is a 20 ms process spike in EVERY run (off r0 21.1, on r0 21.3,
off r1 21.0) and on r1 ran 1.6x slower all round (8.3 busy cores, its t268-272 frames 3.2 ms against 1.9),
so it is the same event pushed over the line by load, not a feed-made frame.

### Verdict (rendered)
- Bar "no frame over 25 ms in the on arm that the off arm (same round load) does not also show": PASS
  (t273 on r1 is the shared spike above, under load). No grind pile-up: the sim loop p99 stays 1.7 ms.
- So no grind cap: no `signature_kills.json` value, no decisions line.
- The fatality's render cost is real but small at this load: +1.5 ms p50, +2.5 ms p99, draw calls x3.4
  (pieces stay on the street). Worth a look if a long wave stacks more pieces than seed 7's first minute.

Raw: `evidence/n31-melee/03-fatal/feed-cost-rendered.json` (per run + medians); frame logs in
`build/n31/03p4/feed-cost/` (git-ignored).
