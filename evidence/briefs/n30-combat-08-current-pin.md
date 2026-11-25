# n30 combat call 08: pin current_look.gd's five draw() survivors

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start: **commit by minute 25,
report and END by minute 40.** Never end uncommitted.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: before every launch (unit tests included) wait until no file in
`$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (`grep -l n23-street "$LOCALAPPDATA"/gtai/runs/*.json`), re-check every 30 s.
Only the shipped tools launch Godot (`tools/tests/run_unit.mjs`, `tools/mutate/mutate.mjs`, `tools/godot/check.mjs`).

## What is known
`evidence/n29/mutate/current_look.md`: mutate of `project/boot/collect_call/view/current_look.gd` against
`test_collect_call_current` is 15/20; the 5 survivors are all in `static func draw(ci, a, b, phase)` (lines ~48-53):
line 49 `scale = 1.0` -> `0.0`; line 52 `1.0 / maxf(0.01, scale)` (`1.0`->`0.0`, `/`->`*`, `0.01`->`1.01`); line 53
`draw_polyline(..., true)` -> `false` (antialias). Unit tests run headless (dummy renderer): a SubViewport pixel readback
returns nothing there, so a GUT readback is not possible. Pin them through a seam instead:
- Extract `static func k_of(ci: CanvasItem) -> float` (off-tree -> 1.0; in-tree -> `1.0 / maxf(0.01, global canvas scale x)`)
  and have `draw()` call it; test: off-tree Node2D -> 1.0; in-tree Node2D (add_child_autofree) with scale 2 -> 0.5, scale
  0.004 -> 100 (the 0.01 floor), scale 0.5 -> 2.0.
- `const ANTIALIAS: bool = true` used by `draw_polyline`; test asserts `CurrentLook.ANTIALIAS` is true (the owner's look is
  antialiased: a thin current drawn without AA prints stair steps).
Pixels must not change: the drawn output is identical by construction (say so with the code diff); no render needed.

## Do
1. The seam + tests in `project/tests/unit/test_collect_call_current.gd`. `node tools/tests/run_unit.mjs --select=test_collect_call_current`
   green, `node tools/lint/lint.mjs` green (file <= 200 lines, function <= 40), `node tools/godot/check.mjs res://boot/collect_call/view/current_look.gd`.
   Commit (`n30 combat: current_look draw() survivors pinned through k_of / ANTIALIAS seams`).
2. `node tools/mutate/mutate.mjs --file=project/boot/collect_call/view/current_look.gd --tests=test_collect_call_current --lines=<the draw/k_of lines> --max=8`
   and quote killed/(killed+survived). Write `evidence/n30/mutate/current_look.md` (before 15/20 from n29, after, per line). Commit it.

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`; the index is shared with another builder); never
`git add -A/./-u`, no stash, no amend, no rebase, no reset --hard. End each message with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook can take ~12 min; never skip it; if it fails
on a stale class cache run `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"` and
commit again. Fix lint and format findings in your own edit and go on. Do not touch docs/decisions.md, JOURNAL.md, REPORT.md.

## Allowlist (any other path: stop and report a NEED)
`project/boot/collect_call/view/current_look.gd`, `project/tests/unit/test_collect_call_current.gd`, `evidence/n30/mutate/**`, `build/**`.
Forbidden: every other lane's worktree, `project/features/player/**`, `project/boot/prologue/**`.

## Report and END
Files, commits, command result lines, mutate score, what you could not do.
