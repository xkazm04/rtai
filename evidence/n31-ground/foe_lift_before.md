# Foe lift before (n31-04, 32 px/m, tilt 70; game code untouched)

Measured from delivered frames by `tools/ground/lift/foes.py` on captures of
`project/dev/ground_n31/foe_lift_probe.tscn` (`node tools/ground/lift/foes_capture.mjs --ppm=32`): each
kind is spawned by the wave squad (`spawn_member`, the staging of `cast_foot_film.gd`), walks a straight
line per facing (8 facings) at its `enemies.json` speed (patrol cop 3.2, riot 2.8, SWAT 3.4,
thug 2.4, gunner 2.2, contractor 3.0, lancer 3.2, door carrier 1.6, war machine 1.8 m/s) and, for
patrol cop and SWAT, also at a staged 6.0 m/s run (the speed `cast_foot_films.mjs` uses; the AI has no run
speed in the table). 24 warm-up ticks, then 48 consecutive ticks per facing (phase cover 1.0 = every
tenth of the stride seen; the turret and door carrier cover less because they barely cycle). Each tick is
rendered full, without any drop shadow (RigCastShadows nodes and the card-owned `_shadow`) and without the
foe; body = pixels that change when the foe is hidden, shadow = pixels the shadows darken (eroded 2 px to
drop body-edge fringe; a fit on the upper 30 % of the body is rejected as body shading).
Columns as `lift_before.md`, plus: body height px (helmet to lowest sole), travel % of that height, shadow
yes / none / partial (partial = some frames show no shadow: the body covers it, or a fit was rejected).
Ground point = the sim position of the foe through the camera. Tree measured: HEAD `03e0f315b` plus
n31-03's uncommitted Rivet bob edits; enemies do not use `RivetBob`, the shared shadow node is `RigCastShadows`
whose code n31-03 does not touch in the working tree. Capture frames and the 3-per-kind check crops with the
found lines (green head top, red lowest sole, yellow ground, blue shadow centre + ellipse) are in
`build/n31/n31-04/` (not committed). I looked at cop, contractor, thug, war machine, turret and door-carrier
crops: the lines sit where the eye puts them (head top, sole, shadow centre) except the door carrier, whose
"shadow" is a body-shading false positive (it has no shadow; treat its shadow columns as none).
Rivet repro: the Rivet capture and `lift.py` are untouched (`test_lift.py` still passes); a Rivet row was NOT
re-captured here: the lane Godot lock was busy with other runs and `lift_before.json` stands as is. 64 px/m was
not captured (time).
Not measured: sergeant_mulroney and appliance_warden (prologue-only, the wave spawner path used here does not
stage them). JSON: `foe_lift_before.json` (`gtai.ground-foe-lift/1`, 96 rows).

## Read

- **Cops and the contractor bounce.** Head-top travel per stride at 32 px/m, worst facing: patrol cop walk 10 px
  (31 cm, 19 % of height) S, run 22-24 px (69-75 cm, 35 %); riot cop 23 px (72 cm, 32 %); SWAT walk 21 px
  (66 cm, 35 %), run 27 px (84 cm, 46 %); lancer 19 px (59 cm); contractor 29 px (91 cm, 35-48 %); gunner 26 px
  (81 cm, 46 %). Thug 6 px, war machine 1 px, door carrier 1 px, turret 0.
- **Shadow stays on the ground while the body lifts (flying look):** facing S the cops and contractor lift the
  soles up to 15 px (patrol walk) / 35 px (patrol run) / 27 px (riot) / 30 px (contractor) off the ground
  point while the shadow centre moves 1-5 px (gap planted 2-5 px, gap max up to 36 px = 112 cm).
- **N-facing rows** (cops, SWAT, lancer, contractor, gunner): the lowest sole is 24-39 px BELOW the ground point and
  the shadow sits 22-38 px above the feet (gap planted 20-38 px): the walk-away cell is drawn low relative to
  the rig origin, so the shadow is behind/above the feet in a mirror of the S lift.
