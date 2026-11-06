extends GutTest
## Lane d8-view70: the per-pitch view rows (tilt70, combo), their art folder and the ease.


func test_tilt70_row_draws_the_p70_art_without_an_ease() -> void:
	var p: ViewPitch = ViewPitch.of("tilt70")
	assert_eq(p.play_pitch, 70.0)
	assert_eq(p.art, "p70")
	assert_false(p.eases(), "a fixed pitch")
	assert_eq(ViewMode.of("tilt70").pitch_deg, 70.0)
	assert_true(ViewMode.of("tilt70").cards)


func test_combo_eases_from_70_to_the_boss_pitch_and_cross_fades_the_art() -> void:
	var p: ViewPitch = ViewPitch.of("combo")
	assert_true(p.eases())
	assert_eq(p.boss_pitch, 55.0)
	assert_eq(p.mix_at(70.0), 1.0, "70: the p70 art only")
	assert_eq(p.mix_at(55.0), 0.0, "55: the base (55) cards only")
	assert_almost_eq(p.mix_at(p.swap_deg), 0.5, 0.001, "half way at swap_deg")
	assert_eq(p.mix_at(p.swap_deg + p.fade_deg * 0.5), 1.0)


func test_a_zero_fade_is_a_hard_swap_and_tilt70_is_all_p70() -> void:
	var p: ViewPitch = ViewPitch.of("combo")
	p.fade_deg = 0.0
	assert_eq(p.mix_at(p.swap_deg - 0.01), 0.0)
	assert_eq(p.mix_at(p.swap_deg), 1.0)
	assert_eq(ViewPitch.of("tilt70").mix_at(70.0), 1.0)
	assert_eq(ViewPitch.of("tilt").mix_at(55.0), 0.0, "tilt: no art folder, base cards")


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


func test_overlay_draws_the_p70_strip_as_tall_as_the_card_and_fades() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	card.texture = load(RigHeadCard.CARDS["king"][0]) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.offset = Vector2(-50.0, -card.texture.get_height() * 0.8)
	card.frame = 3
	card.flip_h = true
	ViewPitchCards.dress(card, "p70", 0.25)
	var o: Sprite2D = card.get_node_or_null(NodePath(String(ViewPitchCards.OVERLAY))) as Sprite2D
	assert_not_null(o, "the p70 King bust overlay")
	assert_eq(o.frame, 3)
	assert_true(o.flip_h)
	assert_almost_eq(o.texture.get_height() * o.scale.y, float(card.texture.get_height()), 0.01)
	assert_almost_eq(o.offset.y / o.texture.get_height(), -0.8, 0.001, "the same anchor fraction")
	assert_almost_eq(o.modulate.a, 0.25, 0.001)
	assert_almost_eq(card.self_modulate.a, 0.75, 0.001)
	ViewPitchCards.dress(card, "p70", 0.0)
	assert_false(o.visible)
	card.free()


func test_no_overlay_without_a_folder_strip() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.texture = load(RigHeadCard.CARDS["gang"][0]) as Texture2D
	ViewPitchCards.dress(card, "p70", 1.0)
	assert_eq(card.get_child_count(), 0, "no p70 gang card: the base card draws")
	assert_eq(card.self_modulate.a, 1.0)
	card.free()
