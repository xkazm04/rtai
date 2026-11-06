extends GutTest


func _lift(pitch: float) -> ChunkLift:
	var tex: CityTextures = CityTextures.new({"textures": []})
	tex.names.assign(["road", "building_tall", "building_warehouse"])
	tex.size_px.assign([Vector2(256, 256), Vector2(269, 269), Vector2(525, 269)])
	var built: Array[bool] = [false, true, true]
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var lift: ChunkLift = ChunkLift.new()
	lift._setup(d, tex, built, "p70")
	lift.drawn_pitch = pitch
	return lift


## rows: (texture id, x m, y m) per command
func _chunk(rows: Array[Vector3]) -> CityChunk:
	var c: CityChunk = CityChunk.new()
	for r: Vector3 in rows:
		@warning_ignore("return_value_discarded")
		c.tex.append(int(r.x))
		for v: float in [r.y, r.z, 0.0, 0.0]:
			@warning_ignore("return_value_discarded")
			c.xf.append(v)
	return c


func test_flat_view_builds_no_lift() -> void:
	assert_true(ViewMode.shared().is_flat(), "the test run is the default top view")
	assert_null(ChunkLift.make(CityTextures.new({"textures": []}), []))


func test_buildings_draw_last_by_south_edge() -> void:
	var lift: ChunkLift = _lift(70.0)
	var c: CityChunk = _chunk(
		[Vector3(1, 4, 20), Vector3(0, 0, 0), Vector3(2, 8, 4), Vector3(1, 0, 12)]
	)
	var got: Array[int] = []
	for k: int in c.command_count():
		got.append(lift.nth(k, c))
	assert_eq(got, [1, 2, 3, 0], "the road first, then roofs north to south")


func test_south_edge_is_in_px_not_metres_plus_px() -> void:
	var lift: ChunkLift = _lift(70.0)
	# the warehouse turned a quarter (525 px deep) at y 1 m ends at 294 px; the tall one at y 10 m
	# (269 px deep) at 454 px: the warehouse is farther, drawn first
	var c: CityChunk = _chunk([Vector3(1, 0, 10), Vector3(2, 0, 1)])
	c.xf[CityChunk.XF_STRIDE + 2] = PI * 0.5
	assert_eq([lift.nth(0, c), lift.nth(1, c)], [1, 0])


func test_heights_come_from_the_table() -> void:
	var lift: ChunkLift = _lift(70.0)
	assert_eq(lift.height_m[1], 21.0 * 0.5, "building_tall at height_k 0.5")
	assert_eq(lift.height_m[2], 8.5 * 0.5, "building_warehouse at height_k 0.5")
	assert_eq(lift.style_of[1], lift.style_of[0], "default is the tenement style")
	assert_ne(lift.style_of[2], lift.style_of[1], "the warehouse is shop style")


func test_parked_cars_go_to_vehicle_parked_not_the_draw_order() -> void:
	var lift: ChunkLift = _lift(70.0)
	lift._carded = true  # as under a tilt with a card atlas
	VehicleParked.live = true  # a VehicleView draws them
	var c: CityChunk = _chunk([Vector3(0, 0, 0), Vector3(44, 3, 5), Vector3(1, 0, 12)])
	assert_eq(lift.count(c), 2, "the sedan (texture 44) is not drawn flat")
	assert_eq(lift.nth(0, c), 0)
	assert_eq(lift.nth(1, c), 2)
	var cars: PackedVector4Array = VehicleParked._chunks[c.key()]
	assert_eq(cars.size(), 1, "it is handed to VehicleParked by chunk key")
	assert_eq(cars[0], Vector4(3, 5, 0, 44))
	VehicleParked.live = false
	VehicleParked.clear()


func test_parked_cars_stay_flat_without_a_live_vehicle_view() -> void:
	var lift: ChunkLift = _lift(70.0)
	lift._carded = true
	VehicleParked.live = false  # the arena city: no VehicleView
	@warning_ignore("return_value_discarded")
	lift._is_building.resize(64)  # texture 44 (a sedan) is in range: a flat prop
	var c: CityChunk = _chunk([Vector3(0, 0, 0), Vector3(44, 3, 5), Vector3(1, 0, 12)])
	assert_eq(lift.count(c), 3, "the sedan stays a flat prop")
	assert_false(VehicleParked._chunks.has(c.key()), "nothing handed over")
	VehicleParked.clear()
