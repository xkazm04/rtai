extends GutTest
## CitySimNative.cell_at (perf L22: Object.call instead of callv) answers as the GDScript reference
## over stamped chunks, the map's edges and points off the map.


func _side(sim: CitySimBackend, gen: CityGen) -> void:
	sim.init(7)
	var res: CityResidency = CityResidency.new(ChunkSource.new(gen), sim, SimConst.CITY_CHUNKS)
	for cy: int in range(2, 4):
		for cx: int in range(2, 4):
			res.adopt(Vector2i(cx, cy), gen.gen_chunk(cx, cy))


func test_native_cells_match_the_reference() -> void:
	if not CitySimNative.available():
		pending("the native library is not loaded")
		return
	var gen: CityGen = CityGen.from_tables(
		"res://data/tables/city_district.json", "res://data/tables/city_textures.json"
	)
	var a: CitySimBackend = CitySimRef.new()
	var b: CitySimBackend = CitySimNative.new()
	_side(a, gen)
	_side(b, gen)
	var span: float = SimConst.CHUNK_M * 5.0
	var built: int = 0
	for k: int in 4000:  # a jittered sweep over the stamped chunks, past them and off the map
		var p: Vector2 = Vector2(fmod(k * 13.37, span) - 8.0, fmod(k * 7.91, span) - 8.0)
		assert_eq(b.cell_at(p.x, p.y), a.cell_at(p.x, p.y), "cell at %s" % p)
		built += 1 if a.cell_at(p.x, p.y) == SimConst.C_BUILD else 0
	assert_gt(built, 100, "the sweep crosses buildings (the compare is not all zeros)")
	assert_eq(b.cell_at(-1.0, 3.0), 0, "off the map")
	assert_eq(b.cell_at(1e9, 3.0), 0, "off the map")
