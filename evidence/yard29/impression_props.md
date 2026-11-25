# impression-props (n29-08b, session 3 short call)

Cause: `PrologueYardOverprint._draw_pieces` lays the i55 impression (`ffffff8c`, rect y -1.1..34) over the world pass. The world pass prints the wrecks not named in `arched_line.over_print` (burnt_pickup, press_carcass, fallen_fridges, scrap_skip) under it, and the south fence (Rect2 y = yard end - 0.65, about 33.35..34) sits inside the rect.

Data fix (table only, no code): `over_print` gained `burnt_pickup`, `press_carcass`, `fallen_fridges`, `scrap_skip` (they draw over the impression in their own colours and are skipped in the world pass, so no double draw); `ground_impression.rect_m.size` y 35.1 -> 34.4 (ends 33.3, north of the fence at 33.35). Pin: `test_arched_line_lays_the_brown_tile_as_a_second_impression_and_raised_line_does_not`.

Not reachable by data: ground decals (stains, tyre marks, bay lines) printed in the world pass stay under the impression. Finding for a later call: they need the impression drawn BEFORE the decals (a code change in `prologue_floor.gd`/`prologue_yard_overprint.gd` order) or a lower tint.

After still: `evidence/yard29/impression_props_after_mid_32ppm.png` (seed 7, tick 300, mid camera). Seen: the skip, fridges and press carcass, the forklift and the south fence and gate read crisp in their own colours; tyre marks and bay lines are still soft (decals). No contrast table, pilots, before still, film: next session.
