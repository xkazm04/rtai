# Brief n26 pressure 01: deflect spread 20 degrees, the measured curve

Hard stop 12:10 wall clock (stop working, commit what is green, report). Commit deadline 12:05.

## Setup, every shell
`export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/pressure` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before any Godot,
test, gate or tool run. One Godot process at a time in this worktree. A windowed run uses `--position 0,1440`.
The import cache is fresh (11:10).

## Goal (owner's pick)
"Deflect spread 20 degrees (a return is a gamble: about a quarter hit at 6 m)."

1. `project/data/tables/combat.json` `deflect.spread_deg` 12 -> 20. Nothing else in that table changes.
2. Measure the share of RETURNED basic rounds that hit their shooter at **4, 6, 8 and 12 m** at 20 deg (guard and
   plasma bat), with the existing dev tool `project/dev/gauntlet/deflect_share.gd`
   (`node tools/dev/run.mjs deflect_share -- --out=<abs dir> --rounds=1000`). Make the tool's distance list
   4, 6, 8, 12 (keep 20 too if cheap) and its spread list 12 and 20 (12 for the before column). Write the result to
   `evidence/n26-pressure/deflect/share.md` (+ the raw json the tool writes) with a two-line header: seed, rounds,
   what the denominator is. Last run's numbers at 20 deg were 6 m 24 % guard / 31 % bat, 12 m 10 / 11 %.
   The owner expects about a quarter at 6 m; if 6 m is outside 20 to 30 %, still keep 20 and say so in your report.
3. Re-derive every test bound that encoded 12 degrees from what the test means (grep tests for `spread_deg`, `12`
   near deflect, and the deflect tests: `project/tests/unit/test_live_deflect.gd`, `test_deflect_throughput.gd`,
   `test_deflect_marks.gd`, `test_player_guard*.gd`, `test_melee_single_swing.gd`, `test_gauntlet_*`,
   `project/tests/scenarios/scenario_rivet_deflect.gd`, and the showcase reel chapter `plasma_sword_deflect` in
   `project/dev/showcase/reel_chapters.gd` / `scenario_showcase_director.gd`). A bound changes only with a one-line
   comment saying what it measures; never widen a bound just to pass. If a scenario or the showcase deflect chapter
   needs a full return to stay a demonstration, it may set its own override (e.g. `pass_ratio_k` 0 or spread 0 for
   that chapter only, as data/args inside dev or test code), not the shipped table.
4. Runs: `node tools/tests/run_unit.mjs --changed`, then the FULL unit suite `node tools/tests/run_unit.mjs`, then
   `node tools/tests/run_scenarios.mjs` if it exists (else `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`).
   All must be green, or every red one named with its cause in your report. Then `node tools/gate/quick.mjs` before
   the commit.
5. One commit for the data + tests ("Deflect spread 20 degrees ..."), one for the tool + evidence. Then
   `node tools/mutate/mutate.mjs --file=<the deflect rule .gd that reads spread_deg> --max=20 --lines=<the lines that read the spread>`
   and quote killed/(killed+survived).
6. A replay or tape whose digest moves because of the spread: name it, re-pin it only if it is a gauntlet/deflect
   fixture, and add one line to `docs/decisions.md`:
   `- [2026-11-23] DECISION pressure deflect spread: 20 deg ... <measured 6 m share> ... <what was re-pinned>.`
   Quest 1's tapes and `replay_60s` must NOT move (if they do, stop and report).

## Allowlist (any other path: stop and report a NEED)
`project/data/tables/combat.json` (deflect.spread_deg only), `project/dev/gauntlet/deflect_share.gd`,
deflect tests and fixtures under `project/tests/**` that encode the spread, `project/dev/showcase/reel_chapters.gd`
(deflect chapter only, if needed), `evidence/n26-pressure/deflect/**`, `docs/decisions.md` (append one line),
`tools/debt/baseline.json` (only via `node tools/debt/debt.mjs --update`).
Forbidden: `input_actions.json`, `rivet_motion.json`, `project/features/player/**`, `project/features/souls/**`,
`project/features/combat/kills/**`, `ghost_attacks.json`, `ghost_forms.json`, `cast_cards.json`, `project/boot/prologue/**`,
`prologue_stage.json`, `prologue_yard_dressings.json`, any enemy/cast art, root `JOURNAL.md` / `REPORT.md`.

## Law
Typed GDScript, files about 200 lines (300 hard), functions <= 40 lines, <= 5 params, `Log` not print, no global RNG.
Fix lint and format findings in your own edit and go on. Stage per path; `git commit -- <paths>`; no stash, no
`add -A`, no amend, no rebase, no reset --hard, never push. Commit `.uid` with any new `.gd`.

## Report
Files changed, the 4/6/8/12 m table (12 deg vs 20 deg, guard and bat), test bounds changed and why, unit/scenario
counts, mutate score, digests moved, commits.
