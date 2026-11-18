class_name CityRoadMap
extends RefCounted
## A hand-made reference/native map for police car tests: chunk (2, 2) all sidewalk and plaza with
## one east-west road on tile row ROAD_TY (y 320..327: lanes at y 322 westbound and 326
## eastbound), its cells C_LANE. The road ends at the chunk's edges (void beyond: cars U-turn).

const ROAD_TY: int = 40
const LANE_E: float = 326.0
const LANE_W: float = 322.0
## paint_cross(): the north-south road's tile column (x 288..295).
const CROSS_TX: int = 36


static func paint(sim: CitySimBackend) -> void:
	sim.init(7)
	var n: int = SimConst.CHUNK_CELLS
	var tiles: PackedByteArray = CityChunk.zeros(CityChunk.TILES)
	tiles.fill(SimConst.T_PLAZA)
	var tn: int = SimConst.CHUNK_TILES
	for tx: int in tn:
		tiles[(ROAD_TY - 2 * tn) * tn + tx] = SimConst.T_ROAD_H
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	for y: int in range(ROAD_TY * 8, ROAD_TY * 8 + 8):
		for lx: int in n:
			cells[(y - 2 * n) * n + lx] = SimConst.C_LANE
	sim.stamp_chunk(2, 2, tiles, cells)


## paint() plus a north-south road on tile column CROSS_TX (x 288..295) and their junction tile.
static func paint_cross(sim: CitySimBackend) -> void:
	sim.init(7)
	var n: int = SimConst.CHUNK_CELLS
	var tn: int = SimConst.CHUNK_TILES
	var tiles: PackedByteArray = CityChunk.zeros(CityChunk.TILES)
	tiles.fill(SimConst.T_PLAZA)
	for k: int in tn:
		tiles[(ROAD_TY - 2 * tn) * tn + k] = SimConst.T_ROAD_H
		tiles[k * tn + CROSS_TX - 2 * tn] = SimConst.T_ROAD_V
	tiles[(ROAD_TY - 2 * tn) * tn + CROSS_TX - 2 * tn] = SimConst.T_INTER
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	for a: int in range(ROAD_TY * 8 - 2 * n, ROAD_TY * 8 + 8 - 2 * n):
		for b: int in n:
			cells[a * n + b] = SimConst.C_LANE
	for a: int in n:
		for b: int in range(CROSS_TX * 8 - 2 * n, CROSS_TX * 8 + 8 - 2 * n):
			cells[a * n + b] = SimConst.C_LANE
	sim.stamp_chunk(2, 2, tiles, cells)


## A dispatched police car (the game's CityDispatch spec) heading east in the eastbound lane.
static func dispatch_car(sim: CitySimBackend, x: float) -> int:
	var fl: int = SimConst.F_PROMOTED | SimConst.F_ENGAGED
	var spec: Array = [SimConst.K_PCAR, x, LANE_E, 1.0, 0.0, 8, fl, 17.0, LANE_E, 0]
	return sim.spawn(PackedFloat64Array(spec))


static func count(sim: CitySimBackend, kind: int) -> int:
	var n: int = 0
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] < SimConst.SNAP_PROJ_BASE and int(snap[r + 1]) == kind:
			n += 1
	return n
