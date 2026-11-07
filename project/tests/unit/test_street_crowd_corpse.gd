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


func test_every_death_frame_has_a_drawn_fall_frame() -> void:
	assert_eq(
		StreetCrowdCorpse.FROM_FALL.size(),
		CrowdAtlas.FRAMES[CrowdAtlas.Clip.DEATH],
		"one fall frame per atlas DEATH frame: no top-down stump left"
	)
	var last: int = StreetCrowdCorpse.FROM_FALL[StreetCrowdCorpse.FROM_FALL.size() - 1]
	assert_eq(last, StreetWalkerFall.FALL_FRAMES - 1, "the held corpse is the lying frame")
	var mid: Image = StreetCrowdCorpse.fall_cell("p70", "cop/head_cap", 1)
	var lying: Image = StreetCrowdCorpse.lying_cell("p70", "cop/head_cap")
	assert_not_null(mid, "the mid-fall frame cuts")
	if mid != null and lying != null:
		assert_ne(mid.get_size(), lying.get_size(), "the mid-fall is its own drawing")
