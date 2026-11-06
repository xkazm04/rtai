class_name StageGuns
extends RefCounted
## Quest 1 fires the table guns (lane n7-ranged, gunplay's next step 4): each tick before the
## pilot fires, the arena's GunHand follows Rivet's weapon. A weapon with a weapons.json row
## (Gloria, from Brass's line) fires as that row (WeaponFxArt muzzle, casings, the table cue, the
## hit feel's per-weapon rows, HitLink's slide); a weapon without one (the contractors' assault
## rifle he picks up, combat.json) keeps the quest's own path, so its magazine still runs dry into
## Gloria. Off (Quest1Session.table_guns false, `--quest-guns=off`) = the evening path for every
## weapon (the before). Sim state: it moves quest 1's replay (DECISION 2026-11-05).

var table: WeaponTable
## A held fire re-taps a semi gun as soon as it is ready: the quest's evening path fired Gloria
## every cooldown while held, and its recorded inputs hold the button.
var tap: bool = true
var _rng: RandomNumberGenerator
var _weapon: StringName = &""


static func make(rng: RandomNumberGenerator, p_table: WeaponTable = null) -> StageGuns:
	var g: StageGuns = StageGuns.new()
	g.table = p_table if p_table != null else WeaponTable.shipped()
	g._rng = rng
	return g


## Arms `arena.gun` for Rivet's weapon when it changed (a pickup, Brass's line, the rifle dry).
func sync(arena: CombatArena) -> void:
	var weapon: StringName = arena.rivet.weapon
	if weapon == _weapon:
		return
	_weapon = weapon
	if table.weapons.has(weapon):
		arena.gun = GunHand.make(table, weapon, _rng)
		arena.gun.tap = tap
	else:
		arena.gun = null
