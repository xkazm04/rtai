extends GutTest
## n8 view: art is keyed by the view row's art key, not the rounded live pitch (combo's ease).


func test_the_art_key_names_the_pitch() -> void:
	var v: ViewMode = ViewMode.new()
	v.art = "p70"
	v.pitch_deg = 63.0  # mid-ease
	assert_eq(v.art_pitch(), 70.0, "the key, not the live 63")
	v.art = "p55"
	assert_eq(v.art_pitch(), 55.0)


func test_no_key_falls_back_to_the_live_pitch() -> void:
	var v: ViewMode = ViewMode.new()
	v.art = ""
	v.pitch_deg = 55.0
	assert_eq(v.art_pitch(), 55.0, "tilt_basecards keeps the court strip it drew")
	assert_eq(ViewMode.of("top").art_pitch(), 90.0, "straight down stays straight down")
	v.art = "pxx"
	assert_eq(v.art_pitch(), 55.0, "a key that names no pitch is not one")


func test_the_king_strip_mid_ease_is_the_keyed_folder() -> void:
	var path: String = KingArt.strip_path("king", 70.0)
	assert_ne(path, "", "the p70 court strip exists")
	assert_eq(
		KingArt.strip_path("king", 63.0), "", "the rounded live pitch had no folder (the bug)"
	)
