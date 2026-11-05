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


## Lane grime (r2_a6): `count` soft dark blotches hashed over the lane, each a lumpy core with
## two satellites (wall_bias < 1 crowds them toward the wall feet), plus a dirt band along both
## wall feet. Hash-placed from the index and `seed` (view only: no RNG stream, so replay and
## parity are untouched). count 0 + edge_m 0 = none.
static func grime(ci: CanvasItem, lane: Rect2, spec: Dictionary) -> void:
	var tone: Color = Color(str(spec.get("tone", "#3A342E59")))
	var edge_m: float = spec.get("edge_m", 0.0)
	var edge: float = edge_m * Ink.PX_PER_M
	if edge > 0.0:
		var edge_a: float = spec.get("edge_a", 0.3)
		var ea: Color = Color(tone, edge_a)
		_band(ci, lane.position, Vector2(lane.size.x, edge), ea)
		_band(ci, Vector2(lane.position.x, lane.end.y), Vector2(lane.size.x, -edge), ea)
	var raw: Array = spec.get("size_m", [0.3, 1.0])
	var sz: PackedFloat32Array = PackedFloat32Array(raw)
	var seed: float = spec.get("seed", 1.0)
	var count: int = spec.get("count", 0)
	var bias: float = spec.get("wall_bias", 1.0)
	for i: int in count:
		var v: float = _h(i, seed + 7.1) * 2.0 - 1.0  # across the lane, pushed to the wall feet
		v = 0.5 + 0.5 * signf(v) * pow(absf(v), bias)
		var at: Vector2 = lane.position + lane.size * Vector2(_h(i, seed), v)
		var t: float = _h(i, seed + 3.3)
		var rad: float = lerpf(sz[0], sz[1], t * t) * Ink.PX_PER_M * 0.5
		_blot(ci, at, rad, tone, i + seed)
		for k: int in 2:
			var dir: Vector2 = Vector2.from_angle(TAU * _h(i * 2 + k, seed + 5.9))
			_blot(ci, at + dir * rad * 1.25, rad * 0.35, tone, i + k + seed * 2.0)


## A band from `p` across `size` (its height may be negative): `c` at the wall, clear inward.
static func _band(ci: CanvasItem, p: Vector2, size: Vector2, c: Color) -> void:
	var clear: Color = Color(c, 0.0)
	var pts: PackedVector2Array = PackedVector2Array(
		[p, p + Vector2(size.x, 0.0), p + size, p + Vector2(0.0, size.y)]
	)
	ci.draw_polygon(pts, PackedColorArray([c, c, clear, clear]))


static func _blot(ci: CanvasItem, at: Vector2, rad: float, c: Color, s: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var grown: int = pts.resize(12)
	assert(grown == OK)
	for k: int in 12:
		var a: float = TAU * k / 12.0
		var lump: float = 0.75 + 0.5 * _h(k, s)
		pts[k] = at + Vector2(cos(a), sin(a) * 0.8) * rad * lump
	ci.draw_colored_polygon(pts, c)


static func _h(i: int, s: float) -> float:
	return fposmod(sin(i * 12.9898 + s * 78.233) * 43758.5453, 1.0)


## A dumpster from above (r2_a6): a dark lid of ribs across its length over a green-grey front
## face (the side toward `toward`, the lane), a lip line, two wheels; a 3 px drop, no cast shadow.
static func dumpster(ci: CanvasItem, r: Rect2, lid: Color, body: Color, toward: Vector2) -> void:
	var c: Vector2 = r.get_center()
	var along_x: bool = r.size.x >= r.size.y
	var length: float = maxf(r.size.x, r.size.y)
	var depth: float = minf(r.size.x, r.size.y)
	var front: float = (toward - c).y if along_x else (toward - c).x
	var turn: float = -0.5 * PI * signf(front + 0.001)
	if along_x:
		turn = 0.0 if front >= 0.0 else PI
	ci.draw_rect(Rect2(r.position + Vector2(3.0, 3.0), r.size), Color(Ink.INK, 0.4), true)
	ci.draw_set_transform(c, turn)
	var l: Rect2 = Rect2(-length * 0.5, -depth * 0.5, length, depth)
	var face: Rect2 = Rect2(l.position.x, l.end.y - depth * 0.3, length, depth * 0.3)
	var top: Rect2 = Rect2(l.position, Vector2(length, depth * 0.7))
	ci.draw_rect(face, body, true)
	for k: int in 5:  # grime mottles on the face
		var at: Vector2 = face.position + face.size * Vector2(_h(k, c.x * 0.01), _h(k, c.y * 0.01))
		ci.draw_circle(at, face.size.y * (0.12 + 0.12 * _h(k, 3.7)), body.darkened(0.3))
	ci.draw_rect(top, lid, true)
	var ribs: int = maxi(3, roundi(length / (0.24 * Ink.PX_PER_M)))
	for i: int in range(1, ribs):
		var x: float = top.position.x + top.size.x * i / ribs
		ci.draw_line(Vector2(x, top.position.y + 2.0), Vector2(x, top.end.y - 2.0), Ink.INK, 2.0)
		var hi: Color = Color(Ink.CREAM, 0.5)  # each rib's lit edge
		ci.draw_line(Vector2(x + 3.0, top.position.y + 4.0), Vector2(x + 3.0, top.end.y - 4.0), hi)
	ci.draw_line(Vector2(l.position.x, top.end.y), Vector2(l.end.x, top.end.y), Ink.INK, 3.0)
	for s: float in [-1.0, 1.0]:
		ci.draw_circle(Vector2(s * (length * 0.5 - depth * 0.12), l.end.y), depth * 0.07, Ink.INK)
	ci.draw_rect(l, Ink.INK, false, 2.5)
	ci.draw_set_transform(Vector2.ZERO)
