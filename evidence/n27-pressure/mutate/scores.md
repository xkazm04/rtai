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
