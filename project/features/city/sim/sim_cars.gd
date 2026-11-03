class_name CitySimCars
extends RefCounted
## Traffic and police cars of the reference sim: route (CitySimCarRoute), steer toward a point
## 6 m ahead on the lane, follow the car or person ahead, then in tier A resolve contacts (run
## people over or shove them, push cars apart) and push the hull out of solid cells.

var _s: CitySimState
var _h: CitySimHash
var _r: CitySimCarRoute
var _x: float = 0.0
var _y: float = 0.0
var _hx: float = 0.0
var _hy: float = 0.0
var _vv: float = 0.0


func _init(state: CitySimState, hash_grid: CitySimHash, flow: CitySimFlow) -> void:
	_s = state
	_h = hash_grid
	_r = CitySimCarRoute.new(state, flow)


func car(i: int, dt: float, tgx: float, tgy: float) -> void:
	var x: float = _s.px[i]
	var y: float = _s.py[i]
	_r.begin(i)
	if _s.ndir[i] < 0:
		_r.plan(i, x, y, tgx, tgy)
	if _s.ndir[i] >= 0:
		_r.turn(i, x, y)
	var waiting: bool = false
	if _s.ndir[i] >= 0 and _s.tier[i] == 0 and _s.res[i] < 0:
		waiting = _r.reserve(i)
	_steer(i, x, y, dt)
	_vv = _accelerate(_s.v[i], _desired_speed(i, x, y, waiting), dt)
	_x = x + _hx * _vv * dt
	_y = y + _hy * _vv * dt
	if _s.tier[i] == 0:
		_contacts(i)
		_hull()
	_finish(i, dt, waiting)


func _steer(i: int, x: float, y: float, dt: float) -> void:
	var tx: float = 0.0
	var ty: float = 0.0
	if _r.d == 0 or _r.d == 2:
		tx = x + _r.ddx * 6.0
		ty = _s.lane[i]
	else:
		tx = _s.lane[i]
		ty = y + _r.ddy * 6.0
	var ax: float = tx - x
	var ay: float = ty - y
	var l: float = sqrt(ax * ax + ay * ay)
	_hx = _s.hx[i]
	_hy = _s.hy[i]
	if l > 1e-6:
		var kk: float = minf(1.0, (1.5 + _s.v[i] * 0.25) * dt)
		_hx += (ax / l - _hx) * kk
		_hy += (ay / l - _hy) * kk
		var hl: float = sqrt(_hx * _hx + _hy * _hy)
		_hx /= hl
		_hy /= hl


func _desired_speed(i: int, x: float, y: float, waiting: bool) -> float:
	var vdes: float = _s.vmax[i]
	if _s.ndir[i] >= 0 and _s.ndir[i] != _r.d:
		vdes = minf(vdes, 7.0)
	if waiting:
		var along2: float = x * _r.ddx + y * _r.ddy
		var dist: float = (_s.jx[i] * _r.ddx + _s.jy[i] * _r.ddy) - along2 - 14.0
		vdes = minf(vdes, maxf(0.0, dist))
	if _s.tier[i] != 0 or _s.kind[i] == SimConst.K_PCAR:
		return vdes
	for j: int in _h.query(x + _hx * 7.0, y + _hy * 7.0, 1):
		if j == i:
			continue
		var rx: float = _s.px[j] - x
		var ry: float = _s.py[j] - y
		var f: float = rx * _hx + ry * _hy
		var s: float = absf(rx * _hy - ry * _hx)
		var kj: int = _s.kind[j]
		if kj == SimConst.K_CAR or kj == SimConst.K_PCAR:
			if f > 0.0 and f < 12.0 and s < 1.8:
				vdes = minf(vdes, maxf(0.0, f - 5.5) * 1.4)
		elif _s.mode[j] != SimConst.M_DEAD:
			if f > 0.0 and f < 7.0 and s < 1.6:
				vdes = minf(vdes, maxf(0.0, f - 3.0) * 1.5)
	for k: int in range(0, _s.obst.size(), 2):
		var ox: float = _s.obst[k] - x
		var oy: float = _s.obst[k + 1] - y
		var of: float = ox * _hx + oy * _hy
		if of > 0.0 and of < 12.0 and absf(ox * _hy - oy * _hx) < 1.8:
			vdes = minf(vdes, maxf(0.0, of - 5.5) * 1.4)
	return vdes


