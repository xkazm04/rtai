extends GutTest
## Chunk source, deterministic residency and the spawner (WLD-01/02, SIM-02, SIM-05).

var _dir: String = TestTmp.dir("city_chunks")

var _gen: CityGen


func before_all() -> void:
	_gen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	assert_eq(DirAccess.make_dir_recursive_absolute(_dir), OK)


func test_a_missing_file_is_generated_identically() -> void:
	var src: ChunkSource = ChunkSource.new(_gen, _dir)
	var why: Array[String] = []
	var c: CityChunk = src.load_now(Vector2i(2, 3), why)
	assert_not_null(c)
	assert_eq(c.cells, _gen.gen_chunk(2, 3).cells)


func test_a_corrupt_file_is_never_instantiated() -> void:
	var bytes: PackedByteArray = ChunkCodec.encode(_gen.gen_chunk(1, 1), CityGen.GENERATOR_VERSION)
	bytes[bytes.size() - 1] ^= 0x5A
	var f: FileAccess = FileAccess.open(
		_dir.path_join(ChunkCodec.file_name(1, 1)), FileAccess.WRITE
	)
	assert_true(f.store_buffer(bytes))
	f.close()
	var src: ChunkSource = ChunkSource.new(_gen, _dir)
	assert_null(src.take(Vector2i(1, 1)))
	assert_eq(src.failures.size(), 1)
	assert_string_contains(src.failures[0], "hash mismatch")


func test_prefetch_then_take_returns_the_chunk() -> void:
	var src: ChunkSource = ChunkSource.new(_gen, _dir)
	src.prefetch(Vector2i(5, 5))
	var c: CityChunk = src.take(Vector2i(5, 5))
	assert_not_null(c)
	assert_eq(c.key(), Vector2i(5, 5))


func test_residency_follows_the_focus_deterministically() -> void:
	var a: CityResidency = _residency()
	var b: CityResidency = _residency()
	var focus: Vector2 = Vector2(700, 700)
	a.update(focus)
	b.update(focus)
	assert_eq(a.resident_keys(), b.resident_keys())
	assert_true(a.is_resident(Vector2i(5, 5)), "the focus chunk")
	assert_false(a.is_resident(Vector2i(9, 5)), "beyond R_SIM")
	a.update(focus + Vector2(600, 0))
	assert_false(a.is_resident(Vector2i(3, 5)), "dropped beyond R_DROP")
	assert_gt(a.dropped, 0)


func test_spawner_fills_the_bubble_from_its_stream() -> void:
	var counts: Array[PackedInt32Array] = []
	for run: int in 2:
		var sim: CitySimRef = CitySimRef.new()
		sim.init(3)
		var res: CityResidency = CityResidency.new(ChunkSource.new(_gen, _dir), sim, 16)
		res.update(Vector2(700, 700))
		var sp: CitySpawner = CitySpawner.new(sim, res, RngRegistry.new(11).stream(&"city_spawn"))
		sp.targets = CityTargets.street(60, 20, 2)
		assert_gt(sp.tick(Vector2(700, 700), true), 60)
		sim.step(SimClock.TICK_DT, 700, 700, 700, 700)
		counts.append(sim.get_counters())
	assert_almost_eq(counts[0][SimConst.CN_PEDS], 60, 2, "a body may despawn in the first step")
	assert_almost_eq(counts[0][SimConst.CN_CARS], 20, 2)
	assert_eq(counts[0][SimConst.CN_PCARS], 2)
	assert_eq(counts[0], counts[1], "same stream, same spawns")


## d9: bikes come from their own stream: the cars' spawn draws (positions, counts) do not move.
func test_bikes_draw_from_their_own_stream() -> void:
	var made: Array[int] = []
	var bikes: Array[int] = []
	for share: float in [0.0, 1.0]:
		var sim: CitySimRef = CitySimRef.new()
		sim.init(3)
		var res: CityResidency = CityResidency.new(ChunkSource.new(_gen, _dir), sim, 16)
		res.update(Vector2(700, 700))
		var sp: CitySpawner = CitySpawner.new(sim, res, RngRegistry.new(11).stream(&"city_spawn"))
		sp.targets = CityTargets.street(60, 20, 2)
		sp.bike_share = share
		sp.bike_rng = RngRegistry.new(11).stream(&"city_bikes")
		made.append(sp.tick(Vector2(700, 700), true))
		bikes.append(sim.get_variants().count(SimConst.ART_BIKE))
	assert_eq(made[0], made[1], "the same spawns either way")
	assert_eq(bikes[0], 0)
	assert_eq(bikes[1], 20, "share 1: every traffic car (the 20 targeted) a bike")


func test_resident_keys_stay_sorted_and_are_rebuilt_only_on_a_change() -> void:
	var a: CityResidency = _residency()
	a.update(Vector2(700, 700))
	var k1: Array[Vector2i] = a.resident_keys()
	assert_eq(k1, CityResidency._sorted(k1.duplicate()), "row order")
	assert_true(is_same(k1, a.resident_keys()), "no change: the same sorted array, no re-sort")
	assert_true(k1.is_read_only(), "callers cannot reorder the cache")
	a.evict(k1[0])
	var k2: Array[Vector2i] = a.resident_keys()
	assert_false(k2.has(k1[0]), "an evict rebuilds")
	assert_eq(k2.size(), k1.size() - 1)
	a.update(Vector2(1300, 700))  # drops the west, adopts the east
	var k3: Array[Vector2i] = a.resident_keys()
	var fresh: Array[Vector2i] = []
	for key: Vector2i in k3:
		assert_true(a.is_resident(key))
		fresh.append(key)
	assert_eq(k3, CityResidency._sorted(fresh), "after update: row order")
	assert_false(k3.has(Vector2i(3, 5)), "a dropped key left the cache")
	assert_true(k3.has(Vector2i(10, 5)), "an adopted key joined it")


func _residency() -> CityResidency:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(1)
	return CityResidency.new(ChunkSource.new(_gen, _dir.path_join("no_such_dir")), sim, 16)
