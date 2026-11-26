extends GutTest
## n31 contact ink: a dark core where the soles press, a skirt that fades in small steps.


func _effective(upto: int) -> float:
	var clear: float = 1.0
	for i: int in range(0, upto + 1):
		clear *= 1.0 - RigCastShadows.CONTACT_RINGS[i].y
	return 1.0 - clear


func test_rings_shrink_inward_and_darken_inward() -> void:
	var rings: Array[Vector2] = RigCastShadows.CONTACT_RINGS
	assert_gte(rings[0].x, 1.0, "the outer ring is the contact radius or wider")
	for i: int in range(1, rings.size()):
		assert_lt(rings[i].x, rings[i - 1].x, "ring %d is smaller than the one outside" % i)
		assert_gt(rings[i].y, 0.0)


func test_the_skirt_edge_is_soft_and_the_core_is_dark() -> void:
	assert_lte(RigCastShadows.CONTACT_RINGS[0].y, 0.08, "the outer edge steps by at most 8 % alpha")
	assert_gte(
		_effective(RigCastShadows.CONTACT_RINGS.size() - 1), 0.6, "the core prints at 0.6 or more"
	)
	assert_lte(
		_effective(RigCastShadows.CONTACT_RINGS.size() - 1), 0.72, "and stays short of a black hole"
	)


func test_every_ring_step_is_small() -> void:
	var prev: float = 0.0
	for i: int in RigCastShadows.CONTACT_RINGS.size():
		var now: float = _effective(i)
		assert_lte(now - prev, 0.13, "ring %d adds at most 0.13 alpha" % i)
		prev = now


func test_the_ink_is_not_pure_black_nor_tinted() -> void:
	var c: Color = RigCastShadows.SHADOW
	assert_gt(c.b, c.r)
	assert_lt(c.b, 0.12, "near-black")
	assert_gt(c.r, 0.0, "not pure black")
