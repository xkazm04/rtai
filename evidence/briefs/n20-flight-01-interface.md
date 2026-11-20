# n20 flight, package 1: the Spectral look interface (commit FAST)

Night context: tonight all four ghost forms (Tonnage, Dent, Kerf, Ohm) become legless, flying spectres.
Four other lanes (tonnage, dent, kerf, ohm) rebuild one ghost each and code against the interface you
commit here. They are waiting. **Commit the interface (stubs that work, names final) as your FIRST commit,
by 01:05 on the machine clock (`date +%H:%M`)**, then keep improving in further small commits until about
01:25, then stop and report. Do not start a long polish before the interface commit is in.

Visual only: no sim, replay, parity or bake digest may move. Abilities, numbers, hit boxes, footprints do
not change. `powers.json` and `ghost_attacks.json` are untouched.

Environment: before any Godot run `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/flight` and
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot
process at a time. Windowed runs use `--position 0,1440`. Never kill processes by name.

## Files you may touch (flight owns these)
`project/features/souls/ghost_*.gd` / `ghost_*.gdshader` (new and existing), `soul_*.gd`, `power_*.gd`,
`project/features/souls/README.md`, the SCHEMA `project/data/schemas/ghost_forms.schema.json`,
`project/data/tables/ghost_forms.json` (add the new field to every row, nothing else), new tables
`project/data/tables/ghost_hover.json` + `project/data/schemas/ghost_hover.schema.json`,
`project/dev/ghost-powers/ghost_review*` and `ghost_reel*`, tests named `test_ghost_*` under `project/tests/unit`,
one appended line in `project/boot/launch_args.gd` `KNOWN_FLAGS`, one appended line in `docs/decisions.md`.
Do NOT edit `tonnage_*`, `hauler_*`, `ram_*`, `kerf_*`, `ohm_*`, `dent_*`, `gearbox_link.gd`, `slam_debris.gd`,
`plate_sparks.gd` (other lanes own them).

## What exists (read these first)
- `project/features/souls/ghost_form_view.gd` (`GhostFormView`): draws the player's ghost form each frame;
  `_process` steps `TonnageRig` (`_tonnage`), `DentBody` (`_dent.step(...)`), `KerfRig` / `OhmRig` via
  `_step_light`, all at `at = r.pos * PX_PER_M`, rotation = facing, `speed_mps`, `advance(steps * TICK_DT)`.
  `steps` = sim ticks since last frame. These are the top-view cut-out rigs.
- `project/features/souls/ghost_drawn.gd` (`GhostDrawn`): in the tilted views (`ViewMode.shared().art` is
  `p70` / `p55`) a drawn sprite per octant replaces the rig parts; `_column` advances the walk phase by ground
  walked (`GhostStride`, `GhostWalkPages`, `GhostSheet`). Each rig owns one (`rig.drawn`).
- `project/core/render/view_mode.gd`: `ViewMode.shared()`, `is_flat()`, `ground_k()`, `lift_k()` (screen y per
  metre of height), `art`.
- `project/features/souls/ghost_form_table.gd` / `ghost_form_def.gd`: the `ghost_forms.json` reader (DataTable).
- `project/boot/launch_args.gd`: `LaunchArgs.value("--x")`, `has()`, `KNOWN_FLAGS` (lint `launch-flags`).
- `project/dev/ghost-powers/ghost_review.gd` (+`.tscn`, `ghost_review_input.gd`): the film driver
  (`--ghost --take --ppm --view ...`, its own `KNOWN_FLAGS`).

## The contract to commit (names are final once committed)

1. **`GhostLook`** (`project/features/souls/ghost_look.gd`, `class_name GhostLook extends RefCounted`, static):
   - `const LEGACY: StringName = &"legacy"`, `const SPECTRAL: StringName = &"spectral"`.
   - `static func of(form_id: StringName) -> StringName`: the launch flag `--ghost-look=legacy|spectral`
     (via `LaunchArgs.value`) wins for every form when given; otherwise the form's row field `look` in
     `ghost_forms.json`; unknown/missing = LEGACY. Cache the table read (static var), plus a
     `static func override_for_test(look: StringName)` / reset so tests do not depend on the command line.
   - `static func spectral(form_id: StringName) -> bool`.
   - Row field: `"look": "legacy"` on all four rows of `ghost_forms.json` (schema: enum legacy|spectral,
     required). `GhostFormDef` gets `var look: StringName`. Update the table's `doc` string with one sentence.
   - Add `"--ghost-look"` to `KNOWN_FLAGS` with a `# n20-flight:` comment. Add it to `ghost_review.gd`'s own
     `KNOWN_FLAGS` too and make sure the review driver passes/reads it.
