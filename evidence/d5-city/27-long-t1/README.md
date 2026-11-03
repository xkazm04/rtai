# 27 - T1-scale long roof in the long (two-tile) slots (GENERATOR 13)

Follows 26: the street-level frame shows the block's street-facing ring, so T1's coarse rooftops have
to reach the perimeter. The long two-tile building slots (30% of the mx 3/5 tiles; mx 3 faces the
street) now pick from 22 long, 23 warehouse and 81, a new 16.4 x 8.4 m Codex plate on layout
template D (masters tools/layout_d.py: 4 m tank, two 2.2 m fan units, stair housing, skylight, vent,
L pipe), tone-matched to plate A (fit_roof.py, 1592 x 809 -> 1312 x 672 px = 80 px/m). Plate 81 is
upright only (shadows lower-right); 22/23 keep their 180 deg turns. Codex used today: 4 (of ~30).

Frames (real city, city_frame.tscn, look auto, CONTENDED GPU, fixed 60 fps):
- after/city-10-{32,48}ppm.png: focus 10 = the street south of focus 6, plate 81 on the facing row.
  The closest street-level frame to T1 this lane has made.
- after/city-6-16ppm.png: overview (plate 81 on the lower block's street row).
- cmp-city-{6,1}-*.png: before (fba312e) vs after at foci 6 / 1. The split 22/23 -> 22/23/81 also
  reshuffles which long building lands where (focus 6's slot is now the warehouse): expected.

Gates at b08a010: lint, bake --check, unit 335, scenarios 8 (replay cbeb734ff9b97c41 unchanged),
selftest PASS after a deliberate re-bless of the block site's d4 32 px/m golden (its bottom-right
warehouse is now plate 81: far 2.25 % > 2 %, mean 2.84 < 4; golden-block-d4-32-before-after.png).
FRICTION: the first selftest re-runs failed "no result (needs a display)" because GODOT_BIN was not
exported in that shell.
