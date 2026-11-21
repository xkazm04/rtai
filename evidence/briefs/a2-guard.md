# Brief a2-guard: the held guard with its meter (lane `guard`, run n22, item 3)

Wall-clock HARD STOP: 02:40 local (check `date` now and then). Commit the logic (part A) by 01:50, the views (part B) by 02:30.
If you run out of time, commit what is green and report what is left.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Any windowed run: `--rendering-driver d3d12 --position 0,1440` (secondary screen, never the main one).
Never kill processes by name, only your own by PID.

## What exists (from your previous call in this worktree, tag `n22-guard-iface`)
`guard` action + TickInput bit, `ControlsMode` (`--controls=wheel|legacy`, legacy default; under legacy RMB stays melee and the
guard bit is never set), `Shot.size` (`Shot.SMALL`/`Shot.LARGE`), `EnemyRounds`, `GuardTuning` over the `guard` block of
`combat.json` (`arc_deg, move_k, meter_max, drain_per_round, refill_per_s, refill_delay_s, stagger_s, melee_drain`).
Round sizes: rockets, thrown and the enemy cannon are large. Read `git log --oneline -5` and your own diff first.

## The owner's words
"Cover should be enabled on right mouse click to deflect smaller projectiles. For larger and explosions player needs to dodge
with movement or cover behind object, or transform into Tonnage." Decided rule: a **guard meter**: front arc only, walk speed,
no attacking while held; each deflected small round drains the meter; empty = a short stagger; it refills when lowered.

## Part A: `project/features/player/player_guard.gd` (`class_name PlayerGuard extends RefCounted`) + wiring
Behaviour (every number from `GuardTuning`, none a constant except pure geometry epsilons):
1. `step(held: bool, can_guard: bool)` once per tick from the pilot. The guard is **up** when held and `can_guard` (alive, not
   rolling — a roll drops it and still works —, not in a vault, not in station cover, not in a ghost form, not broken).
2. While up: Rivet faces the aim (the pilot already turns him to the aim; make sure a guard with no aim keeps the facing),
   moves at `move_k` x walk speed, cannot fire, swing, charge the shock, or throw. Space (`melee`) does nothing while up.
3. **Deflect at the moment of the strike**: in `ArenaProjectiles.step_shots` (yours), when a hostile shot would strike Rivet
   and `arena.guard` is up, the shot is **small**, and its incoming direction (`-s.vel`) is within `arc_deg / 2` of Rivet's
   facing: it is not damage. Send it back with the same reflection `PlayerDeflect` uses (refactor `PlayerDeflect` so `bat()`
   and the guard share one `send_back(arena, s, facing)`; `bat()`'s behaviour must not change: it still deflects every size),
   drain `drain_per_round`, count `deflects`, emit the existing `arena.deflected` signal, leave the spark. A **large** round,
   or one from outside the arc (behind / side), strikes as today.
4. **Hostile melee from the front** while up: `CombatArena.damage()` asks the guard: if the victim is Rivet, the weapon is a
   melee row (`EnemyRounds` can expose `melee` from the weapons block; also treat `claw`/`baton` rows as melee by that flag),
   and the attacker (`killer_id` -> a hostile) stands within the arc, the hit drains `melee_drain` and deals 0. A blast never
   goes through this (it is not melee).
5. **Break**: when a drain takes the meter to <= 0: the meter is 0, `broken()` true for `stagger_s` (no guard, no attack:
   fire / melee / shock / throw blocked; movement is allowed at walk speed), then it stays empty until the refill starts.
6. **Refill**: when not up (lowered or after the stagger), after `refill_delay_s` with no drain, the meter refills at
   `refill_per_s` up to `meter_max * meter_k`. `var meter_k: float = 1.0` is the gauntlet's hook: the street lane will set it
   from its `StatMods.value(&"guard_meter")` (do NOT reference `StatMods`; it is on another branch).
7. API for HUDs and the loop lane's report: `meter() -> float` (0..1), `broken() -> bool`, `up() -> bool`, `deflects: int`,
   `breaks: int`, `melee_blocks: int`. Time in ticks on `SimClock.TICK_DT`, no frame delta, no RNG.
8. `write_state(out)` for the pilot's state; **write it only when the guard exists**.

Wiring (named call sites outside `features/player/`; keep each minimal and name them in your report):
- `project/features/combat/combat_arena.gd`: one field `var guard: PlayerGuard = null` and at most 3 lines in `damage()` for
  rule 4. Nothing else in that file.
- `project/boot/collect_call/stage_pilot.gd` (the live player pilot; no lane owns it, the guard lane is allowed the call sites):
  a `var guard: PlayerGuard = null`, built only when `ControlsMode.wheel()` and assigned to `stage.arena.guard`;
  reading `c.is_held(actions, &"guard")`; the walk scale; the attack gates; `guard.write_state` only when non-null. Stay under
  the 300-line hard limit (it is 193 now); if it gets close, move guard glue into `features/player/player_guard_glue.gd` or similar.
- **Legacy must be byte-identical**: under `--controls=legacy` no `PlayerGuard` exists, `arena.guard` is null, nothing new is
  written to any state stream, and every existing test and scenario passes unchanged. Under wheel in quest 1 the guard
  works too (fine), but quest 1's replay is recorded under legacy.

Tests `project/tests/unit/test_player_guard.gd` (and `test_player_guard_meter.gd` if the file grows past ~200 lines), real
arena objects where practical (build a `CombatArena` the way existing tests do, e.g. `test_wall_landing.gd`, the deflect tests):
front pistol round deflected and Rivet's hp unchanged; the same round from behind (and from 90 deg outside a 120 arc) hits;
a large round (rocket / enemy cannon) from the front hits; each deflect drains `drain_per_round`; enough rounds break it,
`broken()` for exactly `stagger_s` ticks, no fire/melee while broken; refill waits `refill_delay_s` then reaches full at
`refill_per_s`; `meter_k = 1.5` raises the cap; front melee drains `melee_drain` and deals 0, from behind it deals damage;
a roll drops the guard; the plasma sword `bat()` still reflects a large round; under legacy the pilot has no guard and its
`write_state` bytes equal those of a pilot built before this change (pin it against a fixed input sequence).
Then: `node tools/gate/quick.mjs`, `node tools/tests/run_unit.mjs --changed`, the scenario suite once
(`node tools/tests/run_scenarios.mjs` or `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`; quote the summary
line; the 60 s replay and quest 1 must pass unchanged). Commit: `guard: held guard with a meter (wheel controls only)`.
Then `node tools/mutate/mutate.mjs --file=features/player/player_guard.gd --max=20` and quote killed/(killed+survived);
if a survivor shows a missing test, add the test in a second small commit.

## Part B: the look (views only, not replay state)
- A guard pose for Rivet from his existing rig: forearms raised in front of the chest, the striped collar (a RIGID hazard
  collar, never cloth) still visible above them. Find where Rivet's rig is posed in the arena / street views (search the rig
  pose / melee strike pose code) and add the pose when `guard.up()`. Rivet's x1.5 size is visual only.
