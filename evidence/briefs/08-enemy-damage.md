# Brief 08 (street lane, n23): a gauntlet-only enemy damage multiplier (loop's NEED)

Hard stop: 08:05 wall clock (check `date`). Commit deadline: 07:58. If you are short of time, the order is: the step 4 BEFORE run first (at HEAD, ~2 min), then steps 1-3 and the quick check, commit, then step 4 proof, then step 6 mutate (drop it if past 07:55). Short call: one data knob, one test, one proof. No films. Write your final report BEFORE the mutate run; mutate is last and capped.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Never kill processes by name; only a PID you started.

## Why
The loop lane (tuner) wrote: "NEED street: `gauntlet.json` (+ schema) an optional `enemy_damage_k` (default 1.0) ... Why: enemy damage is the tuner's second lever and today it lives only in `enemies.json`, shared with quest 1 and the replays". The gauntlet needs its own multiplier so quest 1, tapes and the 60 s replay stay byte-identical.

## What the director already found (do not re-derive)
- `Fighter.damage_k` is the damage a fighter TAKES (`combat_arena.gd` `damage()`: `amount *= victim.damage_k`). So loop's suggested spot (`gauntlet_street.gd:35`, the foe's `damage_k`) would scale damage the foes take, which is the opposite lever. Do NOT use the foe's `damage_k`, and do NOT use `rivet.damage_k` either (`hauler_stage.gd:62` overwrites it for Tonnage's armour, and it would also scale Rivet's own blast).
- The right place: `project/features/gauntlet/gauntlet_combat.gd` already overrides `damage()`. There, when `victim == rivet` and `killer_id != rivet.id` (any foe: melee, rounds, areas, stomp, ram), multiply `amount` by `enemy_damage_k` before `super.damage(...)`. Rivet's own blasts (`killer_id == rivet.id`) are untouched (the controls lane's `blast.self_k` owns those). Damage Rivet deals is untouched.
- The table is read in `project/features/gauntlet/gauntlet_street.gd` (`_table`; `apply_repair(_table, stage.arena.tuning)` at about line 75 is the model for an optional read with a default). Give `GauntletCombat` a `var enemy_damage_k: float = 1.0` and set it from the table where the stage is installed (read the code for the order of `GauntletCombat.install` and `apply_repair`). Missing key = 1.0.
- `amount * 1.0` is exact in float, so with the key absent or 1.0 no digest moves.

## Do
1. `project/data/tables/gauntlet.json`: add `"enemy_damage_k": 1.0` (sorted keys; keep the file's formatting). `project/data/schemas/gauntlet.schema.json`: `enemy_damage_k` number, `exclusiveMinimum` 0 (or `minimum` 0.05), optional, with a `description` saying: multiplies the damage gauntlet foes deal to Rivet; Rivet's own blast and quest 1 are not affected.
2. The read + the multiply as above (features/gauntlet only; keep each file under its size cap; functions <= 40 lines).
3. Tests in `project/tests/unit/test_gauntlet_street.gd` or a new `project/tests/unit/test_gauntlet_enemy_damage.gd` (commit its `.uid`): (a) k = 2.0: a foe's hit on Rivet takes twice the HP of the same hit with k = 1.0; (b) k = 2.0: Rivet's own hit on himself (killer_id == rivet.id) takes the same HP as with k = 1.0; (c) k = 2.0: Rivet's hit on a foe takes the same HP as with k = 1.0; (d) the key absent reads 1.0.
4. Proof of no move: seed 7 average gauntlet `--waves=10` result before (at the current HEAD, before your edit) and after: `cmp` identical. Use `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs path under build/street/edmg/>`. Then one run with `enemy_damage_k` 2.0 (edit the table in place for the run, put it back to 1.0 before committing) for seed 7 average, `--waves=20`: quote waves reached and death wave against the k = 1.0 run of the same length, so the lever is shown to bite. Write the numbers in `evidence/street/enemy-damage.md` (commands, sha256 of the two identical results, the k = 2.0 numbers).
5. Commit: "Add a gauntlet-only enemy damage multiplier".
6. After committing: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_combat.gd --max=20 --lines=<your changed lines>`; quote killed/(killed+survived), timeouts, survivors.

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green.
- `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`: same pass count as before (65 ran, 0 failed) and the 60 s replay unchanged.

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
`project/data/tables/gauntlet.json` (the one new key), `project/data/schemas/gauntlet.schema.json` (the one new property), `project/features/gauntlet/gauntlet_combat.gd`, `project/features/gauntlet/gauntlet_street.gd`, `project/tests/unit/test_gauntlet_street.gd`, new `project/tests/unit/test_gauntlet_enemy_damage.gd` (+ `.uid`), `evidence/street/enemy-damage.md`, `build/street/**`. If the debt ratchet needs it: `node tools/debt/debt.mjs --update` (tighten only).
Forbidden: `project/features/combat/**` (incl. `combat_arena.gd`), `project/features/gauntlet/bot/**` (loop's), `project/features/player/**`, `project/features/souls/**`, `project/data/tables/enemies.json`, `combat.json`, `tools/**`, tapes and goldens, `docs/**`, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.
