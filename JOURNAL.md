# JOURNAL - lane n7-ranged (night 2026-11-05/06)

Branch `n7-ranged`, cut from main `763f8fba`. Evidence: `evidence/` here, clips in
`C:\Users\kazda\kiro\gtai-masters\n7\ranged\`.

## Iteration 1 (19:19-20:19), phase BUILD

### FINDING 19:25: the hit feel never reached the camera in the live paths
- `GunplayHook.setup` built `HitLink.make(arena, HitFeel.shipped(CameraRig.new()), table)`: a
  **detached rig** nobody draws, and `GunplayHook.step` zeroes `link.hold` without holding the
  clock. So with `--weapon` every class row's shake and hit-stop went nowhere.
- `--loadout` (the arsenal, the director reel) has no HitLink at all; `print_stage.rig` and the
  arena's `city_view.rig` are null (only `boot/world.gd` free roam builds a rig). The only camera
  feel in the arena today is the Hauler stomp/ram (`HaulerKick`, its own private rig).
- Hit-stop is view only by design: `SimClock.hold` withholds wall time, `advance()` returns fewer
  steps, every tick is unchanged; replays step ticks directly. HitLink's knockback is sim (it moves
  `Fighter.pos`) and hashed through the replay; I leave it alone.
- Conclusion: make the camera side a view object (`FeelCam`) owned by `CollectCallView`, so the
  arena pit, the city block and quest 1 get it in one place, and nothing headless ever sees it.

### MILESTONE 19:40: shared feel layer extended (commit below)
- `hit_feel.json` (+ schema): per class `kick_px` / `kick_ticks` (directional camera kick, screen
  px at any zoom), `kill_kick_scale`, `cap` (kicks_per_tick 1, shakes_per_second 3,
  hitstop_ticks_per_second 12, kick_px_max 8), `weapons` overrides (gatling: no stop and no shake
  per round, kick 0.8; machine_pistol kick 0.6; homing_shard no per-shard stop; hand_cannon kick
  5/10t; mini_nuke boss_hit stop, kick 10/18t).
- `HitFeel.camera_row(weapon, class, lethal)`, `HitFeel.enabled` (`--feel=off`, in KNOWN_FLAGS).
- `FeelBudget` (the caps), `FeelCam` (struck -> shake + kick + stop, `offset_px(tick, zoom)`).
- `CollectCallView._feel_kick` adds the offset to `print_stage.kick_px` / `city_view.kick_px`.
- `GunplayHook`'s HitLink no longer gets a rig (it only did dead work).
- Unit `test_feel_cam` 8/8; planted faults: cap gating removed -> 1 failing; `enabled` ignored ->
  1 failing. Lint 13/13.

### REQUEST 1 -> n7-melee (the shared feel interface; ranged owns the module)
Call shape, from any attack that lands on a body (claw, blade, a ghost power):
```gdscript
var cam: FeelCam = view.feel_cam            # CollectCallView owns it (null headless)
if cam != null:
    cam.hit(weapon_id, hit_class, dir.normalized() * strength, lethal, arena.tick)
```
- `hit_class` is a `hit_feel.json` class id (`melee`, `heavy`, `blast`, `shock`, ...). A
  per-weapon look goes in `hit_feel.json` `weapons` (add a row: `{id, doc, hitstop?, shake?,
  kick_px?, kick_ticks?}`), never in your code.
- `strength` 0..2 (the length of `dir`): 1 = the class as tuned; a combo's finisher 1.5, a glancing
  swipe 0.5. It scales only the kick; stops and shakes come from the row.
- The cap is shared: at most 1 kick starts per tick, 3 shakes and 12 stop ticks per second across
  every attack (so a claw kill during a Gatling burst still gets the stop if the gun has not spent
  it). Tell me if melee needs its own budget; I would add a `budget` key per class, not a 2nd module.
- Do not call `HitFeel.land` for the camera in the live paths: `CombatArena.struck` already reaches
  FeelCam, so a claw hit that also emits `struck` would kick twice. Melee kills that emit only
  `kill_landed` (no `struck`) need your `cam.hit` call.
- `--feel=off` turns every camera effect off for before clips (flash/reaction/knockback stay).

### REQUEST 2 -> n7-king, n7-servo (FYI, the call shape a boss slam should use)
A boss attack landing on Rivet, or Rivet's hit landing on a boss, needs no boss code here:
Rivet's rounds on a boss already go through `CombatArena.struck` -> `FeelCam` (generic, no
target-kind case). A boss slam's camera hit: `view.feel_cam.hit(&"<slam id>", &"blast",
dir * strength, false, tick)` and, if it should differ from `blast`, a `hit_feel.json` `weapons`
row with its id. Rivet being hit is skipped by FeelCam (the `player_hit` cue owns that).

### MILESTONE 19:37: feel layer committed `779cdd3d`
Gates on the commit: lint 13/13, unit 1118/0, scenarios 52 ran 0 failed 0 SCRIPT ERROR
(`evidence/ranged/scenarios-it1.log`; the earlier lane's `evidence/scenarios-it1.log` was
overwritten by my first run and restored with `git checkout --`, FRICTION: name lane evidence
`evidence/ranged/`).

### FINDING 19:38: homing shard late reaction (backlog item 4), traced with numbers
(explorer trace, file:line checked against HEAD where cited)
- Not a burst: one shard per shot, 8 Hz; the first shard kills (100 x hp_scale 0.01 = 1 hp).
- ReactLink adds 0 ticks (struck queued and applied the same frame); HumanReact never runs for a
  shard kill: the signature burst kill takes the death (`brutality_hook.gd` `_takes_death`).
- Main already has the view fix `9abe4bc7` (`KillShardJolt`, decisions.md "shard flinch"): the cut
  body jolts on the hit frame (snap 2/3 x 0.2 m at age 1) and on each drawn shard after.
- What still reads late: the pop at T+39 ticks (0.65 s) = `signature_kills.json`
  `homing_shard_burst` `hitstop_ticks` 3 + `grind_ticks` 36 (gib wait). That is the approved
  brutality look; shortening it is an owner call (REPORT), not mine to decide.
- One-tick slip: `kill_burst_fx.gd:184` `born = kills.tick` while hooks step after the arena, so
  the first drawn frame is age 1 (fine: it reads on the hit frame).
- New with FeelCam: a shard kill now takes the 6-tick kill stop (the `homing_shard` override
  removes only the per-shard non-lethal stop). The frozen first frame shows the jolt pose.
- Plan: film chapter 14 before/after; offer `grind_ticks` 36 vs 12 as a call with a flag.

### Registry rules applied (read 19:35)
- `realtime-combat-semantics`: "everything resolves in parallel, every quantity more than one
  writer touches needs one named owner" -> one feel module, one FeelBudget shared by every
  attack; "every repeatable interaction needs an identity so it can be counted once" -> the cap
  refuses extra kicks in a tick instead of summing them; durations quoted in real time -> the
  budget window is 60 ticks = 1 s.
- `motion-quality-gating`: the audit's five dimensions are scored separately (never averaged),
  absolute, defined by visible contrasts (docs/polish/ranged.md rubric), unfilmed = `?`.
