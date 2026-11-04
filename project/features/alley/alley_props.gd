class_name AlleyProps
extends RefCounted
## n5-look: the alley's small ground props painted onto AlleyDecor's canvas (static, view only):
## trash sacks, rain pools and flat litter (r2_a6). Split out of AlleyDecor for the file budget.


## One trash sack from above (r2_a6): a lumpy, slightly long body, a crease, and the tied neck
## (an ink knot with two ear tufts) toward `turn`, so a pile reads as sacks, not balls.
static func sack(ci: CanvasItem, at: Vector2, rad: float, fill: Color, turn: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var grown: int = pts.resize(19)
	assert(grown == OK)
	for k: int in 18:
		var a: float = TAU * k / 18.0
		var lump: float = 1.0 + 0.1 * sin(a * 3.0 + turn) + 0.06 * sin(a * 5.0 - turn)
		pts[k] = at + Vector2(cos(a) * 1.15, sin(a) * 0.9).rotated(turn) * rad * lump
	pts[18] = pts[0]
	var shade: PackedVector2Array = PackedVector2Array(pts.slice(0, 18))
	for k: int in 18:
		shade[k] += Vector2(3.0, 3.0)
	ci.draw_colored_polygon(shade, Color(Ink.INK, 0.4))
	ci.draw_colored_polygon(pts.slice(0, 18), fill)
	ci.draw_polyline(pts, Ink.INK, 2.0)
	var dir: Vector2 = Vector2.from_angle(turn)
	var side: Vector2 = dir.orthogonal()
	ci.draw_line(at - side * rad * 0.4, at + dir * rad * 0.5, Color(Ink.INK, 0.6), 1.5)
	ci.draw_arc(at, rad * 0.6, turn + 2.2, turn + 2.9, 5, Color(Ink.CREAM, 0.55), 2.0)
	var neck: Vector2 = at + dir * rad * 1.05
	ci.draw_line(neck, neck + (dir + side * 0.7) * rad * 0.35, Ink.INK, 2.5)
	ci.draw_line(neck, neck + (dir - side * 0.7) * rad * 0.35, Ink.INK, 2.5)
	ci.draw_circle(neck, rad * 0.14, Ink.INK)


## A rain puddle (r2_a6): a sky-grey pool a value below the lane, a soft lumpy rim, two glints.
static func puddle(ci: CanvasItem, r: Rect2, fill: Color) -> void:
	var c: Vector2 = r.get_center()
	var pts: PackedVector2Array = PackedVector2Array()
	var grown: int = pts.resize(25)
	assert(grown == OK)
	for k: int in 24:
		var a: float = TAU * k / 24.0
		var wob: float = 1.0 + 0.13 * sin(a * 3.0 + c.x * 0.01) + 0.08 * cos(a * 5.0)
		pts[k] = c + Vector2(cos(a) * r.size.x, sin(a) * r.size.y) * 0.5 * wob
	pts[24] = pts[0]
	ci.draw_colored_polygon(pts.slice(0, 24), fill)
	ci.draw_polyline(pts, Color(Ink.INK, 0.45), 1.5)
	var g: Vector2 = Vector2(r.size.x, r.size.y) * 0.18
	ci.draw_line(c - g, c - g + Vector2(g.x * 0.9, -g.y * 0.5), Color(Ink.CREAM, 0.9), 2.0)
	ci.draw_line(
		c + g * 0.4, c + g * 0.4 + Vector2(g.x * 0.6, -g.y * 0.3), Color(Ink.CREAM, 0.7), 2.0
	)


## Flat litter [x, y, w, h, deg]: a squashed cardboard box (taped seam) or, under 0.5 m, paper.
static func litter(ci: CanvasItem, v: Variant, base: Vector2) -> void:
	var raw: Array = v if v is Array else [0, 0, 0, 0, 0]
	var a: PackedFloat32Array = PackedFloat32Array(raw)
	var r: Rect2 = AlleyDecor.rect_px([a[0], a[1], a[2], a[3]], base)
	ci.draw_set_transform(r.get_center(), deg_to_rad(a[4]))
	var l: Rect2 = Rect2(-r.size * 0.5, r.size)
	var card: bool = a[2] >= 0.5
	ci.draw_rect(Rect2(l.position + Vector2(2.0, 2.0), l.size), Color(Ink.INK, 0.3), true)
	ci.draw_rect(l, AlleyDecor.CARD if card else Ink.CREAM, true)
	if card:
		ci.draw_line(Vector2(l.position.x, 0.0), Vector2(l.end.x, 0.0), Color("#8A6C48"), 3.0)
		ci.draw_line(Vector2(0.0, l.position.y), Vector2(0.0, l.end.y), Color(Ink.INK, 0.5), 1.0)
	ci.draw_rect(l, Ink.INK, false, 1.5)
	ci.draw_set_transform(Vector2.ZERO)
