class_name CitySimBody
extends RefCounted
## The player body in the reference sim (native: sim_core/src/body.cpp, operation for operation).
## One circle placed before each step (SimConst.BD_*). A person overlapping it takes BD_SHARE of
## the overlap (the mass ratio) and, above the tackle speed, is knocked down (M_DOWN); after the
## people step the body is pushed out of whatever still overlaps it, then out of solid cells.
## Scratch members x, y carry the person being resolved (doubles, never Vector2: float32).

var x: float = 0.0
var y: float = 0.0
var bx: float = 0.0
var by: float = 0.0
var spec: PackedFloat64Array = SimArrays.f64(SimConst.BD_LEN)
var knocks: PackedFloat64Array = PackedFloat64Array()
var _s: CitySimState
var _h: CitySimHash
var _solid: CitySimSolid


func _init(state: CitySimState, hash_grid: CitySimHash) -> void:
	_s = state
	_h = hash_grid
	_solid = CitySimSolid.new(state)


func set_spec(p_spec: PackedFloat64Array) -> void:
	if p_spec.size() != SimConst.BD_LEN:
		return
	spec = p_spec.duplicate()
	bx = spec[SimConst.BD_X]
	by = spec[SimConst.BD_Y]


## Person i at the scratch (x, y), moving at (pvx, pvy) m/s, against the body.
func push(i: int, pvx: float, pvy: float) -> void:
	if spec[SimConst.BD_ON] == 0.0:
		return
	var rs: float = spec[SimConst.BD_R] + spec[SimConst.BD_RP]
	var ddx: float = x - bx
	var ddy: float = y - by
	var d2: float = ddx * ddx + ddy * ddy
	if d2 >= rs * rs:
		return
	var nx: float = 1.0
	var ny: float = 0.0
	var d: float = 0.0
	if d2 > 1e-12:
		d = sqrt(d2)
		nx = ddx / d
		ny = ddy / d
	var closing: float = spec[SimConst.BD_VX] * nx + spec[SimConst.BD_VY] * ny
	var tackle: bool = _s.mode[i] != SimConst.M_DOWN and closing > spec[SimConst.BD_TACKLE]
	if tackle:
		_knock(i, nx, ny)
	var sh: float = spec[SimConst.BD_SHARE]
	# a person running into the body is blocked (human -> rivet_base run): it takes it all
	var run_in: bool = (
		spec[SimConst.BD_RUN_IN] != 0.0 and -(pvx * nx + pvy * ny) > spec[SimConst.BD_RUN_IN]
	)
	if not tackle and run_in:
		sh = 1.0
	var pen: float = (rs - d) * sh
	x += nx * pen
	y += ny * pen
	if not tackle:
		_aside(i, nx, ny, pen)


func _knock(i: int, nx: float, ny: float) -> void:
	_s.mode[i] = SimConst.M_DOWN
	_s.hx[i] = nx
	_s.hy[i] = ny
	_s.v[i] = spec[SimConst.BD_KNOCK]
	_s.t1[i] = spec[SimConst.BD_DOWN]
	_s.sx[i] = bx
	_s.sy[i] = by
	knocks.append_array([float(i), x, y])


## A shove also steps the person aside (to the side they stand on; dead ahead: by slot), so a
## crowd parts instead of being bulldozed along in a train.
func _aside(i: int, nx: float, ny: float, pen: float) -> void:
	var vx: float = spec[SimConst.BD_VX]
	var vy: float = spec[SimConst.BD_VY]
	var vv2: float = vx * vx + vy * vy
	if vv2 <= 1e-6:
		return
	var vl: float = sqrt(vv2)
	var ux: float = vx / vl
	var uy: float = vy / vl
	var cr: float = ux * ny - uy * nx
	var sd: float = 1.0 if (i & 1) != 0 else -1.0
	if cr > 0.0:
		sd = 1.0
	elif cr < 0.0:
		sd = -1.0
	x += -uy * sd * pen * 0.5
	y += ux * sd * pen * 0.5


## A knocked-down person: slides along the knock, lies for t1, then gets up (a ped flees from
## where it was hit, a cop resumes).
func down(i: int, dt: float) -> void:
	var vv: float = maxf(0.0, _s.v[i] - 8.0 * dt)
	_s.v[i] = vv
	x = _s.px[i] + _s.hx[i] * vv * dt
	y = _s.py[i] + _s.hy[i] * vv * dt
	if _s.tier[i] == 0:
		push(i, 0.0, 0.0)
		_solid.x = x
		_solid.y = y
		_solid.push_out(0.3)
		x = _solid.x
		y = _solid.y
	_s.px[i] = x
	_s.py[i] = y
	_s.t1[i] -= dt
	if _s.t1[i] > 0.0:
		return
	if _s.kind[i] == SimConst.K_COP:
		_s.mode[i] = SimConst.M_WALK
		_s.t1[i] = 0.0
		return
	_s.mode[i] = SimConst.M_FLEE
	_s.t1[i] = spec[SimConst.BD_FLEE]


## The body out of every live tier-A person it still overlaps (twice), then out of solid cells.
func resolve() -> void:
	if spec[SimConst.BD_ON] == 0.0:
		return
	var rs: float = spec[SimConst.BD_R] + spec[SimConst.BD_RP]
	for _it: int in 2:
		for j: int in _h.query(bx, by, 1):
			var kj: int = _s.kind[j]
			if _s.alive[j] == 0 or (kj != SimConst.K_PED and kj != SimConst.K_COP):
				continue
			if _s.mode[j] == SimConst.M_DEAD:
				continue
			var ddx: float = bx - _s.px[j]
			var ddy: float = by - _s.py[j]
			var d2: float = ddx * ddx + ddy * ddy
			if d2 >= rs * rs or d2 <= 1e-12:
				continue
			var d: float = sqrt(d2)
			bx += ddx / d * (rs - d)
			by += ddy / d * (rs - d)
	_solid.x = bx
	_solid.y = by
	_solid.push_out(spec[SimConst.BD_R])
	bx = _solid.x
	by = _solid.y


## BR_X, BR_Y, BR_N, then BR_STRIDE floats per knockdown this step (slot, x, y).
func result() -> PackedFloat64Array:
	@warning_ignore("integer_division")
	var n: int = knocks.size() / SimConst.BR_STRIDE
	var out: PackedFloat64Array = PackedFloat64Array([bx, by, float(n)])
	out.append_array(knocks)
	return out
