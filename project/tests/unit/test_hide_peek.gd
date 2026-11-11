extends GutTest
## n15 hero it14: quest 1's hide bin with Rivet tucked in draws the peek card under a tilt.

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved


func test_a_tilted_view_stands_the_peek_card_on_the_bins_foot() -> void:
	for view: String in ["tilt70", "combo", "tilt"]:
		ViewMode._shared = ViewMode.of(view)
		var r: Rect2 = HidePeek.rect(Vector2(10.0, 4.0))
		var card: Rect2 = PropCards.stand_rect(
			"dumpster",
			Rect2(
				Ink.px(Vector2(10.0, 4.0) - HidePeek.SIZE_M * 0.5), HidePeek.SIZE_M * Ink.PX_PER_M
			)
		)
		assert_gt(r.size.x, 0.0, "%s: the peek card stands" % view)
		assert_almost_eq(r.end.y, card.end.y, 0.01, "%s: on the standing bin's foot" % view)
		assert_almost_eq(r.size.x, card.size.x, 0.01, "%s: as wide as the standing bin" % view)


func test_the_flat_view_keeps_the_token() -> void:
	ViewMode._shared = ViewMode.of("top")
	assert_eq(HidePeek.rect(Vector2(10.0, 4.0)), Rect2(), "no card stands under the top view")
	assert_true(HidePeek.PEEK, "default on")
