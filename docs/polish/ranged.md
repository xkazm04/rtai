# Polish audit: Rivet's ranged attacks (lane n7-ranged, night 2026-11-05/06)

Branch `n7-ranged` cut from main `763f8fba`. Films: `C:\Users\kazda\kiro\gtai-n7p\scratch\ranged\audit\`
(scratch; the kept before/after pairs move to `C:\Users\kazda\kiro\gtai-masters\n7\ranged\`).
Capture: `res://dev/arena/arena.tscn -- --weapon=<id> --bot=gunplay --lone --cam=fight --ppm=32
--clean --feel=off` (the pit, one cop a wave, main's camera feel), `--write-movie`, `--fixed-fps 60`.

## The rubric (scores 0-3, absolute, defined by what is visible)

Per `motion-quality-gating`: the dimensions do not average, each is scored on what a viewer can
point at in the frames, correctness is the floor (a hit that plays and communicates nothing is a 1,
not a 2), and an unfilmed cell is `?`, never a number.

| Dim | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **Anticipation** (trigger to round) | nothing precedes the round | a muzzle flash only | flash + the gun arm / body kicks | flash, kick and a readable wind-up or spin-up where the weapon has one |
| **Impact** (the hit frame) | the round vanishes into the body | a flash or a spark on the body | spark/blood + the camera or the frame answers (kick, stop) | spark/blood, camera answer scaled to the weapon, debris or a mark left |
| **Read at 32 px/m** | cannot tell what fired or what was hit | can tell a hit happened | can tell the weapon class and the hit | can tell the weapon, the hit and the kill apart at a glance |
| **Victim sync** | the reaction starts later than ~6 ticks after the hit, or not at all | starts within 6 ticks but does not follow the hit direction | on the hit frame (0-2 ticks), along the hit | on the hit frame, along the hit, scaled to the weapon (flinch / stagger / down) |
| **Sound** | silent | a generic shot | the weapon's own shot | the weapon's shot and its impact on the frame |

## Ranked (weakest first)

Iteration 1 scores: arena pit, lone cop, 32 px/m, `--feel=off` (main's feel); `a -> b` = the score
after tonight's change (each evidenced below or in REPORT). Columns:
Anticipation / Impact / Read 32 / Victim sync / Sound (arena). `?` = not looked at yet.

| # | Weapon | A | I | R | V | S | Why it ranks here |
|---|---|---|---|---|---|---|---|
| 1 | mini_nuke | 1 -> 2 | 2 -> 3 | 2 -> 3 | 3 | 0 -> 3 | it15 `d4559823`: the launch plays `shot_tube` at -5 dBFS (it played Rivet's joint whine at -19 dBFS: the launch was nearly silent under the bed; in the lone film its first onset rose from -11 to -4 dB peak). it14 `8efe76ca` + `a63bd8e0`: the camera follows the shell and holds on the ring (the whole ring at 32 px/m, was its top arc; `nuke_blast_lead-ab-32-48ppm.mp4`). it13 `5c171ed8`: the launch kicks the camera 4 px against the aim (it had none; `mini_nuke_launch-ab-32-48ppm.mp4`); a harder rig kick did not read at 32 px/m and was dropped. the biggest hit in the game and the frame does not move: a huge ink burst, no stop, kick or shake; half off frame |
| 2 | rocket_launcher | 2 | 2 -> 3 | 3 | 3 | 0 -> 3 | it15 `d4559823`: the launch is a thump of its own, `shot_tube` (the rifle shot an octave down, 1.2 kHz; it played the pistol shot, so the it9 3 was generous). it14 `5586a80e`: the tube no longer pops to Rivet's off shoulder on the launch (`tube_side-ab-32-48ppm.mp4`; the nuke had the same, plus a held swap mid-reload). strong ink blast, debris, smoke, crater; the camera ignores it (no weight) |
| 3 | gatling | 1 -> 3 | 2 | 2 | 2 | 0 -> 2 -> 3 | it16 `6e50068c`: its own shot, `shot_gatling` (the rifle shot at 0.82: onset 1.95 kHz, 1.0 s tail; it shared the contractors' rifle shot with the machine pistol; measured, not listened to: call 7). it14 (lone, `--reach=5`): a cop dies to 2 rounds (damage 50): the wound, then the kill 4 frames later (frames 358-364), so a body pinned under sustained fire exists only on crowds and robots; the stars on the cop before 358 are his own muzzle flashes. casing/spark spray and blood read; sustained fire has no weight at all; the 0.5 s spin-up shows nothing (no barrel turn, no cue) |
| 4 | plasma_rifle | 2 | 2 -> 3 | 2 | 3 | 0 -> 2 -> 3 | it16 `4e8860c3`: its own shot, `shot_plasma` (the crackle at 0.72); it played `player_hit_robo_tazer`, Rivet's hurt cue (measured, not listened to: call 7). it14 re-scored on `994f8feb` (lone, `--reach=5`, 32 px/m, feel on vs off, scratch `pl/p1.png`): on the hit frame an ink star over the cream glow, about 6 frames of stop and a camera kick, then the hole and the scorch (`--feel=off`: the glow only) = 3. impact star and a cream glow at the cop; it3 at 48 px/m: a 3-frame burst, the hole, the body thrown about 1.7 m along the bolt on the hit frame (the it1 "barely answers" was a misread at the frame edge) |
| 5 | electro_gun | 2 | 2 -> 3 | 2 | 3 | 0 -> 3 | it14 re-scored on `994f8feb` (lone, `--reach=5`, 32 px/m, feel on vs off, scratch `el/x.png`): the kill's ink burst holds about 9 frames with a camera shift, then the yellow skeleton (off: the burst for 1 frame) = 3. zigzag bolt, star, skeleton flicker, yellow burst; the kill reads; it3 `9c140ffb`: the struck (stunned) body is thrown 0.3 m along the bolt on the hit frame, then convulses |
| 6 | homing_shard | 2 | 2 | 2 | 2 | 0 -> 1 -> 2 | it15 `d4559823`: its own shot, `shot_shard` (the nail-gun pop at 1.7, quieter: a short high flick, 10.2 kHz centroid, 0.32 s; was the pistol shot at 3.1 kHz); 2 until it is listened to. the lozenge shards read in flight, a star on the hit frame and a small jolt/turn; the pop and the blood come at about T+40 (owner item 4: 3 + 36 grind ticks, JOURNAL) |
| 7 | hand_cannon | 2 | 2 -> 3 | 3 | 3 | 0 -> 2 -> 3 | it15 `d4559823`: its own heavy crack, `shot_hand_cannon` (the rifle shot at 0.72: 1.7 kHz centroid, 1.1 s; it shared Gloria's 6.0 kHz, 0.5 s nail-gun pop). ring at the muzzle, ink star + blood on the hit frame, body thrown; no camera answer for the heaviest single shot |
| 8 | ray_gun | 2 | 3 | 2 | 3 | 0 -> 2 -> 3 | it16 `4e8860c3`: its own shot, `shot_ray` (the crackle at 1.35, cooldown 3: the hurt cue it played had a 10-tick cooldown that voiced every other round; measured, not listened to: call 7). ink bolt and star on the hit frame, a pale ring at the body; it7 at 48 px/m: the kill is the approved brutality `ray_gun_dissolve` (star + stop, glow, the body locks and falls stiff, gold rings eat it from tick +40 to a dust heap); every beat reads at 48, the star, disc and gold ring at 32 |
| 9 | flamethrower | 2 | 3 | 3 | 3 | 0 -> 3 | it16 `e63c186e`: its jet plays its own roar, `shot_flame` (the wreck-bed crackle at 0.9, 6 dB over the bed it borrowed: measured -28.4 -> -23.4 dB rms on the range, continuous; not listened to: call 7). it3 48 px/m: the vermilion/cream tongues grow from the nozzle over about 12 frames and light the cop on contact, patches stay; the ignition had no beat -> `e32720c4` a 3 px kick on the first puff |
| 10 | molotov | 1 -> 3 | 3 | 3 | 3 | 0 -> 2 -> 3 | it18 `3243a483`: the release is drawn on the sim's tick (the claw whip trailed the bottle by 2 frames in the arsenal path: the bottle vanished from behind the helmet, `molotov_release_sync-ab-32-48ppm.mp4`). it16 `b66880c1`: the fire burst lands with an ignition whoomp, `bottle_burst` (the landing played only the generic concrete tick; measured on film -34 -> -22 dB rms at the landing, not listened to: call 7). it13 `9df494f6`: the first aim lifts the bottle to cocked over 0.22 s, not in one frame (`molotov_draw_rise-ab-32-48ppm.mp4`). it11 `8766508f`: a ready bottle is held cocked behind the gun shoulder by the helmet, the release whips the claw out (`molotov_windup-ab-32-48ppm.mp4`). it5 at 48 px/m, `--reach=7`: no wind-up on Rivet (the only cue is the next lit bottle in his claw); the bottle flies as a thin dark stick with a vermilion wick, readable at 48 px/m, thin at 32; the burst (ink, cream and vermilion star) and the burning cop read at a glance |
| 11 | pistol | 1 -> 2 | 2 | 2 | 3 | 0 -> 3 | Rivet's round is a 1-2 frame streak (the muzzle hardly reads at 32 px/m); blood spurt on T+1, the fall reads; it7 `d79c5278` muzzle_k 1.6: his flash now reads before the cop's |
| 12 | machine_pistol | 1 -> 2 | 2 | 2 | 3 | 0 -> 3 | it16 `51cb1194`: its own shot, `shot_smg` (the rifle shot at 1.25: it played the contractors' rifle, so it sounded like the enemy; S was 3 for having a gun shot at all, it is now its own; measured, not listened to: call 7). each round sprays sparks and the body bleeds on the hit frames; the burst reads, Rivet's muzzle hardly did; it9 `193bc529` muzzle_k 1.3: the burst flickers as a cream star at the gun |
| 13 | gloria | 1 -> 2 | 2 | 3 | 3 | 0 -> 3 | it14 re-scored on `994f8feb` (lone, 32 px/m, frames 262-271, scratch `glo/t.png`): the 1.8x flash star (it7) on the shot frame and the gun arm swinging out the next frame (rig_kick 0.8) plus the 1.5 px camera kick: flash + kick = 2; a sidearm has no wind-up. it3 (sheet `sheets/gloria-off-k2.png`, kill 2 at tick 562): a long dashed vermilion/ink tracer from the claw reads at a glance; blood on T+1, the body folds along the shot by T+12; no muzzle or kick of its own beyond the tracer; the victim at the frame edge (capture framing) |
| - | assault-rifle | 0 -> 2 | 2 | 1 -> 3 | 3 | 2 | it20 scored from the hit ticks: a headless struck probe (scratch, the scripted pad) logs 10 rifle hits in Dock 9, every one a one-hit kill (14355, 14381 x2, 14407, 14434, 14438, 14463, 14466, 14477, 14497); `quest1_clip.gd --ppm=32 --cam=fight --ticks=14400-14444` (0 SCRIPT ERROR), crops at 14407 and 14438 (`evidence/ranged/it20-quest1-rifle-kills-32ppm.png`): the tracer runs from the claw to the contractor, he stands on the drawn frame of the hit and is down on the next one (within 2 ticks), falling along the shot; blood sprays along the shot by +4 ticks and the pool stays. V = 3 (on the frame, along, a down: the rifle has no struck-not-killed case in the quest). I = 2: blood and a mark; the camera answer is the light class's 1 px kick by code, not measured on film. it18 (corrected): `quest1_clip.gd --ppm=24 --cam=fight --ticks=14364-14460` frames all of Dock 9 (49 frames, 0 SCRIPT ERROR); the blood bloom on ticks 14390-14394 grows on the heap of bodies already down while the tracer flies on past it, not on a live contractor, so I and V stay `?` (a first read scored it 3: withdrawn). it16 `01a482d1`: the rounds draw with the art stand-in (machine_pistol's flash_smg on the claw tip, muzzle_k 1.3, and its cream-and-ink tracer), view only; filmed in Dock 9 at 32 and 48 px/m (`quest1_rifle_flash-ab-32ppm.mp4`, before `--weapon-fx=shapes`): each round of the 4-round bursts shows a star and a tracer you can follow (before: hair-thin dashes, no flash). it15 filmed in quest 1 (the only place Rivet holds it: picked up from a downed contractor in Dock 9, ticks 14363-14721 of the scripted run; `quest1_clip.gd --ppm=32 --cam=fight --ticks=14340-14740`, 0 SCRIPT ERROR; still `evidence/ranged/it15-quest1-rifle-32ppm-2x.png`): Rivet's rounds are thin dark dashes beside him, with no muzzle flash and no rifle drawn in the claw; at 32 px/m you can tell he fires (the HUD ammo counts down) but not with what. It fires with `arena.gun` null (StageGuns.sync), and quest 1's FxView draws Rivet's flash and table tracers only while `arena.gun` is set (fx_view.gd:47-80), so no flash is drawn (JOURNAL 04:13). Impact and victim not judged (the hits land off the crops). Sound: `shot_assault_rifle`, shared with the contractors. Not a weapons.json row (`--weapon` cannot arm it) |

Sound re-scored (it9, read from weapons.json cues + StageAudio, not listened to; no audio device
here): the arena had no audio at all on main (the 0s); since `0f8e4f5f` every round plays its row's
`shot_cue` on the frame it appears and `hit_flesh`/`projectile_end` on the frame it ends (+ the
`blast` end_cue for rocket and nuke, `da508e6b`). 3 = a cue of its own family + the impact; 2 = a
shared cue (plasma rifle, ray gun and electro share the tazer zap; the Gatling the machine pistol's; the molotov's throw plays `servo`); 1 = the generic `shot`
(homing shard). A per-weapon sound pass is a new-asset job, not tonight's polish.
it15 `d4559823`: without a new asset, three cue rows re-pitch existing samples so the heavy guns
and the shard stop borrowing a light gun's shot (`shot_tube` rocket + nuke, `shot_hand_cannon`,
`shot_shard`). Measured on the samples as played (centroid of the first 150 ms of the source, peak
after gain_db): pistol `shot` 3.1 kHz -6 dBFS, `servo` 9.5 kHz -19 dBFS, Gloria 6.0 kHz -4 dBFS ->
tube 1.2 kHz -5 dBFS (1.6 s tail), hand cannon 1.7 kHz -4 dBFS (1.1 s), shard 10.2 kHz -8 dBFS
(0.32 s). In the lone films (32 px/m, Rivet's first shot at 4.94 s, the bed and the cop's own
shots in the mix) the first onset's centroid moved 3.7 -> 2.4 kHz (hand cannon), 2.6 -> 2.0 kHz
and -11 -> -4 dB peak (nuke), 2.6 -> 2.4 kHz (rocket, masked by the bed), 2.6 -> 5.1 kHz (shard).
Still not listened to (no audio device here): call 7.

Films and 3x3 timing sheets (frames T-3, T, +1, +2, +4, +7, +12, +20, +40 around a kill) in the
scratch audit folder: `<w>-off.avi`, `sheets/<w>-off-k2.png`.

## Cross-cutting findings on main `763f8fba`

- **Camera: 0 on every weapon.** No landed round shook, kicked or stopped the camera in the pit,
  the city block or quest 1 (the arena fed a detached rig; decisions.md 2026-11-05 n7-ranged).
  Fixed by the feel layer `779cdd3d` (FeelCam); every "after" is measured on it.
- **Sound: 0 in the arena** (movie audio -91 dB, digital silence: `ArenaGame` attached no audio).
  Fixed `0f8e4f5f` (StageAudio, as quest 1: -26 dB mean on the hand cannon run). Quest 1 had
  sound; sync unmeasured. The stage bed masks per-frame peaks (about -10 dBFS floor): a sync
  measure needs the bed off or a cue log (iteration 2).
- **Framing (capture, not game):** `--cam=fight` at 32 px/m leaves the rocket and nuke blasts half
  off the right edge on the pit's second wave; the ghost HUD panel shows despite `--clean`.
  it14: for the nuke it is the game's framing too, not only the capture: its ring is 12 m in radius
  (384 px at 32 px/m) on an 800 px tall screen, so the whole ring shows only if the blast lands within
  about 0.5 m of the screen centre vertically, whatever camera follows Rivet.

## Per weapon (before -> after)

### hand_cannon (feel layer)
- Before: no stop, no kick (`hand_cannon-off.avi`).
- After `779cdd3d`: the kill holds 6 frames (movie frames 561-567 repeat tick 557, frame log
  `hand_cannon-on.frames.json`), the ink star stays up through the stop, the camera kicks 7.5 px
  along the shot (5 x kill 1.5) and eases back over 10 ticks. Sheet `sheets/hc-ab-k2.png`.
  Not yet looked at at 48 px/m; not yet a kept clip.

### gatling (feel layer)
- Before: the spin-up is invisible (anticipation 1: the muzzle only); sustained fire 0.27 px rms
  jitter (no weight).
- After `016966b2` + `b2af1801`/`eb1d4f1c`: a spin-up tremor growing with the barrels (0.3 -> 2-3
  px/frame at 64 px/m, ~10/15 Hz), then a 1.8 px recoil kick per round (0.48 px rms, max 1.59).
  Measured, not yet judged by eye in motion. Clips `gatling-ab-32ppm.mp4`,
  `gatling_spinup-ab-32ppm.mp4`.
- it9 LOOK at 48 px/m (head, lone, `--reach=6`, kill 333): for the ~30 frames of spin-up the gun
  just points; the tremor is a camera move, nothing on the gun says "winding up". `d99106f4` +
  `ce923514` WeaponFxSpin: three ink-and-cream arcs turn about the barrel tip while
  0 < spin < spin_ticks (longer, bolder, faster with the spin; one turn step per sim tick, under
  60 deg so it never strobes backwards; frozen under hit-stop), gone on the tick the barrels reach
  speed, where the first flash prints on the same spot (frame ~330). hit_feel.json gatling
  `spin_whirl_m` 0.8 (0.6 read faint at 32 px/m). Verdict: the wind-up READS at 32 and 48 px/m
  (anticipation 3: a readable spin-up). Limit: the whirl and the flash sit on WeaponFxArt's flash
  spot, a claw width beside the drawn barrel of the heavy two-hand hold (GUN_SIDE_M); the hold is
  an owner call, so not moved. Clip `gatling_whirl-ab-32-48ppm.mp4`.

### electro_gun struck (owner item 1, `9c140ffb`)
- Before: the stun (`human_reactions.json` stun, 1.2 s, travel 0.08 m) jolts in place
  (`ShockJolt`); nothing goes along the bolt on the hit frame (victim sync 2).
- After: `snap_m` 0.3 on the stun row: the body (and the head, half as far) is thrown along the
  bolt in 2 ticks and eased back by 0.3 s; the convulsion carries on. `--react-snap=off` = before.
- Where a stun shows: pit humans have 1 hp, so a charged bolt kills (electro_shock signature);
  the director's `electro_chain` chapter (taps into a group, `--loadout=pistol`) gives 7 stuns,
  0 deaths, 4/4 down on both builds. Film diff: frames 61-77 differ (the snap), nothing else moves.
- Clip `electro_snap-ab-48ppm.mp4`. The chain-arc art covers the victim on the first 3-4 hit
  frames, so the throw reads mostly as it eases back.

### plasma_rifle killed (owner item 1): no change
- 48 px/m director chapter `plasma_rifle`: burst on the hit frame (held 3 frames), the hole, the
  body launched about 1.7 m (from where the gun drops to where the body lies), smoke. It reads.
- Tried `plasma_hole.launch_mps` 1.4-2.2 -> 2.2-2.8: only about +0.2 m at rest (10 px at 48
  px/m), and the gib flight is hashed sim state (GibSim). Reverted: not worth a sim change.

### rocket_launcher and mini_nuke: sound on the blast frame (`da508e6b`)
- Before: a round ending played `projectile_end` (a concrete click, -9 dB) or `hit_flesh`; the two
  biggest hits in the arsenal had no sound of their own (sound column 0 -> the arena's generic).
- After: `end_cue` (optional) on weapons rows; rocket and nuke -> cue `blast` (the existing
  `car_wreck` explosion, pitch 0.85, `fire_crackle` layer, cooldown 6 ticks, 2 voices).
  `--end-cue=off` = the before.
- Measured (1/60 s RMS windows of the movie audio, off vs on): rocket blast drawn on video frame
  64, the boom from window 65 (+4..10 dB through 77); nuke blast frame 111, boom from 112. One
  frame (17 ms) after the flash, inside the hit-stop that holds the frame. Clip
  `rocket_blast_sound-ab-32ppm.mp4` (back to back, with sound). Not listened to: no audio
  device judgement possible here; the asset is the approved car wreck explosion.
- How sync works for every gun (read, not measured per weapon): StageAudio cues the shot on the
  frame a round appears in `CombatArena.shots` and the impact on the frame it leaves, in the same
  `_process` as the view; so impact sound is on the hit frame by construction (+0..1 frame).

### flamethrower ignition (brief item 5, `e32720c4`)
- Before: the stream grows from the nozzle (about 12 frames to the cop at 4 m); nothing marks the
  moment it lights (anticipation 2 at best).
- After: hit_feel.json `weapons` flamethrower `ignite_kick_px` 3 (`fire_kick_ticks` 9): the first
  puff after a 20-tick rest (`FeelCam.IGNITE_IDLE_TICKS`) kicks the camera back against the
  stream; the puffs themselves never kick (about 20 a second would blur).
- Measured (phase correlation, floor crop, frames 36-65): one 2.9 px jump at frame 45, eased back
  by frame 52, then still while the stream fires; `--feel=off` 0.0. Clip
  (clip since replaced). Subtle at 32 px/m: a camera move, invisible in stills.
- it6 `5ef1c584`: the lighting round also draws the nozzle lick as a flare (hit_feel.json
  `ignite_flare_k` 1.1 vs the lick's 0.45, shrinking back over `ignite_flare_ticks` 10;
  `WeaponFxIgnite`, the same rest rule as the kick). LOOK at 32 px/m (frames 325-333, x2 crops):
  an ink-edged vermilion and cream fireball about twice the lick on 326-327, smaller on 330, gone
  by 333; the same on 327-330 at 48 px/m. Verdict: the ignition now READS at 32 px/m. Clip
  `flamer_ignite_flare-ab-32-48ppm.mp4`.

### molotov throw follow-through (`41bb90e7` + `7326b53b`)
- Before (48 px/m, `--reach=7`): no wind-up, no follow-through; the next lit bottle in the claw is
  the only cue. Audit 1/3/3/3/0.
- `41bb90e7` (a negative rig_kick: the arm forward on the release): zero pixels changed (the aimed
  arm is already at its reach). `7326b53b`: the torso leans into the release (THROW_LEAN 0.5): the
  diff peaks at 1763 px at frame 301, a few px of body shift toward the target over about 15 frames.
- Verdict: SUBTLE at 48 px/m and practically invisible at 32 px/m (a 1-2 px shift for 3 frames,
  diff 607 px peak); anticipation stays 1 (still no wind-up).
- it6 tuning at 32 px/m: THROW_LEAN 1.0 and 1.5 changed the peak diff only 754 -> 890 px (the body
  translation saturates). `9b351ab4` adds the top-down read of a throw instead: the torso turns the
  gun shoulder through (THROW_TWIST 0.3 rad per unit of negative recoil, so 0.48 rad at the release,
  decaying with the recoil in 0.27 s). At 32 px/m the shoulder line visibly turns for about 15 frames
  (diff 500-800 px per frame, frames 301-315). Verdict: MODEST, a real follow-through now; still no
  anticipation. Clip `molotov_throw_twist-ab-32-48ppm.mp4` (32 px/m, then 48 px/m; deleted in it11, the twist plays in the after of `molotov_windup-ab-32-48ppm.mp4`).

### pistol muzzle (`d79c5278`)
- Before (head, 32 px/m, `--reach=6`, kill tick 302): Rivet's flash a 15 px speck on frames
  298-299; the cop's own flash star (295-297) read bigger than the hero's.
- After: hit_feel.json `weapons` pistol `muzzle_k` 1.6 (WeaponFxArt.muzzle's cell scale; 1 and
  `--feel=off` = before): an ink-edged cream star with a vermilion core about one body wide on
  298-299. At 48 px/m it does not swamp Rivet. Clip `pistol_muzzle-ab-32-48ppm.mp4`.
- it9 machine pistol (`193bc529`): filmed first (32 px/m, `--reach=6`, kill tick 306): at 14
  rounds a second (rof_hz 14, interval 4 ticks, FLASH_TICKS 3) the flash_smg cell is up 3 ticks of
  every 4, a 6-8 px flicker at the gun that hardly reads. muzzle_k 1.3 (under the pistol's 1.6):
  an ink-edged cream star with a vermilion core about the gun's size on every round of the burst,
  Rivet still clear (x3 crops of frames 302-314, both builds; kill 306 on both). Clip
  `machine_pistol_muzzle-ab-32-48ppm.mp4`. Seen in passing: the flash sits to the aim side of the
  held gun's drawn barrel (GUN_SIDE_M vs the hold pose), an owner call (holds), not touched.

### ray_gun kill (it7): no change
- The it6 note ("the body does not answer the beam") was a misread: the kill is the approved
  brutality signature `ray_gun_dissolve` and its lock-up is the design (48 px/m sheet, JOURNAL
  FINDING 23:27). A per-weapon standard death would only change `--gore=reduced`.
