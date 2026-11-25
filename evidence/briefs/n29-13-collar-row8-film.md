# Brief n29-13-collar-row8-film: the p55 collar film and in-game still with row 8 fixed (lane keys, run n29). Evidence only.

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
`{START}` launched. **Evidence commit by `{COMMIT}`. Report and END by `{END}`**, committed or not. 0 images. No product
file changes (no sheet, code, table, test): evidence and masters only, so the commit hook is quick.

## Why
`evidence/n29-keys/films.md` "Job 2" made the p55 collar still and clip when only row 4 was fixed. Since then `56cb77065` +
`e553b6b9e` put the rigid collar on sheet row 8 too (row 4 mirrored, `evidence/n29-keys/collar_p55_transplant.md`). The owner
judges by films: the clip must show the sheet as it ships now.

## Steps (re-use the exact scripts and harness of films.md Job 2: `evidence/n29-keys/films/run_hands.py`, `compose.py`)
1. Re-run the bare-hands harness "after" at HEAD at 32 px/m and 64 px/m into new dirs `collar/run_after8_32`,
   `collar/run_after8_64` (the existing `run_before_*` stay the before: they are the c649a15d6 sheet). One Godot at a time.
2. Frame diff after8 vs the old after: only the 1-based row 8 beats (0-based row 7: its walk beat and sprint beat ticks)
   may differ; every other tick 0 px. Write the numbers.
3. Still `collar/collar_p55_row8_before_after_64.png` exactly like `collar_p55_before_after_64.png` but at the row-8 sprint beat
   (before | after 1:1 crop, plus a 3x nearest crop of the neck band). Look at it yourself and say what you see.
4. Clip `collar/collar_p55_32_r8.mp4` exactly like `collar_p55_32.mp4` (before | after, 16 beats x 60 frames, 1920x1080 60/1);
   ffprobe (width, height, r_frame_rate, duration 15-40 s, nb_frames). Keep the old clip.
5. Append "## Job 2b: collar row 8 (n29-13)" to `evidence/n29-keys/films.md` with runs, diff, ffprobe, what you looked at.
   Commit "evidence: n29 keys collar row 8 film and still". Stage per path.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Take the lane mutex before
every Godot step: `(set -o noclobber; echo "film13 $(date +%H:%M)" > build/n29-godot.lock)` (re-try every 60 s while held;
older than 25 min = stale only if no gate process runs: ask nothing, just wait), `rm build/n29-godot.lock` after. Windowed runs:
`--position 0,1440`. No amend, rebase, stash, `git add -A/./-u`. Python with `-I`.

## Allowlist (anything else: stop and report)
`evidence/n29-keys/films.md`, `evidence/n29-keys/films/**` (only if a script needs an argument added), 
`C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/**`, `build/**`. Forbidden: everything in `project/`, tools, docs,
`JOURNAL.md`, `REPORT.md`, `frames.json`, other lanes' worktrees. Never delete anything in Temp you did not create.

## Report (short), then END
Runs, frame diff, the still (what you saw), ffprobe of the clip, commit sha, what you could not do.
