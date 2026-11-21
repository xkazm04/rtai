class_name FoeArmor
extends RefCounted


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
