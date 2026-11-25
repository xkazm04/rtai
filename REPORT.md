# REPORT lane yard, run n29 (2026-11-25), branch `n29-yard` (DRAFT, in progress, session 3)

**Gate:** not run yet.

## What works
| item | evidence | number |
|---|---|---|
| 1. Floor i55 (owner's pick) | `a880ea994`, `4dfce5328`; `evidence/yard29/floor_i55_bars.md`, `evidence/yard29/floor_i20_vs_i55_mid_32ppm.png`, `evidence/yard29/floor_i20_vs_i55_gate_32ppm.png`, `evidence/yard29/floor_i55_64ppm.png`; masters `n29/yard/floor_i20_vs_i55_mid_32ppm.mp4` (23.0 s, 1920x1080, 60 fps) | floor C* 13.0 -> 18.3, L* 54.4 -> 51.9; patrol 80.6 / 88.7 %, rifle 104.5 %, pellet 100.9 %; pilots identical on 5 seeds (`evidence/yard29/prologue-yard-pilots-i55.json`) |
| 2. Taller lit hall facade with a roof glow | `4e2302840`, `7d4926a06`, `d8dd15d98` (tall collapsed bay), `d838f9e66` (roof glow `PrologueRoofGlow`, mouth pools), `73a4d9968` (fire mouths as a wall light `yard_hall_mouth_wall`), `62982244a` (two bays flipped against the plume stamp), `4fc898482`, `9021d82cd`, `5479f91df`; `evidence/yard29/hall_before_after_front_32ppm.png`, `evidence/yard29/plate_vs_game_front_32ppm.png`, `evidence/yard29/plate_vs_game_front_64ppm.png`, `evidence/yard29/frame-cost.md`; cut tool `tools/art/prologue_yard_hall_tall.py` | lit wall band ~70 -> ~150 px at 32 px/m (2.1x); red share 0.00 % on every cut; frame cost vs n28 p50 -0.040 ms, CI95 upper +0.255 ms (bar 0.5, bench lock, machine saturated); lower window rows burst 116.0 / collapsed 90.8 vs feed 86.9 / shutter 67.2 (fire mouths brightest), floor under the front +0.95 R max; pilots identical (`evidence/yard29/prologue-yard-pilots-hall.json`, `evidence/yard29/prologue-yard-pilots-hall2.json`) |
| 3. Belt as one snaking line | `5d373c8e6`, `ffeeb3165`, `6cb6cdef6`, `96852d911`, `b74df5c69`, `fca8ecd4c`; `evidence/yard29/belt_snake_before_after_mid_32ppm.png`, `evidence/yard29/plate_vs_game_mid_snake_32ppm.png`, `evidence/yard29/belt_snake_64ppm.png`, `evidence/yard29/belt_bars.md`, `evidence/yard29/belt_lanes.txt`; masters `n29/yard/belt_snake_before_after_mid_32ppm.mp4` (h264 1920x1080 yuv420p 60/1, 23.000 s) | five overhead spans, joins 0.05..0.293 m; lanes 31 ok / 0 FAIL (same as n28); no cover or collision; pilots identical (`evidence/yard29/prologue-yard-pilots-spans.json`); patrol blue under a span 84.1 % (one sample 60.4 %) |

## What does not
- Floor i55: Rivet's luminance delta 0.147 (bar 0.19; i20 0.183, also under) and pool gain +2.0 (bar +4; i20 +2.6, also under since n28's hall lights). The brown impression also hazes every printed thing on the floor (stains, bay lines, forklift, skip, crate, the fence at the south edge).
- Belt: Rivet over a span keeps 20.9 % of his floor-only luminance delta (0.021 vs 0.101, worst-case points on the beam): copper on copper; he reads by silhouette, helmet and collar.
- Mutate on `project/boot/prologue/prologue_yard_overprint.gd`: 0 killed / 7 survived (draw-only code, no unit test renders it).
- Hall: the plumes no longer stamp every half bay but still stand on one even row; no roof surface is visible from the game camera; the snake does not come out of a fire mouth as in the plate.

## What blocked or slowed you
- Codex image jobs stall on the copy to `./out` (11 to 15 min a job instead of 90 s).

## Calls for the owner
- The belt beam colour under Rivet: a darker or desaturated beam, or a drop shadow under Rivet (stills: `evidence/yard29/belt_snake_64ppm.png`).
## Merge notes
## Next steps
## Builder ledger
| tag | model | minutes | verdict |
|---|---|---|---|
| floor-i55 | Sonnet | 48 | accepted |
| hall-art | Opus | 74 | accepted |
| hall-finish | Opus | 51 | accepted |
| belt-snake | Opus | 66 | accepted |
| belt-finish | Sonnet | 25 | accepted |
