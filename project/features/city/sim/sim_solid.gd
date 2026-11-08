class_name CitySimSolid
extends RefCounted
## Circle (radius r) against solid 1 m cells (building, prop, unloaded): pushes the point (x, y)
## out of every solid cell it overlaps. Doubles throughout (no Vector2: that is float32).

var x: float = 0.0
var y: float = 0.0
var _s: CitySimState


func _init(state: CitySimState) -> void:
	_s = state


func push_out(r: float) -> void:
	var x0: int = floori(x - r)
	var x1: int = floori(x + r)
	var y0: int = floori(y - r)
	var y1: int = floori(y + r)
	for cy: int in range(y0, y1 + 1):
		for cx: int in range(x0, x1 + 1):
			if not _is_solid(cx, cy):
				continue
			var qxx: float = clampf(x, float(cx), float(cx) + 1.0)
			var qyy: float = clampf(y, float(cy), float(cy) + 1.0)
			var ddx: float = x - qxx
			var ddy: float = y - qyy
			var d2: float = ddx * ddx + ddy * ddy
			if d2 >= r * r:
				continue
			if d2 > 1e-12:
				var d: float = sqrt(d2)
				x += ddx / d * (r - d)
				y += ddy / d * (r - d)
			else:
				_eject(cx, cy, r)


## A dead body's slide along its blow (people.cpp ped, M_DEAD), op for op. n9 (the owner's s-5 B):
## the step that would overlap a wall or prop (push_out moves it) is not taken and the slide ends.
func slide_dead(i: int, dt: float) -> void:
	var px0: float = _s.px[i]
	var py0: float = _s.py[i]
	var vv: float = maxf(0.0, _s.v[i] - 8.0 * dt)
	var nx: float = px0 + _s.hx[i] * vv * dt
	var ny: float = py0 + _s.hy[i] * vv * dt
	if vv > 0.0:
		x = nx
		y = ny
		push_out(0.3)
		if x != nx or y != ny:
			vv = 0.0
			nx = px0
			ny = py0
	_s.v[i] = vv
	_s.px[i] = nx
	_s.py[i] = ny


func _is_solid(cx: int, cy: int) -> bool:
	var c: int = 0
	if cx >= 0 and cy >= 0 and cx < SimConst.W and cy < SimConst.W:
		c = _s.cells[cy * SimConst.W + cx]
	return c == 0 or c >= 4


## The centre is inside the cell: leave through the nearest side.
func _eject(cx: int, cy: int, r: float) -> void:
	var l: float = x - float(cx)
	var rr: float = float(cx) + 1.0 - x
	var u: float = y - float(cy)
	var dd: float = float(cy) + 1.0 - y
	var mm: float = minf(minf(l, rr), minf(u, dd))
	if mm == l:
		x = float(cx) - r
	elif mm == rr:
		x = float(cx) + 1.0 + r
	elif mm == u:
		y = float(cy) - r
	else:
		y = float(cy) + 1.0 + r
