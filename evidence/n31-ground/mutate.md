# n31-20 mutate scores (HEAD e7939560, tests only, no game code changed)

## rivet_bob.gd (72703154f lines, 20 of 39 mutants sampled)
`node tools/mutate/mutate.mjs --file=features/characters/rivet_bob.gd --max=20 --tests=test_rivet_bob --lines=4-10,19-52,56,60,67,70-71,73-74,77-84,93-95`

score 52.6% = killed 10 / (killed 10 + survived 9); timeout 0, invalid 1; 728 s

Survivors: :19 `_stretch_min` default 1.0->0.0, :21 `_lift_max_cell` default 0.0->1.0 (static defaults overwritten by `_load`,
equivalent unless the table is missing), :35 literal 1.0->0.0, :36 `*`->`/`, :42 literal 0.0->1.0, :50 `>`->`>=`
(boundary, equivalent at lo == hi), :52 `/`->`*`, :73 `not` removed, :79 `/`->`*`. Invalid: :81 `+`->`-`.
Not pinned by a new test this call (out of time): the :35/:36/:52 aim and damping arithmetic is the candidate for a pinning assertion.
