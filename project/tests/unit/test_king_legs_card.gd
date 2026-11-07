extends GutTest


func test_the_55_legs_sheet_is_the_requested_layout() -> void:
	var tex: Texture2D = KingLegsCard.sheet(55)
	assert_not_null(tex, "art/p55/king_legs.png")
	assert_eq(tex.get_width() % KingLegsCard.COLS, 0)
	assert_eq(tex.get_height() % KingLegsCard.ROWS, 0)


func test_no_sheet_for_a_pitch_draws_the_parts() -> void:
	assert_null(KingLegsCard.sheet(90), "straight down never has a legs card")