- A spark on each deflect (the existing `PlayerDeflect` spark is fine; make it read at 32 px/m).
- A break flash (amber or white, never teal — teal is for souls only — and never red — red is blood only).
- A small meter readout near Rivet that is visible while the guard is up or not full: a thin bar or arc. Colours: neutral /
  steel for the fill, amber when broken. Put it in a new view under `features/player/` and attach it where the arena draws
  Rivet's other readouts (name that call site).
- Check one still yourself headless-render or windowed (secondary screen), at 32 px/m: Rivet guarding with a pistol round
  coming in. Save it to `C:/Users/kazda/kiro/gtai-masters/n22/guard/scratch/` and give the path in your report.
Commit: `guard: guard pose, deflect spark, break flash, meter readout`.

## Allowlist (any other path: stop and report a NEED; do not edit)
`project/features/player/**`, `project/features/combat/shot.gd`, `project/features/combat/arena_projectiles.gd`,
`project/features/combat/enemy_rounds.gd`, `project/features/combat/weapons/fight_areas.gd`, `project/features/arena/arena_dodges.gd`,
`project/features/combat/combat_arena.gd` (the field + <=3 lines in damage()), `project/boot/collect_call/stage_pilot.gd` (call sites),
the one file where Rivet's rig pose is chosen and the one where the arena attaches Rivet's readouts (call sites only; name them),
`project/data/tables/combat.json` (`guard` block only) and its schema, new tests `project/tests/unit/test_player_guard*.gd` and
`test_guard_*.gd` (+ `.uid`), an existing test only if it pins a pilot/arena state layout that legitimately grew (name it; legacy bytes must not change),
`docs/decisions.md` (append one line at a time), `C:/Users/kazda/kiro/gtai-masters/n22/guard/scratch/`.
Forbidden: `project/features/gauntlet/**`, `project/dev/gauntlet/**`, `project/data/tables/gauntlet*.json`,
`project/features/combat/ai/**`, `project/features/combat/squad/**`, `enemies.json` rows, `project/features/bosses/**`,
`project/features/souls/**` (read only), `tools/gauntlet/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, native/.

## Law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions <= 40 lines, <= 5 params; `Log` not `print`;
no raw keycodes (InputMap actions); no global RNG; sim steps on `SimClock.TICK_DT`. Commit `.uid` files with new scripts (run
`"$GODOT_BIN" --headless --path project --import` once after adding scripts). One commit per part, staged per path. Banned:
`git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix lint and format findings in your own
edit and go on. No existing weapon / enemy / ghost number changes. Mutate capped `--max=20`.

## Report
Commits (SHA + files), the call sites outside features/player, the scenario summary line, test count, the mutate score, the
still path, what you could not do.
