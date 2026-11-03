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


func test_uv_is_the_camera_mapping() -> void:
	var view: Vector2 = Vector2(1422, 800)
	var lamps: PackedVector2Array = PackedVector2Array([Vector2(10, 5), Vector2(12, 5)])
	var uv: PackedVector2Array = NoirLamps.to_uv(lamps, Vector2(10, 5), 1.5, view)
	assert_almost_eq(uv[0], Vector2(0.5, 0.5), Vector2.ONE * 1e-6, "the focus is the screen centre")
	var dx: float = 2.0 * SimConst.PX_PER_M * 1.5 / view.x
	assert_almost_eq(uv[1].x - uv[0].x, dx, 1e-6)


func test_headlights_take_live_cars_only() -> void:
	var snap: PackedFloat64Array = PackedFloat64Array()
	# id, kind, mode, tier, x, y, hx, hy, + 6 more (SNAP_STRIDE 14)
	var rows: Array[Array] = [
		[0, SimConst.K_CAR, SimConst.M_WALK, 0, 10, 5, 1, 0],
		[1, SimConst.K_PED, SimConst.M_WALK, 0, 11, 5, 1, 0],
		[2, SimConst.K_PCAR, SimConst.M_DEAD, 0, 12, 5, 0, 1],
		[3, SimConst.K_PCAR, SimConst.M_WALK, 0, 9, 6, 0, -1],
	]
	for row: Array in rows:
		for k: int in SimConst.SNAP_STRIDE:
			var v: float = row[k] if k < row.size() else 0.0
			@warning_ignore("return_value_discarded")
			snap.append(v)
	var cars: PackedVector4Array = NoirHeadlights.near(snap, Vector2(10, 5), Vector2(20, 12), 9.0)
	assert_eq(cars.size(), 2, "the ped and the wrecked police car throw no light")
	# nearest the focus first
	var nose: float = NoirHeadlights.NOSE_M
	assert_almost_eq(cars[1], Vector4(10 + nose, 5, 1, 0), Vector4.ONE * 1e-6)
	assert_almost_eq(cars[0], Vector4(9, 6 - nose, 0, -1), Vector4.ONE * 1e-6)


func test_params_light_the_street() -> void:
	var frame: Dictionary = NoirLook.read_params(NoirLook.PARAMS)["frame"]
	var r: float = frame.get("lamp_r", 0.0)
	var lift: float = frame.get("lamp_lift", 0.0)
	assert_gt(r, 0.0)
	assert_gt(lift, 0.0)
