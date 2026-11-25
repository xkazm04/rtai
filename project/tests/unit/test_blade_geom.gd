extends GutTest
## n31 melee 01a: BladeGeom's overlap tests and the drawn/hit compare (dev/melee_n31).


func test_segment_touches_circle_beside_its_middle() -> void:
	assert_true(BladeGeom.seg_hits_circle(Vector2(0, 0), Vector2(2, 0), Vector2(1, 0.29), 0.3))
	assert_false(BladeGeom.seg_hits_circle(Vector2(0, 0), Vector2(2, 0), Vector2(1, 0.31), 0.3))


func test_segment_end_is_clamped_not_extended() -> void:
	assert_false(BladeGeom.seg_hits_circle(Vector2(0, 0), Vector2(1, 0), Vector2(1.5, 0), 0.3))
	assert_true(BladeGeom.seg_hits_circle(Vector2(0, 0), Vector2(1, 0), Vector2(1.25, 0), 0.3))


func test_degenerate_segment_is_a_point() -> void:
	assert_true(BladeGeom.seg_hits_circle(Vector2(1, 1), Vector2(1, 1), Vector2(1.2, 1), 0.3))


func test_polygon_covers_centre_or_edge() -> void:
	var sq: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	)
	assert_true(BladeGeom.poly_hits_circle(sq, Vector2(0.5, 0.5), 0.01), "inside")
	assert_true(BladeGeom.poly_hits_circle(sq, Vector2(1.2, 0.5), 0.3), "edge")
	assert_false(BladeGeom.poly_hits_circle(sq, Vector2(1.5, 0.5), 0.3), "clear")
	assert_false(BladeGeom.poly_hits_circle(PackedVector2Array(), Vector2.ZERO, 5.0), "empty")


func test_frame_hits_reads_blade_and_crescent() -> void:
	var blade: Dictionary = {"blade": PackedVector2Array([Vector2.ZERO, Vector2(1, 0)])}
	assert_true(BladeGeom.frame_hits(blade, Vector2(1, 0.2), 0.3))
	var tri: PackedVector2Array = PackedVector2Array([Vector2(2, 0), Vector2(3, 0), Vector2(2, 1)])
	assert_true(BladeGeom.frame_hits({"crescent": tri}, Vector2(2.2, 0.2), 0.05))
	assert_false(BladeGeom.frame_hits({}, Vector2.ZERO, 1.0))


func test_compare_counts_each_kind() -> void:
	var cells: Array[Dictionary] = [
		{"drawn": true, "hit": false},
		{"drawn": true, "hit": false},
		{"drawn": false, "hit": true},
		{"drawn": true, "hit": true},
		{"drawn": false, "hit": false},
	]
	var out: Dictionary = BladeGeom.compare(cells)
	var got: Array[int] = []
	for key: String in ["drawn_no_hit", "hit_not_drawn", "both", "neither"]:
		var n: int = out[key]
		got.append(n)
	assert_eq(got, [2, 1, 1, 1] as Array[int])
