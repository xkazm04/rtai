class_name CitySimFlow
extends RefCounted
## Police flow field of the reference sim (WLD-09), identical to native/sim_core/src/flow.cpp:
## one integer BFS toward the pursuit target over the 1 m cells in an FF_W x FF_W window centred
## on the target cell. Neighbour order E S W N for the BFS, E S W N SE SW NW NE for the descent,
## first strict minimum wins; diagonals only when both sides are open. Recomputed at most every
## FF_EVERY ticks, only when the target cell or the map changed and police are alive.

const NX: Array[int] = [1, 0, -1, 0, 1, -1, -1, 1]
const NY: Array[int] = [0, 1, 0, -1, 1, 1, -1, -1]

## The step flow_dir() found (a unit vector).
var dx: float = 0.0
var dy: float = 0.0
var stats: PackedInt32Array = SimArrays.i32(SimConst.FS_LEN, 0)
var _s: CitySimState
var _dist: PackedInt32Array = SimArrays.i32(SimConst.FF_W * SimConst.FF_W, SimConst.FF_UNREACHED)
var _queue: PackedInt32Array = SimArrays.i32(SimConst.FF_W * SimConst.FF_W, 0)
var _ox: int = 0
var _oy: int = 0
var _tx: int = 0
var _ty: int = 0
var _valid: bool = false
var _map_version: int = 0
var _ticks: int = 0


func _init(state: CitySimState) -> void:
	_s = state


func reset() -> void:
	_dist.fill(SimConst.FF_UNREACHED)
	_valid = false
	_ox = 0
	_oy = 0
	_tx = 0
	_ty = 0
	_map_version = 0
	_ticks = 0
	stats.fill(0)


func update(tgx: float, tgy: float) -> void:
	var tx: int = floori(tgx)
	var ty: int = floori(tgy)
	var due: bool = (_ticks % SimConst.FF_EVERY) == 0
	_ticks += 1
	if not due or not _police_alive():
		return
	if _valid and tx == _tx and ty == _ty and _s.map_version == _map_version:
		return
	var t0: int = Time.get_ticks_usec()
	_build(tx, ty)
	stats[SimConst.FS_COMPUTES] += 1
	stats[SimConst.FS_LAST_US] = Time.get_ticks_usec() - t0
	stats[SimConst.FS_MAX_US] = maxi(stats[SimConst.FS_MAX_US], stats[SimConst.FS_LAST_US])


## Distance in cells from (x, y) to the target, or -1 (outside the window, unreached, none).
func dist(x: float, y: float) -> int:
	if not _valid:
		return -1
	return _local(floori(x) - _ox, floori(y) - _oy)


## Sets dx, dy to the downhill unit step from (x, y); false when there is none.
func dir(x: float, y: float) -> bool:
	var here: int = dist(x, y)
	if here <= 0:
		return false
	var lx: int = floori(x) - _ox
	var ly: int = floori(y) - _oy
	var best: int = here
	var pick: int = -1
	for n: int in 8:
		var d: int = _local(lx + NX[n], ly + NY[n])
		if d < 0:
			continue
		if n >= 4 and (_local(lx + NX[n], ly) < 0 or _local(lx, ly + NY[n]) < 0):
			continue
		if d < best:
			best = d
			pick = n
	if pick < 0:
		return false
	var ix: float = NX[pick]
	var iy: float = NY[pick]
	var l: float = sqrt(ix * ix + iy * iy)
	dx = ix / l
	dy = iy / l
	return true


func _build(tx: int, ty: int) -> void:
	var w: int = SimConst.FF_W
	var half: int = w >> 1
	_tx = tx
	_ty = ty
	_ox = tx - half
	_oy = ty - half
	_map_version = _s.map_version
	_valid = true
	_dist.fill(SimConst.FF_UNREACHED)
	var head: int = 0
	var tail: int = 0
	if _walkable(tx, ty):
		_dist[half * w + half] = 0
		_queue[0] = half * w + half
		tail = 1
	while head < tail:
		var c: int = _queue[head]
		head += 1
		var lx: int = c % w
		var ly: int = floori(float(c) / w)
		var nd: int = _dist[c] + 1
		for n: int in 4:
			var ax: int = lx + NX[n]
			var ay: int = ly + NY[n]
			if ax < 0 or ay < 0 or ax >= w or ay >= w:
				continue
			var a: int = ay * w + ax
			if _dist[a] != SimConst.FF_UNREACHED or not _walkable(_ox + ax, _oy + ay):
				continue
			_dist[a] = nd
			_queue[tail] = a
			tail += 1
	stats[SimConst.FS_REACHED] = tail


func _local(lx: int, ly: int) -> int:
	if lx < 0 or ly < 0 or lx >= SimConst.FF_W or ly >= SimConst.FF_W:
		return -1
	var d: int = _dist[ly * SimConst.FF_W + lx]
	return -1 if d == SimConst.FF_UNREACHED else d


func _walkable(gx: int, gy: int) -> bool:
	if gx < 0 or gy < 0 or gx >= SimConst.W or gy >= SimConst.W:
		return false
	var c: int = _s.cells[gy * SimConst.W + gx]
	return c >= SimConst.C_LANE and c <= SimConst.C_WALK


func _police_alive() -> bool:
	for i: int in SimConst.CAP:
		var k: int = _s.kind[i]
		if _s.alive[i] != 0 and (k == SimConst.K_COP or k == SimConst.K_PCAR):
			return true
	return false
