class_name CitySimCarPass
extends RefCounted
## Passing a stopped service car (twin of native car_pass.cpp; parity stays exact). A tier-A
## traffic car that has stood behind an obstacle (set_obstacles) in its own lane for PASS_WAIT_S,
## mid-block, with the oncoming lane clear, steers into the oncoming lane until every obstacle is
## PASS_BACK_M behind it. lane_line() returns the lane line the car steers to this step.

const PASS_WAIT_S: float = 2.5  # standing behind the obstacle before pulling out
const PASS_ABORT_S: float = 6.0  # standing while passing: give up, back to the own lane
const PASS_BACK_M: float = 7.0  # obstacles this far behind: the pass is over

var _s: CitySimState
var _h: CitySimHash


func _init(state: CitySimState, hash_grid: CitySimHash) -> void:
	_s = state
	_h = hash_grid


func lane_line(i: int, x: float, y: float, r: CitySimCarRoute) -> float:
	var own: float = _s.lane[i]
	if _s.kind[i] == SimConst.K_PCAR or _s.tier[i] != 0:
		_s.flags[i] = _s.flags[i] & ~SimConst.F_PASSING
		return own
	var other: float = own - 2.0 * CitySimState.LANE_OFF[r.d]
	var passing: bool = (_s.flags[i] & SimConst.F_PASSING) != 0
	if passing:
		if _s.stuck[i] > PASS_ABORT_S or not _obst_in([x, y, own, -PASS_BACK_M, 14.0], r):
			_s.flags[i] = _s.flags[i] & ~SimConst.F_PASSING
			passing = false
	elif (
		_s.stuck[i] > PASS_WAIT_S
		and _s.ndir[i] < 0
		and _obst_in([x, y, own, 0.0, 12.0], r)
		and not _obst_in([x, y, other, -6.0, 20.0], r)
		and _lane_clear(i, x, y, other, r)
	):
		_s.flags[i] = _s.flags[i] | SimConst.F_PASSING
		passing = true
	return other if passing else own


## An obstacle point within (a, b) metres along the car's direction and 1.8 m of lane line ln.
## p = [x, y, ln, a, b].
func _obst_in(p: Array[float], r: CitySimCarRoute) -> bool:
	var horiz: bool = r.d == 0 or r.d == 2
	for k: int in range(0, _s.obst.size(), 2):
		var ox: float = _s.obst[k]
		var oy: float = _s.obst[k + 1]
		var along: float = (ox - p[0]) * r.ddx + (oy - p[1]) * r.ddy
		var lat: float = absf((oy if horiz else ox) - p[2])
		if along > p[3] and along < p[4] and lat < 1.8:
			return true
	return false


## No live car on lane line ln from 8 m behind to 36 m ahead of car i.
func _lane_clear(i: int, x: float, y: float, ln: float, r: CitySimCarRoute) -> bool:
	var horiz: bool = r.d == 0 or r.d == 2
	var qx: float = x + r.ddx * 16.0 if horiz else ln
	var qy: float = ln if horiz else y + r.ddy * 16.0
	for j: int in _h.query(qx, qy, 6):
		if j == i or _s.alive[j] == 0:
			continue
		if _s.kind[j] != SimConst.K_CAR and _s.kind[j] != SimConst.K_PCAR:
			continue
		var along: float = (_s.px[j] - x) * r.ddx + (_s.py[j] - y) * r.ddy
		var lat: float = absf((_s.py[j] if horiz else _s.px[j]) - ln)
		if along > -8.0 and along < 36.0 and lat < 2.0:
			return false
	return true
