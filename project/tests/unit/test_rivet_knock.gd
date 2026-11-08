extends GutTest
## n9 rivet it7: a car's knock plays the drawn knock-down strip (row by the throw, column by time).


func after_each() -> void:
	RivetKnock.enabled = true


func test_each_art_key_has_a_square_four_by_four_knock_grid() -> void:
	for art: String in ["p70", "p55"]:
		var tex: Texture2D = load(RivetStrips.DIR + art + "/" + RivetKnock.STRIP) as Texture2D
		assert_not_null(tex, art)
		assert_eq(tex.get_width(), tex.get_height(), art)
		assert_eq(tex.get_width() % RivetKnock.CELLS, 0, art)


func test_the_row_is_the_throw_in_screen_space() -> void:
	assert_eq(RivetKnock.row_of(Vector2(0.2, 1.0)), RivetKnock.Row.TOWARD)
	assert_eq(RivetKnock.row_of(Vector2(-0.2, -1.0)), RivetKnock.Row.AWAY)
	assert_eq(RivetKnock.row_of(Vector2(1.0, 0.6)), RivetKnock.Row.RIGHT)
	assert_eq(RivetKnock.row_of(Vector2(-1.0, -0.6)), RivetKnock.Row.LEFT)


func test_the_column_steps_impact_tumble_slide_down_over_the_down_time() -> void:
	assert_eq(RivetKnock.col_of(0), 0)
	assert_eq(RivetKnock.col_of(5), 0)
	assert_eq(RivetKnock.col_of(6), 1)
	assert_eq(RivetKnock.col_of(30), 2)
	assert_eq(RivetKnock.col_of(71), 3)
	assert_eq(RivetKnock.col_of(500), 3)


func test_the_lying_cells_turn_onto_a_diagonal_throw_and_the_impact_stays_upright() -> void:
	var h: Vector2 = Vector2.from_angle(deg_to_rad(30.0))
	assert_almost_eq(RivetKnock.turn_of(h, 2), deg_to_rad(30.0), 0.001)
	assert_eq(RivetKnock.turn_of(h, 0), 0.0)
	var left_down: Vector2 = Vector2.from_angle(deg_to_rad(160.0))
	assert_almost_eq(RivetKnock.turn_of(left_down, 3), deg_to_rad(-20.0), 0.001)
	assert_lt(absf(RivetKnock.turn_of(Vector2(0.7, 0.71).normalized(), 1)), PI * 0.25 + 0.001)


func test_the_knock_wins_over_the_drawn_figure_only_while_it_is_set() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var base: String = RivetStrips.DIR + "p70/" + RivetStrips.BASE
	assert_eq(RivetKnock.path_or(rig, "p70", base), base)
	rig.set_meta(RivetKnock.KNOCK, Vector3(1.0, 0.0, 120.0))
	assert_eq(RivetKnock.path_or(rig, "p70", base), RivetStrips.DIR + "p70/" + RivetKnock.STRIP)
	assert_eq(RivetKnock.path_or(rig, "p70", ""), "", "no drawn figure (top): nothing to swap")
	RivetKnock.enabled = false
	assert_eq(RivetKnock.path_or(rig, "p70", base), base, "--rivet-knock=off")


func test_place_centres_the_cell_on_his_ground_point() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var card: Sprite2D = autofree(Sprite2D.new())
	rig.add_child(card)
	var path: String = RivetStrips.DIR + "p70/" + RivetKnock.STRIP
	card.texture = load(path) as Texture2D
	card.set_meta(RivetFrames.ON, path)
	rig.set_meta(RivetKnock.KNOCK, Vector3(-1.0, 0.0, 10.0))
	assert_true(RivetKnock.shows(card))
	RivetKnock.place(rig, card, 0.5, 52.8)
	var w: float = card.texture.get_width() / 4.0
	assert_eq(card.frame, RivetKnock.Row.LEFT * RivetKnock.CELLS)
	assert_eq(card.offset, Vector2(-w * 0.5, -w * 0.5))
	assert_eq(card.global_position, rig.global_position)
	assert_true(rig.has_meta(RigCastShadows.CAST_HIP))
