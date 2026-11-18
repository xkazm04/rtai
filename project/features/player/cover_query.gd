class_name CoverQuery
extends RefCounted
## Enemy and player API. solids maps world Rect2 to station kind (VaultProbe.boxes), or city
## bounds to texture name (VaultCity.collect). Only station solids stop shots. near returns
## faces on the asker's side, within radius_m of the standing point. By default an enemy uses
## combat.json's human radius and leans one body radius. Pass fighter-specific sizes as needed.


class CoverSpot:
	extends RefCounted
	var box: Rect2
	var at: Vector2
	var normal: Vector2
	var tangent: Vector2
	var low: bool
	var edge_a: Vector2
	var edge_b: Vector2
	var protects_shots: bool
	var distance_sq: float

	func nearer(other: CoverSpot) -> bool:
		if distance_sq != other.distance_sq:
			return distance_sq < other.distance_sq
		if box.position != other.box.position:
			return box.position < other.box.position
		if box.size != other.box.size:
			return box.size < other.box.size
		return normal < other.normal


static var _human_radius: float = -1.0


static func near(
	point: Vector2,
	radius_m: float,
	solids: Dictionary[Rect2, String],
	body_radius: float = -1.0,
	peek_m: float = -1.0
) -> Array[CoverSpot]:
	var spots: Array[CoverSpot] = []
	if body_radius < 0.0:
		if _human_radius < 0.0:
			_human_radius = CombatTuning.shipped().human["radius_m"]
		body_radius = _human_radius
	if peek_m < 0.0:
		peek_m = body_radius
	for box: Rect2 in solids:
		var nearest: Vector2 = point.clamp(box.position, box.end)
		if point.distance_to(nearest) > radius_m + body_radius:
			continue
		for n: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			if (point - nearest).dot(n) <= 0.0:
				continue
			var at: Vector2 = nearest + n * body_radius
			if point.distance_to(at) > radius_m:
				continue
			var spot: CoverSpot = _face(box, at, n, peek_m)
			spot.distance_sq = point.distance_squared_to(at)
			spot.low = solids[box] == "cover_low"
			spot.protects_shots = solids[box] in ArenaWalls.SOLID
			spots.append(spot)
	spots.sort_custom(func(a: CoverSpot, b: CoverSpot) -> bool: return a.nearer(b))
	return spots


static func protects(spot: CoverSpot, threat: Vector2) -> bool:
	return spot.protects_shots and ArenaWalls._crosses(spot.box, threat, spot.at)


static func _face(box: Rect2, at: Vector2, n: Vector2, peek_m: float) -> CoverSpot:
	var spot: CoverSpot = CoverSpot.new()
	spot.box = box
	spot.normal = n
	spot.tangent = n.orthogonal().abs()
	spot.at = at
	var t: Vector2 = spot.tangent
	spot.edge_a = at * n.abs() + (box.position.dot(t) - peek_m) * t
	spot.edge_b = at * n.abs() + (box.end.dot(t) + peek_m) * t
	return spot
