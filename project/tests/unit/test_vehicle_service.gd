extends GutTest
## VehicleService: enter a parked car, exit on the driver's side, hijack a sim car (driver
## thrown out, vehicle_hijacked), run a person over (pedestrian_struck), wreck traffic by ramming.


class FakeWorld:
	extends VehicleWorld
	var cars: PackedFloat64Array = PackedFloat64Array()
	var people: PackedFloat64Array = PackedFloat64Array()
	var taken: Array[int] = []
	var ejected: int = 0
	var states: Dictionary[int, int] = {}
	var at: Vector2 = Vector2.ZERO
	var in_car: bool = false
	var obstacles: PackedFloat64Array = PackedFloat64Array()

	func set_obstacles(xy: PackedFloat64Array) -> void:
		obstacles = xy

	func cars_near(_p: Vector2, _r: float) -> PackedFloat64Array:
		return cars

	func people_near(_p: Vector2, _r: float) -> PackedFloat64Array:
		return people

	func take_car(slot: int) -> void:
		taken.append(slot)
		cars = PackedFloat64Array()

	func eject_driver(_a: Vector2, _w: Vector2, _art: int) -> void:
		ejected += 1

	func set_car_state(slot: int, state: int) -> void:
		states[slot] = state

	func set_focus(p: Vector2, c: bool) -> void:
		at = p
		in_car = c

	func player_pos() -> Vector2:
		return at


var _bus: EventBus
var _svc: VehicleService
var _w: FakeWorld


func before_each() -> void:
	_bus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_svc = VehicleService.new()
	_svc.setup(World.build_context(_bus, data, 1))
	_w = FakeWorld.new()
	_svc.world = _w
	watch_signals(_bus)


func _ticks(n: int, input: TickInput) -> void:
	for t: int in n:
		_svc.step(t, input)


func test_enters_a_parked_car_and_exits_beside_it() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"sedan", Vector2(10, 10), Vector2.RIGHT)
	assert_eq(_svc.try_enter(Vector2(11, 12)), car.id)
	assert_eq(_svc.driving, car)
	assert_true(_w.in_car)
	assert_signal_emitted_with_parameters(_bus, "vehicle_entered", [car.id])
	var door: Vector2 = _svc.exit()
	assert_null(_svc.driving)
	assert_almost_eq(door.distance_to(car.pos), VehicleService.DOOR_OFF, 0.01)
	assert_signal_emitted_with_parameters(_bus, "vehicle_exited", [car.id])


func test_out_of_reach_enters_nothing() -> void:
	@warning_ignore("return_value_discarded")
	_svc.spawn_parked(&"sedan", Vector2(10, 10), Vector2.RIGHT)
	assert_eq(_svc.try_enter(Vector2(30, 30)), -1)


func test_hijacks_a_sim_car_and_throws_the_driver_out() -> void:
	_w.cars = PackedFloat64Array([7, 0, 5.0, 5.0, 1.0, 0.0, 6.0, 3])
	var id: int = _svc.try_enter(Vector2(5, 7))
	assert_gt(id, 0)
	assert_eq(_w.taken, [7] as Array[int])
	assert_eq(_w.ejected, 1)
	assert_eq(_svc.driving.profile.id, &"taxi", "art 3 drives as the taxi")
	assert_almost_eq(_svc.driving.speed(), 6.0, 0.001, "keeps the car's speed")
	assert_signal_emitted_with_parameters(_bus, "vehicle_hijacked", [&"taxi"])


func test_use_button_toggles_and_throttle_drives() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"sedan", Vector2(0, 0), Vector2.RIGHT)
	_svc.step(0, TickInput.new(1 << VehicleService.BIT_USE, 0, 0))
	assert_eq(_svc.driving, car)
	_ticks(120, TickInput.new(0, 0, -TickInput.AXIS_MAX))
	assert_gt(car.pos.x, 5.0, "drove forward")
	assert_eq(_w.at, car.pos, "the focus follows the car")
	_svc.step(200, TickInput.new(1 << VehicleService.BIT_USE, 0, 0))
	assert_null(_svc.driving)


