# Brief 04b `propose-repair` (follow-up to 04, send with `--resume`): death misses propose repair, one plan for three profiles (lane loop, n23)

Hard stop: HARDSTOP wall clock. Commit deadline: COMMITBY. Commit each step as it lands.
Fix lint and format findings in your own edit and go on. Same files, machine rules and repo law as brief 04. Node-only unless the director's two batches have ended (then one Godot at most).

## Why

The ablations (`evidence/n23-loop/ablate/summary.md`) rank the causes of survival: (1) in-wave repair (10 HP/s after 3 s against 0.6-1.0 HP/s of damage taken), (2) stat picks, (3) enemy damage. Today a death-wave miss in `tools/gauntlet/tune_propose.mjs` (`deathMisses`, ~line 58-71) offers only `enemy_damage` and `budget.per_wave`, so the tuner can never move the first cause. Street's gauntlet override `gauntlet.json` `rivet{repair_per_s, repair_delay_s}` is in the knob list since 522f08cf8.

## Work (commit each)

1. **Death-miss candidates.** A death-wave median deeper than the target proposes, in this order, every one that is eligible (not one): `enemy_damage` (x1.25 at most), `rivet.repair_per_s` (down, x0.8 at most), `rivet.repair_delay_s` (up, x1.25 at most), then `budget.per_wave`. Too early: the mirrored directions. Use the knob's `direction` field from `knobs.json`. The plan says per edit which profile misses it serves.
2. **One plan for all profiles.** `tune.mjs propose --profile=all` (and night.mjs `--profile=all`) writes ONE plan: a knob is proposed once even when several profiles miss, with the step the furthest-missing profile asks for, clamped as usual; when profiles disagree in direction (one too deep, one too early), the knob is skipped with the reason `profiles disagree` in the plan. `--max` counts edits after this merge.
3. **Wave-time guard.** An edit that the plan expects to lengthen waves (enemy hp up, budget up) is not proposed for a death miss while the average median wave time of waves 11-30 is above 18 s; repair and damage edits do not lengthen waves and stay eligible. Say so in the plan's skipped list.
4. Tests for 1-3 (a three-profile batch fixture where all are too deep -> enemy_damage, repair_per_s, repair_delay_s in one plan; disagreement -> skipped; long waves -> budget skipped). `docs/gauntlet-loop.md` table "How a proposal selects edits" updated.
5. Run `node tools/gauntlet/tune.mjs propose --batch=evidence/n23-loop/base-street/batch.json --profile=all --out=build/n23/cycle1-plan.json` (if that batch exists and is complete) and paste the plan's edits and skipped list in your final message. Do not apply.

End with: files changed, commits, commands and results, anything not done and why.
