class_name CitySpawner
extends RefCounted
## Spawn rules (GDScript, low frequency, ported from the cityscale spike): keep the bubble
## populated. New actors appear on a ring around the camera (off screen), on a cell of the right
## kind (sidewalk for people, a lane for cars), accepted with the probability of the resident
## chunk's density map. Its RNG is one stream from the world's registry (SIM-02), so both sim
## backends get identical spawn sequences (parity) and a replay reproduces them (SIM-05).

const DX: Array[float] = [1.0, 0.0, -1.0, 0.0]
const DY: Array[float] = [0.0, 1.0, 0.0, -1.0]
const LANE_OFF: Array[float] = [2.0, -2.0, -2.0, 2.0]
const CAR_ART: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3]
const ART_POLICE_CAR: int = 8
const ART_COP: int = 7

var targets: CityTargets = CityTargets.new()
var riot_c: Vector2 = Vector2.ZERO
var r_min: float = 105.0
var rb: float = 160.0
var per_tick: int = 6
var attempts: int = 40
var use_density: bool = true
var _rng: RandomNumberGenerator
var _sim: CitySimBackend
var _res: CityResidency


func _init(sim: CitySimBackend, residency: CityResidency, rng: RandomNumberGenerator) -> void:
	_sim = sim
	_res = residency
	_rng = rng


func try_ped(cam: Vector2, r0: float, r1: float) -> bool:
	var p: Vector2 = _ring(cam, r0, r1)
	if _sim.cell_at(p.x, p.y) != SimConst.C_WALK or not _dens(p, false):
		return false
	var d: int = 0
	var walk_e: bool = _sim.cell_at(p.x + 1.0, p.y) == SimConst.C_WALK
	if walk_e and _sim.cell_at(p.x - 1.0, p.y) == SimConst.C_WALK:
		d = 0 if _rng.randf() < 0.5 else 2
	else:
		d = 1 if _rng.randf() < 0.5 else 3
	var art: int = _rng.randi_range(0, 6)
	var vmax: float = _rng.randf_range(1.15, 1.6)
	var pos: Vector2 = Vector2(floorf(p.x) + 0.5, floorf(p.y) + 0.5)
	return _spawn([SimConst.K_PED, pos.x, pos.y, DX[d], DY[d], art, 0, vmax, 0.0, d]) >= 0


func try_car(cam: Vector2, r0: float, r1: float, police: bool) -> bool:
	var p: Vector2 = _ring(cam, r0, r1)
	var t: int = _sim.tile_at(p.x, p.y)
	if t != SimConst.T_ROAD_H and t != SimConst.T_ROAD_V:
		return false
	if not police and not _dens(p, true):
		return false
	var x: float = p.x
	var y: float = p.y
	var d: int = 0
	if t == SimConst.T_ROAD_H:
		d = 0 if _rng.randf() < 0.5 else 2
		y = floorf(p.y / 8.0) * 8.0 + 4.0 + LANE_OFF[d]
	else:
		d = 1 if _rng.randf() < 0.5 else 3
		x = floorf(p.x / 8.0) * 8.0 + 4.0 + LANE_OFF[d]
	var lane: float = y if (d == 0 or d == 2) else x
	if police:
		var spec: Array = [SimConst.K_PCAR, x, y, DX[d], DY[d], ART_POLICE_CAR]
		return _spawn(spec + [SimConst.F_PROMOTED, 17.0, lane, d]) >= 0
	var art: int = CAR_ART[_rng.randi_range(0, 11)]
	var vmax: float = _rng.randf_range(9.0, 13.0)
	return _spawn([SimConst.K_CAR, x, y, DX[d], DY[d], art, 0, vmax, lane, d]) >= 0


func try_riot(centre: Vector2, r0: float, r1: float, cop: bool) -> bool:
	var p: Vector2 = _ring(centre, r0, r1)
	var c: int = _sim.cell_at(p.x, p.y)
	if c < SimConst.C_LANE or c > SimConst.C_WALK:
		return false
	var a: int = _rng.randi_range(0, 15)
	var dx: float = cos(a * TAU / 16.0)
	var dy: float = sin(a * TAU / 16.0)
	if cop:
		var spec: Array = [SimConst.K_COP, p.x, p.y, dx, dy, ART_COP, SimConst.F_PROMOTED]
		return _spawn(spec + [3.4, 0.0, 0]) >= 0
	var fl: int = SimConst.F_PROMOTED | SimConst.F_RIOTER
	var i: int = _spawn([SimConst.K_PED, p.x, p.y, dx, dy, _rng.randi_range(0, 6), fl, 2.6, 0.0, 0])
	if i >= 0:
		_sim.set_riot_centre(i, centre.x, centre.y)
	return i >= 0


## One tick of spawning. initial = fill the whole bubble (the loading screen), else only the
## outer ring. Categories take turns (rioters, cops, police cars, cars, peds).
func tick(cam: Vector2, initial: bool) -> int:
	var have: PackedInt32Array = _sim.get_counters()
	var plan: CitySpawnPlan = CitySpawnPlan.new(targets, have)
	var tries: int = 400000 if initial else attempts
	var budget: int = 100000 if initial else per_tick
	while tries > 0 and plan.made < budget:
		tries -= 1
		var cat: int = plan.next()
		if cat < 0:
			break
		if _try(cat, cam, initial):
			plan.add(cat)
	return plan.made


func _try(cat: int, cam: Vector2, initial: bool) -> bool:
	match cat:
		CitySpawnPlan.RIOTERS:
			return try_riot(riot_c, 0.0, 12.0, false)
		CitySpawnPlan.COPS:
			return try_riot(riot_c, 22.0, 34.0, true)
		CitySpawnPlan.POLICE_CARS:
			return try_car(cam, 60.0 if initial else 90.0, rb - 10.0, true)
		CitySpawnPlan.CARS:
			return try_car(cam, 0.0 if initial else r_min, rb - 5.0, false)
	return try_ped(cam, 0.0 if initial else r_min, rb - 5.0)


func _ring(centre: Vector2, r0: float, r1: float) -> Vector2:
	var a: float = _rng.randf() * TAU
	var r: float = sqrt(lerpf(r0 * r0, r1 * r1, _rng.randf()))
	return centre + Vector2(cos(a), sin(a)) * r


func _dens(p: Vector2, car: bool) -> bool:
	if not use_density or _res == null:
		return true
	return (_rng.randi() & 255) < _res.density(p.x, p.y, car)


func _spawn(spec: Array) -> int:
	return _sim.spawn(PackedFloat64Array(spec))
