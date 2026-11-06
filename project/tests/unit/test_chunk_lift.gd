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


func test_heights_come_from_the_table() -> void:
	var lift: ChunkLift = _lift(70.0)
	assert_eq(lift.height_m[1], 21.0, "building_tall")
	assert_eq(lift.height_m[2], 8.5, "building_warehouse")
	assert_eq(lift.style_of[1], lift.style_of[0], "default is the tenement style")
	assert_ne(lift.style_of[2], lift.style_of[1], "the warehouse is shop style")
