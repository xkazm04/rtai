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
