# Builder n31-melee-03p4 (opus, ~45 min): item 3's play takes + the rendered frame cost + the pending scenarios

Read `evidence/briefs/n31-common.md` (binding) and Part 3 of `evidence/briefs/n31-melee-03p3-feed-on.md`. Tag `03p4`.
Commit each part by 25 min into the call; report and END 50 min after launch. Commit with `git commit -- <paths>`.
State: `--melee-sweep` ON (81b877a99) and `--kill-feed` ON (090ae0350) by default; befores = `--melee-sweep=off
--kill-feed=off` (= main's rules). `tools/melee/play_take.mjs` has `--game-flags`, `--before-flags`, `--tag`.

1. Fatality takes (Part 3 of 03p3): seed 7, 32 px/m tilt 70 1080p60, 25-35 s, chainsaw first, then katana,
   plasma_sword, electro_baton, claw. Before AND after rendered NOW from HEAD (both arms same tree, so the marks
   match): `fatal_play_<w>_before.mp4` / `_after.mp4` and `beside_fatal_<w>.mp4` (960x540 hstack, labels "main" /
   "n31 fatality"). Pick the window where kills happen (kill ticks from the probe log; the probe prints them).
   One 64 px/m still of a chainsaw grind on a patrol cop (kill_lab or the take scene's zoom). LOOK at 3 stills per
   film: a grind must be visible in the chainsaw after film; say at which second. Append to
   `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json` (read it first; keep best-first order: the fatality
   beside films go FIRST, the chainsaw on top). Render only when the GPU is not taken: if a frame takes > 100 ms
   in draw, wait 3 min and retry (max twice), then render anyway and note CONTENDED.
2. Rendered frame cost: under the bench lock (`C:\Users\kazda\kiro\gtai-n31\bench.lock`, exclusive create; younger
   than 20 min = held: wait up to 10 min; older = stale) `node tools/melee/feed_cost.mjs --rounds=2` (rendered, not
   headless). Bar: no frame over 25 ms in the on arm that the off arm (same round load) does not also show. If it
   fails on grind pile-ups: one cap value (max simultaneous grinds) in `signature_kills.json` + DECISION line.
   Append the result to `evidence/n31-melee/03-fatal/feed-cost.md`.
3. `node tools/tests/run_scenarios.mjs --quiet-wait=1` full (47 were pending after 090ae0350): name the result line.
Owned: as the common law; plus `tools/melee/**`, `evidence/n31-melee/03-fatal/**`. Do not touch combat/ai, squad,
souls, prologue, gauntlet bot. Before killing a PID print its CommandLine; kill only your own.

## Addendum (session 5, 02:04): Part 0 first, 5 minutes, data only - serve ghost's NEED melee
Ghost lane asks (its JOURNAL 01:03 / 01:47): Ohm's and Kerf's deploy kills should play the existing soul deaths.
In `project/data/tables/signature_kills.json` add `"also_weapons": ["deploy_ohm"]` to the `ohm_shock` row (patch:
`C:/Users/kazda/kiro/gtai-wt/n25-yard/evidence/n31/ghost/ohm_deploy_kills.patch`; read-only, apply by hand, keys
sorted) and `"also_weapons": ["deploy_kerf"]` to the `kerf_split` row (`also_weapons` is read at
`signature_kill_table.gd:31`; check that line first). Run `node tools/tests/run_unit.mjs --changed` and commit alone
("n31 melee 03p4 part 0: ghost NEED"). Your full scenario run in step 3 then shows whether any digest moved; if one
moved ONLY because of part 0, say which and re-pin with a dated decisions line naming part 0 (gauntlet deploys only;
quest 1 must not move - if it does, revert part 0 and report).
Times for this call: launched 02:05; commit each part by 02:30; report and END by 02:55.
