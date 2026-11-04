class_name KillPoly
extends RefCounted
## Fills a star-shaped outline (every point seen from its centroid: the kills' flakes, shards,
## scorches, blots, zap stars and cloth piles) as a triangle fan with explicit indices, so Godot
## never triangulates it. draw_colored_polygon rejects the tiny or near-degenerate shapes a kill
## draws at 32 px/m and then draws nothing (showcase REQUEST 17: 4,462 errors in one city reel,
## the ash flakes never showed).


## Fan indices for an outline of `n` points around a centre vertex at index 0.
static func fan_indices(n: int) -> PackedInt32Array:
	var idx: PackedInt32Array = PackedInt32Array()
	if n < 3:
		return idx
	for k: int in n:
		@warning_ignore("return_value_discarded")
		idx.append_array(PackedInt32Array([0, k + 1, (k + 1) % n + 1]))
	return idx


## Draws `pts` filled with `color` on `ci` (inside its _draw, like any draw_* call).
static func fill(ci: CanvasItem, pts: PackedVector2Array, color: Color) -> void:
	var n: int = pts.size()
	if n < 3:
		return
	var c: Vector2 = Vector2.ZERO
	for p: Vector2 in pts:
		c += p
	var verts: PackedVector2Array = PackedVector2Array([c / float(n)])
	verts.append_array(pts)
	RenderingServer.canvas_item_add_triangle_array(
		ci.get_canvas_item(), fan_indices(n), verts, PackedColorArray([color])
	)
