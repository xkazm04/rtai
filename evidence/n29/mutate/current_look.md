# mutate: project/boot/collect_call/view/current_look.gd, tests test_collect_call_current (n29, brief 04 part C)

`--max=20` (sampled 20 of 27).

Before (HEAD 820c8dfe5): killed 1 / (1 + 19 survived) = 5.0 %, 475 s.
After (HEAD fcb5fa562, three new tests): killed 14 / (14 + 6) = 70.0 %, 471 s. The sixth survivor, line 42
(`out.size() - 1` insert position of the amber body), was then pinned by `test_amber_body_is_drawn_under_the_core`
and re-run alone (`--lines=42`): 3 / 3 killed. Net: 15 killed / (15 + 5 survived) = 75 % of the sample, the 5 left
are all in `draw()`.

New pins in `project/tests/unit/test_collect_call_current.gd`: `_serial` exact values (cells of 0.25 m, negative
cell, posmod floor, same-cell equality), the plan polyline equals `ElectricArc.shape(..., serial, phase * 2, false)` in
view px for every pass, stroke widths scale with `k`, the amber body sits just under the core.

Survivors left (all in `draw()`, lines 49, 52, 53), none equivalent, none pinned:
- 49 `scale = 1.0` -> `0.0`, 52 `1.0 / maxf(0.01, scale)` (`1.0`->`0.0`, `/`->`*`, `0.01`->`1.01`): the off-tree scale
  fallback and the `k = 1 / screen scale` conversion handed to `plan`.
- 53 `draw_polyline(..., true)` -> `false`: the antialias flag.
These only show in pixels on a CanvasItem (draw_polyline is legal only inside `_draw`); a unit test would need a
SubViewport readback. They are covered by the quest 1 stills, not by unit tests. Left for a render-pin ticket.
