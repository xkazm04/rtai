class_name GhostHover
extends RefCounted
## A render-side spring in world pixels. Positive yaw and bank turn right in Godot's y-down plane.

var lift_m: float:
	get:
		return _row.height_m + _row.bob_m * sin(TAU * _phase / _row.bob_ticks)
var bank: float:
	get:
		return _bank
var lean: float:
	get:
		return deg_to_rad(_row.lean_deg) * clampf(_speed_mps / _row.top_mps, 0.0, 1.0)
var lag_px: Vector2:
	get:
		return _lag_px
var speed_mps: float:
	get:
		return _speed_mps
var yaw_rate_dps: float:
	get:
		return _yaw_rate_dps

var _bank: float = 0.0
var _lag_px: Vector2 = Vector2.ZERO
var _speed_mps: float = 0.0
var _yaw_rate_dps: float = 0.0
var _row: GhostHoverRow
var _at: Vector2 = Vector2.INF
var _facing: float = 0.0
var _velocity: Vector2 = Vector2.ZERO
var _phase: int = 0


func _init(row: GhostHoverRow) -> void:
	_row = row


func step(at_px: Vector2, facing: float, ticks: int) -> void:
	if ticks <= 0:
		return
	var start: Vector2 = at_px if _at == Vector2.INF else _at
	var angle: float = facing if _at == Vector2.INF else _facing
	_at = start
	_facing = angle
	for i: int in range(1, ticks + 1):
		var k: float = float(i) / ticks
		_tick(start.lerp(at_px, k), lerp_angle(angle, facing, k))


func _tick(at_px: Vector2, facing: float) -> void:
	var moved: Vector2 = at_px - _at
	_speed_mps = moved.length() / (SimConst.PX_PER_M * SimClock.TICK_DT)
	_yaw_rate_dps = rad_to_deg(angle_difference(_facing, facing)) / SimClock.TICK_DT
	var roll: float = clampf(yaw_rate_dps * _row.bank_per_dps, -_row.bank_deg, _row.bank_deg)
	_bank = lerpf(_bank, deg_to_rad(roll), 0.25)
	_follow(moved)
	_phase = (_phase + 1) % _row.bob_ticks
	_at = at_px
	_facing = facing


## Exact critically damped response to this tick's target. At constant speed the delay is
## approximately lag_ticks. Keeping the error relative to the target avoids large world coordinates.
func _follow(moved: Vector2) -> void:
	if _row.lag_ticks == 0:
		_lag_px = Vector2.ZERO
		return
	var omega: float = 2.0 / (_row.lag_ticks * SimClock.TICK_DT)
	var decay: float = exp(-omega * SimClock.TICK_DT)
	var error: Vector2 = lag_px - moved
	var change: Vector2 = _velocity + omega * error
	_lag_px = (error + change * SimClock.TICK_DT) * decay
	_velocity = (_velocity - omega * change * SimClock.TICK_DT) * decay
