# Brief 02 (street lane, n23): the budget in finer units

Hard stop: 03:35 wall clock (check `date`). Commit deadline: 03:25. If you are not done, commit what is green and report what is left.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Never kill processes by name; only by a PID you started.

## Goal (owner: "Count the budget in finer units.")
`project/data/tables/gauntlet.json` has `budget{base: 2, per_wave: 2}` and `project/features/gauntlet/gauntlet_composer.gd` spends it in whole tiers (`tiers[id]`, from the enemies.json `tier` or the `tier_map` fallback). Count everything in tenths of a tier.

### Part A: convert one to one (commit A)
1. `gauntlet.json` `budget` becomes `{"base": 20, "per_wave": 20, "unit": 10}`. `unit` names the scale (tenths of a tier); the composer reads it and must not assume 10 elsewhere: cost default = `tier * unit`.
2. New optional top-level map `"cost": {"<enemy id>": int}` in `gauntlet.json`, in the same unit; an id missing from it costs `tier * unit`. Ship it empty `{}` (or absent) in commit A. Schema `project/data/schemas/gauntlet.schema.json`: `budget.unit` required int >= 1, `cost` optional object of int >= 1, with descriptions.
3. The composer: eligibility, affordability, the boss deduction and the remaining-budget loop all use costs, not tiers. Keep `tiers` (unlock waves still go by tier) and add `costs`. The loop that today iterates `for _slot in remaining` must still make the same RNG calls in the same order for whole-tier costs (cap the loop by enemy count, not by budget units; break when nothing is affordable, as today).
4. Proof of one to one: for seeds 1, 2 and 3, `node tools/dev/run.mjs gauntlet --seed=<s> --bot=average --waves=10 --result=<abs>` at the commit BEFORE Part A and AFTER Part A: the result files are byte-identical (`cmp`). Also add a unit test in `project/tests/unit/test_gauntlet_composer.gd` that a table with `unit: 10`, base 20, per_wave 20 composes the same rosters for waves 1..30 as `unit: 1`, base 2, per_wave 2 (both seeds 1..3), and a test that a `cost` override changes the roster (two tier-1 enemies at 8 and 12). Write the proof (the six paths, the cmp result) to `evidence/street/budget-one-to-one.md`.
Commit A.

### Part B: opening waves that last (commit B)
The opening waves end in a few seconds. Target: waves 1 to 5 hold enough enemies for about 15 s each for the average bot (`target_wave_s: 15` is already in the table).
1. Measure BEFORE: seeds 1..5, `--bot=average --waves=5`, read each wave row's `seconds` (and `timed_out`). Table: seed x wave seconds, median per wave, median over waves 1..5.
2. Propose new `budget.base`, `budget.per_wave` and, only if it helps the mix, a few `cost` entries (e.g. patrol_cop 8, contractor 12) so the median of waves 1..5 is 12 to 18 s. Do not raise per_wave so hard that wave 20+ becomes absurd: report the budget at waves 1, 5, 10, 20, 40 and what the cap `max_alive` does there. Try at most 4 settings; each one measured on the same 5 seeds.
3. Record BEFORE and AFTER in `evidence/street/budget-opening.md` (the tables, the settings tried, the pick and why) and the raw results under `evidence/street/budget/`. Add one line to `docs/decisions.md` (append at the end, one line): `- [2026-11-22] DECISION gauntlet-budget (n23 street): ...` with the numbers.
Commit B. The tuner (loop lane) tunes from here; do not touch `tools/gauntlet/**`.

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --select=test_gauntlet_composer,test_gauntlet_waves,test_gauntlet_run` and `--changed` green.
- `python tools/gauntlet/test_run_schema.py` (read it for how it runs) green.
- `node tools/achievements/gen.mjs --check` is not yours; skip. `node tools/debt/debt.mjs --check`; on `tighten:` run `--update` and commit the baseline.
- After commit A: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_composer.gd --max=20 --lines=<changed lines>`; quote killed/(killed+survived).

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
`project/features/gauntlet/gauntlet_composer.gd` (and a new helper file beside it if needed, with its `.uid`), `project/data/tables/gauntlet.json`, `project/data/schemas/gauntlet.schema.json`, `project/tests/unit/test_gauntlet_composer.gd`, `evidence/street/**`, one appended line in `docs/decisions.md`, `tools/debt/baseline.json` through the debt tool.
Forbidden: `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/enemies.json`, `combat.json`, `gauntlet_bonuses.json`, `project/features/player/**`, `project/boot/**`, JOURNAL.md, REPORT.md, everything else. Any other path: stop and report a NEED.

## Part C (after commit B): a seed that stacks
Commit `e24cc3847` (the previous session) made a timed-out wave stack, but none of its bot runs ever timed out. With the new budget, find a seed and bot level (`--bot=novice|average`, seeds 1..10, full run to death) whose result has rows with `timed_out: true` and a moment with 2 and 3 waves alive (log line `wave %d tick %d block %d, %d alive`). Report seed, bot, the ticks where 2 and 3 waves are alive, wave reached, `death`. Write it to `evidence/street/stacking-seeds.md`. No code change in Part C; if stacking never happens or misbehaves (Rivet released early, picks lost, a wave never spawning), describe it exactly with the log lines, do not fix it.
