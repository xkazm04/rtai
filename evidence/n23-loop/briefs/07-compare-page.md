# Brief 07 `compare-page`: the before and after page (lane loop, n23)

Hard stop: 07:50 wall clock (the call is stopped at 75 min, but stop by 07:50). Commit deadline: 07:45. Commit each step as it lands.
Fix lint and format findings in your own edit and go on.

## Why

The owner judges tonight by "the before page and the after page side by side" and wants it as a readable page that is filmed.
Tonight's batches exist as `batch.json` + `runs/*.json` (`gtai.gauntlet-run/1`) and each has a `report.md` from
`tools/gauntlet/report.mjs`, but nothing puts two or more of them side by side.

## Work, in order (commit each)

1. **`tools/gauntlet/compare.mjs`** (+ small helper modules if a file would pass ~200 lines): 
   `node tools/gauntlet/compare.mjs --arm=<label>=<abs batch.json> --arm=<label>=<abs batch.json> [...] [--targets=tools/gauntlet/targets.json] --out=<abs path without extension>`
   writes `<out>.md` and `<out>.html`. Reuse `loadBatch` (`report.mjs`), `death_score.mjs` (censored runs at the wave limit are lower bounds, written `>= 40`), `survival.mjs` where they fit; do not re-derive what they already compute.
   Per arm, per profile (novice / average / expert, only those present), one row each:
   - runs, lethal deaths, censored (alive at the wave limit or the tick cap), timeouts with no result;
   - death wave median, P25..P75 (censored runs count at their limit and the cell says `>=` when the median is censored);
   - the profile's target from `targets.json` and the miss (median minus target, `>=` when censored);
   - median wave seconds in bands 1-4, 5, 6-10, 11-20, 21-30, 31-40 (boss waves 5/10/15/... as their own column "boss waves" median); target 15 s for average, 25-30 s boss;
   - median damage taken per second and median repair share (from the `hp` telemetry when present; "not measured" when absent, never 0);
   - top three killers with counts.
   A **separation** block per arm: novice vs average, average vs expert: gap of medians and share of shared seeds where the deeper profile died later (the rule in `targets.json`; censored-vs-censored counts as not separated).
   The HTML is one self-contained file (inline CSS, no script, no external fonts or images), readable at 1920x1080 at 100 % zoom: dark background, large type (body >= 20 px), arms as columns side by side, a short header line per arm with its label, commit SHA from the manifest, seeds, profiles, `--waves`, pick, controls. The game's colour rule applies to the page too: no red anywhere (red is blood only), never teal (souls only); amber for misses, a neutral light for values.
   Values that were not measured print `not measured`.
2. **Tests** `tools/gauntlet/compare.test.mjs` on small fixtures (reuse `tools/gauntlet/fixtures/` or add a minimal one there): censored median prints `>=`, a missing `hp` prints `not measured`, separation of a censored pair is "not separated", two arms produce two columns, refusal of an `--arm` without `=` or a missing file (exit 2, one line).
3. **Run it** on tonight's batches (read only, absolute paths under `C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n23-loop/`):
   `--arm=main=base-greedy/batch.json --arm=street=base-street/batch.json --arm=merged=moves/on/batch.json --arm=cycle1=cycle1/after/batch.json --out=C:/Users/kazda/kiro/gtai-wt/n23-loop/build/n23/compare`
   (`base-greedy` is 20 seeds, 72000-tick cap, no wave limit: its arm header must say so; the others are 10 seeds, `--waves=40`). If `moves/on/batch.json` or `cycle1/after/batch.json` does not exist yet when you get there, leave that arm out and say so. Paste the markdown table of the result in your final message. Do NOT write under `evidence/`: the director copies the page there.
4. `docs/gauntlet-loop.md`: one short paragraph "Comparing batches" with the command.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green (quote the count); `node tools/lint/lint.mjs` green.
- **Node only: no Godot process of yours at all** (the director's batches hold the lane's two Godot slots).

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`. Never kill a process you did not start. Do not touch `C:/Users/kazda/AppData/Local/Temp/gtai-loop-street`, any `gtai-ablate-*` worktree or anything under `evidence/` (the director's running batches write there). Never touch another lane's worktree.

## Files

Allowlist: `tools/gauntlet/**`, `docs/gauntlet-loop.md`, and output under `build/n23/`. Any other path: stop and report a NEED.
Forbidden: every table under `project/data/`, `project/**`, `JOURNAL.md`, `REPORT.md`, `evidence/**`, `docs/decisions.md`, other worktrees.

## Repo law

Staged per path (`git commit -- <paths>`); no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`. Files about 200 lines (hard 300), functions <= 40 lines, <= 5 params.

End with: files changed, commits, commands and results, anything not done and why.
