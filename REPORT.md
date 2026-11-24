# REPORT n27 lane `pressure` (2026-11-24): two-trooper circling and a 6 m deflect, filmed; the numbers after the join

Branch `n27-pressure`, worktree `gtai-wt/n23-loop`, cut from `main` `a3b3f1466`. Director: Opus 5.5; builder: Claude
Sonnet 5.5 (`gtai-n27/tools/builder.mjs`). **No balance value changed** ("I play first and give numbers"): every
change in this branch is a dev take, a test, a tool or evidence. Masters: `C:\Users\kazda\kiro\gtai-masters\n27\pressure\`
(`frames.json`, best first).

Gate: PENDING (`node tools/gate/run.mjs --rev=HEAD`, line and `gate.json` path go here).

## What works

### 1. Median death waves: main, after keys, after melee (10 seeds, salts 0 and 1, greedy pick, wheel controls, 40 waves)

| profile | main `a3b3f1466` s0 / s1 | after keys `e403c4a40` s0 / s1 | after melee `4a3ff4b04` s0 / s1 | paired null floor (main / melee) |
|---|---:|---:|---:|---:|
| novice | 5 / 5 | 5 / 5 | 5 / 5 | 0.3 / 0.3 |
| average | 6 / 5 | 6 / 5 | 8 / 5 | 2.6 / 3.6 |
| expert | 8.5 / 9 | 8.5 / 9 | 8.5 / 9 | 1.8 / 1.6 |

- After keys = main + keys `e1c4b73d9` (`deploy_slots`): byte-identical results to main in salt 0 (the bot presses
  actions, the slot order does not reach its runs). After melee = melee's own merge `4a3ff4b04` (keys + `master_at`
  30, `mastery_free`, `per_boss_cut` 3): 20 of 30 salt 0 results differ from main, but no median moves beyond its
  floor (average +2 in salt 0, +0 in salt 1, floor 3.6). n26's pre-keys numbers were 5/5, 7.5/5, 8.5/9.
- Evidence: `evidence/n27-pressure/medians/{main,keys,melee}/{salt0,salt1}/`, `floors.md`, `killers.md`;
  `evidence/n27-pressure/medians/melee/compare_s0.md` (+ `.html`).
- These are scratch merges for measurement only; this branch never merged another lane.

### 2. Two rocket troopers, Rivet circling at 10 m (film `trooper_pair_32.mp4`, 25.0 s, 1920x1080, 60/1)

Seeds 1 to 10 (`evidence/n27-pressure/takes/seeds.md`):

| take | rockets | direct on his body | splash beside him | HP lost | down |
|---|---:|---:|---:|---:|---|
| steady circle | 80 | 9 (11.3 %, [6.0, 20.0]) | 61 (76.3 %, [65.9, 84.2]) | 100 every seed | 10 / 10, at 7.1 to 7.7 s |
| circle + a dash across each line | 248 | 1 (0.4 %, [0.1, 2.2]) | 42 (16.9 %, [12.8, 22.1]) | median 4.6 | 0 / 10 |

- The steady circle dies to blasts beside him, not rockets on his body (shape A + lead work as the owner kept them).
- One dash per two-rocket volley: the troopers fire two rockets one tick apart every 114 ticks; the second press falls
  inside the first dash (10 ticks + 40-tick cooldown), so 13 dashes for 26 rockets.
- Stills: `pair_dash_cross_64.png` (mid-dash, two rockets on the spot he left), `pair_circle_fatal_64.png` (HP 8.9,
  13 ticks before he falls), `pair_dash_32.png`, `trooper_pair_64.png`.

### 3. Riflemen at 6 m against the guard and the plasma sword (film `deflect_6m_32.mp4`, 39.67 s, 1920x1080, 60/1)

| weapon | fired | turned back | returns that hit a shooter | share [Wilson 95 %] | measured curve at 6 m |
|---|---:|---:|---:|---:|---:|
| guard | 780 | 394 | 99 | 25.1 % [21.1, 29.6] | 24.3 % (inside) |
| plasma sword | 1300 | 334 | 91 | 27.2 % [22.7, 32.3] | 30.6 % (inside) |

- The sword turns back only 334 of 1300 rounds: the shipped sword is single-swing, 33 ticks (8 + 6 active + 19), and
  the riflemen fire pairs 18 ticks apart, so the second round of every pair arrives mid-swing (650 of 1300, exactly 65
  in every seed). PENDING: the spaced-cadence contrast (call 4).
- Stills: `guard_return_64.png`, `blade_struck_64.png`, `blade6_32.png`, `deflect_6m_64.png`.

### 4. Mutate (`evidence/n27-pressure/mutate/scores.md`)

| file | lines | killed | survivors |
|---|---|---:|---|
| `project/features/gauntlet/gauntlet_combat.gd` (seed 9 stall fix) | 12-16, 18, 53-66, 120, 122, 123 (28 mapped tests) | 14 / 15 (93 %) | line 18 initial `_last_damage_tick`, overwritten when a wave goes live: equivalent |
| `project/features/gauntlet/bot/bot_arena_moves.gd` | 7-15, 54 (2 named tests; only 4 mutants on those lines) | 3 / 4 (75 %) | line 13 input index 0 -> 1 with a one-entry input: equivalent |
| `project/dev/gauntlet/pressure_pair.gd` (take) | sample of 12 | 7 / 12 (58 %), then 4 / 5 on lines 83, 110 after two asserts | 3 equivalent, 1 needs a tick pin |

### 5. What kills the test player, and when (after melee, salt 0 / salt 1; `medians/melee/killers.md`)

PENDING what-if numbers.

## What does not

PENDING

## What blocked or slowed you (minutes each)

PENDING

## Calls for the owner

PENDING

## Merge notes

PENDING

## Next steps

PENDING

## Builder ledger

| call | tag | minutes | cost | verdict |
|---|---|---:|---:|---|
| 1 | takes | 65 | $3.22 | accepted |
| 2 | measure | 75 (cap) | $1.31 | accepted |
| 3 | films | 53 | $2.74 | accepted |
| 4 | contrast | PENDING | | |
