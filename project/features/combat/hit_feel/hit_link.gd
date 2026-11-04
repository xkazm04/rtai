class_name HitLink
extends RefCounted
## Wires one CombatArena's landed rounds (CombatArena.struck) into the shared HitFeel: the
## hit-stop the caller holds the play for, the victim's flash, and the knockback as a decaying
## push on the victim (dead bodies slide too: the kill reads). Knockback speeds come from the
## weapon table (knockback_mps x HitFeel.knock_scale of the weapon's hit class). Lane gunplay.

## Knockback decays by this factor each tick (about 0.15 s to a stop at 60 Hz).
const KNOCK_DECAY: float = 0.82
const KNOCK_STOP_MPS: float = 0.05
## The drawn flinch (until enemy-ai animates HitFeel.reaction): the figure leans this far along
## the hit, easing back over the reaction's ticks. View only; the sim position does not move.
const LEAN_M: float = 0.3
## The hit class a charge gun's full-charge round lands as (the electro gun's charged bolt).
const CHARGED_CLASS: StringName = &"blast"

var feel: HitFeel
## Hit-stop ticks owed to the caller (it holds the play, then sets this back to 0).
var hold: int = 0
var hits: int = 0
var kills: int = 0
var _arena: CombatArena
var _table: WeaponTable
var _knock: Dictionary[Fighter, Vector2] = {}
## The reaction in progress per target id: its end tick, direction and length.
var _react_end: Dictionary[int, int] = {}
var _react_dir: Dictionary[int, Vector2] = {}
var _react_len: Dictionary[int, int] = {}


static func make(arena: CombatArena, p_feel: HitFeel, table: WeaponTable) -> HitLink:
	var link: HitLink = HitLink.new()
	link._arena = arena
	link.feel = p_feel
	link._table = table
	@warning_ignore("return_value_discarded")
	arena.struck.connect(link._on_struck)
	@warning_ignore("return_value_discarded")
	p_feel.reaction.connect(link._on_reaction)
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


## The drawn flinch offset for `f` now (metres, zero when no reaction is running).
func lean(f: Fighter) -> Vector2:
	var end: int = _react_end.get(f.id, -1)
	if _arena.tick >= end:
		return Vector2.ZERO
	var k: float = float(end - _arena.tick) / float(maxi(_react_len[f.id], 1))
	return _react_dir[f.id] * LEAN_M * k


func _on_reaction(target_id: int, _kind: StringName, dir: Vector2, ticks: int) -> void:
	_react_end[target_id] = _arena.tick + ticks
	_react_dir[target_id] = dir.normalized()
	_react_len[target_id] = ticks


func _on_struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName) -> void:
	var spec: WeaponSpec = _table.weapons.get(weapon, null)
	var hit_class: StringName = spec.hit_class if spec != null else &"light"
	if _arena.struck_charged:  # a full charge lands as a blast: a long stop, a knockdown
		hit_class = CHARGED_CLASS
	var knock_mps: float = spec.knockback_mps if spec != null else 0.0
	hits += 1
	kills += 1 if lethal else 0
	hold = maxi(hold, feel.land(victim.id, hit_class, dir, lethal, _arena.tick))
	var push: Vector2 = dir.normalized() * knock_mps * feel.knock_scale(hit_class)
	if push != Vector2.ZERO:
		_knock[victim] = _knock.get(victim, Vector2.ZERO) + push
