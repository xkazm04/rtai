# Brief n20-ohm-02: wire Ohm's spectral body: jar charge, tilt jar overlay, top-view spectral rig

Worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`, branch `n20-ohm`. Package 01 committed the art (read its commit:
`git log --stat -1 -- tools/art/ohm_spectral_cut.py`): `art/view/{p70,p55}/ohm_spec_hover.png` (5 facing rows x 2:
idle, drift), `ohm_spec_act.png` (5 x 4: charged, thrust, recovery, struck; the same column meaning as the legacy
act sheet: wind-up, strike, follow, hit), their `_jars.png` masks (jar 1/2/3 in R/G/B), `ohm_spec_cells.json`, and
the top-view parts in `art/ohm/spectral/` + `parts.json`. The plate is
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`: look at it before you pose anything.

This is a VISUAL night: no sim, replay, parity or bake digest may move. `powers.json`, `ghost_attacks.json` numbers,
anchors in `ghost_forms.json`, hit boxes, timing: unchanged. Nothing legacy is deleted; the legacy look must render
exactly as today (`--ghost-look=legacy` and the default).

## Environment (every Godot run)
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm`;
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
d3d12` for anything that renders; windowed runs `--position 0,1440`; one Godot process at a time; kill only your own
PIDs.

## Step 0: take the flight lane's interface
`git log --oneline -5 n20-flight`. When it contains the interface commit ("Add the spectral ghost look interface:
GhostLook, ghost_hover.json, GhostFlight"), run `git merge --no-edit n20-flight` (allowed tonight, only that branch)
and read `project/features/souls/README.md` section "Spectral look" (GhostLook.spectral(id), GhostFlight,
GhostHover: `hover.bank`, `hover.lean`, `hover.speed_mps`, `yaw_rate_dps`; GhostDrawn.hover). If it is not there yet,
do steps 1 and 2 first and check again; merge again later in the session if flight commits more (`git log
HEAD..n20-flight`). If a name below differs from flight's README, follow the README.

## Files you may edit
New files with the `ohm_` prefix; `project/features/souls/ohm_*.gd`; tests `project/tests/unit/test_ohm_*.gd`;
the `ohm` row of `project/data/tables/ghost_hover.json` (after the merge; never the schema or other rows).
Exactly two allowed one-line call sites in flight's files, nothing else in them:
(a) `project/features/souls/ghost_acts.gd` `prepare_ohm`: add `rig.ohm = o` (so the rig reads the jar charge);
(b) only if flight's merged `GhostDrawn` has no public way to reach its shown sprite: add
`func sprite() -> Sprite2D:` / `return _spr` (two lines) to `ghost_drawn.gd`, and if it has no public instant-wind-up
switch, set Ohm's from OhmRig in the least invasive way you can find and say exactly how in your report.
Never edit tonnage/dent/kerf files, the bosses, `ghost_form_view.gd` beyond nothing, or any table but the ohm hover row.

## Step 1: the charge (pure logic + tests first)
- `OhmStage`: add a read-only `func gap_left() -> int: return _gap` (no state change; write_state untouched).
- New `ohm_charge.gd`, `class_name OhmCharge extends RefCounted`, render-side state stepped per sim tick (never frame
  delta): `func step(o: OhmStage, tick: int) -> void`; outputs `func jar(i: int) -> float` (0..1 fill of jar 0..2),
  `func vent() -> float` (1 at a cancel, falling to 0 over VENT_TICKS = 24), `func flash() -> float` (1 on the bolt
  tick, falling to 0 over FLASH_TICKS = 6), `func ready() -> bool` (all three full).
  Rules: soul off -> all jars 0. On: total = the bolt gap in ticks (`PowerDef.ticks(o.num(&"bolt_gap_s"))`),
  elapsed = total - gap_left(); fill = 3 * elapsed / total; jar i = clamp(fill - i, 0, 1), so the jars fill one
  after another and three full jars mean the next press fires. `bolt_tick == tick` (a bolt this tick) -> the jars
  drain (they read the gap, which just reset) and flash = 1. A delayed cast (`o.cast.due_tick >= 0`) holds the jars
  full and lit. A cancel = `o.cast.due_tick` was >= 0 last tick and is -1 now while `o.bolts` did not grow: vent = 1
  (the jars drain AMBER, never teal). Shipped (no delay) has no cancel: never vent there.
  Tests `test_ohm_charge.gd`: fill order and values at 0, 1/3, 2/3, full gap; press empties + flash; delayed cast holds
  full; an interrupted delayed cast vents and does not flash; soul off = 0; stepping is deterministic.
- Commit: "Read Ohm's bolt gap as three filling jars (OhmCharge)".

## Step 2: tilt views (p70 and p55)
Under `GhostLook.spectral(&"ohm")` only:
- Ohm's drawn figure uses `ohm_spec_hover.png` (idle col 0; drift col 1 while moving above about 0.5 m/s) and
  `ohm_spec_act.png` for the act columns. If flight's GhostDrawn already loads `<card>_spec_hover/_spec_act` sheets
  (a NEED was sent), use that; if not, say so in the report and wire it from OhmRig without touching more of
  flight's files than (b) allows.
- The instant cast (shipped) goes straight to the strike column (thrust) at the press: the jars were the wind-up.
  The delayed cast (`--ohm-bolt-delay=on`) still shows the charged column during its real wind-up.
- New `ohm_jars.gd` (+ `ohm_jars.gdshader`): a sprite twin that copies the shown sprite's texture region / frame /
  flip / global transform each frame and draws the matching `_jars.png` mask; the shader paints jar i from the
  mask channel i: empty = nothing (the body already shows dark glass), fill = a teal glow (`#2EC4B6` core going
  white-teal `#BFFFF6` when full), filling bottom-up inside the jar's bbox from `ohm_spec_cells.json` (or simply by
  alpha if bbox is not practical: say which), a flash to white on `flash()`, AMBER `#FFB000` while `vent()` > 0.
  Mirror-flipped octants must keep jar numbering right (the left rows mirror the right ones).