2. **`ghost_hover.json`** (`"schema": "gtai.ghost_hover/1"`, sorted keys, rows keyed by `id` = form id, one row
   per form, + schema file) and its reader **`GhostHoverRow`** (`ghost_hover_row.gd`) with typed fields, all
   metres / ticks / degrees:
   `height_m` (rest hover height), `bob_m`, `bob_ticks` (period), `bank_deg` (max roll into a turn),
   `bank_per_dps` (deg of bank per deg/s of yaw rate), `lag_ticks` (how far the body trails its true spot,
   as a critically damped follow), `lean_deg` (forward pitch at top speed), `top_mps` (speed that means
   "full lean"), and nested objects
   `tail`: `{anchor_m:[x,y], length_m, width_m, stretch_k (extra length per m/s), swing_k (0..1 how much the tail
   lags on a turn), segments, fray (0..1 raggedness)}`,
   `shadow`: `{radius_m, alpha, shrink_k (shadow scale lost per metre of height)}`.
   Defaults that already separate heavy from fast (the ghost lanes will tune their own rows):
   tonnage heavy/slow (height ~0.6 m, bob_m 0.06, bob_ticks 110, bank 6, lag 10, wide short tail), dent
   medium-lurchy (height 0.45, bob 0.08, bob_ticks 70, bank 14, lag 6), kerf fast and steady (height 0.5,
   bob 0.03, bob_ticks 50, bank 24, lag 3, long thin tail, stretch high), ohm small and floaty (height 0.7,
   bob 0.1, bob_ticks 90, bank 10, lag 8). Tail length roughly 1.0 to 2.2 m; shadow radius from the form's
   `radius_m` scale (tonnage biggest).
3. **`GhostHover`** (`ghost_hover.gd`, RefCounted): `func _init(row: GhostHoverRow)`,
   `func step(at_px: Vector2, facing: float, ticks: int) -> void` (advances ticks one sim tick at a time on
   `SimClock.TICK_DT`; never reads frame delta; ticks = 0 changes nothing), outputs (read-only vars or
   getters): `lift_m: float` (height incl. bob), `bank: float` (radians, signed, + = rolling right),
   `lean: float` (radians), `lag_px: Vector2` (body offset behind the true spot, world px), `speed_mps`,
   `yaw_rate_dps`. Deterministic, no RNG.
4. **`GhostTail`** (`ghost_tail.gd`, Node2D): configured from `GhostHoverRow.tail`; keeps a short chain of
   points stepped per tick from the root (anchor in the body frame, world px), stretching with speed, swinging
   behind on turns; `func step(root_px: Vector2, facing: float, speed_mps: float, lift_m: float, ticks: int)`;
   `_draw()`: stub may be a tapered teal polygon (TEAL `Color(0.18, 0.77, 0.71)` family, brighter at the root,
   alpha to 0 at the tip). Tilt views: the tail root rides at body height (screen up by `lift_m * lift_k`),
   the tip sinks toward the ground; top view: no height offset.
5. **`GhostShadow`** (`ghost_shadow.gd`, Node2D): a soft dark ink ellipse ON THE GROUND under the true spot
   (not lifted), squashed by `ground_k()` in tilt views, smaller and fainter as `lift_m` rises.
   `func step(ground_px: Vector2, lift_m: float) -> void`.
6. **`GhostFlight`** (`ghost_flight.gd`, Node2D): the one component a form view uses. Owns a GhostHover, a
   GhostShadow and a GhostTail as children (shadow below tail below the body: the form view adds the flight
   node before/under the body). API:
   - `static func make(form_id: StringName) -> GhostFlight` (reads `ghost_hover.json` once, cached).
   - `func step(at_px: Vector2, facing: float, ticks: int) -> void`.
   - `func body_offset() -> Vector2`: where to draw the body relative to `at_px` in screen/world px (lag +
     height: tilt views move it up the screen by `lift_m * lift_k() * PX scale`; top view: lag only).
   - `func body_scale() -> Vector2`: top view: slightly bigger with height (closer to the camera) and squashed
     across by `cos(bank)`; tilt views: `Vector2.ONE` squashed across by the bank.
   - `func body_rotation() -> float`: added to the facing (a small yaw lag into turns).
   - `var hover: GhostHover` readable (lanes use `hover.bank`, `hover.lean`, `hover.speed_mps` for poses).
