class_name Fighter
extends RefCounted
## One combatant as data (Rivet, a dock guard, the quartermaster): position in metres, hp, and
## the trigger state of the weapon in hand. Views draw it; nothing here is a node (SIM-03).

enum Kind { RIVET, GUARD, BOSS }

var id: int = 0
var kind: Kind = Kind.GUARD
var pos: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
var hp: float = 1.0
var max_hp: float = 1.0
var radius_m: float = 0.45
var weapon: StringName = &""
var cooldown: int = 0
var burst_left: int = 0
var burst_gap: int = 0
## Hits land only while exposed (the boss is in cover outside his vent window).
var exposed: bool = true
var hurt_tick: int = -1000000
## Lane gunplay (GuardTell): ticks of the readable tell left before a burst; 0 = none.
var tell_left: int = 0


static func make(p_kind: Kind, p_id: int, at: Vector2, hp_max: float) -> Fighter:
	var f: Fighter = Fighter.new()
	f.kind = p_kind
	f.id = p_id
	f.pos = at
	f.hp = hp_max
	f.max_hp = hp_max
	return f


func alive() -> bool:
	return hp > 0.0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(id)
	out.put_float(pos.x)
	out.put_float(pos.y)
	out.put_float(hp)
	out.put_32(cooldown)
