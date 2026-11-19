extends GutTest
## Public use/enter/exit paths, including the flag-off writer used before timed doors.

const LEGACY_DOOR: Vector2 = Vector2.DOWN * VehicleService.DOOR_OFF


class Lot:
	extends VehicleWorld
	var foot: Vector2 = Vector2(1.6, 3.0)
	var blocked: bool = false
	var sim_cars: PackedFloat64Array = []

	func solid(x: float, y: float) -> bool:
		return blocked and floori(x) == 0 and floori(y) == 2

	func cars_near(_p: Vector2, _r: float) -> PackedFloat64Array:
		return sim_cars

	func take_car(_slot: int) -> void:
		sim_cars.clear()

	func player_pos() -> Vector2:
		return foot

	func set_focus(p: Vector2, _seated: bool) -> void:
		foot = p


var svc: VehicleService
var car: VehicleBody
var lot: Lot
var bus: EventBus
var tick: int
var saved: PackedStringArray


func before_each() -> void:
	saved = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])
	_setup(true)


func _setup(on: bool) -> void:
	LaunchArgs.parse(PackedStringArray(["--car-doors"] if on else []))
	bus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	svc = VehicleService.new()
	lot = Lot.new()
	svc.world = lot
	svc.setup(World.build_context(bus, data, 19))
	car = svc.spawn_parked(&"sedan", Vector2.ZERO, Vector2.LEFT)
	tick = 0
	watch_signals(bus)


func after_each() -> void:
	LaunchArgs.parse(saved)


func _step(buttons: int = 0, throttle: int = 0) -> void:
	svc.step(tick, TickInput.new(buttons, 0, -throttle))
	tick += 1


func test_enter_walks_the_clear_side_before_seating_and_holds_throttle() -> void:
	var start: Vector2 = lot.foot
	_step(1, TickInput.AXIS_MAX)
	for i: int in 13:
		assert_null(svc.driving, "on foot through tick %d" % tick)
		assert_gt(lot.foot.y, 2.0, "circle outside the parked hull")
		assert_lt(lot.foot.distance_to(LEGACY_DOOR), start.distance_to(LEGACY_DOOR))
		assert_eq(car.pos, Vector2.ZERO)
		assert_signal_not_emitted(bus, "vehicle_entered")
		_step(0, TickInput.AXIS_MAX)
	assert_eq(svc.driving, car)
	assert_eq(car.pos, Vector2.ZERO)
	assert_signal_emit_count(bus, "vehicle_entered", 1)


func test_solid_driver_door_refuses_entry() -> void:
	lot.blocked = true
	var at: Vector2 = lot.foot
	assert_eq(svc.try_enter(at), -1)
	for i: int in 16:
		_step()
	assert_eq(lot.foot, at)
	assert_null(svc.driving)
	assert_signal_not_emitted(bus, "vehicle_entered")


func test_another_car_hull_blocks_the_path() -> void:
	@warning_ignore("return_value_discarded")
	svc.spawn_parked(&"taxi", Vector2(2.6, 2.0), Vector2.RIGHT)
	assert_eq(svc.try_enter(Vector2(0, 2.4)), -1)
	assert_null(svc.driving)


func test_slow_exit_steps_out_for_ten_ticks() -> void:
	_enter()
	car.vel = car.head * 0.5
	var p: Vector2 = svc.exit()
	assert_gt(p.y, car.pos.y + 1.6)
	for i: int in 10:
		_step(0, TickInput.AXIS_MAX)
		assert_gt(lot.foot.y, p.y, "step out from the door")
		p = lot.foot
		assert_eq(car.pos, Vector2.ZERO)
		if i < 9:
			assert_signal_not_emitted(bus, "vehicle_exited")
	assert_signal_emit_count(bus, "vehicle_exited", 1)
	assert_null(svc.driving)


func test_blocked_slow_exit_keeps_the_seat() -> void:
	_enter()
	lot.blocked = true
	@warning_ignore("return_value_discarded")
	svc.exit()
	assert_eq(svc.driving, car)
	assert_eq(lot.foot, car.pos)
	assert_signal_not_emitted(bus, "vehicle_exited")


func test_fast_bail_and_moving_hijack_are_instant() -> void:
	_enter()
	car.vel = car.head * 8.0
	assert_lt(svc.exit().distance_to(LEGACY_DOOR), 0.1)
	assert_null(svc.driving)
	assert_signal_emit_count(bus, "vehicle_exited", 1)
	lot.sim_cars = PackedFloat64Array([7, 0, 10, 0, 1, 0, 6, 3])
	assert_gt(svc.try_enter(Vector2(10, 2)), 0)
	assert_not_null(svc.driving)
	assert_almost_eq(svc.driving.speed(), 6.0, 0.001)


func _enter() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	for i: int in 14:
		_step()


func test_active_door_state_records_each_step_only_while_walking() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	var start: Vector2 = lot.foot
	for i: int in svc.doors.enter_ticks:
		var out: StreamPeerBuffer = StreamPeerBuffer.new()
		svc.doors.write_state(out)
		out.seek(0)
		assert_eq(out.get_u8(), 1)
		assert_eq(out.get_32(), car.id)
		assert_eq(out.get_32(), i)
		assert_eq(Vector2(out.get_float(), out.get_float()), start)
		assert_eq(Vector2(out.get_float(), out.get_float()), svc.doors.goal)
		assert_eq(Vector2(out.get_float(), out.get_float()), lot.foot)
		_step()
	var idle: StreamPeerBuffer = StreamPeerBuffer.new()
	svc.doors.write_state(idle)
	assert_eq(idle.get_size(), 0)


func test_new_obstruction_interrupts_entry_on_clear_footing() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	_step()
	assert_eq(svc.try_enter(lot.foot), -1)
	lot.blocked = true
	for i: int in 14:
		_step()
	assert_null(svc.doors.car)
	assert_null(svc.driving)
	assert_true(VehicleDoorPath.clear(svc, lot.foot, lot.foot, svc.doors.radius))
	assert_signal_not_emitted(bus, "vehicle_entered")


func test_off_is_instant_and_writes_the_original_stage_bytes() -> void:
	_setup(false)
	for use: int in [0, 1, 0, 1]:
		_step(use)
		var current: StreamPeerBuffer = StreamPeerBuffer.new()
		svc.write_state(current)
		assert_eq(current.data_array, _legacy_bytes())
	assert_null(svc.driving)
	assert_eq(lot.foot, LEGACY_DOOR)
	assert_signal_emit_count(bus, "vehicle_entered", 1)
	assert_signal_emit_count(bus, "vehicle_exited", 1)


func _legacy_bytes() -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	out.put_32(svc.cars.size())
	out.put_32(svc.driving.id if svc.driving != null else 0)
	for b: VehicleBody in svc.cars:
		for f: float in [
			b.pos.x, b.pos.y, b.head.x, b.head.y, b.vel.x, b.vel.y, b.hp_lost, b.spin, b.wheel
		]:
			out.put_double(f)
		out.put_32(b.state)
	return out.data_array
