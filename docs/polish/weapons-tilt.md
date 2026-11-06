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
4. **Next:** the impact height (finding 4); chainsaw, flamer, tubes, gatling and molotov parts;
   melee-framed films for the blades.
