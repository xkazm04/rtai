# Rivet's weapons under the 55-degree tilt: the audit (d8-weapons, 2026-11-06)

**What was filmed:** every weapon in the arena pit at 48 px/m:

```
arena.tscn -- --weapon=<id> --bot=gunplay --lone --cam=fight --ppm=48 --clean --feel=off --view=tilt --rigs
```

- 960 frames at 60 fps (16 s) each, run through scratch `film2.sh`.
- The "before" is today's top-down held part (`--held-pitch=off`), so it can be filmed on any build.
- All 18 films have 0 SCRIPT ERROR. The six films that a half-landed edit contaminated
  (chainsaw, flamethrower, gatling, homing shard, mini nuke, rocket launcher) were filmed again clean.
- **How it was judged:** from contact sheets of frames 300/500/700/900 (motion-quality-gating:
  score only what is visible; `?` = not seen in the frames).

## Scores

Each weapon is scored 0 (bad), 1 (partial) or 2 (good) on three columns:

- **H:** the held gun reads as held in the claw at this angle.
- **F:** the FX leaves the drawn barrel tip, at gun height.
- **L:** the shot lands on the target's body, not its feet.

Weakest first:

| # | weapon(s) | H | F | L | what is wrong under tilt |
|---|---|---|---|---|---|
| 1 | plasma rifle, electro gun, ray gun, homing shard (long guns) | 0 | 2 | ? | The low carry is a tan blob at the knee: the top-down part hangs nose-down and loses its outline. Aimed, it is a flat lozenge with no grip or side body. |
| 2 | katana, plasma sword, electro baton (blades) | ? | ? | ? | The bot runs into melee and leaves the crop. They need a melee-framed shot (`--cam=fight` tracks the target, not Rivet). |
| 3 | chainsaw | 1 | ? | ? | A dark top-down bar. At the low carry it hangs straight down the leg. |
| 4 | flamethrower | 1 | 1 | 0 | The wand reads as a lance with a cream tip. **The hit spark lands at the cop's feet** (frame 500): an impact at ground height, not chest height. |
| 5 | molotov (thrown) | 1 | 2 | 2 | The bottle in the claw is tiny at 48 px/m. The blast keeps the vermilion-and-cream law and reads well. |
| 6 | mini nuke, rocket launcher (tubes) | 1 | 2 | 2 | Shouldered, they read. At the low carry the tube stands vertical at the hip. The blast plus blood reads. |
| 7 | pistol, machine pistol, hand cannon, Gloria (sidearms) | 1 | 2 | ? | At 32-48 px/m the top-down part is a dark lozenge beside the claw. **Fixed `ea380dba`/`d87722f9`** (the three-quarter parts). |
| 8 | gatling | 2 | 2 | ? | The long barrel ahead of the hip in both claws reads as a heavy gun even top-down. |
| - | assault rifle | ? | ? | ? | The bot moves out of the crop. Film it again with a wider crop. |

## The fix order (as built)

1. **Sidearms:** three-quarter held parts, keyed by pitch (`weapon_held_pitch.json` "55"), `ea380dba`.
2. **Long guns and blades:** three-quarter held parts generated from the shipped pickups
   (`gen55c`). The three blades show their flat and their edge.
3. **Every held_55 part imports with mipmaps,** as the shipped held parts do. Without them a
   600 px part drawn about 40 px wide aliases into the muddy look found at 64 px/m in iteration 1.
4. **The part stands up on screen** (`ce6ed14d`, HeldPitchArt.stand):
   - It undoes the camera's sin(pitch) squash, because the art is already drawn for 55 degrees.
   - It thins to half height as the barrel turns up or down the screen, so the nose-down carry
     prints as a slim tube, not a blob.
5. **Shots at gun height** (`258173e0` + `5e3d8e25`, ShotLift): this answers finding 4.
   - Rounds, body and metal hits and enemy muzzle stars lift by 1 m under tilt.
   - A faint ink shadow line stays on the ground under each round.
   - Ground hits stay down.

## After (48-64 px/m, tilt, filmed on 258173e0 / 5e3d8e25)

| weapon(s) | H | F | L | note |
|---|---|---|---|---|
| ray gun, plasma rifle (64 px/m) | 2 | 2 | ? | They read as their pickups: grip, ribs, ball tip / stock, cell, vents. The plasma rifle floats about 10 px above-left of the claw. |
| long guns (48) | 1-2 | 2 | 2 | Aimed, they read as guns. The nose-down carry is a slim tube. |
| long guns (32, the shipped zoom) | 1 | 2 | 2 | **Not better than the before:** bigger and muddier than the slim top-down silhouette. |
| pistol (48) | 1 | 2 | 2 | The rounds now land in the chest, not at the feet; the ground shadow shows. |
| blades | ? | ? | ? | Parts landed, but not yet seen in a melee-framed film. |

