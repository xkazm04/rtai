class_name DummyWalkers
extends WorldSystem
## Test-only sim system (F-05 replay scenario): walkers on a wrapping arena, steered by their own
## RNG stream and the tick's input, integrated with the fixed TICK_DT in doubles. Every
## KILL_EVERY ticks one dies (actor_killed, payload complete before the respawn) and respawns.

const COUNT: int = 24
const SPEED: float = 90.0
const ARENA: float = 512.0
const KILL_EVERY: int = 45

var _ctx: WorldContext
var _rng: RandomNumberGenerator
var _pos: Array[float] = []
var _heading: Array[float] = []


func setup(ctx: WorldContext) -> void:
	_ctx = ctx
	_rng = ctx.rng.stream(&"dummy_walkers")
	for i: int in COUNT:
		_pos.append(0.0)
		_pos.append(0.0)
		_heading.append(0.0)
		_respawn(i)


func step(tick: int, input: TickInput) -> void:
	var push_x: float = float(input.move_x) / TickInput.AXIS_MAX * SPEED
	var push_y: float = float(input.move_y) / TickInput.AXIS_MAX * SPEED
	for i: int in COUNT:
		_heading[i] += _rng.randfn(0.0, 0.2)
		var vx: float = cos(_heading[i]) * SPEED + push_x
		var vy: float = sin(_heading[i]) * SPEED + push_y
		_pos[i * 2] = fposmod(_pos[i * 2] + vx * SimClock.TICK_DT, ARENA)
		_pos[i * 2 + 1] = fposmod(_pos[i * 2 + 1] + vy * SimClock.TICK_DT, ARENA)
	if tick % KILL_EVERY == 0:
		var victim: int = _rng.randi_range(0, COUNT - 1)
		var kind: StringName = &"shot" if input.is_pressed(0) else &"stamped"
		_ctx.events.actor_killed.emit(0, victim, kind)
		_respawn(victim)


func write_state(out: StreamPeerBuffer) -> void:
	for value: float in _pos:
		out.put_double(value)
	for value: float in _heading:
		out.put_double(value)


func _respawn(i: int) -> void:
	_pos[i * 2] = _rng.randf_range(0.0, ARENA)
	_pos[i * 2 + 1] = _rng.randf_range(0.0, ARENA)
	_heading[i] = _rng.randf_range(-PI, PI)
