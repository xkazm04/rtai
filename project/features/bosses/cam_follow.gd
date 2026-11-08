class_name CamFollow
extends RefCounted
## BossCam's focus with a limited acceleration (n9-handheld it8): the framing target jumps in
## speed when a keep-in margin engages (the King clip at 40 px/m: 0 -> 20 px a frame in one frame),
## so the camera keeps a velocity and changes it by at most `accel_m` a tick. It brakes on the
## discrete square-root law (stops on the target without overshoot) and matches the target's own
## speed, so a steady pan has no lag. Steps on the sim tick (SimClock.TICK_DT), not the frame:
## at 40 Hz (1 or 2 ticks a frame) or under a hit-stop (0) it moves as at 60. A jump past
## `snap_m` (a respawn, the fight's first frame) cuts. View only (SIM-03).

var pos: Vector2 = Vector2.INF
var vel: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.INF


## One tick toward `target` (metres); returns the new focus.
func step(target: Vector2, accel_m: float, snap_m: float) -> Vector2:
	if pos == Vector2.INF or accel_m <= 0.0 or pos.distance_to(target) > snap_m:
		return cut(target)
	var target_vel: Vector2 = target - _target
	var err: Vector2 = _target - pos  # the lag before this tick's move (the pan's own step apart)
	_target = target
	var d: float = err.length()
	# the fastest closing speed that still stops in `d` braking `accel_m` a tick:
	# v + (v - a) + ... = v^2 / 2a + v / 2 = d
	var close: float = minf(d, accel_m * (sqrt(0.25 + 2.0 * d / accel_m) - 0.5))
	var want: Vector2 = target_vel + (err / d * close if d > 0.0 else Vector2.ZERO)
	vel += (want - vel).limit_length(accel_m)
	pos += vel
	return pos


## Jump to `target` at rest.
func cut(target: Vector2) -> Vector2:
	pos = target
	_target = target
	vel = Vector2.ZERO
	return pos


## `ticks` steps toward a target that holds still over them (a frame that took 2 ticks at 40 Hz).
func advance(target: Vector2, ticks: int, accel_m: float, snap_m: float) -> Vector2:
	if ticks <= 0:
		return pos if pos != Vector2.INF else cut(target)
	var from: Vector2 = _target if _target != Vector2.INF else target
	for i: int in ticks:
		@warning_ignore("return_value_discarded")
		step(from.lerp(target, float(i + 1) / float(ticks)), accel_m, snap_m)
	return pos
