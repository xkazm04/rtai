class_name FoeRocketFlight
extends RefCounted
## The squad retains each launched round until normal arena damage, cover or range spends it.
## Observers get the resolved impact after ArenaProjectiles has dealt its blast.
signal burst(at: Vector2, radius_m: float, shot: Shot)


class Round:
	extends Shot
	signal landed(shot: Round, at: Vector2)
	var target: Vector2
	var radius_m: float

	func blast_tip() -> Vector2:
		return pos.move_toward(target, vel.length() * SimClock.TICK_DT)

	func advance() -> Vector2:
		if from_rivet:
			return super.advance()
		var previous: Vector2 = pos
		pos = blast_tip()
		left_m = pos.distance_to(target)
		return previous


var _live: Array[Round] = []


func count() -> int:
	return _live.size()


func launch(h: Fighter, w: EnemyWeapon, target: Vector2, map: GuardRouteMap) -> Round:
	var s: Round = Round.new()
	FoeAttacks.equip_round(s, h, w)
	var wall: Vector2 = first_wall(h.pos, target, map)
	s.target = wall if wall.is_finite() else target
	if h.pos.distance_to(s.target) < h.pos.distance_to(s.pos):
		s.pos = h.pos
		s.origin = h.pos
	s.vel = s.pos.direction_to(s.target) * w.speed_mps
	s.radius_m = w.splash_radius_m
	s.left_m = s.pos.distance_to(s.target)
	@warning_ignore("return_value_discarded")
	s.landed.connect(_finish)
	_live.append(s)
	return s


## Forget reflected or otherwise retired rounds without creating an impact.
func collect(arena: CombatArena) -> void:
	for i: int in range(_live.size() - 1, -1, -1):
		if not arena.shots.has(_live[i]):
			_live.remove_at(i)


func _finish(s: Round, at: Vector2) -> void:
	_live.erase(s)
	burst.emit(at, s.radius_m, s)


static func first_wall(start: Vector2, end: Vector2, map: GuardRouteMap) -> Vector2:
	var nearest: Vector2 = Vector2.INF
	for box: Rect2 in map.boxes_near(start, start.distance_to(end)):
		var slab: AABB = AABB(
			Vector3(box.position.x, box.position.y, -1), Vector3(box.size.x, box.size.y, 2)
		)
		var hit: Variant = slab.intersects_segment(
			Vector3(start.x, start.y, 0), Vector3(end.x, end.y, 0)
		)
		if hit is Vector3:
			var crossing: Vector3 = hit
			var point: Vector2 = Vector2(crossing.x, crossing.y)
			if point.distance_squared_to(start) < nearest.distance_squared_to(start):
				nearest = point
	return nearest
