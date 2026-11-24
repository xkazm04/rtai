# n27 melee m4: wreck arcs, mastery card (2026-11-24, branch n27-melee)

Env for every Godot run: `APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, d3d12, `--position 0,1440`.

## C: the mastery card has a picture (commit 42f8c948f)
- `project/dev/gauntlet/gauntlet_pick_card.gd`: `mastery` shares the `ghost` branch (`_mount_ghost`: chip face + the ghost's
  drawn card figure), and `_draw_mastery_ring` draws `GhostBondRing`'s INK/TRACK/TEAL/STROKE constants as a full ring with
  the crown diamond behind the figure. `picture()`, `has_figure()`, `is_mastery()` for tests.
- `project/tests/unit/test_gauntlet_pick_card.gd` (2 tests, pass with test_gauntlet_pick_view: 10/10).
- debt: `dev_loc` baseline raised with `--accept-regression` (+44 dev lines, pick card).
- Film: `node evidence/n27/films/render_bond.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee/films/bond_mastery.mp4 32 2 6 1650 2990`
  -> ffprobe `1920,1080,60/1,28.816667,1729`; old kept as `films/bond_mastery_blankcard.mp4`.
  At 15 s the first card shows Tonnage in a full teal ring with the diamond on the crown.

## B: arcs as current (commit 34c12865c)
- Which code drew the glyphs: for the claw on a robot thug (row `claw_discharge_shutdown`, `ElectricWreckFx`, bolt=false) the
  strokes of `_arc` (AMBER 0.12 m + white 0.048 m = 7.7 px + 3 px at 64 px/m, static), `_lift_arc` (extra DARK 0.16 m rim) and
  `_clamp` were the wreck's. `kill_shock_fx.gd` `_arcs/_burst` is the electro X-ray on humans (style `shock`): not used on robots.
  The cream, ink-rimmed star glyphs in panels 1-2 of `claw_shock_64.png` are NOT either: they are `ShockJolt._spark`
  (`project/features/combat/react/shock_jolt.gd`: ink 6 px + cream 2.5 px, 3 arcs + 3 spits re-picked every 2 ticks) drawn by
  `ShockArcsView` (react/) for the electrified robot. That file is outside this lane's allowlist: **NEED react** (give `_spark`
  the same thin core + amber halo, no ink rim; `ElectricArc` is reusable as the stroke).
- New `project/features/combat/kills/electric_arc.gd` (`ElectricArc`): 2 px white core, 4.5 px amber 0.5 alpha, 9 px amber
  0.18 alpha halo (screen px, so the same at 32 and 64), 5 kinks per arc (hash of serial*16+slot, jag cell = tick/3, no RNG),
  fork 0 always and fork 1 on half the cells (short, 0.24 m, 0.55 width), `still` (reduced motion) holds cell 0.
  `ElectricWreckFx._arc/_lift_arc/_bolt_current/_clamp` call it; the clamp prongs (steel), core burst, smoke, clamp and
  lift timings are unchanged; the ink rim of the lift arc is gone.
- `project/tests/unit/test_electric_arc.gd` (6 tests): t and t+3 differ, held inside a cell, same (tick, serial) equal,
  other serial differs, reduced motion holds one shape, 4-7 kinks with fixed ends, fork length, warm palette.
- Stills: `claw_arcs_before_64.png` / `_after_64.png` (4-up ticks 100/112/124/140). Result: the wreck's own arcs are thinner
  and forked, but the star glyphs in panels 1-2 are unchanged (react/).
  Electro gun at 64 px/m (`node evidence/n27/wreck/stills.mjs <dir> 64 <victim> electro_gun`): the bolt's current is a thin white
  core in an amber halo with a short fork instead of the flat 2-colour zig-zag.

## A: each robot wrecks as itself (commit 013c156db)
- The wreck body was already a copy of the robot's rig; `ElectricChassis.fit_core` then pinned `FoeShieldView.TORSO` and
  `FoeTurretView.HEAD` on both. Now `for_row(row, rig)` keeps `rig.torso_spr.texture` and `rig.head_spr.texture` (the live
  drawn art at the kill), `own_plates` finds those sprites in the kill's body copy by texture, `fit_own` pins copies at the same
  size/place as the old plates. A rig that shows neither keeps `fit_core` (reported nowhere yet: none seen).
  The shield robot and turret card path (`card_of`) is untouched.
- Today the robot thug and gunner share ThugPlan art (`FoeLooks.robot_plan` changes nothing for the gunner), so their plates
  match; they differ by the claw (thug) and the rifle (gunner). When the cast lane's gunner/thug redraw lands, the plates follow.
- `project/tests/unit/test_robot_wreck_plates.gd` (3 tests): two rigs with different torso/head textures -> two wrecks with
  those plates and none shared; no wreck carries the shield or turret texture; a body without the textures yields no plates.
- Stills: `wreck_thug_vs_gunner_before_64.png` / `_after_64.png` (rows +10, +30), `wreck_thug_alive_64.png`,
  `wreck_gunner_alive_64.png` (one tick before the shot).

## Films (06:35-06:39)
- `node tools/film/owner_takes.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee 32 electro_gun_wrecks` (new item: loadout
  `electro_gun,electro_gun`, and `owner_take.gd` no longer scrolls the wheel before the second robot when the gun is the electro
  gun; the existing `electric_robots` take is the baton one and cannot show the gun) -> `films/electro_gun_wrecks.mp4`,
  ffprobe `1920,1080,60/1,18.000000,1080`; take.json: thug kill t106, thug t318, gunner t530, shield robot t798, war machine stunned.
- `node tools/film/owner_takes.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee 32 claw_shock` -> `films/claw_shock_robots.mp4`,
  ffprobe `1920,1080,60/1,27.200000,1632` (before kept as `claw_shock_robots_before.mp4`).
- `node --test tools/film/melee.test.mjs` -> 1 pass.
