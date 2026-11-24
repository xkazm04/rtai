# mutate: pressure_rifles.gd, tests test_pressure_takes (commit 55f8d0778), partial

Stopped at the time limit after 7 of 12 mutants (baseline alone took 330 s on the loaded machine): killed 3 / (3 + 4 survived) = 43 %.
Lines asked: 36-41 and 69-85 (note: 36-41 are `near()`, 69-85 are `drive()`'s head; the `turn` line (~line 79) was mutant 8 or later and was NOT reached).

| # | line | mutation | result |
|---|---:|---|---|
| 1 | 39 | 36 -> 37 | killed |
| 2 | 39 | 180 -> 181 (guard beat) | survived |
| 3 | 40 | 2 -> 3 (guard-side salvo literal; sword uses 1/2) | survived |
| 4 | 41 | 9 -> 10 | killed |
| 5 | 74 | 45 -> 46 | survived |
| 6 | 75 | and -> or | survived |
| 7 | 77 | >= -> > | killed |

Not run: the `turn` pick line, which the new `fired_by` pin ([44, 43, 43], [22, 22, 21], [26, 26, 26]) is aimed at.
