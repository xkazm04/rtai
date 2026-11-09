extends GutTest
## n11 (the owner: dead bodies get bigger): at combo ViewPitchEase dresses every card each frame;
## it gave a lying body's hidden fall frame its alpha back, so the fall frame and the plan pose both
## drew, two bodies on one spot.


func _card(lying: bool) -> Sprite2D:
	var card: Sprite2D = Sprite2D.new()
	add_child_autofree(card)
	if lying:
		var plan: Sprite2D = Sprite2D.new()
		plan.name = StreetDeadPlan.NODE
		card.add_child(plan)
		card.self_modulate.a = 0.0
	return card


func test_the_fall_frame_of_a_lying_body_stays_hidden() -> void:
	var card: Sprite2D = _card(true)
	ViewPitchCards.dress(card, "p55", 0.0)
	assert_eq(card.self_modulate.a, 0.0, "the plan pose is the body: its fall frame stays hidden")


func test_a_standing_card_is_drawn_whole() -> void:
	var card: Sprite2D = _card(false)
	card.self_modulate.a = 0.4
	ViewPitchCards.dress(card, "p55", 0.0)
	assert_eq(card.self_modulate.a, 1.0, "no overlay: the card draws at full alpha")


func test_a_lying_body_shows_no_fading_overlay() -> void:
	var card: Sprite2D = _card(true)
	var overlay: Sprite2D = Sprite2D.new()
	overlay.name = ViewPitchCards.OVERLAY
	overlay.set_meta(&"art", "p55")
	card.add_child(overlay)
	ViewPitchCards.dress(card, "p55", 0.5)
	assert_false(overlay.visible, "the other folder's fall frame would be a third body")
	assert_eq(card.self_modulate.a, 0.0, "and the card stays hidden through the fade")
