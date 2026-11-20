class_name OhmDrift
extends RefCounted
## Presentation angles relative to the facing mount. Advance once per simulation tick.

const SWAY_TICKS: int = 144
const MAX_LAG: float = PI * 25.0 / 180.0


class Cloth:
	var angle: float = 0.0
	var velocity: float = 0.0
	var omega: float

	func _init(follow_ticks: float) -> void:
		omega = 2.0 / follow_ticks

	## Exact critically damped step in ticks, with the error measured from the moving body.
	func follow(yaw_step: float) -> void:
		var error: float = clampf(angle - yaw_step, -MAX_LAG, MAX_LAG)
		var change: float = velocity + omega * error
		var decay: float = exp(-omega)
		angle = clampf((error + change) * decay, -MAX_LAG, MAX_LAG)
		velocity = (velocity - omega * change) * decay
		if absf(angle) < 0.00001 and absf(velocity) < 0.00001:
			angle = 0.0
			velocity = 0.0


var hem: Cloth = Cloth.new(8.0)
var beard: Cloth = Cloth.new(5.0)
var _tick: int = -1
var _yaw: float


static func sway(tick: int, cruise: float) -> float:
	var amplitude: float = deg_to_rad(lerpf(3.0, 1.5, clampf(cruise, 0.0, 1.0)))
	return amplitude * sin(TAU * posmod(tick, SWAY_TICKS) / SWAY_TICKS)


func step(tick: int, facing: float) -> void:
	var steps: int = tick - _tick
	if _tick < 0 or steps < 0 or steps > 4:
		hem = Cloth.new(8.0)
		beard = Cloth.new(5.0)
	elif steps == 0:
		return
	else:
		var yaw_step: float = angle_difference(_yaw, facing) / steps
		for i: int in steps:
			hem.follow(yaw_step)
			beard.follow(yaw_step)
	_tick = tick
	_yaw = facing