The director reel goes 19/19 chapters down with 0 SCRIPT ERROR in both `top` and `tilt` (on 258173e0).

## Iteration 3 (7d93ac4a, 8c64bdeb): every weapon has a 55 part; small cells below 56 px/m

6. **The long-gun float** was fixed in `c9828312` (the head clearance uses the top-down barrel thickness).
7. **Heavy, tube and thrown parts** (`gen55d`, from the shipped pickups): chainsaw, Gatling, flame
   wand (the tanks masked out of the reference, so only the wand is drawn), rocket tube, mini-nuke,
   molotov. The tubes get an `empty` part (the warhead cut away) so HeldTube's spent-tube swap stays
   on the 55 canvas.
8. **Small cells** (`tools/art/held_pitch_small.py`): the 55 part re-toned from the unprepped cut,
   drawn by HeldLod below `held_small_below_ppm` (56), as WeaponArt does for `top`.

| weapon(s) | H | F | L | note (48 px/m unless named; director chapters for blades) |
|---|---|---|---|---|
| rocket tube, mini-nuke | 2 | 2 | 2 | Flared back, sight, grip, fins and the striped warhead read; clearly better than the before. |
| katana | 2 | ? | 2 | The curve and the hilt read in the claw; the kill lands. The smear is not yet judged at height. |
| plasma sword | 2 | ? | 2 | The full 55 part's coil hilt printed as an ink blob; its small cell (`8c64bdeb`) fixes it. |
| chainsaw | 2 | ? | 2 | The engine and the toothed bar read at the hip in both claws. |
| flame wand | 2 | 1 | ? | The hose curve reads. The jet's start at the drawn tip is not yet checked. |
| electro baton | 1 | ? | 2 | Still a thin stick with a dark coil at 48 px/m; no clear gain over the before. |
| Gatling | 1 | 2 | ? | **Worse than the before:** a fat tan tube; the slim top-down bundle reads more as a rotary gun. |
| sidearms, long guns (32) | 1 | 2 | 2 | The small cell barely changes pistol and plasma rifle (Gloria goes two-tone dark, as for top). The 32 px/m issue is the part's size and silhouette, not its tones. |

The director reel on 8c64bdeb: top 19/19 and tilt 19/19 chapters, all down, 0 SCRIPT ERROR (headless).

## Still open

- The Gatling: tried size_k 0.85 and a small cell without close_gaps; all read as a pale club. It
  kept the top-down part (`f0651a19`), then a regenerated 55 Gatling (gen55g: dark barrels with
  gaps, no small cell) went back in: aimed it reads as a rotary gun (H 2); carried nose-down it is a
  thin dark stick (H 1). `enabled: false` = the top-down part. Owner's call.
- The 32 px/m read of the long guns: size_k per row; film both at 32 and pick.
- The electro baton at 48 px/m.
- The reload ring (1.5 m up the screen over Rivet) may sit on the tall rig's face under tilt: not yet
  seen on film (no reload in the filmed fights), so it is unchanged.

## Iteration 4 (a06036e6, ddf61c87): the flame jet and the charge crackle leave the drawn tip

9. **The flame jet** drew its tongues and embers on the sim's ground line, below the nozzle lick at
   the drawn wand tip. `ShotLift.jet` lifts them to gun height and pulls them onto the drawn tip near
   the nozzle (let go by 2 m). `--shot-lift=off` = the before; under `top` the lift is zero.
10. **The electro gun's charge crackle** (gathering arcs, a swelling cream core) drew at the ground
    muzzle point by Rivet's feet. `ShotLift.claw_at` puts it on the drawn coil tip under tilt.

| weapon(s) | H | F | L | note (48 px/m, same seed before/after) |
|---|---|---|---|---|
| flame wand | 2 | 2 | 2 | The stream now leaves the wand tip and its tongues reach the cop's chest; before, a gap under the tip and the tongues ran along the floor. `flamethrower_tilt_48_jet_before_after.png`. |
| electro gun | 2 | 2 | 2 | The charge gathers on the coil tip, the arc leaves it and the shock lands on the body; before, the crackle and core sat on the floor by the feet. `electro_gun_tilt_48_charge_before_after.png`. |
| katana (smear) | 2 | 1 | 2 | The smear is drawn in the squashed ground plane about the grip (the tilted plane at hand height); at 48 px/m it shows only faintly under the hit star. |