func test_runs_a_person_over_above_kill_speed() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"sedan", Vector2(0, 0), Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	_svc.try_enter(Vector2.ZERO)
	car.vel = Vector2(12, 0)
	_w.people = PackedFloat64Array([42, 2.0, 0.2, 0])
	_svc.step(0, TickInput.new())
	assert_signal_emitted_with_parameters(_bus, "pedestrian_struck", [42, true])


func test_ramming_traffic_damages_then_disables_it() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"van", Vector2(0, 0), Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	_svc.try_enter(Vector2.ZERO)
	var seen: Array[int] = []
	for hit: int in 6:
		if not _w.taken.is_empty():
			break
		_w.cars = PackedFloat64Array([9, 0, car.pos.x + 3.4, car.pos.y, 1.0, 0.0, 0.0, 0])
		car.vel = Vector2(12, 0)
		_svc.step(hit, TickInput.new())
		seen.append(_w.states.get(9, -1))
	assert_true(seen.has(VehicleBody.State.D1) or seen.has(VehicleBody.State.D2), str(seen))
	assert_true(_w.taken.has(9), "the disabled car left the sim")
	var wrecks: int = 0
	for b: VehicleBody in _svc.cars:
		wrecks += 1 if b != car and b.state >= VehicleBody.State.D2 else 0
	assert_eq(wrecks, 1, "and stays as a damaged service body")
	assert_gt(car.hp_lost, 0.0, "the rammer took damage too")


func test_soul_hijack_marks_traffic() -> void:
	_svc.soul_hijack_traffic(4)
	assert_eq(_w.states[4], VehicleBody.State.HIJACKED)


func test_soul_hijack_marks_a_service_car_until_damaged() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"taxi", Vector2.ZERO, Vector2.RIGHT, 3)
	_svc.soul_hijack(car.id)
	assert_eq(car.state, VehicleBody.State.HIJACKED)
	@warning_ignore("return_value_discarded")
	_svc.rules.hurt(car, 15.0)
	assert_eq(car.state, VehicleBody.State.D1, "damage shows over the plate")


func test_traffic_shoves_a_parked_car() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"hatchback", Vector2(0, 0), Vector2.RIGHT)
	_w.cars = PackedFloat64Array([5, 0, -3.4, 0.0, 1.0, 0.0, 14.0, 4])
	_svc.step(0, TickInput.new())
	assert_gt(car.vel.x, 1.0, "the van rear-ending it pushed it forward")
	assert_gt(car.hp_lost, 0.0)


func test_traffic_is_handed_every_car_hull_circle() -> void:
	@warning_ignore("return_value_discarded")
	_svc.spawn_parked(&"sedan", Vector2(10, 0), Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	_svc.spawn_parked(&"van", Vector2(0, 20), Vector2.DOWN)
	_svc.step(0, TickInput.new())
	assert_eq(_w.obstacles.size(), 12, "3 circles x 2 cars")
	assert_almost_eq(_w.obstacles[0], 10.0 + VehicleContacts.CIRCLE_OFF, 1e-6, "sedan nose")
	assert_almost_eq(_w.obstacles[11], 20.0 - VehicleContacts.CIRCLE_OFF, 1e-6, "van tail")


func test_a_reused_traffic_slot_starts_a_fresh_damage_book() -> void:
	var car: VehicleBody = _svc.spawn_parked(&"van", Vector2(0, 0), Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	_svc.try_enter(Vector2.ZERO)
	_w.cars = PackedFloat64Array([9, 0, 3.4, 0.0, 1.0, 0.0, 0.0, 0])
	car.vel = Vector2(12, 0)
	_svc.step(0, TickInput.new())
	var first: float = _svc.traffic.lost_of(9)
	assert_gt(first, 0.0)
	car.pos = Vector2.ZERO
	_w.cars = PackedFloat64Array([9, 0, 3.4, 0.0, 1.0, 0.0, 0.0, 4])
	car.vel = Vector2(12, 0)
	_svc.step(1, TickInput.new())
	var fresh: float = _svc.traffic.lost_of(9)
	assert_gt(fresh, 0.0)
	assert_lt(fresh, first, "a new (heavier) car in slot 9: its own damage, not added to the old")
