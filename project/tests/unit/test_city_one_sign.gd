extends GutTest
## Lettered landmark roofs (BlockPainter.LETTERED: a drawn name) stand at most once a block in a
## zone with one_sign (downtown), on the block's seeded sign tile, so a name never repeats across
## one view; a zone without it keeps the v14 rule.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"


func test_downtown_stands_at_most_one_lettered_roof_a_block() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	var down: CityZone = gen.zones.rows[gen.zones.index_of(&"downtown")]
	assert_true(down.one_sign)
	var per_block: Dictionary[Vector2i, int] = {}
	var signs: int = 0
	for c: Vector2i in [
		Vector2i(7, 7), Vector2i(8, 7), Vector2i(9, 7), Vector2i(7, 8), Vector2i(8, 8)
	]:
		var ch: CityChunk = gen.gen_chunk(c.x, c.y)
		for i: int in ch.tex.size():
			var flag: float = ch.xf[i * CityChunk.XF_STRIDE + 3]
			if not BlockPainter.LETTERED.has(ch.tex[i]) or flag != 0.0:
				continue
			var x: float = ch.xf[i * CityChunk.XF_STRIDE]
			var y: float = ch.xf[i * CityChunk.XF_STRIDE + 1]
			var t: Vector2i = Vector2i(floori(x / SimConst.TILE_M), floori(y / SimConst.TILE_M))
			assert_true(
				BlockPainter.sign_tile(gen, t), "lettered %d off its sign tile %s" % [ch.tex[i], t]
			)
			var block: Vector2i = Vector2i(floori(t.x / 8.0), floori(t.y / 8.0))
			per_block[block] = per_block.get(block, 0) + 1
			signs += 1
	assert_gt(signs, 0, "downtown still has lettered landmarks")
	for block: Vector2i in per_block:
		assert_eq(per_block[block], 1, "block %s" % block)


func test_mixed_keeps_the_v14_rule() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	assert_false(gen.zones.rows[gen.zones.index_of(&"mixed")].one_sign)
