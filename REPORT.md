# REPORT lane yard, run n29 (2026-11-25), branch `n29-yard` (DRAFT, in progress)

**Gate:** not run yet.

## What works
| item | evidence | number |
|---|---|---|
| 1. Floor i55 (owner's pick) | `a880ea994`, `4dfce5328`; `evidence/yard29/floor_i55_bars.md`, `evidence/yard29/floor_i20_vs_i55_mid_32ppm.png`, `evidence/yard29/floor_i20_vs_i55_gate_32ppm.png`, `evidence/yard29/floor_i55_64ppm.png`; masters `n29/yard/floor_i20_vs_i55_mid_32ppm.mp4` (23.0 s, 1920x1080, 60 fps) | floor C* 13.0 -> 18.3, L* 54.4 -> 51.9; patrol 80.6 / 88.7 %, rifle 104.5 %, pellet 100.9 %; pilots identical on 5 seeds (`evidence/yard29/prologue-yard-pilots-i55.json`) |
| 2. Taller lit hall facade (in progress) | `4e2302840`, `7d4926a06`; `evidence/yard29/plate_vs_game_front_tall_32ppm.png`, `evidence/yard29/hall_tall_front_32ppm.png`; cut tool `tools/art/prologue_yard_hall_tall.py` | lit wall band ~70 -> ~150 px at 32 px/m (2.1x); red share 0.00 % after the amber shift; impression starts at the wall base (y -1.1); frame cost, pilots and the collapsed bay not yet |

## What does not
- Floor i55: Rivet's luminance delta 0.147 (bar 0.19; i20 now 0.183, also under) and pool gain +2.0 (bar +4; i20 +2.6, also under since n28's hall lights). The brown impression also hazes every printed thing on the floor (stains, bay lines, forklift, skip, the fence at the south edge).

## What blocked or slowed you
- Codex image jobs stall on the copy to `./out` (11 to 15 min a job instead of 90 s).

## Calls for the owner
## Merge notes
## Next steps
## Builder ledger
| tag | model | minutes | verdict |
|---|---|---|---|
| floor-i55 | Sonnet | 48 | accepted |
| hall-art | Opus | 74 | accepted |
