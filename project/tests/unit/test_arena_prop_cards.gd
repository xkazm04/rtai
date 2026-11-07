extends GutTest


func test_an_east_west_row_is_one_stack_on_its_south_edge() -> void:
	var feet: Array[Vector2] = ArenaPropCards.row_feet(Rect2(0.0, 0.0, 96.0, 32.0))
	assert_eq(feet, [Vector2(48.0, 32.0)] as Array[Vector2])


func test_a_north_south_row_steps_its_feet_down_the_screen() -> void:
	var feet: Array[Vector2] = ArenaPropCards.row_feet(Rect2(10.0, 0.0, 20.0, 60.0))
	assert_eq(feet.size(), 3)
	assert_eq(feet[0], Vector2(20.0, 20.0))
	assert_eq(feet[2], Vector2(20.0, 60.0), "the last card stands on the row's south edge")


func test_walls_never_become_cards() -> void:
	var ci: Node2D = autofree(Node2D.new())
	assert_false(ArenaPropCards.draw(ci, "wall_high", Rect2(0.0, 0.0, 32.0, 32.0)))
	assert_false(ArenaPropCards.CARD.has("door"))


func test_under_top_the_floor_draws_no_card() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("top")
	var ci: Node2D = autofree(Node2D.new())
	var drawn: bool = ArenaPropCards.draw(ci, "cone", Rect2(0.0, 0.0, 32.0, 32.0))
	ViewMode._shared = saved
	assert_false(drawn, "PropCards.named() is null under a flat view (or city is not merged)")


func test_stand_rect_is_empty_without_city_or_for_a_wall() -> void:
	var r: Rect2 = Rect2(0.0, 0.0, 144.0, 48.0)
	assert_false(ArenaPropCards.stand_rect("wall_high", r).has_area(), "walls keep their box")
	if not ResourceLoader.exists(ArenaPropCards.SCRIPT):
		assert_false(ArenaPropCards.stand_rect("cover_low", r).has_area(), "city not merged")


func test_cut_polys_fall_back_to_the_area_quad_without_city_outlines() -> void:
	var area: Rect2 = Rect2(10.0, -40.0, 30.0, 50.0)
	var cut: Array[PackedVector2Array] = ArenaPropCards.cut_polys("wall", Rect2(), area)
	assert_eq(cut.size(), 1)
	assert_eq(
		cut[0],
		PackedVector2Array([area.position, Vector2(40.0, -40.0), area.end, Vector2(10.0, 10.0)])
	)
