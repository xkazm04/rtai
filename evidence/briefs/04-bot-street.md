# Brief 04 (lane loop, n22): the test player on the real street

Wall-clock: you start about {START}. **Commit deadline {COMMIT}, hard stop {STOP}**. Small commits, one per change; never amend, never rebase. Fix lint and format findings in your own edit and go on.

## Context (read, do not re-derive)
- Your previous work: `project/features/gauntlet/bot/` (GauntletTestPlayer at `gauntlet_bot.gd`, brain `bot_brain.gd`, `BotViewArena`, `BotDefence`, `BotForms`, `BotCover`, `BotPick`), `project/data/tables/test_player.json` (+ schema), `project/dev/test_player/` (pit probe), `tools/gauntlet/` (batch, report; a tuner is being added by another call that ended before yours), `docs/gauntlet-loop.md`.
- The street, guard and foes lanes' heads are merged into this branch now. Street's scene `project/dev/gauntlet/gauntlet.tscn` instantiates your `gauntlet_bot.gd`, calls `configure`, `bind(run, session)`, `sample(tick)`, `pick(offered)`. Street's fallback pilot `project/features/gauntlet/gauntlet_walker.gd` (read only, street's file) shows the street's own idioms: `session.stage.arena.guard_map.route(at, goal)` / `clear_line`, a rest to 90 % HP between waves, retreat to repair at 45 %.
- Launch: `node tools/dev/run.mjs gauntlet --seed=N --bot=<novice|average|expert> --pick=greedy --controls=wheel --result=<abs json>`. A run ends on death or the 90 s wave timeout (`death.by: "timeout"`).

## What the director measured at 01:50 on this branch (seeds 1-3, greedy picks)
| run | waves reached | death | wave seconds |
|---|---|---|---|
| average-1 legacy | 4 | none: **stalled** after wave 4 (block `barricade_line`) until the 72000-tick cap | 9.4 7.9 9.8 8.0 |
| average-2 legacy | 6 | turret_gun, wave 6 | 5.6 9.3 9.0 6.5 26.3 |
| average-2 wheel | 6 | turret_gun, wave 6 | 5.2 6.6 7.8 5.8 31.8 |
| average-3 legacy | 5 | timeout, wave 5 (war_machine) | 9.9 12.6 9.5 12.6 |
| novice-1 legacy | 7 | turret_gun, wave 7 | 9.6 12.9 7.5 15.4 23.7 10.7 |
| expert-1 legacy | 5 | timeout, wave 5 (war_machine) | 9.2 9.7 9.7 8.4 |
A full 5-seed x 3-profile wheel batch is at `evidence/loop/batch-street-1/` (read its batch.json and run report.mjs on it).

### The 5-seed x 3-profile wheel batch (01:58, `evidence/loop/batch-street-1/`)
7 of 15 runs **stalled** to the tick cap (exit 1): novice-1 (after w4), novice-4 (after w1), average-1 (after w5), expert-1, -2, -5 (after w5), expert-3 (after w8). After the war-machine wave (5) is the usual place: look at what blocks the walk there (a wreck, a barricade, a prop, a forward_limit seam the bot never crosses). Deaths: turret_gun 5, war_cannon 1, timeout 1, one death with no `by` (average-4 w9). Wave 5 (war machine) took 29.6-82.5 s for every profile; waves 1-4 took 5-15 s. Medians of wave reached (stalls included): novice 6 (stalls excluded), average 7.5, expert 9 (1 of 5 ok).

Diagnosis so far: `BotViewArena.forward()` returns `Vector2.RIGHT` on the street: no routing, so a barricade or prop stops the walk forever. No rest between waves. The war machine wave times out for average and expert (90 s) — find out why with numbers (damage the bot deals to the war machine per second, how often it is in claw reach, how much time it spends guarding / rolling / in cover): a bot that never commits is not a test player. `shots` was 0 in every wave of that batch (hands only). Street's head 26c606322 (merged into this branch before your call) now **grants taken weapons, ghost forms and stat effects**: the bot must use what it was given (wheel slot by range, the forms per `BotForms`), and the batch must show non-zero `shots` once a gun is taken. Re-measure everything after that merge; the 01:58 numbers above are from before it. Novice reaches a later wave than expert: the profiles are not ordering.

