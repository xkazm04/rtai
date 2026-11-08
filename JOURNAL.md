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
