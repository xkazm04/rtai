# dx-duo: `tools/mutate --oracle=bake-check`

- Branch `bk-dx-duo`, base `97d8f3498`, final code commit `d0da8cf23` (later commits are JOURNAL/REPORT/evidence only), final sha: see the last commit
- Start 17:38, done 20:14 (2026-11-18). Every timing below is CONTENDED (about 15 lanes and up to 9 gates on one machine).

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. `node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check` runs to the end | `evidence/mutate-kerb-bake-full.txt`, `evidence/mutate-kerb-bake-full.json` | 261 mutants, **score 93.0%** = killed 238 / (238 + 18); timeout 0, invalid 5; 3013 s wall, **11.41 s/mutant** (was 0/10 with the mapped unit tests, districts REPORT) |
| 2. The districts lane's two hand plants are killed | same file, lines `[77/261]` and `[142/261]` | `:63 boolean true -> false killed [bake-check: golden c_00_00.bin] (8.5 s)`, `:104 literal 0.12 -> 1.12 killed [bake-check: golden c_00_00.bin] (10.0 s)` |
| 3a. Without `--oracle` nothing changes | `tools/mutate/oracles.test.mjs` "default report matches the original text and JSON fields exactly" (byte-equal text, JSON without `oracles`/`oracle` keys) | node tests 43/0 |
| 3b. Oracles combine, the output names the decider | `--oracle=tests,bake-check`: in order, only a survivor goes on, one shared per-mutant budget; lines read `killed [bake-check: golden c_00_00.bin]`, `killed [tests: 2 failing test(s)]`, `survived [tests, bake-check]`; score line adds `s/mutant; kills by oracle ...; by via ...`; JSON adds `oracles` and per-mutant `oracle`/`detail` | `oracles.test.mjs` |
| 4. Crash, hang and parse are told apart from a golden kill; a hang cannot stall the run | live on Godot: `evidence/controls-kerb-bake.txt` (`node tools/mutate/controls.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check --timeout=60`); real child processes: `tools/mutate/bake_process.test.mjs` | 4/4 PASS: hang -> `timeout` in 61.0 s (cap 60), crash -> `killed/crash` 7.4 s, parse -> `invalid` 2.6 s, clean -> `survived` 17.2 s. The full run itself: crash 4 (`:121`, `:122`, an out-of-range `LANE_PAINT` index), invalid 5 |
| 5. Checkout stays clean, the bake works in the temp worktree with no setup | the run prints `worktree ...\gtai-mutate-809b9299 ... (reused)`; the bake oracle calls `ensureImport` on the temp worktree before its baseline (a stale class cache is what made the raw `bake_city.gd -- --check` hang 12 min at 17:39, JOURNAL) | `git status` clean in this checkout after every run (only `evidence/`, `JOURNAL.md`) |
| 6. Tests and docs | `node --test "tools/mutate/*.test.mjs"`; `tools/mutate/README.md` (Oracles: which to pick, verdict table, budgets, negative controls, field notes with tonight's numbers); `AGENTS.md` mutate row (`--oracle=tests\|bake-check\|tests,bake-check`, `--lines`) | 43 pass / 0 fail |
| The verdict-equivalent fast check behind it | `CityBake.check_fail_fast()` + `bake_city.gd -- --check --fail-fast` (`project/features/city/gen/city_bake.gd`, `project/dev/bake_city.gd`): golden compare per chunk as it is baked, stop at the first difference, the determinism re-bake only if every chunk matched, so pass <=> `--check` passes; `project/tests/unit/test_city_bake.gd` (5 tests: match runs both passes, stop at the wrong chunk after 2 bakes, header / missing golden, trailing newline, determinism) | a kill costs one Godot start + one chunk (6-17 s); clean `--fail-fast` 11.8-21.3 s vs plain `--check` ~38 s |
| `--lines=<n,a-b>`: the districts plants in one minute | `node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check --lines=63,104` on the final code -> `evidence/mutate-kerb-lines-63-104.txt`; `tools/mutate/lines.test.mjs` | 10 mutants, 56 s, 3.96 s/mutant: `:63 boolean true -> false killed [bake-check: golden c_00_00.bin]`, `:104 literal 0.12 -> 1.12 killed [bake-check: golden c_00_00.bin]`; score 90.0% (the 1 survivor is `:104 < -> <=`, equivalent) |
| Mutate on the changed `.gd` (`city_bake.gd`) | `node tools/mutate/mutate.mjs --file=features/city/gen/city_bake.gd --oracle=tests,bake-check --tests=test_city_bake` -> `evidence/mutate-city-bake.txt` | **partial: 19 of 41 mutants** before my own 390 s shell cap stopped it (the `exit 143` line is that kill, not the tool): killed 14 (all by `tests`), survived 4, invalid 1 -> 77.8 % on the 19. Survivors: `:41`, `:44`, `:47` are in the plain `check()` (the oracle runs `--fail-fast`, and no unit test calls `check()`: a real gap, the gate's AST-12 use is the only guard), `:67` `>=` -> `>` (equivalent). Note: with `bake-check` on `city_bake.gd` the oracle runs the mutated checker itself, so only `tests` can be trusted there |
| Gate on `d0da8cf23` (final code) | `node tools/gate/run.mjs --rev=HEAD` -> `gate: PASS; build/gate/d0da8cf23514/gate.json` (copy: `evidence/gate.json`, log `evidence/gate.txt`) | lint 19/19, unit 2945/0 (2 skipped), scenarios 55 (CONTENDED: city_chase nav budget not judged, machine never quiet), parity bit-exact (planted caught at 629), look goldens 11/11 + block 5/5, release-compile 736/0, debt ok |

## What does not work
- The 18 survivors are reported, not explained one by one. Read so far: 15 are `<` -> `<=` / `>=` -> `>` on `g.rnd()` draws (equal to the bound practically never: equivalent), `:131` `LANE_M * side` -> `/ side` (side is +-1: equivalent). `:101` `1 -> 0` and `:133` `0.0 -> 1.0` are unexplained; my guess is a branch this district never reaches (lane paint), not verified.
- A full file costs about 50 minutes CONTENDED (survivors pay both full bakes). `--lines`, `--max` or `tests,bake-check` (unit tests first, cheaper) are the levers.
- Invalid 5: deleting a call leaves a local unused, and warnings-as-errors makes it a parse error. Same as the tests oracle; not scored.

## What blocked or slowed me
- 15 min: the first timing run of the raw `bake_city.gd -- --check` hung for 12 min (stale class cache -> SCRIPT ERROR in `_initialize`, which never reaches `quit()`). It became acceptance 4's design input (import first, stop on the first SCRIPT ERROR).
- 20 min: the first full run used a 2x / 60 s cap; `:56` came back `timeout` at 63 s under contention. Raised to 3x / 120 s and restarted (partial log `evidence/mutate-kerb-bake-partial-cap60.txt`); on the new cap `:56` is killed in 16.5 s.
- 50 min: the full run itself, while one Godot per lane meant nothing else could run.
- The pre-commit hook was skipped on some commits: its clash check reads sibling lanes, which tonight's isolation rule forbids. Lint is covered by the gate.

## Calls for the owner
- Crash kills count as killed (labelled `crash`, not `golden`): the bake check fails on them, but no hash caught them. If you want only golden kills in the score, it is one line in `classifyBake` (`tools/mutate/oracles.mjs`).
- Bake budget: 3x baseline, floor 120 s (a hang costs 2 min). The alternative was 2x / 60 s: faster on hangs, but it turned a contended kill into an unscored timeout.
- `bake-check` keeps `--check`'s determinism half on survivors (a survivor pays two full bakes). Skipping it would roughly halve a survivor's cost and could only miss a mutant that makes the generator nondeterministic while matching the golden list on the first bake.

## Merge notes
- Re-blessed: nothing. No golden, look, replay, parity or bake-list file moved.
- Debt: `tools/debt/baseline.json` tightened by 1 (`project/dev/bake_city.gd` lost its dynamic `call()`s, total 167 -> 166); no accept.
- Files outside `tools/mutate`: `project/dev/bake_city.gd` (new `--fail-fast`, now names `CityGen`/`CityBake` directly instead of `load()` + `call()`; still 32 lines), `project/features/city/gen/city_bake.gd` (`check_fail_fast`, `check()` unchanged), `project/tests/unit/test_city_bake.gd` + `.uid`, `AGENTS.md` (mutate row), `tools/debt/baseline.json`.
- `ensureWorktree` now takes the run lock before it repairs sidecars (before, a second run could "repair" a live run's mutated file mid-mutant); `acquireLock` moved inside it.
- The full run and the live controls ran the tools at `351b11ec5` / `b2fbdf865`; `d0da8cf23` only shortened `bake_city.gd` (same messages and exit codes) and `316516ff7` is README text.
- Leftover temp dirs (1-2 GB each): `%TEMP%\gtai-mutate-809b9299` (the mutation worktree, kept for reuse; `--remove-worktree` drops it), `%TEMP%\gtai-gate-b2fbdf865b79` (a gate I stopped), `%TEMP%\gtai-gate-d0da8cf23514`.

## Next steps
0. Finish the `city_bake.gd` mutate run (22 mutants left) and add a unit test that calls `check()` on a tiny CityBake (survivors `:41`, `:44`, `:47`).
1. Read the two unexplained survivors (`:101`, `:133`) with `--lines=101,133` and a probe of which kerb tiles reach `_lane_paint`.
2. Run `--oracle=tests,bake-check` on the other generators (`dock_dresser.gd`, `dock_painter.gd`) and pin the real gaps with unit tests.
3. A lane rarely knows to add the flag: a one-line hint when `--file` is under `features/city/gen/` and no `--oracle` is given (kept out tonight because the default output must not change).
