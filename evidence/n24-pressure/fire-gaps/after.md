# Enemy fire on the gauntlet street

Open ground, 10 m initial range, 30 seconds at 60 Hz. Every trial uses seed 1.
Rivet stands still, circles the moving enemy at 10 m, or strafes from y = -5 to +5 at x = 10.
Kinematic movement is 9.3 m/s. Rivet takes damage and uses no combat inputs.

Hits include direct and splash impacts from sample rounds followed to the end of flight.
Under fire counts ticks with at least one airborne round that later hits Rivet.

| Enemy | Gun | Motion | Rounds | RPS | Mean s | Max s | Hits | Hit share | Under fire |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| patrol_cop | assault-rifle | standing | 121 | 4.033 | 0.246 | 0.633 | 60 | 0.496 | 41.9% |
| patrol_cop | assault-rifle | circle | 121 | 4.033 | 0.246 | 0.633 | 27 | 0.223 | 26.9% |
| patrol_cop | assault-rifle | strafe | 121 | 4.033 | 0.246 | 0.633 | 42 | 0.347 | 28.0% |
| swat | assault-rifle | standing | 121 | 4.033 | 0.246 | 0.633 | 51 | 0.421 | 46.0% |
| swat | assault-rifle | circle | 121 | 4.033 | 0.246 | 0.633 | 38 | 0.314 | 29.0% |
| swat | assault-rifle | strafe | 121 | 4.033 | 0.246 | 0.633 | 36 | 0.298 | 31.8% |
| robot_gunner | assault-rifle | standing | 121 | 4.033 | 0.246 | 0.633 | 56 | 0.463 | 46.4% |
| robot_gunner | assault-rifle | circle | 121 | 4.033 | 0.246 | 0.633 | 30 | 0.248 | 25.4% |
| robot_gunner | assault-rifle | strafe | 121 | 4.033 | 0.246 | 0.633 | 36 | 0.298 | 31.1% |
| contractor | assault-rifle | standing | 121 | 4.033 | 0.246 | 0.633 | 59 | 0.488 | 43.2% |
| contractor | assault-rifle | circle | 121 | 4.033 | 0.246 | 0.633 | 25 | 0.207 | 23.5% |
| contractor | assault-rifle | strafe | 121 | 4.033 | 0.246 | 0.633 | 37 | 0.306 | 28.7% |
| rocket_trooper | rocket | standing | 10 | 0.333 | 2.861 | 3.100 | 10 | 1.000 | 46.2% |
| rocket_trooper | rocket | circle | 10 | 0.333 | 3.100 | 3.100 | 0 | 0.000 | 0.0% |
| rocket_trooper | rocket | strafe | 9 | 0.300 | 3.219 | 4.100 | 5 | 0.556 | 25.9% |
| sentry_turret | turret_gun | standing | 117 | 3.900 | 0.242 | 2.383 | 18 | 0.154 | 13.5% |
| sentry_turret | turret_gun | circle | 78 | 2.600 | 0.330 | 4.700 | 0 | 0.000 | 0.0% |
| sentry_turret | turret_gun | strafe | 117 | 3.900 | 0.247 | 2.833 | 17 | 0.145 | 10.9% |
| war_machine | war_cannon | standing | 12 | 0.400 | 2.417 | 2.417 | 12 | 1.000 | 32.7% |
| war_machine | war_cannon | circle | 5 | 0.167 | 6.167 | 6.167 | 0 | 0.000 | 0.0% |
| war_machine | war_cannon | strafe | 11 | 0.367 | 2.713 | 2.800 | 5 | 0.455 | 14.2% |

## Seconds between the first and last muzzle events

Ticks follow the active branch and include the next muzzle event.
Startup and the unfinished final interval are excluded. The JSON retains exact tick counts.
Tracking tells and locked aim are separate. The turret traverses to its locked lane.
The war machine traverses in place while in range and waiting to align its cannon.
Rocket repositioning takes priority over a concurrent cooldown.
Street riflemen use GuardBrain. EnemyGunner volley rest applies to the range drill.

| Enemy | Motion | tell | aim_lock | burst_gap | cooldown | volley_rest | line_of_sight | max_shooters | reposition | traverse | trigger_setup | muzzle |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| patrol_cop | standing | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| patrol_cop | circle | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| patrol_cop | strafe | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.02 | 0.00 | 0.50 | 2.00 |
| swat | standing | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| swat | circle | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| swat | strafe | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| robot_gunner | standing | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| robot_gunner | circle | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| robot_gunner | strafe | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| contractor | standing | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| contractor | circle | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| contractor | strafe | 0.00 | 0.00 | 12.00 | 15.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.50 | 2.00 |
| rocket_trooper | standing | 7.20 | 1.65 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 16.60 | 0.00 | 0.15 | 0.15 |
| rocket_trooper | circle | 7.20 | 1.65 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 18.75 | 0.00 | 0.15 | 0.15 |
| rocket_trooper | strafe | 6.40 | 1.47 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 17.62 | 0.00 | 0.13 | 0.13 |
| sentry_turret | standing | 0.00 | 4.80 | 7.20 | 6.00 | 0.00 | 0.00 | 0.00 | 0.00 | 7.87 | 0.27 | 1.93 |
| sentry_turret | circle | 0.00 | 3.00 | 4.80 | 3.75 | 0.00 | 0.00 | 0.00 | 0.00 | 12.42 | 0.17 | 1.28 |
| sentry_turret | strafe | 0.00 | 4.80 | 7.20 | 6.00 | 0.00 | 0.00 | 0.00 | 0.00 | 8.40 | 0.27 | 1.93 |
| war_machine | standing | 13.02 | 0.00 | 0.00 | 13.20 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.18 | 0.18 |
| war_machine | circle | 4.73 | 0.00 | 0.00 | 4.80 | 0.00 | 0.00 | 0.00 | 0.00 | 15.00 | 0.07 | 0.07 |
| war_machine | strafe | 11.83 | 0.00 | 0.00 | 12.00 | 0.00 | 0.00 | 0.00 | 0.00 | 2.97 | 0.17 | 0.17 |
