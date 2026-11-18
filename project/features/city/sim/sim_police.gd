class_name CitySimPolice
extends RefCounted
## n18 living police of the reference sim, op for op native/sim_core/src/police.cpp (parity).
## level -1 (the default) never comes here: every cop pursues the step's target as before n18.
## Heat 0: every cop walks his sidewalk like a pedestrian, holding fire. Heat 1-3: the
## tune[PT_FOOT<level>] cops nearest the last-seen point are engaged (F_ENGAGED, nearest first,
## lowest slot on a tie): they path to the point on the flow field, steer at Rivet and fire only
## with him in sight, and search tune[PT_SEARCH_S] once one is within PT_ARRIVE_M of it; then all
## go back to walking until the point moves to another cell or the level rises.

## The wanted level (set_heat, clamped -1..3) and the point a cop last saw Rivet.
var level: int = -1
var heat_x: float = 0.0
var heat_y: float = 0.0
## The ladder's tune (SimConst.PT_LEN, data/tables/heat.json `city`); kept across reset().
var tune: PackedFloat64Array = PackedFloat64Array([0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4, 2.0, 12.0])
var _s: CitySimState
var _flow: CitySimFlow
var _cx: int = 0
var _cy: int = 0
var _last_level: int = -1
var _search: float = 0.0
var _done: bool = false


func _init(state: CitySimState, flow: CitySimFlow) -> void:
	_s = state
	_flow = flow


func reset() -> void:
	level = -1
	_s.heat = -1
	heat_x = 0.0
	heat_y = 0.0
	_cx = 0
	_cy = 0
	_last_level = -1
	_search = 0.0
	_done = false


func set_heat(p_level: int, x: float, y: float) -> void:
	level = clampi(p_level, -1, 3)
	_s.heat = level
	heat_x = x
	heat_y = y


func set_tune(t: PackedFloat64Array) -> void:
	for k: int in mini(t.size(), SimConst.PT_LEN):
		tune[k] = t[k]


## Before the actors move (CityCore::police_pass): the search clock and who is engaged.
func pass_step(dt: float) -> void:
	var cx: int = floori(heat_x)
	var cy: int = floori(heat_y)
	if cx != _cx or cy != _cy or level > _last_level:
		_cx = cx
		_cy = cy
		_search = 0.0
		_done = false
	_last_level = level
	var want: int = 0 if (level == 0 or _done) else int(tune[SimConst.PT_FOOT0 + level])
	var a2: float = tune[SimConst.PT_ARRIVE_M] * tune[SimConst.PT_ARRIVE_M]
	var arrived: bool = false
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0 or _s.kind[i] != SimConst.K_COP or not _engaged(i):
			continue
		if _s.mode[i] == SimConst.M_DEAD:
			_s.flags[i] = _s.flags[i] & ~SimConst.F_ENGAGED
			continue
		var ax: float = _s.px[i] - heat_x
		var ay: float = _s.py[i] - heat_y
		if ax * ax + ay * ay <= a2:
			arrived = true
	if arrived and not _done:
		_search += dt
		if _search >= tune[SimConst.PT_SEARCH_S]:
			_done = true
			want = 0
	if want == 0:
		_release()
	_fill(want)
	_flow.stats[SimConst.FS_SEARCH_TICKS] = floori(_search / dt + 0.5)


## Engage or release cops until want are engaged (CityCore::police_fill).
func _fill(want: int) -> void:
	var n: int = 0
	for i: int in SimConst.CAP:
		if _s.alive[i] != 0 and _s.kind[i] == SimConst.K_COP and _claimed(i):
			n += 1
	while n != want:
		var add: bool = n < want
		var pick: int = -1
		var best: float = 0.0
		for i: int in SimConst.CAP:
			if _s.alive[i] == 0 or _s.kind[i] != SimConst.K_COP or _s.mode[i] == SimConst.M_DEAD:
				continue
			if _engaged(i) == add or (_s.flags[i] & SimConst.F_CREW) != 0:
				continue
			var ax: float = _s.px[i] - heat_x
			var ay: float = _s.py[i] - heat_y
			var d2: float = ax * ax + ay * ay
			if pick < 0 or (d2 < best if add else d2 > best):
				pick = i
				best = d2
		if pick < 0:
			break
		if add:
			_s.flags[pick] = _s.flags[pick] | SimConst.F_ENGAGED
		else:
			_s.flags[pick] = _s.flags[pick] & ~SimConst.F_ENGAGED
		n += 1 if add else -1
	_flow.stats[SimConst.FS_ENGAGED] = n


func _engaged(i: int) -> bool:
	return (_s.flags[i] & SimConst.F_ENGAGED) != 0


## A cop on a PT_FOOT claim (engaged, not a car's crew).
func _claimed(i: int) -> bool:
	return (_s.flags[i] & (SimConst.F_ENGAGED | SimConst.F_CREW)) == SimConst.F_ENGAGED


## Every claim cancelled (CityCore::police_release): crews walk, police cars drive on as traffic.
func _release() -> void:
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0:
			continue
		if _s.kind[i] == SimConst.K_COP:
			_s.flags[i] = _s.flags[i] & ~(SimConst.F_ENGAGED | SimConst.F_CREW)
		elif _s.kind[i] == SimConst.K_PCAR:
			_s.flags[i] = _s.flags[i] & ~(SimConst.F_ENGAGED | SimConst.F_PARKED)


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
	var ax: float = x - heat_x
	var ay: float = y - heat_y
	var r: float = tune[SimConst.PT_CAR_STOP_M]
	return 0.0 if ax * ax + ay * ay <= r * r else vdes


## Heat 2 (CityCore::car_unload): stopped there, the car parks and its crew gets out on the side
## facing the point. hv: the car's heading x, y and speed after its step.
func car_unload(i: int, x: float, y: float, hv: PackedFloat64Array) -> void:
	if _s.heat < 0 or _s.kind[i] != SimConst.K_PCAR or not _engaged(i) or hv[2] >= 0.5:
		return
	var ax: float = x - heat_x
	var ay: float = y - heat_y
	var r: float = tune[SimConst.PT_CAR_STOP_M]
	if ax * ax + ay * ay > r * r:
		return
	_s.flags[i] = (_s.flags[i] & ~SimConst.F_ENGAGED) | SimConst.F_PARKED
	var n: int = int(tune[SimConst.PT_CREW])
	var sx: float = -hv[1]
	var sy: float = hv[0]
	if sx * (heat_x - x) + sy * (heat_y - y) < 0.0:
		sx = -sx
		sy = -sy
	var fl: int = SimConst.F_PROMOTED | SimConst.F_ENGAGED | SimConst.F_CREW
	for k: int in n:
		var along: float = float(k) * 1.4 - 0.7 * float(n - 1)
		var spec: PackedFloat64Array = PackedFloat64Array(
			[SimConst.K_COP, x + sx * 2.0 + hv[0] * along, y + sy * 2.0 + hv[1] * along, sx, sy]
		)
		spec.append_array(PackedFloat64Array([SimConst.ART_COP, fl, 3.4, 0.0, 0.0]))
		@warning_ignore("return_value_discarded")
		_s.spawn(spec)
