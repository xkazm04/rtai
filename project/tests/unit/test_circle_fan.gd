extends GutTest
## perf-city: CircleFan records splat()'s circles in draw order and prints them in one triangle
## array (the pixel proof is evidence/perf/riot9/pixel-compare.txt; headless draws nothing).


func test_a_moving_splat_records_eleven_circles_in_order() -> void:
	var fan: CircleFan = CircleFan.new()
	BloodMarks.splat_into(fan, Vector2(100, 50), 3.0, Vector2(0.8, 0.0), Color.RED)
	assert_eq(fan.size(), 1 + 3 + 3 + BloodMarks.LOBES)
	assert_eq(fan.centres[0], Vector2(100, 50), "the core first, at the splat")
	assert_almost_eq(fan.radii[0], 2.1, 0.0001, "the core is 0.7 r")


func test_a_small_splat_is_its_core_only() -> void:
	var fan: CircleFan = CircleFan.new()
	BloodMarks.splat_into(fan, Vector2.ZERO, 1.0, Vector2.RIGHT, Color.RED)
	assert_eq(fan.size(), 1)


func test_the_fan_rim_is_the_engines_float32_circle() -> void:
	var f: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0])
	assert_eq(CircleFan._rim(f, 0.0, 2.5), Vector2(2.5, 0.0))
	var step: float = TAU / CircleFan.SEGMENTS
	var q: Vector2 = CircleFan._rim(f, 16 * step, 4.0)
	assert_almost_eq(q.x, 0.0, 0.00001)
	assert_almost_eq(q.y, 4.0, 0.00001)


func test_clear_empties_and_batched_is_the_default() -> void:
	var fan: CircleFan = CircleFan.new()
	fan.add(Vector2.ONE, 2.0, Color.RED)
	fan.clear()
	assert_eq(fan.size(), 0)
	assert_true(CircleFan.batched)
