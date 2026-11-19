class_name FightProbeGeometry
extends RefCounted
## Geometry in world metres. Neighbours count once per unordered pair.

const COVER_M: float = 1.5


static func neighbours(positions: Array[Vector2]) -> PackedInt32Array:
	var counts: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	counts.resize(positions.size())
	for i: int in positions.size():
		for j: int in range(i + 1, positions.size()):
			if positions[i].distance_squared_to(positions[j]) <= 1.0:
				counts[i] += 1
				counts[j] += 1
	return counts


static func in_cover(at: Vector2, los: bool, boxes: Array[Rect2], cells: StageCells) -> bool:
	if los:
		return false
	for box: Rect2 in boxes:
		if at.distance_squared_to(at.clamp(box.position, box.end)) <= COVER_M * COVER_M:
			return true
	if cells != null:
		for y: int in range(floori(at.y - COVER_M) - 1, floori(at.y + COVER_M) + 1):
			for x: int in range(floori(at.x - COVER_M) - 1, floori(at.x + COVER_M) + 1):
				var corner: Vector2 = Vector2(x, y)
				var nearest: Vector2 = at.clamp(corner, corner + Vector2.ONE)
				if at.distance_squared_to(nearest) <= COVER_M * COVER_M and cells.solid(x, y):
					return true
	return false


static func mean_bearing(origin: Vector2, positions: Array[Vector2]) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for pos: Vector2 in positions:
		total += origin.direction_to(pos)
	return Vector2.ZERO if total.is_zero_approx() else total.normalized()


static func flanking(bearing: Vector2, mean_direction: Vector2) -> bool:
	return (
		not bearing.is_zero_approx()
		and not mean_direction.is_zero_approx()
		and absf(bearing.angle_to(mean_direction)) > PI / 3.0 + 0.000001
	)
