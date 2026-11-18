# Brief 05: the debt ratchet fails, fix it in under 10 minutes

Same worktree, branch and repo law. Commit 316516ff7 accepted.

`node tools/debt/debt.mjs --check` FAILS on HEAD: `dev_loc: 22644 -> 22646  project/dev/bake_city.gd grew from 32 to 34 lines`.
The gate runs this check, so the branch cannot pass as it is. Do not skip the hook to get around it.

Fix: bring `project/dev/bake_city.gd` back to 32 lines or fewer without losing information and without
lines over the lint limit: e.g. fold the `--fail-fast requires --check` validation into the existing
argument loop / one condition, and/or merge the doc comment into fewer `##` lines (it must still say:
dev-only; no flag writes `data/generated/city/c_XX_YY.bin` + `data/generated/city_chunks.sha256`;
`--check` = two bakes vs the golden list; `--fail-fast` = stop at the first differing chunk). Behaviour
unchanged (same exit codes and messages). If and only if that is impossible, use
`node tools/debt/debt.mjs --update --accept-regression="dx-duo: bake_city --fail-fast flag validation (+2 dev lines)"`.

Godot IS allowed in this session (I stopped my gate), one process at a time:
`export APPDATA=C:/Users/kazda/kiro/gtai-bake/appdata/dx-duo` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`, then
`node tools/godot/check.mjs res://dev/bake_city.gd` and `node tools/tests/run_unit.mjs --select=test_city_bake`.
Then `node tools/debt/debt.mjs --check` must print PASS, and `node tools/lint/lint.mjs` must pass (paste its last lines).
If debt.mjs prints `tighten:`, run `node tools/debt/debt.mjs --update` and commit the baseline too.
One or two commits, normal hook (if the hook's clash check is the only thing that fails, say so and
skip it then). Final message: commit shas, the debt and lint result lines.
