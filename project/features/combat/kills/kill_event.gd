class_name KillEvent
extends RefCounted
## The kill event payload (lane brutality, agreed with gunplay and human-reactions in JOURNAL):
## who died, where, along which direction, by which weapon and damage type, and whether the body
## is human or undergoing an electric shutdown. Positions are metres.

const SHUTDOWN: StringName = &"melee_electric_shutdown"

var victim_id: int = 0
var archetype: StringName = &""
var at: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.RIGHT
var weapon: StringName = &""
## weapons.json hit_class of the killing blow (blast, shock, burn, ...); empty when unknown.
var damage_type: StringName = &""
var human: bool = true
var shutdown: bool = false
var facing: Vector2 = Vector2.RIGHT


static func make(victim: int, p_at: Vector2, p_dir: Vector2, p_weapon: StringName) -> KillEvent:
	var e: KillEvent = KillEvent.new()
	e.victim_id = victim
	e.at = p_at
	e.dir = p_dir
	e.weapon = p_weapon
	return e


## The event of a CombatArena fighter killed by `weapon` along `p_dir`.
static func of_fighter(f: Fighter, p_dir: Vector2, p_weapon: StringName) -> KillEvent:
	var e: KillEvent = make(f.id, f.pos, p_dir, p_weapon)
	e.archetype = f.archetype
	e.shutdown = f.has_meta(SHUTDOWN)
	e.human = f.kind != Fighter.Kind.BOSS and not f.machine and f.body_class in [&"", &"human"]
	e.facing = f.facing
	return e
