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
	var shifted: Vector2 = BossCam.keep_in(
		Vector2.ZERO, half, Vector2(0, 11.5), 3.0, Vector2(2.0, 0.0)
	)
	assert_eq(shifted, Vector2(0, 2.0), "the view moves down until 3 m below the boss shows")
	assert_eq(
		BossCam.keep_in(Vector2.ZERO, half, Vector2(5, 0), 3.0, Vector2(2.0, 0.0)), Vector2.ZERO
	)
	# near the top, the bar's band counts: 3 m above the boss lies below the bar
	assert_eq(
		BossCam.keep_in(Vector2.ZERO, half, Vector2(0, -9), 3.0, Vector2(2.0, 0.0)),
		Vector2(0, -1.5)
	)
	# the ghost card's band at the bottom counts too: 3 m below the boss lies above the card
	var card: Vector2 = Vector2(0.0, 6.0)
	assert_eq(BossCam.keep_in(Vector2.ZERO, half, Vector2(0, 5), 3.0, card), Vector2(0, 1.5))


func test_hold_top_keeps_the_lifted_boss_under_the_bar() -> void:
	var saved: ViewMode = ViewMode._shared
	var half: Vector2 = Vector2(10, 6.25)
	var bands: Vector2 = Vector2(0.8, 2.8)
	ViewMode._shared = ViewMode.of("top")
	assert_eq(BossCam.hold_top(Vector2(0, 0), half, Vector2(0, 0), bands), 0.0, "flat: unchanged")
	ViewMode._shared = ViewMode.of("tilt")
	var lift_m: float = -ViewMode._shared.lift_px(BossCam.BOSS_TOP_M).y / SimConst.PX_PER_M
	assert_gt(lift_m, 0.5, "a tilt lifts the boss's top up the screen")
	# planted: the boss's ground point 3 m below the screen top (fits flat, bust under the bar)
	var y: float = BossCam.hold_top(Vector2(0, 0), half, Vector2(0, -3.25), bands)
	var top_y: float = -3.25 - lift_m
	assert_true(top_y - BossCam.TOP_MARGIN_M >= y - half.y + bands.x - 0.001, "the top clears")
	assert_lt(y, 0.0, "the view rose to keep the lifted top in")
	ViewMode._shared = saved


func test_aim_leans_near_and_follows_rivet_far() -> void:
	var r: Vector2 = Vector2(0, 0)
	var near: Vector2 = Vector2(10, 0)
	assert_eq(BossCam.aim(r, near), r.lerp(near, BossCam.FRAME_K), "near: the full lean")
	var far: Vector2 = Vector2(BossCam.FAR_M + 1.0, 0)
	assert_eq(BossCam.aim(r, far), r, "far: Rivet alone")


func test_aim_has_no_step_across_the_band() -> void:
	# planted: the boss closing 0.25 m a tick (the King's procession) from 30 m to 10 m; the
	# focus moves at most 0.4 m a tick (16 px at 40 px/m), never the old 1.9 m snap at 20 m
	var r: Vector2 = Vector2(0, 0)
	var last: Vector2 = BossCam.aim(r, Vector2(30, 0))
	var worst: float = 0.0
	for i: int in range(1, 81):
		var now: Vector2 = BossCam.aim(r, Vector2(30.0 - 0.25 * i, 0))
		worst = maxf(worst, now.distance_to(last))
		last = now
	assert_lt(worst, 0.4, "the largest focus move a tick")
