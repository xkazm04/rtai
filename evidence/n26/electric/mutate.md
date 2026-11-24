# Electric robot finisher mutation results

**9/9 planted faults caught (100.0%)**. The run sampled 10 of 56 candidates on changed lines `1-103` of `features/player/robot_finish.gd`. It ran against commit `16910ec6e` in an isolated snapshot. The unmodified tests passed.

| Line | Operator | Change | Verdict |
|---:|---|---|---|
| 37 | cmp_flip | `==` to `!=` | killed |
| 40 | boolean | `and` to `or` | killed |
| 41 | boolean | `false` to `true` | killed |
| 54 | cmp_flip | `!=` to `==` | killed |
| 58 | boolean | `and` to `or` | killed |
| 65 | boolean | `not` to `(removed)` | killed |
| 67 | boolean | `or` to `and` | killed |
| 82 | delete | `_hold(arena, target, machine_stun_ticks)` to `pass` | killed |
| 84 | delete | `arena.damage(target, amount, killer, id)` to `pass` | invalid |
| 95 | cmp_flip | `!=` to `==` | killed |

The score divides killed mutants by killed plus survived. Parse-invalid mutants and timeouts are reported separately.

Invalid: 1. Timeouts: 0.

Test files: `test_electric_contacts`, `test_player_shock`, `test_melee_shutdown`.
