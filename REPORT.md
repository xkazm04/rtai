# REPORT - lane loop (n23, 2026-11-22)

DRAFT (session 5, 06:50). PENDING marks what the running batches still fill in; the final version is written at 09:40.

Branch `n23-loop`, cut from `main` `76111adec`. Evidence under `evidence/n23-loop/`.

## The before page (main `76111adec`, combined game, wheel controls)

Batches: `evidence/n23-loop/base-greedy/` (20 seeds x 3 profiles, greedy picks, 60/60 ok, `report.md`),
`evidence/n23-loop/base-random/` (average, random picks, 20 seeds, `report.md`),
`evidence/n23-loop/base-null-salt1/` (average greedy, bot salt 1, the neutral rerun). Tick cap 72000 (20 sim minutes).

| Profile / pick | Median wave reached | P25..P75 | Lethal deaths | 90 s timeouts | Alive at the cap |
|---|---:|---|---:|---:|---:|
| novice / greedy | 13.5 | 10..20 | 19 | 1 | 0 |
| average / greedy | 36 | 34..37 | 1 | 2 | 17 |
| expert / greedy | 36 | 34..38 | 0 | 3 | 17 |
| average / random | 35 | 35..36 | 0 | 2 | 18 |

- **Separation:** novice is separated from the others (13.5 vs 36); average and expert are NOT: both reach the
  tick cap at about wave 36, so their "wave reached" measures kill speed in 20 sim minutes, not survival.
  Random picks are not harder than greedy (35 vs 36).
- **Wave time** (average, median s; target 15): waves 1-4 5.6-8.5, wave 5 (first boss) 19.1, 7-8 13, 11-20 21-34,
  21-30 33-53, 31+ 46-52. Early waves are too short, every wave after 9 is too long.
- **Who kills** (novice, 19 lethal deaths): war machine stomp 7, shield robot 6, rocket trooper 5, sentry 1;
  8 of 19 on boss waves 5/10/15/20.
- **Damage against repair** (median per wave): average 0.12 / 0.71 / 0.94 / 0.99 HP/s in wave bands
  1-10 / 11-20 / 21-30 / 31+, expert 0.09 / 0.56 / 0.59 / 0.56, against an in-wave repair of 10 HP/s after 3 s
  without damage (`combat.json` rivet), 13.75 HP/s with greedy regen picks by wave 21. Expert minimum HP per wave
  86-99 % of max; repair undid 100 % of each wave's damage (median).
- **Guard / roll / cover** (average, per wave median): deflects 4 / 8 / 12.5 / 17, rolls 1 / 7 / 11 / 15,
  cover ticks 0 / 18 / 33 / 28 (bands as above).

### Why nobody dies (ablations, `evidence/n23-loop/ablate/summary.md`)

Average greedy, seeds 1-2 only (the deadline cut it from 10), control = archived seeds 1-2 (waves 37, 35, alive).

| Arm | Deaths / seeds | Median wave reached |
|---|---:|---:|
| control | 0 / 2 | 36 |
| repair 3 HP/s after 6 s | 2 / 2 | 20 |
| repair off | 1 / 2 | 6.5 (seed 1 stalls: the bot waits to rest, a bot artifact) |
| no stat picks | 1 / 2 | 21 |
| enemy weapon damage x2 | 1 / 2 | 28.5 |
| guard off | 0 / 2 | 32 |

The causes, largest first: (1) **in-wave repair** (10 HP/s, ten times the damage taken per second), (2) **stat picks
stacking hp and regen** to x1.375, (3) **low enemy damage**. The guard is minor. Repair is a `combat.json` number
shared with quest 1: the tuner reaches it only through street's gauntlet override (`NEED street` 01:06).

### After the street merge (stacked waves, budget in tenths, gauntlet repair override)

Batch `evidence/n23-loop/base-street/` (street merged at `2b2ff79d4`, tools at `ccfc29df0`), greedy wheel, 10 seeds
x 3 profiles, every run bounded at 40 waves (`--waves=40`: a run alive at 40 is censored there; the street merge raised
the tick cap to 216000 and an uncapped average run took 8-10 min). Null salt 1 rerun: `evidence/n23-loop/base-street-salt1/`.

