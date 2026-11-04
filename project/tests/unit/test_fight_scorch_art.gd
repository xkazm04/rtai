extends GutTest
## FightScorchArt: the char under a fire patch is a stable, ragged, non-crossing blotch.


func test_same_centre_draws_the_same_outline() -> void:
	var a: PackedVector2Array = FightScorchArt._ring(Vector2.ZERO, 60.0, 18, 1234, true)
	var b: PackedVector2Array = FightScorchArt._ring(Vector2.ZERO, 60.0, 18, 1234, true)
	assert_eq(a, b)


func test_two_patches_do_not_match() -> void:
	var ka: int = FightScorchArt._seed(Vector2(3.0, 4.0))
	var kb: int = FightScorchArt._seed(Vector2(3.5, 4.0))
	assert_ne(ka, kb)
	var a: PackedVector2Array = FightScorchArt._ring(Vector2.ZERO, 60.0, 18, ka, true)
	var b: PackedVector2Array = FightScorchArt._ring(Vector2.ZERO, 60.0, 18, kb, true)
	assert_ne(a, b)


func test_outline_is_ragged_with_tongues_and_never_crosses() -> void:
	var key: int = FightScorchArt._seed(Vector2(-7.25, 11.5))
	var ring: PackedVector2Array = FightScorchArt._ring(Vector2.ZERO, 100.0, 18, key, true)
	var lo: float = INF
	var hi: float = 0.0
	var turned: float = 0.0
	for i: int in ring.size():
		lo = minf(lo, ring[i].length())
		hi = maxf(hi, ring[i].length())
		var step: float = ring[i].angle_to(ring[(i + 1) % ring.size()])
		assert_gt(step, 0.0, "the outline keeps turning one way (no self-crossing)")
		turned += step
	assert_almost_eq(turned, TAU, 0.001, "one full turn")
	assert_gt(hi, 108.0, "a tongue licks past the rim")
	assert_lt(lo, 108.0, "not a circle")


func test_hash_stays_in_unit_range() -> void:
	for n: int in [-99999, -1, 0, 1, 7, 123456789]:
		var h: float = FightScorchArt._h(n)
		assert_true(h >= 0.0 and h < 1.0, "h(%d) = %f" % [n, h])
