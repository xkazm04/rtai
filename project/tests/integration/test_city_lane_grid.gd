extends GutTest
## t-4 (n15): what the car-routing fix can change in the generated city. Every tile a car's
## planning probe can reach from a lane (CAR_PLAN_AHEAD along its road) is road of the lane's
## orientation, a junction, or the void past the city edge; every junction exit probed at
## CAR_EXIT_PROBE is road of the exit's orientation or void. So in this city the old rule (U-turn
## before any non-road tile, any road orientation accepted) never fired: the fix guards other maps
## (quest pads, a future generator), and the shipped city's traffic does not move.

const DISTRICT: String = "res://data/tables/city_district.json"  # CitySystem.DISTRICT
const TEXTURES: String = "res://data/tables/city_textures.json"  # CitySystem.TEXTURES
const NT: int = SimConst.CHUNK_TILES * SimConst.CITY_CHUNKS

var _tiles: PackedByteArray = PackedByteArray()


func before_all() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	@warning_ignore("return_value_discarded")
	_tiles.resize(NT * NT)
	var n: int = SimConst.CHUNK_TILES
	for cy: int in SimConst.CITY_CHUNKS:
		for cx: int in SimConst.CITY_CHUNKS:
			var chunk: CityChunk = gen.gen_chunk(cx, cy)
			for ly: int in n:
				for lx: int in n:
					_tiles[(cy * n + ly) * NT + cx * n + lx] = chunk.tiles[ly * n + lx]


func _at(tx: int, ty: int) -> int:
	if tx < 0 or ty < 0 or tx >= NT or ty >= NT:
		return SimConst.T_VOID
	return _tiles[ty * NT + tx]


func test_a_lane_probe_only_ever_meets_its_own_road_a_junction_or_the_edge() -> void:
	var reach: int = ceili(SimConst.CAR_PLAN_AHEAD / SimConst.TILE_M) + 1
	var bad: Array[String] = []
	var lanes: int = 0
	for ty: int in NT:
		for tx: int in NT:
			var t: int = _at(tx, ty)
			if t != SimConst.T_ROAD_H and t != SimConst.T_ROAD_V:
				continue
			for dir: int in 4:
				if CitySimCarRoute.road_of(dir) != t:
					continue
				lanes += 1
				for k: int in range(1, reach + 1):
					var ahead: int = _at(
						tx + int(CitySimState.DX[dir]) * k, ty + int(CitySimState.DY[dir]) * k
					)
					var fine: bool = ahead == t or ahead == SimConst.T_INTER
					if not fine and ahead != SimConst.T_VOID and bad.size() < 5:
						bad.append("tile %d,%d dir %d meets %d" % [tx, ty, dir, ahead])
	assert_gt(lanes, 10000, "the city has its lanes")
	assert_eq(bad, [] as Array[String], "no kerb, plaza or building ahead of a lane")


func test_every_junction_exit_is_its_own_road_or_the_edge() -> void:
	var step: int = int(SimConst.CAR_EXIT_PROBE / SimConst.TILE_M)
	var junctions: int = 0
	var bad: Array[String] = []
	for ty: int in NT:
		for tx: int in NT:
			if _at(tx, ty) != SimConst.T_INTER:
				continue
			junctions += 1
			for dir: int in 4:
				var t: int = _at(
					tx + int(CitySimState.DX[dir]) * step, ty + int(CitySimState.DY[dir]) * step
				)
				if t != SimConst.T_VOID and t != CitySimCarRoute.road_of(dir) and bad.size() < 5:
					bad.append("junction %d,%d exit %d is %d" % [tx, ty, dir, t])
	assert_eq(junctions, (NT / CityGen.PERIOD) * (NT / CityGen.PERIOD))
	assert_eq(bad, [] as Array[String], "no exit onto a sideways road")
