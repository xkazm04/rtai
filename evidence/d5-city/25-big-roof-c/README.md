# 25 - third 2 x 2 roof plate + a no-repeat cycle (GENERATOR 12)

Plate C: a Codex image on layout template C (masters tools/layout_c.py: a 5.4 x 4 m skylight grid,
3.2 m + 2.4 m water tanks, two 2.2 m fan units, one 3 m fan unit, a 2 x 5.4 m duct housing, three
exhaust stacks, a crate, an L pipe), tone/tint matched to plate A (tools/fit_roof.py), 1312 px at
80 px/m. Codex images used by this lane today: 3 (of ~30).

Pick: the hash at salt 62 clustered in the city_frame window when split 3 ways (8 of 10 big blocks
got B, none A). Replaced with the road-variant scheme: A-B-C cycled along each block row from a
per-row random offset, so two big blocks side by side never share a plate. Over 16 x 16 blocks:
A 27, B 32, C 32. Foci 7 (A) and 8 (B) are pixel-identical to iteration 5's frames (diff 0.0 / 0.02).

Frames (real city, city_frame.tscn foci 7/8/9, look auto, CONTENDED GPU, fixed 60 fps):
after/city-{7,8,9}-{32,48}ppm.png; city-*-16ppm.png overviews (D4 look, not a gameplay zoom).
cmp-a-b-c-{32,48}ppm.png: the three plates side by side. Before for focus 9 = plate B under
GENERATOR 11 at block (10, 6) (not re-rendered); before the 2 x 2 at all = 22-big-roof/before.
0 camera-break rejects (all straight down).
