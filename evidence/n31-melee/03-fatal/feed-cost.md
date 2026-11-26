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
