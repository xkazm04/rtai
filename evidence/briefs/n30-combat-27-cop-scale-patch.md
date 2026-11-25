# Brief n30-combat-27: the killed street cop's build as a proven post-merge patch (evidence only)

Clock: launched ~17:08. Commit the patch + md by **17:45** (part A). Part B (unit proof) only if Godot is free by 17:55;
commit its section by **18:20**. Report and END at **18:22** at the latest. Never end before a commit of what you have.

## Goal
Cast lane (`n30-cast`, commit `c2281acbb` and later) narrowed the patrol cop's build to +-8 %:
`StreetCrowdCards.body_scale(actor_id, spread)`, `COP_SCALE_VAR = 0.08`, and `static func body_scale_of(rig: CutRig) -> float`
(cop = art_dir "cop" -> COP_SCALE_VAR, else SCALE_VAR). On OUR branch `project/features/combat/kills/kill_fall_cells.gd:95` is
`var k: float = StreetCrowdCards.body_scale(rig.actor_id)`: after the Director merges both lanes, a killed street cop is sized at
+-16 % while his living card drew at +-8 % (he jumps size at death). The fix is
`var k: float = StreetCrowdCards.body_scale_of(rig)`. It cannot be committed on our branch (`body_scale_of` exists only on
`n30-cast`). Deliver it as **`evidence/n30/kills/cop_scale.patch`** that applies cleanly AFTER the merge of `n30-cast`, plus a
unit test in the same patch, proven.

## Part A (no Godot: the lane's Godot is held by the `--reels` gate until ~17:50)
1. Read `git show n30-cast:project/features/characters/street_crowd_cards.gd` (lines 20-80) and
   `project/tests/unit/test_kill_card_scale.gd` (our walker tests, lines ~90-115) to see how a rig is built in tests.
2. Make a temp worktree OUTSIDE the repo: `git worktree add --detach "$LOCALAPPDATA/Temp/gtai-c27-merge" HEAD`, then in it
   `git -c user.name=c27 -c user.email=c27@local merge --no-edit n30-cast` (a throwaway merge commit on a detached HEAD;
   never on any branch). If it conflicts on files outside `project/` (JOURNAL.md / REPORT.md / evidence), resolve with ours
   (`git checkout --ours <path>`), never touch product conflicts: if a `project/` path conflicts, stop and report.
3. In the temp worktree, edit `kill_fall_cells.gd:95` to `body_scale_of(rig)` (update the doc comment above
   `victim_scale` by at most one line: "a street walker keeps his crowd build (a cop his +-8 % cop build)") and add ONE
   test to `test_kill_card_scale.gd`: a pose-less cop rig (art_dir "cop") dies at `StreetCrowdCards.body_scale_of(rig)`,
   and for at least one id that value differs from `body_scale(id)` (so the test fails on the old line). Keep the file
   <= 200 lines (trim a header line if needed, as c13 did); typed GDScript, `assert_almost_eq` with 1e-9.
4. `git diff > patch` in the temp worktree (only those 2 files), save as `evidence/n30/kills/cop_scale.patch` in OUR
   worktree. Check: in a second clean temp merge (or `git stash`-free: `git checkout -- .` in the first temp worktree)
   `git apply --check` -> OK; on OUR HEAD (no cast) `git apply --check` is expected to apply too but the code would not
   compile: say so.
5. Lint the patched files in the temp worktree: `node tools/lint/lint.mjs` if it can run there, else
   `gdformat --check` + `gdlint` on the two files. Fix your own findings.
6. Write `evidence/n30/kills/cop_scale.md` (what, why, the apply command, the check results, Part B pending). Commit in OUR
   worktree: `git add evidence/n30/kills/cop_scale.patch evidence/n30/kills/cop_scale.md` then
   `git commit -m "evidence: n30 combat c27 cop scale post-merge patch" -- evidence/n30/kills/cop_scale.patch evidence/n30/kills/cop_scale.md`.

## Part B (Godot, only once `build/gate-runs/gate-ac27d74e5-reels.out` ends with a `gate: PASS|FAIL` line)
- In the temp worktree with the patch applied: copy the native DLLs it lacks from OUR worktree's `project/` (same base,
  nobody rebuilt native: look for the `.gdextension` file and its `bin/` path), `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat`,
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, then
  `node tools/tests/run_unit.mjs --select=test_kill_card_scale,test_street_crowd_cards,test_kill_card_fall` (it imports
  first). Bar: all pass. Then revert ONLY the line 95 change in the temp worktree and run `--select=test_kill_card_scale`:
  the new test must FAIL (quote it). Append `## Unit proof` to cop_scale.md, commit as above.
- If Godot is not free by 17:55 or the import fails, write `Part B: not run (<reason>)` in the md and commit.

## Law
- Allowlist (our worktree): `evidence/n30/kills/cop_scale.patch`, `evidence/n30/kills/cop_scale.md`. Any other path: stop
  and report a NEED. Never edit `project/` in OUR worktree. Never touch the n30-cast worktree (`gtai-wt/n23-prologue`), other
  lanes' worktrees, `main`. Reading `n30-cast` by `git show` is fine.
- No `git stash`, no amend, no rebase, no `add -A/./-u`, no `reset --hard`. Stage per path.
- One Godot at a time for the lane: never start Godot while the reels gate runs (`Get-Process -Id 39500` alive = gate running).
- At the end: `git worktree remove --force "$LOCALAPPDATA/Temp/gtai-c27-merge"` (yours) and `git worktree prune`.
- Report: files, commits, commands run with their result lines, what you could not do. Then END.
