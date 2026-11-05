extends GutTest
## n5-look (r2_w4): the rocket blast's debris is data, seeded by the blast's position, and gone
## after its ticks; `--blast-debris=off` (enabled false) draws nothing.


func after_each() -> void:
	WeaponFxDebris.enabled = true


func test_rules_load_from_the_table() -> void:
	var r: WeaponFxDebris = WeaponFxDebris.rules()
	assert_gt(r.chunks, 0)
	assert_gt(r.chunk_m.y, r.chunk_m.x)
	assert_gt(r.fly_k.y, r.fly_k.x, "slabs fly outward")
	assert_gt(r.ticks, 0)


func test_hash_is_stable_and_in_range() -> void:
	for i: int in 50:
		var h: float = WeaponFxDebris.hash01(12.5, i)
		assert_between(h, 0.0, 1.0)
		assert_eq(h, WeaponFxDebris.hash01(12.5, i), "same key, same slab")


func test_slabs_end_past_the_fireball() -> void:
	var r: WeaponFxDebris = WeaponFxDebris.rules()
	var start: float = WeaponFxDebris.fly(3.5, 0.0, 0.5)
	var end: float = WeaponFxDebris.fly(3.5, 1.0, 1.0)
	assert_almost_eq(start, 3.5 * r.fly_k.x, 0.001)
	assert_gt(end, 3.5, "the last slab lands outside the splash radius")


func test_big_slabs_are_spread_and_the_rest_small() -> void:
	var r: WeaponFxDebris = WeaponFxDebris.new()
	r.chunks = 9
	r.chunk_big = 3
	var big: Array[int] = []
	for i: int in r.chunks:
		if WeaponFxDebris._size_k(r, i, 0.0) >= 0.75:
			big.append(i)
		else:
			assert_lte(
				WeaponFxDebris._size_k(r, i, 1.0), 0.6, "a small slab stays in the lower 60 %"
			)
	assert_eq(big, [0, 3, 6] as Array[int], "three big slabs, a third of the ring apart")
	r.chunk_big = 0
	assert_eq(WeaponFxDebris._size_k(r, 4, 0.37), 0.37, "chunk_big 0 = the uniform sizes")
