# n9 perf JOURNAL (branch n9-perf, cut from main da108c13)

## it1 00:56 BUILD
- Read: brief, AGENTS, decisions tail, LEDGER F19 (d9 it21: quest 1 --autostart freezes ~1 in 4, main thread parked in a
  blocking wait, 0 CPU on the main thread; suspects chunk_source.take / save_worker._collect / load_threaded_get).
- Registry rules applied: runtime-observation-evidence (observe the frozen process, not guess: per-thread CPU + trace of
  every wait the main thread can make), measurement-honesty (a count of N runs with a denominator, CONTENDED labelled).
- No procdump / cdb on the machine (only dbghelp.dll in the Windows Kits Debuggers dir). Plan: temporary printerr trace
  around every main-thread wait in our GDScript (WT> enter / WT< exit, plus a 30-frame heartbeat), hunt2.ps1 loops
  windowed --autostart runs and keeps the logs of the frozen ones. The trace edits are scratch, never committed.
- 01:05 MILESTONE (F-19 located, first layer): trace rounds trace1 (3 frozen / 7 valid runs) and trace3 (2 / 8):
  every freeze lands in the first ~30 frames after Start; no WT> (chunk take, save collect, threaded texture get) is open.
  With crowd-bake traces the last line of both frozen trace3 runs is `CB> cap`: the main thread parked inside
  `CrowdBaker._capture` -> `_vp.get_texture().get_image()` (a synchronous RD download). Logs: evidence/perf/f19-freeze/
  freeze-trace{1,3}-*.log, trace patch trace.patch.
- 01:12 Built CrowdReadback (texture_get_data_async, `--crowd-readback=sync` = old arm). Crowd atlas md5 identical on both
  arms, 2 runs each (a1a606047fc4; atlas_ab.sh), every cell filled (looked at it).
- 01:15 FRICTION: the 40-run acceptance froze on run 2 WITH the async readback. trace4: the frame loop now stops after
  `HB pf6` with no GDScript wait open: the hang is inside the engine's own frame (an RD/GPU sync wait), and the
  sync readback was only the first place that wait was hit. nobake (CB_SKIP scratch hook, the bake skipped): froze 1 of 2.
  So neither the readback nor the bake is the cause. Vulkan arm: crashes at boot in amdxc64.dll (the AMD iGPU), no arm.
- 01:25 Installed WinDbg (winget Microsoft.WinDbg; cdb copied to gtai-n9/tools/windbg) to take native stacks of a frozen
  run (hunt2.ps1 F19_CDB=1 -> stacks-<tag>-<n>.txt; OS/D3D12 frames symbolised from the MS symbol server, Godot frames
  only as offsets: the official build ships no PDB).
