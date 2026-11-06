extends GutTest
## View lab (features/characters/rig_head_card.gd): the upright facing cards. Only a tilted row
## with `cards` draws them; the default and the plain tilt rows never do.


func test_cards_only_on_card_rows() -> void:
	assert_false(ViewMode.of("").cards, "the shipped view draws no cards")
	assert_false(ViewMode.of("top_lift").cards)
	assert_false(ViewMode.of("tilt55").cards, "the plain tilt keeps the top-down head")
	assert_true(ViewMode.of("tilt55_cards").cards)


func test_face_toward_the_camera_draws_the_front() -> void:
	assert_eq(RigHeadCard.frame_of(PI * 0.5), Vector2i(0, 0), "facing screen down = the face")
	assert_eq(RigHeadCard.frame_of(-PI * 0.5), Vector2i(4, 0), "facing screen up = the back")


func test_left_facings_mirror_the_right() -> void:
	assert_eq(RigHeadCard.frame_of(0.0), Vector2i(2, 0))
	assert_eq(RigHeadCard.frame_of(PI), Vector2i(2, 1))
	assert_eq(RigHeadCard.frame_of(PI * 0.75), Vector2i(1, 1))
	assert_eq(RigHeadCard.frame_of(-PI * 0.75), Vector2i(3, 1))


func test_every_card_strip_loads() -> void:
	for dir: String in RigHeadCard.CARDS:
		var row: Array = RigHeadCard.CARDS[dir]
		var path: String = row[0]
		var t: Texture2D = load(path) as Texture2D
		assert_not_null(t, path)
		assert_eq(t.get_width() % RigHeadCard.FRAMES, 0, "%s splits into equal frames" % path)


func test_a_raw_card_flashes_on_a_hit_then_draws_raw() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = BodyPlan.new()
	rig.plan.art_dir = "gang"
	rig.head_card = autofree(Sprite2D.new())
	RigHeadCard.on_tint(rig, true)
	assert_not_null(rig.head_card.material, "the hit flash reaches the card")
	RigHeadCard.on_tint(rig, false)
	assert_null(rig.head_card.material, "a pre-printed card draws raw again")


func test_no_card_no_flash_work() -> void:
	var rig: CutRig = autofree(CutRig.new())
	RigHeadCard.on_tint(rig, true)
	assert_null(rig.head_card)


func test_a_head_variant_row_wins_over_the_set_row() -> void:
	var cop: BodyPlan = BodyPlan.new()
	cop.art_dir = "cop"
	assert_eq(RigHeadCard.key_of(cop, "head_cap"), "cop/head_cap", "the patrol cop: the cap card")
	assert_eq(
		RigHeadCard.key_of(cop, "head_helmet"), "cop/head_helmet", "the riot cop: its own card"
	)
	assert_eq(RigHeadCard.key_of(cop, "head_swat"), "", "SWAT keeps its own head (no card yet)")
	var thug: BodyPlan = BodyPlan.new()
	thug.art_dir = "gang"
	assert_eq(RigHeadCard.key_of(thug, "head"), "gang", "every gang head shares one card")


func test_an_art_folder_overrides_only_its_own_rows() -> void:
	assert_eq(RigHeadCard.rows_of(""), RigHeadCard.CARDS, "no set: the base cards")
	var none_king: String = RigHeadCard.rows_of("none_such")["king"][0]
	assert_eq(none_king, str(RigHeadCard.CARDS["king"][0]), "no such folder: the base strip")
	var r55: Dictionary[String, Array] = RigHeadCard.rows_of("p55")
	assert_eq(str(r55["rivet"][0]), "res://features/characters/art/view/p55/rivet_bust_card.png")
	var bust: bool = r55["rivet"][3]
	assert_true(bust, "Rivet's 55 card is a bust: the torso hides")
	var king: Array = r55["king"]
	var king_base: Array = RigHeadCard.CARDS["king"]
	assert_eq(king, king_base, "rows the set does not name stay the base")
	assert_eq(
		str(RigHeadCard.CARDS["rivet"][0]),
		"res://features/characters/art/view/rivet_head_card.png",
		"the base table is untouched by the merge"
	)


func test_every_set_card_strip_loads() -> void:
	for art: String in RigHeadCard.SET_CARDS:
		for key: String in RigHeadCard.SET_CARDS[art]:
			var path: String = RigHeadCard.SET_CARDS[art][key][0]
			if path == "":
				continue
			var t: Texture2D = load(path) as Texture2D
			assert_not_null(t, path)
			assert_eq(t.get_width() % RigHeadCard.FRAMES, 0, "%s splits into equal frames" % path)


func test_the_tilt_row_draws_the_55_set_and_top_none() -> void:
	assert_eq(ViewMode.of("tilt").art, "p55")
	assert_eq(ViewMode.of("top").art, "", "top draws no cards at all")
	assert_eq(ViewMode.of("tilt_basecards").art, "", "the d8 before: the base cards")


func test_a_set_row_without_a_path_keeps_the_strip_and_takes_its_width() -> void:
	var r70: Dictionary[String, Array] = RigHeadCard.rows_of("p70")
	var base: Array = RigHeadCard.CARDS["king"]
	assert_ne(str(r70["king"][0]), "", "the empty path is filled from the folder or the base")
	assert_eq(str(r70["king"][0]).get_file(), str(base[0]).get_file())
	var king_w: float = r70["king"][2]
	var rivet_w: float = r70["rivet"][2]
	assert_almost_eq(king_w, 3.53, 0.001, "the p70 row's width")
	assert_almost_eq(rivet_w, 1.17, 0.001)
	assert_eq(str(RigHeadCard.SET_CARDS["p70"]["king"][0]), "", "the set table is untouched")


func test_a_dropped_card_gives_up_its_name_for_the_rebuild() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.head = Node2D.new()
	rig.torso = Node2D.new()
	rig.head_spr = Sprite2D.new()
	rig.torso_spr = Sprite2D.new()
	rig.add_child(rig.head)
	rig.add_child(rig.torso)
	rig.head.add_child(rig.head_spr)
	rig.torso.add_child(rig.torso_spr)
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	rig.head.add_child(card)
	rig.head_card = card
	RigHeadCard.drop(rig)
	assert_null(rig.head_card)
	assert_eq(String(card.name), "head_card_dropped", "a card rebuilt this frame keeps head_card")
	assert_true(rig.head_spr.visible, "the top-down head draws again")
