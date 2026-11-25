extends GutTest
## Pins the electro live-current arithmetic: spawn_id, _serial, the fork count and add_path widths.

const A: Vector2 = Vector2(1.0, 2.0)
const B: Vector2 = Vector2(4.0, 2.5)

var _was: bool = false


func before_each() -> void:
	_was = WeaponFxElectro.cells
	WeaponFxElectro.cells = false


func after_each() -> void:
	WeaponFxElectro.cells = _was


func _widths(plan: Array[WeaponFxElectro.Line]) -> Array[float]:
	var out: Array[float] = []
	for l: WeaponFxElectro.Line in plan:
		out.append(l.width)
	return out


func _path_plan(k: float, outline: bool) -> Array[WeaponFxElectro.Line]:
	var plan: Array[WeaponFxElectro.Line] = []
	var pts: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(5.0, 0.0)])
	WeaponFxElectro.add_path(plan, pts, k, outline)
	return plan


func test_spawn_id_exact_value() -> void:
	# (1.3, 2.6) * 4 = (5.2, 10.4) -> cell (5, 10): 5*7 + 10*13 = 35 + 130 = 165
	assert_eq(WeaponFxBolt.spawn_id(Vector2(1.3, 2.6)), 165)


func test_spawn_id_is_one_value_per_quarter_metre_cell() -> void:
	# (1.4, 2.7) * 4 = (5.6, 10.8) -> the same cell (5, 10)
	assert_eq(WeaponFxBolt.spawn_id(Vector2(1.4, 2.7)), 165)
	# +0.25 m in x: cell (6, 10) = 42 + 130 = 172 (the x coefficient 7)
	assert_eq(WeaponFxBolt.spawn_id(Vector2(1.55, 2.6)), 172)
	# +0.25 m in y: cell (5, 11) = 35 + 143 = 178 (the y coefficient 13)
	assert_eq(WeaponFxBolt.spawn_id(Vector2(1.3, 2.85)), 178)


func test_spawn_id_negative_origin_goes_through_posmod() -> void:
	# (-0.1, -0.1) * 4 -> floor (-1, -1): -7 - 13 = -20 -> posmod 997 = 977
	assert_eq(WeaponFxBolt.spawn_id(Vector2(-0.1, -0.1)), 977)
	# (-1.3, -2.6) * 4 = (-5.2, -10.4) -> (-6, -11): -42 - 143 = -185 -> 812
	assert_eq(WeaponFxBolt.spawn_id(Vector2(-1.3, -2.6)), 812)


func test_serial_exact_values() -> void:
	# a (1, 2) -> (4, 8) * 31 = (124, 248); b (4, 2.5) -> (16, 10); q = (140, 258)
	# 140*7 + 258*13 = 980 + 3354 = 4334; 4334 - 4*997 = 346
	assert_eq(WeaponFxElectro._serial(Vector2(1.0, 2.0), Vector2(4.0, 2.5)), 346)
	# a (-1, -1)*... = (-4, -4) * 31 = (-124, -124); b = 0: -868 - 1612 = -2480 -> +3*997 = 511
	assert_eq(WeaponFxElectro._serial(Vector2(-0.9, -0.9), Vector2.ZERO), 511)


func test_serial_weights_the_first_end_by_31() -> void:
	# swapped: (16, 10) * 31 = (496, 310) + (4, 8) = (500, 318): 3500 + 4134 = 7634 -> 655
	assert_eq(WeaponFxElectro._serial(Vector2(4.0, 2.5), Vector2(1.0, 2.0)), 655)


func test_serial_is_one_value_per_cell_of_each_end() -> void:
	var s: int = WeaponFxElectro._serial(Vector2(1.0, 2.0), Vector2(4.0, 2.5))
	assert_eq(WeaponFxElectro._serial(Vector2(1.1, 2.1), Vector2(4.1, 2.6)), s)
	assert_ne(WeaponFxElectro._serial(Vector2(1.25, 2.0), Vector2(4.0, 2.5)), s)
	assert_ne(WeaponFxElectro._serial(Vector2(1.0, 2.0), Vector2(4.0, 2.75)), s)


func test_fork_count_stays_in_range_and_both_counts_occur() -> void:
	var seen: Dictionary = {}
	for serial: int in 40:
		var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.star_plan(
			Vector2.ZERO, 0.24, serial, 0
		)
		# five strokes per fork (two halos, ink, body, core)
		assert_eq(plan.size() % 5, 0)
		var n: int = plan.size() / 5
		assert_between(n, WeaponFxElectro.FORKS_MIN, WeaponFxElectro.FORKS_MAX)
		seen[n] = true
	assert_true(seen.has(3), "three forks occur")
	assert_true(seen.has(4), "four forks occur")


func test_stun_plan_serial_differs_per_spark() -> void:
	var a: Array[WeaponFxElectro.Line] = WeaponFxElectro.stun_plan(Vector2.ZERO, 0, 0)
	var b: Array[WeaponFxElectro.Line] = WeaponFxElectro.stun_plan(Vector2.ZERO, 0, 1)
	assert_ne(a[1].points, b[1].points, "serial 7 + i turns the two stars apart")
	var same: Array[WeaponFxElectro.Line] = WeaponFxElectro.stun_plan(Vector2.ZERO, 0, 0)
	assert_eq(a[1].points, same[1].points, "deterministic")