| Profile | Runs | Median death wave | P25..P75 | Lethal deaths | Censored at 40 | Null floor (pairs) |
|---|---:|---:|---|---:|---:|---:|
| novice | 10 | 14 | 11..23 | 10 | 0 | 8.5 (10) |
| average | 9 (1 run hung) | >= 40 | 40..40 | 1 (wave 22) | 8 | 6 (9) |
| expert | 10 | >= 40 | 40..40 | 0 | 10 | 0 (10) |

- Stacking did not make runs end in death: the 90 s timer fired on 1 wave in 29 runs, because a wave lasts 35-48 s from
  wave 11 on (median, average: 11 / 20 / 35 / 40 / 48 s in bands 1-4 / 6-10 / 11-20 / 21-30 / 31-40).
- Average and expert are still not separated (both censored at 40); novice is (14).
- Damage taken 0.4-1.1 HP/s per wave against the gauntlet repair of 10 HP/s after 3 s (unchanged values).

### After the controls and moves merges (the merged game, `548989d7e`)

Batch `evidence/n23-loop/moves/on/` (controls @ `61c382e3f` + moves @ `73eec563c` merged on the street merge, every move
`enabled`, the bot keeps its own blast clearance and uses the four moves), greedy wheel, 10 seeds x 3, `--waves=40`.

| Profile | Runs | Median death wave | P25..P75 | Lethal deaths | Censored at 40 | Killers |
|---|---:|---:|---|---:|---:|---|
| novice | 10 | 12 | 10..13 | 10 | 0 | rocket 5, shield_robot 3, patrol_cop 1, stomp 1 |
| average | 10 | >= 40 | 40..40 | 0 | 10 | none |
| expert | 10 | >= 40 | 40..40 | 0 | 8 at 40, 2 stalled at 33 (soft-lock, below) | none |

- Average wave seconds (median): 11.4 / 14.4 (wave 5 boss) / 21.5 / 28.0 / 29.8 / 37.9 in bands 1-4 / 5 / 6-10 / 11-20 /
  21-30 / 31-40. Damage taken 0.08-0.93 HP/s against the 10 HP/s repair; the boss wave 5 hurts most (2.97 HP/s, 47 HP).
- Boss waves (each has a war machine now; average, median): main 39.3 s, street merge 32.8 s, merged game **26.0 s**: the
  owner's 25-30 s boss wave is met on the merged game.
- **Soft-lock** (new): 4 of 30 merged runs (average 8, 9; expert 1, 9) and 1 of 30 cycle-1 runs freeze after a timed-out
  wave: the next wave is announced in the held block with 2-3 leftovers alive, nothing spawns, no timer fires, no damage
  until the 216000-tick cap (`evidence/n23-loop/moves/on/logs/expert-1/`). 0 of 60 on the street merge. `NEED street`
  in JOURNAL 07:08 with the replay command.
- Rivet's own blasts: 0 self damage measured in 84 smoke waves (Astra controls-moves smoke) after the bot's blast clearance.

## The noise floor by a neutral change

DECISION: the neutral change is a **bot salt** (`--bot-salt=<n>`) on the test player's private streams (aim, defence,
forms, pick); the world RNG and every balance number are untouched, so the game's difficulty is the same and only the
player's luck is resampled. Proof it differs: salt 1 changes 20 of 20 result files; `--bot-salt=0` is byte-identical
to no flag. Same batch (average greedy, seeds 1-20), null-salt vs the old cross-seed floor (`base-null-salt1/floors.md`):

| Metric | Null-salt floor (pairs) | Cross-seed floor (pairs) |
|---|---:|---:|
| wave 5 s | 3.38 (20) | 24.35 (10) |
| wave 10 s | 7.77 (20) | 16.17 (10) |
| wave 15 s | 10.07 (20) | 22.45 (10) |
| wave 20 s | 11.48 (19) | 22.47 (10) |
| wave 25 s | 10.17 | 27.42 |
| wave 30 s | 6.28 (17) | 22.03 |
| wave reached | 1 (20) | 4 (10) |

Re-judged n22's reverted cuts: `war_machine.hp` 60 -> 48 (gain 13.67 s, CI95 4.75..19.08 at wave 20) clears the
null floor of 11.48 s with its mean, not with its CI low; `shield_robot.hp` 10 -> 8 (3.67 s, CI95 1.72..6.6 at wave 13)
stays under the 6.73 s floor: noise either way.

