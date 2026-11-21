class_name ArenaWalls
extends RefCounted
## The arena's solid props as axis-aligned boxes: walls, high and low cover. Bodies (Rivet, the
## pit's guards) are pushed out of them; a shot whose next tick crosses one is stopped in it, both
## Rivet's and the enemies' (cover works both ways). Cones, lane marks and the firing line are
## paint and stop nothing. Which kinds are solid is SOLID below; a station adds cover by data.

const SOLID: Array[String] = ["wall_high", "cover_high", "cover_low"]

const FACE_NUDGE_M: float = 0.05

var boxes: Array[Rect2] = []
var kinds: Array[String] = []


static func from_stations(stations: ArenaStations, base: Vector2) -> ArenaWalls:
	var w: ArenaWalls = ArenaWalls.new()
	for s: ArenaStation in stations.stations:
		for p: ArenaStation.Prop in s.props:
			if p.kind in SOLID:
				w.boxes.append(Rect2(base + p.at - p.size * 0.5, p.size))
				w.kinds.append(p.kind)
	return w


## `p` moved out of every box a circle of radius `r` overlaps (the shallowest way out).
func push_out(p: Vector2, r: float) -> Vector2:
	var out: Vector2 = p
	for b: Rect2 in boxes:
		out = eject_circle(out, b, r)
	return out


## Does the segment a-b pass through any box?
func blocks(a: Vector2, b: Vector2) -> bool:
	for box: Rect2 in boxes:
		if _crosses(box, a, b):
			return true
	return false


## Blast sight line. A burst inside a prop ignores that prop. On a face, move a short way
## toward the victim to distinguish entering the solid from leaving it on the near side.
func blocks_kinds(a: Vector2, b: Vector2, accepted: Array[String]) -> bool:
	for i: int in boxes.size():
		var kind: String = kinds[i] if i < kinds.size() else "wall_high"
		if kind not in accepted:
			continue
		var box: Rect2 = boxes[i]
		if _inside(box, a):
			continue
		if a == a.clamp(box.position, box.end):
			var probe: Vector2 = a.move_toward(b, FACE_NUDGE_M).clamp(box.position, box.end)
			# The midpoint remains inside even when the probe exits through a nearby corner.
			if _inside(box, a.lerp(probe, 0.5)):
				return true
		elif _crosses(box, a, b):
			return true
	return false


static func _inside(box: Rect2, point: Vector2) -> bool:
	return (
		point.x > box.position.x
		and point.x < box.end.x
		and point.y > box.position.y
		and point.y < box.end.y
	)


static func eject_circle(p: Vector2, b: Rect2, r: float) -> Vector2:
	var near: Vector2 = p.clamp(b.position, b.end)
	var d: Vector2 = p - near
	if d != Vector2.ZERO:
		var dist: float = d.length()
		return p if dist >= r else near + d / dist * r
	var left: float = p.x - b.position.x
	var right: float = b.end.x - p.x
	var top: float = p.y - b.position.y
	var bottom: float = b.end.y - p.y
	var least: float = minf(minf(left, right), minf(top, bottom))
	if least == left:
		return Vector2(b.position.x - r, p.y)
	if least == right:
		return Vector2(b.end.x + r, p.y)
	if least == top:
		return Vector2(p.x, b.position.y - r)
	return Vector2(p.x, b.end.y + r)


static func _crosses(box: Rect2, a: Vector2, b: Vector2) -> bool:
	if box.has_point(a) or box.has_point(b):
		return true
	var c: PackedVector2Array = [
		box.position,
		Vector2(box.end.x, box.position.y),
		box.end,
		Vector2(box.position.x, box.end.y),
	]
	for i: int in 4:
		if Geometry2D.segment_intersects_segment(a, b, c[i], c[(i + 1) % 4]) != null:
			return true
	return false