func test_add_path_widths_and_order_at_full_scale() -> void:
	var plan: Array[WeaponFxElectro.Line] = _path_plan(1.0, true)
	assert_eq(_widths(plan), [9.0, 4.5, 13.0, 10.0, 4.0] as Array[float])
	assert_eq(plan[2].color, Color(Ink.INK, 1.0))
	assert_eq(plan[3].color, ElectricArc.HALO)
	assert_eq(plan[4].color, ElectricArc.CORE)


func test_add_path_widths_scale_with_k() -> void:
	var plan: Array[WeaponFxElectro.Line] = _path_plan(0.5, true)
	assert_eq(_widths(plan), [4.5, 2.25, 6.5, 5.0, 2.0] as Array[float])


func test_add_path_thin_is_the_hop_and_daze_width() -> void:
	var plan: Array[WeaponFxElectro.Line] = []
	var pts: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(5.0, 0.0)])
	WeaponFxElectro.add_path(plan, pts, 1.0, false, true)
	assert_eq(_widths(plan), [9.0, 4.5, 4.0, 1.5] as Array[float])


func test_add_path_without_outline_drops_only_the_ink() -> void:
	var plan: Array[WeaponFxElectro.Line] = _path_plan(1.0, false)
	assert_eq(_widths(plan), [9.0, 4.5, 10.0, 4.0] as Array[float])
	assert_eq(plan[2].color, ElectricArc.HALO)


func _counts(serials: Array[int]) -> Array[int]:
	var out: Array[int] = []
	for s: int in serials:
		out.append(WeaponFxElectro.star_plan(Vector2.ZERO, 0.24, s, 0).size() / 5)
	return out


func test_fork_counts_per_serial_are_pinned() -> void:
	# n = 3 + int(hash01(serial, 0, 3) * 1.99), values observed from the hash (no hand sin)
	var serials: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7]
	assert_eq(_counts(serials), [3, 4, 4, 4, 3, 3, 4, 3] as Array[int])


func test_fork_tip_is_pinned_by_the_bend_hash() -> void:
	var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.star_plan(Vector2.ZERO, 0.24, 3, 0)
	var pts: PackedVector2Array = plan[4].points
	assert_eq(pts.size(), 3)
	assert_almost_eq(pts[1], Vector2(-1.488972, -5.564221), Vector2(0.001, 0.001))
	assert_almost_eq(pts[2], Vector2(-1.119848, -11.31238), Vector2(0.001, 0.001))


func test_stun_under_halo_width_scales_with_k() -> void:
	var stun: Array[WeaponFxElectro.Line] = WeaponFxElectro.stun_plan(Vector2.ZERO, 0, 0, 0.5)
	# the ink under-halo (9 px * k), then the thin add_path without outline: 4.5, 2.25, 2.0, 0.75
	assert_eq(_widths(stun).slice(0, 5), [4.5, 4.5, 2.25, 2.0, 0.75] as Array[float])


func _opaque_amber(plan: Array[WeaponFxElectro.Line]) -> Array[WeaponFxElectro.Line]:
	var out: Array[WeaponFxElectro.Line] = []
	for l: WeaponFxElectro.Line in plan:
		if l.color == ElectricArc.HALO and l.color.a == 1.0:
			out.append(l)
	return out


func _check_layers(
	plan: Array[WeaponFxElectro.Line], k: float, body_px: float, core_px: float
) -> void:
	var body: Array[WeaponFxElectro.Line] = _opaque_amber(plan)
	assert_gt(body.size(), 0, "an opaque amber body")
	for l: WeaponFxElectro.Line in body:
		assert_eq(l.width, body_px * k, "body is exactly the body px * k")
	assert_lt(core_px, body_px)
	var core_n: int = 0
	for l: WeaponFxElectro.Line in plan:
		if l.color == ElectricArc.CORE:
			core_n += 1
			assert_eq(l.width, core_px * k)
	assert_gt(core_n, 0)


func test_bolt_keeps_the_bold_width_and_hop_and_stun_use_the_thin_one() -> void:
	WeaponFxElectro.cells = false
	var bold: Array[float] = [WeaponFxElectro.BODY_PX, WeaponFxElectro.CORE_PX]
	var thin: Array[float] = [WeaponFxElectro.THIN_BODY_PX, WeaponFxElectro.THIN_CORE_PX]
	assert_eq(bold, [10.0, 4.0] as Array[float], "the bolt's pixels do not change")
	assert_eq(thin, [4.0, 1.5] as Array[float])
	_check_layers(WeaponFxBolt.plan(A, B, 11, 6), 1.0, bold[0], bold[1])
	_check_layers(WeaponFxElectro.chain_plan(A, B, 5), 1.0, thin[0], thin[1])
	_check_layers(WeaponFxElectro.chain_plan(A, B, 5, 0.5), 0.5, thin[0], thin[1])
	_check_layers(WeaponFxElectro.stun_plan(A, 30, 0), 1.0, thin[0], thin[1])


func test_the_hop_keeps_the_arcs_own_kink_without_jag_k() -> void:
	WeaponFxElectro.cells = false
	var hop: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 3)
	var serial: int = WeaponFxElectro._serial(A, B)
	var want: PackedVector2Array = WeaponFxElectro.to_px(
		ElectricArc.shape(PackedVector2Array([A, B]), serial, 6, false)
	)
	assert_eq(hop[0].points, want, "no JAG_K on the hop")
