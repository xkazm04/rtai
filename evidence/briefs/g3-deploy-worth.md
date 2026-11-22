# Brief g3-deploy-worth (lane `ghost`, n24): what one deploy is worth, measured

Hard stop: HH:MM_STOP wall clock (check `date`; killed at 75 minutes). Last commit by HH:MM_COMMIT.

## Context
Your previous calls built the ghost deploy (sim g1, views g2): read `git log --oneline -15` and the deploy files in `project/features/souls/`. Now measure what each deploy is worth in a fight, with a cooldown on every deploy. Last night's kill-time probe is the template: `project/dev/moves/move_ttk*.gd` (trials over named seeds, an off arm and an on arm, per-seed pairs, a stats file `evidence/moves/ttk.md` + JSON).
G3_NOTES

## What to build
1. A headless dev probe `project/dev/ghost-deploy/deploy_worth*.gd` (declare `const KNOWN_FLAGS`, e.g. `--seeds=<n>`, `--form=<id|all>`, `--out=<abs path>`; runs through `node tools/dev/run.mjs deploy_worth -- ...` or `"$GODOT_BIN" --headless --path project -s res://dev/ghost-deploy/deploy_worth_run.gd -- ...`). For each form and each of 10 seeds (name them: 1..10), on a fixed small encounter per form, a scripted Rivet with the pistol who walks a strafe circle and fires at the nearest hostile, with two arms on the same seed and tick budget (30 s): `off` (no deploy) and `on` (deploy the form every time it is off cooldown when a target fits, aimed at the best spot). Encounters: Kerf: 1 shield robot + 3 patrol cops; Ohm: 1 sentry turret + 1 shield robot + 2 SWAT; Tonnage: 1 war machine; Dent: 5 patrol cops in a loose line. Measure per arm: time to clear (s, omitted if not cleared), Rivet hp lost, and for `on`: deploys used, kills by deploy (weapon `deploy_<form>`), stun seconds caused by deploy, damage dealt by deploy. Per form: kills per use, stun s per use, damage per use, the clear-time delta on-off with its CI95 over the 10 pairs and how many seeds were faster.
2. Write `evidence/ghost/deploy-worth.md` (a table per form, the encounter, the seeds, the numbers, one plain sentence each: what a deploy is worth) and `evidence/ghost/deploy-worth.json`. Unmeasured = omitted, never 0.
3. If a deploy does nothing in its encounter (e.g. Ohm's stun already given by its bolt, or Kerf one-shots), say it plainly; do not tune numbers to make it look better. If a starting value is clearly wrong (a deploy that cannot reach its target at its `range_m`), you may change that one value in the `deploy` block of `ghost_attacks.json` as its own commit, with the before/after numbers.

## Checks
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/ghost` before every Godot run; one Godot at a time; lint green (fix lint and format findings in your own edit and go on); `node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` before each commit; a `dev_loc` debt rise from the new dev files: `node tools/debt/debt.mjs --update --accept-regression="deploy_worth for n24 ghost"`, commit the baseline.

## Files you may edit
`project/dev/ghost-deploy/**`, `evidence/ghost/**`, `project/data/tables/ghost_attacks.json` (`deploy` block only, see 3), `project/features/souls/**` (only a fix the probe proves necessary, its own commit, with a test), `project/tests/unit/test_ghost*`, `tools/debt/baseline.json` through the tool. Forbidden: everything else, in particular `enemies.json`, `weapons.json`, `project/features/gauntlet/**`, `project/features/player/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/`.

## Repo law
Typed GDScript, warnings are errors; ~200 lines per file (hard 300), functions <= 40 lines, <= 5 parameters; `Log` not print; RNG only through the registry; whole ticks. Stage per path, one commit per change, no `git add -A/./-u`, no stash, no `reset --hard`, no amend, no rebase, never push.

## Report
Files, commits, the per-form table (kills/use, stun s/use, damage/use, clear delta CI95, seeds faster), check lines.
