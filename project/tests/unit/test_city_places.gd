extends GutTest
## CityPlaces (n18 districts item 4): every shipped place resolves, its door is a walkable
## sidewalk cell on the block's street frontage inside its zone, and it is stable across two
## generators built from the same tables.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen = null
var _places: CityPlaces = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_places = CityPlaces.shipped(_gen)


func _cell_at(cell: Vector2i) -> int:
	var n: int = SimConst.CHUNK_CELLS
	var chunk: CityChunk = _gen.gen_chunk(floori(float(cell.x) / n), floori(float(cell.y) / n))
	return chunk.cells[posmod(cell.y, n) * n + posmod(cell.x, n)]


func test_every_place_resolves_in_its_zone() -> void:
	assert_gt(_places.ids().size(), 1)
	for id: String in _places.ids():
		var p: Dictionary = _places.place(id)
		assert_false(p.is_empty(), "%s resolves" % id)
		if p.is_empty():
			continue
		var block: Rect2i = p["block"]
		var zone: StringName = p["zone"]
		assert_eq(_gen.zones.of_tile(block.position).id, zone, "%s lies in its zone" % id)


func test_every_door_is_walkable_sidewalk_outside_its_block() -> void:
	for id: String in _places.ids():
		var p: Dictionary = _places.place(id)
		var cell: Vector2i = p["cell"]
		var door: Vector2 = p["door"]
		var block: Rect2i = p["block"]
		assert_eq(_cell_at(cell), SimConst.C_WALK, "%s door on a walk cell" % id)
		var wall_m: float = block.end.y * SimConst.TILE_M
		assert_between(door.y - wall_m, 0.0, CityGen.WALK_M, "%s door on the frontage" % id)
		var facing: Vector2 = p["facing"]
		assert_eq(facing, Vector2.DOWN, "%s faces the street" % id)
		assert_eq(_cell_at(cell + Vector2i(0, -ceili(door.y - wall_m) - 1)), SimConst.C_BUILD)


func test_places_are_stable_across_two_generators() -> void:
	var other: CityPlaces = CityPlaces.shipped(CityGen.from_tables(DISTRICT, TEXTURES))
	for id: String in _places.ids():
		var a: Dictionary = other.place(id)
		var b: Dictionary = _places.place(id)
		assert_eq(str(a), str(b), "%s is stable" % id)


func test_dock_9_is_a_docks_long_block_on_the_quay_side() -> void:
	var p: Dictionary = _places.place("dock_9")
	var zone: StringName = p["zone"]
	assert_eq(zone, &"docks")
	var block: Rect2i = p["block"]
	assert_eq(block.size.x, 13, "a long block (two blocks and the dropped street)")
	var city_tiles: int = SimConst.CITY_CHUNKS * SimConst.CHUNK_TILES
	assert_gt(block.end.x, city_tiles - 16, "the long block nearest the quay")


func test_an_unknown_place_or_rule_is_empty() -> void:
	assert_eq(_places.place("nowhere"), {})
	var odd: CityPlaces = CityPlaces.new(
		_gen, {"places": [{"id": "x", "zone": "docks", "rule": "moon", "near": [0, 0]}]}
	)
	assert_eq(odd.place("x"), {})
