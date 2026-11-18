# Brief 01: `--oracle=bake-check` for tools/mutate (build it, test it, document it)

You work in this git worktree (cwd), branch `bk-dx-duo`. Read `AGENTS.md` (top rules), then
`tools/mutate/README.md`, `tools/mutate/mutate.mjs`, `report.mjs`, `worktree.mjs` and their `*.test.mjs`,
`project/dev/bake_city.gd`, `project/features/city/gen/city_bake.gd`, and `runProcess` / `runGodot` /
`ensureImport` / `killTree` in `tools/lib/godot.mjs`. Do NOT read any other `C:\Users\kazda\kiro\gtai-wt\bk-*`
worktree, never push, never touch `main` or `C:\Users\kazda\kiro\gtai`.

## Why
`mutate.mjs` judges a mutant only by the unit tests mapped to the file. City generators are guarded by
the AST-12 golden hash list instead (`bake_city.gd -- --check`), so `features/city/gen/kerb_dresser.gd`
scored 0/10 although its real guard catches most faults. Two hand-planted faults that the bake check
catches (and unit tests do not): `kerb_dresser.gd:63` `b.add(ChunkBuild.L_PROP, car, p, r, true)` true -> false,
and `:104` `< 0.12` -> `< 1.12` (the `literal` operator).

## Goal
`node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check` : a mutant
is killed when the bake check fails on it.

## The hard constraint: run time
kerb_dresser.gd has **261 mutants**. One plain `bake_city.gd -- --check` does two full bakes of 256
chunks + a golden compare; 261 x that is impossible on this contended machine, so the oracle needs a
fast, verdict-equivalent check.

