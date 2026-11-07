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


## d9-perf: the cached-rim build submits the very arrays the per-point build did (so the
## pixels cannot move): every point, colour and index equal, on fractional centres and radii.
func test_the_fast_build_is_bit_identical_to_the_per_point_build() -> void:
	var fan: CircleFan = CircleFan.new()
	for k: int in 40:
		var at: Vector2 = Vector2(123.37 + k * 7.31, -45.9 + k * 3.173)
		var c: Color = Color(0.64, 0.02 * (k % 3), 0.035, 0.5 + 0.01 * k)
		fan.add(at, 0.83 + k * 0.417, c)
	var old: Array = _per_point_build(fan)
	var pts: PackedVector2Array = old[0]
	var cols: PackedColorArray = old[1]
	var idx: PackedInt32Array = old[2]
	assert_eq(pts.size(), 40 * 66)
	assert_true(fan.points() == pts, "points bit-identical")
	assert_true(fan.colour_runs() == cols, "colours identical")
	assert_true(CircleFan.indices(fan.size()) == idx, "indices identical")
	assert_true(CircleFan.indices(3) == idx.slice(0, 3 * 64 * 3), "a smaller fan slices the cache")


## The pre-d9 print_on build, verbatim (the reference the fast build must equal).
static func _per_point_build(fan: CircleFan) -> Array:
	var seg: int = CircleFan.SEGMENTS
	var pts: PackedVector2Array = PackedVector2Array()
	var cols: PackedColorArray = PackedColorArray()
	var idx: PackedInt32Array = PackedInt32Array()
	var f: PackedFloat32Array = PackedFloat32Array([TAU / seg, 0.0, 0.0])
	var step: float = f[0]
	@warning_ignore_start("return_value_discarded")
	for c: int in fan.centres.size():
		var at: Vector2 = fan.centres[c]
		f[1] = fan.radii[c]
		var r: float = f[1]
		var base: int = pts.size()
		for i: int in seg + 1:
			pts.append(at + CircleFan._rim(f, i * step, r))
		pts.append(at)
		for i: int in seg + 2:
			cols.append(fan.colours[c])
		for i: int in seg:
			idx.append_array([base + seg + 1, base + i, base + i + 1])
	@warning_ignore_restore("return_value_discarded")
	return [pts, cols, idx]
