class_name VehicleDoorPath
extends RefCounted
## Sweep Rivet's foot circle through the world's actual solid cells and oriented car hulls.
## Both endpoints, edges and round corners count, even on the first use-key tick.

const HALF: Vector2 = Vector2(VehicleView.CAR_L, VehicleView.CAR_W) * 0.5 / SimConst.PX_PER_M


static func driver_door(b: VehicleBody, radius: float) -> Vector2:
	return b.pos + offset(b.head, radius)


static func offset(head: Vector2, radius: float) -> Vector2:
	var width: float = maxf(VehicleService.DOOR_OFF, HALF.y + radius + 0.001)
	return head.orthogonal() * width


static func clear(svc: VehicleService, a: Vector2, b: Vector2, r: float) -> bool:
	var bounds: Rect2 = Rect2(a, Vector2.ZERO).expand(b).grow(r)
	for y: int in range(floori(bounds.position.y), floori(bounds.end.y) + 1):
		for x: int in range(floori(bounds.position.x), floori(bounds.end.x) + 1):
			if svc.world.solid(x + 0.5, y + 0.5) and _hits(a, b, r, Rect2(x, y, 1, 1)):
				return false
	for car: VehicleBody in svc.cars:
		if _hull(a, b, r, car.pos, car.head):
			return false
	var reach: float = a.distance_to(b) + HALF.length() + r
	var cars: PackedFloat64Array = svc.world.cars_near(a, reach)
	for i: int in range(0, cars.size(), VehicleWorld.CAR_STRIDE):
		var at: Vector2 = Vector2(cars[i + 2], cars[i + 3])
		var head: Vector2 = Vector2(cars[i + 4], cars[i + 5])
		if _hull(a, b, r, at, head):
			return false
	return true


static func _hull(a: Vector2, b: Vector2, r: float, at: Vector2, head: Vector2) -> bool:
	var side: Vector2 = head.orthogonal()
	var p: Vector2 = Vector2((a - at).dot(head), (a - at).dot(side))
	var q: Vector2 = Vector2((b - at).dot(head), (b - at).dot(side))
	return _hits(p, q, r, Rect2(-HALF, 2.0 * HALF))


static func _hits(a: Vector2, b: Vector2, r: float, box: Rect2) -> bool:
	for p: Vector2 in [a, b]:
		if p.distance_squared_to(p.clamp(box.position, box.end)) < r * r:
			return true
	if a == b:
		return false
	var corners: PackedVector2Array = [
		box.position,
		Vector2(box.end.x, box.position.y),
		box.end,
		Vector2(box.position.x, box.end.y)
	]
	for i: int in 4:
		var c: Vector2 = corners[i]
		if Geometry2D.segment_intersects_segment(a, b, c, corners[(i + 1) % 4]) != null:
			return true
		if c.distance_squared_to(Geometry2D.get_closest_point_to_segment(c, a, b)) < r * r:
			return true
	return false


## A moving bail still completes in one tick. Prefer the driver's side, then other clear
## footing around the same hull when that door opens into a wall or another car.
static func clear_side(svc: VehicleService, car: VehicleBody, radius: float) -> Vector2:
	var side: Vector2 = driver_door(car, radius) - car.pos
	for away: Vector2 in [
		side, -side, car.head * (HALF.x + radius + 0.001), -car.head * (HALF.x + radius + 0.001)
	]:
		for extra: int in 4:
			var p: Vector2 = car.pos + away + away.normalized() * float(extra)
			if clear(svc, p, p, radius):
				return p
	return Vector2.INF
