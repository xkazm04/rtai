# mutate: project/dev/gauntlet/pressure_rifles.gd, tests test_pressure_takes (n29, brief 04)

Lines 36-41 (`near()`) and 69-85 (`drive()` head, incl. the `turn` pick at 79). `--max=20` (sampled 20 of 30).

Before (HEAD 35d6b40d): killed 13 / (13 + 6 survived) = 68.4 %, 1 invalid, 715 s.
After (HEAD b7f2155de, two new tests): the first 17 mutants of the same sample ran, then the 590 s cap cut the run
(mutant 18+ not reached, line 83/85 mutants were killed before): killed 14 / (14 + 3) = 82.4 % of the 17 reached;
all 6 before-survivors re-ran: 3 now killed, 3 equivalent.

| # | line | mutation | before | after |
|---|---:|---|---|---|
| 1 | 39 | 36 -> 37 | killed | killed |
| 2 | 39 | 180 -> 181 (guard beat) | survived | killed (`test_salvos_start_at_tick_45_and_repeat_each_beat`) |
| 3 | 40 | 1 -> 0 | killed | killed |
| 4 | 40 | 2 -> 3 (sword pair size) | survived | survived: equivalent |
| 5 | 41 | 9 -> 10 | killed | killed |
| 6 | 74 | 45 -> 46 | survived | killed (first shot at tick 45, then +beat) |
| 7 | 75 | 2 -> 3 (weapon_next tick) | survived | survived: equivalent |
| 8 | 75 | and -> or | survived | survived: equivalent |
| 9-17 | 77, 79 | >= -> >, 45 -> 46, and -> or, == -> !=, 0 -> 1, < -> >=, < -> <=, * -> /, `/` -> `*` (turn) | 0 -> 1 survived, rest killed | all killed |

Equivalents:
- 40, `salvo` 2 -> 3 for the sword: `beat` is `posmod(tick - 45, 36)` so it never reaches 36; `beat < salvo * 18` is true
  for beats 0 and 18 either way. Same shots.
- 75, `tick == 2` -> `tick == 3`: the sword switch happens one tick later, 42 ticks before the first shot; nothing
  observes the tick (`test_only_the_sword_takes_switch_to_the_blade` pins the result, not the tick).
- 75, `and` -> `or`: the button would be held every tick of a sword take, but `weapon_next` is edge-triggered
  (`was_pressed`), so the wheel moves once; for the guard takes `tick == 2` presses it once with a single-slot wheel,
  a no-op. No behaviour change.

New pins in `project/tests/unit/test_pressure_takes.gd`: shot ticks (guard6: 45..90 step 9, next salvo +180; blade6:
45, 63, 81, 99) and the blade held only in sword takes (no switch pressed by the guard take).
