# Brief 03: `--lines=` for targeted re-checks, and a live negative-control script (node only)

Same worktree, branch and repo law as briefs 01/02. Commits 376d276b4..351b11ec5 accepted.

**Still no Godot in this session**: the full 261-mutant run holds the arm's one Godot slot until ~19:25.
Node-only work, `node --test`, `node tools/gate/quick.mjs --no-godot --no-clash` are fine.
Code must be final by 19:20 (I gate after the full run), so keep this small.

## 1. `--lines=<n,...>` in mutate.mjs
A lane that wants to re-check a few known mutants (the districts lane's two hand plants at
`kerb_dresser.gd:63` and `:104`) today must run all 261. Add `--lines=63,104` (comma list of positive
ints, also ranges `40-60`): keeps only mutants on those source lines, applied **before** `--max`
sampling (so `--lines` + `--max` samples within the lines). Unknown/malformed -> UsageError; a list that
matches no mutant -> UsageError naming the lines and the nearest lines that do have mutants.
Absent = today's behaviour, output byte-equal (the golden-output test must stay as is). Tests in the
existing style (parseArgs + the filter as a pure exported function). README: one line in the usage
block and one sentence, with the example
`node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check --lines=63,104`.
AGENTS.md mutate row: add `[--lines=<n,a-b>]` to the flag list only.

## 2. `tools/mutate/controls.mjs`: live negative controls for an oracle (do NOT run it)
A small dev script I will run after the full run, proving acceptance item 4 on the real engine:
`node tools/mutate/controls.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check`
- Uses `ensureWorktree` + `acquireLock` + `writeSidecar`/`restoreFile` exactly as mutate.mjs does (the
  same temp worktree, same safety law, file restored and byte-verified after every control, sidecar
  removed, lock released on any exit), then the same `oracleRunners` + `baseline` for the timeout.
- Plants three hand-written faults, one at a time, each inserted as the first statement of the first
  `func` body of the file whose body is indented with one tab (find it by regex; fail with a usage error
  if none):
  - `hang`: `while true: pass` -> expect `timeout`, and the wall time must be <= cap + 15 s;
  - `crash`: `var _crash: Array[int] = []` + `_crash[1] = 0` (two lines, a run-time index error)
    -> expect `killed` via `crash`;
  - `parse`: `var = ` -> expect `invalid`.
  Plus the unmutated file as a 4th control -> expect `survived`.
  Pick these so they are valid for GDScript's warnings-as-errors where they must be (crash must parse:
  check `_crash` naming rules for unused vars; use the var).
- Prints one line per control: `control <name>: expected <verdict/via> got <verdict/via> in <s> s  PASS|FAIL`,
  and exits 0 only if all four PASS (1 otherwise, 2 usage/infra). `--timeout=<s>` overrides the cap
  (I will pass `--timeout=60` to keep the hang short).
- Pure parts (the fault planting into a source string, the expected-vs-got judging) are exported and
  have node tests in `tools/mutate/controls.test.mjs`. Keep the file under ~150 lines.
- README: a short "Negative controls" paragraph with the command.

Done = commits, `node --test "tools/mutate/*.test.mjs"` green (paste the summary), final message with
the commit list. Do not run Godot.
