class_name KillFireSource
extends RefCounted
## Which fire killed a burning human (lane kills-new, n16), view side: the sim reports every fire
## death as the weapon `burn` (FightAreas._burn), so the molotov and the flamethrower shared one
## death (burn_char). This watches CombatArena.struck for the fire weapons' direct and splash hits
## and remembers the last one per fighter; a `burn` kill then names it. A burn death with no fire
## hit on record walked into a ground fire, the molotov's own (2.2 m, 5 s; the flamethrower's
## puffs leave 0.8 m for 1.5 s), so it names `PATCH`. SignatureKills falls back to the `burn`
## row for a weapon with no row of its own. Reads the sim's signals only: no hit, damage or
## replay changes.

## The fire weapons whose hits are remembered.
const FIRES: Array[StringName] = [&"flamethrower", &"molotov"]
## The weapon a burn death with no fire hit on record names (a walk into a ground fire).
const PATCH: StringName = &"molotov"

var _last: Dictionary[int, StringName] = {}


## A source watching `arena`'s hits.
static func watch(arena: CombatArena) -> KillFireSource:
	var s: KillFireSource = KillFireSource.new()
	@warning_ignore("return_value_discarded")
	arena.struck.connect(s.on_struck)
	return s


func on_struck(victim: Fighter, _dir: Vector2, _lethal: bool, weapon: StringName) -> void:
	if victim != null and FIRES.has(weapon):
		_last[victim.id] = weapon


## The weapon a kill by `weapon` on `victim_id` names: a `burn` kill the fire that set him
## alight; any other unchanged.
func weapon_of(victim_id: int, weapon: StringName) -> StringName:
	if weapon != &"burn":
		return weapon
	return _last.get(victim_id, PATCH)
