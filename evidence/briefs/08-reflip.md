# Brief 08 (lane tonnage): pin the two legacy tests, re-apply the flip, small polish

HARD STOP 05:58: everything committed or abandoned by then. All rules of briefs 03-07 bind (no amend/rebase/squash/stash, no
`add -A/./-u`, no `reset --hard`, never push, stage per path, a fix is a NEW commit; `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; one Godot process at a time; kill only by PID).
Never edit a test file that is not ours (ours: `test_tonnage_*`, `test_hauler_*`, `test_ram_*`, `test_slam_debris*`, `test_plate_sparks*`), except `test_ghost_card.gd` in item 2.

## 1. Our own flip blocker (5 min)
`project/tests/unit/test_tonnage_stride.gd`: the legacy walking-grid case failed with the tonnage row = spectral. It tests the legacy body:
pin it to legacy (`GhostLook.override_for_test(GhostLook.LEGACY)` + `GhostLook.reset_for_test()` in `after_each`). Commit.
`node tools/tests/run_unit.mjs --select=test_tonnage_stride` green.

## 2. Pin flight's card test to legacy (flight's owner OKed this as a named call site, 05:3x) and re-apply the flip
`project/tests/unit/test_ghost_card.gd` (flight's file, edit allowed THIS ONCE): its 3 cases that read Tonnage's legacy crown/hose sprites
failed with the row = spectral. Pin them: `GhostLook.override_for_test(GhostLook.LEGACY)` in those cases (or `before_each`) and
`GhostLook.reset_for_test()` in `after_each`. Nothing else in that file. Commit on its own: `Pin the ghost card test to the legacy look`.
Then `git revert --no-edit 1e85ea0a4` (re-applies the flip 8c44e8b90 as a new commit) and run the FULL `node tools/tests/run_unit.mjs`.
`test_vehicle_view.gd` marked-traffic count is a known flake: re-run that file alone once; passing alone = not a blocker. Anything else red
that is not ours: `git revert --no-edit HEAD` (back to legacy) and name it. Green: `node tools/lint/lint.mjs`; keep the flip.
Do items 1 and 2 BEFORE item 3.

## 3. Polish while you wait (each its own commit, stop at 05:50)
a. Double ground glow: under spectral our `TonnageGlow` ground halo (`tonnage_glow.gd` / `tonnage_rig.gd`) draws on top of flight's teal
   pool. Keep the body fill; cut our GROUND halo so one pool remains (one const). `run_unit.mjs --changed` + lint green. Before/after still,
   tick 72, p70 (`--view=tilt70`), 64 px/m, `--ghost-look=spectral`, `--rendering-driver d3d12 --position 0,1440`:
   `C:/Users/kazda/kiro/gtai-masters/n20/tonnage/tonnage_glow_pool_64.png` and `_before.png`.
b. `C:/Users/kazda/kiro/gtai-masters/n20/tonnage/tonnage_morph_32.jpg` shows only the burst ring: re-cut the poster from
   `tonnage_morph_32.mp4` (ffmpeg) at a frame where the golem is half risen. No re-film.

## Report
Commits (sha + line), checks + counts, whether the flip is ON or OFF at the end and why, NEED lines. Short.
