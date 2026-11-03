extends GutTest
## Car lights from the sim (features/city/view/city_headlights.gd): only on a listed grade, only the
## nearest max_cars cars within the radius, a siren on police cars only, released by day.


func _rec(i: int, kind: int, at: Vector2, heading: Vector2) -> Array:
	return [i, kind, 0, 0, at.x, at.y, heading.x, heading.y, 0, 0, 0, 0, 0, 0]


func _snap(n_cars: int, police_at: int) -> PackedFloat64Array:
	var out: PackedFloat64Array = PackedFloat64Array()
	out.append_array(_rec(0, SimConst.K_PED, Vector2(1, 0), Vector2.RIGHT))
	for c: int in n_cars:
		var kind: int = SimConst.K_PCAR if c == police_at else SimConst.K_CAR
		out.append_array(_rec(1 + c, kind, Vector2(5.0 * (c + 1), 0), Vector2.UP))
	out.append_array([SimConst.SNAP_PROJ_BASE, 2.0, 2.0])
	return out


func test_day_holds_no_car_lights() -> void:
	var layer: LightLayer = autofree(LightLayer.new())
	var cars: CityHeadlights = CityHeadlights.new(layer)
	cars.observe(_snap(3, 0), Vector2.ZERO, 10)
	assert_eq(cars.held, 0)


func test_night_lights_the_nearest_cars_and_the_police_siren() -> void:
	var layer: LightLayer = autofree(LightLayer.new())
	var cars: CityHeadlights = CityHeadlights.new(layer)
	layer.set_grade(&"night")
	var n: int = cars.max_cars + 3
	cars.observe(_snap(n, 1), Vector2.ZERO, 10)
	assert_eq(cars.held, cars.max_cars * cars.lamps.size() + 1, "nearest cars only, one siren")
	layer.step(10, Vector2.ZERO)
	assert_eq(layer.active, cars.held)


func test_cars_outside_the_radius_are_dark_and_day_releases_everything() -> void:
	var layer: LightLayer = autofree(LightLayer.new())
	var cars: CityHeadlights = CityHeadlights.new(layer)
	layer.set_grade(&"night")
	var far: Vector2 = Vector2(cars.radius_m + 10.0, 0)
	cars.observe(_snap(2, -1), far * 10.0, 10)
	assert_eq(cars.held, 0, "every car beyond radius_m")
	cars.observe(_snap(2, -1), Vector2.ZERO, 11)
	assert_eq(cars.held, 2 * cars.lamps.size())
	layer.set_grade(&"day")
	cars.observe(_snap(2, -1), Vector2.ZERO, 12)
	assert_eq(cars.held, 0)
	layer.step(12, Vector2.ZERO)
	assert_eq(layer.active, 0, "the held lights were removed")
