class_name ArenaProjectiles
extends RefCounted
## Advances the arena's rounds and arc balls in spawn order, reporting hits to CombatArena.


static func step_shots(arena: CombatArena) -> void:
	for s: Shot in arena.shots.duplicate():
		if not s.from_rivet and s.spec == null and not s.size_known:
			s.size = EnemyRounds.size_of(s.weapon)
		if not s.from_rivet and EnemyRounds.splash_m(s.weapon) > 0.0:
			_step_blast(arena, s)
			continue
		var lands: bool = s.spec != null and arena.areas != null
		if lands and s.spec.homing_rad_per_tick > 0.0:
			FightReach.home(arena, s)
		var from: Vector2 = s.advance()
		# A thrown bottle flies over bodies and lands at the aimed point.
		var over: bool = lands and s.spec.kind == WeaponSpec.Kind.THROWN
		var victim: Fighter = null if over else _struck(arena, s, from)
		if victim == arena.rivet and arena.guard != null and arena.guard.deflect(arena, s, from):
			continue
		var ends: bool = victim != null or s.spent() or _blocked(arena, s, from)
		if victim != null:
			arena.hit_at = Geometry2D.get_closest_point_to_segment(victim.pos, from, s.pos)
		arena.struck_charged = s.charged
		if lands and ends:
			arena.areas.land(arena, s, victim, arena.hit_at if victim != null else s.pos)
		elif victim != null:
			arena.hit_dir = s.vel.normalized()
			arena.damage(victim, s.damage, s.shooter_id, s.weapon)
			arena.struck.emit(victim, arena.hit_dir, not victim.alive(), s.weapon)
		if ends:
			arena.shots.erase(s)


## Stop at the authored range even when the last tick would carry the round past it.
static func _blast_tip(s: Shot) -> Vector2:
	return s.pos.move_toward(s.pos + s.vel * SimClock.TICK_DT, maxf(s.left_m, 0.0))


## The first point on Rivet's body along the bounded flight segment, or INF for a miss.
static func _rivet_contact(r: Fighter, from: Vector2, to: Vector2) -> Vector2:
	if not r.alive():
		return Vector2.INF
	if from.distance_to(r.pos) <= r.radius_m:
		return from
	if from == to:
		return Vector2.INF
	var t: float = Geometry2D.segment_intersects_circle(from, to, r.pos, r.radius_m)
	return from.lerp(to, t) if t >= 0.0 else Vector2.INF


## A hostile shell can be spawned after the stage culls shots. Both paths use its first impact.
static func burst_at_wall(arena: CombatArena, s: Shot, walls: ArenaWalls) -> bool:
	var end: Vector2 = _blast_tip(s)
	var at: Vector2 = _first_wall(walls, s.pos, end)
	if at == Vector2.INF or _rivet_contact(arena.rivet, s.pos, at) != Vector2.INF:
		return false
	arena.shots.erase(s)
	@warning_ignore("return_value_discarded")
	RivetBlast.burst(arena, at, s.weapon, s.shooter_id)
	return true


static func _first_wall(walls: ArenaWalls, from: Vector2, to: Vector2) -> Vector2:
	var closest: Vector2 = Vector2.INF
	var start: Vector3 = Vector3(from.x, from.y, 0.0)
	var end: Vector3 = Vector3(to.x, to.y, 0.0)
	for box: Rect2 in walls.boxes:
		if from == from.clamp(box.position, box.end):
			return from
		var slab: AABB = AABB(
			Vector3(box.position.x, box.position.y, -1), Vector3(box.size.x, box.size.y, 2)
		)
		var intersection: Variant = slab.intersects_segment(start, end)
		if intersection == null:
			continue
		var hit: Vector3 = intersection
		var point: Vector2 = Vector2(hit.x, hit.y).clamp(box.position, box.end)
		point = ArenaWalls.eject_circle(point, box, 0.0)
		if from.distance_squared_to(point) < from.distance_squared_to(closest):
			closest = point
	return closest


static func _step_blast(arena: CombatArena, s: Shot) -> void:
	if arena.walls != null and burst_at_wall(arena, s, arena.walls):
		return
	var tip: Vector2 = _blast_tip(s)
	var from: Vector2 = s.advance()
	s.pos = tip
	var at: Vector2 = _rivet_contact(arena.rivet, from, tip)
	if at == Vector2.INF and not s.spent():
		return
	arena.shots.erase(s)
	@warning_ignore("return_value_discarded")
	RivetBlast.burst(arena, tip if at == Vector2.INF else at, s.weapon, s.shooter_id)


static func _struck(arena: CombatArena, s: Shot, from: Vector2) -> Fighter:
	if not s.from_rivet:
		return (
			arena.rivet
			if arena.rivet.alive() and s.crossed(from, arena.rivet.pos, arena.rivet.radius_m)
			else null
		)
	for h: Fighter in arena.hostiles:
		if h.alive() and h.exposed and s.crossed(from, h.pos, h.radius_m):
			return h
	return null


## A nail at the boss while he is in cover stops in the crates in front of him.
static func _blocked(arena: CombatArena, s: Shot, from: Vector2) -> bool:
	return (
		s.from_rivet
		and arena.boss != null
		and arena.boss.alive()
		and not arena.boss.exposed
		and (s.crossed(from, arena.boss.pos, arena.boss.radius_m + 0.6))
	)


static func step_balls(arena: CombatArena, events: EventBus) -> void:
	for b: ArcBall in arena.balls.duplicate():
		b.step(arena.rivet.pos, arena.rivet.radius_m, arena.metal)
		if b.burst:
			arena.balls.erase(b)
			if b.hit_rivet:
				arena.tazer_hits += 1
				arena.tazer_hit_now = true
				events.player_hit.emit(&"robo-tazer")
				arena.damage(
					arena.rivet,
					arena.tuning.tazer["damage"],
					arena.boss.id if arena.boss != null else 0,
					&"robo-tazer"
				)
			arena.burst_arcs.append(b.arcs)
	if arena.burst_arcs.size() > 8:
		arena.burst_arcs = arena.burst_arcs.slice(arena.burst_arcs.size() - 8)
