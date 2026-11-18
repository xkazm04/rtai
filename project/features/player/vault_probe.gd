class_name VaultProbe
extends RefCounted
## A press-time query. The nearest face wins, even when its height is unknown. Other solids
## along the crossing can veto it, including city cells underneath an arena station.


class Hit:
	extends RefCounted
	var reason: StringName = &"none"
	var entry: Vector2 = Vector2.ZERO
	var landing: Vector2 = Vector2.ZERO
	var takeoff: Vector2 = Vector2.ZERO
	var touchdown: Vector2 = Vector2.ZERO
	var height: float = INF
	var depth: float = 0.0


var boxes: Dictionary[Rect2, String] = {}
var city: VaultCity
var max_height: float
var max_depth: float
var reach: float
var min_speed: float
var angle_cos: float
var land_clear: float
var heights: Dictionary[String, float] = {}


func _init(t: DataTable, row: Dictionary) -> void:
	max_height = t.num(row, "max_height_m")
	max_depth = t.num(row, "max_depth_m")
	reach = t.num(row, "reach_m")
	min_speed = t.num(row, "min_speed_mps")
	angle_cos = cos(deg_to_rad(t.num(row, "max_angle_deg")))
	land_clear = t.num(row, "land_clear_m")
	var h: Dictionary = t.object(row, "heights")
	for kind: String in h:
		heights[kind] = t.num(h, kind)


func stations(source: ArenaStations, base: Vector2) -> void:
	boxes.clear()
	for s: ArenaStation in source.stations:
		for prop: ArenaStation.Prop in s.props:
			if prop.kind in ArenaWalls.SOLID:
				var box: Rect2 = Rect2(base + prop.at - prop.size * 0.5, prop.size)
				boxes[box] = prop.kind if boxes.get(box, prop.kind) == prop.kind else ""


func clear_at(p: Vector2, r: float) -> bool:
	for box: Rect2 in boxes:
		if p.distance_squared_to(p.clamp(box.position, box.end)) < r * r:
			return false
	return city == null or city.cells.clear(p, r)


func find(p: Vector2, r: float, velocity: Vector2, heading: Vector2) -> Hit:
	var dir: Vector2 = velocity.normalized() if velocity != Vector2.ZERO else heading.normalized()
	var hit: Hit = Hit.new()
	if dir == Vector2.ZERO:
		return hit
	var nearby: Dictionary[Rect2, String] = boxes.duplicate()
	var span: float = (reach + 2.0 * r + land_clear) / angle_cos + max_depth
	if city != null:
		city.collect(Rect2(p, Vector2.ZERO).expand(p + dir * span).grow(r), nearby)
	var target: Rect2
	var nearest: Vector3 = Vector3(INF, INF, 0.0)
	for box: Rect2 in nearby:
		var ray: Vector3 = _interval(p, dir, box)
		if ray.x < nearest.x and ray.x * ray.z <= reach + r:
			target = box
			nearest = ray
	if nearest.x == INF:
		return hit
	hit.entry = p + dir * nearest.x
	hit.depth = nearest.y - nearest.x
	hit.height = heights.get(nearby[target], INF)
	var margin: float = (r + 0.001) / nearest.z
	hit.takeoff = p + dir * maxf(0.0, nearest.x - margin)
	# A diagonal ray can exit through a different face. Growing the box also clears its corners.
	var far: float = _interval(p, dir, target.grow(r + 0.001)).y
	hit.touchdown = p + dir * far
	hit.landing = p + dir * (far + land_clear)
	hit.reason = _verdict(hit, velocity.length(), nearest.z)
	if hit.reason == &"ok" and _blocked(p, r, hit.landing, target, nearby):
		hit.reason = &"landing_blocked"
	return hit


func _verdict(hit: Hit, speed: float, alignment: float) -> StringName:
	if hit.height > max_height:
		return &"too_high"
	if speed < min_speed:
		return &"too_slow"
	if alignment < angle_cos:
		return &"bad_angle"
	if hit.depth > max_depth:
		return &"too_deep"
	return &"ok"


func _blocked(p: Vector2, r: float, end: Vector2, target: Rect2, nearby: Dictionary) -> bool:
	if not clear_at(p, r) or not clear_at(end, r):
		return true
	var dir: Vector2 = p.direction_to(end)
	for box: Rect2 in nearby:
		if box != target and _interval(p, dir, box.grow(r)).x <= p.distance_to(end):
			return true
	return false


## Ray/box slab entry, exit, and cosine against the entry face normal. Misses return INF.
static func _interval(p: Vector2, dir: Vector2, box: Rect2) -> Vector3:
	var enter: float = -INF
	var leave: float = INF
	var alignment: float = 0.0
	for axis: int in 2:
		if dir[axis] == 0.0:
			if p[axis] < box.position[axis] or p[axis] > box.end[axis]:
				return Vector3(INF, INF, 0.0)
			continue
		var a: float = (box.position[axis] - p[axis]) / dir[axis]
		var b: float = (box.end[axis] - p[axis]) / dir[axis]
		if minf(a, b) > enter:
			enter = minf(a, b)
			alignment = absf(dir[axis])
		leave = minf(leave, maxf(a, b))
	if leave < maxf(0.0, enter):
		return Vector3(INF, INF, 0.0)
	return Vector3(maxf(0.0, enter), leave, alignment)
