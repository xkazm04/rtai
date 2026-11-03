class_name CitySimShots
extends RefCounted
## Projectiles of the reference sim: two half-steps per tick, stopped by solid cells, killing the
## first live pedestrian within 0.45 m, which scares the peds within 9 m into fleeing.

var _s: CitySimState
var _h: CitySimHash


func _init(state: CitySimState, hash_grid: CitySimHash) -> void:
	_s = state
	_h = hash_grid


func step(dt: float) -> void:
	var half: float = dt * 0.5
	for k: int in SimConst.PCAP:
		if _s.qalive[k] == 0:
			continue
		_s.qt[k] -= dt
		if _s.qt[k] <= 0.0:
			_s.qalive[k] = 0
			continue
		var x: float = _s.qx[k]
		var y: float = _s.qy[k]
		for sub: int in 2:
			x += _s.qvx[k] * half
			y += _s.qvy[k] * half
			if _blocked_or_hit(k, x, y):
				break
		_s.qx[k] = x
		_s.qy[k] = y


## True when the projectile stopped at (x, y): a wall, or a hit.
func _blocked_or_hit(k: int, x: float, y: float) -> bool:
	var c: int = _s.cell_at(x, y)
	if c == 0 or c >= 4:
		_s.qalive[k] = 0
		return true
	var hit: int = -1
	for j: int in _h.query(x, y, 1):
		if _s.kind[j] != SimConst.K_PED or _s.mode[j] == SimConst.M_DEAD:
			continue
		var rx: float = _s.px[j] - x
		var ry: float = _s.py[j] - y
		if rx * rx + ry * ry < 0.2025:
			hit = j
			break
	if hit < 0:
		return false
	var l: float = sqrt(_s.qvx[k] * _s.qvx[k] + _s.qvy[k] * _s.qvy[k])
	_s.mode[hit] = SimConst.M_DEAD
	_s.t2[hit] = 0.0
	_s.v[hit] = 3.0
	_s.hx[hit] = _s.qvx[k] / l
	_s.hy[hit] = _s.qvy[k] / l
	_s.counters[SimConst.CN_KILLED] += 1
	_scare(x, y)
	_s.qalive[k] = 0
	return true


func _scare(x: float, y: float) -> void:
	for j: int in _h.query(x, y, 2):
		if _s.kind[j] != SimConst.K_PED or _s.mode[j] == SimConst.M_DEAD:
			continue
		if _s.mode[j] == SimConst.M_DOWN:
			continue
		var rx: float = _s.px[j] - x
		var ry: float = _s.py[j] - y
		if rx * rx + ry * ry < 81.0:
			_s.mode[j] = SimConst.M_FLEE
			_s.t1[j] = 2.5 + _s.rnd() * 2.0
			_s.sx[j] = x
			_s.sy[j] = y
