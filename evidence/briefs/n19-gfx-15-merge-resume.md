# Brief n19-gfx-15: resume the anim x gfx merge rehearsal past the debt baseline

Follow-up to brief 13 (same thread). You stopped correctly: my brief said "any other conflict, stop", and the sixth conflict was `tools/debt/baseline.json`. That file has a repo resolver, so it is not a stop.

Redo step 1 from a fresh temp worktree and branch (same names; you removed the old ones): merge `n19-anim`, then `n19-gfx` (it is now at a newer docs-only tip, fine). Resolve:
- `tools/debt/baseline.json`: run `node tools/debt/merge_baseline.mjs` inside the conflicted merge (it writes the looser side per metric and file and stages it; `tools/debt/README.md` line 51). Then `node tools/debt/debt.mjs --check` on the merged tree; quote its line. If it names a file worse than both sides, record it in the report (do not accept a regression).
- The five look goldens: take either side for now (step 4 re-renders them).
- Anything else still stops you: report file + both sides' commits.

Then continue brief 13 from step 1's native build through step 6 (cleanup) exactly as written in `evidence/briefs/n19-gfx-13-anim-merge-rehearsal.md`. Same environment rules (`export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx`, one Godot process, d3d12, `--position 0,1440`, own PIDs only, never push, no commit on any lane branch). HARD STOP: report written by 06:55 local even if steps are left; order of value if short of time: step 2 (crowd-switch heights sheet) > step 5 gate lines > step 4 goldens table > step 3 noir patch. Cleanup (step 6) always runs.

Append to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge-13-REPORT.md` under a new heading `## Resume (brief 15)`.
