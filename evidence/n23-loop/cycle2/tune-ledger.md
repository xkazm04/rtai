# Gauntlet tune ledger

Plan 18a50894ee1390b3bf36af76bd50a0f471c8fe0334f7a5676899ca40668268b8. Matched 23 of 29 before and 24 after runs. The null-salt floor decides each verdict. Matched 29 null runs.

Positive improvement means the measured miss shrank. An empty apply SHA means this branch has no commit for that edit. A revert SHA records an executed undo.

| Knob | Before → after | Baseline | Measured miss | Target | Confirmation before → after | Pairs | Improvement (CI95) | Null-salt floor (pairs) | Cross-seed floor (pairs) | Deciding mode | Verdict | Deciding rule | Point | Strict | Apply / revert SHA |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|
| rivet_repair | × 1.25 (2 knobs) | per knob | average median death wave 40 against target 12 (1 deaths, 8 censored as lower bounds) | 12 | 40 → 40 waves (6 → 7 censored, median uses lower bounds) | 7 | -2.57 (-7.71 to 0) | 6 (9) | 13.5* (4) | null-salt | noise | point | noise | noise | — |

## A/A seed pairs

Null-salt pairs each before seed with its null run. Cross-seed pairs adjacent before seeds in each group. The floor is the larger absolute CI95 endpoint for right minus left, with at least 6 pairs. An asterisk marks an estimate below that minimum. Offer entries show take/decline seed pairs.

| Knob | Floor mode | Group | Left seeds | Right seeds |
|---|---|---|---|---|
| rivet_repair | null-salt | ["average","wheel","greedy"] | 1, 2, 3, 4, 5, 7, 8, 9, 10 | 1, 2, 3, 4, 5, 7, 8, 9, 10 |
| rivet_repair | cross-seed | ["average","wheel","greedy"] | 1, 3, 5, 8 | 2, 4, 7, 9 |
