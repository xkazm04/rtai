extends GutTest
## d9 seams (Call 4): CityVehicleWorld hands sim traffic Rivet's ground point ahead of the
## service cars' hull points when yield_to_rivet is on; off (the default) the feed is untouched.
## The sim's braking and pulling round a point obstacle: test_city_sim_pass.


func test_off_hands_the_hull_points_untouched() -> void:
	var hulls: PackedFloat64Array = PackedFloat64Array([10.0, 0.0, 11.0, 0.0])
	assert_eq(CityVehicleWorld.with_rivet(hulls, Vector2(4, 7), false), hulls)


func test_on_puts_rivet_first() -> void:
	var hulls: PackedFloat64Array = PackedFloat64Array([10.0, 0.0, 11.0, 0.0])
	var xy: PackedFloat64Array = CityVehicleWorld.with_rivet(hulls, Vector2(4, 7), true)
	assert_eq(xy, PackedFloat64Array([4.0, 7.0, 10.0, 0.0, 11.0, 0.0]))


func test_rivet_is_kept_when_the_hulls_fill_the_cap() -> void:
	var hulls: PackedFloat64Array = PackedFloat64Array()
	for k: int in SimConst.OBST_MAX:
		@warning_ignore("return_value_discarded")
		hulls.append_array([float(k), 0.0])
	var xy: PackedFloat64Array = CityVehicleWorld.with_rivet(hulls, Vector2(4, 7), true)
	var kept: PackedFloat64Array = xy.slice(0, SimConst.OBST_MAX * 2)  # what the sim keeps
	assert_eq([kept[0], kept[1]], [4.0, 7.0])


func test_the_default_is_off() -> void:
	assert_false(CityVehicleWorld.new(null).yield_to_rivet, "top and the goldens: n8 traffic")
