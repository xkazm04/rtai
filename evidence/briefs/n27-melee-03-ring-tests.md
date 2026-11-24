# Brief n27-melee-03-ring-tests: make the bond ring's tests able to fail when a draw call goes

Lane `melee`, branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadlines are given at the end of this brief (wall clock).** At the hard stop write your report
and END, even mid-task. Never stop to ask: at a fork pick what best serves the owner's words, write it in your report,
go on. Fix lint and format findings in your own edit and go on. No amend, no rebase.

## Why
`project/features/souls/ghost_bond_ring.gd` (the teal arc in each ghost's HUD chip) scored 2 killed / 18 on mutate last
night (`evidence/n26/bond/mutate-ring.txt`): its tests (`project/tests/unit/test_ghost_bond_ring.gd`) pin the fill
fraction and angles, but deleting any draw call (track, ink under-stroke, fill arc, crown diamond, crown dot) passes.

## What
1. Make what the ring draws observable to a test without changing a single drawn pixel. Preferred: split `_draw` into a
   pure `plan(...)` that returns the list of draw commands for the chip (kind, center, radius, angles, colour, width,
   points) and a short `_draw` that replays the list through one dispatcher. Then a test can assert the exact commands
   for: an empty bond (ink + track only, no fill, no crown), a half bond (fill arc span), a full ready bond (crown
   diamond + dot, the arc gap), a mastered bond (full circle, no crown), bond disabled (nothing). Keep colours as the
   named constants (TEAL only for the soul fill: colour law).
2. If the unit runner can render (check whether GUT runs `--headless` with the dummy renderer; it likely cannot), also add
   one pixel test through a SubViewport; if it cannot render, do not fake one: say so and rely on the plan test.
3. Prove it: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond_ring.gd --max=20 --tests=test_ghost_bond_ring`
   before (on HEAD at your start, quote the score) and after your commit; target >= 70 %. Quote both scores and list the
   survivors with one line each on why they survive (an equivalent mutant is fine to name as such).
4. Prove no pixel moved: a 64 px/m still of the chip strip with a prefilled bond, before (HEAD at your start) and after
   (your commit), same tick, pixel diff = 0 (`node tools/film/compare.mjs` or the `bond_film` entry if it exists in
   `project/dev/ghost-forms/`; `--rev=<commit>` snapshots). Save both and the diff count under `evidence/n27/ring/`.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`. One Godot process at a time; kill only
  your own PIDs, never by name.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every new
  `.gd`, Godot `--import` after new scripts before committing. `node tools/gate/quick.mjs` before every commit. Stage per
  path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. If the pre-commit hook
  fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again.
- Inner loop: `node tools/tests/run_unit.mjs --select=test_ghost_bond_ring`.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/souls/ghost_bond_ring.gd`, `project/tests/unit/test_ghost_bond_ring*.gd` (+ new test files),
`project/dev/ghost-forms/**`, `evidence/n27/ring/**`. Forbidden: the keys lane's `ghost_form_hud.gd`,
`ghost_form_layout.gd`, `ghost_deploy.gd`, `ghost_hud_hints.gd`; every other gameplay file; other worktrees; root
`JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; mutate before and after with survivors; the pixel diff line; anything not done and why.