- **Gunner**: gap 2.5 px at most but shadow y range 22-26 px with correlation 0.999 to the head: its shadow
  (`_shadow.position` never set) rides the card's bounce, so it shows no gap and no ground.
- **Thug**: little travel, but the shadow (`_shadow.position = ground_local`) sits 13-14 px (44 cm) off the soles
  in the diagonal and S facings, constant: a placement offset, not a bounce.
- **War machine**: no gap (3 px), no bounce. **Turret**: no shadow, sole 25 px below the card origin. **Door carrier**: no shadow.

## Worst 5 rows (32 px/m)

| # | row | numbers | cause |
|---|---|---|---|
| 1 | swat run N | travel 27 px (84 cm, 46 %), planted gap 38.5 px (120 cm), shadow 36 of 48 frames | drawn cell bounce plus walk-away cell drawn 38 px below the rig ground point where `RigCastShadows` sits |
| 2 | patrol cop run S | travel 22 px (69 cm), sole lift max 35 px, gap max 36 px (112 cm), shadow y range 1 px | drawn cell bounce (cop lean/stretch, `street_patrol_pose.gd`): body leaves the ground, shadow fixed at the rig ground point |
| 3 | contractor walk S | travel 29 px (91 cm), sole lift max 29.5 px, gap max 30 px (94 cm) | drawn cell bounce (card frames); shadow fixed |
| 4 | rocket trooper walk N | planted gap 26.5 px (83 cm), travel 19 px, partial shadow | placement path: walk-away cell sits below the ground point, shadow at the ground point |
| 5 | riot cop walk S | travel 23 px (72 cm, 32 %), sole lift max 26.7 px, gap max 27.5 px | drawn cell bounce, shadow fixed (robot thug SE, planted gap 14 px, is the worst pure placement path) |

## Table (all 96 rows; px are screen px at 32.0 px/m, cm = px / 32 x 100)

