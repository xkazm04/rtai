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
## in_rect's candidate list holds while the view stays inside its rect grown by this much (m).
const RECT_SLACK_M: float = 8.0

var _lift: ChunkLift = null
var _res: CityResidency = null
var _cache: Dictionary[int, Array] = {}
var _rect_at: Rect2 = Rect2()
var _rect_list: Array[Bld] = []
var _rect_rev: int = -1


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
		out.append(_with_area(b))


## The buildings whose drawn areas meet a screen rect (px), for the baked crowd (one query a frame,
## CityCrowdOcclusion). The candidates (the resident chunks' buildings under the rect grown by
## RECT_SLACK_M, and up to REACH_M south of it: a roof lifts north into view) are listed once and
## kept until the rect leaves the grown one or a chunk streams; each frame only their areas are
## taken at today's lift.
func in_rect(view_px: Rect2) -> Array[Bld]:
	var rev: int = _res.stamped + _res.dropped  # a chunk streamed in or out: list again
	if rev != _rect_rev or not _rect_at.encloses(view_px):
		_rect_rev = rev
		_rect_at = view_px.grow(RECT_SLACK_M * SimConst.PX_PER_M)
		_rect_list = _candidates(_rect_at)
	var out: Array[Bld] = []
	for b: Bld in _rect_list:
		if _with_area(b).area.intersects(view_px):
			out.append(b)
	return out


func _candidates(at_px: Rect2) -> Array[Bld]:
	var out: Array[Bld] = []
	var reach: Rect2 = at_px.grow_individual(0.0, 0.0, 0.0, REACH_M * SimConst.PX_PER_M)
	var lo: Vector2 = reach.position / SimConst.PX_PER_M / SimConst.CHUNK_M
	var hi: Vector2 = reach.end / SimConst.PX_PER_M / SimConst.CHUNK_M
	for x: int in range(floori(lo.x), floori(hi.x) + 1):
		for y: int in range(floori(lo.y), floori(hi.y) + 1):
			var key: Vector2i = Vector2i(x, y)
			if _res.is_resident(key):
				for b: Bld in of_chunk(_res.chunk_at(key)):
					if b.r.intersects(reach):
						out.append(b)
	return out


## b with its drawn area at today's lift (combo eases it).
func _with_area(b: Bld) -> Bld:
	var up: float = -_lift.lift_of(b.t).y
	b.area = Rect2(b.r.position - Vector2(0.0, up), b.r.size + Vector2(0.0, up))
	return b


## A chunk's buildings (not its shadow commands), scanned on first use and kept.
func of_chunk(chunk: CityChunk) -> Array[Bld]:
	var id: int = chunk.get_instance_id()
	if _cache.has(id):
		return _cache[id]
	if _cache.size() >= CACHE_MAX:
		_cache.clear()
		_rect_at = Rect2()  # the candidates came from the dropped lists: list them again
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
