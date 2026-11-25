extends GutTest


func _table() -> DataTable:
	return DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)


func test_only_arched_line_has_a_roof_glow_and_it_ends_north_of_the_wall_base() -> void:
	var table: DataTable = _table()
	var look: PrologueYardDressing = PrologueYardDressing.resolve("arched_line", "", table)
	assert_false(look.roof_glow.is_empty())
	var rect: Rect2 = look.roof_glow["rect_m"]
	var wall_base: float = look.impression.rect.position.y
	assert_almost_eq(wall_base, -1.1, 0.001)
	assert_lt(rect.end.y, wall_base - 4.0, "the band stays over the roof, off the yard floor")
	assert_gt(rect.size.y, 4.0)
	for id: String in table.object(table.raw, "dressings"):
		if id != "arched_line":
			assert_true(PrologueYardDressing.resolve(id, "", table).roof_glow.is_empty(), id)


func test_band_covers_the_rect_and_flicker_steps_on_ticks_only() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("arched_line", "", _table())
	var glow: PrologueRoofGlow = autofree(PrologueRoofGlow.build(look.roof_glow))
	var band: ColorRect = glow.get_node(PrologueRoofGlow.BAND_NAME)
	var rect: Rect2 = look.roof_glow["rect_m"]
	assert_eq(
		Rect2(band.position, band.size),
		Rect2(rect.position * SimConst.PX_PER_M, rect.size * SimConst.PX_PER_M)
	)
	var material: ShaderMaterial = band.material
	var ticks: int = look.roof_glow["step_ticks"]
	glow.step(ticks)
	var level: float = material.get_shader_parameter(&"flicker")
	glow.step(ticks * 2 - 1)
	var again: float = material.get_shader_parameter(&"flicker")
	assert_eq(again, level, "same step, same level")
	var depth: float = look.roof_glow["flicker"]
	for tick: int in range(0, ticks * 40, ticks):
		glow.step(tick)
		var now: float = material.get_shader_parameter(&"flicker")
		assert_between(now, 1.0 - depth - 0.0001, 1.0001)


func test_no_spec_attaches_nothing() -> void:
	var stage: PrintStage = autofree(PrintStage.new())
	var before: int = stage.get_child_count()
	PrologueRoofGlow.attach(stage, {}, null)
	assert_eq(stage.get_child_count(), before)


func _spec() -> Dictionary:
	return {
		"rect_m": Rect2(Vector2(2, -9), Vector2(30, 6)),
		"color": Color(1.0, 0.5, 0.1),
		"hot_color": Color(1.0, 0.9, 0.2),
		"strength": 0.7,
		"flicker": 0.4,
		"step_ticks": 4,
	}


func _swing(k: float) -> float:
	return 0.5 + 0.5 * sin(k * 1.7) * sin(k * 0.63 + 1.0)


func test_build_hands_the_row_colours_size_and_strength_to_the_shader() -> void:
	var glow: PrologueRoofGlow = autofree(PrologueRoofGlow.build(_spec()))
	var band: ColorRect = glow.get_node(PrologueRoofGlow.BAND_NAME)
	var material: ShaderMaterial = band.material
	assert_eq(material.shader, PrologueRoofGlow.SHADER)
	var color: Color = material.get_shader_parameter(&"color")
	var hot: Color = material.get_shader_parameter(&"hot_color")
	var size: Vector2 = material.get_shader_parameter(&"size_m")
	var strength: float = material.get_shader_parameter(&"strength")
	assert_eq(color, Color(1.0, 0.5, 0.1))
	assert_eq(hot, Color(1.0, 0.9, 0.2))
	assert_eq(size, Vector2(30, 6))
	assert_eq(strength, 0.7)
	assert_eq(glow.layer, RenderLayers.canvas(&"actors"))
	assert_true(glow.follow_viewport_enabled)


func test_build_starts_on_step_zero_and_each_step_follows_the_fixed_function() -> void:
	var glow: PrologueRoofGlow = autofree(PrologueRoofGlow.build(_spec()))
	var band: ColorRect = glow.get_node(PrologueRoofGlow.BAND_NAME)
	var material: ShaderMaterial = band.material
	var first: float = material.get_shader_parameter(&"flicker")
	var phase0: float = material.get_shader_parameter(&"phase")
	assert_almost_eq(first, 1.0 - 0.4 * 0.5, 0.0001)
	assert_eq(phase0, 0.0)
	for k: int in [1, 3, 7]:
		glow.step(k * 4 + 3)
		var level: float = material.get_shader_parameter(&"flicker")
		assert_almost_eq(level, 1.0 - 0.4 * _swing(float(k)), 0.0001, "step %d" % k)
		var phase: float = material.get_shader_parameter(&"phase")
		assert_almost_eq(phase, float(k) * 0.37, 0.0001, "phase %d" % k)


func test_read_takes_the_row_and_floors_step_ticks_at_one() -> void:
	var table: DataTable = _table()
	var dressings: Dictionary = table.object(table.raw, "dressings")
	var arched: Dictionary = dressings["arched_line"]
	var row: Dictionary = table.object(arched, "roof_glow").duplicate(true)
	var spec: Dictionary = PrologueRoofGlow.read(table, row)
	var want_color: Color = Color(table.text(row, "color"))
	var want_hot: Color = Color(table.text(row, "hot_color"))
	var got_color: Color = spec["color"]
	var got_hot: Color = spec["hot_color"]
	assert_eq(got_color, want_color)
	assert_eq(got_hot, want_hot)
	var strength: float = spec["strength"]
	var flicker: float = spec["flicker"]
	var ticks: int = spec["step_ticks"]
	assert_eq(strength, table.num(row, "strength"))
	assert_eq(flicker, table.num(row, "flicker"))
	assert_eq(ticks, table.integer(row, "step_ticks"))
	row["step_ticks"] = 0
	var floored: Dictionary = PrologueRoofGlow.read(table, row)
	var floor_ticks: int = floored["step_ticks"]
	assert_eq(floor_ticks, 1)


func _flicker_of(glow: PrologueRoofGlow) -> float:
	var band: ColorRect = glow.get_node(PrologueRoofGlow.BAND_NAME)
	var material: ShaderMaterial = band.material
	return material.get_shader_parameter(&"flicker")


func test_process_without_a_stage_keeps_the_flicker_and_does_not_fail() -> void:
	var glow: PrologueRoofGlow = autofree(PrologueRoofGlow.build(_spec()))
	var before: float = _flicker_of(glow)
	glow._process(0.016)
	assert_eq(_flicker_of(glow), before, "no stage: nothing to follow, the level holds")


func test_process_with_a_stage_follows_its_tick() -> void:
	var stage: ArenaStage = ArenaStage.new(
		ArenaPlan.shipped(Vector2(524, 524)), ArenaStations.new()
	)
	var glow: PrologueRoofGlow = autofree(PrologueRoofGlow.build(_spec()))
	glow._stage = stage
	stage.tick = 4 * 7 + 1
	glow._process(0.016)
	assert_almost_eq(_flicker_of(glow), 1.0 - 0.4 * _swing(7.0), 0.0001, "step 7 of the stage tick")
