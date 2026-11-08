# n9 perf REPORT (branch `n9-perf`, cut from main da108c13; DRAFT it10, final at the freeze)

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
   - it10, the control arms on main (vsync Enabled, a real Start press, 20 runs each): the editor binary **5 / 20**
     frozen, the release export **0 / 20**, a debug export **0 / 20** (Fisher p = 0.003, exported vs editor). The
     real Start click freezes too, but only in the editor binary: the shipped build was most likely never hit (0 / 40
     bounds its rate under ~7 % a run). All five new stacks wait on the same never-signalled GPU fence, reached from a
     synchronous readback after Start (LEDGER "F19 it10").
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
   tick, ~2 us each through a Callable into the sim) and the corpse stains (0.15 ms). L22a (cell_at without an
   Array a call) cut the drops' step 337 / 413 -> 283 / 294 us; the per-cell cache is next. Gates on 1d5a65c1:
   ALL PASS (unit 1838 / 0), the reel 19 / 19 in top, tilt70, combo.
   Gates on 6b75d795: ALL PASS (unit 1837 / 0, scenarios 54 / 54, parity exact, look goldens 11 / 11,
   release-compile 618 / 0); the reel 19 / 19 in top, tilt70, combo on L20b.

12. **The research loop, it7: two more exact cuts, one honest wash.** L23: the corpse soaks measure only the
   walkers within reach in x (sorted once a step, a binary search per soak): CorpseStains.step 138 -> 104 us a riot
   frame (-25 %, 4 pairs, ranges apart). L24: the occlusion query finds its 1-2 chunks without building a Dictionary
   a call: 139 -> 101 us a riot frame (-27 %), the drive -10 %. Both are proven exact by tests that run the old
   code inline and catch planted faults; hidden bodies and crowd patches are identical. L22b (a per-cell cache for
   the blood's wall checks) looked like -17 % in raw medians but only -4 % against an unchanged timer in the same
   frames, so it was dropped: the shared machine moved, not the code.
   L25 (the corpse soaks read the rig feed through locals) took CorpseStains.step on to ~87 us (138 at the start of it7).
   Gates on 6ce43cd0 (with L25): ALL PASS (unit 1843 / 0); the reel 19 / 19 in top, tilt70, combo.
   Gates on 6fed0aad: ALL PASS (unit 1842 / 0, scenarios 54 / 54, parity exact, look goldens 11 / 11,
   release-compile 619 / 0); the reel 19 / 19 in top, tilt70, combo, 0 SCRIPT ERROR.

13. **The research loop, it8: two honest washes and a stronger test.** L26 (the FX particles moved through locals)
   and L27 (the feed's dead flags through a local) both measured inside the noise against an unchanged timer in
   the same frames, so neither was kept. Together with L25 they show where GDScript's cost actually is here: reading
   another object's arrays costs a lot, and reading the script's own arrays is already cheap. The remaining feed
   cost is the snapshot reads themselves, and the next step there is native code. `test_fx_pool` now also covers a
   frame with no sim tick (a planted fault is caught).
   A provisional final table (main vs this branch vs a byte copy of it, 3 pairs, 25 of 27 runs CONTENDED) shows the
   honest limit: the same code in two folders differed by 0.35-1.4 ms at p50, more than the ~0.7 ms of CPU cuts
   kept tonight, so no frame-level win is claimed from them (LEDGER "Final table n9"). The drive's p50 was under
   main's in every round (2.2-2.7 vs 2.7-3.8 ms). The same table on the release exports (23 of 27 runs CONTENDED)
   reads WASH everywhere. A quieter re-run of the riot on the release build (4 pairs) is clearer: **riot p50
   4.29 -> 3.38 ms**. Both copies of this branch ran under every main round (3.17-3.59 vs 3.62-4.67 ms), and the
   two copies differed by only 0.14 ms. That matches the ~0.7 ms the CPU cuts measured inside the frame. The
   riot's p99 still overlaps (not claimed). The drive is a WASH (ranges overlap). Open, not claimed: main's
   process settled at ~820 MB in 6 of 17 release runs, this branch at ~755 MB in all 34 (LEDGER "the release
   riot at a quieter moment").
14. **it9: the release build measured over 8 interleaved pairs: this branch is faster in every pair.** On the
   shipped `windows-bench` exports (main da108c13 vs this branch, 32 runs, 0 errors), this branch's p50 was under
   main's in **8 of 8 rounds on the drive and 8 of 8 on the riot**, in both arm orders. Median paired gap: **riot
   -0.75 ms (-18 %), drive -0.34 ms (-15 %)**. With it8's quiet rounds that makes 12 of 12 on each scene. Most of the
   rounds ran next to other lanes' Godots (CONTENDED), so the absolute numbers drift from round to round, and the
   claim rests on the pairing, not on separated ranges. p99 is not claimed. Draw counts are identical
   (no pixel moved). The RAM question is answered: the ~815 MB state appears on both builds (main 8 of 33 runs
   tonight, this branch 1 of 50), so it is a per-run state that this branch hits less often, not a saving to claim
   (LEDGER "the release build, 8 pairs").
15. **it9: what ships, measured.** A scratch trial merge of world's head with this branch merges with no code
   conflict (only the lane docs) and passes lint. As a release build against main: **VRAM 884 -> 528 MB on the
   drive and 899 -> 549 MB on the riot (-40 %)**, frame times WASH (the merge under main in 3 of 4 rounds on each),
   0 errors. **The pck with BC7: the install grows and the download shrinks.** On disk 218 -> 412 MB, because BC7
   blocks are stored raw while lossless textures are WebP. Compressed in 1 MB chunks, the way a store's depot
   does it, it is 213 -> 155 MB (LZMA) or 216 -> 168 MB (zlib): **about 45-60 MB less to download, about 194 MB more
   on disk, about 350 MB less on the GPU** (LEDGER "What ships", `tools/perf/pck_download.py`).
16. **it10: the F-19 control arms and the quest 1 row.** On main's old code a real Start press freezes the editor
    binary (5 / 20) but neither exported build (release 0 / 20, debug 0 / 20): item 1 and Call P-1. Quest 1 (editor
    binary, 3 pairs, main / head / a byte copy): WASH on every metric (p50 3.43 / 3.32 / 3.56 ms; the head-vs-copy
    floor is larger than head vs main). LEDGER "Final table n9, quest 1 and the director reel".

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
  back to 1 (Enabled), which brings the freeze back. **New (it10):** on the old code the freeze hit the editor binary
  (5 / 20) and neither exported build (0 / 40). So a middle option exists: mailbox only in editor runs
  (`vsync_mode.editor=3` instead of `.windows=3`: checked in the editor binary, whose window then boots in mailbox; the
  export side rests on the docs (templates carry no `editor` tag), a probe in the export did not run) and
  Enabled for players, who then keep every tick image. Built default: mailbox for everyone (a fatal hang that 40 runs
  cannot exclude outweighs a rare skipped image).
- **P-3 Pacing default (built: efficient).** "steady" by default on Windows removes the skipped tick images for +0.08
  core. The alternative is one value away: the `pacing` default in `PlayerSettings`.

## Next steps
- The riot's frame is now mostly the rigs (gait, pose, street walkers, head cards: ~1.4 ms a riot tick), in the
  rivet and world lanes' files: the per-system numbers are in the LEDGER for whoever takes them.
- The feed's snapshot scan (~120 us a riot tick) is the last perf-owned GDScript cost worth moving, and it needs
  native code: after world's native work (knock, walls) is merged.
- A stripped export template is worth retrying only with the official toolchain (MinGW-GCC + LTO); the MSVC build
  cost ~10 % frame time (L7).
- See JOURNAL.md NEXT for the session-level list.
