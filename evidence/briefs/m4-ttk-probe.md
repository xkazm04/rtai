# Brief m4 (lane moves, n23): kill time off and on for the four moves, and the all-off byte check

Wall clock: start 04:50. **Commit deadline 05:55. Hard stop 06:10** (report and exit even if unfinished).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Windowed runs: `--position 0,1440`. Kill only your own PIDs. No native rebuild, no bench.

## Where we are
Earlier sessions built four moves in the `moves` block of `project/data/tables/combat.json` (loader and tally in `project/features/combat/moves/`): `ohm_short_circuit`, `tonnage_armour_crack`, `kerf_blink_behind`, `overkill_carry` (+ its rank 2 bonus). Read `git log --oneline -20` and those files first. Nothing is in code you change tonight except new dev files and their tests; **do not change any move rule or number** (if a move is broken, report it with the evidence and stop that part).

## 1. A kill-time probe: `project/dev/moves/move_ttk.gd` (+ helpers `move_ttk_*.gd` in the same folder)
A headless `-s` entry (`extends SceneTree`, `const KNOWN_FLAGS`, run through `node tools/dev/run.mjs move_ttk --out=<abs json> [--move=<id>] [--seeds=10]`). Reuse the n22 kill-time machinery where it fits (`project/dev/enemy_ai/foe_ttk*.gd`, `foe_duel*.gd`, `foe_walker_film.gd`; read-only, do not edit them, copy the pattern). For each move, the same scripted pilot on seeds 1..10, once with the move's row `enabled: false` and once `true` (flip the loaded `MoveTable` / the arena's copy in memory, never the JSON file), measuring per seed: kill tick of the target (or timeout at 30 s, sorted after every kill), damage Rivet took, and the move's `moves{}` count. Report median kill seconds off / on, the paired per-seed delta and how many seeds got faster.
- `ohm_short_circuit`: Rivet in the Ohm form at a fixed range inside the bolt cone (e.g. 8 m) against a `sentry_turret` facing him and, separately, a `shield_robot` facing him; he bolts on cooldown and fires the pistol at the front between bolts (or whatever weapon Ohm can hold; say which). On: the stun stops the turret's fire and drops the robot's arc, so the pistol lands at 1.0.
- `tonnage_armour_crack`: Rivet as Tonnage against a `war_machine`: dodge the stomp (step out of the ring), Tonnage hit in the post-stomp recovery, then pistol from the front. Off vs on.
- `kerf_blink_behind`: Rivet as Kerf against a `shield_robot` facing him on open ground: blink-slice on cooldown. Off vs on. Add one row against a riot cop if the m2 report says its shield blocks the slice.
- `overkill_carry`: Rivet with the `hand_cannon` (and one row with the `pistol`) against a cluster of 3 `patrol_cop`s within 2 m of each other at 8 m: time until all three are dead, off (bonus not held) vs rank 1 vs rank 2. `patrol_cop` has hp 1, so any hit over-kills it; add the same cluster of 3 `robot_thug`s (or whichever human-scale hostile has hp between one pistol hit and one hand-cannon hit: read enemies.json and say which) so the carried leftover is a partial hit. Grant the rank through `MoveCarry.grant(stage, rank)` (see `project/features/combat/moves/move_carry.gd`, `move_bonus.gd`), never by editing the table.
Write `evidence/moves/ttk.json` (`"schema": "gtai.move-ttk/1"`) and `evidence/moves/ttk.md`: one table, rows = move x enemy, columns = off median s / on median s / delta / seeds faster / Rivet damage off/on / move uses; under it, the matching cell(s) from last night's `evidence/foes/ttk.md` for that enemy with the closest weapon so the reader can compare.
A GUT test for the probe's pure helpers only if they have logic worth testing (median with timeouts); no test that runs the whole probe.

## 2. Byte identity with all four moves off
- With every `moves` row `enabled: false` (a temp copy of the JSON in a scratch tree, not the committed file), the game must equal the commit before the moves lane's first change *with the same enemy roster*. The m1 session made a comparison copy at `build/dev/m1-ohm-prologue-baseline` (the prologue iface commit `c7f139b95`, the same roster); use it, or make a fresh snapshot of `c7f139b95` the same way under `build/dev/`.
- Run `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs json>` in both; the result JSONs must be identical (quote both SHA-256). Then the 60 s replay on HEAD with all four on and all four off: that is the scenario `replay_60s` (`project/tests/scenarios/scenario_replay_60s.gd`; run `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=replay_60s`). NOT a bare `--replay=<scenario tape>`: that exits 1 at tick 60 because it starts the city sim against a dummy tape. Pass both ways and the same final hash both times (quote it; m2 saw `cbeb734ff9b97c41`). Write the lines to `evidence/moves/byte-identity.md`.
- Also run the full scenario suite once on HEAD (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) and quote its summary line.

## Files you may edit (allowlist; any other path: stop and report a NEED)
- new `project/dev/moves/**` (+ `.uid`), new `project/tests/unit/test_move_ttk*.gd` (+ `.uid`), `evidence/moves/**`
- `project/boot/launch_args.gd` `KNOWN_FLAGS`: append only, and only if `run.mjs` needs a flag there (prefer the entry's own `KNOWN_FLAGS`); then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 moves"`
- **Forbidden:** every product file (moves code, combat, squad, souls, gauntlet, player, tables, schemas), `project/dev/enemy_ai/**`, `project/dev/gauntlet/**`, `tools/gauntlet/**`, tapes, goldens, other worktrees.

## Checks
1. `node tools/lint/lint.mjs` green (layers: `dev/` may name anything; fix lint and format findings in your own edit and go on). `node tools/godot/check.mjs` on each new script.
2. `node tools/gate/quick.mjs` before each commit.
3. One commit for the probe, one for the evidence files, staged per path with `.uid` files. No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push.

## Also
- Every move row is in `project/data/tables/combat.json` `moves` (`MoveTable` in `project/features/combat/moves/move_table.gd`); the arena reads `arena.squad_ai.moves`, the bonus draw its own `GauntletDraw.moves`: flip both copies for an all-off run, or use the scratch-tree JSON copy.
- Fix lint and format findings in your own edit and go on. Do not amend or rebase. No mutate needed for dev files unless a helper has a test (then `--max=20`).
- Leave `build/dev/m1-ohm-prologue-baseline` in place.

## Report at the end
Files, commits, the full ttk.md table pasted, the byte-identity lines (both SHA-256, replay hash), the scenario summary line, any move that did not help and why you think so.
