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

### 13:58-14:02 MILESTONE: the hitches are attributed (exported release, CONTENDED: other lane 2-4 Godot)
- contended-exe-d/e (vsync off): p99 6.72 / 10.73 ms, hitches 34-208 ms with all-scripts process
  only 3.5-6 ms, draw (HitchRecorder) about 1 ms, canary on time. So the stall is outside _process.
- FightFrames now splits the rest of the frame: flush (probe end -> frame_pre_draw), draw (pre ->
  post draw, includes the present), pump (post draw -> next first _process: OS events + physics),
  physics. contended-exe-f/g: **every mid-fight hitch is in the draw phase** (23-46 ms, render CPU
  < 1 ms, process 2-4, pump 0.1). The swap chain / present blocks; the game's work does not.
  One hitch also had flush 12.5 ms (deferred calls), worth a look if it recurs.
- p99 under contention: 6.7-10.7 ms (vsync off). UNCONTENDED: 5.9-6.6 ms.

### 14:03-14:07 A/B rejected: swapchain_image_count 3 -> 4 (override.cfg beside the exe, vsync on, as shipped)
| run | p99 | 1 % low | > 33 ms after 1 s |
|---|---|---|---|
| swap-A1 (default 3) | 18.98 | 47 | 1 (34.6) |
| swap-B1 (4) | 18.90 | 46 | 1 (34.7) |
| swap-A2 (3) | 19.74 | 47 | 1 (33.7) |
| swap-B2 (4) | 18.76 | 39 | 4 (worst 56.7) |
- No gain: DECISION keep the engine default (no project setting changed). The vsync-on fight has
  about one missed vsync (~34 ms) per 35 s after the first second, CONTENDED.

### Where the brief stands (14:08)
1. Reproduce + measure: DONE (editor + release, uncontended + contended, frame log + graphs).
2. Profile: sim loop / all scripts / flush / draw+present / pump / physics / render CPU+GPU split
   per frame. Per-system spans inside the scripts' 2.5-4 ms were NOT done: at 15-25 % of a
   16.7 ms frame they are not where the hitches are. The 9ebc5918 -> a1275c82 bisect was NOT done:
   uncontended there is no regression in this fight to bisect (p99 under target).
3. 424 ms worst / 50 ms hitches: present-phase stalls under load plus the first frame's 12
   pipeline compiles (35-58 ms, inside the first second). No game-side hot spot found.
4. Fixes: none needed for the targets uncontended; the swap chain A/B was rejected.
5. Targets (release, UNCONTENDED): p99 5.9-6.6 < 8.3 MET; 60 fps MET (vsync paced, 2083/2092
   frames one tick each); "no frame > 33 ms after the first second": 3 of 6 vsync-off runs had
   0, run a had 2 (96/46 ms), the verbose run had 1 (74 ms), all present-phase / outside game work.
   Riot 7.61 (record 6.0 / 2.4 idle) and drive 2.30 (record 3.56), PARTLY CONTENDED, 1 run.
6. Film: BEFORE real-time film + graph done (before-rt-vsync). There is no "after": no code change
   to the fight. The owner's ch 18 "lag" is the still stretch (clip + Call for the owner).

### 14:06-14:12 MILESTONE: on main the ch 18 dead time is mostly gone already
- Fixed-fps film of HEAD (a1275c82) with reel.sh's exact args, cut at reel.sh's 16 s offset:
  **49 still frames (0.8 s) in 15 s vs 210 (3.5 s) in reel-1012's chapter 18** (same metric:
  YDIF < 2.5 over the play area). Rivet's 50 % speed-up (6e3b5fa5) took out most of the
  wave-gap idling. Clips: ch18-head-fixedfps.mp4 (drop-in chapter), ch18-ab-reel1012-vs-head.mp4.
- Gates on this branch: lint 13/13, unit 938/938 (14:10).

## Calls for the owner (draft for REPORT)
- perf-city-1, reel ch 18: the "lag" is 2.4 s + 0.9 s where no guard stands (between pit waves),
  not frame cost. Options: (a) re-cut ch 18 from a window with no wave gap (film edit only),
  (b) the reel bot walks Rivet toward the next wave's door during the gap (dev bot only),
  (c) shorter pit wave gap on the city block (gameplay data). Default if no answer: (a), and on
  main (a) is nearly free: the same cut is down to 0.8 s of stillness (ch18-ab-reel1012-vs-head.mp4).
  Clip: gtai-masters/d6/perf-city/ch18-still-stretch-reel1012.mp4 vs before-rt-vsync.mp4.

NEXT:
- Riot re-run ALONE under the bench lock with nothing else running (`node tools/bench/run.mjs --runs=3`
  or the riot scenario only). 7.61 ms was partly contended; if it holds clean, bisect 9ebc5918..a1275c82
  on the riot (evidence/riot-bisect has the old tooling).
- perf-city-1 (a): the fixed-fps HEAD cut exists (ch18-head-fixedfps.mp4). Still to do: film the
  same window in REAL TIME (film_rt.sh, mapping ticks 960-1860 to wall time via the FightFrames
  tick log) UNCONTENDED, and tell the Director the next reel can use the HEAD cut.
- If a hitch shows flush > 10 ms again: find the deferred call (CombatBlood `_bleed_killed.call_deferred`
  and friends) with a --verbose run.
- The first frame's 12 pipeline compiles in the arena-city path (35-58 ms): pre-warm like
  World._prewarm does for the city, if the owner sees the first second.
