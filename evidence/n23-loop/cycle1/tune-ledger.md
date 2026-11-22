# Gauntlet tune ledger

Plan 8c2cc8227f3420a24ab7ebe4d699798e34557a0505e7de2d682c05ad0800b2be. Matched 29 of 29 before and 30 after runs. The null-salt floor decides each verdict. Matched 29 null runs.

Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.

| Knob | Before → after | Baseline | Measured miss | Target | Confirmation before → after | Pairs | Improvement (CI95) | Null-salt floor (pairs) | Cross-seed floor (pairs) | Deciding mode | Verdict | Deciding rule | Point | Strict | Apply / revert SHA |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|
| rivet.repair_per_s | 10 → 8 | 10 | average median death wave 40 against target 12 (1 deaths, 8 censored as lower bounds) (director: repair instead of enemy_damage, which lives in enemies.json shared with quest 1 and the replays) | 12 | 40 → 40 waves (8 → 8 censored, median uses lower bounds) | 9 | 1.56 (-5.22 to 8.33) | 6 (9) | 13.5* (4) | null-salt | noise | point | noise | noise | — |

## A/A seed pairs

Null-salt pairs each before seed with its null run. Cross-seed pairs adjacent before seeds in each group. The floor is the larger absolute CI95 endpoint for right minus left, with at least 6 pairs. An asterisk marks an estimate below that minimum. Offer entries show take/decline seed pairs.

| Knob | Floor mode | Group | Left seeds | Right seeds |
|---|---|---|---|---|
| rivet.repair_per_s | null-salt | ["average","wheel","greedy"] | 1, 2, 3, 4, 5, 7, 8, 9, 10 | 1, 2, 3, 4, 5, 7, 8, 9, 10 |
| rivet.repair_per_s | cross-seed | ["average","wheel","greedy"] | 1, 3, 5, 8 | 2, 4, 7, 9 |