## The tuning ledger (death wave score, null-salt floor, point verdict)

Before = `evidence/n23-loop/base-street/` (street tree `ccfc29df0`), null = `base-street-salt1/`, after = same seeds and tree
with the plan's edit (`tools/gauntlet/ablate.mjs`, a temp worktree), 10 seeds x 3 profiles, `--waves=40`. Clamps stand
(x0.8..1.25 a night, x0.5..2.0 from `tools/gauntlet/baseline.json`). Shared tables (`enemies.json`, `combat.json`,
`weapons.json`: quest 1 and the replays read them) are off limits by default; the gauntlet-only knobs are `gauntlet.json`.

| Cycle | Change | Profile: before -> after median death wave | Improvement (CI95) | Null floor (pairs) | Verdict | Ledger |
|---:|---|---|---:|---:|---|---|
| 1 | `rivet.repair_per_s` 10 -> 8 | novice 14 -> 16; average >= 40 -> >= 40 (8 -> 8 censored); expert >= 40 -> >= 40 | average 1.56 waves (-5.22..8.33) | 6 (9) | **noise, reverted (never applied)** | `evidence/n23-loop/cycle1/tune-ledger.md` |
| 2 | `rivet_repair` f 1.25: per_s 10 -> 8 and delay 3 -> 3.75 | PENDING | | | | `evidence/n23-loop/cycle2/` |

The tuner's first proposal was `enemy_damage` x1.25 (23 numbers in `enemies.json`); the director replaced it by hand
because the table is shared and a kept change would move shipped replays (`evidence/n23-loop/cycle1/plan.json` `miss`).

**One night's full clamp at once** (diagnostic, not a tuner cycle, `evidence/n23-loop/stack-clamp/`): every gauntlet-only
knob at its night limit toward harder (repair 8 HP/s after 3.75 s, budget base 180 -> 225 and per_wave 16 -> 20,
`max_alive` 40 -> 50, cost patrol_cop 15 -> 12 and war_machine 200 -> 160), merged game, novice + average 8 seeds, against
`moves/on`. PENDING.

## The four moves, off and on (merged game, average, same seeds)

On arm `evidence/n23-loop/moves/on/`, off arms `evidence/n23-loop/moves/<id>-off/` (the row's `enabled` = false through
`ablate.mjs --set`, everything else equal), 10 seeds, `--waves=40`. Uses with an effect over the 10 on runs
(`moves{}` per wave): average Kerf blink 672, Ohm short-circuit 340, overkill carry 2250, Tonnage armour crack **7**
(novice 62 / 62 / 38 / 9). Tonnage has no off arm: 7 uses in 400 waves cannot move a wave time, and that is the finding
(the bot is rarely in Tonnage beside a war machine in its stomp recovery). n22's gaps (waves with the enemy vs without):
turret 38.3 vs 10.7 s, war machine 43.8 vs 26.0 s, shield robot 41.2 vs 12.7 s.

PENDING: `node tools/gauntlet/move_table.mjs --off=... --on=... --move=<id>` per move.

## The before and after page

`tools/gauntlet/compare.mjs` (Astra call 7) puts the batches side by side as markdown + one self-contained HTML page:
PENDING (`evidence/n23-loop/compare.md` / `.html`, filmed for the owner).

## Proposals (for the owner's pick; nothing built)

1. **A wave timer that shortens with depth.** The 90 s timer started the next wave on 1 of 919 waves on the street merge
   (`evidence/n23-loop/base-street/`): from wave 11 a wave lasts 28-48 s (median), so "the next wave starts on top" almost
   never happens and stacking cannot kill. Proposal: 45 s from wave 6, or 3x the wave's median clear time; street's dev
   `--wave-timeout=12` already showed 2-3 waves alive and a death on wave 16 (street JOURNAL 05:44).
2. **Repair that does not refill inside a wave.** Repair is the first cause of survival (ablation: 3 HP/s after 6 s
   killed both average seeds at wave 20; control alive at 35-37). Damage taken is 0.6-1.2 HP/s against 10 HP/s repair.
   Proposal: repair only between waves (or a repair pool per wave), so damage adds up across a wave.
