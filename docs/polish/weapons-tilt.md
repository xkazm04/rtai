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

## Still open

- The long-gun float: `RivetCarryAngle.place_beside` places the part by the top-down geometry.
- A simplified part at 32 px/m (a held LOD, as WeaponArt's `small` part does for `top`).
- Films for the blades, chainsaw, flamer, tubes, gatling and molotov parts.
