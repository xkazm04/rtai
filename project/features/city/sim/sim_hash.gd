class_name CitySimHash
extends RefCounted
## Spatial hash over tier-A actors: HC-metre cells in an HW x HW window centred on the camera,
## rebuilt every step (counting sort, so a query returns ids in a fixed order).

var hcount: PackedInt32Array = SimArrays.i32(SimConst.HW * SimConst.HW, 0)
var hstart: PackedInt32Array = SimArrays.i32(SimConst.HW * SimConst.HW, 0)
var hitems: PackedInt32Array = SimArrays.i32(SimConst.CAP, 0)
var hgx: int = 0
var hgy: int = 0
var _touched: Array[int] = []  # cells occupied at the last build, first met first
var _s: CitySimState


func _init(state: CitySimState) -> void:
	_s = state


## O(actors), not O(HW^2) (t-5 widened the window): clears only the cells the last build filled,
## counts, then gives starts to the occupied cells in the order they were first met. Each cell's
## items are contiguous in id order; query walks cells row-major and reads each cell's own start, so
## the cells' order inside hitems never shows (no sort). An empty cell's start is never read.
func build(camx: float, camy: float) -> void:
	var hw: int = SimConst.HW
	hgx = floori(camx / SimConst.HC) - (hw >> 1)
	hgy = floori(camy / SimConst.HC) - (hw >> 1)
	for c: int in _touched:
		hcount[c] = 0
	_touched.clear()
	for i: int in SimConst.CAP:
		var c: int = _cell_of(i)
		if c >= 0:
			if hcount[c] == 0:
				_touched.append(c)
			hcount[c] += 1
	var s: int = 0
	for c: int in _touched:
		hstart[c] = s
		s += hcount[c]
		hcount[c] = 0
	for i: int in SimConst.CAP:
		var c: int = _cell_of(i)
		if c >= 0:
			hitems[hstart[c] + hcount[c]] = i
			hcount[c] += 1


## The actor ids in the (2r+1)^2 hash cells around a point, in a fixed order.
func query(x: float, y: float, r: int) -> Array[int]:
	var out: Array[int] = []
	var hw: int = SimConst.HW
	var gx: int = floori(x / SimConst.HC) - hgx
	var gy: int = floori(y / SimConst.HC) - hgy
	for cy: int in range(gy - r, gy + r + 1):
		if cy < 0 or cy >= hw:
			continue
		for cx: int in range(gx - r, gx + r + 1):
			if cx < 0 or cx >= hw:
				continue
			var c: int = cy * hw + cx
			var s: int = hstart[c]
			for k: int in hcount[c]:
				out.append(hitems[s + k])
	return out


func _cell_of(i: int) -> int:
	if _s.alive[i] == 0 or _s.tier[i] != 0:
		return -1
	var gx: int = floori(_s.px[i] / SimConst.HC) - hgx
	var gy: int = floori(_s.py[i] / SimConst.HC) - hgy
	if gx < 0 or gy < 0 or gx >= SimConst.HW or gy >= SimConst.HW:
		return -1
	return gy * SimConst.HW + gx