3. **Enemies that punish a moving player.** Average and expert are not separated (both censored at 40 on every merge
   tonight): the expert bot's better aim and timing buy nothing when nothing threatens it. In the owner's words, an
   enemy should be harder by what it does to a moving player: a leading shot (aim at the predicted position), a fast
   lunge with a short tell, or area denial (a slow zone or a burning patch) that forces a choice. Novice dies to rocket
   troopers (5 of 10) and shield robots (3): the moves that hurt are the ones that reach.
4. **Kerf's slice one-shots every new enemy, the war machine included** (moves lane 05:56: kerf GUARD-row slice 99 vs
   war_machine hp 26 at front 0.5). The boss wave of 25-30 s is not reachable while one slice ends it; the boss wave
   ran 14.4 s (median, average, merged game, wave 5). Proposal: a per-enemy cap on slice damage (bosses take a fraction),
   or the boss hp scaled with wave depth.
5. **A gauntlet-only enemy damage multiplier** (`gauntlet.json` `enemy_damage_k`, street brief 08 is building it from my
   NEED of 05:53). Enemy damage is the third cause (x2 ablation: 1 of 2 average seeds died, median wave 28.5 vs 36); today
   it is reachable only in `enemies.json`, which is shared with quest 1 and the replays, so the tuner may not move it.

## What works

- **The noise floor by a neutral change** (item 2): the bot salt, proven different (20/20 result files) and proven
  neutral (`--bot-salt=0` byte-identical); the null floor is about half the cross-seed floor with twice the pairs
  (`evidence/n23-loop/base-null-salt1/floors.md`); every tuner ledger row carries both.
- **The before page** (item 1): 60 + 20 runs on main, why nobody dies with numbers (repair, stat picks, enemy damage;
  `evidence/n23-loop/ablate/summary.md`).
- **The tuner on the combined game** (items 3, 5): death-wave score with censoring at the wave limit, targets in
  `tools/gauntlet/targets.json`, budget units read from `budget.unit` (10), the `cost` map, `max_alive`, the gauntlet
  `rivet` repair override, the `rivet_repair` group, shared tables off by default, `ablate.mjs --rev`; Node tests
  `node --test "tools/gauntlet/*.test.mjs"` 75/75 at `3c379596f`.
- **The bot on the merged game** (item 6): blast clearance (0 self damage in 84 smoke waves) and all four moves used
  (`evidence/n23-loop/moves/on/`).
- Mutation: `bot_street_stats.gd` 100 % = killed 5 / (5 + 0) (`build` log quoted in JOURNAL 03:51).

## What does not

- **The profiles are not separated beyond novice.** Novice dies (median wave 12-16 on every tree tonight), average and
  expert are censored at wave 40 on every merge: no tuning step tonight could separate them, because the tuner can only
  read a difference where runs die.
- **No change was kept tonight.** Cycle 1 (`repair_per_s` 10 -> 8) is noise against a floor of 6 waves; with average
  and expert all censored, a 20 % step on one number cannot show. Cycle 2: PENDING.
- **Targets out of reach at this rate.** The game is too easy by 26+ waves for average (>= 40 vs 12) and 20+ for expert;
  at one x0.8 step a night on repair the x0.5 floor (5 HP/s) is reached after 4 nights, and the ablation says even
  3 HP/s after 6 s only brings average to wave 20. PENDING: the stack-clamp arm gives the one-night number.
- `bot_brain.gd` mutation 5/12 killed (Astra call 5): the moves logic is under-tested.
- The 216000-tick cap on the street merge makes uncapped runs cost 8-10 min; tonight's tuning ran bounded at 40 waves.

## What blocked or slowed you

- 45 min: capped runs. The street merge raised the tick cap to 216000; two batches were stopped and re-run with
  `--waves=40` (JOURNAL 04:12, 05:00).
- 20 min: `ablate.mjs` snapshot the moving lane HEAD; a scratch checkout carried cycle 1 until `--rev` landed (05:54).
- 10 min: the git index lock held by Astra's commit hook blocked three JOURNAL commits.
- 15 min: the tuner's first proposal touched a shared table (`enemies.json`); replaced by hand, then guarded in code.

## Calls for the owner

