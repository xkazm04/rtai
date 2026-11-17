extends GutTest
## Zone lint (n18 districts item 2; registry zone-progression-linting: an orphaned zone is a hard
## failure): over the whole generated city, every road tile is one network (so every zone is
## entered by road from every other), every zone has road in it, and the walkable tiles (kerbs,
## corners, plazas, the quay) are one network too (sidewalks continuous). Dead ends: a lane meets
## only its own road, a junction or the edge (test_city_lane_grid), so the router never U-turns.

const DISTRICT: String = "res://data/tables/city_district.json"  # CitySystem.DISTRICT
const TEXTURES: String = "res://data/tables/city_textures.json"  # CitySystem.TEXTURES
const NT: int = SimConst.CHUNK_TILES * SimConst.CITY_CHUNKS
const ROAD: Array[int] = [SimConst.T_ROAD_H, SimConst.T_ROAD_V, SimConst.T_INTER]
const WALK: Array[int] = [SimConst.T_CURB, SimConst.T_CORNER, SimConst.T_PLAZA]

var _tiles: PackedByteArray = PackedByteArray()
var _gen: CityGen = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	@warning_ignore("return_value_discarded")
	_tiles.resize(NT * NT)
	var n: int = SimConst.CHUNK_TILES
	for cy: int in SimConst.CITY_CHUNKS:
		for cx: int in SimConst.CITY_CHUNKS:
			var chunk: CityChunk = _gen.gen_chunk(cx, cy)
			for ly: int in n:
				for lx: int in n:
					_tiles[(cy * n + ly) * NT + cx * n + lx] = chunk.tiles[ly * n + lx]


func _road(i: int) -> bool:
	return ROAD.has(_tiles[i])


## A sidewalk tile, or a zebra crossing: a junction arm of a kept street line (the docks' dropped
## lines have no junction, so no crossing).
func _walk(i: int) -> bool:
	if WALK.has(_tiles[i]):
		return true
	var t: Vector2i = Vector2i(i % NT, floori(float(i) / NT))
	var m: Vector2i = Vector2i(posmod(t.x, CityGen.PERIOD), posmod(t.y, CityGen.PERIOD))
	var arm: bool = m.x <= 2 and m.y <= 2 and (m.x == 1) != (m.y == 1)
	return arm and _road(i) and not DockPainter.dropped(_gen.zones.of_tile(t), t)


## Tiles `keep` accepts reached from the first such tile, and how many such tiles there are.
func _flood(keep: Callable) -> Vector2i:
	var seen: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	seen.resize(NT * NT)
	var total: int = 0
	var start: int = -1
	for i: int in NT * NT:
		if keep.call(i):
			total += 1
			start = i if start < 0 else start
	if start < 0:
		return Vector2i.ZERO
	var stack: PackedInt32Array = PackedInt32Array([start])
	seen[start] = 1
	var reached: int = 0
	while not stack.is_empty():
		var i: int = stack[stack.size() - 1]
		@warning_ignore("return_value_discarded")
		stack.resize(stack.size() - 1)
		reached += 1
		var x: int = i % NT
		var y: int = floori(float(i) / NT)
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = x + d.x
			var ny: int = y + d.y
			if nx < 0 or ny < 0 or nx >= NT or ny >= NT:
				continue
			var j: int = ny * NT + nx
			if seen[j] == 0 and keep.call(j):
				seen[j] = 1
				@warning_ignore("return_value_discarded")
				stack.push_back(j)
	return Vector2i(reached, total)


func test_the_roads_are_one_network() -> void:
	var r: Vector2i = _flood(_road)
	assert_gt(r.y, 10000, "the city has its roads")
	assert_eq(r.x, r.y, "every road tile reachable from every other (no orphaned zone)")


func test_the_sidewalks_are_one_network() -> void:
	var r: Vector2i = _flood(_walk)
	assert_gt(r.y, 10000, "the city has its sidewalks")
	assert_eq(r.x, r.y, "every kerb, corner, plaza and quay tile reachable on foot (zebras)")


func test_every_zone_has_road_and_sidewalk() -> void:
	for zone: CityZone in _gen.zones.rows:
		var roads: int = 0
		var walks: int = 0
		for i: int in NT * NT:
			var t: Vector2i = Vector2i(i % NT, floori(float(i) / NT))
			if _gen.zones.of_tile(t) != zone:
				continue
			roads += 1 if ROAD.has(_tiles[i]) else 0
			walks += 1 if WALK.has(_tiles[i]) else 0
		assert_gt(roads, 0, "zone %s has road" % zone.id)
		assert_gt(walks, 0, "zone %s has sidewalk" % zone.id)
