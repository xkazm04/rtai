# Melee finisher mutation results

**9/10 planted faults caught (90.0%)**. The run sampled 10 of 25 candidates on changed lines `11,14,18-23,30,40,62,77,90-94` of `features/player/melee_lethal.gd`. It ran against commit `468470a04` in an isolated snapshot. The unmodified tests passed.

| Line | Operator | Change | Verdict |
|---:|---|---|---|
| 20 | boolean | `or` to `and` | killed |
| 30 | cmp_flip | `!=` to `==` | killed |
| 40 | return | `arch.body == &"human" and not _protected.has(arch.id)` to `not (arch.body == &"     " and not _protected.has(arch.id))` | killed |
| 40 | cmp_flip | `==` to `!=` | killed |
| 40 | boolean | `and` to `or` | killed |
| 62 | boolean | `not` to `(removed)` | killed |
| 62 | boolean | `not` to `(removed)` | killed |
| 77 | boolean | `or` to `and` | survived |
| 92 | boolean | `and` to `or` | killed |
| 92 | boolean | `or` to `and` | killed |

The score divides killed mutants by killed plus survived. Parse-invalid mutants and timeouts are reported separately.

Invalid: 0. Timeouts: 0.

Test files: `test_claw_rake`, `test_melee_lethal`, `test_melee_lethal_pit`, `test_melee_lethal_variants`.
