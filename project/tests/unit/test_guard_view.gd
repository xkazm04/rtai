extends GutTest

const STRIP: Texture2D = preload("res://features/characters/art/view/p70/rivet_frames.png")


func test_lowering_guard_restores_the_pitched_figures_existing_opacity() -> void:
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	card.self_modulate.a = 0.75
	var pose: PlayerGuardPose = PlayerGuardPose.for_card(card, "p70", true)
	assert_not_null(pose)
	assert_true(pose.visible)
	assert_eq(card.self_modulate.a, 0.0)
	assert_same(pose, PlayerGuardPose.for_card(card, "p70", true))
	assert_null(PlayerGuardPose.for_card(card, "p70", false))
	assert_false(pose.visible)
	assert_almost_eq(card.self_modulate.a, 0.75, 0.0001)


func test_flat_art_and_a_lowered_guard_allocate_no_pose() -> void:
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	assert_null(PlayerGuardPose.for_card(card, "", true))
	assert_null(PlayerGuardPose.for_card(card, "p55", false))
	assert_eq(card.get_child_count(), 0)


func test_mirrored_pose_turns_about_the_same_foot_position_at_gameplay_scale() -> void:
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	card.rotation = 0.5
	card.scale = Vector2(1.5, 0.8)
	var pose: PlayerGuardPose = PlayerGuardPose.for_card(card, "p70", true)
	pose.strip("p70", STRIP, 14, 0.0)
	var feet: Vector2 = Vector2(40.0, 64.0)
	for mirror: bool in [false, true]:
		pose.face(1, mirror, 0.5, 0.0, feet)
		var forward: Vector2 = Vector2.LEFT if mirror else Vector2.RIGHT
		assert_almost_eq(pose.global_position, feet, Vector2.ONE * 0.0001)
		assert_almost_eq(pose.to_global(Vector2.RIGHT), feet + forward * 0.5, Vector2.ONE * 0.0001)
