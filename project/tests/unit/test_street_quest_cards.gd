extends GutTest
## Lane n8 street: quest 1's dock contractors as a standing card (StreetQuestCards).


func test_the_contractor_strip_loads_per_pitch_with_whole_frames() -> void:
	for art: String in ["p55", "p70"]:
		for strips: Dictionary[String, String] in [StreetQuestCards.GUARD, StreetQuestCards.PATROL]:
			var path: String = strips.get(art, "")
			assert_true(path.contains("/%s/" % art), "%s draws its own card" % art)
			var tex: Texture2D = load(path) as Texture2D
			assert_not_null(tex, path)
			if tex != null:
				assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole frames" % art)


func test_straight_down_the_sprite_draws() -> void:
	var canvas: Node2D = autofree(Node2D.new())
	assert_false(
		StreetQuestCards.draw_guard(canvas, Vector2.ZERO, Vector2.RIGHT, 32.0),
		"the shipped view keeps the dock_guard sprite"
	)
	assert_false(
		StreetQuestCards.draw_down(canvas, Vector2.ZERO, Vector2.RIGHT, 32.0),
		"the shipped view keeps the guard_down sprite"
	)
	assert_false(
		StreetQuestCards.draw_patrol(canvas, Vector2.ZERO, Vector2.DOWN, 32.0),
		"the shipped view keeps the cop sprite"
	)


func test_the_downed_contractor_grid_has_whole_cells() -> void:
	for art: String in ["p55", "p70"]:
		var path: String = StreetQuestCards.DOWN.get(art, "")
		assert_true(path.contains("/%s/" % art), "%s lies as its own drawing" % art)
		var tex: Texture2D = load(path) as Texture2D
		assert_not_null(tex, path)
		if tex != null:
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "five facings")
			assert_eq(tex.get_height() % StreetWalkerFall.FALL_FRAMES, 0, "three fall frames")


func test_corpses_on_different_spots_fall_three_ways() -> void:
	var seen: Dictionary[float, bool] = {}
	for i: int in 12:
		seen[StreetQuestCards.spread_of(Vector2(i * 7.0, i * 3.0))] = true
	assert_eq(seen.size(), 3, "-45, 0 and +45 deg off the facing")
	var at: Vector2 = Vector2(40.0, 90.0)
	assert_eq(StreetQuestCards.spread_of(at), StreetQuestCards.spread_of(at), "fixed per spot")


func test_the_corpse_is_one_body_length_at_every_pitch() -> void:
	# the 70 card: 1.15 m wide x 192 / (705 / 5) -> about 1.57 m, not the longer 55 drawing's 1.73
	assert_almost_eq(StreetQuestCards.body_m(), 1.566, 0.01, "sized by the p70 standing card")


func test_a_walking_patrol_cop_faces_its_step_and_holds_it_standing() -> void:
	var at: Vector2 = Vector2(5000.0, 5000.0)
	var first: Vector2 = StreetQuestCards.walk_facing(at, Vector2.DOWN, 32.0)
	assert_eq(first, Vector2.DOWN, "a new cop takes the given facing")
	await get_tree().process_frame
	var walked: Vector2 = StreetQuestCards.walk_facing(at + Vector2(-2.0, 0.0), Vector2.DOWN, 32.0)
	assert_almost_eq(walked.x, -1.0, 0.001, "walking left faces left")
	await get_tree().process_frame
	var still: Vector2 = StreetQuestCards.walk_facing(at + Vector2(-2.0, 0.0), Vector2.DOWN, 32.0)
	assert_almost_eq(still.x, -1.0, 0.001, "standing keeps the last facing")
