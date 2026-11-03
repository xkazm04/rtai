extends GutTest
## City generator + chunk file format (AST-11, AST-12): deterministic bytes, a checked header,
## and refusal of anything that does not match it.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)


func test_tables_load() -> void:
	assert_not_null(_gen)
	assert_eq(_gen.district_id, "district_01")
	var why: String = "72 road_box_plain, 73 zebra, 74 dash_eraser, 75-77 D5 story paint (2026-11-03)"
	assert_eq(_gen.sizes.size(), 78, why)


func test_generation_is_deterministic() -> void:
	var a: PackedByteArray = ChunkCodec.encode(_gen.gen_chunk(4, 4), CityGen.GENERATOR_VERSION)
	var b: PackedByteArray = ChunkCodec.encode(_gen.gen_chunk(4, 4), CityGen.GENERATOR_VERSION)
	assert_eq(a, b)
	assert_ne(a, ChunkCodec.encode(_gen.gen_chunk(5, 4), CityGen.GENERATOR_VERSION))


func test_chunk_has_streets_sidewalks_and_buildings() -> void:
	var c: CityChunk = _gen.gen_chunk(4, 4)
	assert_true(c.is_well_formed())
	for code: int in [SimConst.C_LANE, SimConst.C_WALK, SimConst.C_BUILD]:
		assert_has(c.cells, code, "cell code %d present" % code)
	assert_has(c.tiles, SimConst.T_INTER)
	assert_gt(c.command_count(), 300, "a full draw list")


func test_codec_round_trip() -> void:
	var c: CityChunk = _gen.gen_chunk(3, 7)
	var bytes: PackedByteArray = ChunkCodec.encode(c, CityGen.GENERATOR_VERSION)
	var why: Array[String] = []
	var back: CityChunk = ChunkCodec.decode(bytes, Vector2i(3, 7), why)
	assert_not_null(back, why[0] if not why.is_empty() else "")
	assert_eq(back.cells, c.cells)
	assert_eq(back.xf, c.xf)
	assert_eq(ChunkCodec.generator_version_of(bytes), CityGen.GENERATOR_VERSION)


func test_corruption_and_mismatch_are_refused() -> void:
	var bytes: PackedByteArray = ChunkCodec.encode(_gen.gen_chunk(3, 7), CityGen.GENERATOR_VERSION)
	var why: Array[String] = []
	assert_null(ChunkCodec.decode(bytes, Vector2i(3, 8), why), "wrong key")
	assert_string_contains(why[0], "names chunk")
	var flipped: PackedByteArray = bytes.duplicate()
	flipped[ChunkCodec.HEADER_SIZE + 100] ^= 0xFF
	assert_null(ChunkCodec.decode(flipped, Vector2i(3, 7), why), "flipped payload byte")
	assert_eq(why[0], "payload hash mismatch")
	var old: PackedByteArray = bytes.duplicate()
	old.encode_u16(4, 99)
	assert_null(ChunkCodec.decode(old, Vector2i(3, 7), why), "unknown format version")
	assert_null(ChunkCodec.decode(PackedByteArray([1, 2, 3]), Vector2i(3, 7), why), "truncated")


func test_a_junction_has_a_plain_box_and_four_approach_zebras() -> void:
	# T1: no crossing ring round the centre tile; zebras on the approaches, against the box
	var chunk: CityChunk = _gen.gen_chunk(4, 4)
	var box: int = 0
	var zebras: int = 0
	var erasers: int = 0
	for i: int in chunk.command_count():
		if chunk.tex[i] == TilePainter.T_BOX:
			box += 1
		elif chunk.tex[i] == TilePainter.T_ZEBRA:
			zebras += 1
		elif chunk.tex[i] == TilePainter.T_DASH_ERASER:
			erasers += 1
		assert_ne(chunk.tex[i], 6, "the ringed intersection tile is not placed")
	assert_gt(box, 0)
	assert_eq(zebras, 4 * box)
	assert_eq(erasers, 8 * box, "no dashes on any approach arm")
