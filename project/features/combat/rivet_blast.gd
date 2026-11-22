class_name RivetBlast
extends RefCounted
## A weapon's blast reaches Rivet from its point of impact. The view gets the same
## ring for an occluded burst as for a hit. The damage chokepoint owns armour and roll i-frames.

const HIGH: Array[String] = ["wall_high", "cover_high"]
const WALL_IMPACT_TICK: StringName = &"rivet_blast_wall_impact_tick"


## Wall hits can burst before CombatArena.step advances the combat clock. Supply the visual
## timestamp for the duration of this arena's cull, including synchronous impact listeners.
static func cull_at_tick(
	dodges: ArenaDodges, arena: CombatArena, walls: ArenaWalls, impact_tick: int
) -> void:
	if arena.shots.is_empty():
		return
	arena.set_meta(WALL_IMPACT_TICK, impact_tick)
	dodges.cull(arena, walls)
	arena.remove_meta(WALL_IMPACT_TICK)


static func burst(arena: CombatArena, at: Vector2, weapon: StringName, by_id: int) -> float:
	var radius: float = EnemyRounds.splash_m(weapon)
	if radius <= 0.0:
		return 0.0
	var impact_tick: int = arena.get_meta(WALL_IMPACT_TICK, arena.tick)
	PlayerShock.areas_of(arena).note_blast(at, radius, impact_tick)
	var amount: float = EnemyRounds.splash_damage(weapon) * falloff(arena, at, radius)
	return hit(arena, at, amount, weapon, by_id)


static func falloff(arena: CombatArena, at: Vector2, radius: float) -> float:
	var r: Fighter = arena.rivet
	var distance: float = maxf(at.distance_to(r.pos) - r.radius_m, 0.0)
	if distance >= radius:
		return 0.0
	if arena.walls != null:
		var solids: Array[String] = ArenaWalls.SOLID if PlayerCover.active_on(r) else HIGH
		if arena.walls.blocks_kinds(at, r.pos, solids):
			return 0.0
	return 1.0 - distance / radius


static func hit(
	arena: CombatArena, at: Vector2, amount: float, weapon: StringName, by_id: int
) -> float:
	if amount <= 0.0:
		return 0.0
	var r: Fighter = arena.rivet
	var before: float = r.hp
	arena.hit_dir = at.direction_to(r.pos)
	arena.hit_at = r.pos - arena.hit_dir * r.radius_m
	arena.struck_charged = false
	arena.damage(r, amount, by_id, weapon, &"blown")
	var dealt: float = before - r.hp
	if dealt > 0.0:
		arena.struck.emit(r, arena.hit_dir, not r.alive(), weapon)
	return dealt
