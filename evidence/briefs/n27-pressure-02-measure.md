# Brief n27-pressure-02-measure: multi-seed numbers for the new takes, and the mutate scores

Launched about 04:00. **Hard stop 05:10** (report and END by then). Commit each finished part as soon as it passes
(first commit by 04:40 at the latest). No product behaviour changes in this call.

## Context

Your call 1 (`625b460c7`, `e7f748ed3`) built `pair_circle`, `pair_dash`, `guard6`, `blade6` and filmed them. One seed
is not enough for the owner to read a share: guard 9/46 = 19.6 %, blade 8/40 = 20.0 % against the curve's 24.3 % /
30.6 % (`evidence/n26-pressure/deflect/share.md`). Item 4 of the lane (mutate the n26 seed-9 stall fix) was never
scored.

## Godot is held until `evidence/n27-pressure/medians/keys/DONE` exists

The director's after-keys median batch runs in a scratch worktree until about 04:15. Write code first; start Godot
only after that file exists. One Godot process at a time from then on. When you finish your last Godot run, write
`evidence/n27-pressure/godot-free.txt` with the time (the director's next batch waits for it).

## Tasks, in order

1. **Seed table for the four takes** (headless, `pressure_film.tscn` already prints the summary in headless mode, or a
   small new `-s` dev script under `project/dev/gauntlet/` with its own `const KNOWN_FLAGS`). Seeds 1 to 10 for each
   of `pair_circle`, `pair_dash`, `guard6`, `blade6`. Write `evidence/n27-pressure/takes/seeds.md` (+ the raw rows as
   `seeds.json`): per take and seed the summary numbers; per take the pooled totals; for the 6 m takes the pooled share
   = sum(struck) / sum(returned) with a 95 % Wilson interval, beside the curve's figure; for the pair takes the pooled
   hits / launches, the death times (s) and the HP at 10 s. State plainly whether the curve's figure lies inside the
   interval. Do not retune the takes to move a share toward the curve: measure what they do. If a seed fails to open
   or a take behaves differently from seed 1 (e.g. the dash take dies), report it as it is.
   Also explain in one paragraph, from the code, why the plasma sword catches only about half of the rounds fired at
   it in `blade6` (passed vs returned vs neither: count the third bucket if one exists, e.g. rounds that hit Rivet
   during a swing, or rounds that miss) — measured, not guessed.
2. **Mutate the stall fix** (item 4; commit `bf32bfd1a` of n26):
   `node tools/mutate/mutate.mjs --file=features/gauntlet/gauntlet_combat.gd --lines=12-16,18,53-66,120,122,123 --max=20 --json`
   and `node tools/mutate/mutate.mjs --file=features/gauntlet/bot/bot_arena_moves.gd --lines=7-15,54 --max=20 --json`
   (default oracle = mapped tests; if the map selects nothing, add `--tests=test_gauntlet_kerf_wall,test_gauntlet_enemy_damage`).
   Then `node tools/mutate/mutate.mjs --file=dev/gauntlet/pressure_pair.gd --max=12 --tests=test_pressure_takes`.
   Quote killed/(killed+survived) and list each survivor (line + mutation) with one sentence on whether a test should
   catch it, in `evidence/n27-pressure/mutate/scores.md` (+ the JSON outputs). Do not add tests to features files'
   owners' areas; a missing pressure test for a survivor in the stall lines may be added under
   `project/tests/unit/test_gauntlet_kerf_wall.gd` / `test_gauntlet_enemy_damage.gd` (these are this lane's n26 tests)
   if it is quick, then re-run mutate on those lines only and quote both scores.
3. If time remains: none. Report and END.

## Files (allowlist; any other path: stop and write NEED in your report)

`evidence/n27-pressure/takes/**`, `evidence/n27-pressure/mutate/**`, `evidence/n27-pressure/godot-free.txt`, new
files under `project/dev/gauntlet/` (with `.uid`), `project/tests/unit/test_gauntlet_kerf_wall.gd`,
`project/tests/unit/test_gauntlet_enemy_damage.gd`, `project/tests/unit/test_pressure_takes.gd`,
`tools/debt/baseline.json` only through `node tools/debt/debt.mjs --update` (`--accept-regression="<reason> for n27 pressure"`).
**Forbidden**: `project/data/**`, `project/features/**`, `project/boot/**`, `JOURNAL.md`, `REPORT.md`, the masters
folder, every other lane's files.

## Machine rules

- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Headless only
  in this call. Free your own processes by PID; never kill by name.
- After new scripts land, one Godot `--import` before committing. Fix lint and format findings in your own edit and
  go on. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit
  again; never `--no-verify`.
- Mutate creates `gtai-mutate-*` temp worktrees; let it clean up, and if one is left in `%LOCALAPPDATA%\Temp`, name it
  in the report (do not delete other lanes' ones).

## Repo law

AGENTS.md and STANDARDS.md: typed GDScript, ~200 lines a file, functions <= 40 lines, <= 5 params, `Log` not `print`,
deterministic (fixed tick, RNG registry). Stage per path; `git commit -- <paths>`. Banned: `git stash`,
`git add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push.

## Report

Commits; the seed table's pooled numbers (share + interval vs curve; hits/launches, death times); the three mutate
scores with survivors; the sword half-catch explanation; anything undone and why.
