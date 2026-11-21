# REPORT - lane loop (n22, 2026-11-21) - DRAFT, completed at 07:40

Lane `loop`: the test player, the batch tool, the report, the tuner and the many-night procedure for the combat gauntlet. Branch `n22-loop`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-loop`.

## What works (item, evidence, number)

- **Speed, pit** (00:12): 13.6 sim s per wall s per Godot (headless pit fight, 5 hostiles, CONTENDED). `evidence/loop/speed-pit5.json`.
- **Speed, real street** (02:03, from `evidence/loop/batch-street-1` engine logs, CONTENDED): a run costs about 10.8 s fixed + 0.028 wall s per sim s (about 35 sim s per wall s while fighting); a ten-wave run about 17 s; one job about 210 runs per wall hour.
- **Test player** `project/features/gauntlet/bot/`, profiles in `project/data/tables/test_player.json`: binds to street's scene, plays real waves with greedy or random picks. Pit: same seed twice byte-identical result.
- **Batch** `tools/gauntlet/batch.mjs` and **report** `tools/gauntlet/report.mjs`: first real-street batch `evidence/loop/batch-street-1/` (5 seeds x 3 profiles, wheel controls), report `evidence/loop/batch-street-1/report.html`.

## What does not (yet)

- (02:00) 7 of 15 street runs stall to the tick cap (no routing on the street); profiles not ordered. Brief 04 targets both.

## What blocked or slowed you (minutes each)

- Botched concurrent merge, 8 min (a backgrounded commit ran merges while a second merge ran by hand).
- Shared index with a running builder, 5 min (session 1).

## Calls for the owner

## Merge notes

- `n22-loop` contains merges of `n22-street` (1b52bf0e6), `n22-guard` (123ec794d), `n22-foes` (0b29f2cb5) heads; `tools/debt/baseline.json` conflicts resolved with `merge_baseline.mjs`.

## Next steps

## Astra ledger

| call | minutes | verdict | note |
|---|---|---|---|
| bot-core | 46 | accepted | |
| batch-report | 37 | accepted | |
