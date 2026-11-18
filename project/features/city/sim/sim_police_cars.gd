class_name CitySimPoliceCars
extends RefCounted
## n18 living police, the police car rules of the reference sim (op for op the car functions of
## native/sim_core/src/police.cpp, parity): who pursues, a dispatched car's stop at the last-seen
## point, its unload (crew out) and bail-out, and the idle police car that is traffic.

var _s: CitySimState
var _p: CitySimPolice


func _init(state: CitySimState, police: CitySimPolice) -> void:
	_s = state
	_p = police


## A police car pursues (the turn rule, no yielding): every one before n18, a dispatched one under
## heat (CityCore::car's is_p).
static func pursuer(s: CitySimState, i: int) -> bool:
	if s.kind[i] != SimConst.K_PCAR:
		return false
	return s.heat < 0 or (s.flags[i] & SimConst.F_ENGAGED) != 0


## Heat 2 (CityCore::car_police_speed): a dispatched car stops within PT_CAR_STOP_M of the point.
func car_speed(i: int, x: float, y: float, vdes: float) -> float:
	if _s.heat < 0 or _s.kind[i] != SimConst.K_PCAR:
		return vdes
	if (_s.flags[i] & SimConst.F_PARKED) != 0:
		return 0.0
	if not _engaged(i):
		return vdes
	var ax: float = x - _p.heat_x
	var ay: float = y - _p.heat_y
	var r: float = _p.tune[SimConst.PT_CAR_STOP_M]
	return 0.0 if ax * ax + ay * ay <= r * r else vdes


## Heat 2 (CityCore::car_unload): stopped there, the car parks and its crew gets out on the side
## facing the point (heat 3: PT_SQUAD cops, looks PT_SQUAD_V0 / V1 in turn). hv: the car's
## heading x, y and speed after its step.
func car_unload(i: int, x: float, y: float, hv: PackedFloat64Array) -> void:
	if _s.heat < 0 or _s.kind[i] != SimConst.K_PCAR or hv[2] >= 0.5 or not _engaged(i):
		return
	var ax: float = x - _p.heat_x
	var ay: float = y - _p.heat_y
	var r: float = _p.tune[SimConst.PT_CAR_STOP_M]
	if ax * ax + ay * ay > r * r and _s.stuck[i] <= _p.tune[SimConst.PT_BAIL_S]:
		return
	_s.flags[i] = (_s.flags[i] & ~SimConst.F_ENGAGED) | SimConst.F_PARKED
	var squad: bool = _s.heat >= 3  # heat 3: a riot / SWAT squad (the look alternates)
	var n: int = int(_p.tune[SimConst.PT_SQUAD if squad else SimConst.PT_CREW])
	var sx: float = -hv[1]
	var sy: float = hv[0]
	if sx * (_p.heat_x - x) + sy * (_p.heat_y - y) < 0.0:
		sx = -sx
		sy = -sy
	var fl: int = SimConst.F_PROMOTED | SimConst.F_ENGAGED | SimConst.F_CREW
	for k: int in n:
		var along: float = float(k) * 1.4 - 0.7 * float(n - 1)
		var spec: PackedFloat64Array = PackedFloat64Array(
			[SimConst.K_COP, x + sx * 2.0 + hv[0] * along, y + sy * 2.0 + hv[1] * along, sx, sy]
		)
		var look: float = _p.tune[SimConst.PT_SQUAD_V0 + k % 2] if squad else SimConst.ART_COP
		spec.append_array(PackedFloat64Array([look, fl, 3.4, 0.0, 0.0]))
		@warning_ignore("return_value_discarded")
		_s.spawn(spec)


## n18: under heat an idle police car (not dispatched, not parked) is traffic: stuck, it despawns
## like traffic though the spawner promoted it (CityCore::car's idle_p; a jam must clear).
static func idle_car(s: CitySimState, i: int) -> bool:
	var busy: int = SimConst.F_ENGAGED | SimConst.F_PARKED
	return s.heat >= 0 and s.kind[i] == SimConst.K_PCAR and (s.flags[i] & busy) == 0


func _engaged(i: int) -> bool:
	return (_s.flags[i] & SimConst.F_ENGAGED) != 0
