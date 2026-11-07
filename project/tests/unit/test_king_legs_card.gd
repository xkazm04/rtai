extends GutTest


func test_the_55_legs_sheet_is_the_requested_layout() -> void:
	var tex: Texture2D = KingLegsCard.sheet(55)
	assert_not_null(tex, "art/p55/king_legs.png")
	assert_eq(tex.get_width() % KingLegsCard.COLS, 0)
	assert_eq(tex.get_height() % KingLegsCard.ROWS, 0)


func test_the_70_legs_sheet_is_the_requested_layout_with_a_lift() -> void:
	var tex: Texture2D = KingLegsCard.sheet(70)
	assert_not_null(tex, "art/p70/king_legs.png")
	assert_eq(tex.get_width() % KingLegsCard.COLS, 0)
	assert_eq(tex.get_height() % KingLegsCard.ROWS, 0)
	assert_true(KingLegsCard.LIFT.has(70), "a lift for every drawn pitch")
	assert_true(KingLegsCard.LIFT.has(55))


func test_no_sheet_for_a_pitch_draws_the_parts() -> void:
	assert_null(KingLegsCard.sheet(90), "straight down never has a legs card")


func test_the_legs_stand_on_the_ground_and_the_upper_body_rises() -> void:
	var was: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt")
	ViewMode._shared.art = "p55"
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = "king"
	rig.torso = Node2D.new()
	rig.add_child(rig.torso)
	rig.head = Node2D.new()
	rig.torso.add_child(rig.head)
	var card: Sprite2D = Sprite2D.new()
	card.texture = load(KingArt.strip_path("king", 55.0)) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	rig.head.add_child(card)
	rig.head_card = card
	rig.global_position = Vector2(100.0, 200.0)
	KingLegsCard.step(rig)
	var legs: Sprite2D = card.get_parent().get_node(NodePath(KingLegsCard.NAME)) as Sprite2D
	assert_true(legs.visible == card.visible, "the legs show with the bust")
	assert_eq(legs.global_position, rig.global_position, "the soles on the ground point")
	assert_lt(rig.torso.global_position.y, rig.global_position.y, "bust and arms rise together")
	ViewMode._shared = was


func test_show_parts_hides_the_pelvis_with_the_legs() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.pelvis_spr = Sprite2D.new()
	rig.add_child(rig.pelvis_spr)
	KingLegsCard.show_parts(rig, false)
	assert_false(rig.pelvis_spr.visible, "no ground-level pelvis under the lifted bust")
	KingLegsCard.show_parts(rig, true)
	assert_true(rig.pelvis_spr.visible, "the parts' pelvis comes back without a sheet")


func test_the_gang_keeps_its_own_legs() -> void:
	var was: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt")
	ViewMode._shared.art = "p55"
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = GangPlan.ART_DIR
	rig.torso = Node2D.new()
	rig.add_child(rig.torso)
	var card: Sprite2D = Sprite2D.new()
	rig.torso.add_child(card)
	rig.head_card = card
	rig.pelvis_spr = Sprite2D.new()
	rig.add_child(rig.pelvis_spr)
	rig.global_position = Vector2(100.0, 200.0)
	KingLegsCard.step(rig)
	var legs: Node = rig.torso.get_node_or_null(NodePath(KingLegsCard.NAME))
	assert_null(legs, "no King legs under a bodyguard")
	assert_true(rig.pelvis_spr.visible, "the bodyguard's own parts stay")
	assert_eq(rig.torso.global_position, rig.global_position, "the bodyguard's torso is not lifted")
	ViewMode._shared = was
