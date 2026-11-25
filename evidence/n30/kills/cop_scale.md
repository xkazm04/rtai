# n30 combat c27: killed street cop at his cop build (post-merge patch)

## What and why
`n30-cast` (c2281acbb and later) narrowed the patrol cop to +-8 % (`StreetCrowdCards.COP_SCALE_VAR`,
`body_scale_of(rig)`). Our `KillFallCells.victim_scale` still calls `body_scale(rig.actor_id)` (+-16 %), so after
both lanes merge a killed street cop would jump size at death. `cop_scale.patch` changes that one line to
`StreetCrowdCards.body_scale_of(rig)` (one extra doc-comment line) and adds
`test_a_street_cop_dies_at_his_cop_build` to `project/tests/unit/test_kill_card_scale.gd` (133 lines): a pose-less
COP rig (art_dir "cop") dies at `body_scale_of(rig)` (1e-9), within +-COP_SCALE_VAR, and for at least one of ids 7, 12, 19
that differs from `body_scale(id)`, so the test fails on the old line.

## Apply (after the Director merges n30-cast)
`git apply evidence/n30/kills/cop_scale.patch`

## Checks (Part A, no Godot)
- Throwaway merge of `n30-cast` into a detached worktree (only JOURNAL.md and REPORT.md conflicted, resolved with ours): `git apply --check` -> OK.
- On our HEAD (no cast) `git apply --check` -> also OK, but the patched code would NOT compile there (`body_scale_of` does not exist): apply only after the merge.
- `gdformat --check --line-length 100` on both files: unchanged; `gdlint`: no problems (one over-long comment line was wrapped).

## Unit proof
Patch applied on a throwaway merge of n30-cast (detached worktree, native DLLs copied from our `project/native/bin`),
APPDATA=gtai-n30/appdata/combat, Godot 4.7.2. The test builds its cop with `RigVariant.crowd(5)` (patrol, `head_cap`);
`crowd(0)` was a first draft that needed a missing `head_hat.png`, and the patch carries the fixed version.
- `node tools/tests/run_unit.mjs --select=test_kill_card_scale,test_street_crowd_cards,test_kill_card_fall` ->
  `unit-tests: 25 passed, 0 failed, 0 skipped (GUT, headless)`.
- Line 95 reverted to `body_scale(rig.actor_id)`, `--select=test_kill_card_scale` ->
  `unit-tests: gut exit 1; gut rerun exit 1; 1 failing (4 passed, 1 failed, 0 skipped)`;
  `FAIL test_kill_card_scale.gd:130 test_a_street_cop_dies_at_his_cop_build - [1.06693705653467610000] expected to equal [1.03346852826734] +/- [0.000000001]:  7`.
- Final patch re-checked: `git apply --check` OK on the merged tree and on our HEAD; gdformat/gdlint clean on the test.
