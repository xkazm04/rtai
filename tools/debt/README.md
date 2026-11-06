# Debt ratchet

Lint's hard caps (300-line files, 40-line functions) are enforced, but debt piles up right below
them. The ratchet makes each debt metric monotonic: `tools/debt/baseline.json` is the committed
ceiling, `node tools/lint/lint.mjs` runs it as the `debt-ratchet` check, and debt can only go down.

```
node tools/debt/debt.mjs                       report: totals + biggest offenders per metric
node tools/debt/debt.mjs --check               lint mode; exit 1 on any regression
node tools/debt/debt.mjs --update              rewrite the baseline (refuses to RAISE anything)
node tools/debt/debt.mjs --update --accept-regression="why"   record a deliberate increase
node --test "tools/debt/*.test.mjs"
```

## Metrics

Own code means `project/` minus `addons/` (plus `tools/canary.gd`), as `ownGdFiles` in
`tools/lib/repo.mjs`. Line counts match `tools/style/check_gd.mjs` (`split('\n')`, trailing
newline not counted). Every metric stores per-file values; the total shown is a file count for the
`files_*`, `lane_*` and `unused_*` metrics, and a sum for `direct_cmdline_reads` and `dev_loc`.

| Metric | Offender (per-file value) |
|---|---|
| `files_near_cap` | `.gd` file with >= 270 lines (its line count) |
| `files_past_soft_cap` | `.gd` file with > 200 lines (its line count). This is exactly the one soft warning `check_gd.mjs` emits, so there is no separate soft-warnings metric: it would count the same files twice |
| `direct_cmdline_reads` | `.gd` file calling `OS.get_cmdline_args` / `OS.get_cmdline_user_args` in code (comments ignored), except `boot/launch_args.gd` and `boot/arena_args.gd` (count of calls). The report splits shipped (`boot/ core/ features/ quests/`) from dev and tests |
| `dev_loc` | `.gd` lines under `project/dev/`, per top-level entry (a dir, or a loose file) |
| `lane_named_dev_dirs` | `project/dev/<dir>` that has a lane/day-style name (`n7_...`, `w2...`, `night...`, `lane...`, `day3`, a date) OR that nothing outside itself references, by the path `res://dev/<dir>/` (any project file, `tools/*.mjs`, `justfile`, `AGENTS.md`) or by a `class_name` declared inside it |
| `unused_class_names` | `.gd` file whose `class_name` appears (as a whole identifier, comments ignored) in no other `.gd/.tscn/.tres/.json/.godot` file. GDS-06: a class_name is only for scripts others use as a type; scripts loaded by path do not need one, so delete the `class_name` |

## What fails

A metric regresses when a per-file value goes up (`x.gd grew from 271 to 284 lines`), or a file
newly appears in a list (`NEW x.gd (271 lines)`). The check names metric, file, old -> new.
Improvements never fail; the check prints `tighten: run node tools/debt/debt.mjs --update` when the
tree is better than the baseline. Separately it warns (never fails) about the split-to-the-cap
pattern: a file that was >= 290 lines in the baseline, now < 300 but freed fewer than 20 lines.
Split for real.

Stored totals in the baseline are informational; the check recomputes them from the per-file
lines, so two branches that tightened different files merge cleanly (one entry per line, sorted).

## Agent workflow

- Ratchet failure: you made something worse. Fix the cause named (shrink the file, route the read
  through `LaunchArgs`, delete the unused `class_name`, wire or delete the dev folder).
- You improved something (the check says `tighten`): run `node tools/debt/debt.mjs --update` and
  commit the baseline with your change. It can only tighten.
- A deliberate increase (rare): `--update --accept-regression="reason"`. The reason is stored with
  the date under `accepted` for that metric, so the debt stays visible in review.
- Merge conflict in `baseline.json`: take either side, then run `--update`. It rewrites the baseline
  to the merged tree and can only tighten; if it refuses, the merged tree is worse than the side you
  took for the files it names, so fix those (or take the other side). Never hand-edit numbers upward.
- A baseline TIGHTER than your tree (another branch tightened, you re-added debt) fails on your
  branch: that is a correct regression, not noise.
