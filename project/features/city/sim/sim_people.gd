class_name CitySimPeople
extends RefCounted
## Pedestrians, rioters and cops of the reference sim. Operation order matches native/sim_core
## exactly (parity). Scratch members (_dx, _dy, _spd, _x, _y) carry the per-actor working values.

var _s: CitySimState
var _h: CitySimHash
var _solid: CitySimSolid
var _flow: CitySimFlow
var _body: CitySimBody
var _dx: float = 0.0
var _dy: float = 0.0
var _spd: float = 0.0
var _x: float = 0.0
var _y: float = 0.0


func _init(
	state: CitySimState, hash_grid: CitySimHash, flow: CitySimFlow, body: CitySimBody
) -> void:
	_s = state
	_h = hash_grid
	_flow = flow
	_body = body
	_solid = CitySimSolid.new(state)


func ped(i: int, dt: float) -> void:
	var x: float = _s.px[i]
	var y: float = _s.py[i]
	var m: int = _s.mode[i]
	if m == SimConst.M_DEAD:
		var vv: float = maxf(0.0, _s.v[i] - 8.0 * dt)
		_s.v[i] = vv
		_s.px[i] = x + _s.hx[i] * vv * dt
		_s.py[i] = y + _s.hy[i] * vv * dt
		return
	if m == SimConst.M_DOWN:
		_body.down(i, dt)
		return
	_dx = _s.hx[i]
	_dy = _s.hy[i]
	_spd = 0.0
	if m == SimConst.M_FLEE:
		_flee(i, x, y, dt)
	elif m == SimConst.M_RIOT:
		_riot(i, x, y, dt)
	else:
		_walk(i, x, y)
	_move(i, x, y, dt)


func cop(i: int, dt: float, tgx: float, tgy: float) -> void:
	var x: float = _s.px[i]
	var y: float = _s.py[i]
	if _s.mode[i] == SimConst.M_DEAD:
		return
	if _s.mode[i] == SimConst.M_DOWN:
		_body.down(i, dt)
		return
	var ax: float = tgx - x
	var ay: float = tgy - y
	var d: float = sqrt(ax * ax + ay * ay)
	_dx = _s.hx[i]
	_dy = _s.hy[i]
	if d > 0.001:
		_dx = ax / d
		_dy = ay / d
	# move along the flow field (WLD-09); aim and shoot straight at the target
	var mx: float = _dx
	var my: float = _dy
	if d > SimConst.FF_NEAR_M and _flow.dir(x, y):
		mx = _flow.dx
		my = _flow.dy
	_spd = 3.4 if d > 7.0 else 0.0
	_s.t2[i] -= dt
	_s.t1[i] -= dt
	if d < 20.0 and _s.t2[i] <= 0.0:
		var sp: float = (_s.rnd() - 0.5) * 0.16
		var fx: float = _dx - _dy * sp
		var fy: float = _dy + _dx * sp
		var l: float = sqrt(fx * fx + fy * fy)
		_s.fire(x + fx / l * 0.8, y + fy / l * 0.8, fx / l * 38.0, fy / l * 38.0, 1.5)
		_s.t2[i] = 0.8 + _s.rnd() * 1.6
		_s.t1[i] = 0.25
	_dx = mx
	_dy = my
	_move(i, x, y, dt)


func _flee(i: int, x: float, y: float, dt: float) -> void:
	_s.t1[i] -= dt
	var ax: float = x - _s.sx[i]
	var ay: float = y - _s.sy[i]
	var l: float = sqrt(ax * ax + ay * ay)
	if l > 0.001:
		_dx = ax / l
		_dy = ay / l
	_spd = 4.5
	if _s.cell_at(x + _dx, y + _dy) >= 4 or _s.cell_at(x + _dx, y + _dy) == 0:
		var nx: float = -_dy
		var ny: float = _dx
		_dx = nx
		_dy = ny
	if _s.t1[i] > 0.0:
		return
	if (_s.flags[i] & SimConst.F_RIOTER) != 0:
		_s.mode[i] = SimConst.M_RIOT
		return
	_s.mode[i] = SimConst.M_WALK
	if absf(_dx) >= absf(_dy):
		_dx = 1.0 if _dx >= 0.0 else -1.0
		_dy = 0.0
	else:
		_dy = 1.0 if _dy >= 0.0 else -1.0
		_dx = 0.0


