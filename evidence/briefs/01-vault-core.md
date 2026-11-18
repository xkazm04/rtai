# Brief 01 `vault-core` (lane move, n19): Rivet vaults low obstacles, behind a flag

Before ANY Godot or gate run in this session: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Any windowed run: `--position 0,1440`. Never kill processes by name, only by your own PID.

## Goal
Running at a low obstacle (about waist height) and pressing the **roll** action carries Rivet over it in one
committed motion (a vault) instead of a roll. Engine behaviour only, no view work in this package (the view
pose, dev course and frames are the next package). Everything sits behind launch flags and data so it is off
by default, and the game, its replays and every golden digest are byte-identical with it off.

## What is true today (I scouted it; verify)
- `project/features/player/player_motion.gd` (`PlayerMotion`, 179 lines): phases FREE / ROLL / RECOVER on the
  60 Hz tick; the roll is a press of action `&"roll"`; `invulnerable()` is the roll's i-frame window;
  `write_state()` feeds the replay digest. Data: `project/data/tables/rivet_motion.json` (schema
  `gtai.rivet-motion/1`, its schema file under `project/data/schemas/`).
- `project/boot/collect_call/stage_pilot.gd` (`StagePilot`): `_move()` calls `motion.step()`, writes
  `stage.intent.move_by`, sets `rivet.exposed = not motion.invulnerable()`; `_fire()` refuses shots while
  `motion.phase == ROLL`. Arena rig code checks `PlayerMotion.Phase.ROLL` too
  (`features/arena/arena_rigs.gd:282`, the ai lane's file: do NOT edit it; say in your report if a vault
  needs the same treatment there and I will route it).
