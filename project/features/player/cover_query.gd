class_name CoverQuery
extends RefCounted
## Station and city face queries for enemies and Rivet. The API holds no player state.


class CoverSpot:
	extends RefCounted
	var box: Rect2
	var at: Vector2
	var normal: Vector2
	var tangent: Vector2
	var low: bool
	var edge_a: Vector2
	var edge_b: Vector2
	## True for the station solid kinds whose boxes stop ordinary shots in ArenaDodges.cull.
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


## Finds outward faces whose standing point is within radius_m of point, both in world metres.
## solids maps world boxes (Rect2) to station kinds (VaultProbe.boxes) or city kinds
## (VaultCity.collect).
## body_radius offsets the fighter from the face, and peek_m extends each end along its tangent.
## Both are metres. Negative defaults use the combat table's human radius and one body radius
## respectively. City faces are returned with protects_shots false.
## Results sort by increasing squared distance, then box position, box size and normal (x then y).
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


## Tests the segment from threat (world metres) to spot.at against the selected box. True only
## when the station stops ordinary shots under ArenaDodges.cull and ArenaWalls.blocks crosses it.
static func protects(spot: CoverSpot, threat: Vector2) -> bool:
	if not spot.protects_shots:
		return false
	var wall: ArenaWalls = ArenaWalls.new()
	wall.boxes.append(spot.box)
	return wall.blocks(threat, spot.at)


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
