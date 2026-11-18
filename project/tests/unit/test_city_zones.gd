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


func test_every_list_key_a_row_names_reaches_its_zone() -> void:
	var row: Dictionary = {"id": "x"}
	var i: int = 0
	for key: String in CityZone.LISTS:
		row[key] = [100.0 + i, 101.0 + i]
		i += 2
	var z: CityZone = CityZone.from_row(row)
	i = 0
	for key: String in CityZone.LISTS:
		var got: Array[int] = z.get(key)
		assert_eq(got, [100 + i, 101 + i] as Array[int], key)
		i += 2


func test_the_docks_water_draws_its_own_art() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, "res://data/tables/city_textures.json")
	var docks: CityZone = gen.zones.rows[gen.zones.index_of(&"docks")]
	assert_false(docks.water_ground.has(72), "72 is the plain asphalt box, not water")
	assert_gt(docks.water_ground.size(), 0)


func test_the_docks_traffic_runs_more_vans_and_pickups_than_the_default() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, "res://data/tables/city_textures.json")
	var docks: CityZone = gen.zones.rows[gen.zones.index_of(&"docks")]
	var mixed: CityZone = gen.zones.rows[gen.zones.index_of(&"mixed")]
	assert_true(mixed.car_art.is_empty(), "mixed keeps CitySpawner.CAR_ART")
	assert_gt(_work_share(docks.car_art), _work_share(CitySpawner.CAR_ART) * 2.0)
	for zone: CityZone in gen.zones.rows:
		if not zone.car_art.is_empty():
			assert_eq(zone.car_art.size(), 12, str(zone.id))
		for art: int in zone.car_art:
			assert_between(art, 0, 7, str(zone.id))


func _work_share(arts: Array[int]) -> float:
	var n: int = 0
	for art: int in arts:
		var kind: StringName = VehicleProfile.archetype_of_variant(art, false)
		n += 1 if kind == &"van" or kind == &"pickup" else 0
	return n / float(maxi(arts.size(), 1))
