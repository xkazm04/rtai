extends GutTest
## n7-melee: the Tonnage slam's debris (SlamDebris, drawn by HaulerMarks) reads its look from
## ghost_attacks.json tonnage and is seeded from the stomp tick only (view only, no RNG stream).


func test_the_shipped_debris_is_on() -> void:
	var g: GhostAttacks = GhostAttacks.shipped()
	assert_gt(g.num(&"tonnage", &"slam_debris"), 0.0)
	assert_gt(g.num(&"tonnage", &"slam_debris_s"), 0.0)
	assert_gt(g.num(&"tonnage", &"slam_flash_s"), 0.0)


func test_the_chips_are_seeded_from_the_stomp_tick() -> void:
	assert_eq(SlamDebris._hash(612, 3), SlamDebris._hash(612, 3), "same stomp, same chip")
	assert_ne(SlamDebris._hash(612, 3), SlamDebris._hash(613, 3), "another stomp, another throw")
	assert_ne(SlamDebris._hash(612, 3), SlamDebris._hash(612, 4), "chips differ")
	assert_gte(SlamDebris._hash(-5, 2), 0, "never negative (the angle maths)")