- Give the whole spectral body a soft additive teal glow so it reads lit-from-within like the plate (a halo under
  the sprite; reuse the legacy card halo approach if it fits). Keep it subtle: the ink must stay readable at 32 px/m.

## Step 3: top view (straight down)
Under `GhostLook.spectral(&"ohm")` OhmRig hides every legacy part (shell, feet, hose, legacy arms and beard) and shows
a new `ohm_spirit.gd` (`class_name OhmSpirit extends Node2D`) built from `art/ohm/spectral/` (`parts.json` for sizes
and pivots; one shared scale so the body is about as wide as the legacy shell at 32 px/m, the staff about 1.6 m):
- Draw order (bottom to top): hem (behind, root under the body's back edge, trailing back; flight's GhostTail
  continues it), free arm (left side, hand forward), body, three jar circles lit by OhmCharge (same colours as the
  tilt: use `body_jars.png` with the same shader), beard at the front edge, staff arm on the right with the staff
  through its fist.
- The staff is planted ahead like a walking stick that never touches the road: its fork about 1.0 m ahead and
  0.35 m right of centre at rest, leaning forward with `hover.lean`, swinging out on turns.
- Old and slow: the beard and hem rotate late on every turn (follow the facing with a lag that grows with
  `hover.yaw_rate_dps`, settling over about 0.4 s), a slow sway from `hover.bank`, a slow breathing scale.
- The cast: at the press (flash) the jars empty and the fork flares white-teal; the staff thrust is the follow
  through: over the next 8 ticks the staff slides forward 0.35 m toward the aim and returns over 12. A cancel: the
  jars flash amber with three short amber vent puffs from the jar tops (no teal).
- `ghost_hover.json` ohm row (after the merge): slow and floaty: height about 0.7 m, bob 0.1 m over ~100 ticks,
  bank about 8 deg, lag ~10 ticks, a tail that starts at the hem's tip, narrow, ragged (fray high).

## Acceptance (quote every result)
1. `node tools/godot/check.mjs` on every new or changed `.gd`; `node tools/lint/lint.mjs` (if `tool-tests` fails
   for a reason unrelated to your files, as it did in package 01, show the failing test name and confirm it fails
   the same on the base commit `a3eb0bf78`).
2. `node tools/tests/run_unit.mjs --changed`, then `--select=test_ohm_charge,test_ghost_card,test_story_forms`.
3. Legacy unchanged: the scenario suite's replay scenario green (`"$GODOT_BIN" --headless --path project -s
   res://tests/run_scenarios.gd` with `--only=` if supported).
4. Stills, through the film driver `project/dev/ghost-powers/ghost_review.tscn` via `node tools/dev/run.mjs` (read
   its `KNOWN_FLAGS` and `C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md` for how the takes were made) with
   `--ghost=ohm --ghost-look=spectral`, the move take and the attack take at 32 px/m, both views (70 deg tilt and
   top), SCRIPT ERROR 0. Save PNG stills to `C:\Users\kazda\kiro\gtai-masters\n20\ohm\wire\`: idle with three full
   jars, mid-charge (one or two jars), the press tick, +4 frames, tilt and top. Name the paths.
5. `node tools/gate/quick.mjs` before each commit. Small commits, staged per path: step 1, step 2, step 3 each its
   own commit. Never push.
6. After the last commit: `node tools/mutate/mutate.mjs --file=features/souls/ohm_charge.gd` and quote the score.

You have up to 75 minutes. If time runs short, finish and commit the step you are on rather than starting the next
one, and say exactly where you stopped.

## Report back
Commits (sha + message), what flight's interface looked like when you merged it (sha), the call sites you touched,
the still paths, test/lint/gate/mutate results, and anything that does not look like the plate.