7. **Feet off under the spectral look** (no ghost-lane file edited):
   - `GhostDrawn` gets `var hover: bool = false`: when true `_column` never advances the phase and shows the
     standing column (`STAND_COL` mapping); no run grid; attack/hit columns unchanged.
   - `GhostFormView`: for every form where `GhostLook.spectral(id)`: create one `GhostFlight` per form,
     step it with `steps`, place the body at `at + flight.body_offset()`, scale and rotation as above, feed the
     top-view rig `speed_mps = 0` (legs at rest, no stamp, no stride; `advance` still called so idle breathing
     works), set `rig.drawn.hover = true`; show the flight node only while that form's body shows. Legacy look:
     every path exactly as today (do not change a single legacy frame).
   - Foot contact marks: find every place a ghost body leaves a foot/stamp/stride mark or dust that is
     driven by walking (not by an attack, e.g. Tonnage's `stamped` signal consumers) and make sure it cannot
     fire under spectral (speed 0 does it if that is how they fire; verify by grep and say where).
8. **README**: `project/features/souls/README.md`, new section `## Spectral look` with: the flag, the row
   field and the rule (a ghost lane sets its row to `spectral` only when body, flight and all attacks are done
   in both tilts and filmed), each class with signatures and units, the `ghost_hover.json` fields, what a
   form lane does to switch feet off in its own rig (read `GhostLook.spectral(id)`; draw no legs; take
   `hover.bank/lean` for poses), and one usage example (10 lines of GDScript).
9. **decisions.md**: one appended line
   `- [2026-11-20] DECISION souls/flight: spectral look interface (GhostLook, ghost_hover.json, GhostFlight/Hover/Tail/Shadow); legacy stays default per form; rejected per-rig flight code in each ghost's files.`

## Tests (GUT, `project/tests/unit/test_ghost_look.gd`, `test_ghost_hover.gd`)
- GhostLook: row default legacy; override spectral wins; unknown value -> legacy.
- ghost_hover.json loads for all four forms with the schema; every form in ghost_forms.json has a row.
- GhostHover: `step(..., 0)` changes nothing; straight flight gives bank 0; a constant left turn gives a
  negative (or the documented sign) bank bounded by `bank_deg`; bob is periodic with `bob_ticks` (lift at t and
  t + bob_ticks equal at rest); stepping 3 ticks at once equals 3 single steps (determinism).
- GhostDrawn.hover: the column stays at the standing column while the host moves.

## Acceptance (run these, quote the results in your final report)
1. `node tools/godot/check.mjs` on every new/changed .gd.
2. `node tools/lint/lint.mjs` green (file <= 300 lines, functions <= 40 lines, <= 5 params, typed, `uid-files`:
   commit every new `.gd.uid`; `launch-flags`).
3. `node tools/tests/run_unit.mjs --changed` green, then `--select=test_ghost_look,test_ghost_hover,test_story_forms,test_ghost_locks`.
4. Replay/sim digests unmoved: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=<the replay scenario name; find it in tests/run_scenarios.gd>`
   (or the full scenarios run if `--only` is not supported) green.
5. Render check: `node tools/dev/run.mjs ghost_review.tscn ... --ghost=kerf --take=move --view=<tilt70 value the
   driver uses> --ghost-look=spectral` (look at how the n19 films were made: `C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md`
   and `tools/film/`) and once with `--ghost-look=legacy`: both run with SCRIPT ERROR 0. Save one PNG still
   of each (spectral, legacy) to `C:\Users\kazda\kiro\gtai-masters\n20\flight\scratch\` and name the paths.
6. `node tools/gate/quick.mjs` before each commit.

## Commits
- First commit: everything in "contract" with stubs that run, tests, README, flag. Message:
  `Add the spectral ghost look interface: GhostLook, ghost_hover.json, GhostFlight`. Stage per path
  (no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`). Never push.
- Further commits: small, one change each (e.g. "Hover the four ghosts under --ghost-look=spectral in the review film").
- Report: the interface commit sha and its time, the files, the checks and their results, the still paths,
  and anything you could not do.
