extends GutTest
## n27 melee: the electro stun sparks read as current (a thin core in an amber halo), not as ink
## glyphs. `--ink-sparks` (ShockJolt.ink_rim) keeps the old 6 px ink rim round a 2.5 px cream core.

var _was: bool = false


func before_each() -> void:
	_was = ShockJolt.ink_rim


func after_each() -> void:
	ShockJolt.ink_rim = _was


func _opaque_ink(plan: Array[ElectricArc.Stroke]) -> int:
	var n: int = 0
	for s: ElectricArc.Stroke in plan:
		var c: Color = s.color
		if c.is_equal_approx(Ink.INK):
			n += 1
	return n


func test_default_spark_has_no_opaque_ink_rim() -> void:
	ShockJolt.ink_rim = false
	assert_eq(_opaque_ink(ShockJolt.spark_plan()), 0)
	for s: ElectricArc.Stroke in ShockJolt.spark_plan():
		var c: Color = s.color
		if c.r < 0.2 and c.g < 0.2:
			assert_lte(c.a, 0.35, "an ink stroke is only a faint under-halo")
			assert_lte(s.width, ElectricArc.HALO_PX, "no wider than the halo")


func test_default_core_is_the_thinnest_opaque_stroke() -> void:
	ShockJolt.ink_rim = false
	var plan: Array[ElectricArc.Stroke] = ShockJolt.spark_plan()
	var core: ElectricArc.Stroke = plan[plan.size() - 1]
	assert_eq(core.color, ElectricArc.CORE)
	assert_lte(core.width, 2.5)
	for s: ElectricArc.Stroke in plan:
		if s.color.a >= 1.0:
			assert_eq(s, core, "the core is the only alpha 1.0 stroke")
		assert_lte(core.width, s.width, "and the thinnest")


func test_default_halo_is_amber_and_wider_than_the_core() -> void:
	ShockJolt.ink_rim = false
	var amber: int = 0
	for s: ElectricArc.Stroke in ShockJolt.spark_plan():
		var c: Color = s.color
		if Color(c, 1.0).is_equal_approx(ElectricArc.HALO):
			amber += 1
			assert_lt(c.a, 1.0)
	assert_eq(amber, 2, "two amber halo passes, like ElectricArc")


func test_ink_sparks_flag_draws_the_old_two_strokes() -> void:
	ShockJolt.ink_rim = true
	var plan: Array[ElectricArc.Stroke] = ShockJolt.spark_plan()
	assert_eq(plan.size(), 2)
	assert_eq(plan[0].color, Ink.INK)
	assert_eq(plan[0].width, 6.0)
	assert_eq(plan[1].color, Ink.CREAM)
	assert_eq(plan[1].width, 2.5)
