extends GutTest


func test_distance_and_cadence_follow_the_measured_support_path() -> void:
	# A planted foot moves 12 texels over three of eight pose advances, at 2 world px/texel.
	var length: float = StrideMatch.cycle_length(12, 3, 8, 2)
	assert_eq(length, 64.0)
	assert_eq(StrideMatch.cadence(96.0, length, 2.0), 1.5)
	assert_eq(StrideMatch.cadence(192.0, length, 2.0), 2.0)
	assert_eq(StrideMatch.cadence(0.0, length, 2.0), 0.0)
	assert_eq(StrideMatch.cadence(1.0, 0.0, 2.0), 0.0)
	assert_eq(StrideMatch.cycle_length(12, 0, 8, 2), 0.0)


func test_one_column_cycle_and_sub_hertz_cap() -> void:
	assert_eq(StrideMatch.cycle_length(6.0, 1, 1, 0.5), 3.0)
	assert_eq(StrideMatch.cadence(12.0, 3.0, 0.5), 0.5)
	assert_eq(StrideMatch.cadence(12.0, 3.0, 0.0), 0.0)


func test_pistol_profile_follows_each_boot_and_other_rows_keep_their_cycle() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.texture = load("res://features/characters/art/view/p55/rivet_walk_eq_pistol.png")
	card.hframes = 4
	card.vframes = 8
	card.frame_coords = Vector2i(0, 2)
	assert_eq(StrideMatch.profile_cycle(card, 1.0, 101.0), 86.0)
	card.frame_coords = Vector2i(2, 2)
	assert_eq(StrideMatch.profile_cycle(card, 1.0, 101.0), 84.0)
	card.frame_coords = Vector2i(1, 3)
	assert_eq(StrideMatch.profile_cycle(card, 1.0, 101.0), 101.0)
	card.texture = load("res://features/characters/art/view/p55/rivet_walk_eq_katana.png")
	card.frame_coords = Vector2i(0, 2)
	assert_eq(StrideMatch.profile_cycle(card, 1.0, 101.0), 101.0)
