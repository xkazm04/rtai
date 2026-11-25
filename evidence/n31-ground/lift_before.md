# Rivet lift before (n31-01, base `ba8e470b0`; game code untouched)

Measured from delivered frames by `tools/ground/lift/lift.py` on captures of
`project/dev/ground_n31/lift_probe.gd` (`node tools/ground/lift/capture.mjs --ppm=64|32`): the real
arena, pilot and camera, Rivet touring the 8 octants, 80 consecutive ticks per direction (ticks
40-119 of 120; phase cover 1.0 = every tenth of the stride cycle seen), each tick rendered full,
without the drop shadows and without Rivet. Body = pixels where the Rivet-hidden render differs;
shadow = pixels the shadow darkens. Crop px = screen px. JSON: `lift_before.json`
(`gtai.ground-lift/1`, the same 80 rows). Check crops (3 per gait and run, lines drawn):
`build/n31/n31-01/check/` (not committed).

- **Scale**: rows `*_64` at 64.0 screen px/m (cm = px / 64 x 100); rows `*_32` at 32.0 px/m, the
  arena camera's default and the owner's play scale (cm = px / 32 x 100). Both measured per tick
  from the sim. The 32 rows are about half the 64 rows' px, as they should be.
- **Gaits**: `move` = full stick without sprint (the keyboard move, 6.7 m/s; there is no slower
  walk at full input), `sprint` = 9.3 m/s. Both draw the run grid, so their rows nearly match.
- **Columns**: helmet travel = max - min helmet-top y over the 80 ticks; sole lift = sim ground
  point y - lowest drawn sole y (> 0 = feet above the ground line); planted = sole within 1 px of
  its lowest; shadow-sole gap = |shadow centre y - lowest sole y|; shadow y range vs helmet travel
  and their correlation say whether the shadow follows the body; card lift (code) = the card's
  offset above the rig (`RivetBob.up`), logged per tick; code vs frame = |code contact-ellipse
  centre - measured centre|, the cross-check.
- **p55** draws the long cast figure (cast_k >= 0.6), not the contact ellipse: its shadow columns
  (centre, gap, rx/ry, code vs frame) fit an ellipse to a cropped long shadow and are NOT
  comparable; only helmet travel and sole lift are valid there.

## Read (p70, the owner's view)

- **Feet lift = RivetBob.up**: sole lift max equals the code's card lift max in every p70 row
  (within 0.26 px at 64, 0.63 px at 32). The feet leave the ground only through the card lift in
  `rivet_frames.gd` L146 (`RivetBob.up`: the take-back past `stretch_cell`, the run grid's flight
  frames). Planted soles sit on the ground line (lift planted 0.0 px at 64).
- **Shadow at the ground point**: shadow centre y range 0-2 px while the helmet travels 8-15 px
  (12.5-23.4 cm); correlation none or weak. Planted, the ellipse centre is 2.3-2.8 px below the
  sole (on it). On lift frames the gap opens to 19.5 px (30 cm) facing N with the pistol.
- **Drawn grid bob**: facing E the card never lifts (card lift 0) and the helmet still travels
  8-9 px (12.5-14.1 cm): the drawn run grid's bob left after damp_run 0.75 plus the stretch.
- **Worst p70 rows** at 64 px/m (sole lift max / gap all max / card lift max / helmet travel):
  1. pistol move + sprint N: 17 px (26.6 cm) / 19.5 / 17.25 / 14 px -> RivetBob.up lift on the N
     run row's flight frames; the shadow stays at the rig ground point.
  2. hands move + sprint N: 14 px (21.9 cm) / 16.5 / 14.21 / 15 px (23.4 cm, the most travel) ->
     same lift; plus the largest drawn bob.
  3. hands move + sprint SW and NE (pistol NE): 10 px (15.6 cm) / 12.5 / 10.15 / 12-13 px -> same.
  S (pistol 9 px, hands 7 px) and SE (5 px) lift too; E lifts 0 and W/NW 2-4 px.
- p55 sprint hands at 64: the same lift pattern (N 17 px = card 17.78, SE/S 7 px, E 3 px, W 0).

## Table

