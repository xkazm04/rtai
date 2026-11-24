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


func test_default_chain_has_no_opaque_ink() -> void:
	WeaponFxElectro.cells = false
	var plan: Array[WeaponFxElectro.Line] = WeaponFxElectro.chain_plan(A, B, 5)
	assert_gt(plan.size(), 0, "live current is planned")
	assert_eq(_ink_opaque(plan), 0, "no ink outline on the new path")


func test_core_is_the_narrowest_opaque_stroke_at_most_2_5_px() -> void:
	WeaponFxElectro.cells = false
	var core: float = 99.0
	for l: WeaponFxElectro.Line in WeaponFxElectro.chain_plan(A, B, 5):
		if l.color.a >= 1.0:
			core = minf(core, l.width)
			assert_eq(l.color, ElectricArc.CORE, "the only opaque pass is the cream core")
	assert_lte(core, 2.5, "thin core")
	assert_gt(core, 0.0)
	for l: WeaponFxElectro.Line in WeaponFxElectro.chain_plan(A, B, 5):
		assert_gte(l.width, core - 0.0001, "nothing is narrower than the core")


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
