class_name CityResidency
extends RefCounted
## Which chunks the SIM holds (tile + cell maps stamped into the backend, densities for the
## spawner). A pure function of the focus point, evaluated once per fixed tick in a fixed order,
## so the sim stays deterministic however fast the disk or the workers are (SIM-05): a chunk
## enters when its rect comes within R_SIM of the focus, leaves beyond R_DROP. Chunks within
## R_PREFETCH are read ahead on workers (WLD-02 stage 1); if one is still missing when needed it
## is loaded synchronously. Drawing is separate (ChunkView, time-sliced).

const R_SIM: float = 190.0
const R_PREFETCH: float = 260.0
const R_DROP: float = 330.0

var stamped: int = 0
var dropped: int = 0
## Extra solid rects (world m) stamped as C_PROP into every chunk adopted: the arena's walls and
## cover on the city block, so the sim's thrown dead stop at the kerb barrier (n9 item 4).
var solids: Array[Rect2] = []
var _source: ChunkSource
var _sim: CitySimBackend
var _chunks: int = SimConst.CITY_CHUNKS
var _resident: Dictionary[Vector2i, CityChunk] = {}
## resident_keys(), sorted once a change (read only): ChunkView asks every frame, city_system,
## the prop lights and the noir lamps / shadows too; the lambda sort of ~70 keys cost ~0.1 ms.
var _keys: Array[Vector2i] = []
var _keys_stale: bool = true


func _init(source: ChunkSource, sim: CitySimBackend, city_chunks: int) -> void:
	_source = source
	_sim = sim
	_chunks = city_chunks


static func rect_dist(key: Vector2i, p: Vector2) -> float:
	var r: Rect2 = Rect2(Vector2(key) * SimConst.CHUNK_M, Vector2.ONE * SimConst.CHUNK_M)
	var q: Vector2 = Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
	return q.distance_to(p)


## Once per tick: drop far chunks, then stamp every needed one (nearest first, ties by key).
func update(focus: Vector2) -> void:
	for key: Vector2i in resident_keys():
		if rect_dist(key, focus) > R_DROP:
			_sim.clear_chunk(key.x, key.y)
			@warning_ignore("return_value_discarded")
			_resident.erase(key)
			_keys_stale = true
			dropped += 1
	var c0: Vector2i = Vector2i(
		floori(focus.x / SimConst.CHUNK_M), floori(focus.y / SimConst.CHUNK_M)
	)
	var reach: int = ceili(R_PREFETCH / SimConst.CHUNK_M)
	var need: Array[Vector2i] = []
	for dy: int in range(-reach, reach + 1):
		for dx: int in range(-reach, reach + 1):
			var key: Vector2i = c0 + Vector2i(dx, dy)
			if not _in_city(key) or _resident.has(key):
				continue
			var d: float = rect_dist(key, focus)
			if d < R_SIM:
				need.append(key)
			elif d < R_PREFETCH:
				_source.prefetch(key)
	need.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return _before(a, b, focus))
	for key: Vector2i in need:
		adopt(key, _source.take(key))


## Stamps one chunk into the sim (null = a corrupt file: it stays void and solid).
func adopt(key: Vector2i, chunk: CityChunk) -> void:
	if chunk == null:
		return
	_sim.stamp_chunk(key.x, key.y, chunk.tiles, with_solids(key, chunk.cells, solids))
	_resident[key] = chunk
	_keys_stale = true
	stamped += 1


## Forces one chunk out (a bench churn): the next update() stamps it again.
func evict(key: Vector2i) -> void:
	if _resident.has(key):
		_sim.clear_chunk(key.x, key.y)
		@warning_ignore("return_value_discarded")
		_resident.erase(key)
		_keys_stale = true
		dropped += 1


func is_resident(key: Vector2i) -> bool:
	return _resident.has(key)


func chunk_at(key: Vector2i) -> CityChunk:
	return _resident.get(key)


## The resident keys in row order (y, then x). Read only: the same array until residency changes.
func resident_keys() -> Array[Vector2i]:
	if _keys_stale:
		_keys = _sorted(_resident.keys())
		_keys.make_read_only()
		_keys_stale = false
	return _keys


func density(x: float, y: float, car: bool) -> int:
	var key: Vector2i = Vector2i(floori(x / SimConst.CHUNK_M), floori(y / SimConst.CHUNK_M))
	var c: CityChunk = _resident.get(key)
	return c.density(x, y, car) if c != null else 0


func _in_city(key: Vector2i) -> bool:
	return key.x >= 0 and key.y >= 0 and key.x < _chunks and key.y < _chunks


static func _before(a: Vector2i, b: Vector2i, focus: Vector2) -> bool:
	var da: float = rect_dist(a, focus)
	var db: float = rect_dist(b, focus)
	if da != db:
		return da < db
	return a.y < b.y or (a.y == b.y and a.x < b.x)


static func _sorted(keys: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	out.assign(keys)
	out.sort_custom(
		func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	return out


## `cells` of chunk `key` with every rect of `rects` (world m) stamped C_PROP (a copy).
static func with_solids(
	key: Vector2i, cells: PackedByteArray, rects: Array[Rect2]
) -> PackedByteArray:
	if rects.is_empty():
		return cells
	var out: PackedByteArray = cells.duplicate()
	var n: int = SimConst.CHUNK_CELLS
	for r: Rect2 in rects:
		var x0: int = maxi(floori(r.position.x) - key.x * n, 0)
		var y0: int = maxi(floori(r.position.y) - key.y * n, 0)
		for y: int in range(y0, mini(ceili(r.end.y) - key.y * n, n)):
			for x: int in range(x0, mini(ceili(r.end.x) - key.x * n, n)):
				out[y * n + x] = SimConst.C_PROP
	return out
