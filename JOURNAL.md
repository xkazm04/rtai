# perf-city JOURNAL (day run 2026-11-04, lane d6-perf-city, cut from main a1275c82)

## Iteration 1 (13:28)
- FRICTION: the runner's iteration 1 died in 4 s on API billing (logs/perf-city/iter-001); no work, no JOURNAL.

## Iteration 2 (13:28-14:28), BUILD

Rules applied: STANDARDS section 20 (bench limits), AGENTS top rules (typed GDScript, dev-only code
in `project/dev/`, no frame delta in sim), the brief's contention rule (every number says
UNCONTENDED or CONTENDED). Bench lock `gtai-d6/bench.lock` held by perf-city from 13:36.

### 13:30 What reel chapter 18 actually shows (reel-1012, `gtai-masters/keep-2026-11-04/reel-1012.mp4`, 113.5-128.5 s)
- The chapter is a `--fixed-fps 60 --write-movie` capture (evidence/reel.sh -> film.sh). Under
  fixed fps every frame is exactly one tick, so **machine lag cannot appear in that film**.
- Frame-to-frame analysis (phase correlation of 899 frame pairs, YDIF): the camera pans smoothly
  (steady 2-3 px/frame), and the mp4's timestamps are clean (1078/1078 deltas at 16.7 ms).
- What reads as "lagging": two still stretches where nothing on the plaza moves: frames
  60-205 (**~2.4 s**) and 526-579 (~0.9 s). Rivet stands with his weapon up, the camera settles in
  1 px steps, only the paper grain changes. Cause (dev/showcase/combat_reel.gd `_pit`): the gun
  beat "walks in only on a guard inside the pit's zone"; on the city block the guards stand
  outside the zone, so the bot idles. That is bot pacing, not frame cost.

### 13:35 New tool: FightFrames (`--frames=<json> --frames-ticks=<n>` on the dev arena)
- `project/dev/bench/fight_frames.gd`: every frame's wall ms, all-scripts process ms (a
  FirstMark node at priority -4096 to the probe at +4096), World sim loop ms (`World.frame_loop_ms()`),
  render CPU/GPU, draw calls, pipeline compiles, sim tick. Logs each frame over 33 ms live.
- `evidence/perf/fight.sh <label>` runs reel ch 18's exact fight (`--arena=city --bot=reel
  --reel=pit --riot --loadout=pistol,plasma_rifle,rocket_launcher,molotov --ppm=32 --rigs --clean`)
  to tick 2100 (the film's length); `EXE=1` = the exported release (`windows-showcase`).
- `evidence/perf/film_rt.sh <label>`: the same in REAL TIME, screen-captured with gdigrab.
- `tools/bench/fight_graph.py`: frame-time graph PNG + sim-hold detection.

### 13:36-13:50 MILESTONE: reproduce + measure (UNCONTENDED: no other Godot, other lane idle; node runners only)
| run | build | vsync | p50 | p99 | 1 % low | worst | worst after 1 s | > 33 ms after 1 s |
|---|---|---|---|---|---|---|---|---|
| editor-vsyncoff-a | editor | off | 2.68 | 6.92 | 108 fps | 58.5 (tick 7, 12 pipelines) | 39.0 | 1 |
| exe-vsyncoff-a | release | off | 2.19 | 6.55 | 114 | 95.7 | 95.7 (tick 103) + 45.5 (tick 118) | 2 |
| exe-vsyncoff-b | release | off | 2.51 | 5.87 | 125 | 40.5 (tick 7) | 31.8 | 0 |
| exe-vsyncoff-c | release | off | 2.38 | 6.18 | 111 | 49.2 (tick 7) | 25.9 | 0 |
| before-rt-vsync (gdigrab on) | release | on | 16.67 | 21.26 | 39 | 35.6 | 35.5 | 4 (34-35 ms: one missed vsync each) |
- The p99 < 8.3 ms target already holds UNCONTENDED in the exported release (5.9-6.6 ms). The
  sim loop is 1-2 ms and all scripts 2.5-4 ms per frame; render CPU < 1 ms.
- The run-a hitches (96 ms / 45 ms at ticks 103/118) had process 2 ms, render < 1 ms and no
  pipeline compile: the time is outside our frame work. They did not recur in runs b, c or the vsync run.
- The first frame (tick 7) always carries 12 pipeline compiles (35-58 ms), inside the first second.
- Vsync on (as shipped): 2083 of 2092 frames step exactly one tick (0-step 4, 2-step 5); four
  frames of 34-35 ms in 35 s (missed vsync).
- Conclusion so far: r19's p99 miss (8.79 ms) and the "lag" were not a steady frame-cost problem in
  this fight. CONTENDED load, the first-frame compiles, and on film the bot's idle stretches explain them.

### 13:48-13:53 Bench (tools/bench/run.mjs --runs=1, exported windows-bench; evidence/perf/bench-1404/)
PARTLY CONTENDED: it started uncontended, but the other lane's Godot processes were up by about 13:51,
during the riot/drive48vsync part.
| scenario | p99 | 1 % low | worst | record |
|---|---|---|---|---|
| drive | 2.30 ms | 151 fps | 47.0 (present) | ~1.7 (pre-12 m city), 3.56 (9ebc5918) |
| drive48 | 5.33 | 95 | 61.4 (unexplained, process 7.8) | 2.17-3.69 (night) |
| riot | **7.61** | 101 | 44.8 (present) | 2.4 idle (pre-combat), 6.0 (9ebc5918) |
| drive48vsync | (vsync) | | 33.2 | |
- Aggregate MISSES p99CpuMs (7 ms) on the riot alone; drive is not "doubled" in this run (2.30).
  The riot needs a clean, locked re-run before anything is called a regression.
- FRICTION: tools/bench needs `build/export/windows-bench/` to exist (the export fails "path doesn't exist" otherwise).

### 13:53-13:57 Real-time film
- FRICTION: gdigrab `title=` grabs a D3D12 flip-model window black. ddagrab (Desktop Duplication)
  on the window's client rect (evidence/perf/client_rect.ps1) works; the window has to be
  --always-on-top because the owner is using the desktop. The capture drops/duplicates frames
  (1528 for 28 s), so the FightFrames log is the measure and the mp4 only shows the look.
- before-rt-vsync (CONTENDED: 4 Godot of the other lane): p50 16.69, p99 20.45, 1 frame over 33 ms
  after 1 s (34.0 ms).
- FightFrames "settled" now means after the first 1000 ms of wall time, not after 60 frames.
  Recomputed (after 1 s): exe-a 2 frames over 33 ms (95.7, 45.5), exe-verbose 1 (73.6 at tick
  1199, right after the first death), exe-b/c/editor 0.
- Evidence: `gtai-masters/d6/perf-city/` frames.json (6 entries).
