# Brief n26-01 `cover`: the conveyor and the wrecks as real cover (lane yard, run n26)

HARD STOP: 12:30 local (stop work, report). LAST COMMIT: 12:25. Check `date` now and then.

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot or a gate.
- main moved since the import cache was made: run ONE `"$GODOT_BIN" --headless --path project --import` first.
- One Godot process at a time in this worktree. Any windowed run: `--position 0,1440`. Never kill processes by name, only by PID you started.
- Read `AGENTS.md`, `project/boot/prologue/prologue_yard.gd`, `prologue_yard_dressing.gd`, `prologue_yard_paint.gd`, `prologue_floor.gd`, `prologue_rifle_posts.gd`, `project/data/tables/prologue_stage.json` (`yard`, `command.rifle_posts`, `arrival`), `prologue_yard_dressings.json` (rows `plain`, `torn_line`), `project/tests/scenarios/scenario_prologue_pilot.gd`, and the existing `project/tests/unit/test_prologue_yard_*.gd`.

## Goal (owner's pick, verbatim: "bring the conveyor and wrecks into the play area as real cover")
The prologue yard (60 x 34 m) today has cover only at the edges; the middle is a bare floor. The approved concept plate `C:\Users\kazda\kiro\gtai-art\factory-n25\out\a-torn-line.png` shows the assembly line ripped out through the burst loading doors of the hall (top edge of the yard) and dragged across the yard in a broad S, plus two pallets of boxed washers, a crashed forklift and fallen machines. Build that as **real cover**: footprints that block movement and shots, drawn with the existing `torn_line` art pieces for now (a new art round follows in a later call; keep every piece's art a data value).

## What to build
1. **A new dressing row `line_fire`** in `prologue_yard_dressings.json` (schema updated) and make it the default (`yard.dressing` in `prologue_stage.json`). Rows `plain` and `torn_line` must keep giving EXACTLY today's yard (same cover, same pilot result bytes): so let a dressing row optionally carry its own cover layout (e.g. a `layout` block with `cover` and `debris` lists that replaces `yard.cover`/`yard.debris` from the stage when present). `--yard-dressing=torn_line` and `=plain` keep working.
2. **The `line_fire` layout** (metres, yard x 0..60 left-right, y 0..34 top-bottom; hall front at y 0, fence and gate at y 34, gate x from `yard.gate_x_m`):
   - The **torn conveyor** as a chain of 4 to 6 straight segments (waist-high, about 1.0 to 1.3 m deep, 4 to 6 m long each), starting at the hall front near the burst doors and snaking in a broad S down and across the middle third of the yard, with **gaps of at least 2.5 m** between segments to pass through. Segments may be rotated if the collision and the draw both support a rotated rect; if not, use axis-aligned segments stepped like a staircase (say which you did).
   - **Two pallet stacks** of boxed appliances in the open lower-left/lower-middle (like the plate's foreground), each about 2.4 x 1.6 m.
   - The **crashed forklift** mid-right, the **toppled robot arm** west of the conveyor's start, a **row of fallen fridges** along the line.
   - Keep the script's places clear and working: `rivet_start`, the opening bodies, `arrival` formations, `first_warden_at`, the gate and its approach (nothing within 4 m of the gate opening inside the yard), the payphone `factory_gate_phone`, the poles (catchers), the line of cops (`command.front_at`, rank/file spacing), and the rifle posts: `command.rifle_posts` names cover ids `burnt_pickup`, `press_carcass`, `fuel_vessel`, `scrap_skip`: keep those ids in the `line_fire` layout (you may move them) so the rifle posts still resolve.
   - Lanes: every walkable passage between two pieces, or a piece and the fence, is at least 2.5 m wide or fully closed (no slivers that trap the cops' pathing).
   - Nothing that hides Rivet from the camera: cover is drawn low (waist-high); no piece taller than its footprint over the floor.
3. **Shots**: check what `cover_high` (in `ArenaStation`) does to rounds. Waist-high cover in this yard should stop rounds that hit it (owner: "block movement and shots where they stand"). If `cover_high` already does, use it; if a lower kind exists that blocks shots, prefer that; do not change the arena's shared kinds' behaviour (other modes use them). Report which.
4. **Tests** (new `project/tests/unit/test_prologue_yard_layout.gd`): for the default dressing: every cover footprint inside the yard; every gap between two footprints (and footprint to yard edge) is >= 2.5 m or <= 0.05 m; the script's places (list above) are outside every footprint by >= 1 m; the 4 rifle-post ids resolve; `plain` and `torn_line` layouts are unchanged (compare to the stage's cover list). Keep the existing footprint-coverage test passing for the new row (art fills its footprint >= 85 %; stretch or pick pieces so it does).
5. **Pilot and scenario re-pin.** The prologue pilot (`scenario_prologue_pilot.gd` and the pilot input it uses) must finish the prologue on the new yard on seeds **7, 3, 11, 21, 42**. Report per seed: finished yes/no, deaths, lowest Rivet health, ticks; and the same on `--yard-dressing=torn_line` (= main) for comparison (main: one death on seed 3). If the pilot gets stuck on the new cover, fix the PILOT's steering (yard owns the pilot), not the cover rule. Watch for cops stuck on cover: count, per run, cops that do not move more than 0.5 m in 5 s while alive and not in their hold role; report the count for 3 runs. Re-pin whatever pinned value or golden the scenario holds and append ONE line to `docs/decisions.md`: `- [2026-11-23] DECISION n26 yard: ...` (what moved, why, old -> new pins).
6. **Two stills** for me (not films): 32 px/m whole-yard view of the `line_fire` layout at tick 300 and 6000 of the seed-7 pilot, with the footprints outlined (debug overlay) beside the plain art, into `evidence/yard26/layout_t0300.png`, `layout_t6000.png`. Use the existing dev entry `project/dev/prologue_yard/yard_stills.gd` (extend its flags if needed: declare every flag in its `KNOWN_FLAGS`).

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/boot/prologue/**`, `project/data/tables/prologue_stage.json`, `project/data/tables/prologue_yard_dressings.json`, their schemas under `project/data/schemas/`
- `project/dev/prologue/**`, `project/dev/prologue_yard/**`
- `project/tests/unit/test_prologue_*.gd`, `project/tests/integration/*prologue*`, `project/tests/scenarios/scenario_prologue_*.gd` and any golden file those scenarios read
- `evidence/yard26/**`
- `docs/decisions.md` (append one line), `tools/debt/baseline.json` (ONLY through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"` if the ratchet stops you on dev code you added)
- `.uid` files of new scripts.

## Forbidden
`input_actions.json`, `rivet_motion.json`, `project/features/**` (player, combat, souls, characters, gauntlet: other lanes own them), `combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`, `cast_cards.json`, `native/**`, quest 1 files and tapes. No balance change. No shipped replay/tape may change bytes except the prologue pilot's own pins you re-pin above.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, data JSON with schema, sorted keys, stable ids. Stage per path; one commit per change; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. Before each commit: `node tools/gate/quick.mjs` (or at least `node tools/lint/lint.mjs` + `node tools/tests/run_unit.mjs --changed`). After your main code commit: `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard.gd --max=20` (and the dressing loader if you changed it, `--max=20`), quote killed/(killed+survived).

## Report (final message)
Commits (sha + one line), the layout as a table (id, at, size, kind), lane-width test result, the five-seed table new vs main, stuck-cop counts, shot-blocking kind used, mutate scores, still paths, anything not done and why.