## Goal, in order (commit each)
1. **Walk the street**: forward and chase both route through `guard_map.route` when the line is blocked (as the walker does), with a stuck detector (no progress for 2 s: take the route's next corner or sidestep). Acceptance: average seed 1 passes wave 4 and the result's `wave_reached` grows; no run ends at the tick cap in a 5-seed x 3-profile batch.
2. **Rest between waves**: a profile column `rest_hp` (share of max HP the bot waits for before entering the next block; novice low, expert high, e.g. 0.4 / 0.75 / 0.95) and `retreat_hp` (falls back along the cleared street to repair under it; novice 0 = never). Schema + table + `BotProfile`.
3. **The war machine and the turret**: commit windows. Attack the war machine between its tells (close in after a stomp or a shell, hit from the side or back, leave when a large tell is read); go round a sentry turret to its back (its front arc; read foes' code under `project/features/combat/ai/` and `squad/` for the turret's arc and the war machine's tells; read only). Tonnage when the war machine is within its stomp reach and the tell is unavoidable. Acceptance with numbers: the war-machine wave's median seconds for average and expert, and the timeout count, before and after.
4. **Profiles must order**: 5 seeds x 3 profiles with `tools/gauntlet/batch.mjs --seeds=5 --profile=all --pick=greedy --controls=wheel --jobs=1`: the median wave reached must be novice < average < expert. If not, change the bot's behaviour or its profile columns, never an enemy or weapon table. Quote the three medians.
5. **Determinism**: the same seed and profile twice gives a byte-identical result file under wheel controls (cmp); the 60 s replay and the scenario suite are not affected (your files are not on those paths; say how you checked: `node tools/tests/run_unit.mjs --changed` green).
6. **Report fixes** (`tools/gauntlet/report.mjs` and its tests; the director looked at `evidence/loop/batch-street-1/report.html`): (a) the "Enemy presence" table lists killer **weapon** ids (`turret_gun`, `war_cannon`) and `timeout` as if they were enemies, so the real enemies show 0 confirmed kills: map `death.by` to the enemy row that carries that weapon (the `weapons` block of `enemies.json`; keep the weapon in a column), and report `timeout` as its own line, not an enemy; (b) runs that ended at the tick cap (stalled, exit 1) are counted per profile in the header and in Deaths as "stalled", not silently dropped; (c) a death with no `by` stays "unattributed" (it is). Node tests for each.
7. Update `docs/gauntlet-loop.md` (the bot section: what it does on the street, where it plays unlike a human) and its speed section with the director's real-street measurement: from `evidence/loop/batch-street-1` engine logs (last `tick N, segment` line vs `wall_s`), a run costs about **10.8 s fixed + 0.028 wall s per sim s** (about 35 sim s per wall s while fighting; a 200 sim s ten-wave run is about 17 s; one job about 210 runs per wall hour, CONTENDED, four lanes busy). Also: `batch.json` `speed.sim_s` is null on street runs: fill it (ticks from the result if street adds them, else the engine log's last `tick N` line) and test it.

## Files you may create or edit (allowlist; any other path: stop and report a NEED)
`project/features/gauntlet/bot/**`, `project/data/tables/test_player.json`, `project/data/schemas/test_player.schema.json`, `project/dev/test_player/**`, `project/tests/unit/test_bot_*.gd` / `test_test_player*.gd` (+ `.uid`), `tools/gauntlet/**`, `docs/gauntlet-loop.md`, `evidence/loop/**`.
Forbidden: every other path under `project/` (street owns `features/gauntlet/` outside `bot/` and `dev/gauntlet/`; guard owns `features/player/`, `combat/shot.gd`, `TickInput`; foes owns `features/combat/ai/**`, `squad/**`, `enemies.json`), every table other than test_player.json, every other worktree.

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` and `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` before any Godot run. One Godot at a time (the director runs none while you work). Batches `--jobs=1`.
- After new scripts: a Godot `--import` before committing (the `.uid` files). `node tools/godot/check.mjs <file>` for a parse check.
- Mutate: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/bot/bot_brain.gd --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).
- Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push, do not merge or switch branches. Before each commit `git status --short` and stage only your own files.

## Report at the end
Files, commits, the numbers for acceptance 1-5 (before and after), the mutate score, NEEDs, what you could not do.
