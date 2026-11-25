# Design note: a dusk grade for the over-print wrecks (n29-12 `film-tool`, read only, no code changed)

## What the premise gets wrong
The dusk grade already reaches the over-print layer. The stack (`project/data/tables/render_layers.json`, `PrintStage._build_print` / `_ready` / `LightLayer._ready`):
canvas 0 `world` (floor, wrecks not in `over_print`), canvas 1 `print` (the `look_d4` full-screen print pass over canvas 0), canvas 2 `actors` (the over-print `CanvasLayer`, `prologue_yard_overprint.gd:11-13`, `RenderLayers.canvas(&"actors")`, sub-order -1), canvas 3 `light` (the `LightLayer` grade rect, `light_layer.gd:44-55`, `hint_screen_texture`, z band `grade`). The grade rect reads the whole screen, so the `arched_line.lights.grade` row (`prologue_yard_dressings.json:2079-2084`: `dusk`, paper_level 0.92, gamma 1.1, accent_keep 0.92; installed by `PrologueYardLights.install`, `prologue_yard_lights.gd:51-57`, called at `prologue_game.gd:137`) multiplies the over-print wrecks too.
What the over-print layer skips is the **D4 print pass** (canvas 1): the world pass flattens every pixel under paper luminance to a grey wash and re-prints it, so a burnt brown wreck came out dark. The grade itself is mild (x0.92, gamma 1.1) and cannot account for the 29-55 % contrast loss in `impression_props.md`. So "give `over_print` the dusk grade" would change almost nothing; the missing piece is a darkening of the wreck's own colour.

## Exact lines
- `prologue_yard_overprint.gd:_draw_pieces` (last 5 lines): ground wrecks go through `paint.wreck(node, piece, Color.WHITE, skin)`; non-wreck debris (spans, fence) through `paint.wreck(node, piece, piece.tint, null)`.
- `prologue_yard_paint.gd:wreck` (lines 93-111): the `tint` argument only reaches the two `skin == null` branches (`draw_texture_rect_region(..., tint)`); the `skin != null` branch (cover art, line 110) draws with no modulate, so a tint passed by the caller is silently ignored for skinned wrecks.
- `prologue_yard_dressing.gd:113-114`: `over_print` is read as a `PackedStringArray` of ids.

## Smallest change (one optional data key, absent = today's look)
Row key `over_print_shade` (float 0..1, absent = 1.0) on a dressing. Code, about 8 lines in two files:
1. `prologue_yard_dressing.gd`: `var over_print_shade: float = 1.0`; `if row.has("over_print_shade"): over_print_shade = table.num(row, "over_print_shade")`; schema property `{"type":"number","minimum":0,"maximum":1}` in the dressings schema.
2. `prologue_yard_overprint.gd:_draw_pieces`: the ground-wreck call becomes `paint.wreck(node, piece, Color(s, s, s), skin)` with `s = plan.dressing.over_print_shade`.
3. `prologue_yard_paint.gd:wreck`: pass `tint` to the skinned branch (`canvas.draw_texture_rect_region(art, Rect2(...), source, tint)`); every existing caller passes `Color.WHITE` or the piece tint with a skin of null for pieces that use it, so default output is unchanged (to be proven by the existing overprint tests and one before/after still).
Not `node.modulate`: it would also darken the ochre impression (`ffffff8c`, the owner's pick) and the overhead spans.
A multiplicative shade, not a luminance remap: the print pass maps l -> its own ramp, but a flat `s` of about 0.5-0.6 reproduces the i20 prop mean (0.074-0.081 on the forklift and skip against 0.145-0.170 now) closely enough to tune by eye in one round of stills.

## Cost
Zero draw calls and no new shader (same `draw_texture_rect_region`, one more `Color`); `_draw_pieces` runs only on redraw of a static layer. Zero change with the key absent. Data cost: one number in `arched_line` (and the other three dressings if wanted). Sim untouched (render only, so the pilots stay identical).

## Tests that would pin it
In `project/tests/unit/test_prologue_yard_overprint.gd` (it already drives `attach`/`order`): (a) absent key -> `over_print_shade == 1.0` and a recorded `wreck` tint of `Color.WHITE` (default look pinned); (b) key 0.5 -> a skinned and an unskinned wreck both draw with `Color(0.5, 0.5, 0.5)`, via a `PrologueYardPaint` subclass that records the `tint` argument (the skinned case fails if step 3 is missed); (c) spans and the impression ignore the shade; (d) a schema test that 1.5 is rejected. Mutate that file with `tools/mutate/mutate.mjs --file=boot/prologue/prologue_yard_overprint.gd` and quote killed/(killed+survived). Visual proof: the `impression_props.md` contrast script (`evidence/yard29/prop_contrast.py`) before and after, target within 10 % of the i20 contrast for forklift, skip and fridges.

## Decision still the owner's
Accept the own-colour wrecks (crisp, saturated, lighter than i20) or darken them with `over_print_shade`; the fridge bank (pale on pale, 0.0426) is the one that needs it most.