1. **The targets** (`tools/gauntlet/targets.json`, tuned toward tonight): death wave novice 6 / average 12 / expert 20 with greedy
   picks; an ordinary average wave 15 s; a boss wave 25-30 s every fifth wave; two profiles are separated when the deeper
   one's median is at least 3 waves deeper AND it dies later on at least 75 % of shared seeds.
2. **One larger step on in-wave repair.** The night clamp (x0.8 per night, x0.5 floor from the first value) lets
   `rivet.repair_per_s` go 10 -> 8 tonight and reach its 5 HP/s floor only on the fourth night (10 -> 8 -> 6.4 -> 5.1 -> 5). The ablation with 3 HP/s after 6 s killed
   both average seeds (death wave 20, on target's side of 12-20). Asked: allow `repair_per_s` 10 -> 3 and
   `repair_delay_s` 3 -> 6 in one step for the gauntlet only (street's `gauntlet.json` `rivet` block; quest 1 keeps
   `combat.json`).
3. **The verdict rule.** Keep a change when its paired mean clears the same-seed null floor AND its CI95 excludes zero
   (`--verdict=point`, tonight's default), instead of n22's CI-low-above-the-floor (`--verdict=strict`), which counted
   the noise twice and rejected every realistic step. Both verdicts are in every ledger row.
4. **The wave limit for tuning batches.** Tonight every tuning batch stops a run at wave 40 and counts a survivor as a
   lower bound (`--waves=40`, decision line of 2026-11-22). The alternative is the full 216000-tick cap (8-10 min a
   run). Asked: keep 40 until the average profile dies before it.
5. **Kerf's slice against bosses** (proposal 4): the owner's boss design, not the tuner's: the slice row is in
   `ghost_attacks.json`, shared, and one slice ends the war machine.

## Merge notes

- `n23-loop` contains merges of `n23-street` @ `cdacafe98` (`2b2ff79d4`), `n23-controls` @ `61c382e3f` (`895a4964a`) and
  `n23-moves` @ `73eec563c` (`620fb288e`). Those lanes moved on afterwards (at 06:50: street `1cccf5d96` +34, controls
  `1599978eb` +9, moves `f5b32cfe7` +2); loop did not re-merge them so that tonight's batches measure one tree. Merge
  the three lanes first, then loop: loop's own changes are `project/features/gauntlet/bot/**`, `tools/gauntlet/**`,
  `docs/gauntlet-loop.md`, `project/data/tables/test_player.json`, plus one-line call sites `project/dev/gauntlet/gauntlet.gd`
  KNOWN (`--bot-salt`) and `project/boot/launch_args.gd` KNOWN_FLAGS (+1, debt accepted).
- No tuned number is kept, so loop moves no balance number in any table.
- `JOURNAL.md` / `REPORT.md` are per lane: keep each lane's own on an add/add conflict.

## Next steps

1. Merge street's `enemy_damage_k` (street brief 08) and add it to `rivet_repair`'s neighbour group in the tuner; it is the
   lever that does not need a shared table.
2. With the owner's larger repair step (Call 2) the average profile should start dying before 40; then the tuner's
   one-number cycles become readable, and separation of average vs expert can be measured at all.
3. Raise `bot_brain.gd` mutation (5/12) with tests for the move openings.
4. Cycles cost ~45-50 min a 30-run batch at one Godot slot; two slots and 10 seeds give 3-4 cycles a night once runs die.

## Astra ledger

| # | Tag | Minutes | Verdict | What landed |
|---:|---|---:|---|---|
| 1 | null-floor | 65 | accepted | bot salt, batch `--salt`, null-salt floor mode, `tune.mjs floor` |
| 2 | why-alive | 76 (cap) | accepted | HP telemetry per wave, survival section, `ablate.mjs`, 5 ablations (2 seeds, not 10) |
| 3 | street-score | 73 | accepted | point/strict verdict, enemy_damage group, street merge, budget-unit/cost/repair knobs, death-wave score, targets |
| 4 | tune-worktree | 35 | accepted | censored wave-limit score, night worktree, batch reuse, `tune.mjs sets`, three-profile cycle, night.md |
| 5 | controls-moves | 49 | accepted | controls + moves merges, bot blast clearance, bot uses the four moves, `--set` booleans, move table, 12 knobs |
| 6 | tuner-shared | running | | shared-table guard, `rivet_repair` group, `ablate --rev`, docs |
