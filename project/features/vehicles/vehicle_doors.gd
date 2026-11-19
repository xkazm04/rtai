class_name VehicleDoors
extends RefCounted
## A committed walk between two clear foot positions. Seating and the exit event happen on
## the last fixed tick. Inactive doors append no bytes to the vehicle state.

var enabled: bool
var view: bool
var enter_ticks: int
var exit_ticks: int
var exit_max_mps: float
var step_out_m: float
var radius: float
var car: VehicleBody
var entering: bool
var elapsed: int
var origin: Vector2
var goal: Vector2
var foot: Vector2


static func shipped() -> VehicleDoors:
	var doors: VehicleDoors = VehicleDoors.new()
	var t: DataTable = DataTable.open(VehicleProfile.TABLE, VehicleProfile.SCHEMA)
	var row: Dictionary = t.object(t.raw, "doors")
	doors.enabled = row.get("enabled", false) == true or LaunchArgs.has("--car-doors")
	doors.view = row.get("view", true) == true
	doors.enter_ticks = t.integer(row, "enter_ticks")
	doors.exit_ticks = t.integer(row, "exit_ticks")
	doors.step_out_m = t.num(row, "step_out_m")
	doors.exit_max_mps = t.num(row, "exit_max_mps")
	doors.radius = BodyTable.load_default().radius(RivetBody.CLASS)
	return doors


func begin(svc: VehicleService, b: VehicleBody, start: Vector2, enter: bool) -> bool:
	var door: Vector2 = VehicleDoorPath.driver_door(b, radius)
	var a: Vector2 = start if enter else door
	var z: Vector2 = door if enter else door + b.head.orthogonal() * step_out_m
	if not VehicleDoorPath.clear(svc, a, z, radius):
		return false
	origin = a
	goal = z
	foot = a
	car = b
	entering = enter
	elapsed = 0
	b.vel = Vector2.ZERO
	b.spin = 0.0
	svc.world.set_focus(foot, false)
	return true


func advance(svc: VehicleService) -> void:
	var duration: int = enter_ticks if entering else exit_ticks
	var door: Vector2 = VehicleDoorPath.driver_door(car, radius)
	var end: Vector2 = door if entering else door + car.head.orthogonal() * step_out_m
	var next: Vector2 = origin.lerp(goal, float(elapsed + 1) / duration)
	if (
		end != goal
		or car.state == VehicleBody.State.WRECK
		or not VehicleDoorPath.clear(svc, foot, next, radius)
	):
		_cancel(svc)
		return
	elapsed += 1
	foot = next
	svc.world.set_focus(foot, false)
	if elapsed < duration:
		return
	var body: VehicleBody = car
	car = null
	if entering:
		svc.seat(body)
	else:
		svc.finish_exit(body, foot)


## Traffic can shove the car or block a step after the press. An interrupted exit keeps
## its original seat. On entry walk back along the checked path to the nearest clear footing.
func _cancel(svc: VehicleService) -> void:
	if not entering:
		svc.world.set_focus(car.pos, true)
	else:
		for i: int in range(elapsed, -1, -1):
			var p: Vector2 = origin.lerp(goal, float(i) / enter_ticks)
			if VehicleDoorPath.clear(svc, p, p, radius):
				foot = p
				break
		if not VehicleDoorPath.clear(svc, foot, foot, radius):
			var side: Vector2 = VehicleDoorPath.clear_side(svc, car, radius)
			if side != Vector2.INF:
				foot = side
		svc.world.set_focus(foot, false)
	car = null


func write_state(out: StreamPeerBuffer) -> void:
	if car == null:
		return
	out.put_u8(1 if entering else 2)
	out.put_32(car.id)
	out.put_32(elapsed)
	for p: Vector2 in [origin, goal, foot]:
		out.put_float(p.x)
		out.put_float(p.y)
