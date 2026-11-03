# 22 - T1-scale 2 x 2 roof (GENERATOR 10, commit 2b2fa98)

Finding (iteration 4): T1 is not denser than our roofs, it is coarser. T1 is ~38 px/m (its sedan is
185 x 85 px = 4.9 x 2.15 m); its buildings span ~15 m with 5-6 big items (4.5 m water tank, 2.2 m AC
units, 3.4 m skylights), ~0.03 items/m2. Ours: 8.4 m roofs with 10-15 items, ~0.17 items/m2, items
half T1's size.

Change: on 35% of blocks (not plazas) one 16.4 x 16.4 m building covers the block's 2 x 2 interior
tiles (mx, my 4-5). Plate: one Codex image on a grey-guide layout template drawn at 80 px/m (5 m ruler),
style refs T1 + the D5 concept; cut from the #00B140 border, Lanczos-fit 1183 -> 1312 px, shipped at
the locked 80 px/m roof texel density. Upright only.

Frames (real city, city_frame.tscn focus 7, look auto, CONTENDED GPU, fixed 60 fps):
- before/ = GENERATOR 9 (four 8.4 m roofs and a long building in the block interior), 32 + 48 px/m.
- after/ = GENERATOR 10, 32 / 48 / 64 px/m. cmp-city-7-{32,48}ppm.png = side by side.
- rejected/rejected-rotated-180-64ppm.png: rotating the plate 180 deg for variety puts its hatched
  shadows upper-left, against every other shadow in the city. Rejected by eye (1 reject).

Gates at 2b2fa98: lint 13/13, unit 335/335, bake --check matches golden, scenarios 8/8 (replay
unchanged: the block is stamped C_BUILD whole either way), selftest PASS (look goldens 11/11 worst
0.78, block goldens 5/5, no new off-doctrine accents, world lock 0 %).
