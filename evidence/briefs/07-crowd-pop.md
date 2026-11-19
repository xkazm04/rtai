# Brief 07 (lane anim, tag crowd-pop): the baked crowd cell pops at the 16-rig switch

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor only).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees (READ-only `git -C ../n19-gfx show` is fine), `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Quick gate: `node tools/gate/quick.mjs --no-godot` (its Godot step fails on
  untouched characters/ files: known tool limit), and prove parse + tests with `node tools/tests/run_unit.mjs --changed`.
- Ownership: anim owns `project/features/characters/**` (crowd_atlas.gd, crowd_baker.gd, crowd_atlas.gdshader if it
  lives there, rigs, plans) and `tools/art/**`. The `gfx` lane owns `project/features/city/**`, `native/**`, every sim /
  replay / parity / bake digest, and tonight changed `native/sim_core/src/render.cpp`, `features/city/sim/sim_render.gd`,
  `features/city/view/city_crowd_contact.gd` on branch n19-gfx (b9cddfe91, 268960380). You may not edit those. If the
  fix needs them, write the exact change into `evidence/crowd-pop/NEED-gfx.md` instead.

## The fault (reported by gfx, confirmed by the director's eye)
`C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/A-compare-tilt70-64ppm-t31-32-33.png`: tilt 70, 64 px/m, a hat-man ped
crosses rank 16 -> 17 (full CutRig -> baked CrowdAtlas cell). The baked cell draws him visibly smaller (~10% shorter,
narrower) and the hat crown is sliced flat at the cell's top edge. A body pop at the LOD boundary.
Known layout: `CrowdAtlas.CELL_PX` 128, `BAKE_ZOOM` 1.5 (cell = 85.3 world px), `CrowdBaker._centre` puts the rig's
origin at 0.55 of the cell height, so anything taller than ~47 world px above the origin is cut.

## Do
0. Owed from your last session (a2e7b603b, Tonnage step-5 mid cell): `node tools/mutate/mutate.mjs --file=features/souls/ghost_sheet.gd`
   (project-relative path as the tool wants) and the same for `ghost_drawn.gd` limited to the lines a2e7b603b changed
   (`--lines=`). Quote killed/(killed+survived) in your report; if a survivor is a real gap, add the test and commit it.
1. Audit, before any change: a dev script (`project/dev/...`, declare `KNOWN_FLAGS`, run through `tools/dev/run.mjs`)
   that for every crowd look x every atlas clip frame (LOOKS x 25 cells), at tilt70 AND top view (whatever views the atlas
   is baked for), reports: (a) clipped = any alpha > 0 in the cell's outer 1 px border (top, left, right, bottom);
   (b) the baked figure's bbox (w, h, feet y) vs the same look rendered as a live CutRig at the same zoom and pose.
   Write `evidence/crowd-pop/audit_before.json` + a one-line summary per look. Name every clipped look and the scale
   ratio baked/live. Find the cause of the "smaller" read: atlas bake scale vs the card quad size the city draws it at
   (GDScript `character_rigs.gd` baked path, and how `sim_render.gd` / native size the quad: file:line).
2. Fix in anim's files: enough headroom that no look clips (e.g. a taller cell or a lower origin anchor; keep the atlas
   a power-of-two-friendly size and stay under the memory the old atlas used x2), and a baked size that matches the
   live rig within 1 px at 64 px/m (bbox height and feet y). Every consumer must read the anchor/size from CrowdAtlas
   constants, not a copy: list each consumer. If a consumer you do not own hard-codes 0.55 / 128 / 1.5, do not edit it:
   NEED-gfx.md with the exact line change, and keep the layout change behind a const so the merged result is right
   once gfx applies it (say clearly in your report whether the visible fix lands without gfx).
3. Re-run the audit: `audit_after.json`, 0 clipped cells, size ratio within 1 px. A unit test that pins the headroom
   rule (e.g. the bake stage origin leaves >= the tallest plan's height above it), red on the old constants.
4. Film: same-tick before/after at the 16 -> 17 switch, tilt70 64 px/m (the hat-man, plus one tall cop and the overalls
   ped) and a 10-40 s 32 px/m clip of a crowd crossing the 16-rig ring. Use or adapt gfx's compare method (READ their
   n19-gfx `docs/` / `evidence/briefs/n19-gfx-02-contact*` for how they made the rank 16/17 still; do not copy their
   files into your tree unless they are already on this branch). Frames to `C:/Users/kazda/kiro/gtai-masters/n19/anim/crowd-pop/`.
   Look at them and describe what you see.
5. Goldens: run the look goldens; re-bless only a golden whose frame really contains a baked crowd cell, name it, and
   add a `docs/decisions.md` line `- [2026-11-19] DECISION anim/crowd-atlas: ...` (what headroom/scale, why, rejected).
   If the atlas bake feeds any digest (sim/replay/parity/bake), STOP and report: those are gfx's.
6. Mutate the changed main file: `node tools/mutate/mutate.mjs --file=<project-relative .gd>`; quote the score.

End with: files, commits (sha + subject), audit before/after summary (clipped looks, size ratios), consumers list,
NEED-gfx (if any), frame paths, mutate score.
