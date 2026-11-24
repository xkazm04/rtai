extends GutTest

const THREE: PackedVector2Array = [Vector2(-1.0, 0.0), Vector2(-0.3, 0.2), Vector2(0.0, 0.0)]
const FOUR: PackedVector2Array = [
	Vector2.ZERO, Vector2(0.3, 0.3), Vector2(0.3, 0.5), Vector2(0.76, 0.64)
]


func test_the_shape_re_jags_every_three_ticks() -> void:
	var a: PackedVector2Array = ElectricArc.shape(THREE, 5, 6, false)
	assert_ne(a, ElectricArc.shape(THREE, 5, 9, false), "t and t+3 differ")
	assert_ne(a, ElectricArc.shape(THREE, 5, 3, false), "t and t-3 differ")
	assert_eq(a, ElectricArc.shape(THREE, 5, 7, false), "held inside a cell")
	assert_eq(a, ElectricArc.shape(THREE, 5, 8, false), "held inside a cell")


func test_the_same_tick_and_serial_draw_the_same_shape() -> void:
	assert_eq(ElectricArc.shape(FOUR, 12, 40, false), ElectricArc.shape(FOUR, 12, 40, false))
	assert_ne(ElectricArc.shape(FOUR, 12, 40, false), ElectricArc.shape(FOUR, 13, 40, false))


func test_reduced_motion_holds_one_shape() -> void:
	assert_eq(ElectricArc.shape(THREE, 5, 0, true), ElectricArc.shape(THREE, 5, 90, true))


func test_the_arc_has_four_to_seven_kinks_and_fixed_ends() -> void:
	for pts: PackedVector2Array in [THREE, FOUR]:
		var path: PackedVector2Array = ElectricArc.shape(pts, 3, 20, false)
		var kinks: int = path.size() - 2
		assert_between(kinks, 4, 7)
		assert_eq(path[0], pts[0])
		assert_eq(path[path.size() - 1], pts[pts.size() - 1])


func test_a_fork_branches_off_a_kink_and_is_short() -> void:
	var path: PackedVector2Array = ElectricArc.shape(THREE, 5, 6, false)
	var fork: PackedVector2Array = ElectricArc.forks(path, 5, 6, false, 0)
	assert_eq(fork.size(), 3)
	assert_true(path.has(fork[0]))
	assert_lt(fork[0].distance_to(fork[2]), ElectricArc.FORK_M)


func test_the_palette_is_amber_and_cream_never_red_or_teal() -> void:
	for c: Color in [ElectricArc.HALO, ElectricArc.CORE]:
		assert_gt(c.r, c.b, "warm")
		assert_gt(c.r, 0.85)
		assert_gt(c.g, 0.6)
