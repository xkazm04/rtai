class_name CityPlaces
extends RefCounted
## Named places bound to generated blocks (n18 districts item 4; data/tables/places.json,
## gtai.places/1). A row names a zone and a rule that picks one block of that zone from the
## generator alone (no baked file, no hand-placed metres), so a place is as deterministic as the
## bake. place(id) answers {zone, block, chunk, cell, door, facing}: the door is a walkable
## sidewalk point on the block's frontage, facing out of the building onto the street.
## Rules: dock_block_nearest (a docks long block whose south row is warehouse, not yard) and
## block_nearest (a square building block of the zone, not a plaza), each the one nearest
## `near`, a fraction of the city ([1, 0.5] = the middle of the east edge, the quay).

const TABLE: String = "res://data/tables/places.json"
const SCHEMA: String = "gtai.places/1"
## How far along the frontage the door may slide off the block's middle to find a free sidewalk
## cell (lamps, benches and parked cars stamp C_PROP), and how far out from the wall it stands.
const SLIDE_M: int = 12
const OUT_M: float = 1.5

var _gen: CityGen
var _rows: Dictionary[String, Dictionary] = {}
var _cache: Dictionary[String, Dictionary] = {}


func _init(gen: CityGen, table: Dictionary) -> void:
	_gen = gen
	for row: Dictionary in table.get("places", []):
		_rows[str(row["id"])] = row


static func shipped(gen: CityGen) -> CityPlaces:
	return CityPlaces.new(gen, CityGen.read_json(TABLE))


func ids() -> Array[String]:
	var out: Array[String] = []
	out.assign(_rows.keys())
	return out


## {zone, block (tile rect), chunk, cell (world 1 m cell), door (m), facing}; {} if unknown or
## the rule finds no block.
func place(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	var row: Dictionary = _rows.get(id, {})
	if row.is_empty():
		return {}
	var block: Rect2i = _pick(row)
	var out: Dictionary = {} if block.size == Vector2i.ZERO else _frontage(row, block)
	_cache[id] = out
	return out


func _pick(row: Dictionary) -> Rect2i:
	var zone: StringName = StringName(str(row.get("zone", "mixed")))
	var near_f: Array = row.get("near", [0.5, 0.5])
	var city_t: float = float(SimConst.CITY_CHUNKS * SimConst.CHUNK_TILES)
	var fx: float = near_f[0]
	var fy: float = near_f[1]
	var near_t: Vector2 = Vector2(fx, fy) * city_t
	var best: Rect2i = Rect2i()
	var best_d: float = INF
	for r: Rect2i in _candidates(str(row.get("rule", "")), zone):
		var d: float = (Vector2(r.position) + Vector2(r.size) * 0.5).distance_squared_to(near_t)
		if d < best_d:
			best_d = d
			best = r
	return best


## Every block of the zone the rule accepts, as tile rects, in row-major order (ties keep the
## first, so the pick is stable).
func _candidates(rule: String, zone: StringName) -> Array[Rect2i]:
	var out: Array[Rect2i] = []
	var period: int = CityGen.PERIOD
	var n: int = floori(float(SimConst.CITY_CHUNKS * SimConst.CHUNK_TILES) / period)
	for by: int in n - 1:  # the last row's frontage would lie off the map
		for bx: int in n:
			var t: Vector2i = Vector2i(bx * period + 3, by * period + 3)
			var z: CityZone = _gen.zones.of_tile(t)
			if z.id != zone:
				continue
			if rule == "dock_block_nearest" and z.street_keep_x > 1:
				if (
					posmod(bx, z.street_keep_x) == 0
					and not DockPainter.is_yard(_gen, z, t + Vector2i(0, 4))
				):
					out.append(Rect2i(t, Vector2i(period * z.street_keep_x - 3, 5)))
			elif rule == "block_nearest" and z.street_keep_x == 1 and not _plaza(z, bx, by):
				out.append(Rect2i(t, Vector2i(5, 5)))
	return out


func _plaza(z: CityZone, bx: int, by: int) -> bool:
	return _gen.rnd(bx, by, 0, 5) < z.plaza_share


## The door on the block's south frontage (the street below it): OUT_M into the sidewalk from
## the wall, slid along the wall to the nearest free walk cell; facing south, onto the street.
func _frontage(row: Dictionary, block: Rect2i) -> Dictionary:
	var tile_m: float = SimConst.TILE_M
	var wx: int = DockPainter.water_x(_gen.zones.of_tile(block.position))
	var right: int = block.end.x if wx < 0 else mini(block.end.x, wx - 1)
	var mid_x: float = (float(block.position.x) + float(right)) * 0.5 * tile_m
	var wall_y: float = float(block.end.y) * tile_m
	var cells: CityChunk = null
	for k: int in range(0, SLIDE_M * 2 + 1):
		var dx: int = floori((k + 1) * 0.5) * (1 if k % 2 == 1 else -1)
		var door: Vector2 = Vector2(floorf(mid_x) + dx + 0.5, wall_y + OUT_M)
		var cell: Vector2i = Vector2i(floori(door.x), floori(door.y))
		var chunk: Vector2i = Vector2i(
			floori(float(cell.x) / SimConst.CHUNK_CELLS),
			floori(float(cell.y) / SimConst.CHUNK_CELLS)
		)
		if cells == null or Vector2i(cells.cx, cells.cy) != chunk:
			cells = _gen.gen_chunk(chunk.x, chunk.y)
		var local: Vector2i = cell - chunk * SimConst.CHUNK_CELLS
		if cells.cells[local.y * SimConst.CHUNK_CELLS + local.x] == SimConst.C_WALK:
			return {
				"id": str(row["id"]),
				"zone": _gen.zones.of_tile(block.position).id,
				"block": block,
				"chunk": chunk,
				"cell": cell,
				"door": door,
				"facing": Vector2.DOWN,
			}
	return {}
