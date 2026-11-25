# Rivet lift before (n31-01, base `ba8e470b0`, tree unchanged)

Measured from delivered frames by `tools/ground/lift/lift.py` on captures of
`project/dev/ground_n31/lift_probe.gd` (`node tools/ground/lift/capture.mjs`): the real arena,
pilot and camera, Rivet touring the 8 octants, 80 consecutive ticks per direction (ticks 40-119
of 120, phase cover 1.0 = every tenth of the stride cycle seen), each tick rendered full, without
the drop shadows and without Rivet. Body = pixels where Rivet-hidden differs; shadow = pixels the
shadow darkens. Crop px = screen px. JSON: `lift_before.json` (`gtai.ground-lift/1`).

- **Scale**: the arena camera draws at **32.0 screen px/m** (measured from the sim, every row), the
  owner's play scale; NOT 64 px/m. Double the px for 64 px/m. cm = px / 32 x 100.
- **Gaits**: `move` = full stick without sprint (the keyboard move, 6.7 m/s; the arena has no
  slower walk at full input), `sprint` = 9.3 m/s. Both draw the run grid: rows are identical.
- **Columns**: helmet travel = max - min helmet-top y over the 80 ticks; sole lift = ground point
  y (sim) - lowest drawn sole y (> 0 = feet above the ground line); planted = sole within 1 px of
  its lowest; shadow-sole gap = |shadow centre y - lowest sole y|; shadow y range vs helmet travel
  and their correlation show whether the shadow follows the body; card lift (code) = the card's
  offset above the rig (RivetBob.up), logged per tick; code vs frame = |code ellipse centre -
  measured centre|, the cross-check.
- **p55** draws the long cast figure (cast_k >= 0.6), not the contact ellipse: its shadow columns
  (centre, gap, rx/ry, code vs frame) fit an ellipse to a cropped long shadow and are NOT
  comparable; only travel and sole lift are valid there.

## Read

- Sole lift max equals the code's card lift max in every p70 row (within 0.63 px): the feet
  leave the ground only by `RivetBob.up` (rivet_frames.gd L146, the part of the take-back past
  `stretch_cell`). Planted soles sit on the ground line (lift planted 0.0-0.37 px).
- The contact ellipse stays at the rig ground point: shadow y range 0-2 px while the helmet
  travels 4-8 px (12.5-25 cm); correlation weak or none. Planted, the ellipse centre is 1.4-2.2 px
  from the sole (it sits on it); on lift frames the gap opens to 8.5-9.5 px (27-30 cm) facing N.
- Helmet travel without any lift (E: card lift 0) is still 4 px (12.5 cm): the drawn grid bob
  left after damp_run 0.75.
- Worst p70 rows (sole lift max / gap all max / card lift max / helmet travel, px at 32 px/m):
  1. pistol move+sprint N: 8.0 / 9.5 / 8.63 / 7 -> RivetBob.up lift on the N run row's flight frames, shadow at ground point.
  2. hands move+sprint N: 7.0 / 8.5 / 7.11 / 7-8 -> same.
  3. hands move SW and NE (and pistol NE): 5.0 / 6.5 / 5.08 / 6-8 -> same; SW also the largest drawn bob (8 px).

## Table

