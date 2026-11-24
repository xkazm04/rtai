# Brief n27-melee-01-mastery: mastery at 30, Kerf's boss cuts earn bond, mastery is free, ten-seed table

Lane `melee`, branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Launched about 02:55. Commit part A by 03:20, part B by 03:35. Hard stop 03:55: at 03:55 write your report and END,
even mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on.
Fix lint and format findings in your own edit and go on. No amend, no rebase.

## Context (read first, briefly)
- `docs/day/2026-11-23/n26-melee/REPORT.md` sections 4 and "Calls for the owner" (the bond, last night).
- `project/features/souls/ghost_bond.gd` (GhostBond), `project/data/tables/ghost_forms.json` `bond` block (+ its schema
  under `project/data/schemas/`), `project/features/souls/ghost_form_table.gd` (reads it),
  `project/features/souls/ghost_deploy_strike.gd` (`_boss()`, the Kerf cap at about line 50; `release_kills/stuns`),
  `project/features/souls/ghost_deploy.gd:54` (`forms.bond.record(...)`),
  `project/features/gauntlet/gauntlet_draw.gd` (`_reserve_mastery`), `gauntlet_bonus_apply.gd` (`"mastery"`),
  `gauntlet_run.gd` / `gauntlet_pilot.gd` / `gauntlet_session.gd` (the rest pick flow; find where one pick ends the rest),
  `project/features/gauntlet/bot/bot_pick.gd` (takes `master_*` first),
  tests `project/tests/unit/test_ghost_bond.gd`, `project/tests/integration/test_gauntlet_mastery.gd`,
  measure entry `project/dev/ghost-forms/bond_measure.gd/.tscn`, summarizer `evidence/n26/bond/summarize.mjs`,
  last night's table `evidence/n26/bond/mastery.md` / `mastery.json`.

## The owner's picks (2026-11-24, verbatim intent)
"Mastery pace: raise the bar to 30 and count Kerf's boss cuts as a stun-sized award. Mastery is free: you take it and
still pick a card." Contract with the other lanes (use these names exactly): `ghost_forms.json` `bond.master_at` 25 -> 30;
new `bond.per_boss_cut` = 3; result-file rows keep `bond{<form id>: value}`. No other balance value changes.

## Part A: master_at 30 and per_boss_cut (commit by 03:20)
1. `ghost_forms.json` `bond.master_at` 30, new key `bond.per_boss_cut` 3 (schema, table reader, the `doc` string's bond
   sentence). GhostBond: a release that landed N deployed Kerf cuts which damaged a boss (the same `_boss()` test the cap
   uses, damage > 0 after the cap) earns N x per_boss_cut. A cut that also kills the boss counts as a kill, not twice.
   Credit at the same point the kills/stuns are credited (on the release), keeping "each counted once".
2. `project/features/souls/ghost_deploy.gd` belongs to the keys lane (it is editing it tonight for the slot order). Prefer
   a design that does NOT edit it (e.g. a `release_boss_cuts` the strike already resets per release, read inside
   GhostBond.record through an optional argument with a default, or credited by the strike itself). If one line there is
   unavoidable, keep it to that one line and say so in your report (`TOUCH keys ghost_deploy.gd:<line>`).
3. Unit tests: master_at read from the table is 30; a Kerf boss cut awards 3; a non-boss Kerf cut awards 0 for the cut
   (kills still 4); a cut with damage 0 awards nothing; the cap at master_at still holds. Make each test able to fail.
4. `node tools/gate/quick.mjs`, then commit (stage per path).

## Part B: mastery is free (commit by 03:35)
1. At a gauntlet rest, taking a `master_*` card no longer uses the rest's one pick: it is applied at once, the card is
   marked taken, and the rest stays open for the player's one pick among the other offered cards. Keep the draw itself
   (which cards, slot keys, layout, the RNG calls) exactly as it is: only the pick accounting changes. Two ready masteries
   in one draw: each is free. If every remaining card is a mastery, the rest ends after they are taken. A mastery not
   taken stays eligible (unchanged rule).
2. Make it one data value: `bond.mastery_free` (bool, true) in `ghost_forms.json` + schema; false = last night's rule.
3. The test player (`bot_pick.gd`) takes every offered mastery first, then picks among the rest exactly as before (greedy
   or random over the non-mastery cards). The result file records both (keep the existing pick field meaning the one
   normal pick; add the mastery ids taken at that rest in a separate field).
