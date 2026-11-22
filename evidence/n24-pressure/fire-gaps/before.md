# Enemy fire on the gauntlet street

Open ground, 10 m initial range, 30 seconds at 60 Hz. Every trial uses seed 1.
Rivet stands still, circles the moving enemy at 10 m, or strafes from y = -5 to +5 at x = 10.
Kinematic movement is 9.3 m/s. Rivet takes damage and uses no combat inputs.

Hits include direct and splash impacts from sample rounds followed to the end of flight.
Under fire counts ticks with at least one airborne round that later hits Rivet.

| Enemy | Gun | Motion | Rounds | RPS | Mean s | Max s | Hits | Hit share | Under fire |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| patrol_cop | assault-rifle | standing | 64 | 2.133 | 0.454 | 1.533 | 36 | 0.563 | 22.7% |
| patrol_cop | assault-rifle | circle | 64 | 2.133 | 0.454 | 1.533 | 0 | 0.000 | 0.0% |
| patrol_cop | assault-rifle | strafe | 64 | 2.133 | 0.454 | 1.550 | 10 | 0.156 | 8.5% |
| swat | assault-rifle | standing | 64 | 2.133 | 0.454 | 1.533 | 27 | 0.422 | 24.3% |
| swat | assault-rifle | circle | 64 | 2.133 | 0.454 | 1.533 | 0 | 0.000 | 0.0% |
| swat | assault-rifle | strafe | 64 | 2.133 | 0.454 | 1.533 | 10 | 0.156 | 8.8% |
| robot_gunner | assault-rifle | standing | 64 | 2.133 | 0.454 | 1.533 | 29 | 0.453 | 22.7% |
| robot_gunner | assault-rifle | circle | 64 | 2.133 | 0.454 | 1.533 | 0 | 0.000 | 0.0% |
| robot_gunner | assault-rifle | strafe | 64 | 2.133 | 0.454 | 1.533 | 13 | 0.203 | 10.6% |
| contractor | assault-rifle | standing | 64 | 2.133 | 0.454 | 1.533 | 35 | 0.547 | 22.6% |
| contractor | assault-rifle | circle | 64 | 2.133 | 0.454 | 1.533 | 0 | 0.000 | 0.0% |
| contractor | assault-rifle | strafe | 64 | 2.133 | 0.454 | 1.533 | 17 | 0.266 | 11.9% |
| rocket_trooper | rocket | standing | 10 | 0.333 | 3.200 | 3.200 | 10 | 1.000 | 42.1% |
| rocket_trooper | rocket | circle | 10 | 0.333 | 3.200 | 3.200 | 0 | 0.000 | 0.0% |
| rocket_trooper | rocket | strafe | 10 | 0.333 | 3.200 | 3.200 | 7 | 0.700 | 33.0% |
| sentry_turret | turret_gun | standing | 63 | 2.100 | 0.445 | 3.433 | 7 | 0.111 | 8.9% |
| sentry_turret | turret_gun | circle | 45 | 1.500 | 0.532 | 5.733 | 0 | 0.000 | 0.0% |
| sentry_turret | turret_gun | strafe | 63 | 2.100 | 0.438 | 3.950 | 17 | 0.270 | 11.4% |
| war_machine | war_cannon | standing | 12 | 0.400 | 2.417 | 2.417 | 12 | 1.000 | 32.7% |
| war_machine | war_cannon | circle | 5 | 0.167 | 6.167 | 6.167 | 0 | 0.000 | 0.0% |
| war_machine | war_cannon | strafe | 11 | 0.367 | 2.688 | 2.800 | 6 | 0.545 | 17.1% |

## Seconds between the first and last muzzle events

Ticks follow the active branch and include the next muzzle event.
Startup and the unfinished final interval are excluded. The JSON retains exact tick counts.
Tracking tells and locked aim are separate. The turret traverses to its locked lane.
The war machine traverses in place while in range and waiting to align its cannon.
Rocket repositioning takes priority over a concurrent cooldown.
Street riflemen use GuardBrain. EnemyGunner volley rest applies to the range drill.

| Enemy | Motion | tell | aim_lock | burst_gap | cooldown | volley_rest | line_of_sight | max_shooters | reposition | traverse | trigger_setup | muzzle |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| patrol_cop | standing | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| patrol_cop | circle | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| patrol_cop | strafe | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.02 | 0.00 | 0.25 | 1.05 |
| swat | standing | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| swat | circle | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| swat | strafe | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| robot_gunner | standing | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| robot_gunner | circle | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| robot_gunner | strafe | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| contractor | standing | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| contractor | circle | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| contractor | strafe | 0.00 | 0.00 | 6.30 | 21.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.25 | 1.05 |
| rocket_trooper | standing | 7.20 | 1.65 | 0.00 | 3.05 | 0.00 | 0.00 | 0.00 | 16.60 | 0.00 | 0.15 | 0.15 |
| rocket_trooper | circle | 7.20 | 1.65 | 0.00 | 0.90 | 0.00 | 0.00 | 0.00 | 18.75 | 0.00 | 0.15 | 0.15 |
| rocket_trooper | strafe | 7.20 | 1.65 | 0.00 | 2.08 | 0.00 | 0.00 | 0.00 | 17.57 | 0.00 | 0.15 | 0.15 |
| sentry_turret | standing | 0.00 | 5.40 | 6.07 | 9.00 | 0.00 | 0.00 | 0.00 | 0.00 | 5.90 | 0.20 | 1.03 |
| sentry_turret | circle | 0.00 | 3.60 | 4.33 | 6.00 | 0.00 | 0.00 | 0.00 | 0.00 | 8.60 | 0.13 | 0.73 |
| sentry_turret | strafe | 0.00 | 5.40 | 6.07 | 9.00 | 0.00 | 0.00 | 0.00 | 0.00 | 5.47 | 0.20 | 1.03 |
| war_machine | standing | 13.02 | 0.00 | 0.00 | 13.20 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.18 | 0.18 |
| war_machine | circle | 4.73 | 0.00 | 0.00 | 4.80 | 0.00 | 0.00 | 0.00 | 0.00 | 15.00 | 0.07 | 0.07 |
| war_machine | strafe | 11.83 | 0.00 | 0.00 | 12.00 | 0.00 | 0.00 | 0.00 | 0.00 | 2.72 | 0.17 | 0.17 |
