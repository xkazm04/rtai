class_name FoeArmor
extends RefCounted

const REAR_COS: float = -0.70710678

static var _blast_weapons: Dictionary[StringName, bool] = {}


static func impact(
	arena: CombatArena, h: Fighter, kind: StringName, killer: int, weapon: StringName
) -> float:
	var squad: ArenaSquad = arena.squad_ai
	var ray: Vector2 = arena.hit_dir
	if h.archetype == &"war_machine" and _detonates(weapon):
		return 1.0
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
	var cover: float = squad.shield_cover.multiplier(h, ray.normalized(), arena, row)
	return minf(cover, own_plate) if cover < 1.0 else own_plate


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
	if arch == null or not arch.explicit_spawn:
		return 1.0
	if OhmShortCircuit.held(squad, h) and squad.shield_cover.carriers.has(h):
		return 1.0
	var bearing: float = h.facing.dot(-hit_dir.normalized())
	if bearing >= arch.shield_cos:
		return arch.shield_front_mult
	return arch.rear_mult if bearing <= REAR_COS else 1.0
