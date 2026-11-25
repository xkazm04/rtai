extends GutTest
## Quest 1's tazer, burst arcs and TUCK-IN bolt are amber current, not vermilion (red audit 17-19).


func test_flat_glyphs_are_amber_not_vermilion() -> void:
	assert_eq(CurrentLook.STRIPE, Ink.AMBER)
	assert_eq(CurrentLook.BOLT, Ink.AMBER)
	assert_ne(CurrentLook.STRIPE, Ink.VERMILION)
	assert_ne(CurrentLook.BOLT, Ink.VERMILION)


func test_current_plan_is_the_live_halo_and_core() -> void:
	var plan: Array[CurrentLook.Pass] = CurrentLook.plan(Vector2.ZERO, Vector2(1.0, 0.5), 4)
	assert_eq(plan.size(), ElectricArc.strokes(1.0).size() + 1)  # + the opaque amber body
	var seen_core: bool = false
	for l: CurrentLook.Pass in plan:
		assert_ne(l.color, Ink.VERMILION)
		assert_gt(l.points.size(), 2)
		seen_core = seen_core or l.color == ElectricArc.CORE
	assert_true(seen_core)


func test_current_rejags_between_jag_cells() -> void:
	var a: Vector2 = Vector2.ZERO
	var b: Vector2 = Vector2(2.0, 0.0)
	var p0: PackedVector2Array = CurrentLook.plan(a, b, 6)[0].points
	assert_eq(CurrentLook.plan(a, b, 6)[0].points, p0)
	assert_ne(CurrentLook.plan(a, b, 8)[0].points, p0)


func test_plan_has_an_opaque_amber_body_wider_than_the_core() -> void:
	var body: float = 0.0
	var core: float = 0.0
	for l: CurrentLook.Pass in CurrentLook.plan(Vector2.ZERO, Vector2(1.0, 0.5), 4):
		if l.color == Ink.AMBER:
			body = maxf(body, l.width)
		if l.color == ElectricArc.CORE:
			core = l.width
	assert_gt(body, core)
	assert_eq(body, ElectricArc.MID_PX)
