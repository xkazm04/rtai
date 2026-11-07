extends GutTest
## n8-hud: the HUD's top corners turn see-through over a clear point (HudSee, HudCorner).

const TICKS_TO_FADE: int = 12  # FADE_S at the 60 Hz tick


func test_a_point_under_the_panel_or_its_pad_is_covered() -> void:
	var r: Rect2 = Rect2(1500.0, 30.0, 380.0, 230.0)
	assert_true(HudSee.covers(r, PackedVector2Array([Vector2(1600.0, 100.0)])))
	assert_true(HudSee.covers(r, PackedVector2Array([Vector2(1480.0, 270.0)])), "within the pad")
	assert_false(HudSee.covers(r, PackedVector2Array([Vector2(960.0, 540.0)])), "screen centre")
	assert_false(HudSee.covers(r, PackedVector2Array()), "no points: opaque")
	assert_false(HudSee.covers(Rect2(), PackedVector2Array([Vector2.ZERO])), "nothing drawn")


func test_the_alpha_eases_down_in_fade_s_and_back() -> void:
	var a: float = 1.0
	for i: int in TICKS_TO_FADE - 1:
		a = HudSee.step(a, true, SimClock.TICK_DT)
	assert_gt(a, HudSee.SEE_A, "not there one tick early: an ease, not a cut")
	a = HudSee.step(a, true, SimClock.TICK_DT)
	assert_almost_eq(a, HudSee.SEE_A, 0.001)
	for i: int in TICKS_TO_FADE:
		a = HudSee.step(a, false, SimClock.TICK_DT)
	assert_almost_eq(a, 1.0, 0.001)


func test_only_the_covered_corner_turns_see_through() -> void:
	var view: HudView = HudView.new()
	view.state.head = "4/6  Dock 9"
	view.state.weapon = "Gloria"
	add_child_autofree(view)
	await wait_physics_frames(2)
	var right: HudCorner = view.get("_right")
	var left: HudCorner = view.get("_left")
	assert_gt(right.rect.size.x, 0.0, "the right corner reports the box it drew")
	assert_gt(left.rect.size.x, 0.0, "the left corner reports the box it drew")
	view.state.clear_px = PackedVector2Array([right.rect.get_center()])
	for i: int in TICKS_TO_FADE + 2:
		left.fade(view.state.clear_px, SimClock.TICK_DT)
		right.fade(view.state.clear_px, SimClock.TICK_DT)
	assert_almost_eq(right.alpha, HudSee.SEE_A, 0.001)
	assert_almost_eq(right.modulate.a, HudSee.SEE_A, 0.001)
	assert_eq(left.alpha, 1.0, "the beat panel stays opaque")


func test_no_clear_points_leave_the_hud_opaque() -> void:
	var c: HudCorner = HudCorner.new()
	c.rect = Rect2(0.0, 0.0, 100.0, 100.0)
	c.fade(PackedVector2Array(), SimClock.TICK_DT)
	assert_eq(c.modulate, Color.WHITE, "today's HUD: modulate untouched")
	c.free()


func test_the_feed_maps_rivet_to_the_centre_and_a_patrol_on_the_ground() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 1))
	stage.patrol_pos = [stage.arena.rivet.pos + Vector2(3.0, 2.0)]
	var screen: Vector2 = Vector2(1920.0, 1080.0)
	stage.heat.level = 0
	var cold: int = HudFeed.clear(stage, null, screen, 32.0, Vector2.ZERO).size()
	stage.heat.level = 1
	var pts: PackedVector2Array = HudFeed.clear(stage, null, screen, 32.0, Vector2.ZERO)
	assert_eq(pts.size(), cold + 1, "a patrol counts only while hot (drawn only then)")
	assert_eq(pts[0], screen * 0.5, "the camera centres Rivet")
	var k: float = ViewMode.shared().ground_k()
	assert_eq(pts[pts.size() - 1], screen * 0.5 + Vector2(96.0, 64.0 * k), "the tilt squashes y")
	var off: PackedVector2Array = HudFeed.clear(stage, null, screen, 32.0, Vector2(0.0, 1.0))
	assert_eq(off[0], screen * 0.5 - Vector2(0.0, 32.0 * k), "the forms lift moves Rivet up")
