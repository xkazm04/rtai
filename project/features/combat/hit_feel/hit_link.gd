class_name HitLink
extends RefCounted
## Wires one CombatArena's landed rounds (CombatArena.struck) into the shared HitFeel: the
## hit-stop the caller holds the play for, the victim's flash, and the knockback as a decaying
## push on the victim (dead bodies slide too: the kill reads). Knockback speeds come from the
## weapon table (knockback_mps x HitFeel.knock_scale of the weapon's hit class). Lane gunplay.

## Knockback decays by this factor each tick (about 0.15 s to a stop at 60 Hz).
const KNOCK_DECAY: float = 0.82
const KNOCK_STOP_MPS: float = 0.05

var feel: HitFeel
## Hit-stop ticks owed to the caller (it holds the play, then sets this back to 0).
var hold: int = 0
var hits: int = 0
var kills: int = 0
var _arena: CombatArena
var _table: WeaponTable
var _knock: Dictionary[Fighter, Vector2] = {}


static func make(arena: CombatArena, p_feel: HitFeel, table: WeaponTable) -> HitLink:
	var link: HitLink = HitLink.new()
	link._arena = arena
	link.feel = p_feel
	link._table = table
	@warning_ignore("return_value_discarded")
	arena.struck.connect(link._on_struck)
	return link


## Once per sim tick after the arena stepped: knockback moves its victims and decays.
func step() -> void:
	for f: Fighter in _knock.keys():
		var v: Vector2 = _knock[f]
		f.pos += v * SimClock.TICK_DT
		v *= KNOCK_DECAY
		if v.length() < KNOCK_STOP_MPS:
			@warning_ignore("return_value_discarded")
			_knock.erase(f)
		else:
			_knock[f] = v


## The victim's flash now (1 on the hit, fading to 0).
func flash(f: Fighter) -> float:
	return feel.flash(f.id, _arena.tick)


func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	var spec: WeaponSpec = _table.weapons.get(weapon, null)
	var hit_class: StringName = spec.hit_class if spec != null else &"light"
	var knock_mps: float = spec.knockback_mps if spec != null else 0.0
	hits += 1
	kills += 1 if lethal else 0
	hold = maxi(hold, feel.land(victim.id, hit_class, dir, lethal, _arena.tick))
	var push: Vector2 = dir.normalized() * knock_mps * feel.knock_scale(hit_class)
	if push != Vector2.ZERO:
		_knock[victim] = _knock.get(victim, Vector2.ZERO) + push