| run | gait | dir | m/s | frames | measured | planted | phase cover | helmet travel px | travel cm | sole lift planted px | sole lift max px | shadow-sole gap planted max | gap planted mean | gap all max | shadow y range | corr shadow/helmet | shadow rx | shadow ry | card lift max px (code) | code vs frame shadow y |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| p70_hands_64 | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 8.0 | 12.5 | 0.0 | 0.0 | 2.5 | 2.5 | 2.5 | 0.0 | None | 39.5 | 23.5 | 0.0 | 0.13 |
| p70_hands_64 | move | SE | 6.8 | 80 | 80 | 61 | 1.0 | 11.0 | 17.2 | 0.0 | 5.0 | 2.5 | 2.34 | 7.5 | 1.0 | 0.344 | 36.8 | 21.8 | 5.08 | 0.16 |
| p70_hands_64 | move | S | 6.7 | 80 | 80 | 38 | 1.0 | 11.0 | 17.2 | 0.0 | 7.0 | 2.5 | 2.5 | 9.5 | 0.0 | None | 39.5 | 23.5 | 7.11 | 0.13 |
| p70_hands_64 | move | SW | 6.8 | 80 | 80 | 59 | 1.0 | 13.0 | 20.3 | 0.0 | 10.0 | 3.0 | 2.83 | 12.5 | 0.5 | -0.817 | 39.5 | 23.3 | 10.15 | 0.25 |
| p70_hands_64 | move | W | 6.7 | 80 | 80 | 72 | 1.0 | 11.0 | 17.2 | 0.0 | 4.0 | 2.5 | 2.5 | 6.5 | 0.0 | None | 39.5 | 23.5 | 4.06 | 0.13 |
| p70_hands_64 | move | NW | 6.8 | 80 | 80 | 69 | 1.0 | 9.0 | 14.1 | 0.0 | 2.0 | 3.0 | 2.57 | 4.5 | 0.5 | 0.333 | 39.5 | 23.4 | 2.03 | 0.16 |
| p70_hands_64 | move | N | 6.7 | 80 | 80 | 41 | 1.0 | 15.0 | 23.4 | 0.0 | 14.0 | 2.5 | 2.5 | 16.5 | 0.0 | None | 39.5 | 23.5 | 14.21 | 0.13 |
| p70_hands_64 | move | NE | 6.8 | 80 | 80 | 61 | 1.0 | 12.0 | 18.8 | 0.0 | 10.0 | 3.0 | 2.55 | 12.5 | 0.5 | -0.178 | 39.5 | 23.5 | 10.15 | 0.15 |
| p70_hands_64 | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 8.0 | 12.5 | 0.0 | 0.0 | 2.5 | 2.5 | 2.5 | 0.0 | None | 39.5 | 23.5 | 0.0 | 0.13 |
| p70_hands_64 | sprint | SE | 9.3 | 80 | 80 | 59 | 1.0 | 11.0 | 17.2 | 0.0 | 5.0 | 2.5 | 2.35 | 7.5 | 2.0 | 0.305 | 37.0 | 21.9 | 5.08 | 0.15 |
| p70_hands_64 | sprint | S | 9.3 | 80 | 80 | 37 | 1.0 | 11.0 | 17.2 | 0.0 | 7.0 | 2.5 | 2.5 | 9.5 | 0.0 | None | 39.5 | 23.5 | 7.11 | 0.13 |
| p70_hands_64 | sprint | SW | 9.3 | 80 | 80 | 62 | 1.0 | 13.0 | 20.3 | 0.0 | 10.0 | 3.0 | 2.81 | 12.5 | 0.5 | -0.803 | 39.5 | 23.3 | 10.15 | 0.25 |
| p70_hands_64 | sprint | W | 9.3 | 80 | 80 | 70 | 1.0 | 11.0 | 17.2 | 0.0 | 4.0 | 2.5 | 2.5 | 6.5 | 0.0 | None | 39.5 | 23.5 | 4.06 | 0.13 |
| p70_hands_64 | sprint | NW | 9.3 | 80 | 80 | 72 | 1.0 | 9.0 | 14.1 | 0.0 | 2.0 | 3.0 | 2.58 | 4.5 | 0.5 | 0.387 | 39.5 | 23.4 | 2.03 | 0.16 |
| p70_hands_64 | sprint | N | 9.3 | 80 | 80 | 42 | 1.0 | 15.0 | 23.4 | 0.0 | 14.0 | 2.5 | 2.5 | 16.5 | 1.0 | 0.012 | 39.5 | 23.5 | 14.21 | 0.13 |
| p70_hands_64 | sprint | NE | 9.3 | 80 | 80 | 61 | 1.0 | 12.0 | 18.8 | 0.0 | 10.0 | 3.0 | 2.57 | 12.5 | 0.5 | -0.197 | 39.5 | 23.4 | 10.15 | 0.16 |
| p70_pistol_64 | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 9.0 | 14.1 | 0.0 | 0.0 | 2.5 | 2.5 | 2.5 | 0.0 | None | 39.5 | 23.5 | 0.0 | 0.13 |
| p70_pistol_64 | move | SE | 6.8 | 80 | 80 | 62 | 1.0 | 11.0 | 17.2 | 0.0 | 5.0 | 2.5 | 2.27 | 7.5 | 1.0 | 0.427 | 35.6 | 21.1 | 5.08 | 0.16 |
| p70_pistol_64 | move | S | 6.7 | 80 | 80 | 37 | 1.0 | 12.0 | 18.8 | 0.0 | 9.0 | 2.5 | 2.5 | 11.5 | 0.0 | None | 39.5 | 23.5 | 9.14 | 0.13 |
| p70_pistol_64 | move | SW | 6.8 | 80 | 80 | 61 | 1.0 | 11.0 | 17.2 | 0.0 | 9.0 | 3.0 | 2.82 | 11.5 | 0.5 | -0.815 | 39.5 | 23.3 | 9.14 | 0.25 |
| p70_pistol_64 | move | W | 6.7 | 80 | 80 | 67 | 1.0 | 10.0 | 15.6 | 0.0 | 4.0 | 2.5 | 2.5 | 6.5 | 0.0 | None | 39.5 | 23.5 | 4.06 | 0.13 |
| p70_pistol_64 | move | NW | 6.8 | 80 | 80 | 59 | 1.0 | 11.0 | 17.2 | 0.0 | 4.0 | 3.0 | 2.68 | 6.5 | 0.5 | -0.925 | 39.5 | 23.4 | 4.06 | 0.19 |
| p70_pistol_64 | move | N | 6.7 | 80 | 80 | 41 | 1.0 | 14.0 | 21.9 | 0.0 | 17.0 | 2.5 | 2.5 | 19.5 | 0.0 | None | 39.5 | 23.5 | 17.25 | 0.13 |
| p70_pistol_64 | move | NE | 6.8 | 80 | 80 | 58 | 1.0 | 12.0 | 18.8 | 0.0 | 10.0 | 3.0 | 2.55 | 12.5 | 0.5 | -0.242 | 39.5 | 23.5 | 10.15 | 0.15 |
| p70_pistol_64 | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 9.0 | 14.1 | 0.0 | 0.0 | 2.5 | 2.5 | 2.5 | 0.0 | None | 39.5 | 23.5 | 0.0 | 0.13 |
| p70_pistol_64 | sprint | SE | 9.3 | 80 | 80 | 61 | 1.0 | 11.0 | 17.2 | 0.0 | 5.0 | 2.5 | 2.35 | 7.5 | 2.0 | 0.383 | 37.0 | 21.9 | 5.07 | 0.15 |
| p70_pistol_64 | sprint | S | 9.3 | 80 | 80 | 38 | 1.0 | 12.0 | 18.8 | 0.0 | 9.0 | 2.5 | 2.5 | 11.5 | 0.0 | None | 39.5 | 23.5 | 9.14 | 0.13 |
| p70_pistol_64 | sprint | SW | 9.3 | 80 | 80 | 61 | 1.0 | 11.0 | 17.2 | 0.0 | 9.0 | 3.0 | 2.82 | 11.5 | 0.5 | -0.812 | 39.5 | 23.3 | 9.14 | 0.25 |
| p70_pistol_64 | sprint | W | 9.3 | 80 | 80 | 71 | 1.0 | 10.0 | 15.6 | 0.0 | 4.0 | 2.5 | 2.5 | 6.5 | 0.0 | None | 39.5 | 23.5 | 4.06 | 0.13 |
| p70_pistol_64 | sprint | NW | 9.3 | 80 | 80 | 59 | 1.0 | 11.0 | 17.2 | 0.0 | 4.0 | 3.0 | 2.66 | 6.5 | 0.5 | -0.901 | 39.5 | 23.4 | 4.06 | 0.19 |
| p70_pistol_64 | sprint | N | 9.3 | 80 | 80 | 39 | 1.0 | 14.0 | 21.9 | 0.0 | 17.0 | 2.5 | 2.5 | 19.5 | 1.0 | -0.064 | 39.5 | 23.5 | 17.26 | 0.13 |
| p70_pistol_64 | sprint | NE | 9.3 | 80 | 80 | 61 | 1.0 | 12.0 | 18.8 | 0.0 | 10.0 | 3.0 | 2.58 | 12.5 | 0.5 | -0.28 | 39.5 | 23.4 | 10.15 | 0.16 |
| p55_hands_64 | sprint | E | 9.3 | 80 | 80 | 59 | 1.0 | 10.0 | 15.6 | -0.0 | 3.0 | 61.5 | 61.5 | 64.5 | 0.0 | None | 35.5 | 1.5 | 3.14 | 58.79 |
| p55_hands_64 | sprint | SE | 9.3 | 80 | 80 | 60 | 1.0 | 14.0 | 21.9 | -0.0 | 7.0 | 62.0 | 58.1 | 69.0 | 28.0 | 0.275 | 33.8 | 4.1 | 7.32 | 56.45 |
| p55_hands_64 | sprint | S | 9.3 | 80 | 80 | 58 | 1.0 | 13.0 | 20.3 | -0.0 | 7.0 | 62.0 | 61.75 | 69.0 | 0.5 | 0.117 | 35.5 | 1.8 | 7.32 | 59.04 |
| p55_hands_64 | sprint | SW | 9.3 | 80 | 80 | 71 | 1.0 | 11.0 | 17.2 | 0.14 | 1.0 | 62.5 | 61.86 | 63.0 | 0.5 | 0.17 | 35.5 | 1.8 | 1.05 | 59.04 |
| p55_hands_64 | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 10.0 | 15.6 | 0.0 | 0.0 | 62.0 | 62.0 | 62.0 | 0.0 | None | 35.5 | 2.0 | 0.0 | 59.29 |
| p55_hands_64 | sprint | NW | 9.3 | 80 | 80 | 44 | 1.0 | 12.0 | 18.8 | 0.04 | 4.0 | 62.5 | 61.76 | 66.0 | 0.5 | 0.052 | 35.5 | 1.7 | 4.19 | 59.03 |
| p55_hands_64 | sprint | N | 9.3 | 80 | 80 | 39 | 1.0 | 16.0 | 25.0 | -0.0 | 17.0 | 62.0 | 61.74 | 79.0 | 0.5 | 0.07 | 35.5 | 1.7 | 17.78 | 59.03 |
| p55_hands_64 | sprint | NE | 9.3 | 80 | 80 | 55 | 1.0 | 11.0 | 17.2 | 0.09 | 5.0 | 62.5 | 61.82 | 67.0 | 0.5 | 0.127 | 35.5 | 1.7 | 5.23 | 59.03 |
| p70_hands_32 | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.66 | 2.0 | 0.5 | -0.062 | 19.5 | 11.3 | 0.0 | 0.35 |
| p70_hands_32 | move | SE | 6.8 | 80 | 80 | 61 | 1.0 | 7.0 | 21.9 | -0.0 | 2.0 | 1.5 | 1.42 | 3.5 | 1.5 | 0.199 | 18.2 | 10.7 | 2.54 | 0.21 |
| p70_hands_32 | move | S | 6.7 | 80 | 80 | 42 | 1.0 | 7.0 | 21.9 | 0.09 | 3.0 | 2.5 | 1.6 | 4.5 | 1.0 | 0.2 | 19.5 | 11.5 | 3.55 | 0.18 |
| p70_hands_32 | move | SW | 6.8 | 80 | 80 | 59 | 1.0 | 8.0 | 25.0 | -0.0 | 5.0 | 2.5 | 2.16 | 6.5 | 2.0 | -0.544 | 19.5 | 11.0 | 5.08 | 0.67 |
| p70_hands_32 | move | W | 6.7 | 80 | 80 | 72 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.67 | 3.5 | 1.0 | 0.202 | 19.5 | 11.3 | 2.03 | 0.34 |
| p70_hands_32 | move | NW | 6.8 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.03 | 1.0 | 3.0 | 1.67 | 3.0 | 2.0 | 0.607 | 19.5 | 11.3 | 1.02 | 0.37 |
| p70_hands_32 | move | N | 6.7 | 80 | 80 | 44 | 1.0 | 8.0 | 25.0 | 0.07 | 7.0 | 2.5 | 1.57 | 8.5 | 1.0 | 0.13 | 19.5 | 11.5 | 7.11 | 0.18 |
| p70_hands_32 | move | NE | 6.8 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | -0.0 | 5.0 | 2.5 | 1.7 | 6.5 | 2.0 | -0.072 | 19.5 | 11.3 | 5.08 | 0.34 |
| p70_hands_32 | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.009 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_hands_32 | sprint | SE | 9.3 | 80 | 80 | 59 | 1.0 | 6.0 | 18.8 | 0.0 | 2.0 | 1.5 | 1.42 | 3.5 | 0.5 | 0.259 | 18.3 | 10.8 | 2.54 | 0.21 |
| p70_hands_32 | sprint | S | 9.3 | 80 | 80 | 56 | 1.0 | 6.0 | 18.8 | 0.34 | 3.0 | 2.5 | 1.84 | 4.5 | 0.0 | None | 19.5 | 11.5 | 3.55 | 0.18 |
| p70_hands_32 | sprint | SW | 9.3 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | 0.0 | 5.0 | 2.5 | 2.13 | 6.5 | 1.0 | -0.843 | 19.5 | 11.0 | 5.08 | 0.67 |
| p70_hands_32 | sprint | W | 9.3 | 80 | 80 | 70 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.76 | 3.5 | 1.0 | 0.187 | 19.5 | 11.3 | 2.03 | 0.41 |
| p70_hands_32 | sprint | NW | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.1 | 1.0 | 3.0 | 1.79 | 3.0 | 1.0 | 0.664 | 19.5 | 11.3 | 1.02 | 0.37 |
| p70_hands_32 | sprint | N | 9.3 | 80 | 80 | 52 | 1.0 | 7.0 | 21.9 | 0.19 | 7.0 | 2.5 | 1.69 | 8.5 | 0.0 | None | 19.5 | 11.5 | 7.11 | 0.18 |
| p70_hands_32 | sprint | NE | 9.3 | 80 | 80 | 61 | 1.0 | 5.0 | 15.6 | 0.0 | 5.0 | 2.5 | 1.75 | 6.5 | 1.0 | -0.379 | 19.5 | 11.3 | 5.08 | 0.38 |
| p70_pistol_32 | move | E | 6.7 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | -0.149 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_pistol_32 | move | SE | 6.8 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | -0.0 | 2.0 | 1.5 | 1.39 | 3.5 | 1.5 | 0.378 | 17.7 | 10.4 | 2.54 | 0.22 |
| p70_pistol_32 | move | S | 6.7 | 80 | 80 | 41 | 1.0 | 7.0 | 21.9 | 0.1 | 4.0 | 2.5 | 1.6 | 5.5 | 1.0 | 0.183 | 19.5 | 11.5 | 4.57 | 0.18 |
| p70_pistol_32 | move | SW | 6.8 | 80 | 80 | 61 | 1.0 | 7.0 | 21.9 | -0.0 | 4.0 | 2.5 | 2.14 | 5.5 | 2.0 | -0.448 | 19.5 | 11.0 | 4.57 | 0.67 |
| p70_pistol_32 | move | W | 6.7 | 80 | 80 | 67 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.0 | 1.64 | 3.5 | 0.5 | 0.214 | 19.5 | 11.4 | 2.03 | 0.3 |
| p70_pistol_32 | move | NW | 6.8 | 80 | 80 | 59 | 1.0 | 6.0 | 18.8 | -0.0 | 2.0 | 2.5 | 1.86 | 3.5 | 2.0 | -0.523 | 19.5 | 11.2 | 2.03 | 0.45 |
| p70_pistol_32 | move | N | 6.7 | 80 | 80 | 47 | 1.0 | 7.0 | 21.9 | 0.13 | 8.0 | 2.5 | 1.63 | 9.5 | 1.0 | 0.183 | 19.5 | 11.5 | 8.63 | 0.18 |
| p70_pistol_32 | move | NE | 6.8 | 80 | 80 | 59 | 1.0 | 7.0 | 21.9 | 0.02 | 5.0 | 2.5 | 1.72 | 6.5 | 2.0 | -0.207 | 19.5 | 11.3 | 5.08 | 0.33 |
| p70_pistol_32 | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 4.0 | 12.5 | 0.0 | 0.0 | 2.0 | 1.62 | 2.0 | 0.5 | 0.009 | 19.5 | 11.4 | 0.0 | 0.31 |
| p70_pistol_32 | sprint | SE | 9.3 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | 0.0 | 2.0 | 1.5 | 1.43 | 3.5 | 0.5 | 0.386 | 18.3 | 10.8 | 2.54 | 0.21 |
| p70_pistol_32 | sprint | S | 9.3 | 80 | 80 | 57 | 1.0 | 6.0 | 18.8 | 0.33 | 4.0 | 2.5 | 1.83 | 5.5 | 0.0 | None | 19.5 | 11.5 | 4.57 | 0.18 |
| p70_pistol_32 | sprint | SW | 9.3 | 80 | 80 | 61 | 1.0 | 6.0 | 18.8 | 0.0 | 4.0 | 2.5 | 2.14 | 5.5 | 1.0 | -0.767 | 19.5 | 11.0 | 4.57 | 0.67 |
| p70_pistol_32 | sprint | W | 9.3 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.0 | 1.63 | 3.5 | 0.5 | 0.349 | 19.5 | 11.4 | 2.03 | 0.3 |
| p70_pistol_32 | sprint | NW | 9.3 | 80 | 80 | 59 | 1.0 | 5.0 | 15.6 | 0.0 | 2.0 | 2.5 | 1.82 | 3.5 | 1.0 | -0.888 | 19.5 | 11.3 | 2.03 | 0.42 |
| p70_pistol_32 | sprint | N | 9.3 | 80 | 80 | 62 | 1.0 | 7.0 | 21.9 | 0.37 | 8.0 | 2.5 | 1.87 | 9.5 | 0.0 | None | 19.5 | 11.5 | 8.63 | 0.18 |
| p70_pistol_32 | sprint | NE | 9.3 | 80 | 80 | 71 | 1.0 | 6.0 | 18.8 | 0.14 | 5.0 | 2.5 | 1.98 | 6.5 | 1.0 | -0.584 | 19.5 | 11.2 | 5.08 | 0.48 |
| p55_hands_32 | sprint | E | 9.3 | 80 | 80 | 80 | 1.0 | 5.0 | 15.6 | 0.26 | 1.0 | 40.5 | 39.76 | 40.5 | 0.0 | None | 19.5 | 24.5 | 1.57 | 38.14 |
| p55_hands_32 | sprint | SE | 9.3 | 80 | 80 | 60 | 1.0 | 6.0 | 18.8 | 0.0 | 3.0 | 39.5 | 36.7 | 42.5 | 21.0 | 0.208 | 18.4 | 23.2 | 3.66 | 36.12 |
| p55_hands_32 | sprint | S | 9.3 | 80 | 80 | 58 | 1.0 | 6.0 | 18.8 | 0.0 | 3.0 | 39.5 | 39.5 | 42.5 | 0.0 | None | 19.5 | 24.5 | 3.66 | 38.14 |
| p55_hands_32 | sprint | SW | 9.3 | 80 | 80 | 80 | 1.0 | 6.0 | 18.8 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.52 | 38.14 |
| p55_hands_32 | sprint | W | 9.3 | 80 | 80 | 80 | 1.0 | 5.0 | 15.6 | 0.0 | 0.0 | 39.5 | 39.5 | 39.5 | 0.0 | None | 19.5 | 24.5 | 0.0 | 38.14 |
| p55_hands_32 | sprint | NW | 9.3 | 80 | 80 | 71 | 1.0 | 6.0 | 18.8 | 0.32 | 2.0 | 40.5 | 39.82 | 41.5 | 0.0 | None | 19.5 | 24.5 | 2.09 | 38.14 |
| p55_hands_32 | sprint | N | 9.3 | 80 | 80 | 39 | 1.0 | 7.0 | 21.9 | 0.0 | 9.0 | 39.5 | 39.5 | 48.5 | 0.0 | None | 19.5 | 24.5 | 8.89 | 38.14 |
| p55_hands_32 | sprint | NE | 9.3 | 80 | 80 | 71 | 1.0 | 5.0 | 15.6 | 0.17 | 2.0 | 40.5 | 39.67 | 41.5 | 0.0 | None | 19.5 | 24.5 | 2.62 | 38.14 |