| run | gait | dir | m/s | frames | measured | planted | phase cover | helmet travel px | travel cm | sole lift planted px | sole lift max px | shadow-sole gap planted max | gap planted mean | gap all max | shadow y range | corr shadow/helmet | shadow rx | shadow ry | card lift max px (code) | code vs frame shadow y |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| p70_hands | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.66 | 2.0 | 0.5 | -0.062 | 19.5 | 11.3 | 0.0 | 0.35 |
| p70_hands | move | SE | 6.8 | 80 | 80 | 61 | 1.0 | 7.0 | 21.9 | -0.0 | 2.0 | 1.5 | 1.42 | 3.5 | 1.5 | 0.199 | 18.2 | 10.7 | 2.54 | 0.21 |
| p70_hands | move | S | 6.7 | 80 | 80 | 42 | 1.0 | 7.0 | 21.9 | 0.09 | 3.0 | 2.5 | 1.6 | 4.5 | 1.0 | 0.2 | 19.5 | 11.5 | 3.55 | 0.18 |
| p70_hands | move | SW | 6.8 | 80 | 80 | 59 | 1.0 | 8.0 | 25.0 | -0.0 | 5.0 | 2.5 | 2.16 | 6.5 | 2.0 | -0.544 | 19.5 | 11.0 | 5.08 | 0.67 |
| p70_hands | move | W | 6.7 | 80 | 80 | 72 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.67 | 3.5 | 1.0 | 0.202 | 19.5 | 11.3 | 2.03 | 0.34 |
| p70_hands | move | NW | 6.8 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.03 | 1.0 | 3.0 | 1.67 | 3.0 | 2.0 | 0.607 | 19.5 | 11.3 | 1.02 | 0.37 |
| p70_hands | move | N | 6.7 | 80 | 80 | 44 | 1.0 | 8.0 | 25.0 | 0.07 | 7.0 | 2.5 | 1.57 | 8.5 | 1.0 | 0.13 | 19.5 | 11.5 | 7.11 | 0.18 |
| p70_hands | move | NE | 6.8 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | -0.0 | 5.0 | 2.5 | 1.7 | 6.5 | 2.0 | -0.072 | 19.5 | 11.3 | 5.08 | 0.34 |
| p70_hands | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.009 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_hands | sprint | SE | 9.3 | 80 | 80 | 59 | 1.0 | 6.0 | 18.8 | 0.0 | 2.0 | 1.5 | 1.42 | 3.5 | 0.5 | 0.259 | 18.3 | 10.8 | 2.54 | 0.21 |
| p70_hands | sprint | S | 9.3 | 80 | 80 | 56 | 1.0 | 6.0 | 18.8 | 0.34 | 3.0 | 2.5 | 1.84 | 4.5 | 0.0 | None | 19.5 | 11.5 | 3.55 | 0.18 |
| p70_hands | sprint | SW | 9.3 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | 0.0 | 5.0 | 2.5 | 2.13 | 6.5 | 1.0 | -0.843 | 19.5 | 11.0 | 5.08 | 0.67 |
| p70_hands | sprint | W | 9.3 | 80 | 80 | 70 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.76 | 3.5 | 1.0 | 0.187 | 19.5 | 11.3 | 2.03 | 0.41 |
| p70_hands | sprint | NW | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.1 | 1.0 | 3.0 | 1.79 | 3.0 | 1.0 | 0.664 | 19.5 | 11.3 | 1.02 | 0.37 |
| p70_hands | sprint | N | 9.3 | 80 | 80 | 52 | 1.0 | 7.0 | 21.9 | 0.19 | 7.0 | 2.5 | 1.69 | 8.5 | 0.0 | None | 19.5 | 11.5 | 7.11 | 0.18 |
| p70_hands | sprint | NE | 9.3 | 80 | 80 | 61 | 1.0 | 5.0 | 15.6 | 0.0 | 5.0 | 2.5 | 1.75 | 6.5 | 1.0 | -0.379 | 19.5 | 11.3 | 5.08 | 0.38 |
| p70_pistol | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | -0.149 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_pistol | move | SE | 6.8 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | -0.0 | 2.0 | 1.5 | 1.39 | 3.5 | 1.5 | 0.378 | 17.7 | 10.4 | 2.54 | 0.22 |
| p70_pistol | move | S | 6.7 | 80 | 80 | 41 | 1.0 | 7.0 | 21.9 | 0.1 | 4.0 | 2.5 | 1.6 | 5.5 | 1.0 | 0.183 | 19.5 | 11.5 | 4.57 | 0.18 |
| p70_pistol | move | SW | 6.8 | 80 | 80 | 61 | 1.0 | 7.0 | 21.9 | -0.0 | 4.0 | 2.5 | 2.14 | 5.5 | 2.0 | -0.448 | 19.5 | 11.0 | 4.57 | 0.67 |
| p70_pistol | move | W | 6.7 | 80 | 80 | 67 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.0 | 1.64 | 3.5 | 0.5 | 0.214 | 19.5 | 11.4 | 2.03 | 0.3 |
| p70_pistol | move | NW | 6.8 | 80 | 80 | 59 | 1.0 | 6.0 | 18.8 | -0.0 | 2.0 | 2.5 | 1.86 | 3.5 | 2.0 | -0.523 | 19.5 | 11.2 | 2.03 | 0.45 |
| p70_pistol | move | N | 6.7 | 80 | 80 | 47 | 1.0 | 7.0 | 21.9 | 0.13 | 8.0 | 2.5 | 1.63 | 9.5 | 1.0 | 0.183 | 19.5 | 11.5 | 8.63 | 0.18 |
| p70_pistol | move | NE | 6.8 | 80 | 80 | 59 | 1.0 | 7.0 | 21.9 | 0.02 | 5.0 | 2.5 | 1.72 | 6.5 | 2.0 | -0.207 | 19.5 | 11.3 | 5.08 | 0.33 |
| p70_pistol | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.009 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_pistol | sprint | SE | 9.3 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | 0.0 | 2.0 | 1.5 | 1.43 | 3.5 | 0.5 | 0.386 | 18.3 | 10.8 | 2.54 | 0.21 |
| p70_pistol | sprint | S | 9.3 | 80 | 80 | 57 | 1.0 | 6.0 | 18.8 | 0.33 | 4.0 | 2.5 | 1.83 | 5.5 | 0.0 | None | 19.5 | 11.5 | 4.57 | 0.18 |
| p70_pistol | sprint | SW | 9.3 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | 0.0 | 4.0 | 2.5 | 2.14 | 5.5 | 1.0 | -0.767 | 19.5 | 11.0 | 4.57 | 0.67 |
| p70_pistol | sprint | W | 9.3 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.0 | 1.63 | 3.5 | 0.5 | 0.349 | 19.5 | 11.4 | 2.03 | 0.3 |
| p70_pistol | sprint | NW | 9.3 | 80 | 80 | 59 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.82 | 3.5 | 1.0 | -0.888 | 19.5 | 11.3 | 2.03 | 0.42 |
| p70_pistol | sprint | N | 9.3 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | 0.37 | 8.0 | 2.5 | 1.87 | 9.5 | 0.0 | None | 19.5 | 11.5 | 8.63 | 0.18 |
| p70_pistol | sprint | NE | 9.3 | 80 | 80 | 71 | 1.0 | 6.0 | 18.8 | 0.14 | 5.0 | 2.5 | 1.98 | 6.5 | 1.0 | -0.584 | 19.5 | 11.2 | 5.08 | 0.48 |
| p55_hands | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 5.0 | 15.6 | 0.26 | 1.0 | 40.5 | 39.76 | 40.5 | 0.0 | None | 19.5 | 24.5 | 1.57 | 38.14 |
| p55_hands | sprint | SE | 9.3 | 80 | 80 | 60 | 1.0 | 6.0 | 18.8 | 0.0 | 3.0 | 39.5 | 36.7 | 42.5 | 21.0 | 0.208 | 18.4 | 23.2 | 3.66 | 36.12 |
| p55_hands | sprint | S | 9.3 | 80 | 80 | 58 | 1.0 | 6.0 | 18.8 | 0.0 | 3.0 | 39.5 | 39.5 | 42.5 | 0.0 | None | 19.5 | 24.5 | 3.66 | 38.14 |
| p55_hands | sprint | SW | 9.3 | 80 | 80 | 80 | 1.0 | 6.0 | 18.8 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.52 | 38.14 |
| p55_hands | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 5.0 | 15.6 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 |
| p55_hands | sprint | NW | 9.3 | 80 | 80 | 71 | 1.0 | 6.0 | 18.8 | 0.32 | 2.0 | 40.5 | 39.82 | 41.5 | 0.0 | None | 19.5 | 24.5 | 2.09 | 38.14 |
| p55_hands | sprint | N | 9.3 | 80 | 80 | 39 | 1.0 | 7.0 | 21.9 | 0.0 | 9.0 | 39.5 | 39.5 | 48.5 | 0.0 | None | 19.5 | 24.5 | 8.89 | 38.14 |
| p55_hands | sprint | NE | 9.3 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.17 | 2.0 | 40.5 | 39.67 | 41.5 | 0.0 | None | 19.5 | 24.5 | 2.62 | 38.14 |
