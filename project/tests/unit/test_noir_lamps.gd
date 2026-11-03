extends GutTest

const LAMP: int = 24


func _chunk(cmds: Array[Array]) -> CityChunk:
	var c: CityChunk = CityChunk.new(0, 0)
	for cmd: Array in cmds:
		var t: int = cmd[0]
		@warning_ignore("return_value_discarded")
		c.tex.append(t)
		for k: int in 4:
			var v: float = cmd[1 + k]
			@warning_ignore("return_value_discarded")
			c.xf.append(v)
	return c


func test_table_names_the_lamp_post() -> void:
	var lamps: NoirLamps = NoirLamps.new(CityGen.read_json(CitySystem.TEXTURES))
	assert_eq(lamps.tex_id, LAMP)


func test_scan_skips_the_shadow_and_lights_under_the_head() -> void:
	var c: CityChunk = _chunk(
		[[LAMP, 10.18, 20.18, 0.0, 1.0], [LAMP, 10.0, 20.0, 0.0, 0.0], [3, 1, 1, 0, 0]]
	)
	var found: PackedVector2Array = NoirLamps.scan(c, LAMP)
	assert_eq(found.size(), 1, "the offset shadow copy is not a second lamp")
	assert_almost_eq(found[0], Vector2(10.0 + NoirLamps.HEAD_M, 20.0), Vector2.ONE * 0.001)


func test_head_follows_the_arm_rotation() -> void:
	var c: CityChunk = _chunk([[LAMP, 5.0, 5.0, PI * 0.5, 0.0]])
	var found: PackedVector2Array = NoirLamps.scan(c, LAMP)
	assert_almost_eq(found[0], Vector2(5.0, 5.0 + NoirLamps.HEAD_M), Vector2.ONE * 0.001)


func test_screen_px_matches_the_pass_world_offset() -> void:
	var px: PackedVector2Array = NoirLamps.to_screen(
		PackedVector2Array([Vector2(10, 5)]), Vector2(100, 40), 1.5
	)
	assert_eq(px[0], Vector2(10, 5) * SimConst.PX_PER_M * 1.5 - Vector2(100, 40))


func test_params_light_the_street() -> void:
	var frame: Dictionary = NoirLook.read_params(NoirLook.PARAMS)["frame"]
	var r: float = frame.get("lamp_r", 0.0)
	var lift: float = frame.get("lamp_lift", 0.0)
	assert_gt(r, 0.0)
	assert_gt(lift, 0.0)
