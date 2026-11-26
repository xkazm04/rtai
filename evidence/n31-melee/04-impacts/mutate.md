# n31 melee 04 impacts: mutate scores (builder 06)

Run at HEAD a6efb133 (wound run at 5018d571, same files), `--max=20 --timeout=90`, lane lock held per run.
Score = killed / (killed + survived); invalid and timeout excluded. Samples are 20 of the file's mutants, not all.

| file | tests | mutants run | killed | survived | invalid | score |
|---|---|---|---|---|---|---|
| `features/combat/react/blade_marks.gd` | test_blade_marks, test_claw_marks | 6 of 20 (206 total) | 0 | 6 | 0 | 0/6 = 0% (INCOMPLETE) |
| `features/combat/react/shield_sparks.gd` | test_shield_sparks_melee | 20 of 72 | 11 | 8 | 1 | 11/19 = 57.9% |
| `features/combat/weapons/gun_fx_wound.gd` | test_gun_fx_wound | 20 of 29 | 8 | 11 | 1 | 8/19 = 42.1% |

## blade_marks.gd (incomplete)
Baseline took 261 s on the contended machine; my outer 540 s cap killed the run after mutant 6 (the 7th was an
infrastructure failure, exit 143, from that kill). No json was written; the six results are from the progress log
(`build/n31/06/blade.err`). Not rerun: past the 04:25 cutoff. The 0% is six draws, not a score for the file.
Survivors: :53 `+ -> -`, :53 `0.5 -> 1.5` (stroke endpoint p1), :75 `1.0 -> 0.0` (fade alpha), :78 `/ -> *`
(bead spacing k), :79 `+ -> -` (bead position), :80 `+ -> -` (bead radius). All are drawing geometry and
alpha in the view code; the headless tests check that marks are made and how many, never the pixels or their
placement, so these are not seen. Likely view-only (a film or a pixel probe would see them, a unit test does not).

## shield_sparks.gd survivors
- :36 `!= -> ==` (blood/at guard) and :37 delete `throw(blood, at, dir)`: the blood throw on a blocked hit is not asserted (the test checks sparks, not the blood throw).
- :50 `false -> true` (`wounded.connect(... bind(false))`): the wounded-path flag is not distinguished by any test.
- :64 `return 0 -> 1` and :68 `- -> +` (fallback direction `-victim.facing`): the zero-length direction branch is not exercised.
- :77 `kind == 1` literal `1 -> 0`: kind-1 branch (robot variant) not driven.
- :102 `h.id == victim -> !=` and :103 `* -> /` (face point position, px scaling): the splash position is view-only and not asserted.
Invalid: :112 delete `fx.splash(...)` (does not parse or lint as a bare delete).

## gun_fx_wound.gd survivors
- :22 delete `_last.clear()` and :28 `!= -> ==` (weak-ref check): reset/cache state with no test that reuses an instance.
- :30 `not` removed (`not blood.bleeds()` guard), :32 `false -> true` (`flick` default), :33 `return 0 -> 1`, :35 `not` removed (`admit`), :36 `return 0 -> 1`: the early-out guards return a count; the tests only check the happy path, so a wrong early-out count is not caught.
- :39 `and -> or` (`robot and blood.oil != null`) and :42 `2 -> 3`, `1 -> 0` (the return count for robot / flesh): returned count is not asserted.
- :41 `* -> /` (`at * PX_PER_M` splash position): view-only position, the test does not read the splash call.
Invalid: :41 delete `to.splash(...)`.
Killed: the `admit` gap/tick arithmetic at :48-49 and the `or -> and` at :30.

## Not done
- blade_marks.gd full 20 (see above); `--max` beyond 20 for all three. Mutate.json of blade is empty.
- No tests or product code were changed.

## 06b re-run
Pin tests added in commit 2c6cf0dd3 (`test_gun_fx_wound.gd`: 6 tests on the early-out counts 0, human 1, robot 2, robot without oil, reuse after `use()`, dead blood ref; `test_shield_sparks_melee.gd`: 4 tests on the blocked-round blood throw, the wounded/kill_landed lethal flag, the zero-length fallback direction, the kind counts). `run_unit --select=test_gun_fx_wound,test_shield_sparks_melee`: 17 passed, 0 failed.
Mutate re-run of `gun_fx_wound.gd` (`--max=20 --tests=test_gun_fx_wound`, 05:12-05:21, own `--worktree` because builder 04g's mutate held the default temp dir) was killed by the 560 s outer cap before any mutant result: no new score. The old score (8/19 = 42.1%) stands until a re-run; the shield_sparks.gd re-run was not attempted.
