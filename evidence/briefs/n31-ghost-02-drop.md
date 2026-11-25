# n31 ghost 02 - Tonnage: one press, a short charge, then a dump on a full circle

Builder tag: `g02-drop`. Launched ~21:14. **Commit the core change by 21:45 (first commit), the rest as each part passes. Hard stop 22:15: commit what passes, report, END.** Never end with a commit sitting in the pre-commit hook.
Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost` (base main `ba8e470b0`). Read `AGENTS.md` (repo law) first.

## Why (the owner, verbatim)
"Tonnage deployment does not need visualization of placement, after deployment it starts its dump attack, charging for short while and effect on circle around. Currently circle too small to be effective against group of enemies in one place."
A player must feel: press `2`, Tonnage is there at once, winds up for under half a second (foes can still walk out), then slams everything around him.

## Today on main (verified, read these first)
- `features/souls/ghost_deploy.gd`: a deploy key is HELD (phase AIMING, `_aim` puts `spot` at Rivet + aim limited to `range_m` 6, wall-clipped by `GhostDeploySpot.clip`), the RELEASE edge calls `_release` -> `strike.land(stage, self)` at once, then `forms.bond.record(id, strike.release_kills, ...)` on the same tick (line ~54).
- `features/souls/ghost_deploy_strike.gd` `_tonnage()`: centre = spot + facing x `press_ahead_m` 0.9; hits foes within `press.num(&"stomp_radius_m")` (= `powers.json` hauler `stomp_radius_m` 4, SHARED with the Q-form stomp in `hauler_form.gd`: do not change powers.json) AND `offset.dot(facing) >= 0` (half-disc); victim radius not added; damage `stomp_damage` 3 kind "shot"; `TonnageCrack.open` for a squad-owned war machine.
- `features/souls/ghost_deploy_marker.gd` draws the range ring + stomp footprint while AIMING. `ghost_deploy_effects.gd` `_draw` keys the effect on `strike.release_tick` and calls `HaulerMarks.draw(..., press.num(&"stomp_radius_m"), ...)`. `ghost_deploy_body.gd` shows TonnageRig at the spot for `life_ticks` 54.
- Data: `data/tables/ghost_attacks.json` deploy rows (tonnage: `range_m` 6, `life_ticks` 54, `cooldown_ticks` 480, `press_ahead_m` elsewhere in the tonnage block), schema `data/schemas/ghost_attacks.schema.json`, loader `features/souls/ghost_attacks.gd` (`DeployRow`, `num`).
- The bot: `features/souls/ghost_deploy_bot.gd` (+ `_spot.gd`) holds and releases; test `tests/unit/test_ghost_deploy_bot.gd`.
- Tests to keep green / update deliberately: `tests/unit/test_ghost_deploy*.gd`, `test_tonnage_attacks.gd`, `test_tonnage_crack.gd`.

## The change (Tonnage only; Dent, Kerf, Ohm keep the hold flow byte-for-byte)
New tonnage deploy-row fields in `ghost_attacks.json` + schema + `GhostAttacks.DeployRow` (each one data value, defaults below are the shipped values):
- `press_mode`: `"drop"` (new: the key's PRESS edge deploys at once, no AIMING phase, no marker) | `"hold"` (main's flow, kept working).
- `drop_at`: `"aim"` (spot = Rivet + aim direction x min(`range_m`, aim distance), wall-clipped as today) | `"rivet"` (spot = Rivet's position). Ship `"aim"` for now; the director picks after the measurement.
- `charge_s`: 0.45. Ticks = round(charge_s x `SimClock.TICK_RATE`). During it Tonnage is present (phase ACTIVE) and nothing is hit; damage resolves on the dump tick = press tick + charge ticks.
- `radius_m`: 5.5 (the deploy's own radius; the Q stomp keeps powers.json 4).
- `dump_damage`: 3, kind "shot" (patrol cop 1 hp dies; riot cop front x0.2 and robot thug 6 hp are hurt, not deleted).
- Geometry on the dump tick: **full circle centred on the spot** (no `press_ahead_m` offset, no facing test), a foe is hit when `spot.distance_to(foe.pos) <= radius_m + foe.radius_m`; hit dir = spot -> foe (any dir if equal). Rivet is never hit (hostiles only). Keep `TonnageCrack.open`.
- `life_ticks` must cover charge + the old aftermath (charge ticks + 54); cooldown starts at the press as today.
- Bond: record on the **dump tick** with that tick's kills (not on the press). Bond per kill unchanged.
- The marker draws nothing for Tonnage in `"drop"` mode (there is no AIMING phase; make sure no ring flashes on the press tick). The effect (`HaulerMarks.draw`) starts on the dump tick (expose `strike.dump_tick` or equivalent; `release_tick` semantics: say what you chose) and is drawn with the deploy's `radius_m`, so the drawn ring equals the damage radius.
- Determinism: the pending dump (spot, ticks to dump) is in `write_state`; replays stay deterministic. Pending dump is cancelled cleanly if Rivet dies or enters a car (say what you chose).
- The bot (`ghost_deploy_bot.gd`): in drop mode it presses once with the aim on its best spot (the aim sample must be in the same tick word as the press). Keep its tests green (update expectations for Tonnage deliberately).

## Tests (GUT, `tests/unit/`), all must pass
- one press (no hold) -> ACTIVE on that tick, no damage until press + charge ticks, damage on exactly that tick;
- a foe inside the circle at the press that walks out before the dump is NOT hit; a foe that walks in IS hit; a foe BEHIND Tonnage (opposite Rivet's facing) inside the radius IS hit; a foe at radius + its radius - 0.01 hit, + 0.01 not;
- Rivet inside the radius takes no damage;
- bond recorded once, on the dump tick, with the dump's kills;
- `press_mode: "hold"` still behaves as main (an existing test adapted, or a new one);
- war machine crack still opens (adapt `test_tonnage_crack.gd` if it pins the release tick);
- Dent/Kerf/Ohm deploy tests unchanged and green.
Run: `node tools/tests/run_unit.mjs --changed` (and `--select=` the ghost/tonnage files), then `node tools/gate/quick.mjs` before each commit if it fits in time.

## Digests
Gauntlet and scenario digests that include Tonnage deploys will move. After the core commit run `just scenarios` equivalent (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` THROUGH `node tools/dev/run.mjs` or `tools/tests/run_scenarios.mjs` if it exists): if a digest moves ONLY because of this change, re-pin it once and append ONE line to `docs/decisions.md`: `- [2026-11-25] DECISION ghost n31 tonnage drop: <before -> after values>; re-pinned <digest names> (item ghost 2 moved them)`. If the quest 1 script, the owner's lines or native parity move: stop, revert that part, report.
Also append ONE decisions line for the data change: `- [2026-11-25] DECISION ghost n31 tonnage deploy: one press (press_mode drop), drop_at aim, charge_s 0.45, full circle radius_m 5.5 (was half-disc 4 m ahead of the spot), dump_damage 3 shot; rejected: hold-to-aim marker (owner) ...` (the director may change radius/drop_at later with a new line).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot or gate command.
- **Lane Godot lock**: before any command that starts Godot (run_unit, scenarios, gate quick, import, the pre-commit hook), wait until `build/n31/godot.lock` does not exist, then write it with `g02-drop <your shell pid>`, delete it when the command ends. Never delete a lock that is not yours. Another builder (`g01-measure`) shares it. Every Godot through `runGodot` (`tools/dev/run.mjs`, `tools/lib/godot.mjs`, the test runners) — never a raw `$GODOT_BIN` (the scenarios command above: use the runner that wraps it).
- Allowlist: `project/features/souls/**`, `project/data/tables/ghost_attacks.json`, `project/data/schemas/ghost_attacks.schema.json`, `project/tests/unit/test_ghost_deploy*.gd`, `project/tests/unit/test_tonnage_*.gd`, new `project/tests/unit/test_tonnage_drop*.gd`, scenario/golden digest files that move because of this change, `docs/decisions.md` (append only, one line at a time). Any other path (powers.json, combat AI, kills folder, launch_args.gd, `project/dev/**`, `tools/**`): STOP and report a `NEED`. Other lanes' files are forbidden. `project/dev/ghost_n31/**` and `tools/ghost/**` belong to `g01-measure`: do not touch.
- Typed GDScript, files ~200 lines (hard 300: `ghost_deploy.gd` is 168 and `ghost_deploy_strike.gd` 170 — split a new class, e.g. `tonnage_dump.gd`, rather than growing them past 200), functions <= 40 lines, <= 5 params, `Log` not `print`, no global rand, no frame delta (ticks). Commit `.uid` with every new `.gd` (run `--import` via runGodot first).
- Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`). Stage per path, commit with `git commit -- <paths>` (the other builder commits in the same worktree). No `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard; never skip the hook (budget ~12 min; if it fails on `kill_reel_*.break.test.mjs`, run `--import` and commit again). If the debt ratchet complains, shrink what it names.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Mutate: only if after 21:55 the core is committed and green: `node tools/mutate/mutate.mjs --file=project/features/souls/<your dump file>.gd --max=20 --tests=<your test basenames>` holding the lane lock; quote killed/(killed+survived). Otherwise say "mutate not run".

## Report (your final message)
Files, commits (hashes), the exact data values shipped, which tests changed and why, digests re-pinned (names, why), commands run with results, mutate score or "not run", and anything you could not do (NEED lines).
