class_name CitySimCarRoute
extends RefCounted
## Lane routing for the reference sim's cars: pick a turn CAR_PLAN_AHEAD before each junction
## (weighted random for traffic, nearest-to-target for police), U-turn before a dead-end tile
## (CAR_DEAD_END_TILES: by default only the city edge or an unloaded tile), take the turn once the
## car reaches the new lane, and reserve the junction tile in tier A. An exit is open only onto a
## road of its own orientation. d/ddx/ddy are the car's current direction and its unit vector,
## updated in place. Distances: SimConst car_route (t-4).

const WEIGHTS: Array[float] = [0.25, 0.5, 0.25]

var d: int = 0
var ddx: float = 0.0
var ddy: float = 0.0
var _s: CitySimState
var _flow: CitySimFlow


func _init(state: CitySimState, flow: CitySimFlow) -> void:
	_s = state
	_flow = flow


func begin(i: int) -> void:
	_set_dir(_s.dir[i])


func plan(i: int, x: float, y: float, tgx: float, tgy: float) -> void:
	var ax: float = x + ddx * SimConst.CAR_PLAN_AHEAD
	var ay: float = y + ddy * SimConst.CAR_PLAN_AHEAD
	var tc: int = _s.tile_at(ax, ay)
	if tc == SimConst.T_INTER:
		var icx: float = floorf(ax / 8.0) * 8.0 + 4.0
		var icy: float = floorf(ay / 8.0) * 8.0 + 4.0
		var pick: int = _pick(i, icx, icy, tgx, tgy)
		_s.ndir[i] = pick
		_s.jx[i] = icx
		_s.jy[i] = icy
		var axis: float = icy if pick == 0 or pick == 2 else icx
		_s.nlane[i] = axis + CitySimState.LANE_OFF[pick]
	elif dead_end(tc):
		# dead end: U-turn onto the opposite lane (t-4: only the city edge or an unloaded tile
		# by default; SimConst.CAR_DEAD_END_TILES picks the tile kinds, Call c-2)
		var centre: float = _s.lane[i] - CitySimState.LANE_OFF[d]
		_set_dir((d + 2) % 4)
		_s.dir[i] = d
		_s.lane[i] = centre + CitySimState.LANE_OFF[d]


func turn(i: int, x: float, y: float) -> void:
	var along: float = x * ddx + y * ddy
	var nd: int = _s.ndir[i]
	if nd != d:
		var cross: float = 0.0
		if nd == (d + 2) % 4:
			cross = _s.jx[i] * ddx + _s.jy[i] * ddy
		elif d == 0 or d == 2:
			cross = _s.nlane[i] * ddx - SimConst.CAR_TURN_LEAD
		else:
			cross = _s.nlane[i] * ddy - SimConst.CAR_TURN_LEAD
		if along >= cross:
			_set_dir(nd)
			_s.dir[i] = d
			_s.lane[i] = _s.nlane[i]
		return
	var past: float = along - (_s.jx[i] * ddx + _s.jy[i] * ddy)
	if past > SimConst.CAR_JUNCTION_CLEAR:
		var r: int = _s.res[i]
		if r >= 0 and _s.owner[r] == i + 1:
			_s.owner[r] = 0
		_s.res[i] = -1
		_s.ndir[i] = -1


## Claims the junction tile; true when another live car holds it (this one must wait).
func reserve(i: int) -> bool:
	var jt: int = floori(_s.jy[i] / 8.0) * SimConst.TW + floori(_s.jx[i] / 8.0)
	var o: int = _s.owner[jt]
	if o == 0 or o == i + 1 or _s.alive[o - 1] == 0 or _s.res[o - 1] != jt:
		_s.owner[jt] = i + 1
		_s.res[i] = jt
		return false
	return true


func _pick(i: int, icx: float, icy: float, tgx: float, tgy: float) -> int:
	var cand: Array[int] = [(d + 1) % 4, d, (d + 3) % 4]
	var ok: Array[bool] = [false, false, false]
	var sumw: float = 0.0
	for c: int in 3:
		var nd: int = cand[c]
		var dx: float = CitySimState.DX[nd] * SimConst.CAR_EXIT_PROBE
		var dy: float = CitySimState.DY[nd] * SimConst.CAR_EXIT_PROBE
		var t: int = _s.tile_at(icx + dx, icy + dy)
		if t == road_of(nd):
			ok[c] = true
			sumw += WEIGHTS[c]
	var pick: int = -1
	if _s.kind[i] == SimConst.K_PCAR:
		pick = _nearest(cand, ok, [icx, icy, tgx, tgy])
	elif sumw > 0.0:
		var r: float = _s.rnd() * sumw
		for c: int in 3:
			if ok[c]:
				pick = cand[c]
				r -= WEIGHTS[c]
				if r < 0.0:
					break
	return pick if pick >= 0 else (d + 2) % 4


## Police: the open exit with the shortest flow-field distance at its far end; exits the
## field does not cover rank after every covered one, by straight-line distance; ties keep the
## first. p = [icx, icy, tgx, tgy].
func _nearest(cand: Array[int], ok: Array[bool], p: Array[float]) -> int:
	var pick: int = -1
	var best_rank: int = 2
	var best_f: int = 0
	var best_e2: float = 0.0
	for c: int in 3:
		if not ok[c]:
			continue
		var ex: float = p[0] + CitySimState.DX[cand[c]] * SimConst.CAR_EXIT_PROBE
		var ey: float = p[1] + CitySimState.DY[cand[c]] * SimConst.CAR_EXIT_PROBE
		var f: int = _flow.dist(ex, ey)
		var e2: float = (ex - p[2]) * (ex - p[2]) + (ey - p[3]) * (ey - p[3])
		var rank: int = 0 if f >= 0 else 1
		var tie: bool = rank == best_rank and (f < best_f if rank == 0 else e2 < best_e2)
		if pick < 0 or rank < best_rank or tie:
			pick = cand[c]
			best_rank = rank
			best_f = f
			best_e2 = e2
	return pick


## True when a car U-turns before tile kind t: its bit is set in SimConst.CAR_DEAD_END_TILES
## (a junction never is).
static func dead_end(t: int) -> bool:
	return t != SimConst.T_INTER and ((SimConst.CAR_DEAD_END_TILES >> t) & 1) != 0


## The road tile a car heading dir drives on: east-west roads for 0 and 2, north-south for 1 and 3.
static func road_of(dir: int) -> int:
	return SimConst.T_ROAD_H if dir == 0 or dir == 2 else SimConst.T_ROAD_V


func _set_dir(nd: int) -> void:
	d = nd
	ddx = CitySimState.DX[d]
	ddy = CitySimState.DY[d]
