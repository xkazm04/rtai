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

### MILESTONE 20:02: `016966b2` Gatling recoil kick 1.8 px (jitter 0.48 rms / 1.59 max vs main 0.27 / 0.52)
Clip `masters n7/ranged/gatling-ab-32ppm.mp4` + frames.json row (4 pairs now). Not judged in
motion yet.

NEXT (supersedes item 1 of the 20:00 NEXT): judge the Gatling clip in motion (32 and 64 px/m) and
the spin-up (none built: the fire kick starts at the first round); if it reads as noise, step back
to 1.2 px. Then the rest of the 20:00 NEXT list, items 2-6.
- GATES 20:03 head `2691917e`: scenarios 52 ran 0 failed, 0 SCRIPT ERROR (`evidence/ranged/it1-scenarios-head.log`); unit 1120/0; lint 13/13; reels pit + city 19/19 (at `e88ebcfe` / `5535aad2`); parity exact.

## Iteration 2 (20:05-21:05), phase BUILD

### REPLY -> n7-melee REQUEST 2 (20:12): landed `eebc82f7`
`"class"` (optional, a `classes` id) on the `weapons` item schema and
`HitFeel.weapon_class(weapon) -> StringName` (&"" when none). Unit `test_hit_feel` adds a route
test and "every `class` names a class row" (data integrity). Add your rows (`kerf_slice` ->
`slice`, `dent_blast` -> `blast`, ...) in your branch; I add no ghost rows, so we do not collide.
Merge `n7-ranged` for it.

### MILESTONE 20:30: `b2af1801` + `eb1d4f1c` the Gatling spin-up tremor (brief item 5)
- Found: the 0.5 s spin-up (`Trigger.spin` up to `spec.spin_ticks`) showed nothing in the view:
  no barrel animation reads `spin` (only the walk slow does), no spin cue in the audio set. The
  anticipation cell was empty.
- Built: hit_feel.json gatling `spin_rumble_px` 1.5 (schema + `HitFeel.spin_row`),
  `FeelCam.spin_tremor(tick)`: amplitude = px x spin/spin_ticks while 0 < spin < full (spin-up and
  wind-down), zero at firing speed (the fire kick takes over), inside the kick_px_max cap. A fixed
  function of the tick (no RNG). Unit `test_feel_spin` 2/2; planted faults (no stop at speed,
  ignore `enabled`) -> 2 failing.
- MEASURE (64 px/m, phase correlation, 9-frame high-pass, crop 640x400): `--feel=off` flat 0.1-0.3
  px/frame over the spin-up; on, it grows 0.3 -> 2-3 px/frame over frames 284-310, then the fire
  kick. The first build used 22 Hz: near the 30 Hz frame Nyquist (a blur), retuned to ~10/15 Hz
  (`eb1d4f1c`). Kill ticks 320/629 identical on and off (sim untouched).
- DECISION (docs/decisions.md 2026-11-05): tremor on the camera, not barrel art (held-gun look is
  an owner call) and not a new sound (art). Off: `--feel=off` or `spin_rumble_px` 0.
- CLIP `masters n7/ranged/gatling_spinup-ab-32ppm.mp4` (11.7 s, real time + 4x slow of the
  spin-up), frames.json row added (5 rows). LOOK: stills only (frame 55 of the clip, side by side):
  the motion is frame-to-frame and does not show in a still; the measure is the evidence. NOT
  judged by eye in motion.
- FRICTION: at 64 px/m `--cam=fight` frames Rivet half off the bottom edge (frame 300 of
  `scratch/ranged/spin/g64-on2.avi`), so a 64 px/m close-up of Rivet needs FightCam work first.

### FINDING 20:50: owner item 1 (electro gun / plasma rifle reaction), where the read is thin
- Electro struck: `human_reactions.json` `stun` 1.2 s, travel 0.08 m, played by `ShockJolt.pose`
  (the hard stepped convulsion, combat night). It jolts in place: nothing goes along the bolt on
  the hit frame, so the victim-sync cell stays 2 ("on the frame, not along the hit"). Plan: a
  hit snap along `r.dir` in the first ~10 % of the family (a `ShockJolt` constant, `--soft-shock`
  keeps the old), film the struck cop at 48 px/m before/after.
- Electro kill: brutality `electro_shock` (stand 42 ticks, X-ray strobe, drops stiff); reads.
- Plasma kill: brutality `plasma_hole` (launch 1.4-2.2 m/s, hole 0.3 m). In the pit audit sheet
  the body barely travels and sits on the frame edge. Plasma struck (shielded only, 150 dmg kills
  any unarmored human): `weapon_wound` -> `stagger`. Next: check whether the gib launch is sim or
  view (RNG stream) before touching `launch_mps`; if view only, try 2.4-3.2 as a flag pair.

GATES 20:50 head `eb1d4f1c`: lint 13/13; unit feel 12/12 + hit_feel 2 new tests (full unit
suite last at `2691917e`: 1120/0). Director reel on head running at stop (see below).

NEXT (iteration 3):
1. Read the it2 director reel result (`evidence/ranged/it2-reel-director.log`, started 20:50 on
   `eb1d4f1c`): 19/19 down, 0 SCRIPT ERROR, or fix. Then full unit + scenarios on head.
2. Owner item 1: electro stun hit snap along the bolt (above), plasma_hole launch check; film both
   at 32 + 48 px/m before/after (`--weapon=electro_gun` / `plasma_rifle --lone --cam=fight`).
3. FightCam framing (capture only): Rivet half off at 64 px/m, blasts half off at 32 px/m. Needed
   for every close-up.
4. Audit gaps: gloria, assault-rifle (`--loadout`), flamer ignition, molotov throw.
5. Sound on the frame (cue log vs struck tick); shard `grind_ticks` call; quest 1 table guns;
   city-block combined clip; exe by 08:30.
- GATE 20:57: director reel (pit) on `eb1d4f1c`: 19/19 chapters fully down, 0 SCRIPT ERROR
  (`evidence/ranged/it2-reel-director.log`). NEXT item 1 reduces to: city reel + full unit +
  scenarios on head.

## Iteration 3 (20:20-21:20 wall clock), phase BUILD

FRICTION: the iteration 2 entries carry times 20:30-20:57, but its commits are 20:08-20:19 by
`git log` (the session guessed times). From here on, times are `date` output.

### GATE 20:22: city-block director reel on head `204c61d1` (code = `eb1d4f1c`)
19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/ranged/it3-reel-city.log`). With it2's pit
reel, both reels are green on the iteration 2 head.

### MILESTONE 20:24: `9c140ffb` the electro stun's hit snap (owner item 1, struck)
- `snap_m` (optional) on `human_reactions.json` reaction rows; stun 0.3 m. `ReactPose._hit_snap`:
  body + head (half) + 0.5 rad twist along `r.dir`, in 0.034 s, eased out by 0.3 s, over the
  ShockJolt convulsion. Render only. `--react-snap=off` = the before (KNOWN_FLAGS).
- Unit `test_react_snap` 4/4; planted faults (snap reversed; SNAP_OUT_S 1.5) -> 1 failing each.
- FRICTION 20:25-20:29 (my error): the first two films showed no stun. `--bot=gunplay --lone`
  holds the trigger (charged bolts kill), and `--bot=reel --chapter=electro_chain` without
  `--loadout=pistol` skips the electro gun ("director: no carry") and kills with the pistol. Use
  `--bot=reel --reel=director --loadout=pistol --chapter=<id>` for any director chapter film.
- FILM (director `electro_chain`, 48 px/m, off vs on): 7 wounds, 0 deaths, 4/4 down on both; the
  frame diff is non-zero only from frame 61 (the first stun) on. Clip
  `masters n7/ranged/electro_snap-ab-48ppm.mp4`. LOOK: the after victim sits about 15 px further
  along the bolt on the hit frames; the bolt's chain-arc art covers the body on the first 3-4
  hit frames, so the throw reads mostly as it eases back. Modest, not dramatic.
- Pit humans have 1 hp: only taps and chain hops stun; a charged bolt kills (electro_shock
  signature, unchanged, it reads).

### FINDING 20:31: plasma kill (owner item 1, killed): no change, with numbers
48 px/m director `plasma_rifle`: a 3-frame burst, the hole, the body thrown about 1.7 m (where
the gun drops to where the body lies), smoke. The it1 audit's "barely answers" was a misread
(the body sat at the frame edge). Tried `plasma_hole.launch_mps` 2.2-2.8: +0.2 m at rest (10 px
at 48 px/m), and GibSim is hashed sim state. Reverted, the clip deleted, audit row corrected
(victim sync 1 -> 3). Decision line `6ea2ed49`.

- GATE 20:31: unit full suite on `015517e2`: 1128 passed, 0 failed (`evidence/ranged/it3-unit-head.log`).

### MILESTONE 20:35: `de10668f` `--shard-pop=<ticks>` (owner item 4 call)
`BrutalityHook.shard_pop`: sets the homing shard burst row's `grind_ticks` (default 36 = the
approved look, unchanged). Unit `test_shard_pop_sets_only_the_shard_freeze` (signature kills
13/13). The grind is GibSim state: another value moves the arena replay hash (no shard gun in
quest 1). FILM: director `homing_shard` 32 px/m, 36 vs 12: frames identical until 84 (the 12
pop), clip `masters n7/ranged/homing_shard_pop-call-32ppm.mp4` (in frames.json as an OWNER CALL).
LOOK: 12 pops while the next shards are still in flight, so the burst reads as the shot's
answer; 36 holds the frozen body with shards in it for about 0.6 s, then pops.

- GATE 20:37: scenarios on `015517e2`: 52 ran, 0 failed, 0 SCRIPT ERROR (`evidence/ranged/it3-scenarios-head.log`).

### MILESTONE 20:43: `da508e6b` the rocket and the mini-nuke boom on the blast frame (sound)
- Found: every round ended on `projectile_end` (concrete click) or `hit_flesh`; the two biggest
  hits had no sound of their own. Built: optional `end_cue` on weapons rows (schema +
  `WeaponSpec.end_cue`), StageAudio plays it where the round ends; new cue row `blast` = the
  shipped `car_wreck` explosion at pitch 0.85 with its crackle layer. `--end-cue=off` = before.
- MEASURE (1/60 s RMS windows of the movie audio, director chapters, off vs on): rocket blast drawn
  on video frame 64, boom from window 65, +4..10 dB through 77; nuke blast frame 111, boom from
  112. One frame after the flash, under the hit-stop. Video identical on and off.
- Clip `masters n7/ranged/rocket_blast_sound-ab-32ppm.mp4` (back to back WITH SOUND); frames.json
  now 8 rows. Not listened to (no audio judgement possible here): the asset is the approved one.
- FRICTION: lint gd-size counts the next function's `##` doc toward the previous function's
  length: a helper placed right after `from_row` made it "43 > 40". Put helpers at the file end.

