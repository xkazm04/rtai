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


func test_swat_swaps_to_the_eight_run_above_the_patrol_run_speed() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var four: String = StreetWalkerCards.DIR + "p70/" + CastSwatAnchors.FOUR
	assert_eq(StreetCopWalk.patrol_path(rig, four).get_file(), CastSwatAnchors.WALK)
	rig.speed_now = 6.0 * SimConst.PX_PER_M
	assert_eq(StreetCopWalk.patrol_path(rig, four).get_file(), CastSwatAnchors.RUN_EIGHT)
	assert_eq(StreetCopWalk.rows_of("p55/" + CastSwatAnchors.RUN_EIGHT), 8)
	assert_true(CastCardKinds.running(CastSwatAnchors.RUN_EIGHT, StreetCopWalk.RUN))
	assert_eq(CastSwatAnchors.RUN70.size(), 40)
	assert_eq(CastSwatAnchors.WALK55.size(), 40)


func test_lancer_card_walks_the_eight_and_keeps_the_four_selectable() -> void:
	var cards: CastCards = CastCards.shipped()
	for pitch: String in ["p70", "p55"]:
		var sheets: CastCards.Sheets = cards.lookup(&"rocket_trooper", pitch)
		assert_eq(sheets.walk.get_file(), CastLancerAnchors.WALK)
		assert_true(CastCards.anchored(sheets.walk))
	assert_eq(CastCardKinds.four_of(CastLancerAnchors.EIGHT), CastLancerAnchors.FOUR)
	assert_between(CastLancerAnchors.WALK_STEP_M, 0.15, 0.30)


## n31-10: walking sideways the upper body holds its line (the toe-off drawings used to drop the
## whole cop 5-8 px at 32 px/m, the cap dip seen in play). The torso mark stands for the head:
## its cell height is fixed and the drawn head top sits within 2 cell px of steady on these sheets.
func test_side_walk_torso_holds_its_line_within_four_screen_pixels() -> void:
	for strip: String in [StreetCopWalk.EIGHT, CastRiotAnchors.EIGHT, CastSwatAnchors.EIGHT]:
		var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
		contact.configure("p70".path_join(strip))
		contact.travel = Vector2.LEFT
		var face: Vector2i = RigHeadCard.frame_of(PI)
		var texel: Vector2 = Vector2(0.3173, 0.3173)
		var stance: float = contact.step_m * 32.0 * (contact.drawings >> 1)
		var low: float = INF
		var high: float = -INF
		var at: Vector2 = Vector2.ZERO
		while -at.x < stance * 6.0:
			var xf: Transform2D = contact.place(at, face, texel, 32.0)
			var ink: Vector4 = contact.registered.marks[face.x * 8 + posmod(contact.cell, 8)]
			if -at.x > stance * 2.0:
				low = minf(low, (xf * Vector2(ink.z, ink.w)).y)
				high = maxf(high, (xf * Vector2(ink.z, ink.w)).y)
			at += Vector2.LEFT * 3.2 * 32.0 * SimClock.TICK_DT
		assert_lte(high - low, 4.0, "%s torso travel %.2f px" % [strip, high - low])
