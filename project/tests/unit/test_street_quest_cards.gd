extends GutTest
## Lane n8 street: quest 1's dock contractors as a standing card (StreetQuestCards).


func test_the_contractor_strip_loads_per_pitch_with_whole_frames() -> void:
	for art: String in ["p55", "p70"]:
		var path: String = StreetQuestCards.GUARD.get(art, "")
		assert_true(path.contains("/%s/" % art), "%s draws its own contractor" % art)
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


func test_the_downed_contractor_grid_has_whole_cells() -> void:
	var tex: Texture2D = load(StreetQuestCards.DOWN["p70"]) as Texture2D
	assert_not_null(tex)
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
