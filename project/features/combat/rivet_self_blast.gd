class_name RivetSelfBlast
extends RefCounted
## Rivet's rounds use the same table-to-fighter HP conversion as their splash against hostiles.

const WAVE_DAMAGE: StringName = &"rivet_self_blast_wave_damage"

static var self_k: float = _load_multiplier()


static func land(arena: CombatArena, shot: Shot, at: Vector2, hp_scale: float) -> void:
	if not shot.from_rivet:
		return
	var w: WeaponSpec = shot.spec
	var base: float = w.splash_damage * hp_scale
	var amount: float = base * RivetBlast.falloff(arena, at, w.splash_radius_m) * self_k
	var lost: float = RivetBlast.hit(arena, at, amount, w.id, arena.rivet.id)
	if lost > 0.0 and arena is GauntletCombat:
		var run: GauntletRun = (arena as GauntletCombat).run
		# Between waves the previous row is already sealed. Its shots can still be in flight.
		if not run.waves.is_empty() and not run.waves[-1].has("self_damage"):
			var previous: float = run.get_meta(WAVE_DAMAGE, 0.0)
			run.set_meta(WAVE_DAMAGE, previous + lost)


## Consume the unrounded interval total. The result writer formats it just like damage_taken.
static func finish_wave(arena: CombatArena) -> float:
	if arena is GauntletCombat:
		var run: GauntletRun = (arena as GauntletCombat).run
		if run.has_meta(WAVE_DAMAGE):
			var lost: float = run.get_meta(WAVE_DAMAGE)
			run.remove_meta(WAVE_DAMAGE)
			return lost
	return 0.0


static func _load_multiplier() -> float:
	var table: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var value: float = table.num(table.object(table.raw, "blast"), "self_k")
	if not table.ok():
		Log.error("rivet_self_blast", str(table.errors()))
	return value
