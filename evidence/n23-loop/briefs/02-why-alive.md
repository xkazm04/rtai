# Brief 02 `why-alive`: measure why nobody dies (lane loop, n23)

Hard stop: 03:20 wall clock. Commit deadline: 03:15. Commit each step as it lands.

## Goal

On the combined game the test player almost never dies (5 seeds x 3 profiles: one death in 15, 11 alive at the 72000-tick cap). The owner wants the two or three largest causes named with numbers. My first reading of tonight's baseline (`evidence/n23-loop/base-greedy/runs/*.json`, read-only for you): Rivet has 100 HP and repairs 10 HP/s after 3 s without damage (`project/data/tables/combat.json` `rivet.repair_per_s`, `repair_delay_s`; greedy regen picks multiply it, `project/features/gauntlet/gauntlet_bonus_apply.gd:61`). Novice seed 1 took 136.8 damage in a 36 s wave and lived. Greedy picks end with every stat at x1.375. The result file has `damage_taken`, `guard_deflects`, `cover_ticks`, `rolls` per wave but no HP trace, so how close he came to death and how much repair saved him are not measured.

## Work, in order (commit each)

1. **HP telemetry per wave**, written by the bot's own hook `project/features/gauntlet/bot/bot_street_stats.gd` (it already writes `guard_ticks`, `cover_ticks`, `form_seconds`, `machine`): `hp {start, min, end, max, repaired}` per wave row (`repaired` = sum of positive HP steps, i.e. repair and any heal; `max` = Rivet's max HP during the wave). Optional object in `project/data/schemas/gauntlet_run.schema.json` (your field only) and `tools/gauntlet/contract.mjs`. The sim must not change: a run's result must equal last night's bytes apart from the new `hp` key (prove it on one seed: strip `hp` and compare to `evidence/n23-loop/base-greedy/runs/average-3.json` once that file exists, or to a fresh run without your change). GUT test that a bot run row carries `hp` with min <= start and repaired >= 0 (extend the existing bot street stats test if there is one). This also covers last night's mutate survivor: a test that rolls/cover/hp from `BotStreetStats` reach the result.
2. **Survival section in the report** (`tools/gauntlet/report.mjs` / `report_tables.mjs` / `render.mjs`, new file if a file would pass 200 lines): per profile and per wave band (1-10, 11-20, 21-30, 31+): median damage taken per wave, median damage per second of wave against the repair rate, median `hp.min / hp.max`, median `hp.repaired` against damage taken (share of damage undone by repair inside the wave), guard deflects per wave, cover ticks, rolls, and the stat multipliers from `mods` at that wave (from `picks`). Waves without `hp` say "not measured", never 0. Node test with a fixture.
3. **Ablation runner** `tools/gauntlet/ablate.mjs --name=<id> --set=<repo-relative json file>#<json pointer>=<number> [--set ...] [--pick-filter=<prefix to never take>] -- <batch.mjs args>`: builds a throwaway git worktree at HEAD under the OS temp dir (reuse `tools/mutate/worktree.mjs` safety rules and its way of providing native DLLs and the import cache; never write in this worktree except `--out`), applies the edits there, runs `batch.mjs` there with `--out` pointing back to the given out folder, writes `ablation.json` (the edits, the head sha, the batch summary), removes the worktree. Node tests for argument parsing, pointer edits and the safety refusal. If `--pick-filter` needs bot support, add a pick policy option in `project/features/gauntlet/bot/bot_pick.gd` that greedy-picks among offers not starting with the prefix (and takes the lowest-valued offer when all match), behind a flag read the same way as `--bot-salt` (see the previous commits), declared in the KNOWN lists like `--bot-salt`.
4. **Run the ablations** (average, greedy, wheel, seeds 1-10, `--jobs=1`, one Godot at a time; each into `evidence/n23-loop/ablate/<name>/`):
   - `repair-off`: `combat.json#/rivet/repair_per_s=0`
   - `repair-slow`: `repair_per_s=3`, `repair_delay_s=6`
   - `no-stat-picks`: `--pick-filter=stat_`
   - `guard-off`: the smallest edit that disables the guard (for example `guard.meter_max` to a value that cannot raise it; read `project/data/tables/combat.json` block `guard` and say what you chose and why it disables it)
   - `enemy-dmg-x2`: every enemy weapon `damage` and `splash_damage` x2 (`project/data/tables/enemies.json` or wherever `tools/gauntlet/knobs.json` points the `enemy_weapon.*.damage` knobs)
   and the control `base` (no edits, same seeds) through the same runner. Report per ablation: deaths of 10, median wave reached, median death wave, capped alive. If time is short, cut seeds (say the count), never ablations; order above is the priority.
5. A short page `evidence/n23-loop/ablate/summary.md`: the table, one line per ablation, and the two or three largest causes in numbers.

## Acceptance (I will re-run these)

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/tests/run_unit.mjs --changed` green; `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
- Pre-commit hook passes (never `--no-verify`). `node tools/gate/quick.mjs` before the GDScript commit.
- Mutate after the GDScript commit: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/bot/bot_street_stats.gd --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
- The ablation temp worktree is gone afterwards (`git worktree list` shows none of yours) and `%TEMP%` holds no leftover `gtai-*` folder of yours.

## Machine rules

- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`.
- **At most ONE Godot process of yours at a time.** I may run a batch alongside you (that is the lane's second). Never kill a process you did not start; free your own by PID. No windowed runs.

## Files

Allowlist: `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/test_player.json`, new tests named for the bot / gauntlet tools under `project/tests/unit/`, your own optional fields in `project/data/schemas/gauntlet_run.schema.json`, the KNOWN list line in `project/dev/gauntlet/gauntlet.gd` (append a flag only), one appended line in `project/boot/launch_args.gd` KNOWN_FLAGS plus `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 loop"`, `evidence/n23-loop/ablate/**`. Edits to `combat.json` / `enemies.json` happen ONLY inside the throwaway worktree, never here. Any other path: stop and report a NEED. Forbidden: the rest of `project/features/gauntlet/**`, `project/features/player/**`, every table except `test_player.json`, `evidence/n23-loop/base-*`, `JOURNAL.md`, `REPORT.md`, other worktrees.

## Repo law

Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, at most 5 parameters, `Log` not `print`, no global RNG. One commit per step, staged per path: no `git add -A/./-u`, no `git commit -a`, no `git stash`, no `reset --hard`, no amend, no rebase, never push. Commit `.uid` with new `.gd`. No sim, parity, bake or replay digest moves.

End with: files changed, commits, commands and results, the ablation table, anything not done and why.
