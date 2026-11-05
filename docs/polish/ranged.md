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

To fill as the films are scored (iteration 1-2).

## Per weapon

To fill.
