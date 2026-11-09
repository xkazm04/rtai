extends GutTest
## BloodFlight: the C++ flight step (CitySim.step_blood_drops) against step_script, its GDScript
## twin, on the same drops over a walled map; and a whole BloodFx run with and without it.

const SEEDS: int = 200


func _sims() -> Array[CitySimBackend]:
	var gen: CityGen = CityGen.from_tables(
		"res://data/tables/city_district.json", "res://data/tables/city_textures.json"
	)
	var out: Array[CitySimBackend] = [CitySimNative.new(), CitySimRef.new()]
	for s: CitySimBackend in out:
		s.init(7)
		var res: CityResidency = CityResidency.new(ChunkSource.new(gen), s, SimConst.CITY_CHUNKS)
		for cy: int in range(2, 4):
			for cx: int in range(2, 4):
				res.adopt(Vector2i(cx, cy), gen.gen_chunk(cx, cy))
	return out


static func _solid_of(sim: CitySimBackend) -> Callable:
	return func(px: Vector2) -> bool:
		var c: int = sim.cell_at(px.x / SimConst.PX_PER_M, px.y / SimConst.PX_PER_M)
		return c == SimConst.C_BUILD or c == SimConst.C_PROP


## A point (px) inside the four stamped chunks.
static func _stamped_px(x: float, y: float) -> Vector2:
	var side: float = SimConst.CHUNK_M * SimConst.PX_PER_M
	return Vector2(2.0 * side + fmod(x, 2.0 * side), 2.0 * side + fmod(y, 2.0 * side))


## A spray over the stamped chunks: fast drops into walls, slow ones landing, dead slots between.
func _spray() -> BloodFlight:
	var f: BloodFlight = BloodFlight.new(SEEDS)
	for i: int in SEEDS:
		var at: Vector2 = _stamped_px(i * 97.13, i * 41.77)
		var v: Vector2 = Vector2.from_angle(i * 1.7) * (1.0 + fmod(i * 1.37, 40.0))
		f.put(i, at, v, 1.0, 0 if i % 7 == 0 else 3 + i % 19)
	return f


func test_the_native_flight_matches_the_script() -> void:
	if not CitySimNative.available():
		pending("the native library is not loaded")
		return
	var sims: Array[CitySimBackend] = _sims()
	var native: CitySimNative = sims[0]
	assert_true(native.blood_step().is_valid(), "this DLL has the entry")
	var a: BloodFlight = _spray()
	var b: BloodFlight = _spray()
	a.bulk = native.blood_step()
	var solid: Callable = _solid_of(sims[1])
	var lands: int = 0
	var walls: int = 0
	for t: int in 30:
		var ea: PackedInt32Array = a.step(solid, 0.86, 0.6)
		var eb: PackedInt32Array = b.step(solid, 0.86, 0.6)
		assert_eq(ea, eb, "events at tick %d" % t)
		assert_eq(a.pos, b.pos, "positions at tick %d" % t)
		assert_eq(a.vel, b.vel, "velocities at tick %d" % t)
		assert_eq(a.life, b.life, "life at tick %d" % t)
		for e: int in eb:
			lands += 1 if e & 1 == BloodFlight.LAND else 0
			walls += 1 if e & 1 == BloodFlight.WALL else 0
	assert_gt(lands, 20, "drops landed (the compare is not vacuous)")
	assert_gt(walls, 5, "drops hit walls")


## Two whole BloodFx over the same walls and hits: the C++ path leaves the same decals.
func test_a_blood_fx_reads_the_same_with_the_native_flight() -> void:
	if not CitySimNative.available():
		pending("the native library is not loaded")
		return
	var sims: Array[CitySimBackend] = _sims()
	var native: CitySimNative = sims[0]
	var a: BloodFx = BloodFx.new()
	var b: BloodFx = BloodFx.new()
	add_child_autofree(a)
	add_child_autofree(b)
	var solid: Callable = _solid_of(sims[1])
	a.solid = solid
	b.solid = solid
	a.bulk_step = native.blood_step()
	for k: int in 80:
		var at: Vector2 = _stamped_px(k * 83.3, k * 31.9)
		for fx: BloodFx in [a, b]:
			fx.splash(at, Vector2.from_angle(k * 0.9), "kill" if k % 5 == 0 else "thug_hit")
			fx.step_ticks(2)
		assert_eq(a.drops, b.drops, "live drops after hit %d" % k)
		assert_eq(a.live_decals(), b.live_decals(), "decals after hit %d" % k)
		assert_eq(a.wall_hits, b.wall_hits, "wall hits after hit %d" % k)
	assert_gt(a.wall_hits, 0, "the run reached a wall")
