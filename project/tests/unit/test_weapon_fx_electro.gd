extends GutTest

const A: Vector2 = Vector2(1.0, 2.0)
const B: Vector2 = Vector2(4.0, 2.5)

var _was: bool = false


class Drawer:
	extends Node2D
	var drew: bool = false

	func _draw() -> void:
		drew = WeaponFxElectro.chain(self, Vector2.ZERO, Vector2(3.0, 0.0), 4)


func before_each() -> void:
	_was = WeaponFxElectro.cells


func after_each() -> void:
	WeaponFxElectro.cells = _was


func _ink_opaque(plan: Array[WeaponFxElectro.Line]) -> int:
	var n: int = 0
	for l: WeaponFxElectro.Line in plan:
		if l.color.r == Ink.INK.r and l.color.g == Ink.INK.g and l.color.a > 0.35:
			n += 1
	return n


func test_chain_ink_outline_is_wider_than_the_body_and_stun_has_none() -> void:
	WeaponFxElectro.cells = false
	var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 5)
	assert_gt(plan.size(), 0, "live current is planned")
	assert_gt(_ink_opaque(plan), 0, "an ink outline under the body")
	for l: WeaponFxElectro.Line in plan:
		if l.color.a == 1.0 and l.color.r == Ink.INK.r:
			assert_eq(l.width, WeaponFxElectro.BODY_PX + WeaponFxElectro.INK_EXTRA_PX)
	assert_eq(_ink_opaque(WeaponFxElectro.stun_plan(A, 30, 0)), 0, "no solid rim on the daze")


func _opaque_amber(plan: Array[WeaponFxElectro.Line]) -> Array[WeaponFxElectro.Line]:
	var out: Array[WeaponFxElectro.Line] = []
	for l: WeaponFxElectro.Line in plan:
		if l.color == ElectricArc.HALO and l.color.a == 1.0:
			out.append(l)
	return out


func _check_layers(plan: Array[WeaponFxElectro.Line], k: float) -> void:
	var body: Array[WeaponFxElectro.Line] = _opaque_amber(plan)
	assert_gt(body.size(), 0, "an opaque amber body")
	for l: WeaponFxElectro.Line in body:
		assert_eq(l.width, WeaponFxElectro.BODY_PX * k, "body is exactly BODY_PX * k")
	assert_lt(WeaponFxElectro.CORE_PX, WeaponFxElectro.BODY_PX)
	assert_lt(WeaponFxElectro.CORE_PX, WeaponFxElectro.BODY_PX)
	var core_n: int = 0
	for l: WeaponFxElectro.Line in plan:
		if l.color == ElectricArc.CORE:
			core_n += 1
			assert_eq(l.width, WeaponFxElectro.CORE_PX * k)
	assert_gt(core_n, 0)


func test_chain_and_bolt_share_the_opaque_amber_body() -> void:
	WeaponFxElectro.cells = false
	_check_layers(WeaponFxElectro.chain_plan(A, B, 5), 1.0)
	_check_layers(WeaponFxElectro.chain_plan(A, B, 5, 0.5), 0.5)
	_check_layers(WeaponFxBolt.plan(A, B, 11, 6), 1.0)
	_check_layers(WeaponFxElectro.stun_plan(A, 30, 0), 1.0)


func test_the_star_at_b_has_three_or_four_forks() -> void:
	for serial: int in 12:
		var forks: Array[WeaponFxElectro.Line] = WeaponFxElectro.star_plan(
			B, 0.24, serial, serial * 3
		)
		var cores: int = 0
		for l: WeaponFxElectro.Line in forks:
			if l.color == ElectricArc.CORE:
				cores += 1
		assert_between(cores, 3, 4, "3 to 4 forks")


func test_same_inputs_same_plan() -> void:
	var p1: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 9)
	var p2: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 9)
	assert_eq(p1.size(), p2.size())
	for i: int in p1.size():
		assert_eq(p1[i].points, p2[i].points)
		assert_eq(p1[i].width, p2[i].width)
	var p3: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 12)
	assert_ne(p1[0].points, p3[0].points, "re-jags on another 3-tick cell")


