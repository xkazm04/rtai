# Street mutation results

The first-offer assertion was committed in `a51a6b1b9`. The complete shot sample improved from 0/20 to 5/20 after `7a29d9ab7` added colour and redraw checks in `test_fight_areas_clear.gd`. The 15 remaining shot mutations include removing the hostile rim draw at line 59. The checked reference frame shows the rim.

In `1818deb63`, `test_foe_shove_zone.gd` gained an exact side-contact assertion. The sole original shove survivor was killed in the four-mutant line recheck. The new `test_gauntlet_draw.gd` assertion exercises a history entry whose bonus ID has been retired. The recheck rows give the scores for those source lines.

Each run used the default mapped tests and a maximum of 20 mutants. The score counts killed mutants over killed plus survived. Every literal invocation with a `project/` prefix exited 2 because the runner adds that directory itself. Removing the prefix selected the requested file in the runner's temporary worktree.

| Run | HEAD | Killed / decided | Survived | Timeout | Invalid |
| --- | --- | ---: | ---: | ---: | ---: |
| First stacked pick, line 146 | `3d36c31a` | 1/1 | 0 | 0 | 0 |
| Wave composer | `704f8c63` | 20/20 | 0 | 0 | 0 |
| Shot drawing, original tests | `1cccf5d9` | 0/20 | 20 | 0 | 0 |
| Shot drawing, expanded tests | `7a29d9ab` | 5/20 | 15 | 0 | 0 |
| Shove zone | `7a29d9ab` | 19/20 | 1 | 0 | 0 |
| Shove contact recheck | `1818deb6` | 4/4 | 0 | 0 | 0 |
| Offer count and eligibility, lines 41–67 | `1818deb6` | 15/16 | 1 | 0 | 0 |
| Offer eligibility recheck | `79844f67` | 2/2 | 0 | 0 | 0 |

### Shot drawing, original tests

| File and line | Mutation | Verdict |
| --- | --- | --- |
| `features/combat/shot_draw.gd:13` | boolean `and -> or` | survived |
| `features/combat/shot_draw.gd:14` | delete `RenderingServer.free_rid(_rid) -> pass` | survived |
| `features/combat/shot_draw.gd:18` | boolean `false -> true` | survived |
| `features/combat/shot_draw.gd:22` | boolean `true -> false` | survived |
| `features/combat/shot_draw.gd:26` | cmp_flip `== -> !=` | survived |
| `features/combat/shot_draw.gd:37` | delete `RenderingServer.canvas_item_set_parent(layer._rid, ci.get_canvas_item()) -> pass` | survived |
| `features/combat/shot_draw.gd:38` | delete `ci.set_meta(LAYER, layer) -> pass` | survived |
| `features/combat/shot_draw.gd:40` | delete `ci.draw.connect(RenderingServer.canvas_item_clear.bind(layer._rid)) -> pass` | survived |
| `features/combat/shot_draw.gd:46` | delete `ci.draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK, 4.0) -> pass` | survived |
| `features/combat/shot_draw.gd:54` | literal `0.3 -> 1.3` | survived |
| `features/combat/shot_draw.gd:55` | delete `ci.draw_circle(Ink.px(head), widths.y + 1.0, Ink.CREAM) -> pass` | survived |
| `features/combat/shot_draw.gd:55` | arith `+ -> -` | survived |
| `features/combat/shot_draw.gd:55` | literal `1.0 -> 0.0` | survived |
| `features/combat/shot_draw.gd:59` | delete `RenderingServer.canvas_item_add_line(rid, Ink.px(tail), Ink.px(head), rim(s), widths.x) -> pass` | survived |
| `features/combat/shot_draw.gd:63` | literal `1.0 -> 0.0` | survived |
| `features/combat/shot_draw.gd:74` | literal `0 -> 1` | survived |
| `features/combat/shot_draw.gd:75` | boolean `not -> (removed)` | survived |
| `features/combat/shot_draw.gd:77` | delete `ci.draw_polyline(ring, Ink.INK, width, true) -> pass` | survived |
| `features/combat/shot_draw.gd:81` | delete `RenderingServer.canvas_item_add_polyline(rid, ring, PackedColorArray([Ink.INK]), width, true) -> pass` | survived |
| `features/combat/shot_draw.gd:81` | boolean `true -> false` | survived |

### Shot drawing, expanded tests

| File and line | Mutation | Verdict |
| --- | --- | --- |
| `features/combat/shot_draw.gd:13` | boolean `and -> or` | survived |
| `features/combat/shot_draw.gd:14` | delete `RenderingServer.free_rid(_rid) -> pass` | survived |
| `features/combat/shot_draw.gd:37` | delete `RenderingServer.canvas_item_set_parent(layer._rid, ci.get_canvas_item()) -> pass` | survived |
| `features/combat/shot_draw.gd:46` | delete `ci.draw_line(Ink.px(tail), Ink.px(s.pos), Ink.INK, 4.0) -> pass` | survived |
| `features/combat/shot_draw.gd:54` | literal `0.3 -> 1.3` | survived |
| `features/combat/shot_draw.gd:55` | delete `ci.draw_circle(Ink.px(head), widths.y + 1.0, Ink.CREAM) -> pass` | survived |
| `features/combat/shot_draw.gd:55` | arith `+ -> -` | survived |
| `features/combat/shot_draw.gd:55` | literal `1.0 -> 0.0` | survived |
| `features/combat/shot_draw.gd:59` | delete `RenderingServer.canvas_item_add_line(rid, Ink.px(tail), Ink.px(head), rim(s), widths.x) -> pass` | survived |
| `features/combat/shot_draw.gd:63` | literal `1.0 -> 0.0` | survived |
| `features/combat/shot_draw.gd:74` | literal `0 -> 1` | survived |
| `features/combat/shot_draw.gd:75` | boolean `not -> (removed)` | survived |
| `features/combat/shot_draw.gd:77` | delete `ci.draw_polyline(ring, Ink.INK, width, true) -> pass` | survived |
| `features/combat/shot_draw.gd:81` | delete `RenderingServer.canvas_item_add_polyline(rid, ring, PackedColorArray([Ink.INK]), width, true) -> pass` | survived |
| `features/combat/shot_draw.gd:81` | boolean `true -> false` | survived |

### Shove zone

| File and line | Mutation | Verdict |
| --- | --- | --- |
| `features/combat/squad/foe_shove_zone.gd:23` | boundary `<= -> <` | survived |

### Offer count and eligibility, lines 41–67

| File and line | Mutation | Verdict |
| --- | --- | --- |
| `features/gauntlet/gauntlet_draw.gd:56` | boolean `and -> or` | survived |
