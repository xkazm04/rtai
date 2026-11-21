# Brief 05 (lane loop, n22): tuner follow-ups and the one-command night

Wall-clock: you start about {START}. **Commit deadline {COMMIT}, hard stop {STOP}**. Small commits, one per change; never amend, never rebase. Fix lint and format findings in your own edit and go on.

## Context (read, do not re-derive)
Your tuner (`tools/gauntlet/tune*.mjs`, `knobs.json`, `baseline.json`, tests) landed in commits 1456bb9f3..a4c7b6ac2. The bot was then fixed on the real street (brief 04, `evidence/briefs/04-bot-street.md`). The director ran `tune.mjs propose` on the real street batch `evidence/loop/batch-street-1/batch.json`:
```
average wave 10 median 47.72 s over 1 timed runs ... robot_thug.hp 6 -> 4.8
average wave 5 median 31.82 s over 3 timed runs ... war_machine.hp 60 -> 48
average wave 9 median 20.43 s over 1 timed runs ... robot_gunner.hp 4 -> 3.2
turret_gun recorded as killer in 5/8 deaths ...: enemy_weapon.turret_gun.damage 4 -> 3.2
```

## Goal, in order (commit each)
1. **Sample floor**: a wave miss needs at least `--min-n=3` timed runs (default 3); a killer-share miss at least 5 deaths. Below it the miss is listed as "too few runs" and proposes nothing. Test.
2. **Too fast is a miss too**: waves whose average median is under 12 s (the report's band) are misses in the other direction. Map them to `budget.base` (early waves) / `budget.per_wave` (if the under-target waves span the run) so more enemies come; never lower a weapon or Rivet's numbers for it. One sentence with the numbers, as for the slow misses. Test with a planted fast fixture.
3. **Knob row identity**: every knob into an array row carries the row's id (`"row": "war_machine"`); read and apply check that the object at the pointer's row has that `id` and otherwise skip it with one line ("knob war_machine.hp: row 13 is shield_robot, skipped"). Regenerate knobs.json from the tables with that field. Test with a reordered copy of a table.
4. **One command for a night**: `tools/gauntlet/night.mjs --seeds=N [--profile=average] [--pick=greedy] [--controls=wheel] [--out=<dir>] [--dry-run]` runs: measure batch (batch.mjs) -> report -> propose -> (on branch `n22-tune*` only, else stop after propose with one line) apply -> confirm batch on the same seeds -> `confirm --revert` -> report on the confirm batch -> one `night.md` summary listing every kept and reverted change with before, after, baseline and the evidence. `--dry-run` prints the commands. Node tests with a stubbed runner (no Godot in tests).
5. `docs/gauntlet-loop.md`: the night procedure uses `night.mjs`; say what each step writes and how the owner undoes a kept change (`git revert <sha>` on the tune branch).

## Files you may create or edit (allowlist; any other path: stop and report a NEED)
`tools/gauntlet/**`, `docs/gauntlet-loop.md`, `evidence/loop/**`.
Forbidden: everything under `project/`, every other worktree. Do not switch branches or merge.

## Machine rules
- No Godot in this call (the director may run batches meanwhile). `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` if any tool needs it.
- Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push. Before each commit `git status --short` and stage only your own files.

## Acceptance (quote)
`node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` clean; `node tools/gauntlet/tune.mjs propose --batch=evidence/loop/batch-street-1/batch.json --out=build/gauntlet/plan-street-1b.json` output (the two n=1 misses must now say "too few runs"); `node tools/gauntlet/night.mjs --seeds=3 --dry-run` output. End with files, commits, numbers, what you could not do.
