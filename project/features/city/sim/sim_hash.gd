class_name CitySimHash
extends RefCounted
## Spatial hash over tier-A actors: HC-metre cells in an HW x HW window centred on the camera,
## rebuilt every step (counting sort, so a query returns ids in a fixed order).

var hcount: PackedInt32Array = SimArrays.i32(SimConst.HW * SimConst.HW + 1, 0)
var hstart: PackedInt32Array = SimArrays.i32(SimConst.HW * SimConst.HW + 1, 0)
var hitems: PackedInt32Array = SimArrays.i32(SimConst.CAP, 0)
var hgx: int = 0
var hgy: int = 0
var _s: CitySimState


func _init(state: CitySimState) -> void:
	_s = state


func build(camx: float, camy: float) -> void:
	var hw: int = SimConst.HW
	hgx = floori(camx / SimConst.HC) - (hw >> 1)
	hgy = floori(camy / SimConst.HC) - (hw >> 1)
	hcount.fill(0)
	for i: int in SimConst.CAP:
		var c: int = _cell_of(i)
		if c >= 0:
			hcount[c] += 1
	var s: int = 0
	for c: int in hw * hw:
		hstart[c] = s
		s += hcount[c]
		hcount[c] = 0
	hstart[hw * hw] = s
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
