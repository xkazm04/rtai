# Shift dash on the fixed tick

Measured on 2026-11-22 at 60 Hz with the production motion table, enemy rounds, war machine and squad patrol cop. The burst covers **4.5 m in 10 ticks**, ends at walk speed (6.75 m/s), and accepts a new press after 40 complete cooldown ticks. Holding Shift and a direction then uses the 9.3 m/s sprint. The dash grants **zero invulnerability ticks**. The 8 m rocket missed by 1.414 m beyond its damage boundary, so there is no blast immunity window.

## Dodge

Rivet stood still for 15 ticks after rocket launch or the first stomp tell. The dodge arm then supplied one tick of sideways stick and dash and released both. The burst completed under its own movement, followed by ordinary braking. Values are from the resolved impact. Positive clearance in metres means the attack missed. Elapsed time is measured in simulation ticks. The standing arm used the same attack and spawn.

| Enemy attack | Initial range | Standing impact tick | Standing clearance | HP lost | Dash impact tick | Dash clearance | HP lost |
|---|---:|---:|---:|---:|---:|---:|---:|
| Rocket | 5.0 m | 26 | −3.000 m | 10 | 30 | +1.296 m | 0 |
| Rocket | 8.0 m | 46 | −3.000 m | 10 | 50 | +1.414 m | 0 |
| Rocket | 12.0 m | 73 | −3.000 m | 10 | 77 | +1.414 m | 0 |
| Stomp | 1.8 m | 48 | −1.700 m | 24 | 48 | +1.827 m | 0 |
| Stomp | 2.5 m | 48 | −1.000 m | 24 | 48 | +2.103 m | 0 |
| Stomp | 3.5 m | 48 | 0.000 m | 24 | 48 | +2.615 m | 0 |

`FoeRocketFlight.launch` fired the authored hostile rocket at Rivet's starting point. `ArenaProjectiles.step_shots` advanced its 9 m/s flight and resolved contact or arrival. Rocket clearance subtracts the 3 m splash radius and Rivet's body radius. A standing target triggered contact before the projectile reached its destination. The 5 m trial deliberately starts the projectile inside the trooper's ordinary 8 m minimum firing distance.

For the stomp, a live squad war machine selected and announced its own attack. Distances span the inside and edge of its 3.5 m reach, where the stomp can actually start. Its damage check includes the centre-to-centre boundary and uses a 3.5 m radius. Rivet stayed exposed on every simulated reaction and dodge tick.

## Chase

A gauntlet patrol cop broke morale after four squadmates fell. Its open-ground travel between ticks 30 and 90 measured **3.200 m/s**. The production squad walk requests the archetype's speed while panicking. The generic human flee example in `bodies.json` is 4.5 m/s.

| Rivet input | Steady mean speed | Gain on patrol cop | Ticks to close 10 m | Time |
|---|---:|---:|---:|---:|
| Plain directional run | 6.750 m/s | 3.550 m/s | 181 | 3.017 s |
| Repeated dash, hold sprint off | 10.800 m/s | 7.600 m/s | 57 | 0.950 s |
| Repeated dash, hold sprint on | 12.692 m/s | 9.492 m/s | 53 | 0.883 s |

The speed measurement averages ten full 50-tick cycles after one warm-up cycle. Direction stays held. Shift is released for one tick before each new burst in the held-sprint arm. The intercept measurement starts Rivet from rest, with a ready dash and the target already fleeing at its measured speed. It counts the first tick that erases the full 10 m centre-to-centre lead. The first burst accounts for the difference between this intercept and a steady-average estimate.

## Contact and replay

Each dash step samples the stage's solid collision at intervals no wider than Rivet's radius. Progress of less than half the requested distance along the dash ends the burst on that tick. The stage's existing body contact rule blocks machines and bosses. Head-on contact with a human above Rivet's 7.5 m/s threshold uses the 1.6 m knockback rule with zero damage. A thin wall, a robot, a boss and a human were exercised through `ArenaStage.step`.

`TickInput` now accepts 48 button bits. Its 16-bit axis packing already uses a Godot int64. `ReplayLog` and `InputTape` store packed inputs in `Array[int]`. JSON numbers preserve every packed combination through wire bit 36. `ControlsReplay` reads the controls header and delegates the input payload to `ReplayLog`. `LiveInput`, `PlayerActions` and `PlayerCommand` already respect the data-defined wire bit. The `StagePilot.write_state` digest writes its preceding button word with `put_32`, which covers dash bit 31 and omits bit 32 from that digest field. Its live edge detector and tape playback both keep the full integer.

Reproduce the measurements with `node tools/tests/run_unit.mjs --select=test_player_motion_dash_dodge,test_player_motion_dash_chase`. The `dash_probe` lines in `build/test-results/unit-tests.log` contain the observed impacts, HP changes, speeds and intercept ticks.