- 01:28 MILESTONE (F-19 located in the engine): cdb round 4 / 8 frozen, the SAME main-thread stack in all 4:
  RenderingServerDefault::_draw -> RenderingDevice::_begin_frame -> its per-frame fence stall -> the D3D12 fence_wait
  (SetEventOnCompletion + WaitForSingleObjectEx INFINITE). Named by static disassembly of the official exe (`cdb -z`,
  the error strings each function references). Every other thread is idle: the GPU never finishes a frame (most likely
  a queue wait on a semaphore never signalled: the transfer workers' upload semaphores are the prime suspect).
  LEDGER "n9 night / F19" has the table and the stack.
- 01:30 Committed 827aefe3: the async crowd readback (byte-identical atlas, full unit suite 1802 / 0, lint 15 / 15),
  labelled NOT the fix. tools/art/split_sheet.py written for item 2 (p70 -> 3 bands 27.6 / 20.7 / 20.7 MB, p55 ->
  2 x 19.1 MB, both stack back byte-identical); not wired into the game yet.
- Registry rules applied: runtime-observation-evidence (stacks of the live frozen process, not a guess),
  measurement-honesty (each count with its denominator; fix40 reported as the failure it is; all CONTENDED).
- DECISION perf/crowd readback: async readback kept (no main-thread stall, same bytes), recorded in docs/decisions.md;
  explicitly not claimed as the F-19 fix.
- 01:38 READ journals: world NOTE (01:36) item 1 landed at 3e02d3b8 (combo default, bikes 6 %, BC7 on 772 imports,
  goldens re-blessed). No REQUEST to perf from world / rivet / handheld. Consequence for item 2: under BC7 the p70
  traffic sheet is 4032 x 4480 x 1 B = ~18 MB (one upload, a 32 MB pow2 staging buffer), already under the 32 MB line;
  the split only pays where the sheet stays lossless. Check on world's branch before wiring it in.
- 01:37 rtsep (`--render-thread separate`): 3 / 8 frozen: no workaround.
- 01:40 MILESTONE novsync (`--disable-vsync`): **0 / 8 frozen** (every vsync arm ~1 in 3). The hang is tied to the vsync
  present path (a present that never completes would block the queue, and the frame fence after it never signals) or
  to vsync's timing. settings.apply() at Start sets no vsync mode (checked). FIRST in it2: `--disable-vsync --max-fps 60`
  (vsync off, same pacing) and the mailbox mode, 10 runs each; if vsync-off-capped holds at 0 / 40 it is the fix candidate
  (a frame-pacing call: tearing; the owner's pacing option, item 3, could carry it).

NEXT (it2):
1. F-19 is an ENGINE hang (RenderingDevice::_begin_frame -> fence_wait INFINITE on a frame fence; LEDGER n9 F19).
   a. Read servers/rendering/rendering_device.cpp (4.7 branch, raw github, ~450 KB: WebFetch with offset 100000,
      200000, ...) for `_stall_for_frame`, `_end_frame`/`_execute_frame`, `_submit_transfer_workers`: list the
      semaphores the frame submission waits on and how one can be left unsignalled.
   b. Confirm on a live frozen run with cdb (`hunt2.ps1`, F19_CDB=1 + extra commands): the frame fence's
      `GetCompletedValue` vs the waited value, and what the queue is blocked on.
   c. Workaround candidates (each one hunt2 round of 8-10; acceptance is 0 / 40): preload/upload every quest texture
      on the title card before Start (no uploads in the first frames); `rendering/rendering_device/vsync/
      frame_queue_size`; delay the first quest frames' uploads; check the release export and the real Start click
      (no --autostart: `hunt2.ps1 -NoAutostart` + a click, or `-Exe build/export/windows/RTAI.exe`).
   d. If it needs an engine patch: a 4.7.2 template build with the fix (tools/perf/template/strip.py has the MSVC
      recipe) = an owner Call (custom engine), with the counts.
2. Traffic split (item 2): BC7 landed on world (3e02d3b8). Measure the p70 traffic sheet's import size there; if
   <= 32 MB the split is moot under BC7 (DECISION + LEDGER), else wire tools/art/split_sheet.py bands into
   VehicleCards (one MultiMesh, the shader picks the band: draw order unchanged) + frame diff + ab.mjs under bench.lock.
3. Pacing option (item 3): PlayerSettings `pacing` efficient / steady in the pause card (desktop default efficient).
4. Re-measure the frame-time / VRAM / RAM table on world's branch (its NOTE says BC7 landed).
- 01:45 MILESTONE novsync60 (`--disable-vsync --max-fps 60`): 0 / 8 at the vsync runs' own CPU (0.21-0.28 cores): NOT
  timing. Vsync off: 0 / 16, vsync on: ~1 in 3. The F-19 hang follows the D3D12 vsync present. it2 FIRST: mailbox mode
  (project `display/window/vsync/vsync_mode=3` via a scratch override, or a runtime DisplayServer.window_set_vsync_mode),
  then the 40-run acceptance on the best vsync-respecting arm; vsync off + 60 cap is the fallback (tearing: an owner Call).
- 01:50 MILESTONE mailbox (vsync_mode=3 through a temporary override.cfg line, restored): 0 / 8, no tearing.
  Vsync off or mailbox: 0 / 24; vsync Enabled: ~1 in 3. NEXT it2, item 1 FIRST: ship mailbox as the desktop default
  (project.godot `display/window/vsync/vsync_mode=3`, or at boot beside FrameCap, one value away), then the 40-run
  acceptance, the pacing / CPU A/B vs Enabled under bench.lock (ab.mjs), the release export and the real Start click,
  plus a test that pins the mode. Then items 2-4 as above.

## it2 01:52 BUILD
- Read: JOURNAL it1 NEXT, git log, world / rivet / handheld journals. REQUEST from world (it1): the card rigs under
  combo cost ~2x top (rig_stress p50 1.1-1.4 vs 0.5-0.76 ms at 50 people). Accepted: profiled in it3 (below).
- Registry rules applied: runtime-observation-evidence (a 0-CPU run is classified from the live process: threads,
  exit, Responding, not from the CPU number alone), measurement-honesty (every count with its denominator, the
  exited run reported, not hidden or counted as a pass).
- 01:55 F-19 fix built: `display/window/vsync/vsync_mode.windows=3` (mailbox, Windows only; the Deck / Linux rows
  keep their own). A scratch probe (deleted) read the live window's mode = 3. `test_frame_cap` pins it.
- 02:01 MILESTONE item 3: the pacing option (efficient / steady) in the pause card's settings, saved in
  settings.json; FrameCap.pacing_cap / apply_pacing; tests 26 / 0 (frame_cap, player_settings, settings_panel_pad;
  the desktop rebind rows moved down one). Commit d6e93b92. DECISION perf/frame-pacing-option.
- FRICTION: mb40 ran from this worktree while I edited `project/` and ran the unit runner (it imports into the same
  `.godot/`). Run 16 read 0 CPU but its process was already gone (no threads, no crash text): reported as
  "exited", not as a pass. hunt2 now classifies exited / idle / frozen. Lesson: no Godot from the hunt's worktree.
- 02:09 MILESTONE F-19: mb40 = 0 parked / 40 (1 exited, above). Committed 06c48c1b. mb40b (exit-aware hunt, cdb on any
  freeze, nothing else from this tree) running.
- 02:12 MILESTONE: the real Start press works: Alt tap + SetForegroundWindow + SendKeys Enter on the focused Start
  (`hunt2.ps1 -PressStart`); the release `windows-slice` export (build/export/slice/RTAI-slice.exe, 02:05) reaches
  quest 1 with it (`evidence/perf/f19-freeze/rel-start-pressed.jpg`, looked at it: the dumpster beat, Rivet's line).
  The first -Exe tries failed because hunt2 hid the exe's own window. rel20 (release + real press, 20 runs) running.
- Item 2 DECIDED moot under BC7: world's import of the p70 traffic sheet is 18.06 MB BC7 (32 MB staging, was 128 MB).
  DECISION perf/traffic-split-under-bc7; LEDGER "Item 2". The RAM A/B lossless vs BC7 is world's item 1 job.
- 02:21 MILESTONE F-19 ACCEPTED: mb40b **0 / 40** (exit-aware hunt, 40 / 40 reached quest 1); rel20 **0 / 20** with
  the release `windows-slice` export and a real Start press. Mailbox total: 0 parked-fence freezes in 107 valid runs,
  Enabled 19 / 47. Source read: mailbox differs from Enabled only by DXGI_PRESENT_RESTART (no queued present).
  DECISION perf/f19-mailbox. Owner Call: mailbox as the default (built) vs Enabled.
- 02:23 world's REQUEST answered (LEDGER "World's REQUEST"): profile of the 50-person rig stress top vs combo in a
  throwaway worktree (scratch timers, removed): combo's extra ~0.45-0.5 ms a tick = StreetView.step 0.23-0.35 ms +
  RigHeadCard.step 0.09-0.14 ms + 8 % more pose steps; the cut rig still poses fully (~0.7 ms) under the cards.
  `evidence/perf/n9-rig-combo/prof.txt` + `prof.patch`.
NOTE to world: the combo rig cost is StreetView.step (~0.23-0.35 ms/tick: shield, crowd, walker cards, Rivet frames)
  plus RigHeadCard.step (~0.09-0.14); numbers in docs/perf/LEDGER.md on n9-perf. I break StreetView.step down per card
  kind in it3 and send the cut as a REQUEST to the owning lane (characters' files are not mine).
- FRICTION (02:16): the first profile script hung 5 min (a `-s` script that names autoload-dependent classes fails to
  compile and the tree never quits); the `_initialize` + load() runner pattern (rig_bench.gd) works.

NEXT (it3):
1. world's REQUEST, part 2: break StreetView.step down (RiotShieldCard / StreetCrowdCards / StreetWalkerCards /
   RivetFrames) and RigHeadCard.step with the same scratch timers (`evidence/perf/n9-rig-combo/prof.patch`, a throwaway
   worktree), find the per-tick work that could be dirty-flagged, and test whether RigPose can be skipped for rigs a
   card hides; REQUEST the cut with numbers to the owner of the file (git log -1 on each).
2. Pacing A/B on mailbox: efficient vs steady (`--max-fps 60`) riot60 + drive60 under bench.lock (ab.mjs, 3 pairs),
   and mailbox vs Enabled CPU / p99 to confirm the default costs nothing (L11 said WASH; re-check on d9 main).
3. Item 4: once world's BC7 A/B lands, re-measure the frame-time / VRAM / RAM table on n9-world (ab.mjs, bench.lock),
   both the desktop and handheld's deck row.
4. The full gates on this branch before the freeze: `node tools/tests/run_unit.mjs` (no-arg), `node tools/evidence/run.mjs
   --no-bench`, the director reel x3 views (`--quit-after 16000`).
5. Owner clips: the King fight and the city drive with the perf HUD, before/after (gtai-masters/n9/perf, frames.json).
6. A still of the pacing row in the real pause card (owed: Esc during the opening dialogue did not open the pause
   card in the release exe at 02:29; press it after the first beat, or film the settings panel via a dev path).
- 02:27 full unit suite 1823 / 0 (53.6 s). Evidence `--no-bench` started 02:28 (log in gtai-n9/tmp/perf/evidence-it2.log).
- 02:37 GATE RESULT `node tools/evidence/run.mjs --no-bench` at 40fb2da3: lint PASS, scenarios 54 / 54, parity bit-exact
  (mutation caught at 629), release-compile 615 / 0, unit 1823 / 0 (flagged FAIL only because I appended to JOURNAL.md
  during the run). **selftest FAIL: look goldens 5 / 11 within mean 4 (worst 6.46; OFF d1@32, d1@48, d4@32, d4@48,
  d4@64, auto@48), block goldens 1 / 5 (worst 7.51)** (`evidence/perf/n9-gates/selftest-it2-40fb2da3.json`).
  The selftest is WINDOWED (`--fixed-fps 60`), so two suspects on this branch: (a) the mailbox default (06c48c1b) and
  (b) it1's async crowd readback (827aefe3), whose atlas may land a frame later than the synchronous read did, so an
  early golden frame draws the crowd before the atlas is in. Not yet bisected. **This branch is NOT mergeable until it is.**

NEXT (it3) FIRST, before everything above:
0. Bisect the golden miss: run the selftest (`node -e "import('./tools/selftest/run.mjs').then(m => m.runSelftest('build/sel'))"`
   or the evidence run with `--no-parity --no-release`) with (a) `display/window/vsync/vsync_mode.windows=1` in the
   local override.cfg (restore it after), (b) `--crowd-readback=sync` if the selftest scenes accept it (else revert
   827aefe3 in a scratch worktree). If (b): the golden frames must wait for the atlas (CrowdReadback ready) or the
   readback goes back to sync for the bake (F-19 no longer needs it). If (a): read the golden capture's frame timing;
   mailbox must not change a pixel, or it is an owner Call. Also compare main da108c13 itself (world's 11 / 11 is on
   its own re-blessed branch).
- 02:40 BISECT (a): selftest with `vsync_mode.windows=1` in a temporary override.cfg line (restored): the SAME miss
  (5 / 11, worst 6.46): mailbox is NOT the cause.
- 02:42 BISECT (b): selftest with `CrowdReadback.async_on()` forced false (scratch, restored): **look goldens 11 / 11,
  worst 0.27**: the async crowd readback (827aefe3) was moving the goldens. FIX: sync is the default again,
  `--crowd-readback=async` the arm; test_crowd_readback flipped; 16 / 0. DECISION perf/crowd-readback-sync-default.
  Not yet re-run: the full evidence gate on the fix commit (it3 item 0 now = re-run `node tools/evidence/run.mjs
  --no-bench` and confirm 11 / 11 + block 5 / 5; then the director reel x3).
NEXT (it3) item 0 replaced: re-run the evidence gate on the fix; then items 1-6 above.
- 02:46 MILESTONE: selftest on 6d365066 (committed tree): **18 / 18 pass, look goldens 11 / 11 (worst 0.27), block
  goldens 5 / 5 (worst 0.22)**. With it2's unit 1823 / 0, scenarios 54 / 54, parity exact and release-compile 615 / 0
  (on 40fb2da3; the fix after it touches only the crowd readback default) the gates are green except the director reel
  x3 (not run this iteration: it3).
NEXT (it3), in order: 0. director reel 19/19 in top, tilt70, combo (`--quit-after 16000`) on n9-perf HEAD;
  1-6 as listed above (world's StreetView.step breakdown first, then the mailbox/steady pacing A/B, item 4 on world).

## it3 (2026-11-08 02:48-03:48) BUILD
- Read: JOURNAL it2 NEXT, git log, world / rivet / handheld journals (world it7: no new REQUEST to perf; handheld /
  rivet: none). Registry rules applied: measurement-honesty (every prof number labelled CONTENDED, a ~5 % cut called
  a wash, not a win), perf-instrumentation (timers in a throwaway worktree only, the patch kept as evidence).
- 02:50 director reel x3 started on 54de9b41 (headless, fixed 60, `--quit-after 16000`, evidence/perf/n9-reel/).
- 03:00 world's REQUEST part 2 done: StreetView.step per card kind (LEDGER "World's REQUEST, part 2"). Walker cards
  ~157-206 us/tick (strip_of 57-75, hide_all 26-32, place 58-80), Rivet 31-39, RigHeadCard._place 66-88. Prototype
  cut (fill cache + one global_transform + street_row first): -20 to -30 us/tick = a wash (~5 % of combo's extra).
NOTE to world (answer to your it1 REQUEST, part 2): combo's rig cost is spread over many small GDScript calls on
  every rig, no single card kind; the only cut I measured is StreetWalkerCards.place (-20 us/tick, ~25 % of place):
  `evidence/perf/n9-rig-combo/walker-place.patch` on n9-perf, optional (your file tonight). Numbers in LEDGER.
- 03:00 GATE director reel x3 on 54de9b41 (headless, fixed 60, `--quit-after 16000`): **19 / 19 chapters down in top,
  tilt70 and combo, 0 SCRIPT ERROR** each (`evidence/perf/n9-reel/{top,tilt70,combo}.log`).
- 03:03 MILESTONE item 2 of NEXT (pacing A/B on mailbox, riot60 x3, bench.lock): mailbox = Enabled in CPU (0.40 vs
  0.41) and frames (no uncapped loop at 60 Hz); in its 2 CONTENDED rounds mailbox showed 10-13 no-tick + 12-14
  double-tick frames (Enabled 0 / 2 under the same load); steady (mbox + 60 limiter) p99 18.6 vs 22.5-26.9, multiTick
  0-3, +0.08 core. LEDGER "Pacing A/B on the mailbox default". Signal, small sample: added to the owner Call.
- 03:06 item 4: BC7 desktop table, main da108c13 vs n9-world 746c2856 (world's committed tree, its .godot copied,
  main's DLLs: world's bin DLL carries its uncommitted knock sim), scratch worktrees under gtai-n9/tmp/perf
  (prof3 = main, world3), `ab.mjs --scenes=king,drive70,riot --pairs=3`, `evidence/perf/n9-bc7-table/`.
- 03:11 MILESTONE item 4 (desktop table on world's BC7, LEDGER "Item 4"): VRAM drive70 900 -> 548 MB, riot 899 -> 536 MB
  (-352 / -362), frame time WASH on king / riot, drive70 p99 5.58 -> 5.14 (-8 %, spreads 0.03 / 0.07), GPU -0.03 ms;
  RAM moves less than the -96 MB estimate (King 801 -> 733 within main's spread 49). Deck row = handheld's E16.
- 03:14 MILESTONE item 5 (owner clips): `gtai-masters/n9/perf/king32-main-vs-bc7.mp4` and `drive32-main-vs-bc7.mp4`
  (movie mode, perf HUD, left main, right world's BC7), end stills looked at (VRAM 635 vs 413, 917 vs 546 MB; the
  drive's traffic differs by world's bikes, not BC7). frames.json 4 entries. Scratch .avi deleted.
- 03:15 pacing A/B 2 (drive60 + riot60, enab vs mbox, 3 pairs, bench.lock) running: firms up or drops the it3
  "mailbox drops tick images under load" signal.
- 03:22 pacing A/B 2 (drive60 + riot60, enab vs mbox): pooled 9 rounds an arm, no-tick frames Enabled 6 vs mailbox 51,
  CPU WASH, p99 mixed. DECISION perf/f19-mailbox-pacing (kept; steady is the one-value fix). Pause-card still of the
  pacing row taken via a scratch `-s` script (deleted): `gtai-masters/n9/perf/pause-card-pacing-row.png`, looked at.
- 03:27 FOUND the mechanism: Godot 4.7.2 smooths the frame delta only under VSYNC_ENABLED (main_timer_sync.cpp
  264-266), so mailbox feeds SimClock raw jittered deltas. L16 built: FrameDeltaSmoother + World._smoothed behind
  `--delta-smooth=on` (default off), tests 6 / 0 (one fails on raw deltas). Commit 36234341.
- 03:35 L16 A/B (drive60 x3, contended): no-tick 7/3/1 -> 2/0/1, double 8/6/2 -> 5/2/4, CPU WASH: direction right,
  inside the noise; not claimed. LEDGER "L16".
- FRICTION: the pre-commit hook ran lint (+ a Godot import) while the A/B ran; the commit sat 2+ min. Commit
  before starting an A/B, not during.
- Scratch worktrees kept for it4: `gtai-n9/tmp/perf/prof3` (main da108c13), `world3` (n9-world 746c2856, main's DLLs).
  Remove with `git worktree remove --force` when done.

NEXT (it4):
1. L16: add a Log.info line when World arms the smoother (prove it is on in the bench), then the A/B again with 6
   pairs on drive60 + riot60 (`--arms=mbox:--vsync=mailbox,smooth:--vsync=mailbox --delta-smooth=on`), plus an
   `enab:--vsync=enabled` arm as the floor. Keep (default on under mailbox) if no-tick frames fall to Enabled's level;
   then the unit no-arg run, `node tools/evidence/run.mjs --no-bench` (look goldens must stay 11 / 11: fixed-fps runs
   never arm it), and the reel x3.
2. If L16 holds: re-check whether "steady" is still needed for pacing (mbox+smooth vs mbox60), update Call P-1 / P-3.
3. Merge-readiness: the full gates on HEAD (unit no-arg, evidence --no-bench, reel x3) after L16 lands.
4. REPORT.md draft (Calls: P-1 mailbox default + the pacing trade, P-3 pacing default, the BC7 numbers), frames.json
   grows with the next clips (a combined clip of the set, 30-90 s).
5. Then the research loop: the combo card cost is structural (LEDGER "World's REQUEST, part 2"); next candidates:
   city_view _process (F6, 2.2 ms mean in the riot), the occlusion pass, the crowd atlas bake time at boot.
- 03:40 L16 proven armed in the bench: a 4 s windowed city_bench with `--vsync=mailbox --delta-smooth=on` logs
  "world: delta smoothing on: 59.94 Hz interval (mailbox)" (so the 03:30 A/B arm was on). Note: the panel reports
  59.94 Hz, so a snapped frame is 16.683 ms vs the 16.667 ms tick: one extra double-tick frame per ~1000 frames is
  the floor (Enabled shows multiTick 1-2 per 30 s too). Unit (smoother, sim_clock, launch_args) 15 / 0.
NEXT it4 item 1 updated: the Log line is in (this commit); go straight to the 6-pair A/B.

## it4 (2026-11-08 03:40-04:40) BUILD
- READ: JOURNAL it3 NEXT, git log, world (it10: no new REQUEST to perf), rivet / handheld (none to perf).
  Registry rules applied: measurement-honesty (a win must clear the measured spread; CONTENDED labels kept),
  perf-regression-gating (the default flips only with the gates green: unit, evidence --no-bench, reel x3).
- 03:43 L16 A/B 2 started: drive60 + riot60, arms enab / mbox / smooth, 4 pairs (3 arms x 2 scenes x 4 = 24 runs),
  `evidence/perf/n9-dsmooth2/`; bench.lock held by handheld (E16b 03:39), ab.mjs waits up to 10 min for it.
- 03:59 L16 A/B 2 done (`evidence/perf/n9-dsmooth2/`, drive60 + riot60, 4 pairs, bench.lock, CONTENDED 2-4 / 4):
  no-tick frames pooled Enabled 4, mailbox 57, smoothing 11 (-81 %); smoothing wins 5 pairs, loses 1, ties 2; CPU and
  p99 WASH. Per-round spread overlaps (ab.mjs: WASH). LEDGER "L16" A/B 2.
- 04:02 FOUND before the flip: World armed the smoother in any windowed mailbox run, incl. `--fixed-fps` (the selftest's
  look goldens): a fixed 16.667 ms delta snapped to 16.683 ms adds a tick every ~1000 frames. Guarded:
  `LaunchArgs.engine_fixed_fps()` -> `FrameDeltaSmoother.realtime_window()`; `wanted()` pure + tested.
- FRICTION (04:03): the debt ratchet failed on a new `OS.get_cmdline_args()` read in world.gd (direct_cmdline_reads
  157 -> 158); moved into LaunchArgs (the allowlisted reader). Lint 15 / 15.
- 04:05 MILESTONE commit 7852a8d4: L16 ON by default under real-time mailbox (`--delta-smooth=off` = the before);
  confirmation A/B (`n9-dsmooth3`, off vs on, drive60 + riot60, 4 pairs) running 04:06.
- 04:16 L16 confirmation A/B 3 (`n9-dsmooth3`, on 7852a8d4, off vs on, 4 pairs, CONTENDED 2-4 / 4): no-tick drive
  off 7/0/0/2 vs on 37/0/2/0 (a 122 ms stall round), riot 1/0/0/1 vs 0/0/0/0. Over 3 A/Bs (19 pairs) smoothing wins
  10, loses 3, ties 6 (sign test p ~0.09): INSIDE THE NOISE. **DROPPED as a default**, back to `--delta-smooth=on`
  (the arm); the fixed-fps guard kept. DECISION perf/mailbox-delta-smoothing rewritten; LEDGER "L16" verdict.
- 04:21 GATE unit no-arg on 34bf44f2: **1831 / 0**.
- 04:23 Riot spans on HEAD (`evidence/perf/n9-spans/`, city_bench riot tilt70, fixed 60, vsync off, windowed d3d12,
  CONTENDED: 6 Godots up, 0 SCRIPT ERROR): per-node _process mean / p99 ms: **city_view.gd 3.41 / 6.48**,
  city_occlusion 1.05 / 3.31, city_blood 0.80 / 2.99, world 0.33 / 2.33, draw blood_fx 0.18. city_view grew from
  F6's 2.2 (d9 morning) to 3.4: the next lever is inside CityView._process (chunks.update, prop_lights.update,
  write_render, lights.step, fx / fx.glow / fx.ground step, overlays, noir.light_street).
- REPORT.md drafted (lane root): items 1-7 with evidence, Calls P-1 / P-3; final at the freeze.

NEXT (it5):
1. Break CityView._process down per call (scratch timers in a throwaway worktree, never committed, the patch kept as
   evidence like `n9-rig-combo/prof.patch`): riot + drive70, find the 1-2 calls that carry the 3.4 ms. Write the
   hypothesis + expected gain in LEDGER, then the smallest cut behind a flag, `ab.mjs --scenes=riot,drive70 --pairs=4`
   under bench.lock (fixed-fps arms: a cost lever, not pacing, so 4 pairs suffice), and the pixel check (top
   bit-identical: `node tools/evidence/run.mjs --no-bench` selftest goldens 11 / 11).
2. Gates on HEAD before the freeze: `node tools/evidence/run.mjs --no-bench` (not run since 40fb2da3 / selftest
   6d365066; since then only World._smoothed (inert by default), the smoother, LaunchArgs.engine_fixed_fps changed)
   and the reel x3 (`--quit-after 16000`) again if any game file changes.
3. Clips: a combined 30-90 s clip of the set (ffmpeg concat of king32 / drive32 + the pacing-row still) for frames.json.
4. The final table (main da108c13 vs n9-perf HEAD) for the LEDGER at the freeze: `ab.mjs --scenes=king,drive70,riot
   --arms=main:^--path <prof3>/project,head:` + an A-vs-A (F12).
5. Scratch worktrees still up: `gtai-n9/tmp/perf/prof3` (main), `world3` (n9-world 746c2856): keep prof3 for item 4,
   remove world3 (`git worktree remove --force`) once world's final BC7 table is not needed.
- 04:33 GATE `node tools/evidence/run.mjs --no-bench` on 10a2348a: lint 15 / 15, unit 1831 / 0, scenarios 54 / 54,
  parity bit-exact (mutation caught at 629), selftest PASS (look goldens 11 / 11; `evidence/perf/n9-gates/
  selftest-it4-10a2348a.json`), release-compile 616 / 0. The branch is green; the reel x3 last ran on 54de9b41 (since
  then only the inert-by-default smoother arm and LaunchArgs.engine_fixed_fps changed: no reel re-run needed unless a
  game file changes in it5).
- it4 ends 04:35. NEXT (it5) as written above; item 2 (the evidence gate) is DONE on 10a2348a.

## it5 (2026-11-08 04:35-05:34) BUILD
- READ: JOURNAL it4 NEXT, git log, world (it13: no REQUEST to perf), rivet / handheld (none to perf).
  Registry rules applied: perf-instrumentation (scratch timers in a throwaway worktree, patch kept as evidence),
  measurement-honesty (CONTENDED labels, a cut must clear the measured spread).
- Plan: item 1 (CityView._process per-call breakdown on riot + drive70), then the smallest cut behind a flag + A/B.
- 04:41 CityView._process per call (scratch timers, worktree `gtai-n9/tmp/perf/cvprof`, patch kept as
  `evidence/perf/n9-l17/cvprof.patch`; riot + drive_dense, fixed 60, CONTENDED): riot total 2.45-3.0 ms =
  before_render 2.1-2.6 (rigs.step_ticks 1.4-1.8: pose 434, street 412, gait 324, assign 132, headcard 113 us;
  _fill_feed 0.5: 262 feed rows a tick at 1.2 us each; crowd.observe 0.13-0.15), fx.ground.step 0.13-0.16, chunks
  0.09. Table in LEDGER "CityView._process per call". The rig step is dense GDScript math (a C++ port is the real
  lever, multi-session); the one pure waste: FxPool.step's ~14 String-keyed Dictionary reads a particle a tick.
- 04:45 MILESTONE L17 committed 4b7c1e44: FxKindRow (the kind's constants cached at put), `test_fx_pool` (MultiMesh
  buffer bit-identical to the verbatim old step, 260 ticks, every real kind) 13 / 0 with test_fx_system, lint 15 / 15.
  Running: the mutation check (`evidence/perf/n9-l17/mutate-fx_pool.txt`) and the timer ABAB (old vs new FxPool in
  cvprof, riot x3 a arm).
- 04:48 L17 timer ABAB (cvprof, riot x3 a arm, interleaved, CONTENDED 0-2 Godots): fx.ground.step old 135 / 152 /
  135 us vs L17 107 / 86 / 97: median -29 %, ranges apart (WIN at the mechanism); fx + glow 44 -> 34 us. Frame total
  inside the noise (not claimed).
- FRICTION (04:50): the mutation run on 4b7c1e44 scored 27 % (3 / 11 killed): velocity and size mutants survived.
  Cause: a headless MultiMesh (the dummy renderer) keeps no data, `mm.buffer` is empty on both sides, the compare was
  vacuous. Fix in 76090884: FxPool.mirror (tests size it; each instance write lands there too), the test compares
  the shown instances through it. Lesson: never compare RenderingServer-backed data in a headless unit test.
- 04:52 MILESTONE L17b committed 76090884: FxPool skips the rewrite of a held particle (zero velocity, grow 0, alpha
  1.0, the same anim cell as `steps` ticks ago; a per-slot `fresh` flag on put / swap-in). test_fx_pool: shown
  instances bit-identical over 260 ticks of every real kind + fewer writes than the every-slot path. Lint 15 / 15.
- 04:58 L17b A/B (cvprof, riot, old / L17 / L17b x3, CONTENDED 0-4): fx.ground.step medians 145 / 101 / 112 us: the
  held skip is worse than L17 alone (the riot's ground pool is mostly moving casings). DROPPED in 9944fd7d (the
  mirror test kept). LEDGER L17 table.
- 05:01 L18 committed 73f30553: CityResidency.resident_keys() sorted once a residency change (it lambda-sorted ~70
  keys on every call: ChunkView every frame, update() every tick, city_system, prop lights, noir lamps / shadows).
  Test in test_city_streaming (row order, same array until a change, rebuilt on evict / drop / adopt). Timer A/B on
  drive_dense running (`cvprof/arms/run_res.sh`).
- Combined clip done: `gtai-masters/n9/perf/perf-set-n9.mp4` (46 s: King 32 combo main vs BC7, drive 32 tilt70 main
  vs BC7, the pause card's pacing row; captions burned in; stills at 10 s and 42 s looked at), frames.json entry 1
  (6 entries).
- 05:06 L18 A/B (cvprof, drive_dense x3, CONTENDED 3-6): chunks.update median 122 -> 114 us (-7 %, ranges apart):
  KEPT as a small cut, no frame claim (the steady cost is the time-sliced chunk build). Full unit run on HEAD started.
- 05:06 GATE unit no-arg on 73f30553: **1833 / 0** (`evidence/perf/n9-l17/unit-it5.txt`). Evidence --no-bench
  started (background, `evidence-it5.txt`).
- 05:07 L19 refuted before building: `feed.looks[i] = v` through another object's property is NOT a copy-on-write
  (microbench: 0.13 us a row for 4 writes at any capacity, the same as in the owner). LEDGER L19.
- 05:08 city_occlusion split (cvprof timers, riot, CONTENDED 6): _process 1085 us a frame = **the per-rig building
  query (`CityOccluders.near` -> `collect`) 883**, crowd + lift 124, rig collect 70 (17 rigs, 12 layer children).
  collect() reads `b.at` off every Bld object of 1-4 chunks (~300 a chunk) for every rig, every frame.
- 05:09 L20 built in the scratch worktree only (the evidence gate runs from this tree): CityOccluders caches each
  chunk's building positions as a PackedVector2Array (list order) and scans that, touching a Bld only on a hit;
  same loop order, same float32 compares. Test written (`collect` == the reach rule over of_chunk, 40 queries over a
  300-building chunk, in order; survives the CACHE_MAX reset). Timer A/B old / new x2 running.

NEXT (it6):
1. If L20 (CityOccluders packed positions) is not committed yet: port `gtai-n9/tmp/perf/occluders_new.gd` into
   `project/features/city/view/city_occluders.gd`, the tests in `gtai-n9/tmp/perf/occ_test_add.gd` appended to
   test_city_occlusion.gd, run `--select=test_city_occlusion`, commit; LEDGER L20 with the cvprof numbers
   (`cvprof/out/ab-l20.txt`).
2. L20b, the bigger cut: `near()`'s 40 m reach box is far looser than what _scan keeps (a building whose drawn area
   meets the body's ~1 x 1.8 m patch). An exact tighter prefilter (the area's x-span and the lift's max `up` bound)
   would skip most of the 300-a-chunk scan per rig: est. near 540 -> <150 us a riot frame. Prove with a test that
   _scan's patches / hits / lifted set are identical over many rig positions, old filter vs new.
3. Gates on HEAD after L20: unit no-arg, `node tools/evidence/run.mjs --no-bench` (log OUTSIDE the tree: a log file
   inside it makes the tree dirty and evidence refuses), the reel x3 (`--quit-after 16000`) since L17 / L18 / L20 touch
   game code (FxPool, CityResidency, CityOccluders; pixel-free by test, but the reel is the combat gate).
4. The final table (main da108c13 vs n9-perf HEAD) at the freeze: `ab.mjs --scenes=king,drive70,riot --arms=main:^--path
   <prof3>/project,head:` + an A-vs-A (F12). The scratch worktree `gtai-n9/tmp/perf/cvprof` (timers; never commit it)
   stays for more splits; remove `world3` when done.
5. Remaining per-frame owners in the riot (LEDGER "CityView._process per call"): the rig step 1.4-1.8 ms (dense
   GDScript, a C++ port is the lever: multi-session, and a REQUEST-level change in shared rig files), the feed 0.5 ms
   (native fill is the lever), city_blood 0.8 ms (not split yet: next split).
- 05:15 GATE evidence --no-bench on 78e039b7 (L17 + L18): ALL PASS: lint 15 / 15, unit 1833 / 0, scenarios 54 / 54,
  parity exact, look goldens 11 / 11 (worst 0.27), release-compile 617 / 0. Mutation fx_pool at 9944fd7d: 90.9 %.
- 05:16 L20 A/B (riot x2): near 705 / 652 -> 542 / 543 us, occlusion _process ~-150 us a frame (ranges apart).
  Ported into the branch (`city_occluders.gd` + 2 tests in test_city_occlusion, 11 / 0). NEXT item 1 is DONE.
- 05:20 L20 behaviour check on the drive (it hides bodies; the riot hides none): with L20 "3432 body-frames hidden,
  crowd 5154 patches" = the two pre-L20 drive runs exactly (`cvprof/out/drive-l20.log`). Evidence --no-bench on HEAD
  28d8c8f7 (with L20) running, log `gtai-n9/tmp/perf/evidence-it5b.txt`.
- 05:26 GATE evidence --no-bench on 28d8c8f7 (+ L20): lint, scenarios 54 / 54, parity exact, look goldens 11 / 11
  (worst 0.27), release-compile 617 / 0 PASS; unit 1835 / 0 passed but the stage is FAIL by the tree-changed guard.
- FRICTION (05:26): I edited JOURNAL.md / REPORT.md while the evidence gate ran; its guard flags ANY tree change
  during the unit stage (docs included). Lesson: write docs in a scratch file during a gate, paste after.
- REPORT.md draft updated (items 8-10: it5's split + L17 / L18 / L20, the clip, the gates).

NEXT (it6), replaces the list above (item 1 DONE: L20 is in 52ff53f0):
1. Re-run `node tools/evidence/run.mjs --no-bench` on HEAD WITHOUT touching the tree (log under gtai-n9/tmp/perf),
   then the director reel x3 (`--quit-after 16000`, top / tilt70 / combo): L17 / L18 / L20 touch game code.
2. L20b: an exact tighter prefilter in CityOccluders.near (the drawn area vs the body patch instead of a 40 m box);
   prove that _scan's patches / hits / lifted set are identical over many rig positions (test), then a cvprof A/B
   (the occlusion timers are in `evidence/perf/n9-l17/cvprof.patch`; the cvprof worktree has them applied).
3. Split city_blood (0.8 ms mean in the riot spans) the same way.
4. The final table at the freeze (main da108c13 via prof3 vs HEAD, `ab.mjs --scenes=king,drive70,riot`, bench.lock)
   + an A-vs-A for the floor (F12).
5. Scratch worktrees: `gtai-n9/tmp/perf/cvprof` (timers, never commit), `prof3` (main) for item 4, `world3` (handheld
   read it; keep until the freeze).

## it6 (2026-11-08 05:28-06:28) BUILD
- 05:28 READ: JOURNAL NEXT, git log, the other journals: world it16 (no REQUEST to perf; its it1 REQUEST answered in
  it3), handheld (none; its E20 holds bench.lock), rivet (none). Registry rules applied: measurement-honesty (every
  A/B is 3 interleaved pairs, CONTENDED labelled, the drive's L20c -4 % called a wash), perf-instrumentation (timers
  only in the cvprof scratch worktree; the arms and logs kept as evidence), motion-quality-gating (the lever is pixel-free
  by an exactness test, not by eye; the reel is the combat gate).
- 05:42 GATE evidence --no-bench on 8990b643 (= L20, the clean re-run owed from it5): ALL PASS: lint 15 / 15, unit
  1835 / 0, scenarios 54 / 54, parity exact (629), look goldens 11 / 11 (worst 0.27), release-compile 617 / 0
  (`evidence/perf/n9-it6/evidence-8990b643.txt`; the log written outside the tree, no doc edits during the run).
- 05:40 L20b A/B (cvprof, 3 pairs riot + drive): the per-rig query median 548 -> 253 us (riot), 543 -> 206 (drive),
  identical hidden / crowd counts. MILESTONE committed 6496dbdb (test: patches per body = the unfiltered scan, 3
  planted faults caught).
- FRICTION (05:45): `tools/godot/check.mjs` fails on city_occluders.gd for both arms ("Identifier not found: Log" in a
  dependency: --check-only has no autoloads); the bench run is the real parse check for view files.
- 05:43 GATE director reel x3 on 6496dbdb (headless, fixed 60, `--quit-after 16000`): 19 / 19 chapters fully down in
  top, tilt70, combo, 0 SCRIPT ERROR (`evidence/perf/n9-it6/reel/`).
- 05:47 L20c A/B (L20b vs L20c, 3 pairs): riot query 246 -> 129 us (-48 %), drive 212 -> 203 (wash). MILESTONE
  committed 700712c7 after the pre-commit hook caught of_chunk at 44 lines and the test file at 212 (the index moved
  to `CityOccluderCols`, the query tests to `test_city_occluders`; 3 planted faults re-caught on the moved code).
- 05:52 LEDGER L20b / L20c (465a52c6).
- 05:56 city_blood split (cvprof timers; `evidence/perf/n9-it6/split/`): riot blood.step 450-496 us a frame
  (BloodFx.step_ticks 347-380: 82 live drops a tick x 2 BloodFx, ~2 us a drop-step through `solid.call` ->
  `CityBlood._solid` -> `sim.cell_at`; _resolve 91-101), CorpseStains.step 140-159: ~0.6 ms = the 0.80 NodeSpans row.
  FRICTION: the first split run had 3668 SCRIPT ERRORs (cvprof's class cache did not know the new CityOccluderCols
  file: run `--import` in a scratch worktree after adding a class file); its blood numbers (37 us) are void.
- 05:58 occlusion counts after L20c: riot 0 candidates / 33 chunk calls a frame (near 120-143 us = per-call
  overhead), drive 139 candidates, 30 kept (near 200 us: the kept path + the hidden bodies' silhouettes).
- 06:02 GATE evidence --no-bench on 6b75d795 (L20b + L20c): ALL PASS: lint 15 / 15, unit 1837 / 0, scenarios 54 / 54,
  parity exact, look goldens 11 / 11, release-compile 618 / 0. Reel x3 on it running (`gtai-n9/tmp/perf/reel6b`).
- LEDGER split + gates (it6), REPORT item 11.

NEXT (it7):
1. Copy the reel x3 from `gtai-n9/tmp/perf/reel6b/` (on 6b75d795 = L20c) into `evidence/perf/n9-it6/reel-l20c/`;
   check 19 / 19 full in each view and 0 SCRIPT ERROR (the awk PARTIAL check in it6), commit.
2. L22 (blood drops): hand BloodFx a direct cell lookup (a typed callable-free path: e.g. a `CitySim` ref +
   `cell_at`, or a cached per-cell solid byte grid for the resident area) instead of `solid.call` -> `_solid`, and skip
   the 320-slot walk when `drops == 0`. Exactness test first: a scripted spray into a wall, the drop / decal sequence
   (positions, sizes, dirs, wall_hits) identical old vs new. BloodFx is `features/fx/noir/` (no lane owns it tonight;
   check the world journal first: the dead redesign may touch blood). A/B with the cvprof timers (riot x3 pairs).
3. Small occlusion levers: near()'s 4-corner keys without the Dictionary / array literal (keep the insertion order
   and the float32 Vector2 math), the silhouette once per rig (drive). < 0.1 ms each: only with a test.
4. The final table at the freeze (main da108c13 via `gtai-n9/tmp/perf/prof3` vs HEAD: `ab.mjs --scenes=king,drive70,riot`,
   bench.lock) + an A-vs-A for the floor (F12); export the exe at 10:30; REPORT final.
5. cvprof scratch worktree: timers for occlusion, blood (city_blood / combat_blood / blood_fx) and the occluder
   counters are applied (never commit it); `arms/` holds every A/B arm.
- 06:07 GATE director reel x3 on 6b75d795 (L20c): 19 / 19 chapters fully down in top, tilt70, combo, 0 SCRIPT ERROR
  (`evidence/perf/n9-it6/reel-l20c/`). NEXT item 1 is DONE. world's branch changes 1 line of boot/city_blood.gd;
  nobody touches features/fx/noir/blood_fx.gd (L22 is free to take).
- 06:09 L22 ceiling probe (riot, no wall checks: measurement only): BloodFx.step_ticks 115 vs 328 us: the wall checks
  are ~65 %. The chain is solid.call -> CityBlood._solid -> CitySimNative.cell_at -> `_call` -> `callv` (an Array a call).
- 06:12 L22 probe A (cvprof, 2 pairs): `cell_at` via `_o.call(&"cell_at", x, y)`: step_ticks 337 / 413 -> 283 / 294 us
  (~-17 %, ranges apart, live drops identical). Not ported yet (a sim-wrapper file: test + full gate first).
  LEDGER "L22 probes". Arm in `cvprof/arms/l22/`, cvprof restored to the branch's city_sim_native.gd.

NEXT (it7) amended, item 2 first:
2a. Port L22 probe A (`evidence/perf/n9-it6/l22/cell_at-call.diff`) into project/features/city/sim/city_sim_native.gd
    with a unit test (native cell_at == the ref's over a stamped chunk, incl. out-of-range points); also look at the
    other `_call(..., [..])` wrappers called per tick (tile_at, etc.) for the same cut. Full gate + reel after.
2b. Then the per-cell solid cache in CityBlood._solid, invalidated on the sim's chunk stamp / clear (exact), with the
    drop / decal sequence test.
- 06:13 MILESTONE L22a committed 1d5a65c1 (CitySimNative.cell_at via Object.call; test_city_sim_native_cells, a planted
  x / y swap caught). 06:15 GATE reel x3 on it: 19 / 19 full, 0 SCRIPT ERROR (`evidence/perf/n9-it6/reel-l22a/`).
  06:22 GATE evidence --no-bench on 1d5a65c1: ALL PASS (lint 15 / 15, unit 1838 / 0, scenarios 54 / 54, parity exact,
  look goldens 11 / 11, release-compile 618 / 0). NEXT item 2a is DONE.

NEXT (it7), replaces the lists above:
1. L22b: a per-cell solid cache in CityBlood._solid (or BloodFx), invalidated on the sim's chunk stamp / clear (check
   what CitySimNative exposes: a map version or the residency's stamped + dropped, as CityOccluders.in_rect uses),
   exact by test (the drop / decal sequence of a scripted spray into a wall, old vs new). Ceiling: ~210 us a riot frame
   minus L22a's ~55. Also look at the other per-tick `_call(..., [..])` wrappers in city_sim_native.gd (26 of them:
   the hot ones per tick, e.g. tile_at, snapshot readers) for L22a's cut.
2. Small occlusion levers (near()'s key Dictionary, the silhouette once per rig): < 0.1 ms, only with a test.
3. Freeze 10:30: the final table (main da108c13 via `gtai-n9/tmp/perf/prof3` vs HEAD, `ab.mjs --scenes=king,drive70,riot`,
   bench.lock) + an A-vs-A for the floor (F12); export `build/export/windows/RTAI.exe`; final gates on the head (reel x3
   + the evidence run with its log OUTSIDE the tree); REPORT final.
4. Scratch: `gtai-n9/tmp/perf/cvprof` (timers for occlusion + blood + counters, never commit; arms in `arms/`),
   `prof3` (main) for item 3, `world3` (keep until the freeze).

## it7 (2026-11-08 06:24-07:2x) BUILD
- 06:25 READ: JOURNAL NEXT, git log, the other journals: no new REQUEST to perf (world's line 129 is it1's, answered in
  it3); world's branch edits boot/city_blood.gd (1 line), city_residency.gd (L18's file: a merge to watch), not
  corpse_stains.gd / city_occluders.gd. Registry rules applied: measurement-honesty (an in-run control timer for every
  A/B: L22b's raw -17 % was machine load, ratio -4 % = a wash), perf-instrumentation (timers only in cvprof), the
  exactness-by-test rule for every kept lever (old algorithm inline in the test, planted faults caught).
- 06:27-06:31 L22b (a per-cell solid memo for the blood wall checks): built + tested, A/B 6 pairs CONTENDED 2-9:
  step_ticks raw medians 322 -> 265, but step_ticks / stains (the unchanged CorpseStains in the same frames) 2.06 ->
  1.97: a wash. DROPPED, not committed (arm in `evidence/perf/n9-it7/l22b/`).
- 06:33 split CorpseStains.step (138 us riot): feed scan 39, _match 10.5, soak loop 84.5 of which _uncovered 69.5
  (14.8 soaks x 263 rows).
- 06:40 MILESTONE L23 kept 4bc6d82c: StainCover.cover (walkers sorted by x, a bsearch window): CorpseStains.step
  141 / 133 / 144 / 135 -> 103 / 102 / 106 / 107 us (4 pairs, ranges apart, control flat). Mutation 9 killed / 5
  survived, the 5 equivalent. Reel x3 on it: 19 / 19, 0 SCRIPT ERROR.
- FRICTION (06:35): Windows python's text mode wrote CRLF into a .gd file (git warned); write with newline='' or
  strip CR after an edit. gdformat on Windows also writes CRLF: strip after it.
- 06:48 MILESTONE L24 kept 509580ac: CityOccluders.near without the key Dictionary: riot near 139 / 132 / 156 ->
  97 / 101 / 102 us (3 pairs, ranges apart, also normalised), drive -10 % normalised; hidden / patches identical.
- 06:55 GATE reel x3 on 6fed0aad (L23 + L24): 19 / 19 chapters fully down in top, tilt70, combo, 0 SCRIPT ERROR
  (`evidence/perf/n9-it7/reel-l24/`).

NEXT (it8):
1. L25 (armed, not measured): CorpseStains.step hoists feed.flags / pos / ids into locals (the feed scan is 39 us a
   riot frame, ~3 member lookups a row x 263 rows). Arms `gtai-n9/tmp/perf/cvprof/arms/cs/l23.gd` vs `l25.gd`; run
   `ROUNDS="1 2 3" ARMS="l23 l25" ./arms/run_cs.sh` under bench.lock (cvprof's city_blood prints BLOODPROF stains;
   blood.step is the in-run control). Keep only if ranges apart vs the control; port + a test that the dead map and
   walkers equal the old loop's.
2. The same hoist audit over the other per-row riot loops in files no lane edits tonight (CrowdReact._observe is
   already hoisted; check FxPool.step, CityOcclusion's per-rig loop, StreetView: world edits street_walker_cards).
3. Freeze 10:30: the final table (main da108c13 via `gtai-n9/tmp/perf/prof3` vs HEAD, `ab.mjs --scenes=king,drive70,riot`,
   bench.lock) + an A-vs-A for the floor (F12); export `build/export/windows/RTAI.exe`; final gates on the head (reel x3
   + the evidence run, log OUTSIDE the tree, no tree edits during it); REPORT final (item 12 is in).
4. Scratch: cvprof (timers: occlusion, blood, CorpseStains CSP via arms/cs/t0.gd; never commit), prof3, world3.
- 06:58 GATE evidence --no-bench on 6fed0aad (L23 + L24): ALL PASS: lint 15 / 15, unit 1842 / 0, scenarios 54 / 54,
  parity exact (629), look goldens 11 / 11 (worst 0.27), release-compile 619 / 0 (`evidence/perf/n9-it7/evidence-6fed0aad.txt`).
- 07:00 L25 A/B (3 pairs on L23): CorpseStains.step 101.5 / 111.8 / 100.0 -> 86.9 / 91.8 / 86.1 us, ranges apart.
  MILESTONE committed 6ce43cd0 after the debt ratchet caught the file at 247 lines (cap 245: `ids` stays a member read
  on the dead rows only, the _by_x doc folded into a trailing comment). NEXT item 1 below is DONE.
- 07:13 GATE on 6ce43cd0 (L25): evidence --no-bench ALL PASS (lint 15 / 15, unit 1843 / 0, scenarios 54 / 54, parity
  exact, look goldens 11 / 11, release-compile 619 / 0); the reel x3 19 / 19, 0 SCRIPT ERROR.

NEXT (it8), replaces it7's list (item 1 there is DONE as L25):
1. The hoist audit over other per-row riot loops in files no lane edits tonight (FxPool.step, CityOcclusion's per-rig
   loop, CrowdReact is already hoisted; world edits city_characters.gd and the street_* files: not those). Each: a
   cvprof arm, 3 pairs with an in-run control timer, a test, keep only if ranges apart.
2. Freeze 10:30: the final table (main da108c13 via `gtai-n9/tmp/perf/prof3` vs HEAD, `ab.mjs --scenes=king,drive70,riot`,
   bench.lock) + an A-vs-A for the floor (F12); export `build/export/windows/RTAI.exe`; final gates on the head (reel x3
   + the evidence run, log OUTSIDE the tree, no tree edits during it); REPORT final.
3. Scratch: cvprof (timers: occlusion, blood, CorpseStains via arms/cs/t0.gd; never commit; run `--import` there after
   adding / removing a class file), prof3, world3.

## it8 (2026-11-08 07:15-08:1x) BUILD
- 07:16 READ: JOURNAL NEXT, git log, the other journals. No REQUEST to perf. handheld's 06:41 NOTE to perf (FYI): a 40
  fps cap steps the 60 Hz sim 1, 2, 1, 2 ticks a frame; ANSWER: the pacing row never pairs with a cap (efficient =
  no limiter at 60 Hz, steady = the limiter at the refresh rate on top of vsync), so it stays even; agreed: any
  future cap is 30 or 60. handheld's FRICTION "ab.mjs ignores --out" is `tools/handheld/ab.mjs` (its own tool,
  hard-coded `evidence/sim/<name>`), not `tools/perf/ab.mjs` (which honours `--out`): nothing for perf to fix.
  main moved past da108c13 (90356ced) with tooling only: `git diff da108c13 main -- project native` is empty, so
  prof3 (da108c13) is still the main baseline for the final table.
  Registry rules applied: measurement-honesty (the in-run control ratio decides, not raw medians), perf-instrumentation
  (scratch timers stay in cvprof), perf-regression-gating (interleaved arms, the bench lock for kept numbers).
- 07:16-07:20 L26 (FxPool.step through locals): A/B 3 pairs, ground.step / blood.step ratio 0.221 -> 0.225: a WASH.
  DROPPED, not committed (arm + numbers `evidence/perf/n9-it8/l26/`, LEDGER L26). The hoist audit's other target,
  CityOcclusion._scan, is already tight after L20-L24 (one near() a rig, no per-row member reads to hoist): skipped.
  Kept: test_fx_pool steps 0 / 1 / 2 ticks (a no-tick frame was not covered).
- 07:20 Final table started early on 49afd875 (main da108c13 via prof3 vs head, `ab.mjs --scenes=king,drive70,riot
  --pairs=3`, bench.lock via ab.mjs) -> `evidence/perf/n9-final-it8/`, so the freeze does not hang on it.
- FRICTION (07:21): ab.mjs's `head:` arm runs the working tree, and I copied the L27 arm into the branch while the
  final table ran: head r1 (king, drive70, riot) carried L27. Restored at ~07:22; the table is labelled provisional
  (`evidence/perf/n9-final-it8/`) and is re-run clean on the final HEAD. Rule: no tree edits under project/ while an
  ab.mjs `head:` arm runs. (The runs are ~20 s each at fixed 60 uncapped: a 3-pair table is ~7 min.)
- 07:28 L27 (CityFxFeed.observe, `_dead` through a local): 4 pairs, FF.observe 117-120 in both arms: a WASH, DROPPED
  (LEDGER L27: own-member reads are already cheap; L25 won on another object's members).
- 07:31 test_fx_pool steps 0 / 1 / 2: a planted "a no-tick frame still moves" fault (`maxi(steps, 1)`) is caught at
  tick 0 (the old 1 / 2 cadence could not see it).
- 07:28-07:34 Final table PROVISIONAL on 1365b7f3 (main / head / head2 byte copy, 3 pairs, 25 / 27 CONTENDED 1-8):
  every row WASH by the A-vs-A floor (head vs head2 0.35-1.4 ms at p50 > the ~0.7 ms of kept CPU cuts); drive70 p50
  head under main in 3 / 3 rounds. LEDGER "Final table n9", REPORT item 13. head2 copy at `gtai-n9/tmp/perf/head2`
  (delete after the freeze table).
- 07:43 GATE evidence --no-bench on efa848cb: ALL PASS (lint 15 / 15, unit 1843 / 0 with FLAKY 1 =
  test_test_tmp's prune test (shared user:// scratch, load 3; not perf code), scenarios 54 / 54, parity exact (629),
  look goldens 11 / 11 (worst 0.27), release-compile 619 / 0; `evidence/perf/n9-it8/evidence-efa848cb.txt`). No game
  code changed since 6ce43cd0 (the reel x3 passed there), so no reel re-run is owed for it8.
- 07:37-07:44 the release exports for the freeze table: `build/export/windows-bench-main/` (prof3 = main da108c13,
  pck 217.77 MB), `build/export/windows-bench/` (efa848cb, pck 217.78 MB), `windows-bench-head2/` (byte copy).
  07:45 the exe table started: `ab.mjs --scenes=riot,drive70,riot60 --pairs=3 --arms=main@exe-windows-bench-main:,
  head@exe:,head2@exe-windows-bench-head2:` -> `evidence/perf/n9-final-exe-efa848cb/`.
- 07:53 the exe table (LEDGER "Final table n9, the release build"): WASH everywhere (23 / 27 CONTENDED, up to 10
  Godots; head vs head2 0.15-1.6 ms p50). Watch (not claimed): steady RAM main bimodal 750 / 820 MB (5 / 9 at ~820),
  head + head2 751-756 in 18 / 18; riot60 CPU 0.38 -> 0.32 cores (head under main's median 3 / 3, ranges overlap).

NEXT (it9), replaces it8's list:
1. A quiet re-run of the exe table with `--pairs=5` (`ab.mjs --scenes=riot,drive70,riot60 --arms=main@exe-windows-bench-main:,
   head@exe:,head2@exe-windows-bench-head2:`), only if `tasklist | grep -ci godot` is low; the exports are built
   (re-export head + re-copy head2 if HEAD's project/ changes). Question it answers: is the steady-RAM split real?
   If yes, find which commit (F-19 mailbox, L18 residency cache, L20 occluder caches) by a 2-arm bisect.
2. Levers left in perf-owned files are below the floor (L26 / L27 washes). The riot's frame is the rigs
   (BR.step_ticks ~1.4 ms: gait 335, pose 446, street 417, headcard 119, assign 135 us; cvprof RIGPROF), in world's /
   rivet's files: re-send the numbers as a REQUEST only if a lane asks; do not edit them.
   One perf-owned candidate: a native `CitySimNative` helper for CityFxFeed.observe's record scan (~120 us a riot
   tick) - native/ is shared with world tonight (knock, walls): only after world's native work merges. Otherwise
   spend it9 / it10 on the owner clips (King + drive with the perf HUD, before / after) if frames.json is short.
3. Freeze 10:30: export `build/export/windows/RTAI.exe` (`"$GODOT_BIN" --headless --path project --export-release
   windows-showcase ../build/export/windows/RTAI.exe`), name it in REPORT with the command; final gates on HEAD if
   project/ changed after efa848cb (reel x3 + evidence run, log outside the tree, NO tree edits under project/ while
   an ab `head:` arm or the gate runs); REPORT final.
4. Scratch: cvprof (arms fx/, ff/ added), prof3, world3, head2 (`gtai-n9/tmp/perf/head2`, the editor-arm copy:
   delete after the freeze), build/export/windows-bench-main + -head2 (git-ignored).
- 07:56-08:01 MILESTONE the release riot, quieter (0-2 Godots), 4 pairs: riot p50 main 3.62-4.67 vs head 3.17-3.53,
  head2 3.35-3.59 (8 of 8 head rounds under every main round, head vs head2 0.14): **riot p50 4.29 -> 3.38 ms**, the
  first frame-level win of tonight's CPU cuts (p99 overlaps: not claimed). The steady-RAM split looked refuted on
  the riot (main 751-754 MB quiet) - CORRECTED at 08:01 below. LEDGER "the release riot at a quieter moment", REPORT item 13. NEXT item 1's RAM question is answered;
  item 1 becomes: the same quiet riot run with `--pairs=5` on the final HEAD at the freeze (confirm), plus drive70.
- 08:00 drive70 quiet exe, 4 pairs: p50 WASH (main 2.11-2.52, head 1.78-2.12, head2 1.88-2.45); main's steady RAM
  817 MB in r0. Correction: the RAM split is NOT refuted: main ~817-821 MB in 6 of 17 exe runs tonight, head + head2
  0 of 34. Open watch item (LEDGER, REPORT corrected).

NEXT (it9), replaces the list above:
1. The RAM mode: is main's ~820 MB steady state (6 / 17 exe runs; head 0 / 34) real, and which commit removes it?
   drive70 + riot, `--pairs=8`, main@exe vs head@exe, quiet machine; if it holds, bisect with exports of 2-3
   intermediate commits (F-19 mailbox 06c48c1b, L18 73f30553, L20 52ff53f0) as `@exe-<dir>` arms.
2. At the freeze: the quiet release riot again on the final HEAD (`--pairs=5`) to confirm 4.29 -> 3.38 ms.
3. Freeze 10:30: `build/export/windows/RTAI.exe` (windows-showcase), final gates if project/ changed after efa848cb,
   REPORT final. No tree edits under project/ while an ab `head:` arm or the gate runs.
4. Levers: perf-owned files are below the floor now (L26 / L27); the riot's frame is the rigs (other lanes' files).
5. Scratch: cvprof, prof3, world3, head2 (delete after the freeze), build/export/windows-bench-main + -head2.

## it9 (2026-11-08 08:03-09:0x) BUILD
- 08:03 READ: JOURNAL NEXT, git log, the other journals: no REQUEST to perf. handheld 07:48: "tick 5800 is the
  Toner Room dialogue, not Dock 9 (perf's preset comment is stale)". ANSWER: fixed (c18385e4: quest1_frames.gd,
  ab.mjs, a correction line under the LEDGER's quest 1 row). Registry rules applied: measurement-honesty (the
  bimodal RAM question gets 8 pairs before any claim), runtime-observation-evidence (close-ups looked at before they
  enter frames.json), perf-regression-gating (bench.lock via ab.mjs for every kept number).
- 08:06 the RAM-mode run: `ab.mjs --scenes=drive70,riot --pairs=8 --arms=main@exe-windows-bench-main:,head@exe:`
  -> `evidence/perf/n9-it9/ram-mode/` (6 Godots up: CONTENDED labels per run).
- 08:07 trial merge for the shipping table: scratch world3 = n9-world b888fe20 + n9-perf c18385e4 (scratch commit
  6e36e936, never pushed): only JOURNAL.md / REPORT.md conflict (lane docs); project.godot, city_residency.gd and
  docs/decisions.md auto-merge; lint 15 / 15 on the merge. NOTE for the Director: n9-perf merges onto world's head
  without code conflicts.
