extends GutTest
## d8 bosses: the court's card strips are picked by the view row's pitch; straight down none.


func test_top_draws_no_court_strip() -> void:
	assert_eq(KingArt.strip_path("king", 90.0), "")
	assert_eq(KingArt.strip_path("gang", 90.0), "")


func test_pitch_55_picks_the_p55_strips() -> void:
	assert_eq(
		KingArt.strip_path("king", 55.0), "res://features/bosses/king/art/p55/king_bust_card.png"
	)
	assert_eq(
		KingArt.strip_path("gang", 55.0), "res://features/bosses/king/art/p55/gang_head_card.png"
	)


func test_a_pitch_without_strips_keeps_the_shared_card() -> void:
	assert_eq(KingArt.strip_path("king", 65.0), "")
	assert_eq(KingArt.strip_path("rivet", 55.0), "")


func test_strips_hold_five_facings() -> void:
	for dir: String in KingArt.STRIPS:
		var tex: Texture2D = load(KingArt.strip_path(dir, 55.0)) as Texture2D
		assert_not_null(tex, dir)
		assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, dir)
