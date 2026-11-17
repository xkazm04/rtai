extends GutTest
## CityZones / CityZone (n18 districts item 1): the zone rows and zone map of city_district.json.

const DISTRICT: String = "res://data/tables/city_district.json"
const DOCKS_BAND: Dictionary = {"zone": "docks", "chunks": [13, 0, 3, 16]}


func _district(rects: Array) -> Dictionary:
	return {
		"zones": [{"id": "mixed"}, {"id": "docks", "plaza_share": 0.5, "street_keep_x": 2}],
		"zone_map": {"default": "mixed", "rects": rects},
	}


func test_no_zones_is_one_mixed_zone_with_the_v14_rules() -> void:
	var z: CityZones = CityZones.from_district({})
	assert_eq(z.rows.size(), 1)
	assert_eq(z.id_of_chunk(7, 9), &"mixed")
	var mixed: CityZone = z.of_chunk(0, 0)
	assert_eq(mixed.plaza_share, 0.12)
	assert_eq(mixed.landmark_roofs, [14, 15, 16, 17, 18, 19, 20, 21] as Array[int])
	assert_eq(mixed.street_keep_x, 1)


func test_a_rect_paints_its_chunks_and_nothing_else() -> void:
	var z: CityZones = CityZones.from_district(_district([DOCKS_BAND]))
	assert_eq(z.id_of_chunk(13, 0), &"docks")
	assert_eq(z.id_of_chunk(15, 15), &"docks")
	assert_eq(z.id_of_chunk(12, 15), &"mixed")
	assert_eq(z.of_chunk(14, 4).plaza_share, 0.5)
	assert_eq(z.of_chunk(14, 4).street_keep_x, 2)


func test_a_tile_takes_its_chunks_zone_and_off_map_the_nearest() -> void:
	var z: CityZones = CityZones.from_district(_district([DOCKS_BAND]))
	var n: int = SimConst.CHUNK_TILES
	assert_eq(z.of_tile(Vector2i(13 * n, 5)).id, &"docks")
	assert_eq(z.of_tile(Vector2i(13 * n - 1, 5)).id, &"mixed")
	assert_eq(z.of_tile(Vector2i(16 * n + 3, -2)).id, &"docks")


func test_later_rects_win_and_an_unknown_zone_paints_nothing() -> void:
	var rects: Array = [
		{"zone": "docks", "chunks": [0, 0, 4, 4]},
		{"zone": "mixed", "chunks": [1, 1, 1, 1]},
		{"zone": "nowhere", "chunks": [0, 0, 16, 16]},
	]
	var z: CityZones = CityZones.from_district(_district(rects))
	assert_eq(z.id_of_chunk(0, 0), &"docks")
	assert_eq(z.id_of_chunk(1, 1), &"mixed")
	assert_eq(z.id_of_chunk(8, 8), &"mixed")


func test_the_shipped_table_reaches_the_generator() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, "res://data/tables/city_textures.json")
	assert_not_null(gen)
	assert_gt(gen.zones.rows.size(), 0)
	assert_ne(gen.zones.index_of(&"mixed"), -1)
