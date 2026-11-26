# Brief b4j-more-guns-weaker (lane foes, run n31): more shooters, each round weaker, inside the rail

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. Read `evidence/briefs/b4f-share.md`,
`evidence/n31/foes/item3-compare.md` (last table + notes) and `git log --oneline -15` first. **Hard stop 55 min
after launch: report and END.** First commit (setting A + its measurement) by 30 min in; start the last commit
12 min before the stop. Never end with a commit in the pre-commit hook.

## Why
Owner: "AI is waiting to shoot too much, cops are just waiting until I can closer to start shooting". The final
setting `9b3730e36` (shooter share 0.5, own guns pistol 3 / rifle 2 / cannon 8 Rivet hp per round via
`squad.own_weapon_damage` in `project/data/tables/enemies.json`) holds react p50 0.68 s but idle is 55 % (bar
< 35 %) because 53 % of the foe-seconds hold no token, and p90 2.58 s (bar 2.5). The guard rail (average bot,
Rivet damage waves 1-4 in 53.5..72.3; final 71.3) leaves no room for more fire at today's round damage. The
brief's own rule: "more enemies shooting sooner, each shot weaker or slower, not a harder game".

## Do, each setting one commit + one docs/decisions.md line (before -> after numbers)
A. `squad.max_shooters_share` 0.5 -> 0.75 AND `own_weapon_damage` pistol 3 -> 2, rifle 2 -> 1.5 (cannon unchanged).
   Read how both values are read first (`project/features/combat/ai/enemy_squad.gd`,
   `project/features/combat/squad/foe_own_gun.gd`, the enemies schema) and check a fractional damage is honoured
   (if damage is int, use pistol 2 / rifle 1 and say so). Measure average, seeds 1-10, `--waves=7`,
   `--rev=<the commit>` into `evidence/n31/foes/waiting-more-guns/` (same tool and options as
   `evidence/n31/foes/waiting-final/`: read its waiting.md header for them).
   Keep A only if: damage w1-4 in 53.5..72.3 AND idle drops >= 8 points (55 % -> <= 47 %) AND react p50 <= 1.0.
B. If A breaks the rail HIGH: pistol 2 -> 1.5 (or share 0.65); if LOW (< 53.5): share 0.75 with pistol 2.5.
   One more measurement only. Same keep rule.
C. If nothing is kept: revert to the 9b3730e36 values in one commit (never leave a rejected value on HEAD) and
   record both measurements as "measured, not kept" in item3-compare.md.
D. The kept setting (or none): novice table too (`--profile=novice` or what the tool calls it) into the same dir,
   add a column to the last two tables of item3-compare.md, commit.
E. Pins: every test or scenario the value change moves (`node tools/tests/run_unit.mjs --changed`, then the
   squad/enemy scenarios: `scenario_enemy_pit` and the ones `test_map.mjs` names), re-pinned in the same commit
   with the decisions line naming them. Full unit suite on the final commit; quote the summary line.

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot.
Lane lock `build/n31/godot.lock` content `b4j <pid>` (wait while another tag holds it; delete yours when each run
ends). Owned: `project/features/combat/ai/**`, `project/features/combat/squad/**` (not `*_card_view.gd`), the
`squad` block and existing rows of `project/data/tables/enemies.json`, `tools/gauntlet/**`,
`project/features/gauntlet/bot/**`, `project/dev/foes_n31/**`, `evidence/n31/foes/**`, tests that pin these, one
append-only line per setting in `docs/decisions.md`. Forbidden: `combat.json`, `weapons.json`, hurt/hit radii and
melee values (melee lane), `project/boot/prologue/**` and prop/collision files (ground), `project/features/souls/**`
(ghost), wave composition and the wave 5 stomp. Any other path: stop and report a NEED. Do not edit JOURNAL.md or
REPORT.md. Typed GDScript, Log not print, functions <= 40 lines, stage per path, no amend/rebase/stash/
--no-verify, no `git add -A/./-u`, fix lint and format findings in your own edit and go on. Commit messages end
with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. If you change a .gd file, mutate it after the
commit: `node tools/mutate/mutate.mjs --file=<it> --max=20 --lines=<changed> --tests=<2-3 basenames>` and quote
the score.
Report: commits, commands with result lines, the compare columns (react p50/p90, idle, firing/s, never fired,
damage w1-4, deaths) main | final | A | B, which setting is on HEAD, the pins moved, what you could not do.
