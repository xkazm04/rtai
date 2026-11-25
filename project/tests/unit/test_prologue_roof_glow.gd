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
