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

- After keys = main + keys `e1c4b73d9` (`deploy_slots`): all 60 run results (salt 0 and 1) byte-identical to main's
  (the slot order changes which key deploys which ghost, not which ghost the bot deploys). After melee = melee's own merge `4a3ff4b04` (keys + `master_at`
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

### 5. What kills the test player, and when (after melee `4a3ff4b04`; `evidence/n27-pressure/medians/melee/killers.md`)

Last blow per run, salt 0 + salt 1 (20 runs a profile); "s alive" is the median time of those deaths.

**Novice** (median death wave 5): the wave 5 war machine's `stomp` 16 of 20 (wave 5 every time, ~75 s in, ~82 HP
taken in that wave); riot cop 3 (waves 3, 4); SWAT 1.

**Average** (median 8 / 5): `stomp` 9 of 20 (all wave 5); shield robot 2 (wave 9); rocket trooper 3 (waves 3, 3,
10); sentry turret 1, war cannon 1, robot thug 1, patrol cop 1, contractor 1, SWAT 1 (waves 5 to 14).

**Expert** (median 8.5 / 9): shield robot 7 of 20 (waves 9 to 14), sentry turret 6 (waves 7 to 11), rocket trooper 2,
`stomp` 2, riot cop 1, robot gunner 1, war cannon 1.

Tuner `propose` on the after-melee tree (`evidence/n27-pressure/medians/melee/plan.json`), **each measured as a
what-if arm, not applied** (`tools/gauntlet/ablate.mjs`, a temp worktree at `4a3ff4b04`, salt 0, 10 seeds;
`evidence/n27-pressure/medians/whatif/{compare.md,killers.md}`):

| arm | change | novice | average | expert | reads |
|---|---|---:|---:|---:|---|
| after melee | none | 5 | 8 | 8.5 | baseline |
| repair | `gauntlet.json` `rivet.repair_per_s` 10 -> 12.5, `repair_delay_s` 3 -> 2.4 | 5 | 5 | 9 | inside the floor (3.6 / 1.6) |
| budget | `gauntlet.json` `budget.per_wave` 16 -> 13 | 5 | 8.5 | 9 | inside the floor; the deaths move from the stomp to the wave 9 shield robot (average 5 of 10, expert 6 of 10) |

Why the repair lever cannot work: the gauntlet has `repair_in_wave: false` (`project/data/tables/gauntlet.json`), so
Rivet repairs only in the cleared block between waves (`project/features/gauntlet/gauntlet_waves.gd:75`), and the
pilot holds there below 95 % HP (`project/features/gauntlet/gauntlet_walker.gd:22`). Measured: HP at the start of a
wave is a median 99 % of max (10th percentile 78 %, 180 waves). The comparison's "repair share 0 %" is the same fact
(the per-wave telemetry never sees between-wave repair), not a broken repair.

## What does not

PENDING

## What blocked or slowed you (minutes each)

PENDING

## Calls for the owner

1. **The wave 5 stomp is the novice wall.** 16 of 20 novice runs end on the war machine's `stomp` at wave 5 (and 9 of
   20 average runs). The levers, none touched: `enemies.json` war machine `stomp` damage 48, splash 48 in 3.5 m,
   cooldown 1.2 s, `alt_telegraph_s` 0.8. You said you play first and give numbers; this is the number to watch when
   you play wave 5.
2. **Repair between waves only.** `gauntlet.json` `repair_in_wave: false` makes the repair rate almost irrelevant
   (waves start at a median 99 % HP), so the tuner's `rivet_repair` proposal measured inside the noise. If you want
   repair to matter in a fight, the switch is `repair_in_wave`, not the rate.
3. **The plasma sword against paired rifle rounds.** The sword is one 33-tick swing that deflects in 6 ticks; two
   rounds 0.3 s apart always beat it (half of all rounds land mid-swing at 6 m). Keep it (a committed swing is a choice
   with a cost) or give the sword a faster recovery or a second deflect window. Film: `deflect_6m_32.mp4`, still
   `blade_struck_64.png`; contrast take PENDING (call 4).
4. **Dash across the rocket line works.** Two troopers kill a steady circler in 7.1 to 7.7 s in every seed; one dash
   per volley keeps him near full (median 4.6 HP lost in 25 s). Rocket shape A and the 1.1 s lead read as you kept
   them. Film: `trooper_pair_32.mp4`. PENDING: the two seeds that lose 41 to 51 HP after 10 s (call 4).

## Merge notes

- Product files: none. Changed paths: `project/dev/gauntlet/**` (takes, film, seeds, moments; `.uid` committed),
  `project/tests/unit/test_pressure_takes.gd`, `tools/gauntlet/pressure_films.mjs`, `tools/debt/baseline.json`
  (dev_loc accept lines only, through the debt tool), `evidence/**`, `JOURNAL.md`, `REPORT.md`.
- No data row of `enemies.json`, `weapons.json`, `combat.json` or `gauntlet.json` changed; no replay, tape or digest
  moved.
- `tools/debt/baseline.json`: a conflict with other lanes' dev_loc rises is expected; run
  `node tools/debt/merge_baseline.mjs`, then `--update`.
- The measurement merges (keys `e1c4b73d9`, melee `4a3ff4b04`) lived in a scratch worktree only.

## Next steps

PENDING

## Builder ledger

| call | tag | minutes | cost | verdict |
|---|---|---:|---:|---|
| 1 | takes | 65 | $3.22 | accepted |
| 2 | measure | 75 (cap) | $1.31 | accepted |
| 3 | films | 53 | $2.74 | accepted |
| 4 | contrast | PENDING | | |
