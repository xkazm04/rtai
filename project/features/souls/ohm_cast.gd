class_name OhmCast
extends RefCounted
## A pending bolt holds the decision's aim. Targets and damage resolve on the release tick.

var delay_ticks: int
var due_tick: int = -1
var aim: Vector2
var _hurt_at_start: int


func _init(attacks: GhostAttacks) -> void:
	if LaunchArgs.value("--ohm-bolt-delay") == "on":
		delay_ticks = int(attacks.num(&"ohm", &"bolt_windup_ticks"))


func begin(tick: int, direction: Vector2, hurt: int) -> void:
	due_tick = tick + delay_ticks
	aim = direction
	_hurt_at_start = hurt


func release(tick: int, active: bool, rivet: Fighter) -> bool:
	if not active or not rivet.alive() or rivet.hurt_tick != _hurt_at_start:
		due_tick = -1
	elif tick >= due_tick:
		due_tick = -1
		return true
	return false


func write_state(out: StreamPeerBuffer) -> void:
	if delay_ticks > 0:
		out.put_32(delay_ticks)
		out.put_32(due_tick)
		if due_tick >= 0:
			out.put_float(aim.x)
			out.put_float(aim.y)
			out.put_32(_hurt_at_start)
