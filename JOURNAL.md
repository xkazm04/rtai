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

### FINDING 19:41: the arena was silent; MILESTONE `0f8e4f5f` StageAudio in the arena
- Every arena movie had digital silence (-91 dB mean): `ArenaGame` never attached audio; only
  quest 1 builds `StageAudio`. Attached as is (null QuestSystem is safe); `--silent` = old arena.
  Hand cannon run: -26 dB mean, -2.6 dB max. Sync on the hit frame NOT measured yet: the stage
  bed holds the per-frame peak floor near -10 dBFS (`peaks.sh` in scratch), so a cue log or a
  bed-off run is needed.

### MILESTONE 19:47: `e88ebcfe` a kill keeps the longer stop; mini-nuke shake; audit iteration 1
- A rocket kill froze 6 ticks (kill) while a rocket non-kill froze 8 (boss_hit). Now the longer.
- camera.json `nuke` shake (14 px, 16 Hz, 36 ticks) on the mini_nuke override.
- `docs/polish/ranged.md`: rubric, ranking (mini_nuke, rocket, gatling, plasma, electro, shard,
  hand cannon weakest first; 6 weapons filmed but not yet scored = `?`), cross-cutting findings.

### LOOK 19:50: the first before/after pairs (32 px/m, arena pit, lone cop)
- `masters n7/ranged/mini_nuke-ab-32ppm.mp4`, `rocket_launcher-ab-32ppm.mp4`,
  `hand_cannon-ab-32ppm.mp4` (12 s: real time, then 4x slow of the impact). Checked clip frames
  38-56 of the nuke: after holds the burst 8 frames and the whole frame drops a few px along the
  throw, then eases back; before never moves. Frame logs: kill stop = 8 repeated ticks (nuke,
  rocket), 6 (hand cannon). Kill ticks identical on and off (665, 592, 556): the sim did not move.
- Weak spot seen: `--cam=fight` leaves the rocket/nuke blasts half off the right edge at 32 px/m.
  The weight now reads, but the framing hides half of it. Capture-only (FightCam), next iteration.
- Not done: 48/64 px/m close-ups; the city-block combined clip.

### MILESTONE 19:53: `5535aad2` classes for melee/ghosts (their REQUEST 1 point 2)
`melee_heavy`, `slam`, `ram`, `slice` (camera.json `slice_hit` 2 ticks), `chain`. The existing
`melee` row is unchanged (jab: melee_hit 4 + shake `hit`); tell me if the jab should drop the shake.

### REPLY -> n7-melee (19:54)
- Your REPLY 19:37 accepted; the feel layer is on `n7-ranged`: `779cdd3d` (FeelCam, FeelBudget,
  `--feel=off`), `e88ebcfe` (kill keeps the longer stop), `5535aad2` (your classes). Merge those.
- `0f8e4f5f` (arena audio) is also on the branch; merge it or not, it touches only
  `dev/arena/arena_game.gd` (`--silent` for the old arena).
- `CollectCallView.feel_cam` is created on the first view frame (`_feel_kick`), not in `_ready`:
  null-check it before calling.

### GATES 19:55 (head `5535aad2` except where noted)
- Lint 13/13; unit 1118/0 at `779cdd3d`, feel 9/9 + hit 19/19 at `5535aad2`.
- Scenarios 52/0, 0 SCRIPT ERROR (`evidence/ranged/scenarios-it1.log`, at `779cdd3d`).
- Parity exact, planted caught at 629 (`evidence/ranged/it1-parity.log`).
- Director reel (pit) 19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/ranged/it1-reel-director.log`,
  at `e88ebcfe`).

### MILESTONE 20:00: `2691917e` the fire side (recoil kick per round Rivet fires)
- `fire_kick_px/ticks` on weapons rows: gatling 0.7/4, rocket_launcher 3/10, hand_cannon 2/7.
  FeelCam watches new Rivet rounds in `CombatArena.shots` (as StageAudio) and kicks against the aim.
- Director reel on the city block 19/19 fully down, 0 SCRIPT ERROR (at `5535aad2`).
- NOT LOOKED AT YET: the Gatling rumble in motion. A 16-frame strip at 1:1 could not show a
  sub-pixel shift (`scratch/ranged/audit/sheets/gat-ab-fire.png`); needs a measured camera
  offset (log FeelCam.offset_px per frame) or a 64 px/m close-up. Not claimed as a visible change.

NEXT (iteration 2, from 20:20):
1. Measure the Gatling rumble: add a dev frame log of FeelCam's offset (or diff a static strip at
   64 px/m), judge "steady, not a blur" on the clip; tune gatling fire/hit kick by data.
2. Finish the audit: score flamethrower, molotov, ray_gun, machine_pistol, gloria, homing_shard
   from the films already in `scratch/ranged/audit/` (`sheet2.sh <w>-off 2`), assault-rifle via
   `--loadout`. Rank again.
3. FightCam framing of blasts (rocket/nuke half off frame at 32 px/m, capture only), then the
   48/64 px/m close-ups and the city-block clip (`--arena=city`) for nuke, rocket, hand cannon.
4. Sound on the frame: measure with a cue log (StageAudio cue tick vs struck tick) since the bed
   masks peaks; consider an impact cue per hit class.
5. Owner item 1 (electro gun / plasma rifle struck + killed human), then item 4 call (shard
   `grind_ticks` 36 vs 12 as a flag, film chapter 14 both ways).
6. Re-run unit full + scenarios on head (last full: `779cdd3d`); evidence run before freeze;
   exe by 08:30. Scratch avis in `gtai-n7p/scratch/ranged/audit` are audit inputs: delete the
   ones not referenced once scored.

### MEASURE 20:03: the Gatling rumble is too timid (data, not looked at yet)
- Tool: `gtai-n7p/scratch/ranged/shift.py <avi> <first> <n> x y w h` (phase correlation of
  consecutive frames on a 640x400 crop; "jitter" = shift minus its 9-frame mean, which removes
  FightCam's ~1 px/frame pan).
- Gatling sustained fire before kill 2 (64 frames): jitter rms 0.267 px / max 0.52 (`--feel=off`)
  -> 0.337 px / max 0.80 (feel on, `2691917e`). +0.07 px rms: steady and not a blur, but it barely
  reads at all. Iteration 2: raise `gatling.fire_kick_px` (try 1.5-2.0), re-measure, then judge it
  in motion at 32 px/m and 64 px/m before calling it.
- Unit full suite on head `2691917e`: 1120 passed, 0 failed (`evidence/ranged/it1-unit-head.log`).
- Audit: ray gun, flamethrower, molotov scored (`7adb597a`); still `?`: machine_pistol, gloria,
  homing_shard detail, assault-rifle.
