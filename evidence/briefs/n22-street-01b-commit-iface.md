# n22-street brief 01b (resume): commit the interface, forward --result, then Part B

Director's answers (00:22). All rules of brief 01 still bind. **Hard stop 01:20; Part B commit by 01:15.**

1. **Debt ratchet: authorised.** The `dev_loc` rise is the new gauntlet dev scene, which the night's contract
   requires. Run `node tools/debt/debt.mjs --update --accept-regression="gauntlet dev scene for n22 street"`,
   stage `tools/debt/baseline.json` with the Part A files, and make the interface commit now (message starting
   `gauntlet iface:`). Do the same for later rises caused by your own new gauntlet files (one reason string per
   commit, naming what grew). Never loosen a metric for a file you did not create.
2. **`--result` must reach the scene in the contract's launch form.** The contract (the judge's command and
   lane loop's batch tool) is exactly
   `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs json>`, with no repeated
   flag after `--`. You are authorised for this one change outside the allowlist: in `tools/dev/run.mjs`, when
   the runner's `--result=<file>` is given AND the resolved entry declares `--result` in its own
   `KNOWN_FLAGS`, also forward `--result=<the resolved absolute path>` to the entry's args (keep the runner's
   freshness check). An entry that does not declare it behaves exactly as today. Add a case to the runner's
   existing node test (`tools/dev/*.test.mjs`) for both branches, run
   `node --test "tools/dev/*.test.mjs"`, and commit it separately (`dev runner: forward --result to entries
   that declare it`). Append one `docs/decisions.md` line (DECISION dev-runner). Then re-run the contract
   command twice without the `--` repetition and byte-compare.
3. Then Part B (the seeded street) exactly as brief 01 says.

Final message as in brief 01, plus both commit shas.