### REPLY -> n7-melee (20:46): your call 7 (Kerf's every-other-cut stop) is decided, `0d4089f1`
`camera.json` `hitstop_cooldown_ticks` 20 -> 16 (decision line). Each 18-tick cut now gets its
stop; FeelBudget's 12 hit-stop ticks per 60 stays the cap for guns and ghosts alike. Merge
`n7-ranged` for it; drop the call from your REPORT (or keep it as "decided by ranged").
Also on the branch for you to know: `end_cue` on weapons rows (gun rounds only; ghost attacks do
not go through `CombatArena.shots`, so it does not reach Dent's blast: that needs a cue from your
side if you want one).

- GATE 20:47: unit full suite on `0d4089f1`: 1129 passed, 0 failed (`evidence/ranged/it3-unit-head2.log`).
- GATE 20:45: pit director reel on `da508e6b`: 19/19 down, 0 SCRIPT ERROR
  (`evidence/ranged/it3-reel-director.log`).

### FINDING 20:46: the director reel without `--loadout` does not fire Rivet's arsenal
The log says "director: no carry (run with --loadout=pistol); pistol skipped": every gun chapter
falls back to the default gun. Every reel gate so far (it1, it2, and n7-melee's) ran without it,
so "19/19" proved the reactions and kills, not the arsenal's own paths. Re-running with
`--loadout=pistol` (below). From now on the reel gate runs both ways.
- FRICTION 20:47: `--arena=city --chapter=<id>` alone fires the rocket short onto the road (0/1
  down in 380 frames); single-chapter city films are not the city reel. Deleted them.

### GATE 20:49: pit director reel WITH `--loadout=pistol` on `0d4089f1`
19/19 chapters fully down, 0 SCRIPT ERROR, no "skipped" line (`evidence/ranged/it3-reel-director-loadout.log`):
the first reel of the night that fired Rivet's own arsenal in every gun chapter.

### MILESTONE 20:50: 48 px/m close-up of the heavy feel (`heavy_feel-ab-48ppm.mp4`)
Hand cannon kill on movie frame 49, stop held 51-55; rocket blast on frame 64, stop held 65-72;
`--feel=off --end-cue=off` vs on, director chapters with the loadout. LOOK (stills): the after
holds the impact star / the first blast frame where the before has already moved on; the after
runs behind by the stop, so side by side shows different phases (noted in frames.json).

### MILESTONE 20:52: `e32720c4` the flamer's ignition kick (brief item 5)
`ignite_kick_px` (optional) on hit_feel weapons rows; flamethrower 3 px / 9 ticks on the first
puff after a 20-tick rest; puffs do not kick. Unit `test_feel_ignite` 2/2; planted fault
(IGNITE_IDLE_TICKS 0: every puff kicks) -> 1 failing. MEASURE: one 2.9 px jump at frame 45, back
by 52, still after; `--feel=off` 0.0. Clip `flamer_ignite-ab-32ppm.mp4` (frames.json now 10
rows). Audit row 9 scored (2/3/3/3). Not judged by eye in motion.

NEXT (iteration 4):
1. Gates on head (last full unit 1129/0 at `0d4089f1`, scenarios 52/0 at `015517e2`): full unit +
   scenarios + the city reel (`--arena=city --bot=reel --reel=director`, both with and without
   `--loadout=pistol`); then `node tools/evidence/run.mjs --no-bench` (tree untouched during it).
2. City-block combined clip (30-90 s, 32 px/m) of the polished set: record ONE full city reel with
   `--loadout=pistol --write-movie` and cut chapters by the "director chapter <id> at tick N" log
   lines (single `--chapter` city films do not frame: the rocket lands short).
3. Judge by eye in motion what is only measured: Gatling rumble + spin-up, flamer ignition (3 px
   may be too timid at 32 px/m: try 4-5), electro snap. If timid, tune by data, re-measure.
4. Brief item 6: quest 1 fires the table guns (GunHand + LiveInput.px_per_m in quest 1); expect a
   quest 1 replay re-bless with a decision line. Biggest remaining brief item.
5. FightCam framing at 64 px/m (Rivet half off frame; blasts half off at 32 on wave 2): capture only.
6. Audit gaps: gloria, assault-rifle (`--loadout`), molotov throw anticipation.
7. REPORT calls so far: shard pop (36 vs `--shard-pop=12`, clip in masters). Exe by 08:30.

### GATES 21:00 on head `9928c09a` (tree untouched during the runs)
- `node tools/evidence/run.mjs --no-bench`: lint 13/13 over 937 files, unit 1131/0, scenarios 52/0,
  parity bit-exact over 1200 steps (planted mutation caught at 629), selftest pass (look goldens
  11/11, block 5/5) (`evidence/ranged/it3-evidence-9928c09a.log`, `build/evidence/*.json`).
  No bench: no performance claim.
- City-block director reel with `--loadout=pistol`: 19/19 fully down, 0 SCRIPT ERROR, nothing
  skipped (`evidence/ranged/it3-reel-city-loadout.log`). Pit with loadout: 19/19 at `0d4089f1`.
- Registry rules applied this iteration: `motion-quality-gating` (scores per dimension; a change
  is judged against a before film on the same path; "measured, not looked at" stays labelled);
  `realtime-combat-semantics` (the victim's reaction on the hit frame: the electro snap starts in
  2 ticks; sound on the frame: the blast cue within 1 frame); restraint (per-second budget, not
  per-hit effects: the flamer kicks once per ignition, never per puff).
### PLAN 20:56: brief item 6, quest 1 fires the table guns (read only, nothing built)
- Quest 1 has no `GunHand`: `CombatArena.gun` stays null, so Rivet fires the evening path
  (combat.json assault rifle, then Gloria from the Toner Room line hook). gunplay REPORT next step 4.
- Where: `Quest1Session.open` builds `CollectCallStage` (owns `arena`) and `LiveInput`; the arena
  path does it in `GunplayHook.setup` (`GunHand.make(table, weapon, ctx.rng.stream(&"gunplay"))`,
  `rivet.weapon`, `GuardTell`, `HitLink.make`). Quest 1's view already has a `CastView.hit_link`.
- Steps: (1) in the stage (headless too, so the replay sees it) make the GunHand for the
  quest's current gun from `weapons.json` (the assault-rifle row via its `shot_cue`, `gloria`
  after the Toner Room hook, swap in `stage_lines.gd`); (2) `session.live.px_per_m =
  func() -> float: return view.px_per_m` in `quest1_game.gd`; (3) film quest 1 before/after at
  32 px/m; (4) the quest 1 replay and scenario goldens will move: decision line + deliberate
  re-bless (`scenario_quest1_*`, the 60 s replay), never a silent one.
- Risk: the gun table's hp scale is 1/human_hp (1 in quest 1) = the same one-hit doctrine; check
  the tazer boss fight (`player_hit_robo_tazer`) is untouched.

### MILESTONE 21:04: `078e83ab` Gloria's recoil kick (audit gap closed)
- Audit row 13 scored from `sheets/gloria-off-k2.png` (`5b6ca7e6`): 1/2/3/3/0, anticipation weakest.
- hit_feel.json gloria `fire_kick_px` 1.5 / 6 ticks. MEASURE (gunplay bot, lone cop, 32 px/m,
  frames 200-290, 9-frame high-pass): jitter rms 0.19 -> 0.34 px, max 0.36 -> 1.53 px; lone kill
  1 at tick 274 on and off. Clip `gloria_kick-ab-32ppm.mp4` (frames.json now 11 rows: trim to 15
  max, newest first). Feel tests 7+10+2+2 pass with the row. Plays in quest 1's Gloria fight too
  (FeelCam reads `Shot.weapon`). Not judged by eye in motion.
- There is no director chapter for Gloria (`--chapter=gloria` runs nothing): film it with
  `--weapon=gloria --bot=gunplay --lone --cam=fight`.

STOP 21:05 iteration 3. Head `078e83ab`; gates last full at `9928c09a` (evidence run green, both
reels 19/19 with the loadout); since then only data rows (gloria kick) + docs, feel tests green.
NEXT is the 20:52 list above, with: item 1 re-run the evidence run + reels on the new head
first; item 6 adds assault-rifle and molotov-throw scoring only (Gloria done). Owner calls so far
for REPORT: the shard pop (36 default vs `--shard-pop=12`, clip in masters).
- GATE 21:08: pit director reel with `--loadout=pistol` on head `b5f5c7c5`: 19/19 fully down,
  0 SCRIPT ERROR, nothing skipped (`evidence/ranged/it3-reel-director-loadout-b5f5.log`).

## Iteration 4 (21:09-22:09), BUILD

