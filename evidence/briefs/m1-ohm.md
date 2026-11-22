# Brief m1-ohm (lane moves, n23): the `moves` block, the moves telemetry, and Ohm short-circuit

Wall clock: start ~01:10. **Commit deadline 02:00. Hard stop 02:10** (report and exit even if unfinished; uncommitted work is lost to the next session, so commit in small steps).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time (headless or not). Any windowed run: `--position 0,1440`. Kill only your own PIDs, never by name.
- Do not rebuild native. Do not run the bench.

## Goal
Ohm's existing forked bolt (the settled-form melee press; ghost row `ohm` in `project/data/tables/ghost_attacks.json`, code in `project/features/souls/ohm_*.gd`, `ghost_attacks.gd`), when it hits a **machine**, stuns it:
- `sentry_turret` and `shield_robot`: stunned for `stun_s` (2.0). A stunned turret stops sweeping and stops firing (rounds already in flight keep flying: decided). A stunned shield robot drops its shield arc for the stun (its front no longer blocks: `FoeArmor` / `foe_shield_cover.gd` must treat it as unshielded, and it does not block for squad mates).
- `war_machine`: stunned for `boss_stun_s` (0.6): it only interrupts / cancels its current tell (telegraph) and holds it for 0.6 s; it does not lose armour.
- The same machine cannot be stunned again for `immune_s` (4.0) counted from the start of the stun.
- "Machine" is a data flag: `machine: true` on the enemy row in `project/data/tables/enemies.json` (`archetypes[]`), parsed by the roster (`EnemyRoster.Archetype`, default false), added to `enemies.schema.json` as an optional bool. **Never a list of ids in code.**
- Humans (and non-machine robots) react to the bolt exactly as today.
- A stunned machine shows it (view only, not hashed): short amber/white electric arcs crawling over its body (amber, never teal, red or blue: colour law), the turret head / gun drops (tilts down), the shield robot's shield lowered. Put the cue drawing in a new own file (e.g. `project/features/combat/squad/foe_stun_view.gd`) driven by the stun state. `foe_shield_view.gd` is the street lane's file: if the lowered shield needs it, a ONE-line call site there is allowed; name it in your report. Otherwise draw the lowered slab from your own view.

## The `moves` block (new, shared shape for all four moves of tonight)
- New block `moves` in `project/data/tables/combat.json` (keys sorted, like the rest of the file), described in `project/data/schemas/combat.schema.json` (add only the `moves` block; the controls lane adds a `blast` block to the same files tonight, so keep your edit to your own block). Tonight's rows (add only Ohm's row now; the others come in later briefs with their own numbers):
  ```
  "moves": { "doc": "...", "ohm_short_circuit": { "enabled": true, "stun_s": 2.0, "boss_stun_s": 0.6, "immune_s": 4.0 } }
  ```
- A typed loader class (e.g. `MoveTable` / `MoveRow` in `project/features/combat/moves/move_table.gd`) reading it through the repo's existing data-table path (look at how `CombatTuning` / `GhostAttacks.shipped()` load JSON with a schema). Nothing is a constant in code: every number above is read from the row. `enabled: false` must make the move a no-op.
- **Byte-identical when off, and outside machines.** With `enabled: false` the game must be byte-identical to `main` (same replay hash, same gauntlet result). Any new state that enters a state hash / `write_state` must write nothing while no stun is active or has ever happened (follow the `OhmCast.write_state` pattern: only write when non-default), so the 60 s replay and every scenario tape stay byte-identical even with `enabled: true` (they have no machines). Check: `node tools/tests/run_unit.mjs --changed` and `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` (only if time allows; report the line).

