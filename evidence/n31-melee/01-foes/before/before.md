# enemy melee on Rivet: before

Real CombatArena + ArenaSquad, bare map, 60 Hz. Rivet stands until the foe tells, waits 0..telegraph ticks (step 3), then walks straight away or sideways at 3 / 5 / 6.75 m/s (instant speed). Drawn tip: the shield slab is the exact polygon FoeShieldView draws; the others use the authored reach_m (the art strike frame is not measured in metres). overhang = hit-time centre distance past the drawn tip.

| foe | weapon | hit reach (centre) m | authored reach m | drawn tip m | trials | hits | hits, centre past drawn tip | hits, whole body past drawn tip | max overhang m | hits while walking sideways |
|---|---|---|---|---|---|---|---|---|---|---|
| riot_cop | baton | 2.2 | 1.6 | 1.6 | 72 | 19 | 19 | 0 | 0.574 | 14 |
| robot_thug | claw | 2.6 | 2 | 2 | 102 | 23 | 23 | 0 | 0.576 | 17 |
| appliance_warden | shove | 2.4 | 1.8 | 1.8 | 72 | 12 | 12 | 0 | 0.59 | 9 |
| shield_robot | shove | 2.4 | 1.8 | 2.2 | 102 | 4 | 2 | 0 | 0.484 | 2 |