4. Integration test in `test_gauntlet_mastery.gd`: a rest offering master_X + two cards -> after the player takes master_X
   the rest is still open, the bond is mastered, and the next pick applies one normal card and ends the rest; with
   `mastery_free` false the old behaviour holds. Unit test for the bot's order.
5. Check the card screen on the live window still works when a mastery is taken (the taken card greys out or leaves,
   your call; keep it simple, no new art). Run the gauntlet once windowed for 60 s at
   `--position 0,1440` only if the rest card screen code changed.
6. `node tools/gate/quick.mjs`, commit.

## Part C: the ten-seed table (commit by 03:55)
Same method as last night (`evidence/n26/bond/mastery.md`: average test player, greedy picks, wheel controls, to wave 15
or death, seeds 1..10, `bond_measure.tscn`). Two arms on HEAD:
- arm `pace`: part A only (`mastery_free` false; give `bond_measure` a `--mastery-free=0|1` flag in its own KNOWN_FLAGS
  that overrides the table value for the run);
- arm `free`: part A + B (shipped values).
Write `evidence/n27/bond/mastery.md` + `mastery.json`: per arm, per seed: which ghost mastered at which rest wave, death
wave, form entries, longest wave; then a summary block beside last night's numbers (n26: 6/10 runs mastered, first
masteries at waves 2,4,4,8,8,8, Kerf never): runs with a mastery, first-mastery waves and median, how many inside the
target band wave 8..15, which ghosts, and whether Kerf is now mastered (and his bond at death on each seed). Do not tune.
If the band is badly missed, name the single value that would meet it and why, as one line at the end.
Run headless; run seeds one after another (one Godot at a time). If the 20 runs cannot finish by 03:50, commit the
`free` arm complete and as many `pace` seeds as finished, and say so.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Run one Godot
  `--import` first (`"$GODOT_BIN" --headless --path project --import`). One Godot process at a time; kill only your own
  PIDs, never by name. Windowed runs only with `--position 0,1440`.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every new
  `.gd`, Godot `--import` after new scripts before committing. `node tools/gate/quick.mjs` before every commit. Stage per
  path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. If the pre-commit hook fails
  on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again (never skip the hook).
- Use `node tools/tests/run_unit.mjs --changed` (or `--select=<basenames>`) for the inner loop, not the full suite.
- Every shipped tape and replay stays byte-identical: run `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`
  once after part B and quote its summary line (quest 1 tapes end with all bonds 0, so they must not move).
- After the part A and part B commits: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond.gd --max=20`
  and quote killed/(killed+survived) in your report (do it last, only if time remains before 03:50).
- If you add a dev flag that must be global, append it to `project/boot/launch_args.gd` `KNOWN_FLAGS` and run
  `node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 melee"`; prefer the entry's own KNOWN_FLAGS.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/souls/**` except the keys lane's `ghost_deploy.gd` (one line at most, see A2), `ghost_form_hud.gd`,
`ghost_hud_hints.gd`, `ghost_form_layout.gd`; `project/data/tables/ghost_forms.json` and its schema;
`project/features/gauntlet/gauntlet_draw.gd`, `gauntlet_bonus_apply.gd`, `gauntlet_run.gd`, `gauntlet_pilot.gd`,
`gauntlet_session.gd`, `gauntlet_wave_stats.gd`, `gauntlet_view.gd` (only for the rest card screen),
`project/features/gauntlet/bot/bot_pick.gd`; `project/tests/unit/test_ghost_bond*.gd`,
`project/tests/integration/test_gauntlet_mastery.gd`, new test files for this; `project/dev/ghost-forms/**`;
`evidence/n27/bond/**`; `tools/debt/baseline.json` via the debt tool; `docs/decisions.md` append-only (one
`- [2026-11-24] DECISION n27 melee: ...` line per decision you make).
Forbidden: `input_actions.json`, `combat.json`, `enemies.json`, `weapons.json`, `cast_cards.json`, `project/dev/gauntlet/**`,
`project/boot/prologue/**`, any other worktree, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits (sha + subject); for each part what changed and the test lines; the scenario summary line; the two-arm table
summary beside n26; mutate score if run; anything not done and why; every TOUCH and NEED.
