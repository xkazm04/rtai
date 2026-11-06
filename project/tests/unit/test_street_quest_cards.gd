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
