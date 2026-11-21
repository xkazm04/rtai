class_name FoeRocketFlight
extends RefCounted
## The squad retains each launched round until normal arena damage, cover or range spends it.
## Guard's splash handler can connect here. ArenaProjectiles owns the direct hit.
signal burst(at: Vector2, radius_m: float, shot: Shot)


class Round:
	extends Shot
	signal landed(shot: Round, at: Vector2)
	var rivet: Fighter
	var target: Vector2
	var previous: Vector2
	var radius_m: float

	func advance() -> Vector2:
		if from_rivet:
			return super.advance()
		previous = pos
		pos = pos.move_toward(target, vel.length() * SimClock.TICK_DT)
		left_m = pos.distance_to(target)
		if spent() and (not rivet.alive() or not crossed(previous, rivet.pos, rivet.radius_m)):
			landed.emit(self, pos)
		return previous


var _live: Array[Round] = []


func count() -> int:
	return _live.size()


func launch(
	h: Fighter, w: EnemyWeapon, target: Vector2, arena: CombatArena, map: GuardRouteMap
) -> Round:
	if not arena.struck.is_connected(_struck):
		@warning_ignore("return_value_discarded")
		arena.struck.connect(_struck)
	var s: Round = Round.new()
	FoeAttacks.equip_round(s, h, w)
	var wall: Vector2 = first_wall(h.pos, target, map)
	s.target = wall if wall.is_finite() else target
	if h.pos.distance_to(s.target) < h.pos.distance_to(s.pos):
		s.pos = h.pos
		s.origin = h.pos
	s.vel = s.pos.direction_to(s.target) * w.speed_mps
	s.previous = s.pos
	s.radius_m = w.splash_radius_m
	s.left_m = s.pos.distance_to(s.target)
	s.rivet = arena.rivet
	@warning_ignore("return_value_discarded")
	s.landed.connect(_finish)
	_live.append(s)
	return s


## ArenaDodges culls before assign. A culled round is still at its last clear position.
## Use the prop face when the route map knows it, including city solids.
func collect(arena: CombatArena, map: GuardRouteMap) -> void:
	for i: int in range(_live.size() - 1, -1, -1):
		var s: Round = _live[i]
		if arena.shots.has(s):
			continue
		if s.from_rivet:
			_live.remove_at(i)
		else:
			var at: Vector2 = s.pos
			if not s.spent():
				var end: Vector2 = s.pos.move_toward(s.target, s.vel.length() * SimClock.TICK_DT)
				var wall: Vector2 = first_wall(s.pos, end, map)
				if wall.is_finite():
					at = wall
			_finish(s, at)


## Resolve direct impacts in the same tick, including the shot that kills Rivet.
func _struck(victim: Fighter, _dir: Vector2, _lethal: bool, weapon: StringName) -> void:
	if victim.kind != Fighter.Kind.RIVET:
		return
	for s: Round in _live:
		if (
			s.weapon == weapon
			and not s.from_rivet
			and s.previous != s.pos
			and s.crossed(s.previous, victim.pos, victim.radius_m)
		):
			var at: Vector2 = Geometry2D.get_closest_point_to_segment(victim.pos, s.previous, s.pos)
			_finish(s, at)
			return


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
