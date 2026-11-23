# Kerf boss cap mutation results

**19/20 planted faults caught (95.0%)**. The run sampled 20 of 30 candidates on changed lines `47-55,59-78` of `features/souls/ghost_deploy_strike.gd`. It ran against commit `83cd62ab0` in an isolated snapshot. The unmodified tests passed.

| Line | Operator | Change | Verdict |
|---:|---|---|---|
| 53 | arith | `*` to `/` | killed |
| 54 | boundary | `>` to `>=` | survived |
| 55 | arith | `*` to `/` | killed |
| 60 | cmp_flip | `==` to `!=` | killed |
| 60 | cmp_flip | `==` to `!=` | killed |
| 61 | boolean | `true` to `false` | killed |
| 62 | cmp_flip | `!=` to `==` | killed |
| 64 | cmp_flip | `!=` to `==` | killed |
| 64 | boolean | `and` to `or` | killed |
| 64 | cmp_flip | `==` to `!=` | killed |
| 65 | boolean | `true` to `false` | killed |
| 66 | boolean | `not` to `(removed)` | killed |
| 66 | boolean | `not` to `(removed)` | killed |
| 73 | boolean | `not` to `(removed)` | killed |
| 73 | boolean | `and` to `or` | killed |
| 73 | literal | `0` to `1` | killed |
| 73 | cmp_flip | `==` to `!=` | killed |
| 75 | return | `number % waves._composer.boss_every == 0` to `not (number % waves._composer.boss_every == 0)` | killed |
| 75 | literal | `0` to `1` | killed |
| 76 | boolean | `false` to `true` | killed |

The score divides killed mutants by killed plus survived. Parse-invalid mutants and timeouts are reported separately.

Invalid: 0. Timeouts: 0.

Test files: `test_ghost_deploy`, `test_ghost_deploy_attacks`, `test_ghost_deploy_bot`, `test_ghost_deploy_mastery`, `test_ghost_deploy_tally`, `test_ghost_deploy_view`, `test_ghost_number_keys`, `test_kerf_boss_cap`.
