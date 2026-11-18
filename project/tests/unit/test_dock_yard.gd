extends GutTest
## The docks container yards (n18 districts item 3; the asset lane's container stacks): a yard tile
## stands its stacks in the two YARD_SLOTS rows as solid props, and keeps the aisles walkable (the
## tile's west column and the gap between the rows), so the yard is one walk network with its block.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen = null
var _docks: CityZone = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_docks = _gen.zones.rows[_gen.zones.index_of(&"docks")]


func _yard_tiles(c: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for j: int in SimConst.CHUNK_TILES:
		for i: int in SimConst.CHUNK_TILES:
			var t: Vector2i = c * SimConst.CHUNK_TILES + Vector2i(i, j)
			var my: int = posmod(t.y, CityGen.PERIOD)
			if my > 2 and not DockPainter.dropped(_docks, t) and posmod(t.x, CityGen.PERIOD) <= 2:
				continue  # a kept street line
			if (
				my > 2
				and t.x < DockPainter.water_x(_docks) - 1
				and DockPainter.is_yard(_gen, _docks, t)
			):
				out.append(t)
	return out


func test_the_docks_row_names_container_stacks() -> void:
	assert_gt(_docks.yard_props.size(), 0)
	assert_gt(_docks.yard_prop_share, 0.0)
	for tex: int in _docks.yard_props:
		assert_true(_gen.solid[tex], "stack %d is solid" % tex)


func test_yards_stand_stacks_and_keep_their_aisles() -> void:
	var stacks: int = 0
	var tiles: int = 0
	for c: Vector2i in [Vector2i(13, 6), Vector2i(14, 9)]:
		var ch: CityChunk = _gen.gen_chunk(c.x, c.y)
		for i: int in ch.tex.size():
			if _docks.yard_props.has(ch.tex[i]) and ch.xf[i * CityChunk.XF_STRIDE + 3] == 0.0:
				stacks += 1
		for t: Vector2i in _yard_tiles(c):
			tiles += 1
			var o: Vector2i = t * 8 - c * SimConst.CHUNK_CELLS
			for y: int in 8:
				assert_eq(_cell(ch, o + Vector2i(0, y)), SimConst.C_WALK, "%s west aisle" % t)
			for x: int in 8:
				assert_eq(_cell(ch, o + Vector2i(x, 3)), SimConst.C_WALK, "%s row gap" % t)
				assert_eq(_cell(ch, o + Vector2i(x, 7)), SimConst.C_WALK, "%s south aisle" % t)
			var want: int = SimConst.C_PROP if _stood(ch, t, 0) else SimConst.C_WALK
			assert_eq(_cell(ch, o + Vector2i(4, 1)), want, "%s slot 0 solid iff stood" % t)
	assert_gt(tiles, 0, "the two chunks hold yard tiles")
	assert_gt(stacks, tiles / 2, "about yard_prop_share x 2 stacks a yard tile")


## Whether slot k of tile t stands a stack (the chunk's prop commands).
func _stood(ch: CityChunk, t: Vector2i, k: int) -> bool:
	var at: Vector2 = Vector2(t * 8) + DockPainter.YARD_SLOTS[k]
	for i: int in ch.tex.size():
		var x: float = ch.xf[i * CityChunk.XF_STRIDE]
		var y: float = ch.xf[i * CityChunk.XF_STRIDE + 1]
		if _docks.yard_props.has(ch.tex[i]) and Vector2(x, y).distance_to(at) < 0.01:
			return true
	return false


func _cell(ch: CityChunk, local: Vector2i) -> int:
	return ch.cells[local.y * SimConst.CHUNK_CELLS + local.x]
