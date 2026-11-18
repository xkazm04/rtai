# tools/mutate - "do my tests bite on this file?"

Real mutation testing for one GDScript file (STANDARDS TST-05). It plants single-line faults in the
file and reports which faults the selected checks caught.

```
node tools/mutate/mutate.mjs --file=core/save/gtsv_container.gd [--max=25] [--ops=cmp_flip,boundary]
                             [--tests=test_gtsv_container,test_save_facade] [--timeout=90] [--json]
                             [--oracle=tests,bake-check] [--worktree=<path>] [--remove-worktree]
                             [--lines=<n,a-b>]
just mutate --file=core/save/gtsv_container.gd --max=25
```

- `--file` is project-relative (`core/...`, `features/...`); tests and addons are refused.
- `--tests` takes test basenames. Without it the tests come from `tools/tests/test_map.mjs`
  (class_name / res:// mentions + the `test_<basename>.gd` twin), minus the slow tier. If the map says
  FULL suite the run stops and asks for `--tests` (1,400 tests per mutant is not acceptable).
- `--max=N` samples N mutants, deterministically (seeded by the file path, source order kept).
- `--lines` selects source lines and inclusive ranges before `--max` samples them, as in `node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check --lines=63,104`.
- `--json` writes `build/mutate/<file-slug>.json` (`gtai.mutate/1`, canonical JSON) in the main checkout.
- Exit 0 for every completed run (it is a measurement; the score is yours to judge), 2 for usage or
  infrastructure errors (including "baseline red").
- It mutates the file **as committed at HEAD** (and runs HEAD's tests): commit first.

## Output

```
core/save/gtsv_container.gd:45 arith  - -> +  survived
...
score 79.1% = killed 34 / (killed 34 + survived 9); timeout 0, invalid 0; 292 s
```

Survivors are listed first, then timeouts, invalid, killed. Score = killed / (killed + survived).

## Oracles

`tests` runs the selected unit tests and is the default. For generators under `features/city/gen/`,
use `tests,bake-check` to run unit tests first and catch what they miss with the AST-12 golden list,
or use `bake-check` alone when no test maps to the file.

```
node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check
node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=tests,bake-check
```

`bake-check` alone skips test mapping. It imports a fresh worktree and gives the same pass/fail
result as `bake_city.gd -- --check`. The oracle adds `--fail-fast` to reorder the checks. It compares
the header and each chunk against the golden list first, then byte-compares a second bake for
determinism only if all chunks matched. A script error stops the Godot process tree after a 1.5 s
grace period so a failed SceneTree initialization cannot hang the run.

With `--oracle=tests,bake-check`, only survivors reach the next oracle. List the names in the order
you want. Every selected oracle must pass on the original file before mutation starts.

| Verdict | What decided it |
|---|---|
| killed | Failed assertions (`tests`), golden-list drift (`golden`), different bytes on the second bake (`nondeterministic`), or a runtime script error (`crash`). |
| survived | Every selected oracle passed. The bake requires both exit 0 and its explicit OK line. |
| invalid | A parse, load or compile error. Excluded from the score. |
| timeout | The per-mutant deadline expired and the runner killed the process tree. Excluded from the score. |
| infrastructure failure | An unexplained exit or missing bake verdict stops the run with exit 2. A red baseline also exits 2. |

The tests budget is 3× baseline (90–300 s). The bake budget is 3× baseline (at least 120 s).
Combined runs share the sum of those budgets. `--timeout=N` sets the whole mutant's budget in seconds.
Explicit oracle reports give mean seconds per mutant excluding setup, and kills by oracle and cause.
JSON records the requested `oracles` in order and the last `oracle` reached by each mutant.

**Field notes: bake-check** (all runs CONTENDED, about 15 lanes on one machine). The full
`kerb_dresser.gd` run scored **93.0% = 238 / (238 + 18)** across 261 mutants, with 0 timeouts
and 5 invalid. It took 3013 s wall, averaging 11.41 s/mutant excluding setup. The earlier
mapped unit tests killed 0/10.

| Result | Observation |
|---|---|
| 238 kills | All 234 golden kills first differed in `c_00_00.bin` (one Godot start and one chunk, 6–17 s). Four mutants crashed at `:121` or `:122` by indexing `LANE_PAINT` out of range. |
| Districts hand plants | Both changed `c_00_00.bin`: `:63` `true -> false` (parked car shadow) and `:104` `0.12 -> 1.12`. |
| 18 survivors | The clean baseline took 21.3 s. Each survivor ran both full bakes (16–42 s). Fifteen `g.rnd()` changes (`<` to `<=` or `>=` to `>`) are effectively equivalent because a draw almost never equals the bound. At `:131`, dividing `LANE_M` by `side` equals multiplying by it (`side` is ±1). Two remain unexplained, `:101` `1 -> 0` and `:133` `0.0 -> 1.0`. The district may never reach those branches. |
| 5 invalid | Deleting a call at `:55`, `:68`, `:95`, `:133` or `:159` left an unused local. Warnings-as-errors made each a parse error. |
| Timeout floor | Deleting `busy.append` at `:56` timed out at 63 s with the old 2× budget and 60 s floor. The 3× budget with a 120 s floor let the oracle kill it in 16.5 s under contention. |
| Negative controls | All four passed with `--oracle=bake-check --timeout=60`. The hang timed out in 61.0 s, the crash was killed (`crash`) in 7.4 s, the parse error was invalid in 2.6 s, and the clean file survived in 17.2 s. |

## Negative controls

Run `node tools/mutate/controls.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check`
to check a hang, a runtime crash, a parse error and the clean file against the live oracle.
Pass `--timeout=60` for a 60-second cap. The hang must return within 15 seconds of that cap.

## Operators (one change, one line)

| op | change |
|---|---|
| `cmp_flip` | `<` `>=`, `>` `<=`, `==` `!=` (and back) |
| `boundary` | `<` `<=`, `>` `>=` (and back) |
| `arith` | `+` `-`, `*` `/`, and the compound forms (binary operators only) |
| `literal` | `n` -> `n+1`, `1` -> `0`, `0.0` -> `1.0` (decimals kept) |
| `boolean` | `true` `false`, `not X` -> `X`, `!X` -> `X`, `and` `or` |
| `delete` | a standalone one-line call statement -> `pass` (indentation kept) |
| `return` | `return X` -> `return not (X)`, only in `-> bool` functions and only for an obviously boolean X |

Never touched: comments, strings (masked first, incl. `"""` blocks), `##` docs, and any line of a
`const` / `enum` / `signal` / `class` / `func` declaration, `@export...`/other annotation lines,
`extends`, `class_name` (data and signatures are noise). Never deleted: `Log.*`, `print*`, `push_*`,
`assert`, `return`, `var`, control flow, `await`, `super`. Lines under `@warning_ignore` are mutated
like any other (a mutant that trips a warning shows as invalid). Unary signs, `->`, and `$Node/Path`
slashes are not arithmetic. Same file + same HEAD = same mutants in the same order.

## The mutation worktree and its safety rules

All mutation happens in a dedicated `git worktree` at the main checkout's HEAD:
`<os tmpdir>/gtai-mutate-<8 hex of sha1(main root)>` (Windows: `%TEMP%\gtai-mutate-xxxxxxxx`),
stamped with `.gtai-mutate-worktree` right after creation. It is reused between runs (the `.godot`
import cache stays warm; only the first run pays the import, ~35 s here); a run checks it out to the
current HEAD, copies `project/native/bin/*` and `project/override.cfg` in from the main checkout
(read-only on the source side) and runs `<wt>/tools/tests/run_unit.mjs`, so every ROOT resolves to
the worktree. `GODOT_BIN` is passed on from the main checkout's discovery.

- The tool never writes to or deletes in the main checkout's `project/` or any lane worktree
  (`C:/Users/kazda/kiro/gtai-wt/*`). The main checkout only receives `build/mutate/<slug>.json`.
- The only removal is `git worktree remove --force <exact path>` + `git worktree prune`
  (`--remove-worktree`), and only if the marker exists and belongs to this checkout, the real path is
  strictly under the OS temp dir, and it is not the repo root, not inside it, not under `gtai-wt`.
  Every refusal is proved in `worktree.test.mjs` with fixture paths. No `rm -rf` anywhere.
- Restoring a mutated file rewrites it from the original bytes (kept in memory and in a
  `<file>.gtai-orig` sidecar), then byte-compares. A hard crash (kill -9, power) leaves the sidecar;
  the next run restores it first and prints `REPAIRED a crashed run`. Tracked changes in the worktree
  are repaired with `git -C <wt> checkout -- <path>`, other untracked files are left alone and named.
- One run per worktree (`.gtai-mutate-lock`, a pid lock; a dead pid's lock is taken over). Use
  `--worktree=<other path under tmp>` for a second parallel run. `--keep-worktree` is accepted and is
  the default; `--remove-worktree` deletes it at the end.
- A kept worktree costs disk: about 1.7 GB each (checkout plus its `.godot` cache; `du`, 2026-11-10,
  both `%TEMP%\gtai-mutate-874f1762` and `-a1e1f612`). There is one per checkout root that ran mutate
  (the suffix hashes that root), so mutating from several lane worktrees keeps several. Pass
  `--remove-worktree` on your last run of the night; the run prints the path at its start.

## How a lane uses it

Before claiming "planted faults caught", run mutate on the file you changed and quote the score:

```
git commit ...                       # mutate sees HEAD
node tools/mutate/mutate.mjs --file=features/combat/ai/enemy_pit.gd --max=25
```

Quote `file, mutants, killed/survived/invalid/timeout, score` in the ticket. Read the survivors: each is
either an equivalent mutant (no observable change), a real test gap (name the missing test), or dead
code. A hand-written negative control is still worth keeping, but it is not a score.

## Field notes

First real run: `core/save/gtsv_container.gd` (105 lines), tests `test_gtsv_container` +
`test_save_facade` (`test_save_slots` is slow tier): 43 mutants, 34 killed, 9 survived, 0 invalid,
0 timeout, score 79.1%, 292 s wall (first-ever run incl. worktree creation and a 33 s import: 67 s for
3 mutants).

Survivors, read against the code and the tests:

- `:29` col 68, `JSON.stringify(envelope, "", true, true)`, last `true` -> `false` (full_precision).
  **(b) real test gap, and a save-integrity one.** Without full precision Godot writes floats with
  about 14 significant digits, so a stored float such as a playtime or a position loses its low bits (per the Godot docs)
  on the way to disk. The sort_keys `true` on the same line was killed, so encode's byte stability is
  tested, float exactness is not. Missing test, in `test_gtsv_container.gd`:
  `test_encode_keeps_full_float_precision` (encode an envelope body holding `0.1 + 0.2` and
  `1234567.8901234567`, decode, `assert_eq` the exact floats).
- `:45`, `as_int`: `-1.0` -> `+1.0`, `1.0` -> `0.0`. **(b) real test gap.** The docstring promises
  `-1` for anything that is not a number; no test calls `as_int` with a String/null or reads
  `Decoded.seq()` of a failed decode (empty envelope). Missing test:
  `test_as_int_is_minus_one_for_non_numbers`.
- `:60`, `bytes.size() < HEADER_SIZE` -> `<=`. **(a) equivalent for the verdict:** a header-sized blob
  with no payload fails either here ("shorter than the header") or a few checks later (hash mismatch),
  `Kind.CORRUPT` both ways. Only the `reason` text differs, which no test asserts.
- `:95` `or` -> `and`, `:98` `or` -> `and` and `< 0` -> `<= 0` / `0` -> `1`: **(b)** no test sends an
  envelope where exactly one of save_version/seq is bad, or `seq: 0` (a valid first save).
- `:103` `==` -> `!=` only changes the `reason` string of a NEWER save_version: untested text.

No dead code found in this file.
