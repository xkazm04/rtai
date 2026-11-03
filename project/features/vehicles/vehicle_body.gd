class_name VehicleBody
extends RefCounted
## One driveable car (the player's, a parked one or a wreck): the arcade top-down handling step.
## The velocity is split into forward and lateral parts along the heading; throttle, brake,
## reverse and rolling drag act on the forward part, a friction-limited grip bleeds the lateral
## part, and above drift_at of lateral slip (or with the handbrake held) the grip drops to the
## slide grip, so the car drifts. The heading turns at a speed-shaped steer rate. Fixed tick
## only, and + - * / sqrt only (no trig in the state), so a replay reproduces it exactly.

enum State { INTACT, D1, D2, HIJACKED, WRECK }

## The steer rate reaches its full value at this forward speed (m/s) and fades above 60 % vmax.
const STEER_FULL_V: float = 6.0
const STEER_HIGH_FADE: float = 0.35
const HANDBRAKE_YAW: float = 1.35
const HANDBRAKE_DECEL: float = 6.0
const GRIP_YAW: float = 0.85

var id: int = 0
var profile: VehicleProfile = null
var art: int = 0
var pos: Vector2 = Vector2.ZERO
## Unit heading (nose direction); the art's +x.
var head: Vector2 = Vector2.RIGHT
var vel: Vector2 = Vector2.ZERO
var hp_lost: float = 0.0
var state: State = State.INTACT
var soul_hijacked: bool = false
## Seconds since the car became a wreck.
var wreck_t: float = 0.0
## Last step's lateral slip (m/s) and whether the car was sliding (traces, skid FX).
var slip: float = 0.0
var sliding: bool = false


func _init(p_id: int, p_profile: VehicleProfile, p_pos: Vector2, p_head: Vector2) -> void:
	id = p_id
	profile = p_profile
	pos = p_pos
	head = p_head.normalized() if p_head.length_squared() > 1e-9 else Vector2.RIGHT


## One tick. throttle and steer in -1..1 (steer > 0 turns clockwise on screen, y down).
func step(dt: float, throttle: float, steer: float, handbrake: bool) -> void:
	if state == State.WRECK:
		throttle = 0.0
		steer = 0.0
		handbrake = true
	var right: Vector2 = Vector2(-head.y, head.x)
	var vf: float = vel.dot(head)
	var vl: float = vel.dot(right)
	vf = _longitudinal(vf, throttle, handbrake, dt)
	slip = vl
	sliding = handbrake or absf(vl) > profile.drift_at
	var g: float = profile.slide_grip if sliding else profile.grip
	if handbrake:
		g = minf(g, profile.grip * profile.handbrake_grip)
	var bleed: float = minf(absf(vl), g * dt)
	vl -= bleed if vl > 0.0 else -bleed
	vel = head * vf + right * vl
	_turn(vf, steer, handbrake, dt)
	pos += vel * dt


func speed() -> float:
	return vel.length()


## The slip angle in degrees (0 = rolling straight; traces only, never fed back).
func slip_angle_deg() -> float:
	var vf: float = absf(vel.dot(head))
	return rad_to_deg(atan2(absf(slip), vf)) if vf + absf(slip) > 0.3 else 0.0


func _longitudinal(vf: float, throttle: float, handbrake: bool, dt: float) -> float:
	var p: VehicleProfile = profile
	if handbrake:
		vf = _toward(vf, 0.0, HANDBRAKE_DECEL * dt)
	if throttle > 0.0:
		if vf < 0.0:
			return minf(0.0, vf + p.brake * throttle * dt)
		return minf(p.vmax, vf + p.accel * throttle * (1.0 - 0.5 * maxf(vf, 0.0) / p.vmax) * dt)
	if throttle < 0.0:
		if vf > 0.0:
			return maxf(0.0, vf + p.brake * throttle * dt)
		return maxf(-p.reverse_max, vf + p.accel * 0.6 * throttle * dt)
	return _toward(vf, 0.0, p.drag * dt)


## Rotates the heading by the tick's yaw (sin of the step angle, then renormalised).
func _turn(vf: float, steer: float, handbrake: bool, dt: float) -> void:
	var a: float = absf(vf)
	var shape: float = minf(1.0, a / STEER_FULL_V)
	var high: float = maxf(0.0, a / profile.vmax - 0.6) / 0.4
	shape *= 1.0 - STEER_HIGH_FADE * minf(1.0, high)
	var yaw: float = steer * profile.steer_rate * shape * (HANDBRAKE_YAW if handbrake else 1.0)
	if not handbrake and a > 1.0:
		# grip-limited yaw: v * yaw stays under GRIP_YAW * grip, so a full-lock turn at speed
		# carves a wide arc instead of spinning; the handbrake is the way to rotate hard
		var cap: float = GRIP_YAW * profile.grip / a
		yaw = clampf(yaw, -cap, cap)
	if vf < 0.0:
		yaw = -yaw
	var s: float = yaw * dt
	if absf(s) < 1e-12:
		return
	var c: float = sqrt(maxf(0.0, 1.0 - s * s))
	head = Vector2(head.x * c - head.y * s, head.x * s + head.y * c)
	head /= head.length()


static func _toward(v: float, target: float, step_by: float) -> float:
	if v > target:
		return maxf(target, v - step_by)
	return minf(target, v + step_by)
