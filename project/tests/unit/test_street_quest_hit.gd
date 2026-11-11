extends GutTest
## n15 combat item 2: quest 1's dock contractor thrown back by a blow (StreetQuestHit).

const PPM: float = 32.0

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved


func _guard(hurt: int) -> Fighter:
	var h: Fighter = Fighter.make(Fighter.Kind.GUARD, 3, Vector2(4.0, 5.0), 100.0)
	h.hurt_tick = hurt
	return h


func test_the_hit_grid_has_five_whole_facings() -> void:
	var tex: Texture2D = load(StreetQuestHit.PATH) as Texture2D
	assert_not_null(tex, StreetQuestHit.PATH)
	if tex != null:
		assert_eq(tex.get_width() % StreetQuestHit.FRAMES, 0, "five facings")
		assert_eq(tex.get_width() / StreetQuestHit.FRAMES, 344, "street_hit.py's cell")


func test_straight_down_no_hit_cell_draws() -> void:
	var canvas: Node2D = autofree(Node2D.new())
	ViewMode._shared = ViewMode.of("top")
	assert_false(StreetQuestHit.shows(), "the sprite path")
	assert_false(StreetQuestHit.opening(canvas, Vector2.ZERO, _guard(0), PPM, 0), "no cell")


func test_a_card_view_draws_the_stagger_inside_the_hold_only() -> void:
	var canvas: Node2D = autofree(Node2D.new())
	ViewMode._shared = ViewMode.of("tilt70")
	assert_true(StreetQuestHit.shows(), "the drawn cell under a card view")
	var past: int = 100 + StreetQuestHit.OPEN_TICKS
	assert_false(StreetQuestHit.opening(canvas, Vector2.ZERO, _guard(100), PPM, past), "lying")
	assert_lt(StreetQuestHit.OPEN_TICKS, StreetQuestDeadPlan.FALL_TICKS, "inside the fall")
	assert_lt(StreetQuestHit.OPEN_TICKS, StreetQuestHit.HOLD_TICKS, "a death opens shorter")


func test_the_cell_is_sized_by_the_standing_card() -> void:
	# 256 px = 347 / 0.96 sheet px and 192 px = 340: the two 70 sheets share one drawing scale
	assert_almost_eq(StreetQuestHit.CELL_K, (347.0 / 0.96) / 340.0, 0.002)
	ViewMode._shared = ViewMode.of("tilt70")
	assert_true(StreetQuestHit.shows(), "the grid loads")
	var size: Vector2 = StreetQuestHit.size_px(PPM)
	var card_h: float = StreetQuestCards.body_m() * PPM
	var tex: Texture2D = load(StreetQuestHit.PATH) as Texture2D
	var tall: float = tex.get_height() / StreetQuestHit.CELL_PX
	assert_almost_eq(
		size.y, card_h * StreetQuestHit.CELL_K * tall, 0.01, "the card's cell x CELL_K"
	)
	assert_almost_eq(size.x / size.y, 344.0 / tex.get_height(), 0.001, "the cell's own aspect")
	# v3's pad under the feet (street_hit.py PAD_BELOW) leaves the feet where a 256 cell put them
	var foot_px: float = size.y * StreetQuestHit.FOOT_Y * StreetQuestHit.CELL_PX / tex.get_height()
	assert_almost_eq(foot_px, card_h * StreetQuestHit.CELL_K * StreetQuestHit.FOOT_Y, 0.01, "feet")
