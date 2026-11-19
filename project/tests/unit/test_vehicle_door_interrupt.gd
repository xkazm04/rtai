extends GutTest
## Traffic moves after the press. Each cancellation must finish this tick with Rivet either
## in his original seat or at a clear standing position reported by the world.

var svc: VehicleService
var car: VehicleBody
var lot: DoorTestLot


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	svc = VehicleService.new()
	svc.setup(World.build_context(bus, data, 31))
	svc.doors.enabled = true
	lot = DoorTestLot.new()
	svc.world = lot
	car = svc.spawn_parked(&"sedan", Vector2.ZERO, Vector2.LEFT)


func test_interrupted_exit_restores_focus_to_the_original_seat() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	for i: int in svc.doors.enter_ticks:
		svc.step(i, TickInput.new())
	@warning_ignore("return_value_discarded")
	svc.exit()
	svc.step(14, TickInput.new())
	lot.blocked = true
	svc.step(15, TickInput.new())
	assert_eq(svc.driving, car)
	assert_null(svc.doors.car)
	assert_eq(lot.foot, car.pos)


func test_entry_rewinds_to_the_last_clear_sample_even_if_only_the_origin_fits() -> void:
	var start: Vector2 = Vector2(1.44, 2.5)
	assert_eq(svc.try_enter(start), car.id)
	for i: int in 4:
		svc.step(i, TickInput.new())
	lot.blocked = true
	svc.step(4, TickInput.new())
	assert_null(svc.driving)
	assert_null(svc.doors.car)
	assert_eq(lot.foot, start)


func test_a_car_closing_the_whole_approach_leaves_rivet_on_the_clear_side() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	svc.step(0, TickInput.new())
	lot.sim_cars = PackedFloat64Array([7, 0, 0, 4, 1, 0, 0, 0])
	svc.step(1, TickInput.new())
	assert_null(svc.driving)
	assert_null(svc.doors.car)
	assert_lt(lot.foot.y, -2.0, "the far side of the sedan stays clear")
	assert_true(VehicleDoorPath.clear(svc, lot.foot, lot.foot, svc.doors.radius))


func test_surrounded_approach_finds_clear_ground_between_the_four_traffic_cars() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	svc.step(0, TickInput.new())
	for p: Vector2 in [Vector2(0, 3.55), Vector2(0, -3.55), Vector2(5, 0), Vector2(-5, 0)]:
		lot.sim_cars.append_array(PackedFloat64Array([7, 0, p.x, p.y, 1, 0, 0, 0]))
	svc.step(1, TickInput.new())
	assert_null(svc.driving)
	assert_null(svc.doors.car)
	assert_true(VehicleDoorPath.clear(svc, lot.foot, lot.foot, svc.doors.radius))


func test_no_standing_room_shelters_until_the_normal_seating_tick() -> void:
	assert_eq(svc.try_enter(lot.foot), car.id)
	svc.step(0, TickInput.new())
	lot.enclosed = true
	for i: int in range(1, svc.doors.enter_ticks):
		assert_null(svc.driving)
		svc.step(i, TickInput.new())
		assert_eq(lot.foot, car.pos)
	assert_eq(svc.driving, car)
	assert_null(svc.doors.car)
