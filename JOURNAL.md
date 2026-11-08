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
