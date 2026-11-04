# REPORT (DRAFT, updated 17:55 in iteration 9) - day lane perf-city, 2026-11-04

Branch `d6-perf-city`, cut from main `a1275c82`. Clips and graphs are in
`C:\Users\kazda\kiro\gtai-masters\d6\perf-city\` (`frames.json`, newest and best first).
Journal: `JOURNAL.md` in the lane worktree. Raw frame logs: `evidence/perf/*.json`.
Gates on 5e21053a (`node tools/evidence/run.mjs --no-bench`, all PASS): lint 13/13, unit 941/941, scenarios 46/46,
parity bit-exact (planted mutation caught at step 629), selftest pass (look goldens 11/11 worst 0.00, block 5/5 worst 1.81).

**Contention.** The machine was 52-100 % CPU busy all day: docker, node runners, many Python jobs,
and the other lane's Godot renders. Only the 13:36-13:50 runs were UNCONTENDED. Every number after
that is CONTENDED, and the post-fix uncontended re-check is **still owed**.

## The owner's complaint: reel chapter 18 "is lagging, cannot be watched"
- **What the film shows.** Most of the "lag" in reel-1012's chapter 18 was dead time: 3.5 s of
  still frames in 15 s, where no guard stands between pit waves. It was not frame cost.
  Rivet's 50 % speed-up on main (6e3b5fa5) took most of it out: the same cut on main has 0.8 s still.
  Clips: `ch18-still-stretch-reel1012.mp4`, `ch18-ab-reel1012-vs-head.mp4`, `ch18-head-fixedfps.mp4`.
- **What the frame log shows** (exported release, UNCONTENDED, before any fix, vsync off):
  p50 2.2-2.5 ms, p99 5.9-6.6 ms (target 8.3: met), 1 % low 111-125 fps. With vsync on (as shipped),
  2083 of 2092 frames step exactly one tick.
- **Real-time film, before | after fixes 1-3**: `ch18-rt-ab-before-after.mp4` (20.7 s) with the
  frame-time graphs `rt7-before-graph.png` and `rt7-after-graph.png`. It was rebuilt from the real-time
  frame log plus fixed-fps renders (`tools/bench/rt_recon.py`), because a desktop grab would have filmed
  the owner's windows. It is not yet validated against a real desktop capture.

## Fixes (all pixel-identical: exact compare of fixed-fps renders, 0 differing frames; no re-bless)
| # | what | release cost before -> after (CONTENDED) | proof |
|---|---|---|---|
| 1 | ArenaFloorView prints the city block's static props and crowd rings once | floor _draw 1.01 -> 0.61 ms a frame | 420 frames identical |
| 2 | ArenaFloorView culls off-screen target rings and tracks (3 m margin) | floor 0.57 -> 0.25 ms | 420 frames identical |
| 3 | FxGround: gun ground marks retained, one child per mark, redrawn only while fading | FxView 0.74 -> 0.41 ms, FxView p99 2.4 -> 0.7 | 900 frames identical |
| 5 | CorpseStains: each corpse soak prints in one draw call (CircleFan, the engine's circle fan as one triangle array) | riot: 1759 -> 673 draw calls a frame (load-independent), render CPU 1.38 -> 0.73 ms | 921600 px identical; test_circle_fan 4/4 |
| 4 | RivetHeldView.warm(): the carried guns' art loads at load, not on the first draw | tick 2019 process 9.9-19.2 -> 2.7 ms (the spike was in 18 of 18 logs); tick 1528 5.6-8.5 -> 2.8 (editor 22.0 -> 3.3) | 512 frames identical; test_rivet_held_warm 3/3 |

Together: scripts + draws went from 5.1 to 2.8 ms a frame in the release. With vsync on, the canvas flush fell
2.06 -> 0.86 ms a frame, and frames that skip or repeat a tick (the visible stutter) went from 13/8 to 6/5 per 35 s. Draw calls a frame
(a count, not affected by load): 557 -> 534 (-4 %). Most of the gain is GDScript canvas work, not GPU batches.

## The hitches (424 ms worst, 50 ms hitches in r19)
- Every mid-fight hitch logged over 33 ms was in the **draw/present phase**: render CPU < 1 ms, game
  scripts 2-4 ms, so the time is outside the game's work. These came and went with the machine's
  load, up to a 2.6 s present stall in a contended riot.
- **The first frame** carries 12 pipeline compiles (35-58 ms) inside the first second. A cold shader
  cache adds nothing mid-fight.
- **About 4 s after launch**, the release has one 25-95 ms frame that follows process age, not the fight
  (engine time 3934-4161 ms in 4 runs). In the shipped boot that falls in title and loading. FINDING in decisions.md.
- **Rejected:** swapchain_image_count 3 -> 4 (no gain, 2 pairs).

## Targets (exported release)
- p99 < 8.3 ms: **met UNCONTENDED before the fixes** (5.9-6.6). After the fixes it is not yet re-measured uncontended.
- 60 fps: vsync paced; 99.6 % of frames step one tick (UNCONTENDED, before).
- No frame > 33 ms after the first second: 3 of 6 uncontended vsync-off runs had none. The other 3 had 1-2 present-phase stalls.
- **The riot regression has a cause, and fix 5 removes it.** The 2026-11-03 bisect put the d-combat step (avg frame 1.13 -> 2.08 ms)
  on CityBlood. Its scripts are only 0.1-0.3 ms a frame. The rest was ~1100 unbatched circle draw calls a frame from the corpse
  soaks (A/B: noir 1759, ink 623, stains off 658, fix 5 673). A clean riot p99 against the 7 ms limit is still owed (CONTENDED all day).
- Riot / drive vs records: riot 7.61 ms p99 (record 6.0; 2.4 idle pre-combat), drive 2.30 (record 3.56).
  PARTLY CONTENDED, 1 run. A clean riot run, and its bisect if it holds, is owed.

## Calls for the owner
- **perf-city-1, reel chapter 18 dead time.** Options:
  - (a) re-cut ch 18 from a window with no wave gap (film edit only);
  - (b) the reel bot walks to the next wave's door during the gap (dev bot only);
  - (c) a shorter pit wave gap on the city block (gameplay data).

  Default: (a). On main it is nearly free (0.8 s still). Clip: `ch18-ab-reel1012-vs-head.mp4`.
- (Informational) The ~35 ms frame ~4 s after launch is process age, not the fight. No action proposed.

## Owed
- An UNCONTENDED re-check of fixes 1-4 (release, vsync off, 3 runs), plus riot and drive under the bench lock.
- Validate rt_recon against a real desktop capture on an idle desktop.
