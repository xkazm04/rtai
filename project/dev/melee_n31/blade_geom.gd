class_name BladeGeom
extends RefCounted
## n31 melee 01a: the pure geometry of "the blade passes through and nothing happens". A drawn
## volume (the blade segment grip to tip, the swipe crescent polygon) against a body circle, and
## the compare of the drawn set with the hit set over a ring of cells. Metres in, no state.


## True when the segment a-b comes within `r` of `c` (touches the body circle).
static func seg_hits_circle(a: Vector2, b: Vector2, c: Vector2, r: float) -> bool:
	var ab: Vector2 = b - a
	var len2: float = ab.length_squared()
	var t: float = 0.0 if len2 < 1e-9 else clampf((c - a).dot(ab) / len2, 0.0, 1.0)
	return (a + ab * t).distance_to(c) <= r


## True when the closed polygon covers `c` or any of its edges touches the circle.
static func poly_hits_circle(poly: PackedVector2Array, c: Vector2, r: float) -> bool:
	if poly.size() < 3:
		return false
	if Geometry2D.is_point_in_polygon(c, poly):
		return true
	for i: int in poly.size():
		if seg_hits_circle(poly[i], poly[(i + 1) % poly.size()], c, r):
			return true
	return false


## One drawn frame against a body: `frame` holds "blade" ([grip, tip] or empty) and
## "crescent" (a polygon or empty).
static func frame_hits(frame: Dictionary, c: Vector2, r: float) -> bool:
	var blade: PackedVector2Array = frame.get("blade", PackedVector2Array())
	if blade.size() == 2 and seg_hits_circle(blade[0], blade[1], c, r):
		return true
	var crescent: PackedVector2Array = frame.get("crescent", PackedVector2Array())
	return poly_hits_circle(crescent, c, r)


## The compare over cells, each {"drawn": bool, "hit": bool}: the four counts.
static func compare(cells: Array[Dictionary]) -> Dictionary:
	var out: Dictionary = {"drawn_no_hit": 0, "hit_not_drawn": 0, "both": 0, "neither": 0}
	for cell: Dictionary in cells:
		var drawn: bool = cell.get("drawn", false)
		var hit: bool = cell.get("hit", false)
		var key: String = "both" if drawn and hit else "neither"
		if drawn != hit:
			key = "drawn_no_hit" if drawn else "hit_not_drawn"
		var n: int = out[key]
		out[key] = n + 1
	return out