### MILESTONE 21:25: `48679f03` quest 1 fires the table guns (brief item 6)
- `StageGuns` (boot/collect_call/stage_guns.gd), set by `Quest1Session.open` when `table_guns`
  (default true; `--quest-guns=off` = the before, in LaunchArgs and the quest1_clip recorder):
  each tick before the pilot fires, `CombatArena.gun` follows `rivet.weapon`. A weapon with a
  weapons.json row (Gloria, from Brass's line) gets a `GunHand` (rng stream `quest_guns`, `tap`
  true: a held fire re-fires her as the evening path did every 0.4 s); a weapon without one (the
  contractors' assault rifle he picks up) sets `gun` null, so combat.json's rifle (30 rounds, then
  Gloria) is untouched. `LiveInput.px_per_m` wired in `quest1_game.gd` (`_bind_live`).
- DECISION (docs/decisions.md): the rifle stays on combat.json; mapping it onto `machine_pistol`
  (50 dmg = two hits per human) was rejected (breaks the one-hit doctrine). Re-check when the rifle
  gets a weapons.json row.
- SIM: quest 1's state hash moves (scenario_quest1_input final 5fce2662.. -> 4aab804f..); beats,
  49 kills, 65 shots, 0 deaths, 316.6 s identical. No quest golden hash is committed (the 60 s
  replay is the dummy sim), so no re-bless was needed; b3+ checkpoints from older builds will be
  refused (stale-save rule). Quest scenarios 9/9 (`evidence/ranged/it4-scen-quest.log`).
- Unit `test_stage_guns` 4/4, 0 orphans; planted fault (`tap` false) -> 1 failing.
- FILM: quest 1 Dock 9, ticks 13580-13860, 32 px/m, `--cam=fight`, off vs on:
  `masters n7/ranged/quest1_table_gloria-ab-32ppm.mp4` (hstack). LOOK (stills 20-120 + a per-frame
  diff): the change is SMALL at 32 px/m in this window: the table floor (a scuff/casing dot by
  Rivet), the dropped rifle drawn as art instead of an ink dash; I saw no Gloria muzzle cell in the
  sampled stills (Rivet fires little in this window). Not a strong visual win yet: the quest's
  Gloria fight (b5 Mertz, from tick ~15181) is the better window to film next.
- FRICTION: gdformat on Windows writes CRLF; strip with `sed -i 's/\r$//'` after it.
- NOTE -> n7-melee: your NEXT item 6 (a carried blade in quest 1) will move the same quest 1 hash;
  there is no committed golden, so the two changes do not conflict in a golden file, only in
  `collect_call_stage.gd`/`quest1_session.gd` if you touch them (my edits: a `guns` var + 2 lines
  in `step()`, a `table_guns` static + 2 lines in `open()`).
- GATES 21:25 on `48679f03`: lint 13/13 over 939 files; unit 1135/0 (`evidence/ranged/it4-unit.log`);
  scenarios 52 ran, 1 failed = `scenario_city_chase` nav budget (3274 us > 2 ms, the known flake
  under contention), re-run alone: 1/0 (`it4-scen.log`, `it4-scen-city-chase.log`); 0 SCRIPT ERROR.
- FILM 21:28: quest 1 Mertz fight (b5), ticks 15180-15600, 48 px/m, `--cam=fight`, off vs on:
  `masters n7/ranged/quest1_table_gloria_mertz-ab-48ppm.mp4`. LOOK (tile of every 15th frame +
  the most-different pair, frame 178): mostly under Mertz's dialogue; the fine sim state diverges
  (Mertz stands a little elsewhere in frame 178, as expected once the hash moved), beats the same.
  Again a small visible change; I could not find a frame with a Gloria muzzle cell in the samples.
  frames.json now 13 rows. Scratch frames deleted.

### MILESTONE 21:42: the city-block combined clip of the polished set (deliverable)
- One continuous director reel in the city block with the loadout, 32 px/m, fixed 60 fps, Movie
  Maker (`res://dev/arena/arena.tscn -- --arena=city --bot=reel --reel=director --loadout=pistol
  --ppm=32`, `--quit-after 5800`): 16 chapters down (claw_combo .. riot_cop), 0 SCRIPT ERROR
  (`evidence/ranged/it4-city-reel-movie.log`). Cut: frames 1150-2280 (rocket, flamer, electro),
  3850-5080 (hand cannon, plasma rifle, ray gun, homing shard, riot cop), 5470-5800 (the nuke chapter
  to its first blast frame) -> `masters n7/ranged/city_block_polished_set-32ppm.mp4`, 44.8 s, with
  sound; frames.json row 1 (14 rows now). LOOK (stills 3/12/24/44 s): Rivet with each gun, red blood,
  ink scorch, cops' cars blue-lit; the dev telemetry panel and the ghost bar are in frame (arena
  HUD); the fight sits at the right of a fixed camera (no `--cam=fight` in this take).
- FRICTION 21:35: `--arena=city ...` on `--path project` alone boots the MAIN scene (title card;
  every arena flag "unknown, ignored"): 7 min of Movie Maker wasted. The arena is
  `res://dev/arena/arena.tscn` as the scene argument. Frames run about 25-40 ticks ahead of the sim
  tick by mid-reel (hit-stops hold frames), so 5800 frames stopped on the nuke's first blast frame;
  next time `--quit-after 6200` to keep the nuke's whole blast.
- GATE 21:46: pit director reel with `--loadout=pistol` on head `43622ec7` (quest 1 table guns
  in): 19/19 chapters fully down, 0 SCRIPT ERROR, nothing skipped
  (`evidence/ranged/it4-reel-director-loadout.log`). City reel on the same head: 16/16 down to
  riot_cop in the movie take above (the nuke chapter was cut by the frame cap, not failed); the
  full city reel with the loadout was last 19/19 at `9928c09a`.

- Registry rules applied this iteration: `motion-quality-gating` (the quest change judged against a
  same-build before film on the shipped path; "small visible change" stated, not dressed up);
  `realtime-combat-semantics` (hits stay generic: StageGuns arms the table row by weapon id, no
  target special case; the one-hit doctrine kept by refusing the machine-pistol mapping).
- FINDING 21:48: quest 1's Gloria muzzle: FxView draws WeaponFxArt's muzzle when the row has art,
  else GunFxArt's star; a flash lasts a few ticks per 24-tick shot, so my 10-15 sampled stills per
  film probably missed it. Unverified by eye, not claimed.

STOP 21:49 iteration 4. Head `e1250b91`. Gates on `48679f03` (the only code change): lint 13/13,
unit 1135/0, scenarios 52 (city_chase flake re-run green), pit reel 19/19 with the loadout on
`43622ec7`.

NEXT (iteration 5):
1. Quest 1 Gloria muzzle by eye: re-film Dock 9 at 48 px/m every tick (`quest1_clip_rec` `every`
   1, a 120-tick window where the HUD shows GLORIA and Rivet fires) on vs `--quest-guns=off`; find a
   shot frame (diff Rivet's box), make a still pair. If the table read is not visibly better, say so
   in REPORT (the change still unifies quest 1 with the arena: feel, cue, casings, slide).
2. Full city reel with the loadout on head (`res://dev/arena/arena.tscn -- --arena=city --bot=reel
   --reel=director --loadout=pistol`), 19/19; then `node tools/evidence/run.mjs --no-bench` on head.
3. Judge by eye in motion (48 px/m, every frame): Gatling spin-up rumble, flamer ignition (3 px,
   maybe 4-5), electro snap. Tune by data only if timid; re-measure.
4. Optional retake of the city combined clip with `--cam=fight` and `--quit-after 6200` (keeps the
   whole nuke blast, frames the fight); replace row 1 of frames.json if better.
5. Audit gaps: assault rifle (quest 1's own, not a table gun: score its read in quest 1), molotov
   throw anticipation.
6. REPORT calls so far: shard pop (36 default vs `--shard-pop=12`, clip in masters). Mention
   `--quest-guns=off` as the before of quest 1's table guns (not a call: gunplay's next step).
   Exe by 08:30 (int-day recipe in docs/decisions.md).
7. n7-melee: told in JOURNAL (21:25 NOTE) that quest 1's hash moved and which lines I touched.

### MILESTONE 21:55: `1ce1b11e` the muzzle flash stays on the shot's aim (found by filming quest 1)
- NEXT item 1 done early: quest 1 Dock 9 re-filmed at 48 px/m, no fight cam, off vs on; a diff of
  Rivet's 400 px box per frame spikes every 12 frames (= Gloria's 24-tick shots: frames 35, 47, 59..).
- BUG seen on frame 35: the nail flew left while Gloria's ink-and-cream star drew on Rivet's RIGHT.
  Cause: `WeaponFxArt.muzzle` anchored on `rivet.facing`, which the pilot resets to the walk
  heading on the ticks between shots (the driver aims only on fire ticks), and the flash lives a
  few ticks after the shot. Fix: `GunHand.last_aim` (set in `pull`, view only, in no state hash);
  the muzzle uses it, `r.facing` only before the first shot. Applies in the arena too.
- AFTER (look): frame 35 the star sits on the nail line in front of Rivet; frame 47 (other heading)
  too, cream with its vermilion fire core. Still `masters .../quest1_gloria_muzzle_side-48ppm.png`
  (3 panels: evening path / bug / fix); clip `quest1_table_gloria_dock9-ab-48ppm.mp4` (off vs fix)
  replaces the Mertz close-up (deleted: it showed no shot). frames.json 15 rows.
- Unit 1135/0 on the change (`evidence/ranged/it4-unit-muzzle.log`); lint 13/13.
- LEFT: `GunFxArt`'s fallback muzzle (`gun_fx_art.gd:114`, guns WITHOUT weapon art) and `GunFx`'s
  claw bits (`gun_fx.gd:129/135/153`) still use `r.facing`; same flip is possible there. The 32 px/m
  quest clip `quest1_table_gloria-ab-32ppm.mp4` predates the fix: retake it (fight cam, 32 px/m).

NEXT (iteration 5), replaces the 21:49 list:
1. The same muzzle flip for guns WITHOUT weapon art: `GunFx.muzzle(r, ahead)` (gun_fx.gd:129,
   used by the fallback flash, smoke and shells) and `GunFxArt._muzzle` (gun_fx_art.gd:114) use
   `r.facing`. GunFx.muzzle also serves the hostiles' stars, so use `arena.gun.last_aim` only when
   `r.kind == Fighter.Kind.RIVET` (store it in `GunFx.step`). gun_fx.gd is 212 lines: keep it short.
   Which table guns lack weapon art: `WeaponFxArt.art().has(id)` per weapons.json id.
2. Retake `quest1_table_gloria-ab-32ppm.mp4` on head (32 px/m, `--cam=fight`, Dock 9 13580-13860;
   the current one predates the muzzle fix), replace its frames.json row.
3. Full city reel with the loadout on head (19/19) + `node tools/evidence/run.mjs --no-bench`.
4. Judge by eye at 48 px/m, every frame (the per-frame diff trick finds the shot frames): Gatling
   spin-up rumble, flamer ignition (3 px; maybe 4-5), electro snap. Tune by data only if timid.
5. City combined clip retake with `--cam=fight`, `--quit-after 6200` (whole nuke blast).
6. Audit gaps: quest 1's assault rifle read, molotov throw anticipation.
7. REPORT: calls so far = the shard pop (36 vs `--shard-pop=12`). Befores to list: `--feel=off`,
   `--react-snap=off`, `--end-cue=off`, `--quest-guns=off`. Exe by 08:30.
STOP 21:57 iteration 4. Head after this commit; code gates last on `1ce1b11e`: lint 13/13, unit
1135/0; scenarios 52 (flake re-run green) and pit reel 19/19 on `48679f03`/`43622ec7` (the muzzle fix
is view only and changes no sim path).

