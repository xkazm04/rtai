class_name ArenaFloorStatic
extends RefCounted
## The arena floor's held drawing (ArenaFloorView's `_static` child): the dock floor's tiles and
## rim, the city's barrier runs and crate rows, drawn on any canvas item. The same draw calls in
## the same order as StageView's `_tiled` + `_floor`, so a held floor prints what a per-frame one
## printed. Render only.

## On the city block a pit wall is a row of inked concrete barrier segments (still solid), not
## the arena's flat ink bar: the street's warm grey, a cream top edge, a joint every BARRIER_M.
const BARRIER_FILL: Color = Color("#8E867C")
const BARRIER_M: float = 2.0
const CRATES: Texture2D = preload("res://features/city/art/props/crate_stack.png")
const CRATE_PX: Rect2 = Rect2(0.0, 0.0, 80.0, 80.0)


## A texture tiled over `r` (m), one repeat per `tile_m` square, then the area's ink rim.
static func tiles(ci: CanvasItem, r: Rect2, t: Texture2D, tile_m: float) -> void:
	var reps: Vector2 = Vector2(r.size.x / tile_m, r.size.y / tile_m)
	var x: float = 0.0
	while x < reps.x:
		var y: float = 0.0
		while y < reps.y:
			var cell: Vector2 = Vector2(minf(1.0, reps.x - x), minf(1.0, reps.y - y))
			var at: Vector2 = r.position + Vector2(x * tile_m, y * tile_m)
			var dst: Rect2 = Rect2(Ink.px(at), cell * tile_m * Ink.PX_PER_M)
			ci.draw_texture_rect_region(t, dst, Rect2(Vector2.ZERO, Vector2(t.get_size()) * cell))
			y += 1.0
		x += 1.0
	var p: Rect2 = Rect2(Ink.px(r.position), r.size * Ink.PX_PER_M)
	ci.draw_rect(p, Color(0, 0, 0, 0), true)
	ci.draw_rect(p, Ink.INK, false, Ink.LINE_PX)


## A concrete barrier run: fill, ink rim, a cream top edge and a joint line every BARRIER_M.
static func barrier(ci: CanvasItem, r: Rect2) -> void:
	ci.draw_rect(r, BARRIER_FILL, true)
	var long_x: bool = r.size.x >= r.size.y
	var step: float = BARRIER_M * Ink.PX_PER_M
	var n: int = int(maxf(r.size.x, r.size.y) / step)
	for i: int in range(1, n + 1):
		var off: Vector2 = Vector2(step * i, 0.0) if long_x else Vector2(0.0, step * i)
		var end: Vector2 = Vector2(0.0, r.size.y) if long_x else Vector2(r.size.x, 0.0)
		ci.draw_line(r.position + off, r.position + off + end, Ink.INK, Ink.LINE_PX * 0.5)
	var edge: Rect2 = r.grow(-Ink.LINE_PX * 1.5)
	var top: Vector2 = Vector2(edge.size.x, 0.0) if long_x else Vector2(0.0, edge.size.y)
	ci.draw_line(edge.position, edge.position + top, Ink.CREAM, Ink.LINE_PX)
	ci.draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## Square crates along the box's long side (the last one squeezed to fit).
static func crate_row(ci: CanvasItem, r: Rect2) -> void:
	var side: float = minf(r.size.x, r.size.y)
	var along: Vector2 = Vector2(side, 0.0) if r.size.x >= r.size.y else Vector2(0.0, side)
	var n: int = maxi(roundi(maxf(r.size.x, r.size.y) / side), 1)
	for i: int in n:
		var cell: Rect2 = Rect2(r.position + along * i, Vector2(side, side))
		ci.draw_texture_rect_region(CRATES, cell.intersection(r), CRATE_PX)
