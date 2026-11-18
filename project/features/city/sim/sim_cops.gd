class_name CitySimCops
extends RefCounted
## Foot cops of the reference sim, op for op native people.cpp cop() and police.cpp (parity).
## Heat -1 (the default): every cop pursues the step's target on the flow field (WLD-09), straight
## only near and in sight on the cell map (n18 item 1), and fires inside 20 m. Heat 0-3 (n18
## living police, CitySimPolice): a free cop walks his sidewalk; an engaged one goes to the
## last-seen point, searches there, and steers at and fires on Rivet only with him in sight.
## CitySimPeople integrates the step.

var _s: CitySimState
var _flow: CitySimFlow
var _police: CitySimPolice
## Scratch step (doubles: Vector2/3 are float32 and would break parity).
var _mx: float = 0.0
var _my: float = 0.0
var _spd: float = 0.0


func _init(state: CitySimState, flow: CitySimFlow, police: CitySimPolice) -> void:
	_s = state
	_flow = flow
	_police = police


## One live, standing cop's step (CityCore::cop after its dead/down checks).
func step(people: CitySimPeople, i: int, dt: float, tgx: float, tgy: float) -> void:
	if _police.level >= 0:
		if (_s.flags[i] & SimConst.F_ENGAGED) == 0:
			_walk(people, i, dt)
		else:
			_engaged(people, i, dt, tgx, tgy)
		return
	var x: float = _s.px[i]
	var y: float = _s.py[i]
	var ax: float = tgx - x
	var ay: float = tgy - y
	var d: float = sqrt(ax * ax + ay * ay)
	var dx: float = _s.hx[i]
	var dy: float = _s.hy[i]
	if d > 0.001:
		dx = ax / d
		dy = ay / d
	# flow field (WLD-09) unless near and in sight on the cell map (n18); aim and shoot straight
	_mx = dx
	_my = dy
	var see: bool = d <= SimConst.FF_NEAR_M and _flow.sight(x, y, tgx, tgy)
	if not see and _flow.dir(x, y):
		_mx = _flow.dx
		_my = _flow.dy
	_spd = 3.4 if (d > 7.0 or not see) else 0.0
	_s.t2[i] -= dt
	_s.t1[i] -= dt
	if d < 20.0 and _s.t2[i] <= 0.0:
		_shoot(i, x, y, dx, dy)
	people.cop_move(i, _mx, _my, _spd, dt)


## n18: an engaged cop (CityCore::cop_heat).
func _engaged(people: CitySimPeople, i: int, dt: float, tgx: float, tgy: float) -> void:
	var x: float = _s.px[i]
	var y: float = _s.py[i]
	var rx: float = tgx - x
	var ry: float = tgy - y
	var dr: float = sqrt(rx * rx + ry * ry)
	var ax: float = _s.hx[i]
	var ay: float = _s.hy[i]
	if dr > 0.001:
		ax = rx / dr
		ay = ry / dr
	_mx = ax
	_my = ay
	_spd = 0.0
	if dr <= SimConst.FF_NEAR_M and _flow.sight(x, y, tgx, tgy):
		_spd = 3.4 if dr > 7.0 else 0.0
	else:
		_to_point(i, x, y)
	_s.t2[i] -= dt
	_s.t1[i] -= dt
	if dr < 20.0 and _s.t2[i] <= 0.0 and _flow.sight(x, y, tgx, tgy):
		_shoot(i, x, y, ax, ay)
	people.cop_move(i, _mx, _my, _spd, dt)


## n18: a free cop (CityCore::cop_walk): a diagonal heading snaps to its main axis, off the
## sidewalk he keeps crossing, then the pedestrians' walk at PT_WALK_V.
func _walk(people: CitySimPeople, i: int, dt: float) -> void:
	_s.t2[i] -= dt
	_s.t1[i] -= dt
	var dx: float = _s.hx[i]
	var dy: float = _s.hy[i]
	if dx != 0.0 and dy != 0.0:
		if absf(dx) >= absf(dy):
			dx = 1.0 if dx >= 0.0 else -1.0
			dy = 0.0
		else:
			dy = 1.0 if dy >= 0.0 else -1.0
			dx = 0.0
	if _s.cell_at(_s.px[i], _s.py[i]) != SimConst.C_WALK:
		_s.flags[i] = _s.flags[i] | SimConst.F_CROSSING
	people.cop_walk(i, dx, dy, _police.tune[SimConst.PT_WALK_V], dt)


## Search amble near the point (CityCore::cop_search), else the flow field to it (_mx _my _spd).
func _to_point(i: int, x: float, y: float) -> void:
	var gx: float = x - _police.heat_x
	var gy: float = y - _police.heat_y
	var r: float = _police.tune[SimConst.PT_ARRIVE_M]
	if gx * gx + gy * gy <= r * r:
		var k: int = (floori(_s.time / SimConst.POL_SEARCH_TURN_S) * 5 + i) & 15
		_mx = _s.dir16x[k]
		_my = _s.dir16y[k]
		_spd = SimConst.POL_SEARCH_V
		return
	gx = _police.heat_x - x
	gy = _police.heat_y - y
	var dg: float = sqrt(gx * gx + gy * gy)
	if dg > 0.001:
		_mx = gx / dg
		_my = gy / dg
	if _flow.dir(x, y):
		_mx = _flow.dx
		_my = _flow.dy
	_spd = 3.4


## One round along (ax, ay) with a small spread; the cooldown and the muzzle timer restart.
func _shoot(i: int, x: float, y: float, ax: float, ay: float) -> void:
	var sp: float = (_s.rnd() - 0.5) * 0.16
	var fx: float = ax - ay * sp
	var fy: float = ay + ax * sp
	var l: float = sqrt(fx * fx + fy * fy)
	_s.fire(x + fx / l * 0.8, y + fy / l * 0.8, fx / l * 38.0, fy / l * 38.0, 1.5)
	_s.t2[i] = 0.8 + _s.rnd() * 1.6
	_s.t1[i] = 0.25
