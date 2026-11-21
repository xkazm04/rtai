class_name FoeAttacks
extends RefCounted
## Explicit gauntlet spawns fire their enemies.json rounds in the arena's normal projectile loop.


static func trigger(e: EnemyAgent, h: Fighter, arena: CombatArena) -> Shot:
	h.cooldown = maxi(0, h.cooldown - 1)
	if not e.token or not e.has_shot_at(arena.rivet.pos):
		h.burst_left = 0
		h.swing_left = 0
		return null
	var alt: EnemyWeapon = e.arch.alt_weapon
	if alt != null and (h.swing_left > 0 or h.pos.distance_to(arena.rivet.pos) <= alt.reach_m):
		_stomp(e, h, arena, alt)
		return null
	var w: EnemyWeapon = e.arch.weapon
	if h.burst_left == 0:
		if h.cooldown > 0:
			return null
		h.burst_left = w.burst
		h.burst_gap = 0
	if h.burst_gap > 0:
		h.burst_gap -= 1
		return null
	h.burst_left -= 1
	h.burst_gap = w.burst_gap_ticks
	if h.burst_left == 0:
		h.cooldown = w.cooldown_ticks
	e.shot_tick = arena.tick
	e.state = EnemyAgent.State.FIRE
	return round_from(h, w)


static func round_from(h: Fighter, w: EnemyWeapon) -> Shot:
	var shot: Shot = Shot.new()
	equip_round(shot, h, w)
	return shot


static func equip_round(shot: Shot, h: Fighter, w: EnemyWeapon) -> void:
	shot.pos = h.pos + h.facing * (h.radius_m + 0.1)
	shot.origin = shot.pos
	shot.vel = h.facing * w.speed_mps
	shot.from_rivet = false
	shot.weapon = w.id
	shot.damage = w.damage
	shot.left_m = w.reach_m
	shot.shooter_id = h.id


static func melee_hit(e: EnemyAgent, arena: CombatArena, map: GuardRouteMap) -> void:
	arena.hit_dir = e.aim
	arena.hit_at = arena.rivet.pos
	arena.damage(arena.rivet, e.arch.production_damage, e.id, e.arch.weapon.id, &"melee")
	if e.arch.weapon.knockback_m > 0.0:
		var end: Vector2 = arena.rivet.pos + e.aim * e.arch.weapon.knockback_m
		if map.region().has_point(end) and map.clear_line(arena.rivet.pos, end):
			arena.rivet.pos = end


static func _stomp(e: EnemyAgent, h: Fighter, arena: CombatArena, w: EnemyWeapon) -> void:
	if h.swing_left == 0:
		if h.cooldown > 0:
			return
		h.swing_tick = arena.tick
		h.swing_left = e.arch.telegraph_ticks
		e.state = EnemyAgent.State.WINDUP
		arena.announce_tell(w.id)
		return
	h.swing_left -= 1
	e.state = EnemyAgent.State.WINDUP
	if h.swing_left > 0:
		return
	e.shot_tick = arena.tick
	e.state = EnemyAgent.State.FIRE
	h.cooldown = w.cooldown_ticks
	e.token = false
	if h.pos.distance_to(arena.rivet.pos) <= w.splash_radius_m:
		arena.hit_dir = h.pos.direction_to(arena.rivet.pos)
		arena.hit_at = arena.rivet.pos
		arena.damage(arena.rivet, w.splash_damage, h.id, w.id, &"blown")


## Plant for the row's tell, then resolve the locked arc against Rivet's current position.
static func swing(mind: SquadMind, h: Fighter, arena: CombatArena, map: GuardRouteMap) -> void:
	var e: EnemyAgent = mind.agent
	e.cooldown = maxi(0, e.cooldown - 1)
	if not e.token or mind.motion == EnemyAgent.State.PANIC:
		h.swing_left = 0
		return
	var to: Vector2 = arena.rivet.pos - h.pos
	var reach: float = e.arch.weapon.reach_m + arena.rivet.radius_m
	if h.swing_left == 0:
		if not e.sees or to.length() > reach or e.cooldown > 0:
			return
		h.swing_tick = arena.tick
		h.swing_left = e.arch.telegraph_ticks
		e.aim = to.normalized()
		arena.announce_tell(e.arch.weapon.id)
	else:
		h.swing_left -= 1
	e.state = EnemyAgent.State.WINDUP
	h.facing = e.aim
	if h.swing_left > 0:
		return
	e.state = EnemyAgent.State.FIRE
	e.cooldown = e.arch.weapon.cooldown_ticks
	e.token = false
	if to.length() <= reach and e.aim.dot(to.normalized()) >= EnemyPit.MELEE_ARC_COS:
		if map.sight_line(h.pos, arena.rivet.pos):
			FoeAttacks.melee_hit(e, arena, map)
