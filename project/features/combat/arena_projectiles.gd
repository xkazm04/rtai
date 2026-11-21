class_name ArenaProjectiles
extends RefCounted
## Advances the arena's rounds and arc balls in spawn order, reporting hits to CombatArena.


static func step_shots(arena: CombatArena) -> void:
	for s: Shot in arena.shots.duplicate():
		if not s.from_rivet and s.spec == null and not s.size_known:
			s.size = EnemyRounds.size_of(s.weapon)
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
