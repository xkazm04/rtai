class_name RivetBlast
extends RefCounted
## A hostile weapon's blast reaches Rivet from its point of impact. The view gets the same
## ring for an occluded burst as for a hit. The damage chokepoint owns armour and roll i-frames.

const HIGH: Array[String] = ["wall_high", "cover_high"]


static func burst(arena: CombatArena, at: Vector2, weapon: StringName, by_id: int) -> float:
	var radius: float = EnemyRounds.splash_m(weapon)
	if radius <= 0.0:
		return 0.0
	PlayerShock.areas_of(arena).note_blast(at, radius, arena.tick)
	var r: Fighter = arena.rivet
	var distance: float = maxf(at.distance_to(r.pos) - r.radius_m, 0.0)
	if distance >= radius:
		return 0.0
	if arena.walls != null:
		var solids: Array[String] = ArenaWalls.SOLID if PlayerCover.active_on(r) else HIGH
		if arena.walls.blocks_kinds(at, r.pos, solids):
			return 0.0
	var amount: float = EnemyRounds.splash_damage(weapon) * (1.0 - distance / radius)
	if amount <= 0.0:
		return 0.0
	var before: float = r.hp
	arena.hit_dir = at.direction_to(r.pos)
	arena.hit_at = r.pos - arena.hit_dir * r.radius_m
	arena.struck_charged = false
	arena.damage(r, amount, by_id, weapon, &"blown")
	var dealt: float = before - r.hp
	if dealt > 0.0:
		arena.struck.emit(r, arena.hit_dir, not r.alive(), weapon)
	return dealt
