# Brief n29-08-films: the owner's clips for the plasma sword and the p55 collar row 4, evidence only (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
**No product file changes** (nothing under `project/`, `tools/`, `docs/`): you render, compose and write evidence. No images.

## Wall clock (run `date +%H:%M` first and often)
`{START}` launched. Commit the evidence md by `{COMMIT}` (inert path: the hook is quick). **Report and END by `{END}`.**

## Machine law
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. `{GODOT_RULE}`.
Godot only through `tools/lib/godot.mjs` (`runGodot`) or the repo tools; d3d12; windowed `--position 0,1440`;
`mem-budget: waiting` = machine full. A temp worktree you create goes under `%LOCALAPPDATA%\Temp\gtai-keys-film-<sha8>`
(copy `project/native/bin`, `project/data/generated/city`, `project/.godot` from this worktree into it) and you remove it
(`git worktree remove --force`) before you END. Never delete anything in Temp you did not create.

## The capture
`C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/scripts/capture28.py <weapon> <mode>` (run from the worktree root; it
copies the archived dev scene `grid_arena_film` in for the run and moves it out afterwards: check `git status --short project/`
is empty after each run): tilt 70 at 32 and 64 px/m, 1080p, `--fixed-fps 60`, King's Boulevard, walk then sprint in 8
directions, 991 frames to `gtai-masters/<run>/keys/grid_<weapon>_arena/<mode>_<ppm>/`. Read the script first; point its
output under `C:/Users/kazda/kiro/gtai-masters/n29/keys/` (argument or a copy of it under `evidence/n29-keys/films/`).

## Jobs, in this order (each finished and looked at before the next)
1. **Plasma sword**: `capture28.py plasma_sword n29` at HEAD (32 and 64); the stop-gap `capture28.py plasma_sword base` from a
   temp worktree at `c649a15d6`; the katana donor `capture28.py katana n29` at HEAD (32 only).
   Clip `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/plasma_sword_32.mp4`: three 640x540 tiles side by side
   (stop-gap | n29 | katana, 1:1 crops of the 32 px/m frames centred on the screen centre, ffmpeg hstack) over the 64 px/m n29
   tile below (1920x1080 total), the same frame index in every tile, 60/1, libx264 crf 16, yuv420p, cut to 15-40 s
   (the walk then the sprint). `ffprobe` it, quote the line. Plain ASCII labels burned in (drawtext or a PIL overlay).
1b. **Gloria beside the pistol**: the captures exist (`C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/grid_gloria_arena/candidate_32/`,
   `grid_pistol_arena/`: check it has the full 991-frame 32 px/m lap, else `capture28.py pistol n29`); the stop-gap from the base temp
   worktree (`capture28.py gloria base`). Clip `gloria/gloria_vs_pistol_32.mp4` laid out as job 1 (stop-gap | n29 | pistol over the
   64 px/m n29 tile: `capture28.py gloria n29` at 64 if `candidate_64` holds samples only). ffprobe it.
2. **Collar p55 row 4** (Rivet sprinting at tilt 55): the row-4 facing at 64 px/m, before (`c649a15d6`'s
   `project/features/characters/art/view/p55/rivet_run8.png`, swapped into a scratch copy or the base temp worktree) | after
   (HEAD), the same tick: `C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/collar_p55_before_after_64.png` (crop 1:1 and a 3x
   nearest crop of the neck). Find the p55 sprint scene from `evidence/n27-keys/p55_sprint_drift.md` (the drift setup) and
   re-measure the drift there at 64 px/m (bar: 3.83 cm +- 0.1, unchanged by a neck-only edit). A 10-20 s 32 px/m clip of the
   p55 sprint if the setup films it: `collar_p55_32.mp4` (ffprobe).
3. `evidence/n29-keys/films.md`: every still/clip path, ffprobe lines, the drift number, what you looked at. Commit it alone:
   `git commit -m "evidence: n29 keys films (plasma sword, p55 collar row 4)" -- evidence/n29-keys/films.md`.
4. `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json` (create or extend; `[{ "file", "title", "ppm", "before", "note" }]`,
   best first, 8 to 15 entries; `file` relative to that folder): the sword clip first, then the existing Gloria clip/stills if
   present (`gloria/`), the HUD pair (`hud/hud_pair_crop_3x.png`, `hud/hud_before_1080.png` -> `hud/hud_after_1080.png`), the
   sword grid stills (`sword/grid_plasma_sword_64.png`, `_32.png`), the collar pair, the rag crops (`rag/`).
   Delete only scratch you made that frames.json does not reference; keep the `*_arena` frame dirs.

## Allowlist
`evidence/n29-keys/films.md`, `evidence/n29-keys/films/**` (scripts), `C:/Users/kazda/kiro/gtai-masters/n29/keys/**`,
`build/**`, your temp worktree. Everything else read only. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`,
`reset --hard`. Free only your own processes, by PID.

## Report (short), then END
Each job: done or not, paths, ffprobe lines, drift, commit sha, temp worktree removed, what you could not do.
