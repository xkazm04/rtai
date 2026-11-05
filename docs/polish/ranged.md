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
| 4 | plasma_rifle | 2 | 2 | 2 | 1 | 0 | impact star and a cream glow at the cop, but the struck/killed body barely answers (owner item 1) |
| 5 | electro_gun | 2 | 2 | 2 | 2 | 0 | zigzag bolt, star, skeleton flicker, yellow burst; the kill reads, the struck human is thin (owner item 1) |
| 6 | homing_shard | 2 | 2 | 2 | 2 | 0 | the lozenge shards read in flight, a star on the hit frame and a small jolt/turn; the pop and the blood come at about T+40 (owner item 4: 3 + 36 grind ticks, JOURNAL) |
| 7 | hand_cannon | 2 | 2 | 3 | 3 | 0 | ring at the muzzle, ink star + blood on the hit frame, body thrown; no camera answer for the heaviest single shot |
| 8 | ray_gun | 2 | 2 | 2 | 2 | 0 | ink bolt and star on the hit frame, a pale ring at the body; the kill reads as a faint flash, the body barely answers at 32 px/m |
| 9 | flamethrower | ? | 2 | 2 | 3 | 0 | burn death: star and a charred black body on the kill frame, scorch marks stay; the stream itself was not in the sampled frames |
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
