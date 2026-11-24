extends GutTest
## The riot, SWAT and lancer eight-drawing walks: wiring, scale and registration tables.


func test_riot_eight_is_the_cop_rig_walk_and_the_four_stays_one_value() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var four: String = StreetWalkerCards.DIR + "p70/" + CastRiotAnchors.FOUR
	var eight: String = StreetCopWalk.patrol_path(rig, four)
	assert_eq(eight.get_file(), CastRiotAnchors.WALK)
	assert_eq(StreetCopWalk.patrol_path(rig, eight), eight)
	assert_eq(CastRiotAnchors.WALK, CastRiotAnchors.EIGHT)
	assert_eq(StreetCopWalk.rows_of("p70/" + CastRiotAnchors.EIGHT), 8)
	assert_eq(StreetCopWalk.rows_of("p70/" + CastRiotAnchors.FOUR), 4)
	assert_true(CastCards.anchored("p55/" + CastRiotAnchors.EIGHT))
	assert_eq(CastCardKinds.four_of(CastRiotAnchors.EIGHT), CastRiotAnchors.FOUR)


func test_riot_eight_keeps_the_shipped_screen_size() -> void:
	for pitch: String in ["p70", "p55"]:
		var four: float = StreetCopWalk.fill_of(pitch + "/" + CastRiotAnchors.FOUR)
		var eight: float = StreetCopWalk.fill_of(pitch + "/" + CastRiotAnchors.EIGHT)
		assert_almost_eq(eight, four * StreetCopWalk.CELL_RATIO, 0.0001)


func test_riot_marks_cover_five_facings_of_eight_drawings() -> void:
	assert_eq(CastRiotAnchors.WALK70.size(), 40)
	assert_eq(CastRiotAnchors.WALK55.size(), 40)
	var pose: StreetPatrolPose = StreetPatrolPose.new()
	var step: float = pose.configure("p70/" + CastRiotAnchors.EIGHT, 8, false)
	assert_eq(step, CastRiotAnchors.WALK_STEP_M)
	assert_between(step, 0.15, 0.30)
	assert_eq(pose.marks.size(), 40)


func test_planted_contact_cycles_all_eight_drawings_at_the_step() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure("p70/" + CastRiotAnchors.EIGHT)
	assert_eq(contact.drawings, 8)
	assert_eq(contact.step_m, CastRiotAnchors.WALK_STEP_M)
	var seen: Dictionary[int, bool] = {}
	var at: Vector2 = Vector2.ZERO
	for tick: int in 200:
		at += Vector2.RIGHT * 2.8 * 32.0 * SimClock.TICK_DT
		@warning_ignore("return_value_discarded")
		contact.place(at, Vector2i(2, 0), Vector2(0.27, 0.25), 32.0)
		seen[posmod(contact.cell, 8)] = true
	assert_eq(seen.size(), 8)
