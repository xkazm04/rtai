# n30-23 molotov 3-way clip at HEAD (stop-gap | n30 | plasma rifle, 32 px/m)

Lane keys, run n30. Worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n30-keys`. Launched ~15:55.
**Commit by 16:25. Report and END by 16:35** (wall clock; check `date` often).

## Goal
`C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/molotov_32.mp4` (n30-05, brief `evidence/briefs/n30-05-molotov-film.md`,
method in `evidence/n30-keys/films.md` lines 1-16) is the brief's "clip beside the stop-gap at 32 px/m". It was filmed before
`0e399a732` (row 1 cols 5, 6 of `project/features/characters/art/view/p70/rivet_run8_eq_molotov.png` moved 1 px: the run-step fix).
Re-film only the middle (n30) tile and the 64 px/m tile at HEAD, re-compose as NEW files. No product file changes.

## Reuse (do not rewrite)
- Scripts `evidence/n30-keys/films/capture_film.py` and `compose.py` (read both first: args, output dirs, job name).
- The stop-gap side `molotov/grid_molotov_arena/basef_32` and the donor `molotov/grid_plasma_rifle_arena/n30f_32` are still valid
  (neither sheet changed since): reuse them as they are, do not re-capture them.
- Capture the HEAD side from THIS worktree (no temp worktree needed: HEAD is the "after"), to NEW dirs
  `molotov/grid_molotov_head_arena/n30f_32` and `n30f_64` (n30-22 already made `grid_molotov_head_arena/{rows,candidate_32,candidate_64}`:
  do not touch those). If `capture_film.py` hard-codes its output dir or a source path that no longer exists, copy it to
  `build/n30-23/` and change only the paths (n30-22 found `capture28.py`'s n24 source dir gone and read the archived
  `rows_source` / `candidate_source` instead: see `build/n30-22/capture28_head.py`). The old capture dirs stay untouched.
- The import cache is current at HEAD (no art changed since 0e399a732).

## Deliverables
1. Clip `molotov/molotov_head_32.mp4`, same layout as `molotov_32.mp4` (three 640x540 1:1 crops stop-gap | n30 | plasma rifle,
   frames 70-990, over the n30 64 px/m tile), 1920x1080, 60 fps, 15-40 s: quote
   `ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate,nb_frames -show_entries format=duration`.
2. Proof with numpy/PIL or ffmpeg: per frame of the middle tile, old n30f_32 capture vs new; count frames that differ and the max
   changed px. Expect differences only while Rivet runs the front facing (row 1) on cells 5, 6; the walk part and other facings
   identical. If they differ everywhere (render noise, different timing), say so and find why before composing.
3. Look at the new clip yourself at 3 s (walk) and 12 s (sprint) and one frame where the middle tile differs from the old one;
   say what you see (bottle in claw, flame, soles, tiles aligned, labels readable).
4. Append `## Molotov clip at HEAD (n30-23)` to `evidence/n30-keys/films.md`: commands, ffprobe line, the diff count, what you saw.
5. `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json`: if it holds an entry for `molotov/molotov_32.mp4`, point it at
   `molotov/molotov_head_32.mp4` with an updated note; otherwise leave frames.json alone (do not exceed 15 entries; keep valid JSON).
6. Commit only the md: `git add evidence/n30-keys/films.md` then
   `git commit -m "evidence(keys n30): molotov 3-way clip at HEAD after the run-step fix" -- evidence/n30-keys/films.md`
   with the trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Godot rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` before every Godot run.
- Only through `runGodot` (the capture script uses it). Windowed runs at `--position 0,1440` (secondary monitor), `--rendering-driver d3d12`.
- Lane lock: before each Godot batch create `build/n30-godot.lock` exclusively
  (`set -o noclobber; echo "n30-23 $$ $(date +%H:%M)" > build/n30-godot.lock`), delete it right after. If it exists and is not
  yours, wait (poll 30 s); never delete another's lock. You are the only builder; the director will not run Godot before you END.
- `mem-budget: waiting` = machine full: wait, note the minutes. Free only your own processes, by PID. Never kill by name.

## Repo law
- Allowed to write: `build/n30-23/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/molotov_head_32.mp4`,
  `.../molotov/grid_molotov_head_arena/n30f_32/**` and `n30f_64/**`, that frames.json, `evidence/n30-keys/films.md`.
  **Any other path: stop and report a NEED.** Other lanes' worktrees (n23-street, n23-prologue, n25-yard), `main`,
  `C:/Users/kazda/kiro/pof`: forbidden. No image generation.
- Stage per path; no `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard.
- Fix lint and format findings in your own edit and go on. Do not delete anything in Temp or masters you did not create.

## Report (your final message)
Commit sha, files written, ffprobe line, the diff count, what you saw, what you could not do, minutes waited.
