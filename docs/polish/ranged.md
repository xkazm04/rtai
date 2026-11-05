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

Iteration 1 scores: arena pit, lone cop, 32 px/m, `--feel=off` (main's feel). Columns:
Anticipation / Impact / Read 32 / Victim sync / Sound (arena). `?` = not looked at yet.

| # | Weapon | A | I | R | V | S | Why it ranks here |
|---|---|---|---|---|---|---|---|
| 1 | mini_nuke | 1 | 2 | 2 | 3 | 0 | the biggest hit in the game and the frame does not move: a huge ink burst, no stop, kick or shake; half off frame |
| 2 | rocket_launcher | 2 | 2 | 3 | 3 | 0 | strong ink blast, debris, smoke, crater; the camera ignores it (no weight) |
| 3 | gatling | 1 | 2 | 2 | 2 | 0 | casing/spark spray and blood read; sustained fire has no weight at all; the 0.5 s spin-up shows nothing (no barrel turn, no cue) |
| 4 | plasma_rifle | 2 | 2 | 2 | 3 | 0 | impact star and a cream glow at the cop; it3 at 48 px/m: a 3-frame burst, the hole, the body thrown about 1.7 m along the bolt on the hit frame (the it1 "barely answers" was a misread at the frame edge) |
| 5 | electro_gun | 2 | 2 | 2 | 3 | 0 | zigzag bolt, star, skeleton flicker, yellow burst; the kill reads; it3 `9c140ffb`: the struck (stunned) body is thrown 0.3 m along the bolt on the hit frame, then convulses |
| 6 | homing_shard | 2 | 2 | 2 | 2 | 0 | the lozenge shards read in flight, a star on the hit frame and a small jolt/turn; the pop and the blood come at about T+40 (owner item 4: 3 + 36 grind ticks, JOURNAL) |
| 7 | hand_cannon | 2 | 2 | 3 | 3 | 0 | ring at the muzzle, ink star + blood on the hit frame, body thrown; no camera answer for the heaviest single shot |
| 8 | ray_gun | 2 | 2 | 2 | 2 | 0 | ink bolt and star on the hit frame, a pale ring at the body; the kill reads as a faint flash, the body barely answers at 32 px/m |
| 9 | flamethrower | 2 | 3 | 3 | 3 | 0 | it3 48 px/m: the vermilion/cream tongues grow from the nozzle over about 12 frames and light the cop on contact, patches stay; the ignition had no beat -> `e32720c4` a 3 px kick on the first puff |
| 10 | molotov | ? | 3 | 3 | 3 | 0 | the fire patch reads at a glance (vermilion and cream flame cluster), the burning cop dies charred with a star; the throw not judged |
| 11 | pistol | 1 | 2 | 2 | 3 | 0 | Rivet's round is a 1-2 frame streak (the muzzle hardly reads at 32 px/m); blood spurt on T+1, the fall reads |
| 12 | machine_pistol | 1 | 2 | 2 | 3 | 0 | each round sprays sparks and the body bleeds on the hit frames; the burst reads, Rivet's muzzle hardly does |
| 13 | gloria | ? | ? | ? | ? | 0 | filmed, not scored |
| - | assault-rifle | ? | ? | ? | ? | ? | in rivet_arsenal.json, not in weapons.json (`--weapon` cannot arm it); film via `--loadout` |

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
  `flamer_ignite-ab-32ppm.mp4`. Subtle at 32 px/m; not judged by eye in motion yet.
