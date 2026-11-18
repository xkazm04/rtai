class_name CityHeat
extends WorldSystem
## n18 police item 2: heat in the streamed city (the sandbox boot). A sim foot cop SEES Rivet when
## he is within the heat table's sight_m and the cell map gives a clear line (CitySimBackend.sight,
## the same sense the cop's straight steer uses). Violence this tick (a person killed by Rivet's car
## or by Rivet) while a cop sees him raises heat one level; out of every cop's sight it drains as
## HeatMeter does on quest 1. The level and the last-seen point go to the sim (set_heat) each tick.
## Register after CitySystem and VehicleService so their tick's events and positions are in.

## The city this heat watches (its sim and Rivet's position, `target`).
var city: CitySystem = null
var meter: HeatMeter = null
## The heat table's city block (drain, the ladder's counts and times, living_police).
var tune: CityHeatTune = null
## The foot patrol the ladder sends (the street targets keep none).
var patrol: CityPatrol = null
## Heat 2-3: police cars sent to the last-seen point.
var dispatch: CityDispatch = null
## A sim cop sees Rivet this tick.
var seen: bool = false
## Where a cop last saw Rivet (the investigate point); valid once `ever_seen`.
var last_seen: Vector2 = Vector2.ZERO
var ever_seen: bool = false
var _violence: int = 0


func _init(p_city: CitySystem) -> void:
	city = p_city


func setup(ctx: WorldContext) -> void:
	meter = HeatMeter.new(ctx.events)
	tune = CityHeatTune.load_table()
	meter.drain_ticks = tune.drain_ticks
	city.sim.set_police(tune.sim_tune)
	patrol = CityPatrol.new(ctx.rng.stream(CityPatrol.STREAM), tune.patrol_cops)
	dispatch = CityDispatch.new(ctx.rng.stream(CityDispatch.STREAM))
	dispatch.cars = tune.cars
	dispatch.delay_ticks = tune.car_delay_ticks
	dispatch.ring_m = tune.car_ring_m
	@warning_ignore("return_value_discarded")
	ctx.events.pedestrian_struck.connect(_on_struck)
	@warning_ignore("return_value_discarded")
	ctx.events.actor_killed.connect(_on_killed)


func step(tick: int, _input: TickInput) -> void:
	seen = cop_sees(city.sim, city.target, meter.sight_m)
	if seen:
		last_seen = city.target
		ever_seen = true
	if _violence > 0 and seen:
		meter.raise_by(1)
	_violence = 0
	meter.step(seen)
	city.sim.set_heat(meter.level if tune.living else -1, last_seen.x, last_seen.y)
	@warning_ignore("return_value_discarded")
	patrol.tick(city.sim, city.focus)
	var lv: int = meter.level if tune.living else 0
	@warning_ignore("return_value_discarded")
	dispatch.step(city.sim, tick, lv, last_seen, city.focus)


## Violence from outside the sim's own events (a shot Rivet fired, later sources).
func witness_violence() -> void:
	_violence += 1


## True when a live sim foot cop stands within r of `at` with a clear line on the cell map.
static func cop_sees(sim: CitySimBackend, at: Vector2, r: float) -> bool:
	var snap: PackedFloat64Array = sim.snapshot()
	var r2: float = r * r
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[k + 1]) != SimConst.K_COP or int(snap[k + 2]) == SimConst.M_DEAD:
			continue
		var x: float = snap[k + 4]
		var y: float = snap[k + 5]
		var dx: float = at.x - x
		var dy: float = at.y - y
		if dx * dx + dy * dy <= r2 and sim.sight(x, y, at.x, at.y):
			return true
	return false


func write_state(out: StreamPeerBuffer) -> void:
	meter.write_state(out)
	dispatch.write_state(out)
	out.put_8(1 if ever_seen else 0)
	out.put_double(last_seen.x)
	out.put_double(last_seen.y)


func _on_struck(_victim_id: int, killed: bool) -> void:
	if killed:
		_violence += 1


func _on_killed(killer_id: int, _victim_id: int, _kind: StringName) -> void:
	if killer_id == RivetBody.RIVET_ACTOR_ID:
		_violence += 1
