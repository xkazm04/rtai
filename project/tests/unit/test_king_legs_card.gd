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


func test_an_art_dir_without_a_sheet_keeps_its_parts() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = "thug"
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
	assert_null(legs, "only the court's listed art dirs stand on drawn legs")
	assert_true(rig.pelvis_spr.visible, "its own parts stay")
	assert_eq(rig.torso.global_position, rig.global_position, "its torso is not lifted")


func test_the_king_and_his_gang_have_a_sheet_at_both_pitches() -> void:
	for art_dir: String in ["king", GangPlan.ART_DIR]:
		assert_true(KingLegsCard.SHEETS.has(art_dir), art_dir)
		for pitch: int in [55, 70]:
			assert_not_null(KingLegsCard.sheet(pitch, KingLegsCard.SHEETS[art_dir]), art_dir)


func test_the_gang_stands_on_its_own_steel_sheet() -> void:
	var gang: String = KingLegsCard.SHEETS[GangPlan.ART_DIR]
	assert_ne(gang, KingLegsCard.SHEETS["king"], "the bodyguards no longer wear the King's legs")
	for pitch: int in [55, 70]:
		var own: Texture2D = KingLegsCard.sheet(pitch, gang)
		var king: Texture2D = KingLegsCard.sheet(pitch, KingLegsCard.SHEETS["king"])
		assert_eq(own.get_size(), king.get_size(), "a drop-in on the King's canvas at %d" % pitch)


func test_the_walk_row_follows_the_ground_walked() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var legs: Node = autofree(Node.new())
	rig.speed_now = 100.0
	rig.global_position = Vector2.ZERO
	assert_eq(KingLegsCard.walk_row(rig, legs, 100.0), 1, "no ground walked yet: the first frame")
	rig.global_position = Vector2(30.0, 0.0)
	assert_eq(KingLegsCard.walk_row(rig, legs, 100.0), 2, "0.3 of a drawn cycle: the second frame")
	rig.global_position = Vector2(30.0, 40.0)
	assert_eq(KingLegsCard.walk_row(rig, legs, 100.0), 3, "0.7: the third, whatever the heading")
	rig.global_position = Vector2(30.0, 80.0)
	assert_eq(KingLegsCard.walk_row(rig, legs, 100.0), 1, "1.1: round the cycle again")
	rig.speed_now = 0.0
	assert_eq(KingLegsCard.walk_row(rig, legs, 100.0), 0, "standing")


func test_a_drawn_cycle_is_longer_than_the_kings_gait_cycle_at_55() -> void:
	# The probe of it10: the King's gait cycle is 64 world px at card scale 0.555 (55).
	assert_gt(KingLegsCard.CYCLE_CELL[55] * 0.555, 64.0 * 1.5, "stepping by the gait would skate")


func test_the_king_walks_under_his_robe_on_the_legs_grid() -> void:
	assert_eq(KingLegsCard.SHEETS["king"], "king_robe", "the owner's s-1 C: the long drawn robe")
	for pitch: int in [55, 70]:
		var robe: Texture2D = KingLegsCard.sheet(pitch, "king_robe")
		var legs: Texture2D = KingLegsCard.sheet(pitch, "king_legs")
		assert_not_null(robe, "art/p%d/king_robe.png" % pitch)
		if robe != null and legs != null:
			assert_eq(robe.get_size(), legs.get_size(), "cell for cell with the legs at %d" % pitch)
