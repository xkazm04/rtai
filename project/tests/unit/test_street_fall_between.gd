extends GutTest


func test_the_patrol_cop_falls_through_the_drawn_in_betweens() -> void:
	var path: String = StreetWalkerFall.path_of("p70", "cop/head_cap")
	assert_eq(path, "p70/cop_patrol_between_fall.png")
	assert_eq(StreetFallBetween.rows_of(path), StreetFallBetween.FRAMES)
	assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + path), "the 5-row grid ships")


func test_a_kind_without_in_betweens_keeps_its_three_rows() -> void:
	var path: String = StreetWalkerFall.path_of("p70", "cop/head_helmet")
	assert_eq(StreetFallBetween.rows_of(path), StreetWalkerFall.FALL_FRAMES)


func test_the_lying_frame_starts_where_it_did() -> void:
	var last: float = StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]
	assert_eq(StreetFallBetween.AT[StreetFallBetween.FRAMES - 1], last, "the corpse hand-over")
	assert_eq(StreetFallBetween.AT[1], StreetWalkerFall.FALL_AT[1], "the hit cell's window")


func test_the_in_betweens_play_in_order_between_mid_fall_and_lying() -> void:
	var rows: int = StreetFallBetween.FRAMES
	assert_eq(StreetWalkerFall.fall_frame(0.2, rows), 1, "mid-fall")
	assert_eq(StreetWalkerFall.fall_frame(0.28, rows), 2, "knees and hands")
	assert_eq(StreetWalkerFall.fall_frame(0.35, rows), 3, "chest down")
	assert_eq(StreetWalkerFall.fall_frame(0.5, rows), 4, "lying")
	assert_eq(StreetWalkerFall.fall_frame(0.35), 1, "a 3-row grid still holds mid-fall")


func test_a_grid_with_no_in_betweens_is_kept() -> void:
	assert_eq(StreetFallBetween.swap("p70/ped_suit_long_fall.png"), "p70/ped_suit_long_fall.png")
