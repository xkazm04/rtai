extends GutTest
## n17 npc-react (DEFECTS 22): StreetFallFit draws a fall grid's buckle and mid-fall rows at the
## walk's size and its chest-down and lying rows as drawn.


func _grid(file: String) -> Sprite2D:
	var cells: Sprite2D = autofree(Sprite2D.new())
	cells.texture = load(StreetWalkerCards.DIR + file) as Texture2D
	cells.hframes = RigHeadCard.FRAMES
	cells.vframes = StreetFallBetween.FRAMES
	return cells


func test_every_fit_grid_exists_and_keeps_the_lying_rows_as_drawn() -> void:
	for file: String in StreetFallFit.FIT_K:
		var ks: Array = StreetFallFit.FIT_K[file]
		assert_eq(ks.size(), StreetFallBetween.FRAMES, file)
		assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + file), file)
		var chest: float = ks[3]
		var lying: float = ks[4]
		assert_eq(chest, 1.0, file + ": chest down as drawn")
		assert_eq(lying, 1.0, file + ": the corpse keeps its length")
		for i: int in 3:
			var k: float = ks[i]
			assert_between(k, 0.78, 1.0, file + ": a standing row only drawn down")


func test_the_mid_fall_row_draws_smaller_than_the_lying_row() -> void:
	var cells: Sprite2D = _grid("p70/cop_patrol_between_fall.png")
	cells.frame_coords = Vector2i(0, 1)
	assert_almost_eq(StreetFallFit.k(cells), 0.89, 0.001)
	cells.frame_coords = Vector2i(2, 4)
	assert_eq(StreetFallFit.k(cells), 1.0)


func test_fit_scales_from_the_cut_scale_without_compounding() -> void:
	var cells: Sprite2D = _grid("p70/swat_between_fall.png")
	cells.scale = Vector2(0.5, 0.5)
	for row: int in [1, 1, 4, 0]:
		cells.frame_coords = Vector2i(0, row)
		StreetFallFit.fit(cells)
	assert_almost_eq(cells.scale.x, 0.5 * 0.94, 0.0001, "row 0 of the base, not of the last step")


func test_a_grid_without_a_fit_draws_as_drawn() -> void:
	var cells: Sprite2D = _grid("p70/cop_riot_between_fall.png")
	cells.frame_coords = Vector2i(0, 1)
	assert_eq(StreetFallFit.k(cells), 1.0)
