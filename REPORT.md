# REPORT - lane loop (n22, 2026-11-21) - DRAFT, completed at 07:40

Lane `loop`: the test player, the batch tool, the report, the tuner and the many-night procedure for the combat gauntlet. Branch `n22-loop`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-loop`. Tune branch `n22-tune` (net zero tonight: five changes applied, all five reverted as noise).

## What works (item, evidence, number)

- **Speed, pit** (00:12): 13.6 sim s per wall s per Godot (headless pit fight, 5 hostiles, CONTENDED). `evidence/loop/speed-pit5.json`.
- **Speed, real street** (02:03, from `evidence/loop/batch-street-1` engine logs, CONTENDED): a run costs about 10.8 s fixed + 0.028 wall s per sim s (about 35 sim s per wall s while fighting); one job about 210 ten-wave runs per wall hour. Uncapped average runs (to wave 20-25) took 3 min 46 s for 10 seeds at 1 job (`evidence/loop/tune1-before/batch.json`).
- **Test player** `project/features/gauntlet/bot/`, profiles in `project/data/tables/test_player.json` (reaction ticks, aim error, tells read, guard lead, rest/retreat HP): routes through street corners, backs out of wedges, rests and retreats to repair, presses the war machine's recovery windows, circles the sentry turret's shield, picks wheel slots by range, uses Tonnage, Ohm and Kerf. 5 seeds x 3 profiles, wheel, greedy (`evidence/loop/street-final/`): **0 of 15 runs stalled** (13 of 15 on the merged baseline), **median wave reached novice 10 / average 20 / expert 25**, 15188 gun rounds fired across the 14 runs that took a gun.
- **Determinism**: 15 of 15 repeat runs byte-identical (`evidence/loop/street-final/determinism.json`); my own re-run of average seed 2 `cmp` identical. `run_unit --changed` 3509 green, 65 scenarios incl. the 60 s replay green (builder's run).
- **Batch** `tools/gauntlet/batch.mjs` and **report** `tools/gauntlet/report.mjs` (Markdown + one HTML page): wave time per profile against 15 s, deaths and killers mapped from weapon to enemy, stalls and timeouts on their own lines, offered bonuses paired take vs decline with an A/A floor, telemetry per wave, the most unusual deep runs with a replay command. Node tests: 30 of 30 (`node --test "tools/gauntlet/*.test.mjs"`).
- **Tuner** `tools/gauntlet/tune.mjs` (propose / apply / confirm, `knobs.json` 69 knobs, write-once `baseline.json`, clamps 0.8..1.25 per night and 0.5..2.0 of baseline, applies only on `n22-tune*`). **One full cycle on the real street** (03:45-03:57): measure average seeds 1-10 -> 5 HP cuts proposed, each tied to a wave median 39-62 s against 15 s -> applied on `n22-tune` (c8fb30f85..cc5f44ffc) -> confirm batch on the same seeds -> **all five noise** (improvement 0.2-20.6 s, A/A floor 19-47 s from only 2-4 pairs) -> reverted (33ad79efb..9c019401e). Ledger `evidence/loop/tune1-after/tune-ledger.md`.

## What does not (yet)

- **Waves miss 15 s in both directions** (average, `evidence/loop/street-final/report.md`): waves 1-4 at 5.5-7.9 s, the war-machine wave 5 at 33 s, waves 9-24 at 30-83 s. Most runs end at the 90 s wave timer, not a death (5 of 9 ended runs in `tune1-before`).
- **10 seeds cannot confirm a change**: the A/A floor is built from 2-4 pairs. A night needs 30+ seeds per profile for a confirmable cycle (brief 05 item 0).
- **Bonus take vs decline is "insufficient data"** for every bonus: deep greedy runs take nearly every bonus, so there are almost no decliners. Bonus evaluation needs `--pick=random` batches.
- **Hit rate** in the report (100-1165 %) is meaningless: street's `hits` counts every damaging contact, claws and kills included, `shots` only gun rounds (`project/features/gauntlet/gauntlet_waves.gd:181`). Brief 05 drops the ratio.
- **Guard deflects not measured** in any wave: guard's deflect signal is not counted in the result (NEED street). Dent never used (no cars on the street).
- Runs that reach the 72000-tick run cap alive (seeds 6 and 10, wave 32) are counted as failed runs.

## What blocked or slowed you (minutes each)

- Botched concurrent merge, 8 min (a backgrounded commit ran merges while a second merge ran by hand).
- Shared index with a running builder, 5 min (session 1).
- Tune apply through the pre-commit hook, about 1 min per commit (5 applies + 5 reverts = 10 min of a 12 min cycle).

## Calls for the owner

### Proposals (from `evidence/loop/street-final` and `evidence/loop/tune1-before`; nothing built)
Timed parry is a non-goal in the design note, so none of these is a parry.
1. **Ohm short-circuit on machines**: an Ohm pulse that stuns a sentry turret or shield robot for about 2 s. Observation: waves with a sentry turret take a median 38.3 s against 10.7 s without one (99 vs 83 waves), and `turret_gun` is a top killer in both street batches.
2. **Tonnage armour crack**: a Tonnage hit landed in the war machine's recovery after a stomp opens its armour for a few seconds. Observation: war-machine waves take 43.8 s against 26.0 s without it, and the bot's damage on the machine was 0.7-1.9 HP/s with Tonnage time capped at 7.1 s per wave.
3. **Kerf blink behind a shield**: Kerf's blink-slice ends behind its target, so a shield robot's front is skipped. Observation: shield-robot waves take 41.2 s against 12.7 s without one, the widest present/absent gap of any enemy.
4. **Overkill carry** (weapon effect for crowds): damage beyond a kill jumps to the nearest enemy within 3 m. Observation: late waves hold 10+ low-tier humans with the machines (patrol cops are in 89 % of wave time) and run to the 90 s timer; the bot spends its time finishing the crowd, not the threat.
5. **Deeper bonus pool**: second ranks of the existing weapon effects (a call on the pool, not a mechanic). Observation: a run takes one bonus per wave, the table has 26, and the deepest greedy runs had taken 24 by wave 25 (`evidence/loop/tune1-before/report.md`, unusual runs); late offers come from a nearly empty pool (the contract check had to accept short late draws, `4cb164110`).

## Merge notes

- `n22-loop` contains merges of `n22-street` (1b52bf0e6, 36cbb7405, bddea101e), `n22-guard` (123ec794d), `n22-foes` (0b29f2cb5) heads; `tools/debt/baseline.json` conflicts resolved with `merge_baseline.mjs`.
- `n22-tune` is cut from `n22-loop` at 50f0e6ae3 and is net zero against it (5 tune commits + 5 reverts); it is the tuner's branch and is not for merging into main.

## Next steps

## Astra ledger

| call | minutes | verdict | note |
|---|---|---|---|
| bot-core | 46 | accepted | |
| batch-report | 37 | accepted | |
| tune | 40 | accepted | knob pointers by array index (row-id check in brief 05) |
| bot-street | 65 | accepted | 0 stalls, profiles ordered 10 / 20 / 25, 18/20 mutate on bot_brain |
