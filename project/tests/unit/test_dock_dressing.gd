extends GutTest
## The docks dressing (n18 districts item 3, the asset lane's it471/it473 cards and plan twins,
## DockDresser): quay apron tiles stand an apron prop on their land side under apron_prop_share
## and keep DockDresser.OPEN_M by the water walkable; each basin's west quay stands one
## quay_edge_prop on its land strip by the coping.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
const EAST_CHUNK: int = 15

var _gen: CityGen = null
var _docks: CityZone = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_docks = _gen.zones.rows[_gen.zones.index_of(&"docks")]


func test_the_docks_row_names_solid_dressing() -> void:
	assert_gt(_docks.apron_props.size(), 0)
	assert_gt(_docks.apron_prop_share, 0.0)
	assert_gt(_docks.quay_edge_prop, 0)
	for tex: int in _docks.apron_props + [_docks.quay_edge_prop]:
		assert_true(_gen.solid[tex], "dressing %d is solid" % tex)


func test_apron_props_stand_on_the_land_side_and_keep_the_walk() -> void:
	var wx: int = DockPainter.water_x(_docks)
	var tiles: int = 0
	var props: int = 0
	for cy: int in SimConst.CITY_CHUNKS:
		var ch: CityChunk = _gen.gen_chunk(EAST_CHUNK, cy)
		for p: Vector3 in _props(ch, _docks.apron_props):
			var t: Vector2i = Vector2i(floori(p.x / 8.0), floori(p.y / 8.0))
			assert_eq(t.x, wx - 1, "an apron prop stands in the apron column")
			var right: float = p.x - t.x * 8.0 + _gen.sizes[int(p.z)].x * 0.5
			assert_lt(right, 8.0 - DockDresser.OPEN_M + 0.01, "%s leaves the open walk" % t)
			props += 1
		for j: int in SimConst.CHUNK_TILES:
			var t: Vector2i = Vector2i(wx - 1, cy * SimConst.CHUNK_TILES + j)
			if posmod(t.y, CityGen.PERIOD) <= 2:
				continue
			tiles += 1
			var o: Vector2i = t * 8 - Vector2i(EAST_CHUNK, cy) * SimConst.CHUNK_CELLS
			for y: int in 8:
				assert_eq(_cell(ch, o + Vector2i(7, y)), SimConst.C_WALK, "%s by the water" % t)
				assert_eq(_cell(ch, o + Vector2i(6, y)), SimConst.C_WALK, "%s by the water" % t)
	assert_gt(tiles, 50, "the docks have an apron column")
	assert_between(props, int(tiles * 0.3), int(tiles * 0.7), "about apron_prop_share a tile")


func test_each_basin_stands_one_quay_edge_prop_by_the_coping() -> void:
	var wx: int = DockPainter.water_x(_docks)
	var stood: int = 0
	for cy: int in SimConst.CITY_CHUNKS:
		var ch: CityChunk = _gen.gen_chunk(EAST_CHUNK, cy)
		var here: Array[Vector3] = _props(ch, [_docks.quay_edge_prop])
		assert_eq(here.size(), SimConst.CHUNK_TILES / CityGen.PERIOD, "one a basin, chunk %d" % cy)
		for p: Vector3 in here:
			assert_eq(floori(p.x / 8.0), wx, "on the west quay")
			assert_lt(p.x - wx * 8.0, DockPainter.LAND_M, "on the land strip")
			stood += 1
	assert_eq(stood, SimConst.CITY_CHUNKS * 2)


## [x, y, tex] of every standing prop of `texs` in chunk ch.
func _props(ch: CityChunk, texs: Array) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for i: int in ch.tex.size():
		if texs.has(ch.tex[i]) and ch.xf[i * CityChunk.XF_STRIDE + 3] == 0.0:
			var x: float = ch.xf[i * CityChunk.XF_STRIDE]
			var y: float = ch.xf[i * CityChunk.XF_STRIDE + 1]
			out.append(Vector3(x, y, ch.tex[i]))
	return out


func _cell(ch: CityChunk, local: Vector2i) -> int:
	return ch.cells[local.y * SimConst.CHUNK_CELLS + local.x]
