# Brief a4-wheel: one weapon wheel with hands first (lane `guard`, run n22, item 5)

Wall-clock HARD STOP: 03:35 local. Commit logic by 03:20. If short of time, commit what is green and report what is left.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Windowed: `--rendering-driver d3d12 --position 0,1440`. Never kill by name, only your own PIDs.

## Owner's words
"Hold RMB blocks, melee on left mouse click. Mouse scroll up/down will change weapons, including hands melee as first native
choice." Decided: under `--controls=wheel` one ordered wheel: slot 0 `hands` (the bare claw combo), then the carried melee
weapons, then the guns, each group in pick-up order. Scroll up/down cycles (the `weapon_next` / `weapon_prev` actions already
sit on mouse wheel down / up and Tab / LB; keep them). Keys 1 to 4 still jump to their carry slots as today. Left mouse
(`fire`) uses the selected slot: hands or a melee weapon swings (press = a hit, held = the combo chains / the chainsaw grinds,
as a held fire on a drawn melee weapon does today), a gun fires. Right mouse is guard only (done in your earlier call).
Space (`melee`) stays a quick hands strike: it swings the claw whatever is selected, without changing the selection (if a gun is
drawn, that is a claw strike with the gun kept; if that is too invasive in the current pilot, make Space select hands and
swing, and say which you did). Under `--controls=legacy` nothing changes (byte-identical state and behaviour).

## What exists
`RivetCarry` (`features/player/rivet_carry.gd`: 4 grip-class slots, `select`, `_cycle`, `take`, `write_state`), `StagePilot`
(`boot/collect_call/stage_pilot.gd`: `wielding()`, `_melee_press`, `_attack_held`, `_fire`, `_pick_melee`), `WeaponHold`
(stow/draw), `ControlsMode.wheel()`, `PlayerGuard` (guard blocks attacks while up). HUD weapon slot:
`features/hud/hud_weapon_slot.gd` (not yours; you may add ONE call site in `features/hud/hud_view.gd` or wherever the slot is
built to attach a new view).

## Build
1. `project/features/player/rivet_wheel.gd` (`class_name RivetWheel extends RefCounted`): built by the pilot only under
   `ControlsMode.wheel()` over the pilot's `RivetCarry`. `order() -> Array[StringName]` = `[&"hands"] + melee (pick-up order)
   + guns (pick-up order)`; `selected() -> StringName`; `step(c: PlayerCommand, actions, arena)` handles `weapon_next/prev`
   (wraps; hands is always there) and the slot keys; selecting hands puts any gun / blade away (`arena.gun = null`,
   `rivet.weapon` = what the claw means today: find the value the arena uses for "no gun", likely `&""` or the claw id) through the
   existing stow/draw; selecting a gun or blade goes through `RivetCarry.select`. Pick-up order: the order `RivetCarry.add/take`
   first saw each id (record it in the wheel; launch-flag arms count in the order they were armed). `switched_tick` for the readout.
   `write_state(out)`: only when the wheel exists.
2. `StagePilot` call sites (minimal; keep the file under 300 lines, move glue into `features/player/` if needed): under wheel,
   carry's own `weapon_next/prev` handling must not also run (one owner of the press); `_melee_press` / `_attack_held` treat
   hands as "wielding the claw" so `fire` swings; `_fire` fires only when a gun is selected; Space = hands strike.
3. Readout `project/features/player/wheel_readout_view.gd`: for 1.0 s after a switch, a small vertical list next to the HUD
   weapon slot: the wheel's ids (localised names through the existing weapon name keys / `tr()`; add keys only if a name is
   missing, and say where), the selected one highlighted (white / steel, no teal, no red), fading out. Attach it with ONE call
   site in the HUD (name it). Under legacy it is never built.
4. Tests `project/tests/unit/test_rivet_wheel.gd`: fresh wheel = `[hands]`, selected hands; after taking a katana, a pistol,
   a rifle: order `[hands, katana, pistol, rifle-or-its-id]` (melee before guns, pick-up order within); scroll next goes hands
   -> katana -> pistol -> ... -> wraps to hands; prev goes back; key 1..4 jumps to that carry slot; with hands selected, a
   held `fire` starts a claw hit and no shot; with the pistol selected, `fire` shoots and no claw hit; Space swings the claw;
   RMB under wheel never swings (guard only); under legacy the pilot has no wheel and its `write_state` bytes equal a
   fixed-input reference built with the legacy code path.
5. `node tools/gate/quick.mjs`, `node tools/tests/run_unit.mjs --changed`, the scenario suite once (quote the summary; replay and
   quest 1 unchanged). Commit `guard: weapon wheel with hands first (wheel controls only)`.
   `node tools/mutate/mutate.mjs --file=features/player/rivet_wheel.gd --max=20`, quote the score.
6. Pins for the flip (report only, do not flip the default): list every test, scenario and dev bot that presses `melee` by
   mouse button 2 or depends on RMB being melee, and say whether it records actions (`TickInput` bits) or raw mouse/keys. That
   list decides the flip later.

## Allowlist (any other path: stop, report a NEED)
`project/features/player/**`, `project/boot/collect_call/stage_pilot.gd` (call sites), ONE call site in the HUD file that builds
the weapon slot (name it), `project/data/tables/input_actions.json` (only if a binding must change under wheel; say why),
localisation file(s) only to add missing weapon-name keys (name them), new tests `project/tests/unit/test_rivet_wheel*.gd`
(+ `.uid`), `docs/decisions.md` (append one line), `tools/debt/baseline.json` (through the debt tool only).
Forbidden: `project/features/gauntlet/**`, `project/dev/gauntlet/**`, gauntlet tables, `project/features/combat/ai/**`,
`project/features/combat/squad/**`, enemies.json, `project/features/bosses/**`, `project/features/souls/**`, `tools/gauntlet/**`,
`JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, native/.

## Law
Never delete or reword an existing comment you did not need to change (lane rule). A debt-ratchet rise you cannot avoid goes
through `node tools/debt/debt.mjs --update --accept-regression="<what> for n22 guard wheel"` (never a hand edit of the baseline).
Never stop the whole call for a NEED that only blocks one part: report it, skip that part, and go on with the others.
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions <= 40 lines, <= 5 params; `Log` not `print`;
no raw keycodes; no hardcoded UI text (`tr()`); no global RNG. `.uid` with new scripts (`--import` once). One commit per
change, staged per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix
lint and format findings in your own edit and go on. Mutate `--max=20`.

## Report
Commits (SHA + files), call sites outside features/player, the scenario summary, the mutate score, the pin list (item 6),
what you could not do.
