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

### 14:10-14:13 Gates + riot re-run
- Scenarios 46 ran, 0 failed (14:10). Gates: lint 13/13, unit 938/938, scenarios 46/46. The
  evidence runner (tools/evidence/run.mjs) was not run this session (it needs the full bench window).
- Riot alone, exported windows-bench, 2 x 60 s, under the bench lock but CONTENDED (the other lane
  had a Godot up): p99 12.00 / 11.88 ms, 1 % low 62 / 26 fps, worst 64 / **2633 ms**.
  evidence/perf/riot-1412-{1,2}.json. Every frame over 60 ms is cause `present` (draw incl. swap
  60-2632 ms, render CPU 1.0-1.5 ms, game 0.01-0.25 ms). The 2.6 s frame is a present stall: the
  GPU / compositor is shared (the other lane's renders, the owner's desktop), not riot work.
  Process ms also rises to 10-57 ms in the worst frames under this load. Our scripts get
  descheduled, so the riot's steady p99 can only be judged UNCONTENDED.

### 14:14 Housekeeping
- d6-combat-notes JOURNAL: no REQUEST addressed to perf-city. Scratch (601 MB of raw frames in
  temp) deleted; masters frames.json has 8 entries and matches the folder. The exported exes in
  build/export/ (git-ignored) are kept for the next iteration. The bench lock is released.
- Registry: the brief's rules (STANDARDS section 20, contention labels) governed every call here.
  There was no design fork, so no game-production registry subject was needed this iteration.

### 14:16-14:20 FRICTION: real-time capture of HEAD failed twice
- The exe window opened on the second display (client rect 402,1696). ddagrab output 0 covers
  only the primary display, so the grab failed ("Picture size invalid"). Adding `--screen 0` did
  not fix it on the retry. The frame log of that run is still valid: head-rt-vsync.json (vsync on,
  no other Godot at start): p50 16.68, p99 19.93, 1 frame over 33 ms after 1 s (38.2).