## Iteration 5 (BUILD, 21:55-22:55)
Read: JOURNAL, git log, the other lanes' journals (no new REQUEST for ranged; melee merged
`48679f03` at 21:41).

### MILESTONE 22:05: `ed60713e` smoke, shells and the fallback flash follow the shot's aim
- NEXT item 1: `GunFx.aim` (= `GunHand.last_aim`, taken in `step`), `GunFx.aim_of(r)` (facing
  before the first shot); used by `muzzle`, `_eject`, `_reload_drop` and `GunFxArt._muzzle`. Every
  `GunFx.muzzle` caller passes `arena.rivet`, so no hostile path changes. View only.
- All 13 weapons.json guns have weapon art (checked), so the fallback star never draws for a table
  gun; the visible part of this fix is the smoke puff and the shell kick side.
- `test_gun_fx_aim.gd` 2 tests; planted fault (`aim_of` returns facing) -> 1 failing. Unit
  1135/0 before the test (`evidence/ranged/it5-unit-gunfx-aim.log`), 1137/0 with it; lint 13/13.
- FRICTION: Python text-mode writes on Windows put CRLF into .gd files; `sed -i 's/\r$//'` after.

### FILM 22:08: quest 1 Dock 9 at 32 px/m retaken on head (NEXT item 2)
- `quest1_clip.gd --ppm=32 --cam=fight --ticks=13580-13860` on vs `--quest-guns=off`
  (`it5-q1-on.log`/`it5-q1-off.log`, exit 0 both). LOOK (frames 44-92, every frame round the
  launches): frame 47 Gloria's cream star with the vermilion core sits on the nail line on the shot
  side at 32 px/m, then the nail flies; a smoke puff on the aim side at frames 90-92. Replaced
  `masters .../quest1_table_gloria-ab-32ppm.mp4` and its frames.json row (still 15 rows).

### FINDING 22:20: molotov throw at 48 px/m (audit gap, NOT scored)
- Film: `--weapon=molotov --bot=gunplay --lone --cam=fight --ppm=48`, 600 frames; 1 throw, 1 burn
  kill at tick 447, 0 SCRIPT ERROR (scratch `molo/`).
