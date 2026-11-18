extends GutTest
## Long dock roofs drawn with a south-eave feature (CityZone.upright_roofs; the asset lane's
## warehouse c with its hoist over the south eave) are never turned 180 deg, while the other long
## roofs still turn on half the blocks (the v21 look): the hoist always overhangs the south side.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen = null
var _docks: CityZone = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_docks = _gen.zones.rows[_gen.zones.index_of(&"docks")]


## [upright roofs seen, of them turned, other long roofs seen, of them turned] over the docks.
func _count() -> Array[int]:
	var out: Array[int] = [0, 0, 0, 0]
	for cy: int in range(0, 4):
		for cx: int in range(13, 16):
			var c: CityChunk = _gen.gen_chunk(cx, cy)
			for i: int in c.tex.size():
				var tex: int = c.tex[i]
				if not _docks.long_roofs.has(tex) or c.xf[i * 4 + 3] != 0.0:
					continue
				var turned: bool = absf(c.xf[i * 4 + 2]) > 0.01
				var k: int = 0 if _docks.upright_roofs.has(tex) else 2
				out[k] += 1
				out[k + 1] += 1 if turned else 0
	return out


func test_the_docks_row_names_an_upright_long_roof() -> void:
	assert_gt(_docks.upright_roofs.size(), 0)
	for tex: int in _docks.upright_roofs:
		assert_true(_docks.long_roofs.has(tex), "upright roof %d is one of the long roofs" % tex)


func test_upright_roofs_never_turn_and_the_others_still_do() -> void:
	var n: Array[int] = _count()
	assert_gt(n[0], 0, "the docks draw the upright roof")
	assert_eq(n[1], 0, "an upright roof turned")
	assert_gt(n[2], 0, "the docks draw other long roofs")
	assert_gt(n[3], 0, "the other long roofs still turn")