What I saw when I ran the raw command in this checkout (`"$GODOT_BIN" --headless --path project -s
res://dev/bake_city.gd -- --check`, no `--import` first): `SCRIPT ERROR: Invalid call. Nonexistent function
'from_tables (via call)' in base 'GDScript'. at: _initialize (res://dev/bake_city.gd:19)` and then the
process **hung for 12 minutes** until my shell killed it (a SceneTree `_initialize` that errors never
reaches `quit()`). I assume a stale class cache (the raw command skips the launcher's `ensureImport`); find
out and make sure the oracle path never hits it. Both lessons go into the oracle: import first, and
kill on the first SCRIPT ERROR. Measure a correct baseline `--check` yourself and report its time.

Build this:

1. `project/dev/bake_city.gd` gets a second flag `--fail-fast` (only valid with `--check`; add it to
   `KNOWN_FLAGS`; usage comment updated). `CityBake` gets a method (e.g. `check_fail_fast() -> String`)
   with **the same verdict as `check()`**, cheaper on failure:
   - parse the committed golden list once; bake chunk by chunk in the same row-major order and compare
     each chunk's sha256 with its golden line **as soon as it is baked**; stop at the first mismatch
     (message names the chunk, e.g. `c_03_00.bin differs from the golden list`), also fail on the header
     line (generator version) and on a missing golden;
   - only when every chunk matched, do the second bake and byte-compare it with the first (the
     determinism half of `check()`), so pass <=> `check()` passes.
   - Print one machine-readable verdict line to stderr, e.g. `bake_city: GOLDEN-DIFF c_03_00.bin ...` /
     `bake_city: NONDETERMINISTIC ...` / `bake_city: OK deterministic, matches golden`, exit 0/1 like
     `--check`. Keep `check()` and plain `--check` behaviour and output as they are (the gate uses it).
   - GDScript law: typed, functions <= 40 lines, file ~200 lines (hard 300), `Log`/`printerr` as the file
     already does, no new RNG. A unit test in `project/tests/unit/` for the fail-fast method (e.g. a
     tiny CityBake with `chunks` = 1 or 2 against a hand-made golden text: match passes, a wrong sha fails
     naming the chunk, a wrong header fails). Commit the `.uid` of any new `.gd`.
2. `tools/mutate`: a new module (e.g. `tools/mutate/oracles.mjs`) so `mutate.mjs` stays small:
   - `--oracle=<list>`, comma-separated, known values `tests` and `bake-check`, in the order given;
     **absent = `tests` = today's behaviour and today's output byte for byte** (text and `--json`).
   - `bake-check` only: no test mapping at all (no FULL-suite refusal, no `pickTests`).
   - `tests,bake-check`: run the oracles in order per mutant, stop at the first that kills; a mutant
     that survives one oracle goes to the next. Each mutant line and the JSON say which oracle decided it,
     e.g. `killed [bake-check: golden c_03_00.bin]`, `killed [tests: 2 failing test(s)]`,
     `survived [tests, bake-check]`. JSON: add `oracles` (top level) and per mutant `oracle` only when
     `--oracle` was given (so the default JSON is unchanged).
   - Bake oracle run: `<GODOT> --headless --path <wt>/project -s res://dev/bake_city.gd -- --check --fail-fast`
     with `cwd` = the mutation worktree (use `runGodot(..., { cwd: wt })` or `runProcess` + an explicit
     `ensureImport({ projectDir: <wt>/project })` first, so a fresh worktree is imported without a manual
     step). Pass `stopOn` so a `SCRIPT ERROR` / `Parse Error` kills the tree within a short grace (a
     SceneTree script that errors never reaches `quit()`, i.e. it would hang), and a per-mutant timeout
     that tree-kills (derive it from the baseline bake, e.g. 2x baseline, min 60 s; `--timeout` overrides).
   - Bake verdicts, each told apart in the output (`via`):
     - `killed` via `golden` (GOLDEN-DIFF line) or `nondeterministic`;
     - `killed` via `crash` (a SCRIPT ERROR at run time; the bake check fails, so it is noticed, but it
       is labelled crash, not golden);
     - `invalid` (Parse Error / Failed to load script / compile error: not scored, as today);
     - `timeout` (the cap hit; tree killed; not scored, as today);
     - `survived` (exit 0 with the OK line);
     - anything else (non-zero exit with no verdict line and no error) -> infra failure, exit 2, as today.
   - Baseline: before the first mutant, every chosen oracle runs on the unmutated file; red =
     "baseline red", nothing mutated (as today). Note its duration and the per-mutant timeout.
   - The score line also prints seconds per mutant (mean), and, when an oracle is given, the kill count
     per oracle and per via (golden / crash / tests...).
3. Tests (`node --test "tools/mutate/*.test.mjs"` green): new tests for argv parsing of `--oracle`
   (unknown value -> UsageError; absent -> `['tests']`), bake output classification on canned outputs
   (golden, nondeterministic, crash, parse, timeout, ok, unexplained exit -> infra), the combined
   ordering and the "which oracle" labels, and a golden-output test that the default report text is
   unchanged. Pure functions, no Godot in node tests.
4. Docs: `tools/mutate/README.md` (a section "Oracles": what each judges, the verdict table, cost per
   mutant, when to use `bake-check`: city generators under `features/city/gen/`), and the `AGENTS.md`
   mutate command row (mention `--oracle=tests|bake-check|tests,bake-check`). Keep it short.

## Repo law
- Commit per change, stage per path (`git add <path>`); never `git add -A/./-u`, `git stash`,
  `reset --hard`, `commit -a`. Plain commit messages (`mutate: --oracle=bake-check ...`), no
  attribution or model names anywhere (the work is judged blind).
- Before Godot or gate runs: `export APPDATA=C:/Users/kazda/kiro/gtai-bake/appdata/dx-duo` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
  One Godot process at a time; kill only your own PIDs (`taskkill /F /T /PID <pid>`), never by name.
- Use `node tools/gate/quick.mjs` before commits, `node tools/godot/check.mjs res://dev/bake_city.gd`
  for parse checks, `node tools/tests/run_unit.mjs --select=<test basename>` for your GDScript test.
- Do not run the full gate, the bench, reels or exports. Do not edit `docs/decisions.md`, `JOURNAL.md`
  or `REPORT.md` (mine).

## Done for this brief
- Commits on the branch: the GDScript fail-fast check + its unit test; the mutate oracle + node tests;
  docs.
- Measured by you: `bake_city.gd -- --check --fail-fast` time on the clean tree and on a tree with
  `:63` true -> false planted by hand **in the mutation worktree or a scratch copy, never in this checkout
  uncommitted** (or simply via mutate below).
- A smoke run: `node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check --max=4`
  runs to the end. Paste its full stdout and the seconds per mutant in your final message.
- Final message: commits (sha + one line each), what you measured, anything you were unsure of.
