extends GutTest
## n7-melee: the Tonnage slam's debris (SlamDebris, drawn by HaulerMarks) reads its look from
## ghost_attacks.json tonnage and is seeded from the stomp tick only (view only, no RNG stream).


func test_the_shipped_debris_is_on() -> void:
	var g: GhostAttacks = GhostAttacks.shipped()
	assert_gt(g.num(&"tonnage", &"slam_debris"), 0.0)
	assert_gt(g.num(&"tonnage", &"slam_debris_s"), 0.0)
	assert_gt(g.num(&"tonnage", &"slam_flash_s"), 0.0)


func test_strike_lights_the_shipped_reach_at_both_native_zooms() -> void:
	var reach: float = HaulerStage.shipped().form.num(&"stomp_radius_m")
	assert_eq(reach, 4.0)
	assert_eq(HaulerMarks.STRIKE_TEAL, Color(0.42, 0.98, 0.89))
	for zoom: float in [1.0, 2.0]:
		var ring: Vector3 = HaulerMarks.strike_ring(reach, SimConst.PX_PER_M, zoom, 0.0)
		assert_eq(ring.x * zoom, reach * SimConst.PX_PER_M * zoom)
		assert_eq(ring.y * zoom, 4.0)
		assert_eq(ring.z, 1.0)
		var age: float = 2.0 * SimClock.TICK_DT
		assert_almost_eq(HaulerMarks.strike_ring(reach, 32.0, zoom, age).z, 0.648, 0.001)
		assert_eq(HaulerMarks.strike_ring(reach, 32.0, zoom, 5.0 * SimClock.TICK_DT).z, 0.0)


func test_the_chips_are_seeded_from_the_stomp_tick() -> void:
	assert_eq(SlamDebris._hash(612, 3), SlamDebris._hash(612, 3), "same stomp, same chip")
	assert_ne(SlamDebris._hash(612, 3), SlamDebris._hash(613, 3), "another stomp, another throw")
	assert_ne(SlamDebris._hash(612, 3), SlamDebris._hash(612, 4), "chips differ")
	assert_gte(SlamDebris._hash(-5, 2), 0, "never negative (the angle maths)")


func test_a_chip_is_drawn_around_its_own_origin() -> void:
	# At city coordinates (~16000 px) an absolute few-px quad fails triangulation; the quad stays
	# local and the draw transform carries it to the chip (SlamDebris.chip, RamMarks too).
	for s: float in [3.8, 5.0, 10.0]:
		var pts: PackedVector2Array = SlamDebris.chip_points(s)
		for p: Vector2 in pts:
			assert_lte(p.length(), s + 0.001, "the quad sits on the origin")
		assert_eq(Geometry2D.triangulate_polygon(pts).size(), 6, "two triangles, never empty")
