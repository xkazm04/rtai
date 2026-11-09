extends GutTest


func test_the_patrol_cop_falls_through_the_drawn_in_betweens() -> void:
	var path: String = StreetWalkerFall.path_of("p70", "cop/head_cap")
	assert_eq(path, "p70/cop_patrol_between_fall.png")
	assert_eq(StreetFallBetween.rows_of(path), StreetFallBetween.FRAMES)
	assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + path), "the 5-row grid ships")


func test_a_kind_without_in_betweens_keeps_its_three_rows() -> void:
	var path: String = StreetWalkerFall.path_of("p70", "thug")
	assert_eq(StreetFallBetween.rows_of(path), StreetWalkerFall.FALL_FRAMES)


func test_riot_swat_and_the_suit_fall_through_their_in_betweens_too() -> void:
	for row: String in ["cop/head_helmet", "cop/head_swat", "ped/head_hair"]:
		var path: String = StreetWalkerFall.path_of("p70", row)
		assert_eq(StreetFallBetween.rows_of(path), StreetFallBetween.FRAMES, row)
		assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + path), "%s ships" % path)


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
	assert_eq(StreetFallBetween.swap("p70/thug_long_fall.png"), "p70/thug_long_fall.png")


func test_a_body_that_fell_through_the_in_betweens_lies_face_down() -> void:
	StreetDeadPlan.reset()
	for actor: int in range(40):
		var at: Vector2 = Vector2(actor * 500.0, 0.0)
		var pose: int = StreetDeadPlan.pick(90000 + actor, &"death_bullet", at, true)
		assert_has(StreetFallBetween.FACE_DOWN, pose, "actor %d" % actor)
	StreetDeadPlan.reset()


func _fallen(col: int, flip: bool) -> Sprite2D:
	var card: Sprite2D = Sprite2D.new()
	card.texture = load(StreetWalkerCards.DIR + "p70/cop_patrol_between_fall.png") as Texture2D
	card.hframes = 5
	card.vframes = StreetFallBetween.FRAMES
	card.frame_coords = Vector2i(col, StreetFallBetween.FRAMES - 1)
	card.flip_h = flip
	autofree(card)
	return card


func test_the_corpse_lies_along_the_column_it_fell_in() -> void:
	# it14 critique: the chest-down cell lay head right, then the corpse head up-left (a 120 deg turn)
	var want: PackedInt32Array = [0, 1, 2, 3, 3]
	for col: int in range(5):
		for flip: bool in [false, true]:
			var head: Vector2 = StreetFallBetween.head_of(_fallen(col, flip))
			assert_eq(StreetDead70.cell(head, 0, false), want[col], "col %d" % col)
			assert_eq(StreetDead70.mirrored(head, flip), flip, "col %d flip %s" % [col, flip])


func test_the_fall_heading_mirrors_with_the_card() -> void:
	var right: Vector2 = StreetFallBetween.head_of(_fallen(2, false))
	var left: Vector2 = StreetFallBetween.head_of(_fallen(2, true))
	assert_almost_eq(right.x, 1.0, 0.001)
	assert_almost_eq(left.x, -1.0, 0.001)


func test_the_drawn_corpse_takes_the_fall_card_heading_not_the_blow() -> void:
	StreetDeadPlan.reset()
	var card: Sprite2D = _fallen(2, false)  # chest down, head right
	add_child(card)
	var rig: CutRig = autofree(CutRig.new())
	rig.actor_id = 4242
	rig.react = HumanReact.new()
	rig.react.kind = &"death_bullet"
	rig.react.dir = Vector2(-1.0, -1.0).normalized()  # a blow up-left: StreetDeadHeading lays it so
	StreetDeadPlan.draw(rig, card, "cop/head_cap", 1.0, 0.9)
	var plan: Sprite2D = card.get_node(StreetDeadPlan.NODE) as Sprite2D
	assert_eq(plan.texture, card.texture, "its own grid, not a dead70 cell on another angle")
	assert_eq(plan.frame_coords, Vector2i(2, StreetFallBetween.FRAMES - 1), "the column it fell in")
	assert_false(plan.flip_h, "not mirrored to the left")
	assert_eq(card.self_modulate.a, 0.0, "the card itself is hidden: one body")
	assert_null(card.get_node_or_null(StreetDeadHeading.SIDE_NODE), "drawn art has its own side")
	remove_child(card)
	StreetDeadPlan.reset()


func test_a_corpse_fallen_head_down_mirrors_with_its_card() -> void:
	StreetDeadPlan.reset()
	for flip: bool in [false, true]:
		var card: Sprite2D = _fallen(0, flip)
		add_child(card)
		var rig: CutRig = autofree(CutRig.new())
		rig.actor_id = 4243
		rig.react = HumanReact.new()
		rig.react.kind = &"death_bullet"
		StreetDeadPlan.draw(rig, card, "cop/head_cap", 1.0, 0.9)
		var plan: Sprite2D = card.get_node(StreetDeadPlan.NODE) as Sprite2D
		assert_eq(plan.frame_coords, Vector2i(0, StreetFallBetween.FRAMES - 1), "head down")
		assert_eq(plan.flip_h, flip, "the side the card fell on")
		remove_child(card)
	StreetDeadPlan.reset()


func test_the_grid_corpse_lies_where_the_card_stands_and_its_size() -> void:
	StreetDeadPlan.reset()
	var card: Sprite2D = _fallen(2, false)
	add_child(card)
	card.global_position = Vector2(5000.0, 7000.0)
	card.global_scale = Vector2(0.6, 0.6)
	var rig: CutRig = autofree(CutRig.new())
	rig.actor_id = 4244
	rig.global_position = card.global_position
	rig.react = HumanReact.new()
	rig.react.kind = &"death_bullet"
	StreetDeadPlan.draw(rig, card, "cop/head_cap", 0.6, 0.9)
	var plan: Sprite2D = card.get_node(StreetDeadPlan.NODE) as Sprite2D
	assert_almost_eq(plan.global_scale.x, 0.6, 0.001, "the size the fall card drew it")
	assert_almost_eq(plan.global_scale.y, 0.6, 0.001, "not squashed by the ground")
	assert_lt(plan.global_position.distance_to(card.global_position), 1.0, "where it fell")
	remove_child(card)
	StreetDeadPlan.reset()


func test_a_riot_cop_lies_in_his_own_grid_without_a_painted_side() -> void:
	StreetDeadPlan.reset()
	var card: Sprite2D = _fallen(1, true)
	card.texture = load(StreetWalkerCards.DIR + "p70/cop_riot_between_fall.png") as Texture2D
	add_child(card)
	var rig: CutRig = autofree(CutRig.new())
	rig.actor_id = 4245
	rig.react = HumanReact.new()
	rig.react.kind = &"death_bullet"
	StreetDeadPlan.draw(rig, card, "cop/head_helmet", 1.0, 0.9)
	var plan: Sprite2D = card.get_node(StreetDeadPlan.NODE) as Sprite2D
	assert_eq(plan.texture, card.texture, "the grid drawn for this camera, not the plan poses")
	assert_eq(plan.frame_coords, Vector2i(1, StreetFallBetween.FRAMES - 1))
	assert_true(plan.flip_h)
	assert_null(card.get_node_or_null(StreetDeadHeading.SIDE_NODE), "drawn art has its own side")
	assert_not_null(card.get_node_or_null(StreetDeadHeading.SHADOW_NODE), "still a contact shadow")
	remove_child(card)
	StreetDeadPlan.reset()
