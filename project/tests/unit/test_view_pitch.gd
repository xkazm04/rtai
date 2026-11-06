extends GutTest
## Lane d8-view70: the per-pitch view rows (tilt70, combo), their art folder and the ease.


func test_tilt70_row_draws_the_p70_art_without_an_ease() -> void:
	var p: ViewPitch = ViewPitch.of("tilt70")
	assert_eq(p.play_pitch, 70.0)
	assert_eq(p.art, "p70")
	assert_false(p.eases(), "a fixed pitch")
	assert_eq(ViewMode.of("tilt70").pitch_deg, 70.0)
	assert_true(ViewMode.of("tilt70").cards)


func test_combo_eases_from_70_to_the_boss_pitch_and_swaps_art_at_swap_deg() -> void:
	var p: ViewPitch = ViewPitch.of("combo")
	assert_true(p.eases())
	assert_eq(p.boss_pitch, 55.0)
	assert_eq(p.art_at(70.0), "p70")
	assert_eq(p.art_at(p.swap_deg - 0.1), "", "below the swap the base (55) cards")


func test_tilt_and_top_have_no_art_folder() -> void:
	assert_eq(ViewPitch.of("tilt").art, "")
	assert_false(ViewPitch.of("top").eases())


func test_ease_is_smooth_and_lands_exactly() -> void:
	assert_eq(ViewPitch.eased(70.0, 55.0, 0.0, 1.0), 70.0)
	assert_almost_eq(ViewPitch.eased(70.0, 55.0, 0.5, 1.0), 62.5, 0.001)
	assert_eq(ViewPitch.eased(70.0, 55.0, 1.0, 1.0), 55.0)
	var a: float = ViewPitch.eased(70.0, 55.0, 1.0 / 60.0, 1.0)
	assert_lt(70.0 - a, 0.1, "leaves with near-zero speed (no snap)")


func test_card_path_falls_back_to_the_base_card() -> void:
	var base: String = RigHeadCard.CARDS["rivet"][0]
	assert_eq(ViewPitch.card_path(base, ""), base)
	assert_eq(
		ViewPitch.card_path(base, "p70"),
		"res://features/characters/art/view/p70/rivet_head_card.png"
	)
	var king: String = RigHeadCard.CARDS["king"][0]
	assert_eq(ViewPitch.card_path(king, "nope"), king)


func test_ease_turns_back_mid_ease_without_a_jump() -> void:
	var e: ViewPitchEase = ViewPitchEase.new()
	e.pitch = ViewPitch.of("combo")
	var view: ViewMode = ViewMode.shared()
	var keep: float = view.pitch_deg
	view.pitch_deg = 70.0
	view.pitch_deg = e.step(0, true)
	view.pitch_deg = e.step(30, true)
	var mid: float = view.pitch_deg
	assert_almost_eq(mid, 62.5, 0.01, "half way at 0.5 s")
	assert_eq(e.step(31, false), mid, "a turn back starts where it is")
	view.pitch_deg = keep
	e.free()
