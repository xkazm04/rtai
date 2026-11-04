class_name PlayerMotion
extends RefCounted
## Rivet's locomotion on the fixed tick, on top of TopDownMover (rivet_motion.json): the held
## sprint (above the 5.0 m/s tackle line; the facing follows the walk, at a slower turn) and the
## dodge roll (a press: roll_m on an ease-out curve, invulnerable on a window of its ticks, then
## a recovery with a damped stick and a cooldown). Free movement is TopDownMover unchanged.

enum Phase { FREE, ROLL, RECOVER }

const TABLE: String = "res://data/tables/rivet_motion.json"
const SCHEMA: String = "gtai.rivet-motion/1"

var mover: TopDownMover = TopDownMover.new()
var phase: Phase = Phase.FREE
var sprinting: bool = false
var rolls: int = 0
var roll_dir: Vector2 = Vector2.ZERO
var sprint_mps: float = 9.3
var sprint_accel_mps2: float = 24.0
var sprint_turn_dps: float = 320.0
var min_forward_dot: float = 0.4
var roll_m: float = 3.2
var roll_ticks: int = 22
var iframe_from: int = 2
var iframe_to: int = 14
var recovery_ticks: int = 10
var recovery_move_scale: float = 0.35
var cooldown_ticks: int = 8
var exit_speed_k: float = 0.5
var errors: Array[String] = []
var _phase_tick: int = 0
var _cooldown: int = 0
## The roll tick executed by the last step (-1 outside a roll): the i-frame window reads it.
var _roll_tick: int = -1
var _sprint_actions: PlayerActions = null


static func shipped() -> PlayerMotion:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> PlayerMotion:
	var m: PlayerMotion = PlayerMotion.new()
	var s: Dictionary = t.object(t.raw, "sprint")
	m.sprint_mps = t.num(s, "sprint_mps")
	m.sprint_accel_mps2 = t.num(s, "accel_mps2")
	m.sprint_turn_dps = t.num(s, "turn_dps")
	m.min_forward_dot = t.num(s, "min_forward_dot")
	var r: Dictionary = t.object(t.raw, "roll")
	m.roll_m = t.num(r, "roll_m")
	m.roll_ticks = maxi(t.integer(r, "roll_ticks"), 1)
	m.iframe_from = t.integer(r, "iframe_from")
	m.iframe_to = t.integer(r, "iframe_to")
	m.recovery_ticks = t.integer(r, "recovery_ticks")
	m.recovery_move_scale = t.num(r, "recovery_move_scale")
	m.cooldown_ticks = t.integer(r, "cooldown_ticks")
	m.exit_speed_k = t.num(r, "exit_speed_k")
	m.errors = t.errors()
	if m.iframe_to >= m.roll_ticks:
		m.errors.append("rivet_motion.json: roll.iframe_to must be inside roll_ticks")
	return m


## The displacement for one tick. `aim` Vector2.ZERO faces the walk direction.
func step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	_cooldown = maxi(_cooldown - 1, 0)
	_roll_tick = -1
	if c.was_pressed(actions, &"roll") and can_roll():
		_start_roll(c.move)
	match phase:
		Phase.ROLL:
			return _roll_step(walk_mps)
		Phase.RECOVER:
			return _recover_step(c, walk_mps, actions)
	return _free_step(c, walk_mps, actions)


func can_roll() -> bool:
	return phase == Phase.FREE and _cooldown == 0


## True on the roll's invulnerable ticks (iframe_from..iframe_to, inclusive).
func invulnerable() -> bool:
	return _roll_tick >= iframe_from and _roll_tick <= iframe_to


## 0..1 through the roll (for the rig's tuck), 0 outside it.
func roll_progress() -> float:
	return float(_roll_tick + 1) / float(roll_ticks) if _roll_tick >= 0 else 0.0


func facing() -> Vector2:
	return mover.facing


func velocity() -> Vector2:
	return mover.velocity


func stop() -> void:
	mover.stop()
	sprinting = false


func write_state(out: StreamPeerBuffer) -> void:
	mover.write_state(out)
	out.put_32(phase)
	out.put_32(_phase_tick)
	out.put_32(_cooldown)
	out.put_float(roll_dir.x)
	out.put_float(roll_dir.y)


func _free_step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	var push: Vector2 = c.move.limit_length(1.0)
	sprinting = c.is_held(actions, &"sprint") and push.length() > 0.5
	if not sprinting:
		return mover.step(c.move, c.aim, walk_mps, actions)
	var aligned: bool = push.normalized().dot(mover.facing) >= min_forward_dot
	var top: float = sprint_mps if aligned else walk_mps
	return mover.step(c.move, Vector2.ZERO, top, _sprint_feel(actions))


func _start_roll(stick: Vector2) -> void:
	var push: Vector2 = stick.limit_length(1.0)
	roll_dir = push.normalized() if push.length() > 0.2 else mover.facing
	mover.facing = roll_dir
	phase = Phase.ROLL
	_phase_tick = 0
	sprinting = false
	rolls += 1


## Ease-out: f(u) = 1 - (1 - u)^2, so the covered distance is exactly roll_m.
func _roll_step(walk_mps: float) -> Vector2:
	var k: int = _phase_tick
	var u0: float = float(k) / float(roll_ticks)
	var u1: float = float(k + 1) / float(roll_ticks)
	var ds: float = roll_m * ((1.0 - u0) * (1.0 - u0) - (1.0 - u1) * (1.0 - u1))
	_roll_tick = k
	_phase_tick += 1
	mover.velocity = roll_dir * ds / SimClock.TICK_DT
	if _phase_tick >= roll_ticks:
		phase = Phase.RECOVER
		_phase_tick = 0
		mover.velocity = roll_dir * walk_mps * exit_speed_k
	return roll_dir * ds


func _recover_step(c: PlayerCommand, walk_mps: float, actions: PlayerActions) -> Vector2:
	_phase_tick += 1
	if _phase_tick >= recovery_ticks:
		phase = Phase.FREE
		_phase_tick = 0
		_cooldown = cooldown_ticks
	return mover.step(c.move * recovery_move_scale, c.aim, walk_mps, actions)


## The sprint's feel: the table's accel and turn rate over the walk's brake and strafe.
func _sprint_feel(actions: PlayerActions) -> PlayerActions:
	if _sprint_actions == null:
		_sprint_actions = PlayerActions.new()
	_sprint_actions.accel_mps2 = sprint_accel_mps2
	_sprint_actions.brake_mps2 = actions.brake_mps2
	_sprint_actions.turn_dps = sprint_turn_dps
	_sprint_actions.strafe_scale = actions.strafe_scale
	return _sprint_actions
