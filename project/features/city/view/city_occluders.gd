class_name CityOccluders
extends RefCounted
## CityOcclusion's index of the lifted buildings around a body (n8 city): the resident chunks'
## buildings with their drawn areas (ground rect + the roof's lift above it). Each chunk's command
## list is scanned once and kept (the per-body, per-frame scan was CityOcclusion's whole cost on
## the tilt70 drive); the lift is read on every query, since `combo` eases it. Render only.

## Chunks whose building lists are kept (the resident set is 9-16); past it all are dropped.
const CACHE_MAX: int = 48
## A building farther than this (m) from the body on either axis is not looked at.
const REACH_M: float = 40.0

var _lift: ChunkLift = null
var _res: CityResidency = null
var _cache: Dictionary[int, Array] = {}


## A building on the ground (px): its texture, turn, ground centre and rect, drawn area.
class Bld:
	var t: int
	var rot: float
	var at: Vector2
	var r: Rect2
	var area: Rect2


func _init(lift: ChunkLift, res: CityResidency = null) -> void:
	_lift = lift
	_res = res


## The buildings of the resident chunks around a ground point (m), with their drawn areas.
func near(at_m: Vector2) -> Array[Bld]:
	var out: Array[Bld] = []
	var keys: Dictionary[Vector2i, bool] = {}
	for d: Vector2 in [Vector2(-16, -4), Vector2(16, -4), Vector2(-16, 28), Vector2(16, 28)]:
		var p: Vector2 = (at_m + d) / SimConst.CHUNK_M
		keys[Vector2i(floori(p.x), floori(p.y))] = true
	for key: Vector2i in keys:
		var chunk: CityChunk = _res.chunk_at(key) if _res.is_resident(key) else null
		if chunk != null:
			collect(chunk, at_m * SimConst.PX_PER_M, out)
	return out


## Appends chunk's buildings within REACH_M of near_px, their drawn areas at today's lift.
func collect(chunk: CityChunk, near_px: Vector2, out: Array[Bld]) -> void:
	var reach: float = REACH_M * SimConst.PX_PER_M
	for b: Bld in of_chunk(chunk):
		if absf(b.at.x - near_px.x) > reach or absf(b.at.y - near_px.y) > reach:
			continue
		var up: float = -_lift.lift_of(b.t).y
		b.area = Rect2(b.r.position - Vector2(0.0, up), b.r.size + Vector2(0.0, up))
		out.append(b)


## A chunk's buildings (not its shadow commands), scanned on first use and kept.
func of_chunk(chunk: CityChunk) -> Array[Bld]:
	var id: int = chunk.get_instance_id()
	if _cache.has(id):
		return _cache[id]
	if _cache.size() >= CACHE_MAX:
		_cache.clear()
	var list: Array[Bld] = []
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if not _lift.is_building_tex(t) or chunk.xf[o + 3] > 0.5:
			continue
		var b: Bld = Bld.new()
		b.t = t
		b.rot = chunk.xf[o + 2]
		b.at = Vector2(chunk.xf[o], chunk.xf[o + 1]) * SimConst.PX_PER_M
		var ext: Vector2 = _lift.extent(t, b.rot)
		b.r = Rect2(b.at - ext * 0.5, ext)
		list.append(b)
	_cache[id] = list
	return list


## Cached chunks (for the tests and the probe).
func cached() -> int:
	return _cache.size()
