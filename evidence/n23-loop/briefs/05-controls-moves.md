# Brief 05 `controls-moves`: merge controls and moves, the bot uses the moves and spares itself, off/on table (lane loop, n23)

Final, session 4 (05:10).

Hard stop: 06:30 wall clock (the call is stopped at 75 min). Commit deadline: 06:25. Commit each step as it lands.
Fix lint and format findings in your own edit and go on.

## Goal

The lane `loop` tunes the combined gauntlet with a test player (bot). Two lanes have finished parts the bot must use:
- **controls** (`n23-controls`, merge its head at the time you start; its blast work is `12d548bf6`..`61c382e3f`): the wheel is the default everywhere, and Rivet's own blasts now hurt him (`combat.json` block `blast`, `self_k` 1.0). The bot must not kill itself with its own blasts. Controls' note: ,
- **moves** (`n23-moves`, `MILESTONE ready 73eec563c`; merge its head): four new moves in `combat.json` block `moves`, each with `enabled` (true): `ohm_short_circuit`, `tonnage_armour_crack`, `kerf_blink_behind`, and the weapon effect `overkill_carry` (bonus card; second ranks end `_2` in `gauntlet_bonuses.json`). The bot must use each when its condition holds (below, verbatim from moves' JOURNAL). Note: moves' branch already contains prologue's iface commit `c7f139b95` (two `enemies.json` rows); that is expected.

## Work, in order (commit each)

Priority when time runs short: 1, 2, 3, the `--set` booleans and `move_table.mjs` of 4, then 6, then 5, and the report "Moves" section last. The director measures each move off and on right after this call, so a committed, working step 3 + `--set` booleans matters more than polish.

1. **Merge** `git merge --no-edit n23-controls`, then `git merge --no-edit n23-moves` (two merge commits). Conflict rules: root `JOURNAL.md`/`REPORT.md` keep ours; append-only shared lists (`project/boot/launch_args.gd` KNOWN_FLAGS, the KNOWN line in `project/dev/gauntlet/gauntlet.gd`, `docs/decisions.md`, `project/data/schemas/gauntlet_run.schema.json`) keep both sides' lines; `tools/debt/baseline.json`: `node tools/debt/merge_baseline.mjs`, commit, then `node tools/debt/debt.mjs --update`; any other conflict outside loop's files: `git merge --abort` and report. Then `node tools/tests/run_unit.mjs --changed` and `node --test "tools/gauntlet/*.test.mjs"`; fix only lane-owned breakage, report the rest as a NEED.
2. **Self-blast safety in the bot** (`project/features/gauntlet/bot/**`): the bot does not fire a blast weapon (rocket and any weapon with a splash radius; read the radius from the weapon/`blast` table, never a literal) when the predicted impact point (its target, or the first wall on the line) is within that radius plus Rivet's radius plus a margin from Rivet. Profile-dependent margin in `project/data/tables/test_player.json` (novice small, expert large; schema updated). Unit test: a target 1 m away with a rocket selected -> no fire; 10 m -> fire.
3. **The bot uses the four moves** (`bot/**`), each gated on its row's `enabled` and its condition:
   - Ohm short circuit: Ohm short-circuit (`ohm_short_circuit`, combat.json `moves`) is worth using when Rivet can take the Ohm form and a live machine (roster `EnemyRoster.Archetype.machine == true`: sentry_turret, shield_robot, war_machine) is inside Ohm's bolt cone (ghost_attacks.json `ohm.range_m` 11, `cone_deg` 30) with a clear line, and is not immune: `arena.squad_ai.minds[h.id].immune_until <= arena.tick` (stunned now: `OhmShortCircuit.held(arena.squad_ai, h)`). Best on a turret (2 s of no fire, no sweep: walk to its rear) or a shield robot (2 s with its arc down: shoot its front, its SWAT/contractors lose cover). Gate on `arena.squad_ai.moves.ohm_short_circuit.enabled`.
   - Tonnage armour crack: Tonnage armour crack (`tonnage_armour_crack`) is worth using when Rivet can take Tonnage and a live `war_machine` has just stomped: `TonnageCrack.post_stomp(arena.squad_ai.minds[h.id])` is true (agent state RECOVER after the melee stomp) and the crack is unspent (`mind.walker.cracked_at < mind.agent.shot_tick`): close in, stomp or ram it, then switch to the best gun and shoot its FRONT while `TonnageCrack.is_open(mind, squad.moves.tonnage_armour_crack, arena.tick)` (4 s, front 1.0 instead of 0.5). Gate on `squad.moves.tonnage_armour_crack.enabled`.
   - Kerf blink behind: Kerf blink behind (`kerf_blink_behind`) is worth using when Rivet can take Kerf and the target nearest his aim inside Kerf's pick reach has a front plate facing him: `FoeArmor.k(target, (target.pos - rivet.pos).normalized(), KerfStage.KILL_KIND, squad, arena.tick) < 1.0` (shield robot; also turret / war machine if the m2 report says so) and the spot `target.pos - target.facing * (kerf behind_m + target.radius_m)` is free (`KerfBehind._clear` logic: walls `blocks`/`push_out`, `pit.bounds`). Today's straight slice into a shield robot's front does 0.2x; behind it is the rear multiplier. Gate on `squad.moves.kerf_blink_behind.enabled`.
   - Overkill carry: Overkill carry (`overkill_carry`, `effect_overkill_carry`/`_2` cards of kind `effect` in gauntlet_bonuses.json) is scored 0 by the greedy bot today, so the bot never takes it. Worth taking from wave 3 when the run's weapons over-kill (hand cannon, shotgun, launcher) and waves arrive clustered; rank 2 (requires rank 1) when held. State: `arena.squad_ai.carry` (null = not held; `.rank` 1|2), row `arena.squad_ai.moves.overkill_carry` (radius 3 / 4.5 m, hops 1 / 2). No play change needed: it fires on any base-form weapon kill with leftover damage; the bot can prefer finishing low-hp foes inside a cluster with a big gun. Tuner knobs: `carry_k`, `radius_m`, `hops`, `rank_2.*`, card `min_wave`/`weight`.
   Profiles: expert uses every move whenever its condition holds; average with a probability from `test_player.json` (start 0.6); novice 0.25. Draw from the bot's own streams (the salted ones), never global RNG. One unit test per move: condition true -> the bot's intent picks the move; `enabled` false -> never.
4. **Off/on measurement tooling.** `tools/gauntlet/ablate.mjs --set=<file>#<pointer>=<true|false>` accepts booleans for boolean fields (refuse a bool on a number field and vice versa; tests). The report (`tools/gauntlet/report*.mjs`) gains a "Moves" section: per move, uses per wave (from each wave's optional `moves{<id>: count}`), and the median seconds of waves that contain the enemy the move answers (sentry_turret for Ohm, war_machine for Tonnage, shield_robot for Kerf, all waves for overkill) beside waves without it. `tools/gauntlet/compare.mjs` or a new `tools/gauntlet/move_table.mjs --off=<batch.json> --on=<batch.json> --move=<id>`: paired by seed, the difference in those wave times with a CI95, plus the death wave difference. Node tests.
5. **Knobs.** Add the moves' numeric fields (durations, multipliers: whatever each `moves.<id>` row holds besides `enabled` and `doc`) and the self-blast `blast.self_k` to `tools/gauntlet/knobs.json` with bounds; `enabled` is not a knob. Knob tests pass; `baseline.json` gains the new ids only through `tune.mjs propose`'s append (do not hand-edit it).
6. **Smoke** (one Godot): `node tools/gauntlet/batch.mjs --profile=all --pick=greedy --seeds=2 --jobs=1 --controls=wheel --waves=15 --out=evidence/n23-loop/moves-smoke` (the wave limit keeps it under ~15 min); report per run: death wave, moves counts per wave, self damage. At least one run shows a use of each of Ohm/Tonnage/Kerf, or say which condition never held and why.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` green; `node tools/tests/run_unit.mjs --changed` green (quote the line).
- Mutate on the main bot file you changed: `node tools/mutate/mutate.mjs --file=features/gauntlet/bot/<file>.gd --max=20 --lines=<changed lines>` (path relative to `project/`, commit first); quote killed/(killed+survived).
- The scenario tapes and the 60 s replay are not moved by your bot edits (the bot runs only in the gauntlet): `node tools/tests/run_unit.mjs --select=<the replay test if mapped>` or say what you ran.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. At most ONE Godot process of yours; the director runs batches alongside from a snapshot worktree. Never kill a process you did not start. Never touch another lane's worktree. Windowed runs (none needed): `--position 0,1440`.

## Files

Allowlist: merge commits of `n23-controls` and `n23-moves`; `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/test_player.json` + its schema, `docs/gauntlet-loop.md`, one appended line in `docs/decisions.md`, `tools/debt/baseline.json` through the debt tools, `evidence/n23-loop/moves-smoke/**`. Any other path: stop and report a NEED. Forbidden: `combat.json`, `enemies.json`, `gauntlet*.json` and every other table except `test_player.json`; `project/features/combat/**`, `project/features/player/**`, `project/features/souls/**`, the rest of `project/features/gauntlet/**`; other worktrees; `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-*`.

## Repo law

Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, 5 parameters max, `Log` not `print`, no global RNG, `.uid` with every new `.gd`, run a Godot `--import` before committing new scripts. Staged per path; no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`. No sim, parity, replay or bake digest moves.

End with: files changed, commits, commands and results, anything not done and why.
