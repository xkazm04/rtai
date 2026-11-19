# Brief n19-gfx-13: anim x gfx merge rehearsal (report only, nothing committed to any lane)

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -25`, `AGENTS.md`, `tools/README.md` (the `tools/merge/` sections) and the last 10 lines of `docs/decisions.md` first. You build and measure; the director reviews every number and frame. FREEZE: finish by 07:20 local.

Write your report as you go to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge-13-REPORT.md`.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time (yours). `--rendering-driver d3d12` for renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name.
- Never push. Never check out, edit or commit on `main`, `int-n19` or any `n19-*` branch, and never open another lane's worktree directory. Reading other branches through git (`git log n19-anim`, `git show n19-anim:<path>`, `git merge` into YOUR temp branch) is allowed.

## Why
`node tools/merge/preview.mjs --lanes=n19-ai,n19-anim,n19-guns,n19-move,n19-gfx --base=int-n19` (04:20 run) says gfx meets exactly one conflict in the morning: five look goldens changed on both `n19-anim` and `n19-gfx` (`project/tests/golden/look/{auto-48ppm-ov,auto-56ppm-ov,auto-64ppm-ov,d4-48ppm,d5-48ppm-ov}.png`). Also, the anim lane's crowd shader (its `b472095b6`) reads the people instance's `INSTANCE_CUSTOM.y` as sim slot + 1 to scale the baked cell by the actor's build. gfx now writes that value (`0dc71557a`, native `render.cpp` and `sim_render.gd`). Each half is invisible alone. Only the merged tree shows whether the baked crowd's body size now matches the live rig at the 16-rig switch. anim's request, with its expected numbers, is in `git show n19-anim:evidence/crowd-pop/NEED-gfx.md`.

## Steps
1. Make a temp worktree on a temp branch: `git worktree add -b rehearse-n19-gfx-anim %LOCALAPPDATA%/Temp/gtai-gfx-rehearse int-n19`. In it: `git merge --no-edit n19-anim`, then `git merge --no-edit n19-gfx`. For the five golden conflicts, take either side for now (they get re-rendered in step 4). For any other conflict, stop and report it (file + both sides' commits). Copy this worktree's `native/godot-cpp` and scons setup if needed (fresh worktrees lack them), build the native DLLs debug + release from the MERGED `native/`, then `--import` once.
2. **The visible end-to-end check.** Re-run anim's crowd-pop switch probe (find it via `git show n19-anim --stat` / `n19-anim:evidence/crowd-pop/`) on the merged tree, at 64 px/m tilt 70 and top, ticks 31/32/33 (rig -> atlas). Measure the hat, riot and overalls heights on the live rig and on the baked cell (anim's NEED expects 115, 118 and 122 px held across the switch; before the slot write the baked hat was 101 px). Also check slot 0 and a slot past a rigged slot. Make one sheet `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge/crowd-switch-merged-64ppm.png`: rows = int-n19+anim only (slot field 0) vs the merged tree (slot field set), columns = ticks 31/32/33, heights labelled. Look at it.
3. **Noir part.** In the temp worktree only, apply anim NEED part 2 (`project/assets/shaders/look_noir_crowd.gdshader` includes `res://features/characters/crowd_atlas_vertex.gdshaderinc` and keeps its ink uniforms and fragment; `NoirFrames._ink_crowd()` in `project/dev/noir/noir_frames.gd` uses `_characters.rigs.atlas.configure_material(m)`). Parse-check both (`node tools/godot/check.mjs`), run the noir dev frames once if a runner exists and look at one frame. Save the diff as `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge/anim-need-part2.patch` (the Director applies it at the merge).
4. **Goldens.** On the merged tree, re-render the look goldens the way the repo re-blesses them (find the bless path in the golden test or `tools/`); report, for each of the 16 junction + block goldens, the mean diff against the n19-gfx PNG and against the n19-anim PNG and pass/fail at the stored tolerance. Copy the five conflicted re-renders to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge/goldens/` (masters only, not into git).
5. On the merged tree: lint, `node tools/tests/run_unit.mjs --fast`, scenarios, parity, bake `--check`. Quote each line. Name anything red with its first error line and which branch it comes from.
6. Clean up: remove the temp worktree (`git worktree remove --force`), `git worktree prune`, delete the temp branch (`git branch -D rehearse-n19-gfx-anim`), and remove `%LOCALAPPDATA%/Temp/gtai-gfx-*` leftovers you made. Confirm `git branch --list rehearse*` is empty.

## Acceptance
- No commit on `n19-gfx` unless a gfx-owned fault on n19-gfx itself is found. If one is, fix it there with a test, one commit, green `tools/gate/quick.mjs`, and say so.
- Every number has a file behind it in `C:/Users/kazda/kiro/gtai-masters/n19/gfx/merge/`.

## Report back (short, also in the report file)
Conflicts met, heights table (rig vs baked per look, before/after), the sheet path, noir patch status, the golden table, the merged tree's gate lines, cleanup confirmed.