func _riot(i: int, x: float, y: float, dt: float) -> void:
	_s.t1[i] -= dt
	if _s.t1[i] <= 0.0:
		var k: int = int(_s.rnd() * 16.0)
		_dx = _s.dir16x[k]
		_dy = _s.dir16y[k]
		_s.t1[i] = 1.0 + _s.rnd() * 2.0
	var ax: float = _s.sx[i] - x
	var ay: float = _s.sy[i] - y
	var d2: float = ax * ax + ay * ay
	if d2 > _s.riot_r * _s.riot_r:
		var l: float = sqrt(d2)
		_dx = ax / l
		_dy = ay / l
	_spd = 2.6


func _walk(i: int, x: float, y: float) -> void:
	_spd = _s.vmax[i]
	var c: int = _s.cell_at(x + _dx, y + _dy)
	if c == SimConst.C_WALK:
		_s.flags[i] = _s.flags[i] & ~SimConst.F_CROSSING
		return
	var crossing: bool = (_s.flags[i] & SimConst.F_CROSSING) != 0
	if (c == SimConst.C_LANE or c == SimConst.C_PARK) and (crossing or _s.rnd() < 0.04):
		_s.flags[i] = _s.flags[i] | SimConst.F_CROSSING
		return
	_s.flags[i] = _s.flags[i] & ~SimConst.F_CROSSING
	var ax: float = -_dy
	var ay: float = _dx
	var bx: float = _dy
	var by: float = -_dx
	if _s.rnd() >= 0.5:
		ax = _dy
		ay = -_dx
		bx = -_dy
		by = _dx
	if _s.cell_at(x + ax, y + ay) == SimConst.C_WALK:
		_dx = ax
		_dy = ay
	elif _s.cell_at(x + bx, y + by) == SimConst.C_WALK:
		_dx = bx
		_dy = by
	elif _s.cell_at(x - _dx, y - _dy) == SimConst.C_WALK:
		_dx = -_dx
		_dy = -_dy
	else:
		_spd = 0.0


## Integrate, then (tier A only) separate from people and push out of solid cells.
func _move(i: int, x0: float, y0: float, dt: float) -> void:
	_x = x0 + _dx * _spd * dt
	_y = y0 + _dy * _spd * dt
	if _s.tier[i] == 0:
		_crowd(i)
		_body.x = _x
		_body.y = _y
		_body.push(i, _dx * _spd, _dy * _spd)
		_solid.x = _body.x
		_solid.y = _body.y
		_solid.push_out(0.3)
		_x = _solid.x
		_y = _solid.y
	_s.px[i] = _x
	_s.py[i] = _y
	if _s.mode[i] == SimConst.M_DOWN:
		return  # tackled this step (CitySimBody.push)
	_s.hx[i] = _dx
	_s.hy[i] = _dy
	_s.v[i] = _spd
	_s.phase[i] += _spd * dt


## Separation from other live people in the 3x3 hash cells (works on _x, _y).
func _crowd(i: int) -> void:
	for j: int in _h.query(_x, _y, 1):
		if j == i:
			continue
		var kj: int = _s.kind[j]
		if (kj != SimConst.K_PED and kj != SimConst.K_COP) or _s.mode[j] == SimConst.M_DEAD:
			continue
		var ddx: float = _x - _s.px[j]
		var ddy: float = _y - _s.py[j]
		var d2: float = ddx * ddx + ddy * ddy
		if d2 < 0.49 and d2 > 1e-9:
			var d: float = sqrt(d2)
			var push: float = (0.7 - d) * 0.5
			_x += ddx / d * push
			_y += ddy / d * push