func test_stun_star_is_amber_with_only_a_faint_under_halo() -> void:
	var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.stun_plan(A, 30, 0)
	var under: int = 0
	for l: WeaponFxElectro.Line in plan:
		if l.color.r == Ink.INK.r and l.color.g == Ink.INK.g:
			under += 1
			assert_lte(l.color.a, 0.35, "faint")
			assert_lte(l.width, ElectricArc.HALO_PX, "no wider than the halo")
	assert_gt(under, 0)
	assert_eq(_ink_opaque(plan), 0)


func test_cells_flag_is_the_old_cell_path() -> void:
	WeaponFxElectro.cells = true
	assert_eq(
		WeaponFxElectro.chain_plan(A, B, 5).size(), 0, "no live strokes under --electro-cells"
	)
	var d: Drawer = add_child_autofree(Drawer.new())
	d.queue_redraw()
	await wait_frames(2)
	assert_true(d.drew, "the cell path still draws")


func test_the_jag_cell_follows_phase_times_two_over_three_ticks() -> void:
	WeaponFxElectro.cells = false
	var p3: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 3)
	var p4: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 4)
	assert_eq(p3[0].points, p4[0].points, "phases 3 and 4 share the cell (ticks 6 and 8)")
	var p2: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 2)
	assert_ne(p2[0].points, p3[0].points, "phase 2 is the cell before")


func test_forks_are_two_half_reach_pieces() -> void:
	var reach: float = 0.3
	var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.star_plan(B, reach, 5, 9)
	var half: float = reach * 0.5 * Ink.PX_PER_M
	var checked: int = 0
	for l: WeaponFxElectro.Line in plan:
		if l.color == ElectricArc.CORE:
			assert_almost_eq(l.points[0], Ink.px(B), Vector2.ONE * 0.01, "rooted at the landing")
			assert_almost_eq(l.points[1].distance_to(l.points[0]), half, 0.01, "first piece")
			assert_almost_eq(l.points[2].distance_to(l.points[1]), half, 0.01, "second piece")
			checked += 1
	assert_gt(checked, 0)


func test_widths_follow_the_screen_scale() -> void:
	var loose: Node2D = autofree(Node2D.new())
	assert_eq(WeaponFxElectro.screen_k(loose), 1.0, "off the tree: screen px")
	var live: Node2D = add_child_autofree(Node2D.new())
	live.scale = Vector2.ONE * 2.0
	assert_almost_eq(WeaponFxElectro.screen_k(live), 0.5, 0.001, "a 2x canvas halves the width")


func test_a_zero_length_hop_draws_nothing() -> void:
	var node: Node2D = autofree(Node2D.new())
	assert_false(WeaponFxElectro.chain(node, A, A, 1))


func test_bolt_star_has_three_or_four_forks() -> void:
	var forks: int = 0
	for l: WeaponFxElectro.Line in WeaponFxBolt.plan(A, B, 11, 6):
		if l.color == ElectricArc.CORE and l.points.size() == 3:
			forks += 1
	assert_between(forks, 3, 4)


func test_bolt_plan_is_pure_and_holds_inside_a_jag_cell() -> void:
	var a: Array[WeaponFxElectro.Line] = WeaponFxBolt.plan(A, B, 11, 6)
	var b: Array[WeaponFxElectro.Line] = WeaponFxBolt.plan(A, B, 11, 6)
	var c: Array[WeaponFxElectro.Line] = WeaponFxBolt.plan(A, B, 11, 7)
	var d: Array[WeaponFxElectro.Line] = WeaponFxBolt.plan(A, B, 11, 9)
	assert_eq(a.size(), b.size())
	for i: int in a.size():
		assert_eq(a[i].points, b[i].points, "same inputs, same plan")
		assert_eq(a[i].points, c[i].points, "ticks 6 and 7 share a 3-tick cell")
	assert_false(a[0].points == d[0].points, "tick 9 re-jags")


func test_bolt_serial_is_stable_per_spawn() -> void:
	assert_eq(WeaponFxBolt.spawn_id(A), WeaponFxBolt.spawn_id(A))
