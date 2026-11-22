# Brief 06 `tuner-shared`: keep the tuner off shared tables, one repair group, ablate at a fixed revision, docs (lane loop, n23)

Hard stop: 07:25 wall clock (the call is stopped at 75 min). Commit deadline: 07:20. Commit each step as it lands.
Fix lint and format findings in your own edit and go on.

## Why (measured tonight)

- The tuner's first proposal for the street-merge baseline (`evidence/n23-loop/base-street/batch.json`) was `enemy_damage` x1.25 (`evidence/n23-loop/cycle1-enemy-damage-plan/plan.json`): 23 numbers in `project/data/tables/enemies.json`. That table is shared with quest 1, the scenario tapes and the 60 s replay; a kept change would move shipped replays, which the night's rules forbid ("put it behind the gauntlet or a table switch"). The director replaced it by hand with `rivet.repair_per_s` 10 -> 8 (cycle 1, `evidence/n23-loop/cycle1/plan.json`).
- In-wave repair is the first cause of survival (`evidence/n23-loop/ablate/summary.md`), and its two numbers (`gauntlet.json` `rivet.repair_per_s` down, `rivet.repair_delay_s` up) only make sense together; a death-wave plan holds one change (`tools/gauntlet/tune_git.mjs` checkPlan), so today they need two cycles.
- `tools/gauntlet/ablate.mjs` always snapshots the lane HEAD; a cycle's after batch must run on the same tree as its before batch while the lane HEAD moves. The director worked around it with a scratch checkout.
- `docs/gauntlet-loop.md` projects 4 h 49 min a cycle from uncapped smoke runs; measured tonight with `--waves=40`: an average/expert run ~1.5 min, novice ~0.8 min, a 30-run batch at jobs 1 ~45-50 min (`evidence/n23-loop/base-street/batch.json` and `base-street-salt1/batch.json` manifests).

## Work, in order (commit each)

1. **Shared tables.** `tools/gauntlet/knobs.json`: every knob whose file is not gauntlet-only gets `"shared": true` (at least `enemies.json`, `combat.json`, weapon tables; `gauntlet.json` and `gauntlet_bonuses.json` are gauntlet-only; CHECK each file's readers with `rg` and say which you marked and why). `tune.mjs propose` skips shared knobs (and the `enemy_damage` group when any member is shared) unless `--allow-shared`, with the reason `shared with quest 1 / replays` in the plan's skipped list. Tests: the base-street fixture (or a small one) proposes no shared knob by default; with `--allow-shared` it proposes `enemy_damage` as today.
2. **Repair group.** A knob group `rivet_repair` in `tools/gauntlet/tune_groups.mjs` like `enemy_damage`: one factor f in 0.8..1.25 makes `rivet.repair_per_s` x(1/f) and `rivet.repair_delay_s` x f (both clamped against the baseline as usual; budget/rounding rules unchanged). A death-wave miss too deep proposes `rivet_repair` first (f = 1.25 for a miss of more than 3 waves), then `budget.per_wave`; too early mirrors it. `occupied()` treats the group and its members as one. `tune.mjs sets` expands it. Tests (plan, sets, occupied, clamps). If a gauntlet `enemy_damage_k` lands later (NEED street, 05:53), it is the next group member; do not wait for it.
3. **`ablate.mjs --rev=<sha>`**: the worktree is cut at that commit instead of HEAD (must be a commit of this repo; refuse anything else); the receipt records it. `night.mjs` passes `--rev` when the director gives `--rev`. Tests for parsing and refusal (no Godot).
4. **Moves knobs** landed in brief 05 (`65bad8351`): only mark them `shared` by rule 1 (combat.json is shared with quest 1).
5. **Docs.** `docs/gauntlet-loop.md`: replace the runtime projection with the measured numbers above; add "The noise floor by a neutral change" (bot salt, how to run `tune.mjs floor`, tonight's floors: street merge death-wave floor novice 8.5 / average 6 / expert 0 because all censored at 40; main, average, wave seconds null vs cross-seed: wave 5 3.38 vs 24.35, wave 20 11.48 vs 22.47, from `evidence/n23-loop/base-null-salt1/floors.md`), "Shared tables" (rule 1), "Censored runs" (a run alive at the wave limit counts as a lower bound; when every run of a profile is censored, its floor is 0 and no change can be judged for it until the game gets harder). Append to `docs/decisions.md` (one line each, format `- [2026-11-22] DECISION <area>: ...`): the bot-salt neutral change (rejected: spawn-order shuffle, cosmetic salt); the point verdict (rejected: strict); `--waves=40` censoring for tuning batches (rejected: uncapped 10 seeds, ~2.5 h a batch); shared-table knobs off by default (rejected: tuning enemies.json and moving quest 1 / replays).
6. `node tools/gauntlet/tune.mjs propose --batch=evidence/n23-loop/base-street/batch.json --profile=all --metric=death --max=1 --out=build/n23/propose-06.json` and paste the plan's change and skipped list in your final message. Do not apply.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green (quote the count); `node tools/lint/lint.mjs` green.
- Node only: **no Godot process of yours** (the director's batches hold the lane's two Godot slots).

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`. Never kill a process you did not start. Do not touch `C:/Users/kazda/AppData/Local/Temp/gtai-loop-street` or any `gtai-ablate-*` worktree (the director's running batches). Never touch another lane's worktree.

## Files

Allowlist: `tools/gauntlet/**`, `docs/gauntlet-loop.md`, `docs/decisions.md` (append only). Any other path: stop and report a NEED. Forbidden: every table under `project/data/`, `project/**`, `JOURNAL.md`, `REPORT.md`, `evidence/**` (except what step 6 writes under `build/`), other worktrees.

## Repo law

Staged per path; no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`. Small files and functions (about 200 lines a file).

End with: files changed, commits, commands and results, anything not done and why.
