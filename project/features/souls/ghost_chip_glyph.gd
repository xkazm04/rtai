class_name GhostChipGlyph
extends RefCounted
## The D5 glyph inside a ghost's chip when it has no drawn face (GhostChipFace); moved out of
## GhostFormHud (n9-handheld) unchanged.


## Each ghost's mark inside its chip, from the concept's silhouette from above.
static func draw(ci: CanvasItem, id: StringName, c: Vector2, s: float, col: Color) -> void:
	match id:
		&"tonnage":  # the press slab with its four corner feet
			ci.draw_rect(Rect2(c - Vector2(s, s) * 0.6, Vector2(s, s) * 1.2), col)
			for d: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
				ci.draw_circle(c + d * s * 0.85, s * 0.28, col)
		&"dent":  # the crash-test target disc
			ci.draw_arc(c, s * 0.8, 0.0, TAU, 24, col, 3.0)
			ci.draw_circle(c, s * 0.3, col)
		&"kerf":  # the cutting beam's line through the lens
			ci.draw_line(c - Vector2(s, -s), c + Vector2(s, -s), col, 3.0)
			ci.draw_circle(c, s * 0.3, col)
		&"ohm":  # the forked bolt
			var bolt: PackedVector2Array = PackedVector2Array(
				[
					c + Vector2(-s * 0.2, -s),
					c + Vector2(s * 0.3, -s * 0.1),
					c + Vector2(-s * 0.3, s * 0.1),
					c + Vector2(s * 0.2, s)
				]
			)
			ci.draw_polyline(bolt, col, 3.0)
