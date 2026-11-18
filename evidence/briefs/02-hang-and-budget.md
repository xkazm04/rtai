# Brief 02: prove the hang/crash path with real processes, and widen the bake budget

Same worktree and branch, same repo law as brief 01 (stage per path, plain commit messages without
model names, no stash/add -A/reset --hard, never push, no other bk-* worktree).

**Do not start Godot in this session at all** (no run_unit, no check.mjs, no mutate, no bake): I am running
the full 261-mutant `--oracle=bake-check` run on the mutation worktree right now and the arm may run one
Godot process at a time. Node-only work and `node --test` are fine. `node tools/gate/quick.mjs` only if it
starts no Godot (check first; if it does, skip it and say so).

Your commits so far (eb16964ad, d58644649, 1e63815a2) are accepted. Review notes to act on:

1. **Hang/crash path tested with real processes.** Today `oracles.test.mjs` proves `judgeMutant` and
   `classifyBake` on canned objects only; nothing shows that a real hanging or erroring child is
   tree-killed and classified. Make the process launcher of the `bake-check` runner injectable
   (e.g. `oracleRunners(wt, tests, env, explicit, { runBake = runGodot } = {})`, or a small exported
   `bakeRunner(run)`; keep `mutate.mjs` calling it as today) and add node tests that drive the real
   runner with `runProcess` on tiny `node -e` children:
   - a child that prints nothing and never exits -> verdict `timeout`, the run returns within the cap
     (cap ~1.5 s; assert the measured wall time is under, say, 5 s);
   - a child that prints `SCRIPT ERROR: Invalid call ...` then hangs -> `killed` via `crash`, returned
     shortly after the stop grace, not at the cap;
   - a child that prints `Parse Error: ...` then hangs -> `invalid`;
   - a child that prints the OK line and exits 0 -> `survived`; one that prints `bake_city: GOLDEN-DIFF c_01_00.bin ...`
     and exits 1 -> `killed` via `golden` detail `c_01_00.bin`.
   Spawn `process.execPath`, never Godot; keep the test under ~10 s total. If a spawned grandchild
   pattern is easy (node -e spawning a second sleeping node), include one case proving the grandchild
   is gone after the kill (the `_console.exe` -> engine child situation), checked by pid with
   `process.kill(pid, 0)`.
2. **Bake budget.** The full run's baseline took 20.7 s on this machine (CONTENDED) and set a 60 s
   per-mutant cap; a survivor does two full bakes, so a contention spike turns an honest survivor into
   a `timeout` (unscored, i.e. the score silently loses it). Make the bake budget 3x baseline with a
   floor of 120 s (tests keep 3x, 90-300 s). Update the test and the README sentence.
3. **README polish** (`tools/mutate/README.md`), short:
   - the Oracles section's example should be the plain lane command without `--max`
     (`--oracle=bake-check` on kerb_dresser) plus the combined form `--oracle=tests,bake-check`, and one
     sentence on which to pick: generators under `features/city/gen/` -> `tests,bake-check` (unit tests
     first, the golden list for what they miss) or `bake-check` alone when no test maps to the file;
   - say plainly that `bake-check` gives the same pass/fail as `bake_city.gd -- --check` (fail-fast only
     reorders: golden compare per chunk first, the determinism re-bake only if all chunks matched);
   - leave the measured numbers paragraph for me to update after the full run (keep it, mark nothing).
4. `project/dev/bake_city.gd`: your rewrite dropped the header that said what the no-flag run writes
   (`res://data/generated/city/c_XX_YY.bin` + `data/generated/city_chunks.sha256`) and that it is
   dev-only. Put that back in the doc comment (two or three lines). This is a doc-only change; it
   cannot be parse-checked now, so keep it to `##` lines only.

Done = commits for 1-4, `node --test "tools/mutate/*.test.mjs"` green (paste its summary line), and a
final message listing the commits.
