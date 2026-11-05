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
