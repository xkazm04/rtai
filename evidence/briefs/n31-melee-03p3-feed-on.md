# Builder n31-melee-03p3 (opus): fatalities ON where the owner plays, the frame cost, the fatality takes

Read `evidence/briefs/n31-common.md` (binding) and `evidence/n31-melee/03-fatal/table.md`. Tag `03p3`. HARD STOP:
commit each part by 25 min into the call; report and END 55 min after launch. Commit with `git commit -- <paths>`.
Precondition: 02p3's `--melee-sweep` flip and its digest re-pin are committed (check `git log`); never re-pin a
digest in the same minutes as another builder.

## State
`--kill-feed` (off) installs `BrutalityHook` in the gauntlet (`GauntletSession.install_kills`, `GauntletView`) and
`QuestKillFeed` in quest 1 when the view draws rigs (tilt70/combo). With it, every melee kill plays its signature
row (chainsaw on a shieldless human = chainsaw_grind 138/138). `--gore=reduced` turns it off.

## Part 1: frame cost (bar: no NEW frame over 25 ms in the horde take)
Under the bench lock (`C:\Users\kazda\kiro\gtai-n31\bench.lock`: create exclusively; younger than 20 min = skip and
say CONTENDED; older = stale, delete): `node tools/perf/fight_gate.mjs --arms=off:<nothing>,on:--kill-feed
--scenes=horde,city --rounds=3` (check its flag syntax; it must pass `--kill-feed` where the gauntlet/arena reads
it - if the horde scene is not the gauntlet session, say what it measures and add the closest gauntlet measure:
a 60 s `play_baseline_take` run with the chainsaw under `--fixed-fps 60`, frame times from the log). Record p50,
p99, worst, frames over 25 ms per arm, and the machine load. If a grind pile-up costs frames: cap simultaneous grind
kills (one value in `signature_kills.json` or the hook, DECISION it). Delete the lock after.

## Part 2: flip ON
`--kill-feed` default ON in the gauntlet and quest 1 (rig view); `--kill-feed=off` restores the generic deaths
(keep the old flag accepted). Run `node tools/tests/run_scenarios.mjs` (allow 20 min) and
`node tools/tests/run_unit.mjs --changed`; re-pin each moved digest once with ONE dated `docs/decisions.md` line
("n31 melee item 3 moved <digests>"). Quest 1 script + native parity must not move; quest 1 digests may move only
by the kill state. Mutate `project/features/combat/kills/quest_kill_feed.gd` `--max=20` with a test subset; quote.

## Part 3: fatality takes main | HEAD
Using `tools/melee/play_take.mjs` (02p4 adds `--game-flags`; if not there yet, add it in a way that does not clash:
a separate wrapper `tools/melee/fatal_take.mjs`), seed 7, 32 px/m tilt 70 1080p60, 20-40 s: chainsaw first, then
katana, plasma_sword, electro_baton, claw: `fatal_play_<w>.mp4` with `--kill-feed=off` (before) and default (after),
beside film per weapon (as 02p4: 960x540 hstack, labels "main" / "n31 fatality"). Pick a window where kills happen
(read the kill ticks from the probe log). One 64 px/m still of a chainsaw grind on a patrol cop. LOOK at 3 stills
per film before committing. Append to `gtai-masters/n31/melee/frames.json` (read it first; 02p4 may have written it).
