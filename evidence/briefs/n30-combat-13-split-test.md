# n30 combat call 13: kill the last KillCardFall mutate survivor (the sheet split rule)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start. **Code + test committed by
14:35, mutate quoted and report END by 14:50 (hard).** Never end uncommitted.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c12) is running Godot takes here and has TEMPORARILY patched
`project/core/render/light_pool.gd`, `project/assets/shaders/light_ink.gdshader`, `project/data/tables/lights.json`, its schema,
`arena_combat_lights.gd`, `test_light_explosion_amber.gd` and a new `test_light_pool_rim.gd`: never stage, restore or edit those.
Before every Godot launch wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (re-check every 30 s).

## What is known
c09's mutate on `project/features/combat/kills/kill_card_fall.gd` (`--tests=test_kill_card_fall,test_kill_card_scale`) scored
5/6: the survivor is line 47 in `usable()`, `tex.get_width() % RigHeadCard.FRAMES != 0 or tex.get_height() % rows != 0` with
`or` -> `and`. No test feeds a sheet that splits on one axis only, and `usable()` reads a real texture, so the rule cannot be fed
a made-up size.

## Do
1. Extract the rule: `static func splits(size: Vector2i, rows: int) -> bool` in `kill_card_fall.gd` (true when width % FRAMES == 0
   and height % rows == 0; doc comment one line), and `usable()` calls it. Behaviour identical. File stays under 200 lines,
   functions <= 40 lines, typed.
2. Test in `project/tests/unit/test_kill_card_fall.gd`: `test_a_sheet_must_split_on_both_axes`: (FRAMES*96, 3*192, rows 3) true;
   (FRAMES*96, 3*192+1, 3) false; (FRAMES*96+1, 3*192, 3) false; (FRAMES*96+1, 3*192+1, 3) false.
3. `node tools/godot/check.mjs project/features/combat/kills/kill_card_fall.gd project/tests/unit/test_kill_card_fall.gd`;
   `node tools/tests/run_unit.mjs --select=test_kill_card_fall,test_kill_card_scale,test_kill_new_styles,test_claw_card_victims`
   (quote the line; all pass); `node tools/lint/lint.mjs` clean on your two files. Commit both
   (`test: KillCardFall.splits needs both axes (kills the or->and survivor)`).
4. Mutate after the commit: `node tools/mutate/mutate.mjs --file=project/features/combat/kills/kill_card_fall.gd --lines=<the splits line(s)> --tests=test_kill_card_fall --max=4`
   (time budget 10 min). Quote killed/(killed+survived). Append it to `evidence/n30/kills/card_fall.md` under
   `## Street walker identity (c09)` as a line `c13: ...` and commit that file.

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook
(~12 min possible; if it fails on a stale class cache, run `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"` and commit again).
Do not touch docs/decisions.md, JOURNAL.md, REPORT.md. Fix lint and format findings in your own edit and go on.

## Allowlist
`project/features/combat/kills/kill_card_fall.gd`, `project/tests/unit/test_kill_card_fall.gd`, `evidence/n30/kills/card_fall.md`,
`build/**`. Any other path: stop and report a NEED.

## Report and END
Diff summary, check/unit/lint lines, commit hashes, mutate score, what you could not do.
If the pre-commit hook fails on one of c12's temporarily patched paths (listed above), do not fix it: wait 5 minutes and commit
again; if it still fails at 14:45, report the hook output and END uncommitted only for that reason.
