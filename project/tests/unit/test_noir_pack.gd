extends GutTest
## Render-only blood helpers: repeatable counter noise, table RGB and fresh zeroed pools.


func test_counter_hash_is_independent_of_call_order() -> void:
	var first: float = NoirPack.hash01(47)
	var other: float = NoirPack.hash01(901)
	assert_ne(first, other, "different counters vary the render noise")
	assert_eq(NoirPack.hash01(47), first, "another sample does not advance an RNG stream")
	assert_eq(NoirPack.hash01(901), other, "samples can be requested in either order")


func test_counter_hash_stays_in_the_half_open_unit_interval() -> void:
	var lowest: float = INF
	var highest: float = -INF
	for counter: int in 4096:
		var sample: float = NoirPack.hash01(counter)
		lowest = minf(lowest, sample)
		highest = maxf(highest, sample)
	assert_gte(lowest, 0.0, "render noise is never negative")
	assert_lt(highest, 1.0, "one is excluded from the noise range")


func test_rgb_preserves_json_channel_order_and_is_opaque() -> void:
	var source: String = "[0.125,0.5,0.875]"
	var parsed: Variant = JSON.parse_string(source)
	var colour: Color = NoirPack.rgb(parsed)
	assert_eq(colour, Color(0.125, 0.5, 0.875, 1.0), "RGB is linear channel data, not bytes")
	assert_eq(JSON.stringify(parsed), source, "reading a colour leaves its table row unchanged")


func test_rgb_preserves_black_white_and_primary_channel_boundaries() -> void:
	assert_eq(NoirPack.rgb([0, 0, 0]), Color.BLACK)
	assert_eq(NoirPack.rgb([1, 1, 1]), Color.WHITE)
	assert_eq(NoirPack.rgb([1, 0, 0]), Color(1.0, 0.0, 0.0, 1.0))
	assert_eq(NoirPack.rgb([0, 1, 0]), Color(0.0, 1.0, 0.0, 1.0))
	assert_eq(NoirPack.rgb([0, 0, 1]), Color(0.0, 0.0, 1.0, 1.0))


func test_vector_pool_has_exactly_the_requested_zeroed_slots() -> void:
	for count: int in [0, 1, 7, 64]:
		var pool: PackedVector2Array = NoirPack.vec2s(count)
		assert_eq(pool.size(), count, "zero also requests a valid empty pool")
		for slot: int in pool.size():
			assert_eq(pool[slot], Vector2.ZERO, "every position starts at the origin")


func test_float_pool_has_exactly_the_requested_zeroed_slots() -> void:
	for count: int in [0, 1, 7, 64]:
		var pool: PackedFloat32Array = NoirPack.floats(count)
		assert_eq(pool.size(), count, "zero also requests a valid empty pool")
		for slot: int in pool.size():
			assert_eq(pool[slot], 0.0, "every scalar starts at zero")


func test_integer_pool_has_exactly_the_requested_zeroed_slots() -> void:
	for count: int in [0, 1, 7, 64]:
		var pool: PackedInt32Array = NoirPack.ints(count)
		assert_eq(pool.size(), count, "zero also requests a valid empty pool")
		for slot: int in pool.size():
			assert_eq(pool[slot], 0, "every tick counter starts at zero")


func test_vector_pools_do_not_share_particle_positions() -> void:
	var first: PackedVector2Array = NoirPack.vec2s(2)
	first[0] = Vector2(3.0, 5.0)
	var second: PackedVector2Array = NoirPack.vec2s(2)
	second[1] = Vector2(7.0, 9.0)
	assert_eq(first, PackedVector2Array([Vector2(3.0, 5.0), Vector2.ZERO]))
	assert_eq(second, PackedVector2Array([Vector2.ZERO, Vector2(7.0, 9.0)]))


func test_float_pools_do_not_share_particle_scalars() -> void:
	var first: PackedFloat32Array = NoirPack.floats(2)
	first[0] = 0.25
	var second: PackedFloat32Array = NoirPack.floats(2)
	second[1] = 0.75
	assert_eq(first, PackedFloat32Array([0.25, 0.0]))
	assert_eq(second, PackedFloat32Array([0.0, 0.75]))


func test_integer_pools_do_not_share_particle_ticks() -> void:
	var first: PackedInt32Array = NoirPack.ints(2)
	first[0] = 3
	var second: PackedInt32Array = NoirPack.ints(2)
	second[1] = 7
	assert_eq(first, PackedInt32Array([3, 0]))
	assert_eq(second, PackedInt32Array([0, 7]))
