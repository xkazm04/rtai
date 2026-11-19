# Package 1b (guns lane): finish the audit commit

Your audit is accepted as built (director reviewed the matrix and the test). Finish it:

1. The `dev_loc` debt rise is deliberate and allowed: run `node tools/debt/debt.mjs --update --accept-regression="n19 guns: arsenal completeness audit (dev/rivet_arsenal, ratchet test) +522 dev LOC"` (the debt tool is the only sanctioned way to touch `tools/debt/baseline.json`; it is shared, the tool's edit is fine). Read `tools/debt/README.md` first if the flag differs.
2. Re-run `node tools/lint/lint.mjs` (all green) and `node tools/tests/run_unit.mjs --select=test_arsenal_audit`.
3. Commit the staged audit (code + uid + allowlist + test) and the baseline as two commits, staged per path, through the normal pre-commit hook (never `--no-verify`).
4. Run `node tools/mutate/mutate.mjs --file=dev/rivet_arsenal/arsenal_audit.gd --tests=test_arsenal_audit --max=12` and, if time allows, the same for `arsenal_audit_files.gd` `--max=8`. Paste the killed/(killed+survived) lines. If a surviving mutant shows a real blind spot (not an equivalent mutant), add one test that kills it and commit it.

Same law as before (APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns, GODOT_BIN, headless, one Godot at a time, no stash/add -A/reset --hard, never push). Report: commits (sha + subject), lint/test lines, mutation scores.
