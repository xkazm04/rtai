# n27 pressure: mutate scores (HEAD cca975316, default single-line mutants, killed / (killed + survived))

Raw outputs: `combat.json`, `moves.json`, `pair.json` (+ `.err` logs). No tests were added: time ran out first.

## 1. `features/gauntlet/gauntlet_combat.gd` lines 12-16,18,53-66,120,122,123: 14 / 15 killed (93 %)

Oracle: the 28 mapped tests (baseline 435 s). One survivor:

- line 18 `var _last_damage_tick: int = 0` literal `0 -> 1`: the initial value is always overwritten by the `wave_live` setter (`_last_damage_tick = tick` when a wave goes live), and `report_bot_freeze` returns false while `wave_live` is false. Equivalent in practice; no test should catch it.

## 2. `features/gauntlet/bot/bot_arena_moves.gd` lines 7-15,54: 3 / 4 killed (75 %)

Oracle: `--tests=test_gauntlet_kerf_wall,test_gauntlet_bot_arena` (the mapped set was too slow for the time left; only 4 mutants were generated). One survivor:

- line 13 `PlayerCommand.decode(input, 0, actions)` literal `0 -> 1`: the second argument is the input index; the `TickInput` packed here has one entry, so the aim decodes the same. Equivalent for the single-input case; a test would have to pass a second input, which this helper never does.

## 3. `dev/gauntlet/pressure_pair.gd` (12 of 61 mutants, `--max=12`, `--tests=test_pressure_takes`): 6 / 12 killed (50 %)

Survivors (all dev measurement code; `test_pressure_takes` checks launches, hit share, death and survival, not these internals):

| line | mutation | should a test catch it? |
|---:|---|---|
| 14 | `first_launch` literal `0 -> 1` | No: only the summary's `first_launch` initial, overwritten at the first launch. |
| 33 | `at + Vector2 -> at - Vector2` (trooper spots) | No: the two troopers swap places; the layout is mirror-symmetric. |
| 46 | clamp `0.6 -> 1.6` | Weak: the pull to the circle radius is never saturated in the 10 m steady circle. A test that starts Rivet far off the circle would catch it. |
| 49 | `tick >= _due[0]` -> `>` | No: a one-tick shift of the dash. Only a test pinning the dash tick would catch it. |
| 53 | `side.dot(move) >= 0.0` literal `0.0 -> 1.0` | Weak: only changes which perpendicular side is picked; the take still survives. A test comparing the dash direction would catch it. |
| 72 | `10 * TICK_RATE` `* -> /` | Yes, cheaply: `hp_at_10s` is then read at the wrong tick (it is only reported, never asserted). An assertion on `summary()["hp_at_10s"]` in `test_pressure_takes` would kill it. |

Not done in this call: the optional re-run after adding tests (none were added), and the other 49 untried `pressure_pair.gd` mutants.

## 3b. `dev/gauntlet/pressure_pair.gd` after the n27 pressure call 3 rewrite (damage split, `--max=12`, `--tests=test_pressure_takes`)

Beside call 2's 6 / 12 (50 %) for the old file: **7 / 12 killed (58.3 %)** at HEAD a382890e5 (sample of 12 from 82 mutants; the file grew, so the sampled lines are different ones; 361 s).
Survivors of that run: line 43 `at + Vector2(-RADIUS_M, 0)` `+ -> -` (Rivet starts on the mirror side; equivalent, the circle is symmetric), line 73 `first_launch > 0 -> >=` (a tick is never 0; equivalent), line 83 `tick == 10 * TICK_RATE` `== -> !=` (hp_at_10s was still plausible at the end of the take), line 107 `dealt <= 0.0 -> 1.0` (only differs for a blast under 1 HP; no take produces one), line 110 `direct += 1 -> -=` (the circle test only checked the damaging share).
Call 2's two cheap kills are in: the radius pull (old line 46) is pinned by `test_circle_pulls_back_to_the_radius_from_either_side` (starts 20, 9 and 4 m off the circle); `hp_at_10s` (old line 72) is pinned by the dash test, which reads his HP at tick 600 itself.
After adding the pin for line 83 and `direct >= 1` in the circle test (commit 72c9e1754), `--lines=83,110`: **4 / 5 killed (80 %)**; line 83 `10 -> 11` survived (his HP at tick 660 equals the one at 600 in seed 1; a test pinning the tick itself would kill it). The 12-mutant sample was not re-run in full; lines 83 and 110 account for 2 of its 5 survivors, so the full sample would now be at least 9 / 12 if those two mutants are the same ones (not measured).

## 3c. `dev/gauntlet/pressure_rifles.gd`, the `blade6_spaced` change (n27 pressure call 4)

`--max=10 --lines=37-45,68-76 --tests=test_pressure_takes` at HEAD 16ae1ea1 (10 sampled of 13 mutants in those lines; 345 s): **4 / 10 killed (40.0 %)**. The `--lines` range was meant to cover the new spacing lines but missed the shooter-rotation lines 81-82 (`var turn: int = fired if spaced else beat / gap_ticks`, `_shots[turn % ...]`); those were not mutated.

Killed: line 39 `fan_rad 0.5 -> 1.5`, line 40 `reactive = true -> false`, line 42 `1 if spaced -> 0` (the spaced salvo of one round), line 71 `_hp.append(cop.hp)` deleted.
Survivors, all in the guard or shipped-pair values the new tests do not pin: line 41 `beat_ticks` guard 180 -> 181 (equivalent for the share), line 42 sword pair `2 -> 3` (the shipped pair test only checks that arrivals come closer than 34 ticks, which a triple also does), line 42 guard salvo `6 -> 7`, line 43 guard `gap_ticks 9 -> 10`, line 76 `tick - 45 -> tick + 45` and `45 -> 46` (the take start offset: only shifts every beat, equivalent for the counts). A test pinning `blade6`'s `fired == 130` and the guard's salvo would kill the pair and salvo survivors; not added in this call.
