extends GutTest
## A zone's plaza centrepiece (CityZone.plaza_centre; downtown's fountain): one per plaza block,
## on the block's middle tile, never among the slot props.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"


func test_one_centrepiece_per_plaza_block_on_its_middle_tile() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	var down: CityZone = gen.zones.rows[gen.zones.index_of(&"downtown")]
	assert_gte(down.plaza_centre, 0)
	assert_false(down.plaza_props.has(down.plaza_centre), "the centrepiece is not a slot prop")
	var per_block: Dictionary[Vector2i, int] = {}
	for c: Vector2i in [Vector2i(8, 6), Vector2i(9, 6)]:
		var ch: CityChunk = gen.gen_chunk(c.x, c.y)
		for i: int in ch.tex.size():
			var flag: float = ch.xf[i * CityChunk.XF_STRIDE + 3]
			if ch.tex[i] != down.plaza_centre or flag != 0.0:
				continue
			var x: float = ch.xf[i * CityChunk.XF_STRIDE]
			var y: float = ch.xf[i * CityChunk.XF_STRIDE + 1]
			var t: Vector2i = Vector2i(floori(x / SimConst.TILE_M), floori(y / SimConst.TILE_M))
			assert_eq(
				Vector2i(posmod(t.x, CityGen.PERIOD), posmod(t.y, CityGen.PERIOD)), Vector2i(5, 5)
			)
			var block: Vector2i = Vector2i(floori(t.x / 8.0), floori(t.y / 8.0))
			per_block[block] = per_block.get(block, 0) + 1
	assert_gt(per_block.size(), 0, "the two chunks hold a downtown plaza")
	for block: Vector2i in per_block:
		assert_eq(per_block[block], 1, "block %s" % block)
