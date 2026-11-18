extends GutTest
## Dock 9's harbour office (n18 districts item 5, the asset lane's it471 office roof): the docks
## row's office_roof stands exactly once in the city, on the quay-end shed tile of the south row
## of the block places.json's dock_9 resolves to, so the place and its landmark agree.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen = null
var _docks: CityZone = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_docks = _gen.zones.rows[_gen.zones.index_of(&"docks")]


func test_the_office_rule_is_dock_9s_row() -> void:
	var table: Dictionary = CityGen.read_json(CityPlaces.TABLE)
	var row: Dictionary = {}
	for r: Dictionary in table["places"]:
		if str(r["id"]) == "dock_9":
			row = r
	assert_eq(str(row.get("rule", "")), DockDresser.OFFICE_RULE)
	var near: Array = row.get("near", [])
	var nx: float = near[0]
	var ny: float = near[1]
	assert_eq(Vector2(nx, ny), DockDresser.OFFICE_NEAR)


func test_the_office_stands_once_on_dock_9s_block() -> void:
	assert_gt(_docks.office_roof, 0)
	var tile: Vector2i = DockDresser.office_tile(_gen, _docks)
	var place: Dictionary = CityPlaces.shipped(_gen).place("dock_9")
	var block: Rect2i = place["block"]
	assert_true(block.has_point(tile), "office tile %s on Dock 9's block %s" % [tile, block])
	assert_eq(tile.y, block.end.y - 1, "on the south row, over the street the door faces")
	var found: Array[Vector2] = []
	for cy: int in SimConst.CITY_CHUNKS:
		for cx: int in range(12, SimConst.CITY_CHUNKS):
			var ch: CityChunk = _gen.gen_chunk(cx, cy)
			for i: int in ch.tex.size():
				if ch.tex[i] == _docks.office_roof and ch.xf[i * CityChunk.XF_STRIDE + 3] == 0.0:
					var x: float = ch.xf[i * CityChunk.XF_STRIDE]
					var y: float = ch.xf[i * CityChunk.XF_STRIDE + 1]
					found.append(Vector2(x, y))
	assert_eq(found.size(), 1, "one harbour office in the city (shadows aside): %s" % [found])
	if found.size() == 1:
		assert_eq(found[0], Vector2(tile * 8) + Vector2(4.0, 4.0), "drawn on the office tile")