static func _accelerate(vv: float, vdes: float, dt: float) -> float:
	if vv < vdes:
		return minf(vdes, vv + 6.0 * dt)
	return maxf(vdes, vv - 14.0 * dt)


func _contacts(i: int) -> void:
	for j: int in _h.query(_x, _y, 1):
		if j == i or _s.alive[j] == 0:
			continue
		var kj: int = _s.kind[j]
		var rx: float = _s.px[j] - _x
		var ry: float = _s.py[j] - _y
		if kj == SimConst.K_PED or kj == SimConst.K_COP:
			if _s.mode[j] != SimConst.M_DEAD:
				_hit_person(j, rx, ry)
			continue
		var d2: float = rx * rx + ry * ry
		if d2 < 4.84 and d2 > 1e-9:
			var dd: float = sqrt(d2)
			var push: float = (2.2 - dd) * 0.5
			_x -= rx / dd * push
			_y -= ry / dd * push
			_s.px[j] += rx / dd * push
			_s.py[j] += ry / dd * push
			_vv *= 0.9


## A person inside the car's footprint: killed above 4 m/s, else shoved sideways.
func _hit_person(j: int, rx: float, ry: float) -> void:
	var f: float = rx * _hx + ry * _hy
	var s: float = -rx * _hy + ry * _hx
	if absf(f) >= 2.6 or absf(s) >= 1.3:
		return
	if _vv > 4.0:
		_s.mode[j] = SimConst.M_DEAD
		_s.t2[j] = 0.0
		_s.v[j] = _vv * 0.5
		_s.hx[j] = _hx
		_s.hy[j] = _hy
		_s.counters[SimConst.CN_KILLED] += 1
		return
	var sg: float = 1.0 if s >= 0.0 else -1.0
	var push: float = 1.35 - absf(s)
	_s.px[j] += -_hy * sg * push
	_s.py[j] += _hx * sg * push


## Six hull sample points against solid cells: push out along the shallowest axis.
func _hull() -> void:
	for p: int in 6:
		var f: float = 2.3 if p < 2 else (-2.3 if p < 4 else 0.0)
		var s: float = 0.95 if (p % 2) == 0 else -0.95
		var qxx: float = _x + _hx * f - _hy * s
		var qyy: float = _y + _hy * f + _hx * s
		var ix: int = floori(qxx)
		var iy: int = floori(qyy)
		var c: int = 0
		if ix >= 0 and iy >= 0 and ix < SimConst.W and iy < SimConst.W:
			c = _s.cells[iy * SimConst.W + ix]
		if c != 0 and c < 4:
			continue
		var lft: float = qxx - float(ix)
		var rgt: float = float(ix) + 1.0 - qxx
		var up: float = qyy - float(iy)
		var dn: float = float(iy) + 1.0 - qyy
		var mm: float = minf(minf(lft, rgt), minf(up, dn))
		if mm == lft:
			_x -= lft + 0.01
		elif mm == rgt:
			_x += rgt + 0.01
		elif mm == up:
			_y -= up + 0.01
		else:
			_y += dn + 0.01
		_vv *= 0.7


func _finish(i: int, dt: float, waiting: bool) -> void:
	if _vv < 0.3 and not waiting:
		_s.stuck[i] += dt
	else:
		_s.stuck[i] = 0.0
	_s.px[i] = _x
	_s.py[i] = _y
	_s.hx[i] = _hx
	_s.hy[i] = _hy
	_s.v[i] = _vv
	_s.phase[i] += _vv * dt
	var stuck: float = _s.stuck[i]
	if (stuck > 8.0 and _s.tier[i] == 1) or stuck > 20.0:
		if (_s.flags[i] & SimConst.F_PROMOTED) == 0:
			_s.kill(i)
