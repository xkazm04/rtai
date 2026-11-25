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


func test_arc_serial_hashes_both_ends_at_quarter_metre_cells() -> void:
	assert_eq(CurrentLook._serial(Vector2.ZERO, Vector2(1.0, 0.5)), 54, "cells (0,0) and (4,2)")
	assert_eq(CurrentLook._serial(Vector2(1.25, -0.5), Vector2(2.5, 0.75)), 388, "negative cell")
	assert_eq(CurrentLook._serial(Vector2.ZERO, Vector2(-1.0, -1.0)), 917, "posmod keeps it >= 0")
	assert_eq(
		CurrentLook._serial(Vector2(0.1, 0.1), Vector2(0.2, 0.2)), 0, "the same cell is the same"
	)


func test_plan_polyline_is_the_arc_shape_at_double_phase_in_view_px() -> void:
	var a: Vector2 = Vector2(1.25, -0.5)
	var b: Vector2 = Vector2(2.5, 0.75)
	var shape: PackedVector2Array = ElectricArc.shape(
		PackedVector2Array([a, b]), CurrentLook._serial(a, b), 6, false
	)
	var px: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in shape:
		@warning_ignore("return_value_discarded")
		px.append(Ink.px(p))
	var plan: Array[CurrentLook.Pass] = CurrentLook.plan(a, b, 3)
	for l: CurrentLook.Pass in plan:
		assert_eq(l.points, px, "every pass draws the one jagged line: phase 3 jags as cell 6")


func test_plan_stroke_widths_follow_the_screen_scale() -> void:
	var near: Array[CurrentLook.Pass] = CurrentLook.plan(Vector2.ZERO, Vector2.RIGHT, 1, 1.0)
	var far: Array[CurrentLook.Pass] = CurrentLook.plan(Vector2.ZERO, Vector2.RIGHT, 1, 2.0)
	assert_eq(near.size(), far.size())
	for i: int in near.size():
		assert_almost_eq(far[i].width, near[i].width * 2.0, 0.001, "k doubles every width")
