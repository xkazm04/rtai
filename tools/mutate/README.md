# tools/mutate - "do my tests bite on this file?"

Real mutation testing for one GDScript file (STANDARDS TST-05). It plants single-line faults in the
file, runs the tests that cover it, and reports which faults the tests noticed.

```
node tools/mutate/mutate.mjs --file=core/save/gtsv_container.gd [--max=25] [--ops=cmp_flip,boundary]
                             [--tests=test_gtsv_container,test_save_facade] [--timeout=90] [--json]
                             [--worktree=<path>] [--remove-worktree]
just mutate --file=core/save/gtsv_container.gd --max=25
```

- `--file` is project-relative (`core/...`, `features/...`); tests and addons are refused.
- `--tests` takes test basenames. Without it the tests come from `tools/tests/test_map.mjs`
  (class_name / res:// mentions + the `test_<basename>.gd` twin), minus the slow tier. If the map says
  FULL suite the run stops and asks for `--tests` (1,400 tests per mutant is not acceptable).
- `--max=N` samples N mutants, deterministically (seeded by the file path, source order kept).
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

| verdict | meaning |
|---|---|
| killed | a mapped test failed (or the mutant crashed at run time in a way the clean file does not) |
| survived | every mapped test passed: the tests do not notice this fault |
| timeout | the per-mutant cap hit (default 3x the baseline, 90-300 s); the tree was killed. Usually an infinite loop the mutant created, which counts as noticed but is not scored |
| invalid | the mutant does not compile (a `Parse Error` / `Failed to load script`): not a test result, left out of the score |

Before the first mutant the mapped tests run on the unmutated file; red means "baseline red", nothing
is mutated.

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

## How a lane uses it

Before claiming "planted faults caught", run mutate on the file you changed and quote the score:

```
git commit ...                       # mutate sees HEAD
node tools/mutate/mutate.mjs --file=features/combat/ai/enemy_pit.gd --max=25
```

Quote `file, mutants, killed/survived/invalid/timeout, score` in the ticket. Read the survivors: each is
either an equivalent mutant (no observable change), a real test gap (name the missing test), or dead
code. A hand-written negative control is still worth keeping, but it is not a score.

Cost: about 6.5 s per mutant for small focused tests (a Godot start + import step per mutant), so 25
mutants is ~3 minutes and a full 43-mutant file ~5 minutes.

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
