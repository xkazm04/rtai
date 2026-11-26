# Brief b4o-noise (lane foes, run n31): how noisy is the damage rail? main | final | B on a second seed set

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 35 min after launch:
report and END.** Commit the evidence by 25 min in (evidence-only commits skip lint: fast).

## Why
Item 3's guard rail: Rivet's damage in waves 1-4 (average bot) within +-15 % of main's 62.9 (53.5..72.3). The
final setting 9b3730e36 sits at 71.3; setting B (c825715e8: shooter share 0.75, pistol/rifle 1.5 hp per round)
cut idle 55 -> 43 % but measured 75.1. b4j found the damage total moves 3-10 points between settings that barely
change fire, so the 10-seed rail may be inside noise. The owner gets B as a call; he needs the honest spread.

## Do
1. Read `evidence/n31/foes/waiting-more-guns-b/waiting.md` (header: the exact options) and
   `tools/gauntlet/waiting.mjs` arg parser (seed options: `--seeds=N --seed0=S`).
2. Three measurements, average bot, seeds 11-20 (`--seeds=10 --seed0=11`), `--waves=7`, same options as b4j:
   main `--rev=ba8e470b0` -> `evidence/n31/foes/noise-main-s11/`; final `--rev=9b3730e36` ->
   `noise-final-s11/`; B `--rev=c825715e8` -> `noise-b-s11/`. Order: final, B, main.
3. Write `evidence/n31/foes/noise.md`: one table, rows = damage w1-4, deaths (runs), waves 6/7 reached, idle share,
   react p50/p90, firing/s, never fired; columns = main s1-10 | main s11-20 | main s1-20 (pooled: mean of the 20
   per-seed values, read from waiting.json / runs) | final s1-10 | s11-20 | s1-20 | B s1-10 | s11-20 | s1-20.
   s1-10 values come from `waiting-main/`, `waiting-final/`, `waiting-more-guns-b/`. Add the per-seed damage
   w1-4 standard deviation and a 95 % interval of the mean for each 20-seed column. Then 3 lines: is B's damage
   over 20 seeds within +-15 % of main's 20-seed damage? Is final's? Is B vs final a difference beyond the
   interval? No opinion beyond the numbers.
4. Commit the three dirs + noise.md (stage per path).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every
run; Godot only through the tools (runGodot). Lane lock `build/n31/godot.lock` is shared with b4n (film takes):
content `b4o <pid>` while you run, wait while another tag holds it, delete only your own. Run one measurement at a
time. Owned: `evidence/n31/foes/**` only (and `tools/gauntlet/**` if the tool needs a fix, node tests green,
committed alone). Do not edit game code, data, JOURNAL.md, REPORT.md, `docs/decisions.md`. Any other path: stop and
report a NEED. Stage per path; no amend/rebase/stash/--no-verify, no `git add -A/./-u`. Commit messages end with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, commands with result lines, the table, the three lines.
