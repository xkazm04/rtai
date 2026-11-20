class_name DentStringSteer
extends RefCounted
## One steering sample per displayed sim tick. Mirrored cards exchange anatomical hands.

const TRAVEL_M: float = 0.25
const OPEN_55: Array[Vector2] = [
	Vector2(191, 131), Vector2(192, 134), Vector2(66, 140), Vector2(48, 140), Vector2(40, 141)
]
const OPEN_70: Array[Vector2] = [
	Vector2(251, 164), Vector2(231, 163), Vector2(79, 177), Vector2(62, 170), Vector2(62, 172)
]

var turn: float = 0.0
var _car: VehicleBody
var _yaw: float
var _tick: int = -1


func sample(car: VehicleBody, now: int, limit_dps: float) -> void:
	if car == null or car != _car or now < _tick:
		turn = 0.0
	elif now == _tick:
		return
	else:
		var limit: float = deg_to_rad(limit_dps) * SimClock.TICK_DT * (now - _tick)
		turn = clampf(angle_difference(_yaw, car.head.angle()) / limit, -1.0, 1.0)
	_car = car
	_tick = now
	if car != null:
		_yaw = car.head.angle()


## Positive turn is clockwise (+y right of the nose). Draw the inside grip back and lift it.
static func offset_m(side: int, steer: float, facing: Vector2, vm: ViewMode) -> Vector2:
	var signed_pull: float = side * steer
	var lift: Vector2 = vm.lift_px(1.0) / SimConst.PX_PER_M
	return (-facing * signed_pull + lift * maxf(0.0, signed_pull)).limit_length(1.0) * TRAVEL_M
