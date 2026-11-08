class_name CarKnockClipDrive
extends WorldSystem
## The car-knock clip's script on the fixed tick (registered after the city): one sim car runs
## east down a straight lane at 12 m/s; Rivet waits LATERAL_M off its line and runs across when
## its centre is START_M behind him (scenario_car_knocks_rivet's scene). The camera (city.focus)
## holds on the crossing. --creep: he stands in the lane instead (the car brakes and touches).

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const BACK_M: float = 30.0
const LATERAL_M: float = 2.5
const RUN_MPS: float = 6.0
const START_M: float = 6.0

var knocks: int = 0
var hit_tick: int = -1
var lane: Vector2 = Vector2(-1, -1)
var _city: CitySystem
var _creep: bool = false
var _slot: int = -1
var _rivet: Vector2 = Vector2.ZERO
var _running: bool = false


func _init(city: CitySystem, creep: bool) -> void:
	_city = city
	_creep = creep


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if tick == 0:
		_plant()
		return
	if _slot < 0:
		return
	if _city.body.knocked():
		if hit_tick < 0:
			hit_tick = tick
			knocks += 1
		return
	if hit_tick >= 0:
		return  # up again: he stays where the slide left him
	var car_x: float = _car_x()
	_running = _running or (car_x > -INF and _rivet.x - car_x <= START_M)
	if _running:
		_rivet.y = minf(lane.y, _rivet.y + RUN_MPS * SimClock.TICK_DT)
	_city.target = _rivet


func _plant() -> void:
	_city.residency.update(_city.focus)
	var l: Vector2 = Drive.call(&"_east_lane", _city)
	lane = l + Vector2(BACK_M + 10.0, 0.0)
	_rivet = lane if _creep else lane - Vector2(0.0, LATERAL_M)
	_city.focus = lane
	_city.target = _rivet
	_city.body.pos = _rivet
	var at: Vector2 = lane - Vector2(BACK_M, 0.0)
	var spec: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, 0, 0, 12.0, at.y, 0]
	_slot = _city.sim.spawn(PackedFloat64Array(spec))


## The car's x from the sim snapshot, or -INF when it is gone.
func _car_x() -> float:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r]) == _slot:
			return snap[r + 4]
	return -INF
