# 23 - second 2 x 2 roof plate (GENERATOR 11)

One plate on 35% of blocks repeats in a 64 m city grid (see 22). Plate B: a Codex image on layout
template B (stair / lift machine room 4.6 x 3.8 m, a 1.4 x 6.2 m skylight strip, a 3.5 m tank, a row of
three 2.2 m fan units, a louvred hatch, a vent box, a crate, an L pipe). The raw output came back with a
pink-grey membrane (median 199 vs plate A's 241) and a brown door, so masters tools/fit_roof.py
transfers plate A's tone and tint (luma histogram match, then A's luma -> RGB lookup) before the
1312 px fit: both plates print alike, no colour outside the ink/cream doctrine.
Pick per block (salt 62): 50/50. Upright only (rotation rejected in 22).

Frames (real city, city_frame.tscn, look auto, CONTENDED GPU, fixed 60 fps):
- after/city-8-{32,48,64}ppm.png: focus 8 = block (9, 6), plate B. city-8-16ppm.png and
  city-7-16ppm.png: 16 px/m overviews of the whole block (D4 look; not a gameplay zoom).
- cmp-a-vs-b-{32,48}ppm.png: plate A (focus 7) beside plate B (focus 8).
- before for focus 8 = plate A on every big block (GENERATOR 10, see 22); not re-rendered.
- First focus 8 pick (block 7, 7) was a plaza (the plaza check runs first): moved, no frame kept.
Codex images used by this lane today: 2 (of ~30).
