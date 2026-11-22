# Brief m4b (lane moves, n23, follow-up of m4): commit the probe, fix Ohm vs the turret, make the Kerf row measure the bypass

Wall clock: start 05:22. **Commit deadline 06:05. Hard stop 06:20** (report and exit even if unfinished).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Windowed runs: `--position 0,1440`. Kill only your own PIDs. No native rebuild, no bench.

## 0. Commit what you staged (first, before anything else)
- The `dev_loc` rise is authorised by the director: `node tools/debt/debt.mjs --update --accept-regression="move_ttk kill-time probe for n23 moves"`, then stage `tools/debt/baseline.json`.
- Commit the probe (`project/dev/moves/**` + `.uid`, `project/tests/unit/test_move_ttk_stats.gd` + `.uid`, baseline) in one commit. The evidence files are committed after items 1 and 2 (they change).
- Then `node tools/mutate/mutate.mjs --file=project/dev/moves/move_ttk_stats.gd --max=20 --tests=test_move_ttk_stats` and quote the score.

## 1. Ohm: the short circuit must add to the ordinary electro stun, never replace it (product change, director's decision)
Your m4 finding: with the move off, Ohm's ordinary bolt stuns a sentry turret 1.2 s every bolt (`PlayerShock.stun_on`, no immunity), so it never fires; with the move on, `OhmShortCircuit.strike` replaces that stun with the 2 s short circuit + 4 s immunity, and the turret fires in the immunity gaps (Rivet hp lost 0 -> 4). A move that makes Ohm worse is a bug.
- Change `project/features/combat/moves/ohm_short_circuit.gd` `strike()`: always apply the ordinary stun exactly as today (`PlayerShock.stun_on(...)`), and in addition, when the row is enabled, the target is a flagged machine and it is not immune, apply the short circuit (`_apply`). Keep the return value meaning "a short circuit was applied" (that is what the tally counts). The disabled path must stay byte-identical to today (it already calls only `stun_on`).
- Update its tests (`project/tests/unit/test_ohm_short_circuit.gd`, `test_ohm_short_circuit_compat.gd`): an immune machine still takes the ordinary stun; a non-machine is unchanged; disabled is unchanged. Keep each file under 200 lines (split into a new `test_ohm_short_circuit_*.gd` if needed).
- Re-run the Ohm rows of the probe. Add a **flanking** turret row besides the stationary one: one pilot policy for both arms ("while the turret is not firing and not sweeping toward Rivet, strafe toward its rear arc at walk speed and fire; else hold"), so a stun the pilot can exploit shows up as time saved. If the turret row still shows no gain, say plainly why (e.g. the ordinary bolt already locks a turret down) and give the turret's rounds fired off / on.
- `node tools/tests/run_unit.mjs --changed`, then commit (one commit, staged per path), then `node tools/mutate/mutate.mjs --file=project/features/combat/moves/ohm_short_circuit.gd --max=20 --lines=<the lines you changed>` and quote the score.

## 2. Kerf: a row that measures the bypass
The shield robot dies to one slice either way (10 HP, the 99-damage GUARD row; the blocked slice still deals 19.8), so its kill time cannot show the bypass. Keep that row and add to it the **damage of the first slice** off / on. Then add rows against targets where one slice does not kill and the front plate matters: the closed-front `war_machine` and the `sentry_turret` (m2 said Kerf's bypass covers both): blink-slice on cooldown, kill time off / on, slices to kill off / on. If a row still one-shots, report the per-slice damage instead and say so.

## 3. Re-check and evidence
- Byte identity after item 1: re-run `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs json>` with all four moves off on HEAD (scratch copy of the JSON, as you did) and compare with your baseline SHA-256 `2d60b987de723daa...555f`; then `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=replay_60s` with all on and all off (same final hash `cbeb734ff9b97c41`). Also the `ghost_attacks` scenario (it uses Ohm/Kerf): `--only=ghost_attacks`, pass.
- Update `evidence/moves/ttk.md` / `ttk.json` / `byte-identity.md` with the new rows and the Ohm re-run (keep the old Ohm turret row as "before the fix" so the reader sees why it changed). Commit the evidence.

## Files you may edit (allowlist; any other path: stop and report a NEED)
- `project/dev/moves/**` (+ `.uid`), `project/tests/unit/test_move_ttk*.gd`, `project/tests/unit/test_ohm_short_circuit*.gd` (+ `.uid`), `project/features/combat/moves/ohm_short_circuit.gd`, `evidence/moves/**`, `tools/debt/baseline.json` (through the debt tool only).
- **Forbidden:** every other product file (combat_arena, squad, ai, souls, gauntlet, player, tables, schemas), `project/dev/enemy_ai/**`, `project/dev/gauntlet/**`, `tools/gauntlet/**`, tapes, goldens, other worktrees. Do not change any move number in `combat.json`.

## Checks and law
- `node tools/lint/lint.mjs` green; `node tools/godot/check.mjs` on each changed script; `node tools/gate/quick.mjs` before each commit. Fix lint and format findings in your own edit and go on.
- Typed GDScript, functions 40 lines or fewer, files about 200 lines (hard 300), at most 5 parameters, `Log` not `print`, no global RNG.
- Staged per path with `.uid` files. No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push.

## Report at the end
Commits (sha + subject), the mutate scores, the new ttk.md table pasted, the byte-identity lines, the turret rounds fired off/on, anything left unfinished.
