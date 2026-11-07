extends GutTest
## d8 bosses: the court's card strips are picked by the view row's pitch; straight down none.


func test_top_draws_no_court_strip() -> void:
	assert_eq(KingArt.strip_path("king", 90.0), "")
	assert_eq(KingArt.strip_path("gang", 90.0), "")


func test_pitch_55_picks_the_p55_strips() -> void:
	assert_eq(
		KingArt.strip_path("king", 55.0), "res://features/bosses/king/art/p55/king_bust_card.png"
	)
	assert_eq(
		KingArt.strip_path("gang", 55.0), "res://features/bosses/king/art/p55/gang_head_card.png"
	)


func test_a_pitch_without_strips_keeps_the_shared_card() -> void:
	assert_eq(KingArt.strip_path("king", 65.0), "")
	assert_eq(KingArt.strip_path("rivet", 55.0), "")


func test_strips_hold_five_facings() -> void:
	for dir: String in KingArt.STRIPS:
		var tex: Texture2D = load(KingArt.strip_path(dir, 55.0)) as Texture2D
		assert_not_null(tex, dir)
		assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, dir)


func test_straight_down_dresses_no_court_part() -> void:
	assert_true(ViewMode.shared().is_flat(), "the unit run draws the default top view")
	assert_null(KingArt.part("press_plate"))


func test_court_parts_keep_todays_part_boxes() -> void:
	for name: String in ["press_plate", "l_thigh", "r_shin", "l_foot", "r_forearm_press"]:
		var court: Texture2D = load("res://features/bosses/king/art/p55/parts/%s.png" % name)
		var today: Texture2D = PartLibrary.texture("king", name)
		assert_eq(court.get_size(), today.get_size(), name)


func test_a_live_pitch_change_re_dresses_the_card() -> void:
	var was: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt")
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = "king"
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	var shared: Texture2D = load(RigHeadCard.CARDS["king"][0]) as Texture2D
	card.texture = shared
	ViewMode._shared.pitch_deg = 55.0
	KingArt.dress(rig)
	assert_eq(card.texture.resource_path, KingArt.strip_path("king", 55.0), "55: the court strip")
	# n8: the art key picks the folder (ViewMode.art_pitch); a row without a key falls back to
	# the live pitch, and 65 has no strip
	ViewMode._shared.art = ""
	ViewMode._shared.pitch_deg = 65.0
	KingArt.dress(rig)
	assert_eq(card.texture, shared, "a pitch without a strip: the shared card again")
	ViewMode._shared.art = "p55"
	KingArt.dress(rig)
	assert_eq(card.texture.resource_path, KingArt.strip_path("king", 55.0), "back at 55")
	ViewMode._shared = was