- Fix next: in client_rect.ps1, print the DXGI output index plus output-relative offsets (the
  Screen bounds: primary 3440x1440 at 0,0; DISPLAY5 1920x1080 at 0,1440), or move the window with
  SetWindowPos before grabbing.

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
- (14:20) Fix the film_rt.sh second-display capture (see the FRICTION above), then film the HEAD ch 18
  window in real time (ticks 960-1860 start 15.9 s after the probe's first frame) as the "after"
  of perf-city-1.
- (14:18) client_rect.ps1 now moves the window to 200,200 on the primary display (SetWindowPos),
  and the grab worked. But the owner's own terminal windows sat above the game for part of the
  44 s (--always-on-top did not hold against them), so the mp4 showed the owner's screen. It is
  DELETED, not kept. Desktop capture on the shared machine is not safe for evidence while the owner
  is at the desk. Next: film real time only when the desktop is idle, or capture inside the
  engine (a viewport-texture grab every frame costs ~ms, so measure it, then label the film with that cost).

## Iteration 3 (14:19-15:19), BUILD

Rules applied: STANDARDS section 20 (bench), AGENTS top rules (dev-only probe code in `project/dev/`,
typed GDScript), the brief's "optimise only what the profile proves" and "look unchanged".
Bench lock held by perf-city from 14:20. The machine is about 52 % CPU busy without any Godot
(docker, three node runners, launchers), so **every number below is CONTENDED** even though no
other Godot ran.

### 14:20 Cold shader cache: not the hitch source (exported release, vsync off, CONTENDED)
- cold-exe-1 (fresh APPDATA, empty shader cache): first frame 59.8 ms (12 pipelines), the later
  pipeline compiles at ticks 20/324/389/390/448 cost 2-8 ms frames, same as warm. Hitches of
  28-76 ms had 0 pipelines (draw/present or pump). warm-exe-1 straight after: p99 10.7 (5.9 at
  13:40 uncontended): the background load, not the cache.

### 14:25-14:50 MILESTONE: per-system profile (NodeSpans, `--spans=<json>`, commit 47774726 + fix)
- `project/dev/bench/node_spans.gd`: every processing node gets a strictly increasing priority in
  its own process order, with a mark before each one (the order and so the fight are unchanged).
  The flush is split on the CanvasItem `draw` signal; hooks are added on `node_added`.
- FRICTION/lesson: Godot 4 emits `draw` BEFORE the script's `_draw`, so the first cut charged each
  redraw to the NEXT item (kill_char_fx looked like 1 ms; stubbing its _draw out did not move
  the row). Fixed: an interval belongs to the item whose signal opened it.
- The city fight, editor, vsync on (60 fps, 1500 ticks), mean / p99 ms per frame (spans-fixed):
  | system | mean | p99 |
  |---|---|---|
  | world.gd (sim tick + nav, the World loop) | 1.27 | 1.64 |
  | draw: arena_floor_view.gd (the city block's barriers, cones, rings) | **1.00** | 1.70 |
  | draw: fx_view.gd (gun FX: shells, smoke, tracers, impacts) | 0.91 | 2.87 |
  | character_rigs.gd (rig posing) | 0.72 | 1.21 |
  | city_view.gd | 0.59 | 0.90 |
  | arena_rigs.gd | 0.33 | 0.45 |
  | collect_call_view.gd | 0.15 | 0.23 |
  | city_blood / kill_view / blood_fx / corpse_fade / kill_char_fx | < 0.1 each | |
- A tried `KillCharFx` skip for spent burns showed no gain, so it was reverted (the cost was never there).

### 14:50 Fix 1: ArenaFloorView prints the city block's static props once
- The floor `_draw` issued 27 props (barrier runs with a joint every 2 m, cones) and the crowd rings
  every frame: 0.43-0.64 ms, plus 19 target rings at 0.32-0.44 ms (editor build).
- On the city block (only there) the props and crowd rings now draw once on a `show_behind_parent`
  child with `use_parent_material` (the same draw order under the cars and rings, the same print).
  The dock arena keeps the old path. Props and spawns are built at load and never mutated.
- Pixel check: 420 fixed-fps frames (reel ch 18 args, 1280x720) rendered with the old and the
  new file are **pixel-identical** (0 frames with any differing pixel); frame 398 looked at: the
  barrier runs, joints, crate rows and cones are there. Commit 6b41019f; decisions line added.
- Editor spans (CONTENDED, CPU 93 % mid-run): floor 1.00 -> 0.69 ms mean, p99 1.70 -> 1.18; every
  other row rose 8-10 % in the same run.
- **Exported release** (windows-showcase, vsync on, 1500 ticks, interleaved pre/post exes that both
  carry NodeSpans; CONTENDED), evidence/perf/rel-*.json:
  | run | floor _draw mean | p99 | all spans mean | frame p99 | > 33 ms after 1 s |
  |---|---|---|---|---|---|
  | pre | 1.006 | 1.46 | 5.09 | 21.8 | 0 |
  | post | **0.612** | 0.98 | 4.52 | 24.9 | 0 |
  | pre2 | 0.767 | 1.27 | 3.92 | 20.2 | 2 |
  | post2 | **0.483** | 0.90 | 3.65 | 20.6 | 2 |
  -0.29 to -0.39 ms per frame on the floor (about -38 %). The vsync-on frame p99 (20-25 ms) is
  the machine (93 % CPU from other processes), not this fight's work, so it cannot move with a
  0.3 ms fix. Unit 938/938 after the fix (one throwaway FxView probe was in the tree for part of
  that run and has been restored; lint runs on every commit: 13/13).

### 14:46 FxView: where its 0.9 ms goes (throwaway probe, not committed)
- draw_under (ground scuffs <= 24, live 240 ticks; shells/mags <= 48) grows over the fight to
  ~0.4 ms+; draw_over (smoke, impact sparks, muzzle) ~0.1; GunFx.step ~0.02. FightScorch had
  0 marks in this stretch (checked, so no scorch work). Scuffs and shells are many small native draw calls:
  no identical-pixel shortcut found in the time left. Candidate next: print each scuff once to a
  ground layer while it holds full alpha (it fades only in its last 60 ticks).

### 14:52-15:00 Fix 2: ArenaFloorView culls off-screen target rings and tracks
- 19 target rings (0.8 m, 32-point arcs) plus moving tracks were issued every frame wherever the
  camera was. Now a ring is drawn only if its target stands inside the on-screen rect grown by
  3 m, and a track only if its box meets that rect.
- Pixel check: 420 fixed-fps frames vs the ORIGINAL file (before both fixes): 0 differing frames.
  (Caveat: whether any target ring was on screen in those 420 frames was not checked. The
  in-view path is the old code unchanged.)
- Exported release, interleaved, CONTENDED (evidence/perf/rel-{static,cull}{,2}.json):
  | run | floor _draw mean | p99 | all spans mean |
  |---|---|---|---|
  | static (fix 1 only) | 0.561 | 0.99 | 4.21 |
  | cull | **0.238** | 0.58 | 3.93 |
  | static2 | 0.581 | 1.00 | 4.36 |
  | cull2 | **0.261** | 0.61 | 4.03 |
- Floor total over both fixes: 0.77-1.01 -> 0.24-0.26 ms a frame (about -0.6 ms, -70 %), release.

### 15:03 Housekeeping
- d6-combat-notes JOURNAL: no REQUEST addressed to perf-city. The pixel-check renders (/tmp/px-*)
  and the cold APPDATA dir are deleted. build/export/{windows,windows-pre,windows-cull} are kept
  (git-ignored): windows-pre has NodeSpans + the old floor, windows-cull = f60cd1f5.
- There was no design fork, so no registry subject. Rules applied: STANDARDS section 20 + the brief
  ("look identical": proven by exact pixel compare, so no golden re-bless was needed).
- No masters clip this iteration. Both fixes are pixel-identical by construction and by the
  420-frame compare, so a before/after film would show the same pixels. The gain is CPU time
  (evidence/perf/rel-*.json).

NEXT:
- Gates on f60cd1f5: see the line below (unit + scenarios were running at 15:03). If they were not
  logged green, re-run them first. Also run `node tools/evidence/run.mjs --no-bench` once: the
  selftest's look goldens 11/11 + block 5/5 are the brief's look gate.
- Profile order now (release, per 60 fps frame): World loop ~1.0 ms, FxView _draw ~0.9 (ground
  scuffs <= 24 live 240 ticks + shells <= 48: many small native draw calls), CharacterRigs ~0.7,
  CityView ~0.6, ArenaRigs ~0.3, floor 0.25. Candidate next: FxView's scuffs printed once while
  at full alpha (they only fade in their last 60 ticks). It must stay pixel-identical: use the
  /tmp/pxcmp.py method (fixed-fps --write-movie of the reel ch 18 args, exact compare; script text
  is in this session's log; re-create it, 20 lines of PIL+numpy).
- The machine was 52-93 % CPU busy without any Godot all session: riot/drive bench vs records
  still needs a quiet window (bench lock, nothing else heavy). Same for the uncontended
  frame p99 re-check of the city fight after fixes 1+2 (fight.sh EXE=1 EXE_DIR=windows-cull --disable-vsync).
- Real-time film of ch 18 (perf-city-1 "after"): desktop capture only when the owner's desktop is idle.
- (15:06) Gates on f60cd1f5: lint 13/13, unit 938/938, scenarios 46/46 (exit 0). Not run: the
  evidence runner's selftest (look goldens 11/11, block 5/5). The 420-frame exact pixel compare
  stands in for it this iteration; run it first next session.
- Bench lock released 15:07.

## Iteration 5 (15:08-16:08), BUILD

- 15:08 read JOURNAL + git log. No bench.lock, no Godot running, but the machine is at 90 % CPU
  (docker, node runners, launchers): every number this session is CONTENDED. No REQUEST in
  d6-combat-notes' JOURNAL. First: the look gate (selftest) on f60cd1f5, then FxView scuffs.
- 15:20 Look gate on f60cd1f5 (fixes 1+2): `node tools/selftest/run.mjs` exit 0: look goldens
  11/11 (worst 0.00), block goldens 5/5 (worst 1.81), world lock holds, no new off-doctrine accents.

### 15:10-15:40 FxView: where its 0.9 ms goes (throwaway probe in fx_view/gun_fx_art, restored)
Editor, vsync off, CONTENDED (the other lane's Godot renders + 90 % CPU), ~11.5k frames each.
Means / p99 in ms: draw_under 0.56 / 1.9 (fxprobe-a), all in the impacts loop (u_impacts 0.56 / 2.05;
u_scorch 0.01 / 0.4; the shells are drawn by weapon-art here, u_bits ~0). draw_over 0.11 / 0.36,
shots 0.02 / 0.15, the rest < 0.02. Up to ~31 live impacts.
- Math only (draw calls stubbed, fxprobe-c): the impacts loop drops to 0.14 / 0.98. So the ~100
  circle polygons a frame (4 per scuff + a line) are the cost, not the GDScript math.
- Culling: none possible. 96847 of 96847 impact checks were inside the on-screen rect + 3 m (fxprobe-d).

### 15:20-15:40 Fix 3: FxGround, the retained ground-mark layer (DECISION in docs/decisions.md)
- `boot/collect_call/view/fx_ground.gd` + `fx_ground_mark.gd`: a behind-parent child of FxView
  (use_parent_material) draws the rifle drops and the fire scorch each frame (as FxView did), and holds one
  child per scuff / plasma scorch. A mark redraws only when its fade changes (the last 60 of 240
  ticks). The same GunFxMarks calls run in the same order. `FxGround.enabled = false` = the old path.
- Pixel proof: 900 fixed-fps frames (reel ch 18 args, 1280x720, flag off vs on) **0 differing**.
  I looked at frame 850: a live fight, tracers, scuffs on the asphalt.
- Editor, vsync on, 1500 ticks, NodeSpans, 2 interleaved pairs, CONTENDED (evidence/perf/gnd-*.spans.json):
  | run | FxView _draw | marks | FxGround | FxView total | all spans |
  |---|---|---|---|---|---|
  | off1 | 0.912 / p99 2.78 | - | - | 0.91 | 4.41 |
  | on1 | 0.314 / 0.77 | 0.183 / 0.90 | 0.032 | 0.53 | 4.04 |
  | off2 | 0.914 / 2.92 | - | - | 0.91 | 4.42 |
  | on2 | 0.324 / 0.82 | 0.203 / 1.03 | 0.033 | 0.56 | 4.07 |
  -0.35 to -0.38 ms per frame, and FxView's own p99 2.8-2.9 -> 0.8.
- Rules applied: STANDARDS section 20, AGENTS top rules 2/3 (typed, functions <= 40 lines: _draw split
  into _under), the brief's "look identical" rule (exact pixel compare, so no re-bless).
- 15:44 Gates on fix 3: lint 13/13, scenarios 46/46 (exit 0), unit 937/938 twice. The 1 failure is
  `test_noir_shadows` ("Parameter t is null", CityChunk shadow RIDs: the brief's known flake under load;
  it does not touch FxView/GunFx). FRICTION: `-gtest=` on gut_cmdln still ran the whole suite,
  so the flake was not re-run alone. Next session: re-run it alone (`-gselect=test_noir_shadows`).

### 15:45-15:50 Fix 3 in the exported release (windows-showcase -> build/export/windows-gnd; CONTENDED:
the other lane was rendering, CPU ~90 %), interleaved against windows-cull (fixes 1+2 only), 1500 ticks.
- Spans, vsync on (evidence/perf/rel3-*.spans.json):
  | run | FxView total mean | FxView p99 | all spans mean | frame p99 | > 33 ms after 1 s |
  |---|---|---|---|---|---|
  | cull1 | 0.740 | 2.39 | 3.62 | 21.2 | 1 |
  | gnd1 | **0.408** | 0.64 (+ marks 0.91) | **2.84** | 20.7 | 1 |
  | cull2 | 0.757 | 2.32 | 3.36 | 20.9 | 1 |
  | gnd2 | **0.424** | 0.69 (+ marks 0.88) | **2.75** | 21.1 | 0 |
- Vsync off, frame p99 (evidence/perf/rel3v-*.json): cull 8.31 / 11.41, gnd 7.47 / 9.66 ms; p50 1.8-2.0.
  The hitches (34-116 ms, 1-14 per run) came and went with the other lane's renders. Both pairs
  improved, but the size of the gain is not readable under this load. The uncontended re-check is still owed.
- Fixes 1-3 together, release, mean script+draw spans: 5.09 / 3.92 (pre, 13:xx) -> 2.75-2.84 ms a frame.
- 15:52 `test_noir_shadows` alone (`gut_cmdln -gdir=res://tests/unit -gselect=test_noir_shadows`):
  2/2 pass, so it was the known flake. Gates on f1c15f46: lint 13/13, unit 938/938 (937 + the flake
  green alone), scenarios 46/46, look goldens 11/11 + block 5/5 (selftest on f60cd1f5; fix 3 is
  pixel-identical by the 900-frame compare, and the selftest's city render does not load FxView).
- Scratch cleaned: /tmp/pxw-* (1.8k PNGs), the fxprobe frame logs. build/export/windows-gnd (= f1c15f46)
  and windows-cull (= f60cd1f5) are kept for the next interleaved A/B (git-ignored).
- No masters clip: fix 3 is pixel-identical, so a before/after film would show the same pixels.
  There was no design fork, so no registry subject was needed.

NEXT (iteration 6):
- Release profile now (rel3-gnd2, mean / p99 ms a frame): world.gd (sim + nav) 0.77 / 1.21,
  character_rigs 0.44 / 0.74, city_view 0.39 / 0.62, FxView 0.24 / 0.69 + marks 0.16 / 0.88,
  arena_rigs 0.21, floor 0.11. Scripts + draws total ~2.8 ms a frame (5.1 at the start of the day).
  The steady cost is far under the 8.3 ms target, so the remaining work is the hitches and proving it uncontended.
- The FxGroundMark p99 (0.9 ms) is the frames where many marks fade at once. If it matters: hold
  a mark's redraw to every 2nd fade step? NO: that changes pixels. Leave it.
- UNCONTENDED re-check still owed (the machine was 52-93 % busy all day): city fight release
  vsync off (fight.sh EXE=1 EXE_DIR=windows-gnd --disable-vsync, 3 runs), the riot + drive bench
  vs records (node tools/bench/run.mjs) under the bench lock in a quiet window.
- Real-time "after" film of ch 18 for perf-city-1: desktop capture only when the owner's desktop is idle.
- First frame's 12 pipeline compiles (35-58 ms, inside the first second): pre-warm like
  World._prewarm, only if the owner's first second matters.
- 15:53 No quiet window for the uncontended re-check: CPU 88 %, and two Godot processes from the other
  lane started 15:50. Skipped; the bench lock was never taken this session (no bench run).

## Iteration 7 (15:53-16:53), BUILD

- 15:53 read JOURNAL + git log. No REQUEST in d6-combat-notes' JOURNAL. CPU 87-97 % all session,
  and the owner was at the desk (last input 36 s earlier): desktop capture is unsafe and every number is CONTENDED.
  Bench lock taken 15:55.

### 15:56-16:02 Fixes 1-3 in the exported release, vsync on (as shipped), interleaved, CONTENDED (CPU 97 %)
windows-pre (before fixes 1-3) vs windows-gnd (= f1c15f46, fixes 1-3), 2100 ticks, no spans
(evidence/perf/rt7-*.json):
| run | p99 | 1 % low | > 33 ms after 1 s | flush (canvas _draw) mean | frames not stepping exactly 1 tick |
|---|---|---|---|---|---|
| pre-1 | 21.17 | 38 fps | 3 (34-35 ms) | 2.06 | 13 |
| gnd-1 | 21.40 | 42 | 2 (35.1, 33.3) | **0.87** | 6 |
| pre-2 | 20.89 | 43 | 1 (35.2) | 2.07 | 8 |
| gnd-2 | 20.98 | 43 | 1 (33.8) | **0.85** | 5 |
- The canvas flush is down 1.2 ms a frame in the shipped build. Frames that skip or repeat a tick
  (the visible stutter under vsync) went from 13/8 to 6/5. Frame p99 under vsync is the machine.
- Graphs: masters rt7-before-graph.png / rt7-after-graph.png.

### 16:02-16:12 Real-time film without desktop capture (tools/bench/rt_recon.py, commit 7183cf62)
- The owner was at the desk, so a desktop grab would film their windows. Instead: one --fixed-fps
  PNG render of the same fight (fixed7, 2101 frames, one tick each) + the real-time frame log.
  Each live frame shows the PNG of the tick it had on screen, held for the live frame's measured
  wall time, then the result is encoded at 60 fps CFR. Holds and skips appear as they did live. No frame is drawn or blended.
- masters ch18-rt-ab-before-after.mp4 (before | after, ticks 840-2080, 20.7 s) + rt7-{before,after}-graph.png.
  Looked at 12 s in: a live fight on the plaza, both sides.
- NOT validated against a real capture. The morning's desktop capture (before-rt-vsync.mp4) is framed
  differently (zoomed out ~5 % and shifted; best frame correlation 0.67-0.69, not a match). The likely cause,
  unverified, is the DPI change when that window was moved between displays. camera_rig follow/step
  take only the tick (no frame delta), so a live frame of tick T should equal the fixed-fps frame of T.

### 16:13-16:25 MILESTONE: the "1.2-1.9 s" release stall is bound to process age, not the fight (a5699ca5)
- Nearly every release run had one 25-95 ms draw-phase frame 1.2-1.9 s after the first fight frame.
- Scratch probes (/tmp, not committed): an empty ColorRect window in the same project, 3 x 4 s: no
  stall over 22 ms. 8 s, CONTENDED: random 22-42 ms frames (the machine). Arena loaded 3 s after the
  window opened: stalls follow the load, none 1.5 s later.
- FightFrames now logs `engine_ms_at_first`. Release (windows-age export), 4 runs: the stall fell at engine
  time 3934-4161 ms while its offset from the first frame varied 1176-1547 ms. In the editor the first
  frame comes ~5 s in, so the stall is hidden in the load (age7-*: none). Not fixed: no game work
  causes it. In the shipped boot the first ~4 s are title and loading. FINDING in decisions.md.
- Gates on a5699ca5's tree: lint 13/13, unit 937/938 (test_noir_shadows, the known flake, 2/2 green alone), scenarios exit 0.

### 16:26-16:32 Fix 4: Rivet's first draw of a carried gun loaded its art from disk mid-fight
- Every frame log (18 of 18, editor + release, all loads) has an 8-19 ms process frame at tick
  2018/2019, while the World loop was ~1 ms. NodeSpans to tick 2040 (t2019.spans.json):
  rivet_held_view.gd max 18.4 ms. `_swap` -> `WeaponArt.make_held` -> a synchronous `load()` of the
  gun's held / small / empty art on first use.
- RivetHeldView.warm() (in _ready, behind the load) makes and frees the held sprite of every carried
  gun and touches its mag/tank parts. Same calls, same textures, same pixels.
- Editor, spans, CONTENDED (t2019-warm): tick 2019 process 15.9 -> 3.8 ms, held view max 18.4 -> 1.9.
  over33_settled 1 -> 0. The flush of ~7 ms every 30 ticks in span runs is the probe's own rescan.
- DECISION line for rivet-arsenal in decisions.md. No new unit test: the gain is measured by the frame log
  (the evidence above). A test would need a full RivetCarry; it is owed.
- 16:33 Gates with fix 4: lint 13/13, unit 938/938, scenarios 46/46 (exit 0). The pixel compare (fixed7 =
  HEAD before fix 4 vs fixed7w, the same fixed-fps run with fix 4) is rendering.
