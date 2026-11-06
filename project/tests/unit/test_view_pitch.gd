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
	assert_eq(p.mix_at(55.0), 0.0, "55: the p55 cards only")
	assert_almost_eq(p.mix_at(p.swap_deg), 0.5, 0.001, "half way at swap_deg")
	assert_eq(p.mix_at(p.swap_deg + p.fade_deg * 0.5), 1.0)


func test_a_zero_fade_is_a_hard_swap_and_tilt70_is_all_p70() -> void:
	var p: ViewPitch = ViewPitch.of("combo")
	p.fade_deg = 0.0
	assert_eq(p.mix_at(p.swap_deg - 0.01), 0.0)
	assert_eq(p.mix_at(p.swap_deg), 1.0)
	assert_eq(ViewPitch.of("tilt70").mix_at(70.0), 1.0)
	assert_eq(ViewPitch.of("tilt").mix_at(55.0), 1.0, "tilt: its own p55 folder only")


func test_tilt_draws_p55_and_neither_tilt_nor_top_eases() -> void:
	assert_eq(ViewPitch.of("tilt").art, "p55")
	assert_false(ViewPitch.of("tilt").eases())
	assert_false(ViewPitch.of("top").eases())
	assert_eq(ViewPitch.of("top").art, "")


func test_ease_is_smooth_and_lands_exactly() -> void:
	assert_eq(ViewPitch.eased(70.0, 55.0, 0.0, 1.0), 70.0)
	assert_almost_eq(ViewPitch.eased(70.0, 55.0, 0.5, 1.0), 62.5, 0.001)
	assert_eq(ViewPitch.eased(70.0, 55.0, 1.0, 1.0), 55.0)
	var a: float = ViewPitch.eased(70.0, 55.0, 1.0 / 60.0, 1.0)
	assert_lt(70.0 - a, 0.1, "leaves with near-zero speed (no snap)")


func test_combo_builds_the_cards_from_p70_above_the_swap_and_p55_below() -> void:
	var p: ViewPitch = ViewPitch.of("combo")
	assert_eq(p.boss_art, "p55")
	assert_eq(p.art_at(p.mix_at(70.0)), "p70")
	assert_eq(p.art_at(p.mix_at(55.0)), "p55")
	assert_eq(ViewPitch.of("tilt70").mix_at(70.0), 1.0, "a fixed row: its own art only")


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


func test_overlay_draws_the_other_folder_sized_by_its_own_row_and_fades() -> void:
	var p70: Dictionary[String, Array] = RigHeadCard.rows_of("p70")
	var p55: Dictionary[String, Array] = RigHeadCard.rows_of("p55")
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	var path70: String = p70["king"][0]
	var k70: float = p70["king"][2]
	var k55: float = p55["king"][2]
	var anchor55: float = p55["king"][1]
	card.texture = load(path70) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.set_meta(&"art", "p70")
	card.frame = 3
	card.flip_h = true
	ViewPitchCards.dress(card, "p55", 0.25)
	var o: Sprite2D = card.get_node_or_null(NodePath(String(ViewPitchCards.OVERLAY))) as Sprite2D
	assert_not_null(o, "the p55 King bust overlay on the p70 card")
	assert_eq(o.texture.resource_path, str(p55["king"][0]))
	assert_eq(o.frame, 3)
	assert_true(o.flip_h)
	var cw70: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	var cw55: float = o.texture.get_width() / float(RigHeadCard.FRAMES)
	var want: float = (k55 / cw55) / (k70 / cw70)
	assert_almost_eq(o.scale.x, want, 0.0001, "drawn as wide as RigHeadCard draws the p55 card")
	assert_almost_eq(o.offset.y / o.texture.get_height(), -anchor55, 0.001)
	assert_almost_eq(o.modulate.a, 0.25, 0.001)
	assert_almost_eq(card.self_modulate.a, 0.75, 0.001)
	ViewPitchCards.dress(card, "p55", 0.0)
	assert_false(o.visible)
	assert_eq(card.self_modulate.a, 1.0)
	card.free()


func test_no_overlay_when_the_other_folder_draws_the_same_strip() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.texture = load(RigHeadCard.CARDS["gang"][0]) as Texture2D
	card.set_meta(&"art", "p70")
	ViewPitchCards.dress(card, "p55", 0.5)
	assert_eq(card.get_child_count(), 0, "no p70 or p55 gang card: one base strip")
	assert_eq(card.self_modulate.a, 1.0)
	card.free()


func test_a_ghost_card_cross_fades_to_the_other_folder_as_wide_and_anchored_alike() -> void:
	var card: Sprite2D = Sprite2D.new()
	card.name = &"ghost_card"
	card.texture = load("res://features/souls/art/view/p70/tonnage_card.png") as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.centered = false
	card.offset = Vector2(0.0, -card.texture.get_height() * 0.6)
	assert_eq(ViewPitchCards.art_of(card), "p70", "a ghost card's folder is its strip's")
	ViewPitchCards.dress(card, "p55", 0.4)
	var o: Sprite2D = card.get_node_or_null(NodePath(String(ViewPitchCards.OVERLAY))) as Sprite2D
	assert_not_null(o, "the p55 Tonnage card over the p70 one")
	assert_eq(o.texture.resource_path, "res://features/souls/art/view/p55/tonnage_card.png")
	var w70: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	var w55: float = o.texture.get_width() / float(RigHeadCard.FRAMES)
	assert_almost_eq(o.scale.x * w55, w70, 0.001, "drawn as wide as the card")
	assert_almost_eq(o.offset.y / o.texture.get_height(), -0.6, 0.001, "the same anchor")
	assert_almost_eq(card.self_modulate.a, 0.6, 0.001)
	card.free()
