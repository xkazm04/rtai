class_name MotionProbeRun
extends RefCounted
## rivet-motion: PlayerMotion's feel numbers on the 60 Hz tick (run by motion_probe.gd).
## Time to 90 % of the top speed, the stop distance and time after release, a 180-degree turn,
## and the roll's distance, i-frames and lockout. Sim-true only: the display latency (input
## sampling to the presented frame) is not measured here.

const WALK_MPS: float = 4.5

var actions: PlayerActions = PlayerActions.shipped()
var _drop: Vector2 = Vector2.ZERO


func run() -> Dictionary:
	var out: Dictionary = {"walk": _run([]), "sprint": _run(["sprint"])}
	out["turn180_walk_ms"] = _turn([])
	out["turn180_sprint_ms"] = _turn(["sprint"])
	out["roll"] = _roll()
	return out


func _motion() -> PlayerMotion:
	return PlayerMotion.shipped()


func _cmd(move: Vector2, aim: Vector2, held: Array, prev: int) -> PlayerCommand:
	var c: PlayerCommand = PlayerCommand.new()
	for n: String in held:
		c.held |= 1 << actions.bit(StringName(n))
	c.move = move
	c.aim = aim
	c.pressed = c.held & ~prev
	return c


## Ticks to 90 % of the top speed from a stand, then the stop distance after release.
func _run(held: Array) -> Dictionary:
	var m: PlayerMotion = _motion()
	var t90: int = -1
	var first_tick_m: float = 0.0
	for t: int in 180:
		var d: Vector2 = m.step(_cmd(Vector2.RIGHT, Vector2.ZERO, held, 0xFF), WALK_MPS, actions)
		if t == 0:
			first_tick_m = d.length()
		var v: float = m.velocity().length()
		if t90 < 0 and v >= 0.9 * (6.2 if held.size() > 0 else WALK_MPS):
			t90 = t + 1
	var top: float = m.velocity().length()
	var stop_m: float = 0.0
	var stop_t: int = 0
	while m.velocity().length() > 0.01 and stop_t < 600:
		var d2: Vector2 = m.step(_cmd(Vector2.ZERO, Vector2.ZERO, [], 0), WALK_MPS, actions)
		stop_m += d2.length()
		stop_t += 1
	return {
		"top_mps": snappedf(top, 0.01),
		"to_90pct_ms": roundi(t90 * 1000.0 / 60.0),
		"press_tick_moves_m": snappedf(first_tick_m, 0.0001),
		"stop_m": snappedf(stop_m, 0.01),
		"stop_ms": roundi(stop_t * 1000.0 / 60.0),
	}


## The aim (walk) or the stick (sprint) flips 180 degrees; ms until the facing is within 5 deg.
func _turn(held: Array) -> int:
	var m: PlayerMotion = _motion()
	for _t: int in 60:
		_drop = m.step(_cmd(Vector2.RIGHT, Vector2.RIGHT, held, 0xFF), WALK_MPS, actions)
	var flip: Vector2 = Vector2.LEFT.rotated(0.01)
	for t: int in 240:
		var mv: Vector2 = flip if held.size() > 0 else Vector2.ZERO
		_drop = m.step(_cmd(mv, flip, held, 0xFF), WALK_MPS, actions)
		if m.facing().dot(flip) > cos(deg_to_rad(5.0)):
			return roundi((t + 1) * 1000.0 / 60.0)
	return -1


func _roll() -> Dictionary:
	var m: PlayerMotion = _motion()
	var moved: float = 0.0
	var iframes: int = 0
	var t: int = 0
	_drop = m.step(_cmd(Vector2.RIGHT, Vector2.ZERO, ["roll"], 0), WALK_MPS, actions)
	while not m.can_roll() and t < 300:
		if m.invulnerable():
			iframes += 1
		var d: Vector2 = m.step(_cmd(Vector2.ZERO, Vector2.ZERO, [], 0), WALK_MPS, actions)
		moved += d.length()
		t += 1
	return {
		"roll_ms": roundi(m.roll_ticks * 1000.0 / 60.0),
		"iframes_ms": roundi((iframes + 1) * 1000.0 / 60.0),
		"lockout_ms": roundi((t + 1) * 1000.0 / 60.0),
		"moved_after_press_tick_m": snappedf(moved, 0.01),
	}
