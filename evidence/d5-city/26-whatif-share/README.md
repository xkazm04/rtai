# 26 - WHAT-IF (not adopted): 2 x 2 roof share 70% instead of 35%

For owner call 4. Rendered with BIG_SHARE 0.7 + a re-bake, then reverted and re-baked (the tree and
the baked chunks are back at GENERATOR 12 / 35%; bake --check matches golden). Real city,
city_frame foci 1 (block of roofs beside a street), 6 (street under a roof row), 9; 32 px/m and
16 px/m overviews. CONTENDED GPU. Compare with ../../../gtai-masters ladder (35%) or after-i5/.

FINDING: the share barely changes a street-level frame. The 2 x 2 building fills the block's
interior (tiles 4-5 of 8); a 32-48 px/m street frame shows the street-facing perimeter ring
(tiles 1-2 and 6-7), which still carries the 8.4 m roofs. To reach T1's coarseness where the
player looks, the next step is T1-scale plates on the perimeter: 2 x 1 (16.4 x 8.2 m) buildings
facing the street, with their parapet + wall shadow on the kerb side. Not built today.
