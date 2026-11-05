extends GutTest
## BossCam.clamp_focus: the boss cam's centre keeps the screen on the fight's floor.

const AREA: Rect2 = Rect2(60, -30, 80, 30)
## 1280 x 800 at 32 px/m.
const HALF: Vector2 = Vector2(20, 12.5)


func test_inside_is_unchanged() -> void:
	assert_eq(BossCam.clamp_focus(Vector2(100, -15), HALF, AREA), Vector2(100, -15))


func test_edges_pull_in() -> void:
	# planted: the west end, a focus past the north edge
	assert_eq(BossCam.clamp_focus(Vector2(62, -29), HALF, AREA), Vector2(80, -17.5))
	assert_eq(BossCam.clamp_focus(Vector2(150, 5), HALF, AREA), Vector2(120, -12.5))


func test_view_wider_than_area_centres() -> void:
	var tall: Vector2 = Vector2(20, 20)  # 40 m of screen over a 30 m area
	assert_eq(BossCam.clamp_focus(Vector2(90, -3), tall, AREA), Vector2(90, -15))


func test_empty_area_keeps_focus() -> void:
	assert_eq(BossCam.clamp_focus(Vector2(7, 7), HALF, Rect2()), Vector2(7, 7))


func test_keep_in_holds_the_boss_on_screen() -> void:
	# planted: the boss 1 m inside the bottom edge of a 20 x 12.5 half view centred at the origin
	var half: Vector2 = Vector2(20, 12.5)
	var shifted: Vector2 = BossCam.keep_in(Vector2.ZERO, half, Vector2(0, 11.5), 3.0, 2.0)
	assert_eq(shifted, Vector2(0, 2.0), "the view moves down until 3 m below the boss shows")
	assert_eq(BossCam.keep_in(Vector2.ZERO, half, Vector2(5, 0), 3.0, 2.0), Vector2.ZERO)
	# near the top, the bar's band counts: 3 m above the boss lies below the bar
	assert_eq(BossCam.keep_in(Vector2.ZERO, half, Vector2(0, -9), 3.0, 2.0), Vector2(0, -1.5))
