# n9 perf REPORT (branch `n9-perf`, cut from main da108c13; DRAFT it6, final at the freeze)

Numbers, methods and every A/B: `docs/perf/LEDGER.md` section "n9 night". Clips and stills:
`C:\Users\kazda\kiro\gtai-masters\n9\perf\` (`frames.json`).

## What works, with its evidence

1. **The quest 1 freeze (F-19) is found and fixed.**
   - Located with native stacks of 4 frozen runs (cdb, all the same): `RenderingServerDefault::_draw ->
     RenderingDevice::_begin_frame -> D3D12 fence_wait (WaitForSingleObjectEx INFINITE)`. The GPU never finishes a
     frame that queued behind a vsync `Present(1, 0)`. It is an engine/driver hang, not our GDScript. None of the
     suspects (`chunk_source.take`, `save_worker`, threaded texture loads) was open (trace rounds, LEDGER "F19").
   - Vsync off: 0 / 16. Vsync Enabled: 19 / 47 frozen. **Mailbox: 0 parked-fence freezes in 107 valid runs**
     (mb40b 0 / 40 windowed `--autostart`, rel20 0 / 20 in the release export with a real Start press).
   - Fix: `display/window/vsync/vsync_mode.windows=3` (mailbox, Windows only, no tearing). Commit 06c48c1b.
     `test_frame_cap.test_windows_boots_in_mailbox_vsync` fails on the old tree.
2. **The frame-pacing option** (efficient / steady) is in the pause card's settings and saved with them. The desktop
   default is efficient. Commit d6e93b92. Still: `gtai-masters/n9/perf/pause-card-pacing-row.png`.
3. **The traffic-sheet split is not needed under BC7.** world's BC7 import of the p70 sheet is 18 MB (a 32 MB staging
   buffer, was 128 MB). The splitter (`tools/art/split_sheet.py`, bands stack back byte-identical) stays for a
   lossless build. DECISION perf/traffic-split-under-bc7.
4. **The BC7 table on world's branch** (desktop, bench.lock): VRAM drive70 900 -> 548 MB, riot 899 -> 536 MB;
   drive70 p99 -8 %; the other frame times WASH. Clips `king32-main-vs-bc7.mp4`, `drive32-main-vs-bc7.mp4`.
5. **world's REQUEST (the combo rig cost):** profiled per card kind. It is spread over many small GDScript calls,
   not one hotspot. The one cut measured (StreetWalkerCards.place, -20 us/tick) is a wash; the patch is offered.
6. **The crowd bake's readback** stays synchronous by default (the async arm moved the look goldens: 5 / 11 -> 11 / 11
   with sync). DECISION perf/crowd-readback-sync-default.
7. Gates on 54de9b41: unit 1823 / 0, scenarios 54 / 54, parity bit-exact, release-compile 615 / 0, look goldens
   11 / 11, block goldens 5 / 5, the director reel 19 / 19 with 0 SCRIPT ERROR in top, tilt70 and combo.
8. **The research loop, it5: where the riot's frame goes, and three pixel-free CPU cuts.** I split
   CityView._process call by call with scratch timers (LEDGER "CityView._process per call"). The rig pose step is
   ~60 % of it (dense GDScript math, no waste to strip), the feed is 262 rows a tick at 1.2 us each, and the
   occlusion pass spent 883 us of its 1.05 ms on a per-rig building query. Kept, each bit-identical by test, each A/B'd
   with interleaved arms (every new round under every old round):
   - L17 FxPool reads a cached per-kind row instead of ~14 String-keyed Dictionary reads a particle a tick: the
     riot's ground marks 140 -> 99 us a frame (-29 %).
   - L18 CityResidency sorts its resident keys once a change, not on every call: chunks.update 122 -> 114 us (-7 %).
   - L20 CityOccluders scans packed building positions: the occluder query 705 / 652 -> 542 / 543 us, about
     -150 us a riot frame; the drive hides the same 3432 body-frames.
   Together about -0.2 ms of main-thread CPU in a riot frame. That is below the frame-to-frame noise on this shared
   machine, so no frame-time win is claimed. Dropped with numbers: L17b (skip held particles: slower than L17).
   Refuted before building: L19 (no copy-on-write in packed-array writes through another object).
9. **A combined clip of the set:** `gtai-masters/n9/perf/perf-set-n9.mp4` (46 s, the King and the drive with the
   perf HUD, main vs BC7, then the pacing row).
10. Gates on 78e039b7 (L17 + L18): all PASS: unit 1833 / 0, scenarios 54 / 54, parity bit-exact, look goldens
   11 / 11, release-compile 617 / 0. The fx_pool mutation score is 90.9 %. On 28d8c8f7 (+ L20): every stage passed on
   content (unit 1835 / 0, scenarios 54 / 54, parity exact, look goldens 11 / 11, release-compile 617 / 0), but the run
   is marked FAIL because I edited JOURNAL / REPORT while it ran (the tree-changed guard). It must be re-run untouched.

11. **The research loop, it6: the occlusion query cut to a fifth.** L20b keeps only the buildings whose ground rect
   can meet the body box (exact: any other building's drawn area misses the box at every lift); L20c indexes each
   chunk's buildings by screen column so a body reads one or two columns. The riot's per-rig query went
   ~650 (L20's before) -> 253 (L20b) -> 129 us a frame (L20c); the drive 543 -> 206 us (L20b; L20c a wash there).
   The occlusion pass as a whole: ~800 -> ~280 us a riot frame. Hidden bodies and crowd patches identical in every
   run; tests compare the filtered query to the plain scan per body, in order, at 70 and 55 (6 planted faults
   caught). I split city_blood too: ~0.6 ms a riot frame, mostly the blood drops' wall checks (82 live drops a
   tick, ~2 us each through a Callable into the sim) and the corpse stains (0.15 ms): the next lever (L22).
   Gates on 6b75d795: ALL PASS (unit 1837 / 0, scenarios 54 / 54, parity exact, look goldens 11 / 11,
   release-compile 618 / 0); the reel 19 / 19 in top, tilt70, combo on L20b.

## What does not
- The first L17 test was vacuous. It compared `MultiMesh.buffer`, which a headless run keeps empty. The mutation run
  caught it (27 %); the test now compares through `FxPool.mirror` (90.9 %).
- Mailbox drops a tick image on a loaded machine: no-tick frames pooled over 9 rounds, Enabled 6 vs mailbox 51,
  at the same CPU. Steady fixes it for +0.08 core. L16 (the engine's own delta smoothing, re-applied under
  mailbox) is built behind `--delta-smooth=on`. Over three A/Bs (19 pairs) it had fewer no-tick frames in 10 pairs,
  more in 3 and tied in 6. That is inside this machine's noise, so it stays off (DECISION perf/mailbox-delta-smoothing).
- The frozen-fence root cause inside the driver/engine is a hypothesis from the source + the counts (a queued present
  never retired), not a driver-level proof.

## What blocked, and for how long
- No debugger on the machine at the start (it1, ~10 min to install WinDbg/cdb).
- The bench lock is shared; several A/Bs waited 1-10 min, and most numbers are labelled CONTENDED.

## Calls for the owner
- **P-1 Mailbox as the Windows default (built).** It ends the quest 1 freeze (0 / 107 vs ~2 in 5). The cost: an
  occasional skipped tick image under load. The alternative is one value away: `display/window/vsync/vsync_mode.windows`
  back to 1 (Enabled), which brings the freeze back.
- **P-3 Pacing default (built: efficient).** "steady" by default on Windows removes the skipped tick images for +0.08
  core. The alternative is one value away: the `pacing` default in `PlayerSettings`.

## Next steps
- See JOURNAL.md NEXT.
