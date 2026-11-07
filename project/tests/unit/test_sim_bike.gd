extends GutTest
## d9 the sim bike: a K_CAR with art SimConst.ART_BIKE has a small hull and the lighter body in a
## car contact (CitySimCarPush, the twin of car_hit.cpp's car_push); car vs car is unchanged.


func _state() -> CitySimState:
	var s: CitySimState = CitySimState.new()
	s.init(1)
	for i: int in 2:
		s.kind[i] = SimConst.K_CAR
		s.alive[i] = 1
	s.px[1] = 1.0
	return s


func test_a_bike_takes_seven_eighths_of_a_car_overlap() -> void:
	var s: CitySimState = _state()
	s.variant[0] = SimConst.ART_BIKE
	var o: PackedFloat64Array = CitySimCarPush.push(s, true, 1, 1.0, 0.0)
	assert_eq(o[0], 0.75 * 0.875, "the bike moves back 7/8 of the 0.75 m overlap")
	assert_eq(s.px[1], 1.0 + 0.75 * 0.125, "the car takes 1/8")
	assert_eq(o[2], 0.9)


func test_car_against_car_keeps_the_old_numbers() -> void:
	var s: CitySimState = _state()
	var o: PackedFloat64Array = CitySimCarPush.push(s, false, 1, 1.0, 0.0)
	assert_eq(o[0], (2.2 - 1.0) * 0.5)
	assert_eq(s.px[1], 1.0 + (2.2 - 1.0) * 0.5)


func test_apart_is_no_push() -> void:
	var s: CitySimState = _state()
	s.variant[0] = SimConst.ART_BIKE
	var o: PackedFloat64Array = CitySimCarPush.push(s, true, 1, 2.0, 0.0)
	assert_eq(o, PackedFloat64Array(CitySimCarPush.NONE), "1.75 m reach: 2 m apart is clear")
	assert_eq(s.px[1], 1.0)


func test_the_bike_maps_to_its_profile() -> void:
	assert_eq(VehicleProfile.archetype_of_variant(SimConst.ART_BIKE, false), &"bike")
	assert_true(VehicleProfile.load_all().has(&"bike"), "vehicle_handling.json has a bike row")
	assert_lt(VehicleProfile.load_all()[&"bike"].mass, VehicleProfile.load_all()[&"sedan"].mass)


func test_the_table_share_is_small() -> void:
	var share: float = CitySpawner.table_bike_share()
	assert_gt(share, 0.0)
	assert_lt(share, 0.15, "a small share of traffic")