## Telemetry
- Each move counts **its uses that had an effect** (here: a stun applied; a hit on an immune machine is not counted). Keep the counter in a small class of your own (e.g. `project/features/combat/moves/move_tally.gd`, ids as StringName keys) owned by the arena/stage.
- The gauntlet result: each wave row may carry `moves: {<id>: count}`. The wave rows are written by `project/features/gauntlet/gauntlet_wave_stats.gd` (street lane's file): you may add at most two ONE-line call sites there (snapshot at wave start, append at wave close, same pattern as `append_guard_deflects`); all logic lives in your file. Omit `moves` when no move had an effect in the wave (unmeasured/none is omitted, never a 0 nobody measured: a wave with the tally present and zero uses omits the key).
- Describe the optional `moves` field (object of id -> integer >= 1) in `project/data/schemas/gauntlet_run.schema.json` (your field only).

## enemies.json order (contract with the prologue lane)
The prologue lane is adding rows `sergeant_mulroney` and `appliance_warden` to `enemies.json` in its first commit tonight. **Before you edit `enemies.json`**, run `git -C C:/Users/kazda/kiro/gtai-wt/n23-prologue log --oneline -10 -- project/data/tables/enemies.json`. If a commit there adds those rows, `git merge --no-edit <that sha>` into this branch first (a merge commit; never rebase, never cherry-pick), then add `"machine": true` to `sentry_turret`, `shield_robot`, `war_machine` only. If that commit does not exist yet, do everything else first (tests can build rows in memory / use a test fixture), leave the `enemies.json` data edit for last, check again before your commit deadline, and if still absent report "enemies.json machine flags NOT added: prologue iface not committed" — do not add them without the merge.

## Files you may edit (allowlist; any other path: stop and report a NEED)
- `project/data/tables/combat.json` (`moves` block only), `project/data/schemas/combat.schema.json` (`moves` only)
- `project/data/tables/enemies.json` (`machine` key on the three rows only, after the merge above), `project/data/schemas/enemies.schema.json` (the `machine` key)
- `project/features/souls/**`, `project/features/combat/ai/**`, `project/features/combat/squad/**` except `foe_shield_view.gd` (one call-site line there at most)
- new files under `project/features/combat/moves/**`
- `project/features/gauntlet/gauntlet_wave_stats.gd`: two one-line call sites at most
- `project/features/combat/combat_arena.gd`: at its size cap, one-line call sites only (name each in your report)
- `project/data/schemas/gauntlet_run.schema.json` (your `moves` field only)
- tests: new `project/tests/unit/test_move_*.gd` / `test_ohm_short_circuit*.gd` (and `.uid`s)
- **Forbidden:** `project/features/player/**`, `project/features/gauntlet/bot/**`, `project/dev/gauntlet/**`, `tools/gauntlet/**`, `project/boot/**`, `gauntlet.json`, `input_actions.json`, the `blast`/`guard` blocks of combat.json, `rivet_blast.gd`, `shot*.gd`, `project/tests/run_scenarios.gd`, any scenario tape or golden, `bosses.json`, the native sim, other worktrees.
- Do not change any existing enemy, weapon or ghost number.

## Acceptance checks
1. Unit tests (GUT 9.7.1, `extends GutTest`, typed): turret stunned 2.0 s stops firing and sweeping then resumes; shield robot stunned drops the arc (a frontal shot during the stun takes the full multiplier 1.0, after it the front multiplier again); war machine stunned 0.6 s with its current tell cancelled; immunity: a second bolt at 1.0 s and at 3.9 s does not re-stun and does not count, a bolt at 4.1 s does; a human hit by the bolt behaves exactly as before; `enabled: false` = no stun, no count; a row without `machine` = no stun. Use the existing test support for arenas/squads (look in `project/tests/support` and the existing `test_foe_*` / `test_ohm*` tests).
2. `node tools/tests/run_unit.mjs --changed` green; `node tools/lint/lint.mjs` green (fix lint and format findings in your own edit and go on; `gdformat` your files).
3. `node tools/gate/quick.mjs` before each commit.
4. After the main code commit: `node tools/mutate/mutate.mjs --file=<your main stun file> --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).
5. Commit: one commit per change, staged per path (`git add <path>`), `.uid` files with their `.gd`. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. If the debt ratchet trips on a file you made larger, shrink it; for a real rise use `node tools/debt/debt.mjs --update --accept-regression="ohm short circuit for n23 moves"`.
6. Repo law: typed GDScript, files about 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, no global RNG, sim steps on `SimClock.TICK_DT` (count stuns in ticks from the seconds in the row), no frame delta in sim code.

## Report at the end
Files changed, commits (sha + title), the one-line call sites you added and where, test/lint/quick results, mutate score, whether the enemies.json flags landed (and the merge sha), and anything left undone.