- Movement resolution: `collect_call_stage.gd::_move()` applies `move_by` then `_collide()`; the arena stage
  (`features/arena/arena_stage.gd::_collide`, ai lane's file, do not edit) pushes out of `ArenaWalls` boxes,
  then `StageCells`. If `move_by` is zero and `move_to` is INF, the stage does not touch Rivet's position.
  **So the vault should set `arena.rivet.pos` itself from the pilot and leave `move_by` zero during the vault
  ticks** (no edit to either stage file). Mind the ghost pilot (`features/souls/ghost_pilot.gd` reads
  `move_by`) and melee's `move_by +=`: nothing may add movement during a vault. If this approach turns out
  wrong, say why in your report before editing a stage file.
- Arena solids: `features/arena/arena_walls.gd` boxes from station props of kind `wall_high`, `cover_high`,
  `cover_low` (`cover_low` is 2.4 x 0.8 m in `data/tables/arena_stations/arena.json`). ArenaWalls keeps only
  Rect2s, not the kind, and you need the kind for the height. Do not edit arena files; read `ArenaStations`
  yourself the way `ArenaWalls.from_stations` does, in a new small class under features/player.
- City solids: `boot/collect_call/stage_cells.gd` (`StageCells`), 1 m cells; `SimConst.C_BUILD` (building),
  `SimConst.C_PROP` (prop OR parked car) and `C_VOID` are solid. Cells carry no height. Find where the
  generator places props and parked cars per chunk (CityGen chunk output; `features/city/view/chunk_lift.gd`
  reads a `height_m` per prop row from some table) so a solid cell can be resolved to a prop id and a height.
  **Unknown or unresolvable = not vaultable.** Buildings and void are never vaultable. A parked car is
  vaultable across its width if its height in data is <= the max. Do not change the generator or any city
  file (the gfx lane owns them; any bake/sim digest move is forbidden).

## Build
1. Data: a `"vault"` object in `rivet_motion.json` + schema: `enabled` (false), `max_height_m` (~1.2),
   `max_depth_m` (obstacle thickness along the motion, ~2.0 so a car's width passes), `reach_m` (gap from
   Rivet's edge to the obstacle face at the press), `min_speed_mps`, `max_angle_deg` (travel vs the face
   normal), `ticks` (the committed motion), `iframe_from`/`iframe_to`, `no_fire` (true: no shot during it, as
   the roll), `land_clear_m` (clearance past the far face), `apex_m` (visual lift, for the next package), plus
   `heights`: arena prop kind -> m (`cover_low` ~1.0, `cover_high` ~1.7, `wall_high` 3.0) and city prop/car id
   -> m. Choose sensible numbers and state them in the report. Update the table's `doc` string.
2. `features/player/vault_probe.gd` (or similar; small, typed): from Rivet's position, radius, travel
   direction and the stage's solids (arena stations if present, StageCells if present) it returns the obstacle
   ahead: entry point, landing point, depth, height, and vaultable or the refusal reason (`none`, `too_high`,
   `too_deep`, `landing_blocked`, `too_slow`, `bad_angle`). The landing must be **clear** for Rivet's radius
   against BOTH arena boxes and city cells. Expose a pure `clear_at(p, r) -> bool` for tests and the fuzz.
3. `PlayerMotion`: a new phase `VAULT` (append at the enum's end so existing values keep their numbers). On a
   roll press, if vault is enabled and the probe says vaultable: start a vault, a fixed path from start to the
   landing over `ticks` (deterministic; positions from integer tick math, no frame delta), then RECOVER as after
   the roll (or straight to FREE: choose and say why). `invulnerable()` covers the vault's i-frame window; the
   pilot refuses shots during the vault exactly as during the roll. A press at an obstacle that is too high, too
   deep or has a blocked landing: **no vault**; for a blocked landing Rivet stops (velocity zero) instead of
   rolling into it; with no obstacle at all the roll is exactly today's roll. Keep `player_motion.gd` under 200
   lines: put the vault in its own class (e.g. `player_vault.gd`) that PlayerMotion delegates to.
4. `write_state()`: **byte-identical with the vault off.** Write vault fields only while phase == VAULT.
5. Flags: `--vault` (force on) and `--no-vault` (force off) appended to `KNOWN_FLAGS` in
   `project/boot/launch_args.gd` (one line each, append only, a comment naming lane move n19). Default from data
   `vault.enabled`. Read the flag the way other features do (see `--quest1-places` in
   `boot/collect_call/stage_dock_place.gd`); tests set it through a property, not flags.
6. Enemies and bullets treat a vaulting Rivet like a rolling one (exposed false on the i-frame ticks).

## Tests (first-author, red before green: write them, see them fail, then make them pass; say so)
`project/tests/unit/test_rivet_vault.gd` (more files if needed, each about 200 lines):
- vaults a 1.0 m arena `cover_low` box at speed and lands clear on the far side; never overlaps a solid on any tick;
- refuses a `cover_high` / `wall_high` box (never crosses it);
- refuses when the landing is blocked (a second box right behind): Rivet stops, never inside a solid;
- refuses below `min_speed_mps` and outside `max_angle_deg`;
- i-frames on the window; no fire during the vault (through StagePilot);
- flag off: a roll press at the same box is the old roll, and `write_state` bytes of a scripted FREE/ROLL run
  are identical with the vault code present but off;
- a city case on `StageCells`: a building is never vaulted; a prop with a known height <= max is.

## Scenario (determinism + fuzz)
`project/tests/scenarios/scenario_rivet_vault.gd`, registered the way the others are (see `tests/run_scenarios.gd`):
- scripted input on the arena: run at a cover_low, vault it; run twice from scratch: identical digest of the
  `write_state` bytes and identical positions;
- fuzz: seeded through the RNG registry (no global randf) 300+ random approaches (position, angle, speed, press
  tick) over the arena's cover and over one city block with props and parked cars, vault forced on; after
  **every tick** assert Rivet's circle overlaps no arena box and no solid city cell (`clear_at`). Print
  attempts, vaults started, refused by reason, landed. Any overlap fails it.
- the existing scenarios and quest 1's replay stay unchanged (flag off).

## Repo law (binding)
AGENTS.md + STANDARDS.md. Typed GDScript, functions <= 40 lines, files ~200 (hard 300), <= 5 params, `Log` not
print, no global RNG, sim on `SimClock.TICK_DT`. Commit `.uid` files with new `.gd`. You may touch:
`project/features/player/**`, `rivet_motion.json` + its schema, the new test and scenario files (and their
registration), `project/dev/rivet_motion/**`, small call sites in `boot/collect_call/stage_pilot.gd`, one line
per flag in `launch_args.gd`. Do NOT edit features/arena, features/combat, features/city, features/characters,
native, or any golden/digest file. Stage per path (no `git add -A/./-u`, no stash, no reset --hard), never push.
Commit each logical step (data+probe, phase+flag, tests, scenario) as its own commit, message `move: ...`,
ending with the line `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I will run these myself after you)
- `node tools/gate/quick.mjs` clean; `node tools/lint/lint.mjs` clean.
- `node tools/tests/run_unit.mjs --changed` green, then `node tools/tests/run_unit.mjs --fast` green.
- the scenario suite green (at least your scenario plus the quest 1 / replay ones via `--only=` if the runner
  supports it), with the fuzz counts printed.
- `git status` clean at the end. Report: the commits, the chosen numbers, the fuzz counts, anything left undone.