- LOOK: frames 270-298 a dashed then solid vermilion line through Rivet with a black ring ahead
  (I take it for a telegraph or aim aid; not identified); a vertical vermilion stick that stays put
  in world (no spin, so not the spinning bottle; probably the weapon rack's molotov on the floor);
  the fire burst and the burning cop at frames 340-365 read strongly. I did NOT find the spinning
  bottle in flight in 2- and 4-frame samples. Throw anticipation stays "?" in the audit.
- Next time: log the Shot's tick (or film `--reach=6` so the throw and the patch share the frame)
  before judging the throw.

### FINDING 22:16: the molotov throw resolved with `--reach=7` (48 px/m), audit row 10 scored 1/3/3/3/0
- The long vermilion line through Rivet in the 22:20 take is the COP's aim telegraph: it ends at
  the cop, who then fires (white stars at frames 300 and 320 of `molo/molotov-r6.avi`). The bottle
  flies from Rivet to the cop as a thin dark stick with a vermilion wick; the burst at about
  frame 328 (big ink, cream and vermilion star, glass) and the burning cop read at a glance.
  Rivet shows NO throw wind-up: anticipation 1.
- A real wind-up (arm back BEFORE the release) needs the release to wait in the sim (a gameplay
  timing change, a re-bless): not tonight. Follow-through on the release is view only.

### MILESTONE-NOT 22:24: `41bb90e7` (molotov rig_kick -1.6, the arm forward on release): NO visible effect
- Before/after at 48 px/m, same args (`--weapon=molotov --bot=gunplay --lone --cam=fight --reach=7`),
  kill tick 458 both (sim identical). Pixel diff of frames 250-340: ZERO pixels differ (> 40).
- Cause: `rig_arm.gd:41-42` clamps the hand to upper+fore length; the aimed pose already sits at
  0.97 of it (`rig_arm.gd:85`), so a forward kick gains at most 3 %. A pull-back shows; a push
  forward cannot. Kept (harmless, generic: a negative kick is legal now), but claimed as nothing.
- Next: the follow-through through the torso (`c_lean`, 40 part-px per unit in `rig_pose.gd:35`,
  the punch's lean): `c_lean = max(0.6 * c_reach, -k * recoil)` in `RigClips.sample`.

- GATE 22:05: city-block director reel with `--loadout=pistol` on `ed60713e`: 19/19 fully down,
  0 SCRIPT ERROR (`evidence/ranged/it5-reel-city-loadout.log`). The reel does not quit after its
  last chapter in headless (earlier takes ended on `--quit-after`): I killed my own process (PID
  49384) after the 19th chapter line. Next time add `--quit-after 7400`.
- 22:18 I killed my own first evidence run (started 22:11 on `ed60713e`) because I edited the tree
  under it; re-run on `41bb90e7` at 22:21 (`evidence/ranged/it5-evidence-41bb90e7.log`).
- REPORT.md draft committed (`f4a3da61`): what works with evidence, the shard-pop call, befores.

### GATE 22:29: evidence run on `41bb90e7` (`evidence/ranged/it5-evidence-41bb90e7.log`)
- lint 13/13, scenarios 52/52, parity bit-exact over 1200 steps (planted mutation caught at 629),
  selftest pass (look goldens 11/11, block 5/5). Unit 1138/0 but FAIL by the tree-change guard:
  I committed docs (JOURNAL, REPORT, audit) during the run. My error; tests themselves green.
  Lesson: touch nothing in the worktree, docs included, while `run.mjs` or `run_unit.mjs` runs.

### MILESTONE 22:35: `7326b53b` the throw leans the torso into the release
- `RigClips.THROW_LEAN` 0.5: `c_lean = max(0.6 * c_reach, -THROW_LEAN * recoil)`; guns unchanged.
- A/B at 48 px/m, `--reach=7`, same args as the before (`molo/molotov-r6.avi`): kill tick 458 on
  both; pixel diff around Rivet from frame 289 (the release), peak 1763 px at frame 301, fading by
  about 315. LOOK (pair at frames 286/292/296/301/306): the torso sits a few px toward the cop on
  292-301, then settles. SUBTLE, not a strong read; anticipation stays 1 (no wind-up).
- Unit 1138/0 (`it5-unit-lean.log`, the test asserts c_lean > 0.7 on `shoot(-1.6)`), lint 13/13.
- Clip `masters .../molotov_throw_lean-ab-48ppm.mp4` (frames.json row 2; the 48 px/m muzzle-side
  still dropped, the Dock 9 48 px/m clip shows the same fix in motion). Decision line written.
- Registry rules applied: `motion-quality-gating` (A/B on the live arena path with identical args
  and sim, a pixel diff to find the frames, then a look; a change with no visible effect,
  `41bb90e7`, recorded as such, not dressed up); `realtime-combat-semantics` (the release stays on
  the sim's frame; the wind-up that would move it is deferred as a gameplay change).

- GATE 22:36: pit director reel with `--loadout=pistol` on `7326b53b`: 19/19 fully down, 0 SCRIPT
  ERROR (`evidence/ranged/it5-reel-director-7326b53b.log`; stopped by my watch after the last
  chapter). With the city reel 19/19 on `ed60713e`, both reels are green this iteration.

NEXT (iteration 6):
1. A clean `node tools/evidence/run.mjs --no-bench` on head, touching NOTHING during it (the
   it5 run on `41bb90e7` was flagged by the tree guard for my docs commits).
2. The throw lean is TIMID at 32 px/m (MEASURE 22:38 below). Try THROW_LEAN 1.0 (and maybe a
   longer hold: the lean follows the recoil's 0.27 s decay) with the same A/B (`lean_ab.sh`, swap
   `--ppm=32`); keep the value that reads at 32 without looking like a stumble; re-run unit + pit reel.
3. Judge at 48 px/m every frame: Gatling spin-up rumble, flamer ignition (3 px; maybe 4-5), electro
   snap. Tune by data only if timid.
4. City combined clip retake with `--cam=fight`, `--quit-after 6200` (whole nuke blast).
5. Quest 1's assault rifle read (score it).
6. Exe by 08:30: `windows-showcase` preset (decisions.md 2026-11-04 showcase export) ->
   `build/export/windows/RTAI.exe`; REPORT command lines + befores (`--feel=off`,
   `--react-snap=off`, `--end-cue=off`, `--quest-guns=off`, `--silent`, `--shard-pop=12`).
7. Headless reels do not quit by themselves, and `--quit-after` counts frames, not ticks (8000
   frames reached only tick 3390): watch the log for `director chapter electro_chain: ` and stop
   my own process then (the it5 22:36 run did exactly this).

STOP 22:37 iteration 5. Head after this commit. Code commits: `ed60713e` (gun_fx aim), `41bb90e7`
(negative rig_kick, no visible effect alone), `7326b53b` (throw lean, subtle). Gates on `7326b53b`:
unit 1138/0, lint 13/13, pit reel 19/19; evidence run (scenarios, parity, selftest) on `41bb90e7`.
- MEASURE 22:38: the throw lean at 32 px/m (`7326b53b` vs THROW_LEAN 0 set locally and restored,
  same args, `--ppm=32`): diff 607 px at frame 301, 291 at 302, 171 at 303, then 10-45 px. About a
  1-2 px shift for 3 frames: practically INVISIBLE at 32 px/m. At 48 px/m it is a few px over about
  15 frames. Verdict: an honest small gain at close-up zoom only; tune in iteration 6 (NEXT 2).

## Iteration 6 (BUILD, 22:40-23:40)
Read: JOURNAL NEXT, git log, the other lanes' journals (no new REQUEST for ranged).

### MILESTONE 22:58: `9b351ab4` a throw whips the gun shoulder through (NEXT 2)
- MEASURE first (32 px/m, `--reach=7`, kill tick 458 on every take, `molo/lean_multi.sh`):
  THROW_LEAN 0 vs 1.0 vs 1.5: peak diff 754 / 890 px (607 at 0.5): the lean saturates; the grid
  (frames 298-312, x3 crops) shows no visible difference even at 1.5. Kept 0.5.
- Instead `RigClips.THROW_TWIST` 0.3 rad per unit of negative recoil, in `RigPose` beside the
  strike's `reach_tw` (same sign convention: the gun shoulder leads). A/B vs no follow-through:
  diff 500-800 px per frame over frames 301-315 at 32 px/m; 48 px/m from frame 289 (the release),
  peak 2210 px. LOOK (grids `tw_grid32.png`, `tw_grid48.png`): the shoulder line turns toward the
  throw and back; no stumble. MODEST but visible at 32. Anticipation stays 1 (no wind-up).
- Test `test_a_throw_whips_the_gun_shoulder_through`; planted THROW_TWIST 0 -> exactly that test
  fails (1138/1139); unit 1139/1139 with it; lint 13/13 (940 files).
- Clip `masters .../molotov_throw_twist-ab-32-48ppm.mp4` replaces the lean clip (frames.json row 2,
  still 15 rows). Decision line written. Registry rule applied: motion-quality-gating (measure the
  candidate values on the live path, judge the grid, keep the channel that reads at 32 px/m).

### GATE 22:57: evidence run on `46db2e81`, clean tree, nothing touched during it
- lint 13/13 (940 files), unit 1139/0, scenarios 52/52, parity bit-exact over 1200 steps (planted
  caught at 629), selftest pass (look goldens 11/11, block 5/5). `evidence/ranged/it6-evidence-46db2e81.log`.

### MILESTONE 23:06: `5ef1c584` the flamer flares as it lights (NEXT 3, the flamer part)
- The 3 px ignition kick was motion only and subtle. Now the lighting round also draws the nozzle
  lick as a fireball: hit_feel.json flamethrower `ignite_flare_k` 1.1 (lick 0.45) over
  `ignite_flare_ticks` 10; new `WeaponFxIgnite` (39 lines, static, keyed off the sim's shot tick =
  tick - age, FeelCam's rest rule), `HitFeel.ignite_flare` (zero under --feel=off), schema fields.
- FRICTION: `Dictionary[StringName, int].get()` returns Variant; `float(...)` / `Vector2(...)` on
  it is a warning-as-error (27 unit failures from the parse error); typed locals fix it.
- Tests `test_weapon_fx_ignite.gd` 2; planted fault (never lit) -> exactly that test fails
  (1140/1141); unit 1141/1141 with it (GUT direct); lint 13/13 (942 files).
- LOOK 48 px/m (`ign_grid2.png`, frames 327-330, x3): an ink-edged vermilion and cream fireball
  about 2x the lick on 327-328, smaller on 330 (the muzzle cell draws 2 of 3 ticks). 32 px/m
  (`ign_grid32.png`): reads on 326-327, smaller 330, gone by 333. Doctrine kept (fire = vermilion
  and cream, ink edge). Clip `masters .../flamer_ignite_flare-ab-32-48ppm.mp4` (frames.json row 1,
  replaces `flamer_ignite-ab-32ppm.mp4`; 15 rows). Decision line written.
- Registry rule applied: realtime-combat-semantics (the flare keys to the sim's shot tick, view
  only, the sim untouched); motion-quality-gating (A/B same args, look per frame at 32 and 48).

### GATE 23:09-23:12: both director reels with `--loadout=pistol` on `5ef1c584`
- Pit: 19/19 chapters, every one fully down (14x 1/1, 2x 2/2, 3x 4/4), 0 SCRIPT ERROR
  (`evidence/ranged/it6-reel-director-5ef1c584.log`). City block (`--arena=city`): 19/19 fully
  down, 0 SCRIPT ERROR (`evidence/ranged/it6-reel-city-5ef1c584.log`). Both stopped by my watcher
  after the electro_chain line (my own PIDs 34727, 36865).

### FINDING 23:15: the ray gun kill at 32 px/m (audit row 8, the next item)
- Film `--weapon=ray_gun --bot=gunplay --lone --cam=fight --ppm=32 --clean --reach=6` (kill tick
  300, 0 SCRIPT ERROR; scratch `ray/ray32r.avi`; without `--reach` the victim was off the fight
  framing). LOOK (sheet `ray/ray_sheet2.png`): f300 the cream beam; f302-304 a big ink/cream star
  on the cop, the kill stop holds 304-307; f308-310 a cream disc on the body; from f313 the body
  lies ON THE SPOT with a pale ring. The hit frame reads (star + stop); the body does not answer
  the beam: the ray's class is `shock`, so it dies `death_shock` (convulse + plank, travel 0.4 m),
  the electro gun's signature.
- Plan (it7): a `weapon_death` map in human_reactions.json beside `weapon_wound`
  (`ReactTable.weapon_death`, `DeathPipe.kill` tries it before `death_for(hit_class)`), ray_gun ->
  `death_bullet` (falls back along the hit, 0.7 m) or a stronger family; A/B at 32 px/m with the
  row removed as the before; owner call (the ray's death changes an approved reaction). Generic:
  keyed by weapon id, so it works on any human victim; robots keep `death_robot`.

NEXT (iteration 7):
1. The ray gun death (FINDING 23:15): `weapon_death` map, ray_gun first; unit test with a planted
   fault; A/B 32 px/m (`--reach=6`) + 48 close-up; both reels; REPORT call (options: death_shock
   as main / death_bullet / a heavier throw; how to see: remove the row).
2. Electro snap: the chain-arc art covers the victim on the first 3-4 hit frames (`electro_snap`
   note): look at 48 px/m whether the arc can draw under/after the body, or the snap waits 1 tick.
3. Gatling spin-up at 48 px/m: judge by eye in the clip (measured only so far).
4. City combined clip retake with `--cam=fight`, `--quit-after 6200` (add the flamer flare and the
   throw twist to the set).
5. Quest 1's assault rifle read (score it).
6. Exe by 08:30: `windows-showcase` preset (decisions.md 2026-11-04 showcase export) ->
   `build/export/windows/RTAI.exe`; REPORT command lines + befores (`--feel=off`,
   `--react-snap=off`, `--end-cue=off`, `--quest-guns=off`, `--silent`, `--shard-pop=12`).
7. Commit docs BEFORE `run.mjs`, touch nothing while it runs (it6 run clean that way).

STOP 23:17 iteration 6. Code commits: `9b351ab4` (throw shoulder twist, modest, visible at 32),
`5ef1c584` (flamer ignition flare, reads at 32). Gates: evidence run on `46db2e81` all green (unit
1139); on `5ef1c584` unit 1141/1141, lint 13/13 (942 files), pit + city reels 19/19 fully down.
- GATE 23:19 on `81176d04` (= `5ef1c584` code): scenarios 52 ran, 1 failed = `scenario_city_chase`
  2 ms nav budget (max 3871 us, the known contention flake); re-run alone (`--filter=city_chase`):
  1 ran, 0 failed. 0 SCRIPT ERROR. Parity bit-exact over 1200 steps, planted mutation caught at 629.
  Logs `evidence/ranged/it6-{scenarios,scenario-city-chase-alone,parity}-81176d04.log`.
  So every gate is green on head's code.

## Iteration 7 (BUILD, 23:23-00:23)
Read: JOURNAL NEXT, git log, n7-melee / n7-king / n7-servo journals.

### FINDING 23:27: the ray gun kill is the approved dissolve; my it6 diagnosis was wrong (NEXT 1 closed, no change)
- Film 48 px/m (`--weapon=ray_gun --bot=gunplay --lone --cam=fight --ppm=48 --clean --reach=6`,
  kill tick 300, 0 SCRIPT ERROR; scratch `ray/ray48.avi`, sheet `ray/sheet48.png`, frames
  298-349 every 3rd, cropped on the victim). The arena's 18 stations include `brutality_pit`, so
  the ray kill IS the brutality signature `ray_gun_dissolve` (signature_kills.json, an approved
  baseline): f301-304 the ink/cream star + kill stop; f307 the cream glow on the head; f310-313 the
  hot ring wraps the body; f316-337 the body locks and falls stiff inside a pale disc (the shock
  plank under the dissolve: "the victim locks up glowing"); from f340 (stand_ticks 30) gold echo
  rings eat it down to the dust heap. Every beat reads at 48 px/m; at 32 px/m (it6 sheet) the star,
  the disc and the gold ring read.
- So the "body does not answer the beam" note was the signature's lock-up working as designed. A
  `weapon_death` map would only change the `--gore=reduced` path. NOT built: it would rewrite an
  approved signature beat without a reason the film shows. Registry rule applied:
  motion-quality-gating (look at the film per frame before building; a diagnosis the frames refute
  is recorded, not built on).

### FRICTION 23:40: REQUEST 4 (n7-melee, stun marks under a mass arc) was already built by melee
- I built a `cap.stun_arcs_full` row in hit_feel.json + ShockArcsView ranking (unit 1145/1145, a
  planted `<=` caught by exactly its test, lint 13/13) before reading melee's journal past 22:55:
  melee had built it at 23:25 as `7ce7b33d` (human_reactions.json `stun_crowd`, StunCrowd, which
  also caps WeaponFxElectro's head sparks, the larger share of the cream). Mine was a second layer
  over the same views: DISCARDED (files restored, test deleted). REQUEST 4 is CLOSED by melee's
  7ce7b33d; the electro gun's chain shares it when the Director merges both lanes.
- Rule for me: read the other lanes' journals to their END before building on a REQUEST. Cost
  about 15 min. Also: `run_unit.mjs` needs `GODOT_BIN` exported (`spawnSync godot ENOENT` = exit -1).
- To keep the merge clean I do not touch `shock_arcs_view.gd`, `shock_jolt.gd`,
  `weapon_fx_electro.gd`, `fight_areas_art.gd`, `react_table.gd` tonight (melee's 7ce7b33d files).

### MILESTONE 23:56: Rivet's pistol flash reads at 32 px/m (audit row 11, anticipation 1)
- LOOK first (head, `--weapon=pistol --bot=gunplay --lone --cam=fight --ppm=32 --clean --reach=6`,
  kill tick 302, 0 SCRIPT ERROR; x4 crops frames 296-301): Rivet's flash is a 15 px speck on
  frames 298-299, while the cop's own flash (f295-297) is a bigger cream star: the hero's shot read
  second. hit_feel.json `weapons` pistol `muzzle_k` 1.6 (new optional field; `HitFeel.muzzle_k`,
  1 for any weapon without it and under --feel=off; `WeaponFxIgnite.muzzle_k` feeds
  `WeaponFxArt.muzzle`, one line there, the file stays 290).
- A/B (same args, identical sim, kill 302 on both): after = an ink-edged cream star with a
  vermilion core about one body wide on 298-299; at 48 px/m it reads without swamping Rivet.
  Doctrine: fire is vermilion and cream, in ink (look-3).
- Tests `test_muzzle_k.gd` 4; planted fault (the off switch ignored) -> exactly the two off tests
  fail (1143/1145); unit 1145/1145 (`run_unit.mjs`), lint 13/13 (943 files).
- Clip `masters .../pistol_muzzle-ab-32-48ppm.mp4` (frames.json row 0; dropped
  `hand_cannon-ab-32ppm.mp4`, covered by `heavy_feel-ab-48ppm.mp4`; still 15 rows).
- Registry rule applied: motion-quality-gating (judge per frame on the live path at 32 and 48;
  the fix sized against what competes in the same frame, the cop's flash, not in isolation);
  realtime-combat-semantics (the shooter's own action must read before its consequence).

### FYI -> n7-melee (23:57): a new feel-layer commit to merge
- `d79c5278` (hit_feel.json `weapons` row `pistol` with the new optional field `muzzle_k`, the
  schema field, `HitFeel.muzzle_k`, `WeaponFxIgnite.muzzle_k`, one line in `WeaponFxArt.muzzle`,
  `test_muzzle_k.gd`). In hit_feel.json the pistol row sorts after mini_nuke, away from your rows
  (chainsaw ... electro_baton). Any melee weapon that draws a muzzle cell can take a `muzzle_k`.
- Your `7ce7b33d` (stun_crowd) closes your REQUEST 4; I build nothing on those views.

### GATE 23:59: both director reels with `--loadout=pistol` on `d79c5278`
- Pit and city block (`--arena=city`): 19/19 chapters each, every one fully down (14x 1/1, 2x 2/2,
  3x 4/4), 0 SCRIPT ERROR (`evidence/ranged/it7-reel-{director,city}-d79c5278.log`; headless,
  run in parallel by `scratch/ranged/reels.sh`, my own PIDs stopped after electro_chain's line).

NEXT (iteration 8):
1. Gates on head with docs committed first and nothing touched during the run:
   `GODOT_BIN=... node tools/evidence/run.mjs --no-bench` (lint, unit, scenarios, parity, selftest).
2. DONE 00:05 (`50c0883b`); left: Gloria in quest 1 Dock 9 at 32 px/m. Was: Gloria's flash: it draws the same `flash_pistol` cell (weapon_art.json gloria muzzle_fx), so it
   is the same 15 px speck, and Gloria is quest 1's sidearm. Film `--weapon=gloria` lone at 32
   (`--reach=6`), then try `muzzle_k` 1.6 (maybe 1.8: the heavier sidearm) with the same A/B; then
   look at quest 1 Dock 9 at 32 px/m (StageGuns uses Gloria's row, so the change reaches quest 1).
3. Machine pistol muzzle (audit row 12): film first; at about 10 rounds a second a bigger cell
   every round may be noise; try 1.2 only if a single round reads as nothing.
4. Gatling spin-up at 48 px/m: judge by eye (measured only so far).
5. City combined clip retake (`--cam=fight`, the whole nuke blast), now with the pistol flash,
   flamer flare and the throw twist.
6. Exe by 08:30: `windows-showcase` preset (decisions.md 2026-11-04 showcase export) ->
   `build/export/windows/RTAI.exe`; REPORT command lines + befores (`--feel=off`,
   `--react-snap=off`, `--end-cue=off`, `--quest-guns=off`, `--silent`, `--shard-pop=12`).
7. Reels: `scratch/ranged/reels.sh <tag>` runs pit + city director reels headless in parallel and
   stops each after electro_chain's line (about 8 min contended).

STOP 00:01 iteration 7 (continuing on NEXT 2 until 00:23). Code commit: `d79c5278` (pistol muzzle_k 1.6, reads at 32 px/m). Gates on
it: unit 1145/1145, lint 13/13, pit + city reels 19/19 fully down. Closed without code: NEXT 1 (the
ray kill is the approved dissolve), REQUEST 4 (melee's `7ce7b33d`). Scenarios/parity not re-run
this iteration (NEXT 1 of it8); the change is view only (WeaponFxArt draw scale, no sim read).

### MILESTONE 00:05: `50c0883b` Gloria's flash reads at 32 px/m (NEXT 2 of it8, done now)
- LOOK (head, `--weapon=gloria`, same args as the pistol, kill tick 303): Gloria draws the pistol's
  `flash_pistol` cell, the same 15 px speck on 298-299, the cop's star (295-296) bigger.
  hit_feel.json gloria `muzzle_k` 1.8 (one notch over the pistol: the heavier sidearm). A/B x3
  crops 296-300: a cream star with a vermilion core about Rivet's torso wide on 298-299; it does
  not cover him. Unit 1145/1145 (the pistol test also asserts gloria > pistol; not separately
  planted: a gloria muzzle_k of 1 fails that assert by construction), lint 13/13 (hook).
- Clip `masters .../gloria_muzzle-ab-32ppm.mp4` (frames.json row 1; dropped `gatling-ab-32ppm.mp4`,
  the Gatling keeps `gatling_spinup-ab-32ppm.mp4`; REPORT row repointed). Not yet seen in quest 1
  (StageGuns arms Gloria's row there, so it applies): it8 films Dock 9 at 32 px/m.
- Not re-run on `50c0883b`: the reels (a data value on a view-only draw scale; `d79c5278`, the
  code, has both reels 19/19). NEXT 1 of it8 runs the full evidence on head.

### GATE 00:14: evidence run on `1eb069c8` (= `50c0883b` code), nothing touched during it
- lint 13/13 (943 files), scenarios 52/52, parity bit-exact over 1200 steps (planted caught at
  629), selftest pass (look goldens 11/11, block 5/5). Unit 1144/1145: the one red is
  `test_hitch_recorder` canary timing (25.143 ms against a 25.0 ms bound, a wall-clock test under
  4-lane contention, not a test of mine); re-run alone (`-gselect=test_hitch_recorder`): 3/3 pass.
  New contention flake for the list. Logs `evidence/ranged/it7-{evidence-1eb069c8,unit-hitch-alone}.log`.
- So every gate is green on head's code; the muzzle change is view only (parity unmoved).

STOP 00:16 iteration 7. Code commits: `d79c5278` (pistol muzzle_k 1.6), `50c0883b` (Gloria 1.8).
NEXT for iteration 8 is the list above (item 2 done except Gloria in quest 1 Dock 9).

## Iteration 8 (BUILD, 00:17-01:17)
Read: JOURNAL NEXT, git log, n7-melee / n7-king / n7-servo journals (melee cherry-picked
`d79c5278` as `648e6523` at 00:00; no new REQUEST to ranged).

### FILM 00:30: Gloria's flash in quest 1 Dock 9 at 32 px/m (it7 NEXT 2, closed)
- `quest1_clip.gd --ppm=32 --cam=fight --ticks=13580-13860` on head (exit 0, 0 SCRIPT ERROR,
  141 frames; scratch `q8/`). Frame 47, same tick and camera as the it5 take: at muzzle_k 1 the
  shot was a speck by Rivet; at 1.8 an ink-edged cream star with a vermilion core about his body
  wide on the aim side, the nail streak behind it. It does not cover Rivet or the ghost tether.
- Clip replaced in place as a 3-panel (evening | table guns muzzle_k 1 | muzzle_k 1.8), frames
  40-56 at 1/8 after the real-time pass: `masters .../quest1_table_gloria-ab-32ppm.mp4`, row
  updated (still 15 rows).
- FRICTION: the fight cam pans every frame, so frame diffs cannot find the shot; a per-frame count
  of vermilion pixels (scratch `findstar.py`) found the spike at 47 in seconds.

## Iteration 9 (BUILD, 00:24-01:24)
Read: JOURNAL NEXT (it7 list; it8 closed Gloria in Dock 9), git log, n7-melee journal to its end
(`f593aac4` hit cues for melee and ghost hits, no REQUEST to ranged), n7-king/servo (none new).

### MILESTONE 00:32: `193bc529` the machine pistol's flicker reads at 32 px/m (it7 NEXT 3)
- FILM first (head, `--weapon=machine_pistol --bot=gunplay --lone --cam=fight --ppm=32 --clean
  --reach=6`, kill tick 306, 0 SCRIPT ERROR; scratch `mp/`). x1.5 crops 296-319: Rivet's flash a
  6-8 px speck at the gun on 302, 306, 310-316. rof 14 Hz = a round every 4 ticks with
  FLASH_TICKS 3: the cell is up 3 ticks of 4, so a burst is a steady flicker.
- hit_feel.json machine_pistol `muzzle_k` 1.3 (under the pistol's 1.6). A/B (same sim, kill 306
  on both), x3 zooms of 302/306/310/312/314: an ink-edged cream star with a vermilion core about
  the gun's size, Rivet clear. 48 px/m `--feel=off` vs on: the same, read to the kill (after the
  kill the two drift apart by the kill stop, so the clip stops there).
- Test: `test_muzzle_k` asserts 1 < k < pistol; planted k = 1.6 -> exactly that test fails (4/5,
  `evidence/ranged/it9-unit-mp-planted.log`); unit 1146/1146 (`it9-unit-mp-muzzle.log`), lint 13/13.
- Clip `masters .../machine_pistol_muzzle-ab-32-48ppm.mp4` (frames.json row 0; dropped and deleted
  `rocket_launcher-ab-32ppm.mp4`, covered by heavy_feel + rocket_blast_sound; REPORT row repointed).
- Seen in passing: the flash sits to the aim side of the drawn barrel (GUN_SIDE_M vs the hold
  pose). Holds are an owner call: not touched.
- Registry rule applied: motion-quality-gating (film before deciding; size against the burst's
  duty cycle, not a single frame); combat-pacing-and-dramatic-arc (a rapid weapon's per-round
  effect stays below a single heavy shot's, so weight follows the hit, not the rate).

### MILESTONE 00:44: `d99106f4` + `ce923514` the Gatling winds up visibly (audit row 3, it7 NEXT 4)
- LOOK first (head, `--weapon=gatling --bot=gunplay --lone --cam=fight --ppm=48 --clean
  --reach=6`, kill tick 333, 0 SCRIPT ERROR; scratch `gat/`): for the ~30 frames of spin-up the
  gun just points; the it2 tremor is a camera move, invisible in any still and nothing on the gun.
- Built WeaponFxSpin (new, 81 lines): three ink-and-cream arcs turning about the barrel tip while
  0 < spin < spin_ticks, longer, bolder and faster with the spin; one turn step per sim tick
  (TURN_MAX 0.8 rad < 60 deg: the three-fold whirl never strobes backwards), frozen under
  hit-stop, no RNG. Gone on the tick the barrels reach speed: the first flash prints on the same
  spot. hit_feel.json gatling `spin_whirl_m` (+ schema, `HitFeel.spin_whirl_m`, 0 under
  --feel=off); hooked in GunFxArt._claw_state beside the charge crackle (one line).
- First take drew it at `fx.muzzle(r, 0.45)`: mid-barrel on the long Gatling, under the gun
  sprite, only slivers showed. Moved onto WeaponFxArt's flash spot pulled back to the tip
  (`WeaponFxSpin.tip`). Width A/B at 32 px/m (same sim): 0 / 0.6 / 0.8 m -> 0.6 faint, 0.8 reads
  as a whirl and stays off Rivet (`ce923514`). 48 px/m: whirr arcs at the tip, then the flash.
- Tests `test_weapon_fx_spin` 4; planted faults (drawn at full speed; the off switch ignored) ->
  exactly their two tests fail (`it9-unit-spin-planted.log`). Unit 1150/1150, lint 13/13.
- Clip `masters .../gatling_whirl-ab-32-48ppm.mp4` (frames.json row 0; dropped and deleted
  `gloria_kick-ab-32ppm.mp4`; REPORT rows repointed). Audit anticipation 1 -> 3.
- FINDING: the muzzle flash (and so the whirl) sits on WeaponFxArt's flash spot, GUN_SIDE_M
  (0.35 m) to the aim side, which matches the one-hand hold; on the heavy two-hand Gatling and the
  machine pistol it prints a claw width beside the drawn barrel. Holds are owner calls tonight, so
  not moved; the robust fix is the muzzle FX reading the drawn barrel tip from RivetHeldView
  (any hold verdict then carries the flash with it). Candidate for a later iteration.
- DECISION (docs/decisions.md): the spin-up reads on the gun, not only the camera; rejected a
  bigger tremor (noise, invisible in a still) and a sim wind-up cue (timing). Alternative = one
  data value (`spin_whirl_m` 0).
- Registry rules applied: realtime-combat-semantics (a wind-up must be legible before the action
  it announces, and hand over to it in place); motion-quality-gating (judged per frame at 32 and
  48, width chosen by a same-sim A/B, the first misplaced take rejected on film).

### FYI -> n7-melee (00:49): three feel-layer commits to merge
- `193bc529` (hit_feel.json machine_pistol `muzzle_k` 1.3 + one test), `d99106f4` (new
  `weapon_fx_spin.gd` + test, `HitFeel.spin_whirl_m`, schema field `spin_whirl_m`, one hook line
  in `gun_fx_art.gd` `_claw_state`, gatling row field), `ce923514` (gatling `spin_whirl_m` 0.8).
  All rows I touch sort away from yours (gatling, machine_pistol). Any spun weapon (spin_s on its
  weapons.json row) can take a `spin_whirl_m`: nothing of yours spins today.

### GATE 00:55: evidence run on `42f74955` (= `ce923514` code), nothing tracked touched during it
- lint 13/13 (945 files), unit 1150/1150, scenarios 52/52, parity bit-exact over 1200 steps
  (planted caught at 629), selftest pass (look goldens 11/11, block 5/5)
  (`evidence/ranged/it9-evidence-42f74955.log`). The whirl and the muzzle scale are view only:
  parity unmoved.
- Reels on `ce923514` (00:47): pit and city director reels with `--loadout=pistol` 19/19 chapters
  each, every one fully down, 0 SCRIPT ERROR (`evidence/ranged/it9-reel-{director,city}-ce923514.log`).
- REPORT: Calls for the owner 2 (muzzle sizes) and 3 (the Gatling whirl, and the flash spot beside
  the heavy holds' drawn barrel) added with their clips and exe lines.

### MILESTONE 01:02: city-block combined clip retaken on `42f74955` (it7 NEXT 5)
- `res://dev/arena/arena.tscn -- --arena=city --bot=reel --reel=director --loadout=pistol --ppm=32
  --cam=fight --clean`, Movie Maker 60 fps, `--quit-after 6150`: 16 chapters down (to the nuke),
  0 SCRIPT ERROR (`evidence/ranged/it9-city-movie-42f74955.log`); recorded in about 4 min.
- Cut frames 360-2700 (pistol, machine pistol, rocket, flamer, electro, molotov), 3810-5100 (hand
  cannon, plasma rifle, ray gun, homing shard, riot cop), 5460-6150 (the nuke), crop 960x560 (the
  ghost HUD panel out; the nuke segment's crop shifted 120 px right so the whole ring shows),
  game audio (mean -23.6 dB, peak -1.1 dB): `masters .../city_block_polished_set-32ppm.mp4`, 72 s,
  replaced in place; frames.json row 1. LOOK: sheet every 300 frames + 4 nuke frames: each gun,
  red blood, ink scorch, the blue-lit car, the nuke's ring of vermilion-and-cream bursts with the
  vaporised shadows inside. No Gatling chapter exists in the director reel.
- FRICTION: `bc` is not in this Git Bash; use awk for the frame-to-seconds maths.
- Scratch cleaned: the it9 AVIs, hc-*.avi, spin/, molo/, q8/ renders deleted (5.0 -> 3.4 GB; the
  audit/ befores of main kept for later A/Bs).

NEXT (iteration 10):
1. The muzzle FX print on the drawn barrel, whatever the hold: RivetHeldView already finds the
   drawn muzzle (`_sprite.to_global(art.muzzle_px(id) + _sprite.offset)`, used by `_light_rag`).
   Publish it per frame in a tiny static holder (e.g. `HeldMuzzle.at_m` + the frame number;
   rivet_held_view.gd is 286 lines, so one line there), and let `WeaponFxArt.muzzle` and
   `WeaponFxSpin.tip` use it when fresh (same process frame), GUN_SIDE_M as the fallback (quest 1
   cast rig, no held view). Both draws are in FxView's draw pass, after `_process`, so it is
   fresh. Flag for the before (`--flash-at=side`). Film every hold class at 32 and 48 px/m: pistol
   (one hand), machine pistol, Gloria, plasma rifle (two-hand long), rocket (shoulder), Gatling and
   flamer (hip); quest 1 Dock 9 for Gloria. Holds stay the owner's; this only makes the flash
   follow whatever hold he picks. melee does not touch rivet_held_view.gd (checked 00:52).
2. Exe by 08:30: `windows-showcase` preset (decisions.md 2026-11-04 showcase export) ->
   `build/export/windows/RTAI.exe`; REPORT command lines for calls 1-3 (+ `--feel=off`,
   `--react-snap=off`, `--end-cue=off`, `--quest-guns=off`, `--shard-pop=12`). Check the exe
   accepts `--weapon=` as the REPORT says (boot it once and look).
3. Molotov anticipation (audit row 10, still 1): a view-only cock-back cannot lead a release the
   sim fires at once; look at whether the bot's held-trigger moment gives a tick to read (the
   draw), else record it as a sim-timing call for the owner.
4. Homing shard pop call stays open (REPORT call 1).
5. Reels: `scratch/ranged/reels9.sh <tag>` (pit + city in parallel, about 2 min tonight).

STOP 01:04 iteration 9. Code commits: `193bc529` (machine pistol muzzle_k 1.3), `d99106f4` +
`ce923514` (the Gatling's spin-up whirl, 0.8 m). Gates: evidence on `42f74955` all green (lint,
unit 1150/1150, scenarios 52/52, parity bit-exact, selftest), reels 19/19 + 19/19 fully down on
`ce923514`. City combined clip retaken. Calls 2-3 added to REPORT.

### MILESTONE 01:06: trial exe of the branch (de-risks NEXT 2; re-export at the freeze)
- `bake_city.gd` (256 chunks, 4 s; git-ignored), then `"$G" --headless --path project
  --export-release windows-showcase ../build/export/windows/RTAI.exe` on `074db37d`: exit 0, 20 s,
  245 MB (+ the release sim DLL beside it; `evidence/ranged/it9-export.log`).
- Booted: `build/export/windows/RTAI.exe --screen 0 --rendering-driver d3d12 --write-movie <abs>
  --fixed-fps 60 --quit-after 345 -- --weapon=gatling --bot=gunplay --lone --cam=fight --ppm=32
  --clean --reach=6`: exit 0, no unknown-flag line, 0 SCRIPT ERROR, lone kill at tick 333 (the
  editor's tick), and the whirl shows at the barrel tip on frames 300-325 (sheet looked at). So the
  arena args after `--` work in the shipped build, Movie Maker included; REPORT exe lines hold.
  The only stderr line is the usual "105 resources still in use at exit".
- NEXT 2 shrinks to: re-bake + re-export on the final head at the freeze, name it in REPORT.

### AUDIT 01:08: the audit table's Sound and Impact columns brought up to date
- Sound still showed iteration 1's zeros (the arena had no audio on main). Re-scored from the
  weapons.json cue table + StageAudio (read, not listened: no audio device here): 3 for an own-family
  shot cue + the impact on the frame (pistol, machine pistol, Gloria, flamer, electro, rocket and
  nuke with `blast`), 2 for a shared cue (plasma rifle / ray gun share electro's tazer zap, hand
  cannon shares Gloria's shot, the Gatling the machine pistol's, the molotov's throw is `servo`),
  1 for the generic `shot` (homing shard). Own sounds per gun are a new-asset job (noted in the doc).
- Impact 2 -> 3 for hand cannon, rocket and nuke (the camera answer scaled to the weapon, evidenced
  by `heavy_feel-ab-48ppm.mp4` and `mini_nuke-ab-32ppm.mp4`). The header now says `a -> b` = after.
- NEXT 1 addendum (read 01:09): RivetHeldView sits on the RIGS' CanvasLayer (`arena_rigs.gd`
  `_add_hand_views`, z = rigs + 60) while FxView sits on the print stage's actor layer
  (`collect_call_view.gd:96`), so `to_global` coordinates are NOT shared between them. Publish the
  muzzle in canvas (screen) space (`_sprite.get_global_transform_with_canvas() * local`) and convert
  it in FxView with `get_global_transform_with_canvas().affine_inverse()`, then / Ink.PX_PER_M.
  Also: FX draw UNDER the held weapon sprite (the first whirl take hid under the barrel), so the
  flash must sit past the tip by about half its cell, tuned on film.

STOP 01:10 iteration 9 (final). Commits after the 01:04 stop: `db355669` (trial exe journal),
`d98750ba` (audit columns). Tree clean. NEXT for iteration 10 is the list above (1 with this
addendum; 2 is now only the re-export at the freeze).

## Iteration 11 (BUILD, 01:10-02:10)
Read: JOURNAL NEXT (it9 list; no it10 entries), git log, n7-melee / n7-king / n7-servo journals (no new REQUEST for ranged).
Working NEXT 1: the muzzle FX prints on the drawn barrel whatever the hold.

### MILESTONE 01:30: `9054e346` the muzzle FX print on the drawn barrel tip (it9 NEXT 1)
- HeldMuzzle (new, 42 lines, `features/combat/weapons/art/`): RivetHeldView publishes
  `_sprite.get_global_transform_with_canvas() * (muzzle_px + offset)` once per process frame
  (one line in rivet_held_view.gd, now 287); `HeldMuzzle.at_m(ci, fallback)` returns it in the
  drawing item's metres (`ci.get_global_transform_with_canvas().affine_inverse()`, / Ink.PX_PER_M)
  if fresh, else the GUN_SIDE_M spot. Used by WeaponFxArt.muzzle (every flash, the flamer's lick)
  and WeaponFxSpin.tip (the whirl). `--flash-at=side` = the before (in LaunchArgs.KNOWN_FLAGS).
- Tests `test_held_muzzle` 5/5; planted fault (fresh() ignoring the frame and the flag) -> 2 fail.
- FILM (`scratch/ranged/hm/`, `--bot=gunplay --lone --cam=fight --clean --reach=6`, same build
  with and without `--flash-at=side`, 0 SCRIPT ERROR in all 16 takes): diff frames find the FX
  (first round at frame 298). LOOK at 48 px/m (2x crops): pistol flash now touches the barrel tip;
  plasma rifle a few px nearer the tip; rocket flash moves from beside and below the tube onto its
  line (a ~0.3 m gap to the mouth remains: the flash_tube star's own back edge, art); flamer lick
  leaves the nozzle (before: beside it); Gatling whirl rings the barrel's end (before: arcs beside
  its middle), at 32 px/m too; Gatling flash frames 330-335 at 32 px/m sit on the barrel end.
- FRICTION: the weapon ids are `rocket_launcher` and `flamethrower` (`--weapon=rocket` boots with
  422 SCRIPT ERRORs from a null spec in arena_game.gd:122, a dev flag with no guard; not fixed).
- Clip `masters .../muzzle_on_drawn_tip-ab-48-32ppm.mp4` (18 s, frames.json row 0; dropped and
  deleted `quest1_table_gloria-ab-32ppm.mp4`, the Dock 9 48 px/m pair stays). REPORT row + call 4.
- DECISION (docs/decisions.md): the flash follows the drawn tip; rejected per-hold offsets in data.

### GATES 01:24: evidence on `2cb85d5b` all green
- lint 13/13, unit 1155/1155, scenarios 52/52, parity bit-exact (planted mutation caught at 629),
  selftest pass (`evidence/ranged/it11-evidence-2cb85d5b.log`, git-ignored copy). Pit + city
  director reels on `9054e346` 19/19 + 19/19 fully down, 0 SCRIPT ERROR.
- FRICTION: the first unit run had no GODOT_BIN in the subshell (every step exit -1; the 1150 count
  was the stale junit); and evidence/run.mjs refuses an untracked file in the tree: commit the gate
  summaries before it.

### MILESTONE 01:38: `8766508f` the molotov is held cocked and the throw whips out (it9 NEXT 3)
- Numbers first: rof 1.2 Hz = interval 50 ticks, reload 0.7 s = 42 ticks (out 0.3 / in 0.45 /
  cock 0.25 = about 10 ticks), magazine 1, semi (fires on the press edge). So the release never
  falls on the reload's end, and the lone film (and each reel chapter) sees one throw with no reload
  before it: a wind-up in the reload's cock phase alone would never show before a release.
- Built RigThrow (new, 52 lines): a ready, aimed molotov is held cocked (claw at gun shoulder x -
  windup_px, y x OUT_K, z +40); `release(rig)` = clamp(-c_recoil, 0, 1) swings it out to the arm's
  aimed target on the throw (rig_kick -1.6: out for 0.1 s, back over the next 0.17 s); in the
  reload it holds the chest and the cock phase lerps back. Hooks: 2 lines in RigGrip.target, one in
  RigGrip._reload (now takes the aimed target). held_classes.json thrown `windup_px` 110 (+ schema,
  optional; HeldTable.windup_px). `--throw-windup=off` in KNOWN_FLAGS.
- FRICTION: `static func reload` / `ready` on a class collide with GDScript's Script.reload()
  ("Expected 1 argument"): renamed in_reload / held_ready. `float(row.get(...))` is a
  Variant-to-float warning-as-error: used `t.num` behind `row.has`.
- Tests `test_rig_throw` 4/4 (cocked -110 px behind the shoulder, thrown +275 px: a 385 px swing;
  the planted fault is the off switch, out at the aim).
- FILM lone cop, `--cam=fight`, same build +/- `--throw-windup=off`, 0 SCRIPT ERROR, lone kill at
  tick 465 in all takes (the sim is unchanged). LOOK 48 px/m frames 300-315: before, the bottle hangs
  ahead and vanishes; after, it rides up behind the head and the claw swings out on the release.
  OUT_K 1.15 laid the bottle and its lit rag over the helmet and collar; 1.5 clears them (A/B
  `scratch/ranged/hm/mtk.png`). 32 px/m: the raised bottle by the helmet reads clearly; the
  release shows as an open claw up and back, then forward (2 frames).
- Clip `masters .../molotov_windup-ab-32-48ppm.mp4` (6.4 s; frames.json row 0; the it6 twist clip
  dropped and deleted, the twist plays in its after). Audit row 10 anticipation 1 -> 3. REPORT
  row, call 5, the "not done" note rewritten. DECISION in docs/decisions.md.
- GATES 01:41 on `8766508f`: pit + city director reels 19/19 + 19/19 fully down, 0 SCRIPT ERROR
  (`evidence/ranged/it11-reel-{director,city}-8766508f.log`), unit 1159/1159.

### FIX 01:50: `63d2a29e` a mistyped `--weapon=` boots with Gloria and one warning
- `--weapon=rocket` gave 422 SCRIPT ERRORs (the gunplay bot read the null spec); GunplayHook
  already warns and keeps Gloria, so the bot takes Gloria's reach too. Checked headless: bad id
  0 SCRIPT ERROR + the warning; `--weapon=pistol` still "Rivet holds the table pistol".

### FIX 01:51: `cb98ccd4` the molotov leaves the claw on its forward swing
- FOUND in the city director reel (molotov chapter, tick 2250; `--arena=city --loadout=pistol
  --ppm=32 --cam=fight`, +/- `--throw-windup=off`, 0 SCRIPT ERROR): the wind-up reads in the live
  path (three throws, the bottle cocked back behind the shoulder away from the cop between them),
  but on frame 2364 the claw was still cocked with the bottle already hidden: the rig poses before
  RivetHeldView reads the new reload. `RigThrow.lag_frame` keeps the bottle drawn that frame
  (reload_k < 0.2 and no release posed yet); the next frame shows the empty claw out at the aim.
  Re-filmed: city frame 2364 holds the cocked bottle, 2365 the claw forward; lone 48 px/m the
  same at 310/311. Test 5/5 (+ the lag case and its off switch). Masters clip re-cut on it.

NEXT (iteration 12):
1. Retake the city-block combined clip on the final head (it now carries the muzzle on the drawn
   tip and the molotov wind-up): same recipe as it9 (JOURNAL 01:02, frames 360-2700, 3810-5100,
   5460-6150, crop 960x560), replace in place, LOOK at the molotov and rocket segments.
2. (Measured 01:58, closed without code for the rocket and plasma rifle: on `cb98ccd4` at 48 px/m,
   lone, frames 298-309, the rocket's first drawn frame (301) and the plasma bolt's sit within a
   few px of the drawn barrel's line; the GUN_SIDE_M convergence matches those holds.) Still to
   look at: the Gatling's rounds and the casings (WeaponCasings.track, the GUN_SIDE_M spot) at
   48 px/m. Seen in passing: after the rocket fires its tube flips to point back over Rivet's head
   for the reload (frames 301-309); existing reload pose, not tonight's change, not a hold call of
   mine; mention to the owner only if it reads wrong at 32 px/m.
3. Rocket flash: a ~0.3 m gap between the tube's mouth and the flash_tube star (the cell's own back
   edge). Only if it reads on film at 32 px/m: a per-weapon `muzzle_back_m` in hit_feel.json.
4. Molotov: the first draw snaps from the hanging claw to cocked when aiming starts; lerp it over
   WeaponHold DRAWING progress (RigThrow, view only). Look at the arena molotov reel chapter.
5. Exe at the freeze: re-bake + re-export `windows-showcase` -> `build/export/windows/RTAI.exe` on
   the final head; REPORT exe lines for calls 4 (`--flash-at=side`) and 5 (`--throw-windup=off`).
6. Calls 1-5 stay open in REPORT.
- GATES 01:55 on `cb98ccd4`: pit + city director reels 19/19 + 19/19 fully down, 0 SCRIPT ERROR;
  unit 1159/1160, the one red `test_noir_shadows` (the known flake, under the two reels' load):
  alone 2/2 green (`evidence/ranged/it11c-noir-shadows-alone-cb98ccd4.log`). Lint 13/13.

STOP 01:56 iteration 11. Code commits: `9054e346` (muzzle FX on the drawn barrel tip, HeldMuzzle),
`8766508f` + `cb98ccd4` (the molotov held cocked, the throw whips out; RigThrow), `63d2a29e`
(a mistyped --weapon boots with Gloria). Evidence on `2cb85d5b` all green; reels 19/19 on every
code commit. Clips: `muzzle_on_drawn_tip-ab-48-32ppm.mp4`, `molotov_windup-ab-32-48ppm.mp4`
(frames.json rows 0-1). REPORT rows + calls 4-5. NEXT for iteration 12 is the list above.
