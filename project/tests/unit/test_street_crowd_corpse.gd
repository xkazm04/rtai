extends GutTest
## Lane n8 street: the baked crowd atlas's corpse cell under a card view (StreetCrowdCorpse).


func test_a_drawn_fall_row_gives_a_lying_body_inside_the_cell() -> void:
	for row: String in ["cop/head_cap", "ped/head_hat", "ped/head_bald"]:
		var body: Image = StreetCrowdCorpse.lying_cell("p70", row)
		assert_not_null(body, row)
		if body != null:
			assert_lte(body.get_height(), CrowdAtlas.CELL_PX, "%s fits the cell" % row)
			assert_gt(body.get_height(), body.get_width(), "%s lies along +y" % row)


func test_p55_falls_back_per_row_and_unknown_rows_draw_nothing() -> void:
	assert_not_null(StreetCrowdCorpse.lying_cell("p55", "ped/head_hat"), "the p70 grid at p55")
	assert_null(StreetCrowdCorpse.lying_cell("p70", "no/such_row"), "no drawn fall: the bake")


func test_straight_down_the_atlas_is_untouched() -> void:
	var image: Image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	StreetCrowdCorpse.stamp(image, [])
	assert_eq(image.get_pixel(5, 5), Color.WHITE, "the shipped view keeps the baked cells")
