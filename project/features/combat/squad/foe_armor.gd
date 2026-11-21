class_name FoeArmor
extends RefCounted

static var _blast_weapons: Dictionary[StringName, bool] = {}


static func impact(
	arena: CombatArena, h: Fighter, kind: StringName, killer: int, weapon: StringName
) -> float:
	var squad: ArenaSquad = arena.squad_ai
	var ray: Vector2 = arena.hit_dir
	var own_plate: float = k(h, ray, kind, squad)
	if squad == null or squad.shield_cover.carriers.is_empty() or not squad.owns(h):
		return own_plate
	# FightAreas classifies small detonations by their weapon's death kind. The
	# shard explodes on contact even when its kill says "shot"; firebombs say "burned".
	if _detonates(weapon):
		return 1.0 if h.archetype == &"shield_robot" else own_plate
	if kind != &"shot" or killer != arena.rivet.id or ray.is_zero_approx():
		return own_plate
	if own_plate < 1.0 and h.archetype == &"shield_robot":
		var mind: SquadMind = squad.minds.get(h.id)
		if mind != null:
			mind.shield.block_tick = arena.tick
			mind.shield.block_dir = ray.normalized()
	var row: EnemyRoster.Archetype = squad.pit.roster.archetype(&"shield_robot")
	return minf(own_plate, squad.shield_cover.multiplier(h, ray.normalized(), arena.rivet, row))


static func _detonates(weapon: StringName) -> bool:
	if _blast_weapons.is_empty():
		var table: WeaponTable = WeaponTable.shipped()
		for w: WeaponSpec in table.weapons.values():
			if w.splash_radius_m > 0.0:
				_blast_weapons[w.id] = true
	return _blast_weapons.has(weapon)


## hit_dir follows the projectile into the victim. Blasts and directionless damage bypass plates.
static func k(h: Fighter, hit_dir: Vector2, kind: StringName, squad: ArenaSquad) -> float:
	if squad == null or h.archetype == &"" or kind == &"blown" or hit_dir.is_zero_approx():
		return 1.0
	var arch: EnemyRoster.Archetype = squad.pit.roster.archetype(h.archetype)
	if (
		arch != null
		and arch.explicit_spawn
		and h.facing.dot(-hit_dir.normalized()) >= arch.shield_cos
	):
		return arch.shield_front_mult
	return 1.0
