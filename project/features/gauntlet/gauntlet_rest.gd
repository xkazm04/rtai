class_name GauntletRest
extends RefCounted
## A prone body occupies a square footprint. Project its centre into the road and outside the
## grown solid rectangles. The closest free centre lies on a projected face or two faces' corner.

var _road: Rect2
var _boxes: Array[Rect2]


func _init(road: Rect2, boxes: Array[Rect2]) -> void:
	_road = road
	_boxes = boxes


func solid_px(px: Vector2) -> bool:
	var point: Vector2 = px / SimConst.PX_PER_M
	if not _road.has_point(point):
		return true
	for box: Rect2 in _boxes:
		if box.has_point(point):
			return true
	return false


func place(foe: Fighter) -> void:
	# Leave room for a recumbent human or the larger powered-down robot silhouette.
	var radius: float = maxf(foe.radius_m, 2.0 if foe.machine else 1.15)
	foe.pos = nearest(foe.pos, radius)


func nearest(at: Vector2, radius: float) -> Vector2:
	var road: Rect2 = _road.grow(-radius)
	var p: Vector2 = at.clamp(road.position, road.end)
	if _free(p, radius):
		return p
	var xs: Array[float] = [p.x]
	var ys: Array[float] = [p.y]
	for box: Rect2 in _boxes:
		var edge: Rect2 = box.grow(radius)
		xs.append(clampf(edge.position.x, road.position.x, road.end.x))
		xs.append(clampf(edge.end.x, road.position.x, road.end.x))
		ys.append(clampf(edge.position.y, road.position.y, road.end.y))
		ys.append(clampf(edge.end.y, road.position.y, road.end.y))
	var best: Vector2 = p
	var distance: float = INF
	for x: float in xs:
		for y: float in ys:
			var candidate: Vector2 = Vector2(x, y)
			var d: float = candidate.distance_squared_to(at)
			if d < distance and _free(candidate, radius):
				best = candidate
				distance = d
	return best


func _free(p: Vector2, radius: float) -> bool:
	for box: Rect2 in _boxes:
		var edge: Rect2 = box.grow(radius)
		if (
			p.x > edge.position.x
			and p.x < edge.end.x
			and p.y > edge.position.y
			and p.y < edge.end.y
		):
			return false
	return true
