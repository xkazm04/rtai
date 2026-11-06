extends GutTest


func test_a_long_x_row_has_one_foot_per_cell_on_the_south_edge() -> void:
	var feet: Array[Vector2] = ArenaPropCards.row_feet(Rect2(0.0, 0.0, 96.0, 32.0))
	assert_eq(feet.size(), 3)
	assert_eq(feet[0], Vector2(16.0, 32.0))
	assert_eq(feet[2], Vector2(80.0, 32.0))


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
