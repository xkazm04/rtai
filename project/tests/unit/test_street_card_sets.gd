extends GutTest
## Lane n8 street: the street cast's per-pitch card rows (StreetCardSets).


func test_every_street_strip_loads_with_whole_frames() -> void:
	for art: String in StreetCardSets.SETS:
		var rows: Dictionary = StreetCardSets.rows_for(art)
		for key: String in rows:
			var row: Array = rows[key]
			assert_eq(row.size(), 5, "%s/%s row shape" % [art, key])
			var tex: Texture2D = load(str(row[0])) as Texture2D
			assert_not_null(tex, "%s/%s loads" % [art, key])
			if tex != null:
				assert_eq(
					tex.get_width() % RigHeadCard.FRAMES, 0, "%s/%s whole frames" % [art, key]
				)


func test_p70_street_rows_point_at_p70_art() -> void:
	var rows: Dictionary = StreetCardSets.rows_for("p70")
	assert_true(rows.has("cop/head_cap"), "the patrol cap has a p70 row")
	for key: String in rows:
		var row: Array = rows[key]
		assert_true(str(row[0]).contains("/p70/"), "%s is drawn for 70, not 55" % key)


func test_an_art_without_street_rows_is_empty() -> void:
	assert_eq(StreetCardSets.rows_for("").size(), 0)
	assert_eq(StreetCardSets.rows_for("nope").size(), 0)


func test_the_shield_plate_loads_per_pitch() -> void:
	for art: String in ["p55", "p70"]:
		var path: String = StreetCardSets.shield_for(art)
		assert_true(path.contains("/%s/" % art), "%s draws its own plate" % art)
		assert_not_null(load(path) as Texture2D, path)
	assert_eq(StreetCardSets.shield_for(""), "", "no art: the crescent part draws")


func test_straight_down_the_crescent_stays_and_no_plate_is_built() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.torso = autofree(Node2D.new())
	var crescent: Sprite2D = autofree(Sprite2D.new())
	crescent.visible = true
	rig.sides[BodyPlan.L].shield = crescent
	RiotShieldCard.step(rig)
	assert_true(crescent.visible, "the shipped view keeps the top-down shield")
	assert_null(rig.torso.get_node_or_null(^"shield_card"), "no plate straight down")


func test_a_rig_without_a_shield_is_left_alone() -> void:
	var rig: CutRig = autofree(CutRig.new())
	RiotShieldCard.step(rig)
	assert_null(rig.sides[BodyPlan.L].shield)


func test_straight_down_the_thug_keeps_its_dark_steel() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = ThugPlan.build()
	rig.body = autofree(Node2D.new())
	var part: Sprite2D = Sprite2D.new()
	part.material = ShaderMaterial.new()
	rig.add_child(part)
	StreetView.step(rig)
	assert_false(rig.body.has_meta(StreetView.LIT), "the shipped view lifts nothing")
	assert_eq(part.self_modulate, Color.WHITE)
