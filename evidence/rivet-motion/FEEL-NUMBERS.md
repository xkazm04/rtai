# rivet-motion: feel numbers (consolidated 23:22, 2026-11-03)

These are sim-true numbers at 60 Hz, measured by the lane's probes (sources: `motion-probe.json` and
`test_melee_cadence`). None of them is a perf number. Display latency (input to pixel) is
**UNMEASURED** because PlayerMotion is not yet wired into the live game input path.

## Locomotion (PlayerMotion, motion-probe.json)
| gait | top | to 90 % | stop distance | stop time | 180-degree turn |
|---|---|---|---|---|---|
| walk/run | 4.5 m/s | 150 ms | 0.22 m | 117 ms | 250 ms |
| sprint (held, above the 5.0 m/s tackle line) | 6.2 m/s | 350 ms | 0.43 m | 167 ms | 550 ms |

- Input to motion (sim): Rivet moves on the press tick, so the sim adds 0 ticks.
- Dodge roll: 3.2 m in 22 ticks (367 ms), i-frames on ticks 2-14 (233 ms), 667 ms lockout before the next roll.

## Melee cadence (mashing at 20 presses/s; landing ticks per hit)
| table | hit 1 | hit 2 | finisher | finisher at |
|---|---|---|---|---|
| claw (bare-handed) | 5 | 16 | 32 | 0.53 s |
| electro baton | 4 | 13 | 27 | 0.45 s |
| katana | 5 | 16 | 30 | 0.50 s |

- Claw impact in the clips: hit-stop 3/3/7 ticks (these are clip constants until gunplay's HitFeel `land()` lands; see REQUEST 1).
- Tackle reel (48 px/m): contact at 6.03 m/s gives a knockdown (0.4 m slide). In the same reel claw 1/2/3 land at ticks 568/579/595.

## Planted faults caught
- A baton with no cancel point (cancel = recovery) lands its finisher late, and `test_melee_cadence` catches it.
- `test_player_motion` 6/6 catches two planted faults: a sprint at walk speed misses the 5 m/s line, and i-frames that run past the roll are a table error.

## Owner answers applied
- rivet-motion-1 = A: the T2 arm ratio 0.72.
- rivet-motion-2 = B: kept as a placeholder. Stop tuning on numbers and re-ask only with a real-time clip in the final look.
