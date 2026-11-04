extends GutTest
## FightScorch: a fire patch that goes out leaves its char, which holds and then fades away.


func _gone(areas: FightAreas, i: int) -> void:
	areas.patches.remove_at(i)
	areas.patch_ticks.remove_at(i)


func test_a_patch_that_goes_out_leaves_a_char() -> void:
	var areas: FightAreas = FightAreas.new()
	var scorch: FightScorch = FightScorch.new()
	areas.add_patch(Vector2(3.0, 4.0), 1.5, 60, 20.0)
	scorch.step(areas, 100)
	assert_eq(scorch.marks.size(), 0, "no char while the fire burns (the live patch draws it)")
	_gone(areas, 0)
	scorch.step(areas, 101)
	assert_eq(scorch.marks.size(), 1)
	assert_eq(scorch.marks[0], Vector4(3.0, 4.0, 1.5, 101.0))


func test_the_char_holds_then_fades_out() -> void:
	var areas: FightAreas = FightAreas.new()
	var scorch: FightScorch = FightScorch.new()
	areas.add_patch(Vector2.ZERO, 1.5, 60, 20.0)
	scorch.step(areas, 0)
	_gone(areas, 0)
	scorch.step(areas, 1)
	scorch.step(areas, 1 + FightScorch.HOLD_TICKS + FightScorch.FADE_TICKS - 1)
	assert_eq(scorch.marks.size(), 1, "still fading")
	scorch.step(areas, 1 + FightScorch.HOLD_TICKS + FightScorch.FADE_TICKS)
	assert_eq(scorch.marks.size(), 0, "gone")


func test_the_nuke_ring_leaves_no_char() -> void:
	var areas: FightAreas = FightAreas.new()
	var scorch: FightScorch = FightScorch.new()
	areas.add_patch(Vector2.ZERO, FightAreasArt.RING_PATCH_M + 2.0, 60, 20.0)
	scorch.step(areas, 0)
	_gone(areas, 0)
	scorch.step(areas, 1)
	assert_eq(scorch.marks.size(), 0)


func test_marks_are_capped() -> void:
	var areas: FightAreas = FightAreas.new()
	var scorch: FightScorch = FightScorch.new()
	for i: int in FightScorch.MAX_MARKS + 5:
		areas.add_patch(Vector2(float(i) * 4.0, 0.0), 1.0, 60, 20.0)
	scorch.step(areas, 0)
	areas.patches.clear()
	areas.patch_ticks.clear()
	scorch.step(areas, 1)
	assert_eq(scorch.marks.size(), FightScorch.MAX_MARKS)
