# JOURNAL: night n10, lane world

MILESTONE [21:05] Session opened (runner calls it iteration 4; this worktree had no JOURNAL and no commits past c394af55, so nothing was lost from earlier iterations: start at item 1).

## Reading the frames
- d10/block70 h05 (half height): the wall band is a dark squashed strip. The p70 strip is 4 storeys cut to 768x297 and drawn over a 76 px wall: every storey about 19 px tall, windows squat.
- Heights after height_k 0.5: shop 4.25-5 m, tenement 6.5-8 m, tall 8.5-10.5 m, so canvas wall (32 px/m, lift_k/ground_k) about 49-121 px.

## Item 1, the wall art at half height
- Tool `tools/art/city_facade_storeys.py` cuts the r2 elevations into upper + ground storey rows (bay 256 px wide, native aspect). `FacadeStoreys` stacks them from the ground, as many upper storeys as fit. Tenement 2 storeys at 76-93 px, tall ground + upper rows, shop one storey.
- FRICTION: the machine is badly contended (a plain `--import` passed 200 s and was killed; grep over project/tests times out).
