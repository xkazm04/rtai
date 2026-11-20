class_name DentStringSteer
extends RefCounted
## One steering sample per displayed sim tick. Mirrored cards exchange anatomical hands.

const TRAVEL_M: float = 0.25
## Palm centres in column four of dent_sp_act, rows toward through away. +y is the right side.
const LEFT_55: Array[Vector2] = [
	Vector2(182, 100), Vector2(202, 95), Vector2(188, 72), Vector2(155, 72), Vector2(55, 65)
]
const RIGHT_55: Array[Vector2] = [
	Vector2(55, 100), Vector2(112, 108), Vector2(188, 100), Vector2(201, 76), Vector2(183, 64)
]
const LEFT_70: Array[Vector2] = [
	Vector2(223, 127), Vector2(249, 112), Vector2(237, 87), Vector2(207, 74), Vector2(80, 82)
]
const RIGHT_70: Array[Vector2] = [
	Vector2(79, 129), Vector2(175, 127), Vector2(229, 120), Vector2(258, 88), Vector2(219, 80)
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
