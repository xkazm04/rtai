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