| run | gait | dir | m/s | frames | measured | planted | phase cover | body height px | head travel px | travel cm | travel % of height | sole lift planted px | sole lift max px | shadow | gap planted max | gap planted mean | gap all max | gap all max cm | shadow y range | shadow below ground px | corr shadow/head |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| contractor_32 | walk | E | 3.0 | 48 | 48 | 37 | 1.0 | 52.0 | 3.0 | 9.4 | 5.8 | -1.19 | 1.0 | yes | 2.5 | 1.62 | 2.5 | 7.8 | 3.5 | 2.46 | 0.572 |
| contractor_32 | walk | SE | 3.0 | 48 | 48 | 3 | 1.0 | 61.0 | 14.0 | 43.8 | 23.0 | 1.0 | 20.06 | yes | 3.0 | 2.33 | 21.0 | 65.6 | 1.0 | 0.85 | 0.139 |
| contractor_32 | walk | S | 3.0 | 48 | 48 | 1 | 1.0 | 83.0 | 29.0 | 90.6 | 34.9 | -6.08 | 29.5 | yes | 5.0 | 5.0 | 30.0 | 93.8 | 4.5 | 0.89 | 0.326 |
| contractor_32 | walk | SW | 3.0 | 48 | 48 | 2 | 1.0 | 56.0 | 18.0 | 56.2 | 32.1 | -9.79 | 12.26 | yes | 7.0 | 6.75 | 13.0 | 40.6 | 3.5 | 1.25 | 0.649 |
| contractor_32 | walk | W | 3.0 | 48 | 48 | 2 | 1.0 | 52.0 | 15.0 | 46.9 | 28.8 | -14.0 | 1.0 | partial | 13.5 | 13.5 | 13.5 | 42.2 | 6.0 | 2.12 | 0.009 |
| contractor_32 | walk | NW | 3.0 | 48 | 48 | 1 | 1.0 | 57.0 | 20.0 | 62.5 | 35.1 | -28.06 | -3.13 | partial | 25.5 | 25.25 | 25.5 | 79.7 | 4.5 | 1.44 | 0.707 |
| contractor_32 | walk | N | 3.0 | 48 | 48 | 2 | 1.0 | 61.0 | 29.0 | 90.6 | 47.5 | -38.29 | -2.92 | partial | 25.5 | 24.75 | 25.5 | 79.7 | 4.0 | 1.7 | 0.203 |
| contractor_32 | walk | NE | 3.0 | 48 | 48 | 3 | 1.0 | 57.0 | 22.0 | 68.8 | 38.6 | -23.68 | 1.39 | partial | 22.5 | 21.17 | 22.5 | 70.3 | 5.0 | 1.17 | 0.214 |
| patrol_cop_32 | run | E | 6.0 | 48 | 48 | 36 | 1.0 | 56.0 | 5.0 | 15.6 | 8.9 | -2.56 | 3.0 | yes | 2.5 | 1.5 | 4.0 | 12.5 | 4.0 | 1.5 | -0.468 |
| patrol_cop_32 | run | SE | 6.0 | 48 | 48 | 3 | 1.0 | 63.0 | 15.0 | 46.9 | 23.8 | -1.46 | 22.62 | yes | 2.5 | 1.67 | 23.5 | 73.4 | 3.5 | 1.0 | 0.229 |
| patrol_cop_32 | run | S | 6.0 | 48 | 48 | 3 | 1.0 | 63.0 | 22.0 | 68.8 | 34.9 | 1.34 | 34.98 | yes | 3.0 | 2.33 | 36.0 | 112.5 | 1.0 | 1.0 | -0.299 |
| patrol_cop_32 | run | SW | 6.0 | 48 | 48 | 3 | 1.0 | 63.0 | 15.0 | 46.9 | 23.8 | -1.46 | 22.62 | yes | 1.0 | 0.5 | 23.5 | 73.4 | 1.5 | 0.85 | 0.204 |
| patrol_cop_32 | run | W | 6.0 | 48 | 48 | 36 | 1.0 | 56.0 | 5.0 | 15.6 | 8.9 | -2.56 | 3.0 | yes | 2.5 | 1.58 | 4.0 | 12.5 | 4.5 | 1.68 | -0.514 |
| patrol_cop_32 | run | NW | 6.0 | 48 | 48 | 3 | 1.0 | 63.0 | 16.0 | 50.0 | 25.4 | -25.25 | -1.15 | yes | 25.0 | 24.5 | 25.0 | 78.1 | 2.5 | 1.15 | 0.081 |
| patrol_cop_32 | run | N | 6.0 | 48 | 48 | 2 | 1.0 | 66.0 | 24.0 | 75.0 | 36.4 | -37.92 | -4.12 | partial | 25.0 | 25.0 | 25.0 | 78.1 | 4.5 | 2.14 | 0.006 |
| patrol_cop_32 | run | NE | 6.0 | 48 | 48 | 3 | 1.0 | 63.0 | 16.0 | 50.0 | 25.4 | -25.25 | -1.15 | yes | 25.0 | 24.67 | 25.0 | 78.1 | 2.5 | 1.06 | 0.002 |
| patrol_cop_32 | walk | E | 3.2 | 48 | 48 | 10 | 1.0 | 51.0 | 8.0 | 25.0 | 15.7 | -7.6 | 0.0 | partial | 9.5 | 7.3 | 9.5 | 29.7 | 5.5 | 1.58 | -0.354 |
| patrol_cop_32 | walk | SE | 3.2 | 48 | 48 | 2 | 1.0 | 53.0 | 10.0 | 31.2 | 18.9 | -3.33 | 11.05 | yes | 1.5 | 1.0 | 12.0 | 37.5 | 3.0 | 0.85 | 0.11 |
| patrol_cop_32 | walk | S | 3.2 | 48 | 48 | 4 | 1.0 | 53.0 | 10.0 | 31.2 | 18.9 | 0.06 | 14.72 | yes | 2.0 | 1.38 | 15.5 | 48.4 | 2.0 | 0.88 | 0.146 |
| patrol_cop_32 | walk | SW | 3.2 | 48 | 48 | 2 | 1.0 | 53.0 | 10.0 | 31.2 | 18.9 | -3.33 | 11.05 | yes | 1.5 | 1.25 | 12.0 | 37.5 | 4.0 | 1.03 | 0.172 |
| patrol_cop_32 | walk | W | 3.2 | 48 | 48 | 10 | 1.0 | 51.0 | 8.0 | 25.0 | 15.7 | -7.6 | 0.0 | partial | 8.0 | 5.58 | 8.5 | 26.6 | 6.0 | 1.94 | -0.123 |
| patrol_cop_32 | walk | NW | 3.2 | 48 | 48 | 5 | 1.0 | 53.0 | 11.0 | 34.4 | 20.8 | -8.87 | 4.01 | yes | 8.0 | 6.77 | 8.0 | 25.0 | 3.5 | 1.43 | 0.338 |
| patrol_cop_32 | walk | N | 3.2 | 48 | 48 | 2 | 1.0 | 57.0 | 21.0 | 65.6 | 36.8 | -33.88 | -9.13 | partial | 22.0 | 22.0 | 22.0 | 68.8 | 2.25 | 1.23 | -0.328 |
| patrol_cop_32 | walk | NE | 3.2 | 48 | 48 | 5 | 1.0 | 53.0 | 11.0 | 34.4 | 20.8 | -8.87 | 4.01 | yes | 8.0 | 6.9 | 8.0 | 25.0 | 4.5 | 1.42 | 0.203 |
| riot_cop_32 | walk | E | 2.8 | 48 | 48 | 5 | 1.0 | 54.0 | 5.0 | 15.6 | 9.3 | -5.0 | 0.0 | yes | 2.0 | 1.8 | 2.5 | 7.8 | 2.5 | 2.41 | 0.43 |
| riot_cop_32 | walk | SE | 2.8 | 48 | 48 | 5 | 1.0 | 55.0 | 8.0 | 25.0 | 14.5 | -8.97 | 3.93 | yes | 7.5 | 6.9 | 7.5 | 23.4 | 2.5 | 1.48 | 0.383 |
| riot_cop_32 | walk | S | 2.8 | 48 | 48 | 1 | 1.0 | 73.0 | 23.0 | 71.9 | 31.5 | -4.28 | 26.65 | yes | 3.5 | 3.5 | 27.5 | 85.9 | 1.0 | 0.85 | 0.097 |
| riot_cop_32 | walk | SW | 2.8 | 48 | 48 | 5 | 1.0 | 55.0 | 8.0 | 25.0 | 14.5 | -8.97 | 3.93 | yes | 8.0 | 7.1 | 8.0 | 25.0 | 5.0 | 1.81 | 0.143 |
| riot_cop_32 | walk | W | 2.8 | 48 | 48 | 5 | 1.0 | 54.0 | 5.0 | 15.6 | 9.3 | -5.0 | 0.0 | yes | 2.0 | 1.9 | 2.5 | 7.8 | 2.5 | 2.29 | 0.18 |
| riot_cop_32 | walk | NW | 2.8 | 48 | 48 | 2 | 1.0 | 57.0 | 15.0 | 46.9 | 26.3 | -23.4 | -3.18 | partial | 18.5 | 18.5 | 18.5 | 57.8 | 5.0 | 1.02 | -0.138 |
| riot_cop_32 | walk | N | 2.8 | 48 | 48 | 3 | 1.0 | 63.0 | 20.0 | 62.5 | 31.7 | -31.96 | -6.72 | partial | 13.0 | 12.17 | 13.0 | 40.6 | 4.5 | 1.99 | 0.55 |
| riot_cop_32 | walk | NE | 2.8 | 48 | 48 | 2 | 1.0 | 58.0 | 17.0 | 53.1 | 29.3 | -22.4 | -0.18 | partial | 20.5 | 19.75 | 20.5 | 64.1 | 5.5 | 2.18 | -0.352 |
| robot_gunner_32 | walk | E | 2.2 | 48 | 48 | 48 | 1.0 | 55.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | yes | 2.5 | 2.5 | 2.5 | 7.8 | 0.0 | 2.5 | None |
| robot_gunner_32 | walk | SE | 2.2 | 48 | 48 | 47 | 1.0 | 60.0 | 16.0 | 50.0 | 26.7 | -0.43 | 10.07 | yes | 2.0 | 1.46 | 2.0 | 6.2 | 13.0 | 1.64 | 0.978 |
| robot_gunner_32 | walk | S | 2.2 | 48 | 48 | 47 | 1.0 | 57.0 | 26.0 | 81.2 | 45.6 | -0.28 | 24.64 | yes | 1.5 | 0.71 | 2.5 | 7.8 | 22.0 | -0.88 | 0.999 |
| robot_gunner_32 | walk | SW | 2.2 | 48 | 48 | 47 | 1.0 | 60.0 | 16.0 | 50.0 | 26.7 | -0.43 | 10.07 | yes | 2.0 | 1.46 | 2.0 | 6.2 | 13.0 | 1.64 | 0.978 |
| robot_gunner_32 | walk | W | 2.2 | 48 | 48 | 48 | 1.0 | 55.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | yes | 2.5 | 2.5 | 2.5 | 7.8 | 0.0 | 2.5 | None |
| robot_gunner_32 | walk | NW | 2.2 | 48 | 48 | 1 | 1.0 | 57.0 | 20.0 | 62.5 | 35.1 | -19.07 | -0.64 | yes | 1.0 | 1.0 | 1.0 | 3.1 | 21.0 | 0.72 | 0.995 |
| robot_gunner_32 | walk | N | 2.2 | 48 | 48 | 1 | 1.0 | 59.0 | 26.0 | 81.2 | 44.1 | -25.64 | 0.21 | yes | 2.5 | 2.5 | 2.5 | 7.8 | 26.0 | 3.3 | 0.995 |
| robot_gunner_32 | walk | NE | 2.2 | 48 | 48 | 1 | 1.0 | 57.0 | 20.0 | 62.5 | 35.1 | -19.07 | -0.64 | yes | 1.0 | 1.0 | 1.0 | 3.1 | 21.0 | 0.72 | 0.995 |
| robot_thug_32 | walk | E | 2.4 | 48 | 48 | 1 | 1.0 | 75.0 | 4.0 | 12.5 | 5.3 | -7.0 | 0.0 | yes | 6.0 | 6.0 | 6.0 | 18.8 | 2.0 | 2.59 | -0.733 |
| robot_thug_32 | walk | SE | 2.4 | 48 | 48 | 48 | 1.0 | 72.0 | 1.0 | 3.1 | 1.4 | -14.35 | -13.85 | yes | 14.0 | 13.11 | 14.0 | 43.8 | 2.5 | 1.23 | 0.326 |
| robot_thug_32 | walk | S | 2.4 | 48 | 48 | 47 | 1.0 | 72.0 | 6.0 | 18.8 | 8.3 | -11.27 | -3.66 | yes | 11.0 | 10.71 | 11.0 | 34.4 | 1.0 | 0.57 | -0.101 |
| robot_thug_32 | walk | SW | 2.4 | 48 | 48 | 48 | 1.0 | 72.0 | 1.0 | 3.1 | 1.4 | -14.35 | -13.85 | yes | 14.0 | 13.11 | 14.0 | 43.8 | 2.5 | 1.23 | 0.326 |
| robot_thug_32 | walk | W | 2.4 | 48 | 48 | 1 | 1.0 | 75.0 | 4.0 | 12.5 | 5.3 | -7.0 | 0.0 | yes | 6.0 | 6.0 | 6.0 | 18.8 | 2.0 | 2.59 | -0.733 |
| robot_thug_32 | walk | NW | 2.4 | 48 | 48 | 48 | 1.0 | 76.0 | 5.0 | 15.6 | 6.6 | -0.36 | 0.14 | yes | 1.0 | 0.36 | 1.0 | 3.1 | 1.0 | -0.0 | 0.404 |
| robot_thug_32 | walk | N | 2.4 | 48 | 48 | 48 | 1.0 | 79.0 | 3.0 | 9.4 | 3.8 | -0.37 | 0.15 | yes | 2.5 | 2.42 | 2.5 | 7.8 | 1.0 | 2.79 | 0.643 |
| robot_thug_32 | walk | NE | 2.4 | 48 | 48 | 48 | 1.0 | 76.0 | 5.0 | 15.6 | 6.6 | -0.36 | 0.14 | yes | 1.0 | 0.36 | 1.0 | 3.1 | 1.0 | -0.0 | 0.404 |
| rocket_trooper_32 | walk | E | 3.2 | 48 | 48 | 3 | 1.0 | 52.0 | 6.0 | 18.8 | 11.5 | -6.33 | 0.0 | yes | 3.5 | 3.17 | 3.5 | 10.9 | 3.0 | 2.28 | 0.182 |
| rocket_trooper_32 | walk | SE | 3.2 | 48 | 48 | 2 | 1.0 | 63.0 | 11.0 | 34.4 | 17.5 | -18.97 | 4.46 | yes | 17.5 | 16.75 | 17.5 | 54.7 | 5.0 | 1.61 | 0.772 |
| rocket_trooper_32 | walk | S | 3.2 | 48 | 48 | 3 | 1.0 | 69.0 | 18.0 | 56.2 | 26.1 | 1.2 | 25.06 | yes | 2.5 | 2.17 | 26.0 | 81.2 | 1.0 | 0.84 | 0.002 |
| rocket_trooper_32 | walk | SW | 3.2 | 48 | 48 | 2 | 1.0 | 62.0 | 12.0 | 37.5 | 19.4 | -18.97 | 4.46 | yes | 18.0 | 17.25 | 18.0 | 56.2 | 6.0 | 1.72 | 0.643 |
| rocket_trooper_32 | walk | W | 3.2 | 48 | 48 | 3 | 1.0 | 52.0 | 6.0 | 18.8 | 11.5 | -6.33 | 0.0 | yes | 4.0 | 3.33 | 4.0 | 12.5 | 4.0 | 2.26 | 0.16 |
| rocket_trooper_32 | walk | NW | 3.2 | 48 | 48 | 1 | 1.0 | 52.0 | 15.0 | 46.9 | 28.8 | -22.01 | -3.99 | partial | 17.0 | 15.75 | 17.0 | 53.1 | 3.0 | 0.38 | 0.401 |
| rocket_trooper_32 | walk | N | 3.2 | 48 | 48 | 1 | 1.0 | 57.0 | 19.0 | 59.4 | 33.3 | -32.06 | -7.94 | partial | 26.5 | 26.5 | 26.5 | 82.8 | 1.5 | 1.3 | -0.291 |
| rocket_trooper_32 | walk | NE | 3.2 | 48 | 48 | 1 | 1.0 | 52.0 | 15.0 | 46.9 | 28.8 | -22.01 | -1.99 | partial | 20.0 | 19.25 | 20.0 | 62.5 | 6.33 | 1.89 | -0.332 |
| sentry_turret_32 | walk | E | 0.0 | 48 | 48 | 48 | 0.1 | 53.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | SE | 0.0 | 48 | 48 | 48 | 0.1 | 53.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | S | 0.0 | 48 | 48 | 48 | 0.1 | 56.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | SW | 0.0 | 48 | 48 | 48 | 0.1 | 53.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | W | 0.0 | 48 | 48 | 48 | 0.1 | 53.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | NW | 0.0 | 48 | 48 | 48 | 0.1 | 52.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | N | 0.0 | 48 | 48 | 48 | 0.1 | 56.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| sentry_turret_32 | walk | NE | 0.0 | 48 | 48 | 48 | 0.1 | 52.0 | 0.0 | 0.0 | 0.0 | -25.0 | -25.0 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | E | 1.6 | 48 | 48 | 48 | 0.8 | 54.0 | 0.0 | 0.0 | 0.0 | -8.0 | -8.0 | partial | 14.5 | 11.76 | 14.5 | 45.3 | 4.0 | -3.76 | None |
| shield_robot_32 | walk | SE | 1.6 | 48 | 48 | 48 | 0.7 | 57.0 | 1.0 | 3.1 | 1.8 | -8.13 | -7.64 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | S | 1.6 | 48 | 48 | 48 | 0.8 | 63.0 | 1.0 | 3.1 | 1.6 | -8.24 | -7.77 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | SW | 1.6 | 48 | 48 | 48 | 0.7 | 57.0 | 1.0 | 3.1 | 1.8 | -8.13 | -7.64 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | W | 1.6 | 48 | 48 | 48 | 0.8 | 54.0 | 0.0 | 0.0 | 0.0 | -8.0 | -8.0 | partial | 14.5 | 11.76 | 14.5 | 45.3 | 4.0 | -3.76 | None |
| shield_robot_32 | walk | NW | 1.6 | 48 | 48 | 48 | 0.8 | 58.0 | 1.0 | 3.1 | 1.7 | -8.28 | -7.79 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | N | 1.6 | 48 | 48 | 48 | 0.7 | 65.0 | 1.0 | 3.1 | 1.5 | -8.3 | -7.8 | none | - | - | - | - | - | - | - |
| shield_robot_32 | walk | NE | 1.6 | 48 | 48 | 48 | 0.8 | 58.0 | 1.0 | 3.1 | 1.7 | -8.28 | -7.79 | none | - | - | - | - | - | - | - |
| swat_32 | run | E | 6.0 | 48 | 48 | 39 | 1.0 | 49.0 | 3.0 | 9.4 | 6.1 | 0.0 | 4.0 | yes | 2.5 | 1.72 | 5.0 | 15.6 | 2.0 | 1.56 | -0.306 |
| swat_32 | run | SE | 6.0 | 48 | 48 | 2 | 1.0 | 55.0 | 16.0 | 50.0 | 29.1 | -8.31 | 21.36 | yes | 6.5 | 6.5 | 22.5 | 70.3 | 2.5 | 1.09 | 0.618 |
| swat_32 | run | S | 6.0 | 48 | 48 | 1 | 1.0 | 59.0 | 27.0 | 84.4 | 45.8 | -15.06 | 25.17 | yes | 13.5 | 13.5 | 26.0 | 81.2 | 3.5 | 1.34 | 0.556 |
| swat_32 | run | SW | 6.0 | 48 | 48 | 1 | 1.0 | 56.0 | 15.0 | 46.9 | 26.8 | -16.01 | 12.03 | yes | 13.0 | 13.0 | 13.0 | 40.6 | 4.5 | 1.39 | 0.311 |
| swat_32 | run | W | 6.0 | 48 | 48 | 11 | 1.0 | 49.0 | 13.0 | 40.6 | 26.5 | -12.0 | -1.0 | partial | 10.5 | 8.58 | 10.5 | 32.8 | 5.0 | 2.05 | 0.497 |
| swat_32 | run | NW | 6.0 | 48 | 48 | 3 | 1.0 | 56.0 | 19.0 | 59.4 | 33.9 | -28.01 | 0.61 | partial | 27.5 | 26.75 | 27.5 | 85.9 | 3.0 | 0.77 | 0.032 |
| swat_32 | run | N | 6.0 | 48 | 48 | 2 | 1.0 | 59.0 | 27.0 | 84.4 | 45.8 | -38.6 | 1.06 | partial | 38.5 | 38.5 | 38.5 | 120.3 | 4.0 | 1.51 | -0.258 |
| swat_32 | run | NE | 6.0 | 48 | 48 | 2 | 1.0 | 56.0 | 19.0 | 59.4 | 33.9 | -22.83 | 5.01 | partial | 22.0 | 22.0 | 22.0 | 68.8 | 6.5 | 1.98 | -0.009 |
| swat_32 | walk | E | 3.4 | 48 | 48 | 48 | 1.0 | 49.0 | 1.0 | 3.1 | 2.0 | -0.08 | 0.0 | yes | 2.5 | 2.2 | 2.5 | 7.8 | 3.0 | 2.28 | 0.206 |
| swat_32 | walk | SE | 3.4 | 48 | 48 | 4 | 1.0 | 55.0 | 11.0 | 34.4 | 20.0 | -10.01 | 4.93 | yes | 8.5 | 7.75 | 8.5 | 26.6 | 4.5 | 1.48 | 0.523 |
| swat_32 | walk | S | 3.4 | 48 | 48 | 3 | 1.0 | 72.0 | 21.0 | 65.6 | 29.2 | -0.74 | 27.22 | yes | 1.0 | 0.33 | 28.0 | 87.5 | 1.0 | 0.84 | -0.088 |
| swat_32 | walk | SW | 3.4 | 48 | 48 | 4 | 1.0 | 55.0 | 11.0 | 34.4 | 20.0 | -10.01 | 4.93 | yes | 9.0 | 8.0 | 9.0 | 28.1 | 4.5 | 1.78 | 0.269 |
| swat_32 | walk | W | 3.4 | 48 | 48 | 48 | 1.0 | 49.0 | 1.0 | 3.1 | 2.0 | -0.08 | 0.0 | yes | 2.5 | 2.31 | 2.5 | 7.8 | 2.5 | 2.4 | -0.047 |
| swat_32 | walk | NW | 3.4 | 48 | 48 | 2 | 1.0 | 57.0 | 20.0 | 62.5 | 35.1 | -24.11 | -1.95 | partial | 23.5 | 22.75 | 23.5 | 73.4 | 6.5 | 1.2 | -0.238 |
| swat_32 | walk | N | 3.4 | 48 | 48 | 2 | 1.0 | 60.0 | 21.0 | 65.6 | 35.0 | -34.71 | -6.9 | partial | 7.5 | 7.0 | 7.5 | 23.4 | 1.0 | 3.75 | -0.457 |
| swat_32 | walk | NE | 3.4 | 48 | 48 | 2 | 1.0 | 57.0 | 20.0 | 62.5 | 35.1 | -24.11 | -1.95 | partial | 24.5 | 24.0 | 24.5 | 76.6 | 6.0 | 1.29 | -0.204 |
| war_machine_32 | walk | E | 1.8 | 48 | 48 | 48 | 0.9 | 65.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | yes | 3.0 | 2.75 | 3.0 | 9.4 | 0.5 | 2.75 | None |
| war_machine_32 | walk | SE | 1.8 | 48 | 48 | 48 | 0.9 | 67.0 | 1.0 | 3.1 | 1.5 | 0.55 | 1.03 | yes | 1.5 | 0.76 | 1.5 | 4.7 | 2.0 | 0.17 | 0.305 |
| war_machine_32 | walk | S | 1.8 | 48 | 48 | 48 | 0.9 | 68.0 | 1.0 | 3.1 | 1.5 | 0.93 | 1.41 | yes | 1.5 | 0.39 | 1.5 | 4.7 | 1.5 | -0.79 | 0.614 |
| war_machine_32 | walk | SW | 1.8 | 48 | 48 | 48 | 0.9 | 67.0 | 1.0 | 3.1 | 1.5 | 0.55 | 1.03 | yes | 1.5 | 0.68 | 1.5 | 4.7 | 1.5 | 0.13 | 0.161 |
| war_machine_32 | walk | W | 1.8 | 48 | 48 | 48 | 0.9 | 65.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | yes | 3.0 | 2.75 | 3.0 | 9.4 | 0.5 | 2.75 | None |
| war_machine_32 | walk | NW | 1.8 | 48 | 48 | 48 | 0.9 | 65.0 | 1.0 | 3.1 | 1.5 | -0.51 | -0.02 | yes | 3.0 | 2.7 | 3.0 | 9.4 | 1.5 | 3.2 | 0.188 |
| war_machine_32 | walk | N | 1.8 | 48 | 48 | 48 | 0.8 | 64.0 | 0.0 | 0.0 | 0.0 | 1.63 | 2.12 | yes | 3.0 | 2.43 | 3.0 | 9.4 | 1.5 | 0.79 | None |
| war_machine_32 | walk | NE | 1.8 | 48 | 48 | 48 | 0.8 | 65.0 | 1.0 | 3.1 | 1.5 | -0.51 | -0.02 | yes | 3.0 | 2.7 | 3.0 | 9.4 | 1.5 | 3.2 | 0.188 |
