# REPORT - lane loop (n22, 2026-11-21) - DRAFT, completed at 07:40

Lane `loop`: the test player, the batch tool, the report, the tuner and the many-night procedure for the combat gauntlet. Branch `n22-loop`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-loop`. Tune branch `n22-tune` (net zero tonight: five changes applied, all five reverted as noise).

## What works (item, evidence, number)

- **Speed, pit** (00:12): 13.6 sim s per wall s per Godot (headless pit fight, 5 hostiles, CONTENDED). `evidence/loop/speed-pit5.json`.
- **Speed, real street** (02:03, from `evidence/loop/batch-street-1` engine logs, CONTENDED): a run costs about 10.8 s fixed + 0.028 wall s per sim s (about 35 sim s per wall s while fighting); one job about 210 ten-wave runs per wall hour. Uncapped average runs (to wave 20-25) took 3 min 46 s for 10 seeds at 1 job (`evidence/loop/tune1-before/batch.json`).
- **Test player** `project/features/gauntlet/bot/`, profiles in `project/data/tables/test_player.json` (reaction ticks, aim error, tells read, guard lead, rest/retreat HP): routes through street corners, backs out of wedges, rests and retreats to repair, presses the war machine's recovery windows, circles the sentry turret's shield, picks wheel slots by range, uses Tonnage, Ohm and Kerf. 5 seeds x 3 profiles, wheel, greedy (`evidence/loop/street-final/`): **0 of 15 runs stalled** (13 of 15 on the merged baseline), **median wave reached novice 10 / average 20 / expert 25**, 15188 gun rounds fired across the 14 runs that took a gun.
- **Determinism**: 15 of 15 repeat runs byte-identical (`evidence/loop/street-final/determinism.json`); my own re-run of average seed 2 `cmp` identical. `run_unit --changed` 3509 green, 65 scenarios incl. the 60 s replay green (builder's run).
- **Batch** `tools/gauntlet/batch.mjs` and **report** `tools/gauntlet/report.mjs` (Markdown + one HTML page): wave time per profile against 15 s, deaths and killers mapped from weapon to enemy, stalls and timeouts on their own lines, offered bonuses paired take vs decline with an A/A floor, telemetry per wave, the most unusual deep runs with a replay command. Node tests: 30 of 30 (`node --test "tools/gauntlet/*.test.mjs"`).
- **Tuner** `tools/gauntlet/tune.mjs` (propose / apply / confirm, `knobs.json` 69 knobs, write-once `baseline.json`, clamps 0.8..1.25 per night and 0.5..2.0 of baseline, applies only on `n22-tune*`). **One full cycle on the real street** (03:45-03:57): measure average seeds 1-10 -> 5 HP cuts proposed, each tied to a wave median 39-62 s against 15 s -> applied on `n22-tune` (c8fb30f85..cc5f44ffc) -> confirm batch on the same seeds -> **all five noise** (improvement 0.2-20.6 s, A/A floor 19-47 s from only 2-4 pairs) -> reverted (33ad79efb..9c019401e). Ledger `evidence/loop/tune1-after/tune-ledger.md`.
- **Second cycle, 30 seeds** (05:00-05:40, after the tuner's follow-ups: alive caps kept, 6-pair A/A floor, min-n 3, knob row ids): measure `evidence/loop/tune2-before/` (average seeds 1-30, greedy, wheel, 12 min 54 s; median wave reached 22) -> `plan.json`, the same five HP cuts, now from 5-30 timed runs each -> applied on `n22-tune-2` (aa367f09b..e945e1e39) -> confirm `evidence/loop/tune2-after/` on the same seeds (median wave reached **27**, 8 runs capped alive at 72000 ticks against 1) -> ledger `evidence/loop/tune2-after/tune-ledger.md`: war_machine.hp 60->48 wave 20 59.6 -> 39.9 s, improvement 13.7 s (CI95 4.75 to 19.08, 12 pairs); shield_robot.hp 10->8 32.7 -> 27.7 s, 3.7 s (CI95 1.72 to 6.6, 25 pairs); robot_gunner 10.9 s (CI95 -7.5 to 16.7); sentry_turret 0.3 s; robot_thug too few pairs. All five are under their A/A floors (12.6-41.0 s), so the verdict is **noise** and all five were reverted (0ce71cf3f..b4647eb73; `n22-tune-2` is net zero under `project/` against `n22-loop`). See the first Call below: I think the floor is too strict.
- **Greedy vs random picks** on the same 30 seeds: median wave reached 22 vs 15, so the greedy value table plays better than chance.
- **One-command night** `tools/gauntlet/night.mjs` (measure -> report -> propose -> apply on `n22-tune*` only -> confirm on the same seeds -> revert -> report -> `night.md`), `--dry-run` prints the seven commands; procedure in `docs/gauntlet-loop.md`. Node tests 39/39.

- **Film** (owner judges by these), `C:\Users\kazda\kiro\gtai-masters\n22\loop\` with `frames.json` (15 entries, best first): the `average` test player, seed 5 (picked from a 12-seed scan, `evidence/loop/film-seed-scan.json`: the only seed of 1-12 that showed guard, roll, cover and Tonnage within five waves), wheel, greedy, 32 px/m, 1080p60: `waves-1-2.mp4` 21.7 s, `waves-3-4.mp4` 23.0 s, `wave-5.mp4` 31.3 s (war machine), `closeup-wave-4.mp4` 10.0 s at 64 px/m; a caption names the act each frame (ADVANCE, GUARD, ROLL, COVER, TONNAGE, ATTACK CLAW, ...). In that run: 21 guard deflects, 6 rolls, 54 cover ticks against a large threat, 6.70 s in Tonnage. Captions read sim state after the tick and never feed input: results with and without captions `cmp` identical (seeds 1, 5), the filmed result identical to headless (`evidence/loop/film.json`). Stills I looked at: `guard-64.png`, `tonnage-32.png`, `five-cleared-32.png` (Ohm pick), plus four frames extracted from the clips.
- **Report page**: `tune2-report.png` (the second tune cycle, before against after) and `report-full.png` (the whole `tune1-before` page) in the same folder, rendered through Chrome headless.

## What does not (yet)

- **The film does not show a large round actually stopped by cover**: `cover-32.png` shows Rivet at the pallet under an aiming line, but no impact on the prop.

- **Waves miss 15 s in both directions** (average, `evidence/loop/street-final/report.md`): waves 1-4 at 5.5-7.9 s, the war-machine wave 5 at 33 s, waves 9-24 at 30-83 s. Most runs end at the 90 s wave timer, not a death (5 of 9 ended runs in `tune1-before`).
- **No change has been kept yet**: at 10 seeds the A/A floor had 2-4 pairs; at 30 seeds it has 6-13 pairs but is built across seeds (Call 1), so two changes whose CI95 excludes zero were still reverted.
- **Bonus take vs decline shows no effect beyond noise yet.** Greedy runs take nearly every bonus (no decliners), so I ran `--pick=random` for 30 seeds (`evidence/loop/random-30/report.md`, average, 8 min 55 s wall): of 26 bonuses x 2 outcomes, 28 rows are "noise" and 24 "too few pairs" (pairing by pick wave leaves 2-8 pairs; the A/A floor needs 6). A night that wants bonus verdicts needs about 100 random seeds per profile (about 30 min per Godot job). The random runs reach a median wave 15.
- **Hit rate** in the report (100-1165 %) is meaningless: street's `hits` counts every damaging contact, claws and kills included, `shots` only gun rounds (`project/features/gauntlet/gauntlet_waves.gd:181`). Brief 05 drops the ratio.
- **Guard deflects not measured** in any wave: guard's deflect signal is not counted in the result (NEED street). Dent never used (no cars on the street).
- Runs that reach the 72000-tick run cap alive (seeds 6 and 10, wave 32) are counted as failed runs.

## What blocked or slowed you (minutes each)

- Botched concurrent merge, 8 min (a backgrounded commit ran merges while a second merge ran by hand).
- Shared index with a running builder, 5 min (session 1).
- A pre-commit flake during the second apply, 2 min (`tools/merge/step_guard.break.test.mjs:79` spawnSync timeout on the contended machine; re-running apply resumed).
- Tune apply through the pre-commit hook, about 1 min per commit (5 applies + 5 reverts = 10 min of a 12 min cycle).

## Calls for the owner

### Call 1: the tuner's noise floor (my recommendation: change it before night 2)
The tuner keeps a change only when its paired improvement clears an A/A floor. Tonight that floor pairs **different seeds** of the before batch (seed 1 against 3, 4 against 5, ...; table "A/A seed pairs" in `evidence/loop/tune2-after/tune-ledger.md`). That measures how much two different runs differ. A same-seed pair carries no measurement noise: the sim is deterministic and a re-run is byte-identical. So the floor is 12-41 s and nothing short of a huge change clears it. War machine HP 60 -> 48 shortened its wave by 13.7 s (CI95 4.75 to 19.08 over 12 same-seed pairs), and shield robot HP 10 -> 8 by 3.7 s (CI95 1.72 to 6.6 over 25 pairs). Neither CI touches zero, and both were reverted.
- **A (recommended):** the floor comes from a null change: re-run the before seeds with a neutral perturbation (an RNG salt on a stream that does not touch balance) and take the paired spread. Keep a change when its paired CI95 clears that floor. One data value in the tuner (`floor: "null-salt" | "cross-seed"`).
- **B:** keep the cross-seed floor and buy power with seeds: roughly 150+ seeds per cycle (about 45 min per Godot job), which makes a night one or two cycles.
- Side-by-side: `C:\Users\kazda\kiro\gtai-masters\n22\loop\tune2-report.png` (before against after per wave). Waves 1-4 hold none of the changed enemies, and their paired change is exactly 0.00 s on all 30 seeds. Same-seed noise is zero until a change touches the run, so a pair's difference is the change's effect plus the chaos it sets off. That chaos is what a null-salt floor measures.
- Tonight's ledger is the side-by-side: the same five rows under both rules would keep war_machine.hp and shield_robot.hp under A and nothing under B.

### Call 2: the wave budget cannot rise by 20 %
Waves 1-4 take 6.1-8.0 s against 15 s (30 of 30 runs). The tuner wants more enemies, but `budget.base` is the integer 2, and the next integer step (+50 %) is past the 1.25x clamp. The choice: budget in finer units (street's table, for example cost x10), or allow integer knobs one unit per night. Not built; street owns the table.

### Proposals (from `evidence/loop/street-final` and `evidence/loop/tune1-before`; nothing built)
Timed parry is a non-goal in the design note, so none of these is a parry.
1. **Ohm short-circuit on machines**: an Ohm pulse that stuns a sentry turret or shield robot for about 2 s. Observation: waves with a sentry turret take a median 38.3 s against 10.7 s without one (99 vs 83 waves), and `turret_gun` is a top killer in both street batches.
2. **Tonnage armour crack**: a Tonnage hit landed in the war machine's recovery after a stomp opens its armour for a few seconds. Observation: war-machine waves take 43.8 s against 26.0 s without it, and the bot's damage on the machine was 0.7-1.9 HP/s with Tonnage time capped at 7.1 s per wave.
3. **Kerf blink behind a shield**: Kerf's blink-slice ends behind its target, so a shield robot's front is skipped. Observation: shield-robot waves take 41.2 s against 12.7 s without one, the widest present/absent gap of any enemy.
4. **Overkill carry** (weapon effect for crowds): damage beyond a kill jumps to the nearest enemy within 3 m. Observation: late waves hold 10+ low-tier humans with the machines (patrol cops are in 89 % of wave time) and run to the 90 s timer; the bot spends its time finishing the crowd, not the threat.
5. **Deeper bonus pool**: second ranks of the existing weapon effects (a call on the pool, not a mechanic). Observation: a run takes one bonus per wave, the table has 26, and the deepest greedy runs had taken 24 by wave 25 (`evidence/loop/tune1-before/report.md`, unusual runs); late offers come from a nearly empty pool (the contract check had to accept short late draws, `4cb164110`).

## Merge notes

- `n22-loop` contains merges of `n22-street` (1b52bf0e6, 36cbb7405, bddea101e), `n22-guard` (123ec794d), `n22-foes` (0b29f2cb5) heads; `tools/debt/baseline.json` conflicts resolved with `merge_baseline.mjs`.
- `n22-tune` (cut at 50f0e6ae3) and `n22-tune-2` (cut at 3cc9334c3) are the tuner's branches, each net zero under `project/` against `n22-loop` (5 tune commits + 5 reverts each). Not for merging into main.

## Next steps

1. Decide Call 1 (noise floor), then run `night.mjs --seeds=30` on a fresh `n22-tune-*` branch each night: about 26 min per Godot job for the measure and the confirm batches.
2. Bonus verdicts: one `--pick=random` batch of about 100 seeds per profile per night (about 30 min per job).
3. Raise the 72000-tick run cap or treat capped runs as a ceiling: 8 of 30 confirm runs hit it alive, which censors "wave reached".
4. Street: `guard_deflects` in the result (still absent), and finer budget units (Call 2).

## Astra ledger

| call | minutes | verdict | note |
|---|---|---|---|
| bot-core | 46 | accepted | |
| batch-report | 37 | accepted | |
| tune | 40 | accepted | knob pointers by array index (row-id check in brief 05) |
| bot-street | 65 | accepted | 0 stalls, profiles ordered 10 / 20 / 25, 18/20 mutate on bot_brain |
| tune-night | 23 | accepted | 7 commits: alive caps, 6-pair floor, min-n, fast waves -> budget, knob row ids, `night.mjs`; 39/39 tests. Would brief the floor from a null perturbation, not cross-seed pairs (Call 1) |
| bot-film | 50 | accepted | act caption, 12-seed scan, 4 clips + 11 stills, mutate 38/38 on scratch copies; would brief a CRF target (clips came out at 98-140 Mbit/s) and a required "blast hits cover" still |
