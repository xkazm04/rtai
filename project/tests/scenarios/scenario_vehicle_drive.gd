extends Scenario
## Vehicles feel test on the real World (CitySystem + VehicleService + CityVehicleWorld): Rivet
## enters a parked sedan on a straight street and drives a fixed route (full throttle, a grip
## turn, a handbrake slide, brake, reverse, exit) while a pedestrian stands in the lane ahead.
## Asserts speed, a handbrake slip well above the grip-turn slip, the run-over, the exit, a
## hijack of a traffic car (driver thrown out), and that the run records and replays identically.
## Writes the per-tick trace (speed, slip angle, state) as evidence (vehicle-drive.json).

const MASTER_SEED: int = 31
const TICKS: int = 12 * SimClock.TICK_RATE
const PED_AHEAD_M: float = 26.0
const STRAIGHT_TILES: int = 10
## Route phases (ticks): full throttle to GRIP_AT, an S-bend at half lock (grip), throttle to
## HB_AT, a handbrake slide at full lock, brake and reverse to 560, coast, exit at EXIT_AT.
const GRIP_AT: int = 170
const HB_AT: int = 330
const EXIT_AT: int = 700


class RouteInput:
	extends InputSource
	const USE: int = 1 << VehicleService.BIT_USE
	const HB: int = 1 << VehicleService.BIT_HANDBRAKE
	const A: int = TickInput.AXIS_MAX

	## [until tick, buttons, move_x, move_y] rows, first match wins.
	const PLAN: Array[Array] = [
		[6, 0, 0, 0],
		[GRIP_AT, 0, 0, -A],
		[GRIP_AT + 15, 0, 64, -A],
		[GRIP_AT + 30, 0, -64, -A],
		[HB_AT, 0, 0, -A],
		[HB_AT + 60, HB, -A, -64],
		[560, 0, 0, A],
		[1 << 30, 0, 0, 0],
	]

	func sample(tick: int) -> TickInput:
		if tick == 5 or tick == EXIT_AT:
			return TickInput.new(USE, 0, 0)
		for row: Array in PLAN:
			var until: int = row[0]
			var buttons: int = row[1]
			var mx: int = row[2]
			var my: int = row[3]
			if tick < until:
				return TickInput.new(buttons, mx, my)
		return TickInput.new()


func run(_tree: SceneTree) -> String:
	var w: Array[Object] = _world(MASTER_SEED)
	var world: World = w[0]
	var bus: EventBus = w[1]
	var svc: VehicleService = w[3]
	var struck: Array[int] = []
	var hijacks: Array[StringName] = []
	@warning_ignore("return_value_discarded")
	bus.pedestrian_struck.connect(func(v: int, _k: bool) -> void: struck.append(v))
	@warning_ignore("return_value_discarded")
	bus.vehicle_hijacked.connect(func(k: StringName) -> void: hijacks.append(k))
	world.loop().set_input(RouteInput.new())
	world.loop().start_recording()
	var trace: Array[Dictionary] = []
	var car: VehicleBody = svc.cars[0]
	var total_us: int = 0
	for t: int in TICKS:
		world.loop().step()
		total_us += svc.last_us
		trace.append(_row(t, car))
	var log: ReplayLog = world.loop().finish_recording()
	var reason: String = _judge(trace, struck, svc)
	if reason == "":
		reason = _hijack(svc, w[4] as CitySystem, hijacks)
	var summary: Dictionary = _summary(trace, struck.size(), hijacks)
	summary["service_us_avg"] = float(total_us) / TICKS
	summary["service_us_max"] = svc.max_us
	summary["timing"] = "CONTENDED (shared machine, headless, native sim)"
	_free(w)
	if reason == "":
		var again: Array[Object] = _world(MASTER_SEED)
		reason = (again[0] as World).verify_replay(log)
		reason = "" if reason == "" else "replay diverged: %s" % reason
		_free(again)
	summary["replay"] = "identical" if reason == "" else reason
	var err: String = write_evidence("vehicle-drive.json", {"summary": summary, "trace": trace})
	Log.info("scenario", "vehicle drive: %s" % JSON.stringify(summary))
	return reason if reason != "" else err


static func _row(t: int, b: VehicleBody) -> Dictionary:
	return {
		"t": t,
		"x": snappedf(b.pos.x, 0.001),
		"y": snappedf(b.pos.y, 0.001),
		"speed": snappedf(b.speed(), 0.001),
		"slip_deg": snappedf(b.slip_angle_deg(), 0.01),
		"sliding": b.sliding,
		"state": b.state,
		"hp_lost": snappedf(b.hp_lost, 0.01),
	}


static func _judge(trace: Array[Dictionary], struck: Array[int], svc: VehicleService) -> String:
	var peak: float = 0.0
	var grip_slip: float = 0.0
	var hb_slip: float = 0.0
	for r: Dictionary in trace:
		var t: int = r["t"]
		var v: float = r["speed"]
		var sl: float = r["slip_deg"]
		peak = maxf(peak, v)
		if t >= GRIP_AT and t < GRIP_AT + 60:
			grip_slip = maxf(grip_slip, sl)
		if t >= HB_AT and t < HB_AT + 60:
			hb_slip = maxf(hb_slip, sl)
	if peak < 15.0:
		return "peak speed %.1f m/s < 15" % peak
	if hb_slip < grip_slip + 8.0:
		return "handbrake slip %.1f deg not above grip slip %.1f" % [hb_slip, grip_slip]
	if struck.is_empty():
		return "the pedestrian in the lane was not struck"
	if svc.driving != null:
		return "still driving after the exit press"
	return ""


## On foot again: a taxi pulls up beside Rivet; walk up to it and take it.
static func _hijack(svc: VehicleService, city: CitySystem, hijacks: Array[StringName]) -> String:
	var p: Vector2 = svc.world.player_pos() + Vector2(0, -3.0)
	@warning_ignore("return_value_discarded")
	city.sim.spawn(PackedFloat64Array([SimConst.K_CAR, p.x, p.y, 1, 0, 3, 0, 8.0, p.y, 0]))
	svc.world.refresh()
	var recs: PackedFloat64Array = svc.world.cars_near(svc.world.player_pos(), 10.0)
	if recs.is_empty():
		return "no traffic car to hijack"
	var at: Vector2 = Vector2(recs[2], recs[3]) + Vector2(recs[5], -recs[4]) * 1.5
	var before: int = svc.cars.size()
	if svc.try_enter(at) < 0 or svc.cars.size() != before + 1 or hijacks.is_empty():
		return "hijack failed"
	return ""


static func _summary(
	trace: Array[Dictionary], struck: int, hijacks: Array[StringName]
) -> Dictionary:
	var peak: float = 0.0
	var slip: float = 0.0
	for r: Dictionary in trace:
		var v: float = r["speed"]
		var sl: float = r["slip_deg"]
		peak = maxf(peak, v)
		slip = maxf(slip, sl)
	var last: Dictionary = trace.back()
	return {
		"ticks": trace.size(),
		"peak_speed_mps": peak,
		"max_slip_deg": slip,
		"struck": struck,
		"hijacked": hijacks,
		"final_state": last["state"],
		"final_hp_lost": last["hp_lost"],
	}


## [World, EventBus, DataStore, VehicleService, CitySystem], the sedan parked on a straight
## east-bound lane and a pedestrian standing in that lane ahead of it.
static func _world(master_seed: int) -> Array[Object]:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, master_seed)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(120, 0, 0)  # people, no traffic on the test street
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = _east_lane(city)
	@warning_ignore("return_value_discarded")
	svc.spawn_parked(&"sedan", lane, Vector2.RIGHT, 0)
	vw.set_focus(lane + Vector2(0, -2.0), false)
	var ped: Vector2 = lane + Vector2(PED_AHEAD_M, 0.0)
	@warning_ignore("return_value_discarded")
	city.sim.spawn(PackedFloat64Array([SimConst.K_PED, ped.x, ped.y, 0, 1, 2, 0, 0.0, 0, 0]))
	return [world, bus, data, svc, city]


## The east-bound lane of the first east-west road with STRAIGHT_TILES road tiles ahead, scanning
## rows outward from the city's start.
static func _east_lane(city: CitySystem) -> Vector2:
	var s: Vector2 = city.focus
	for dy: int in range(0, 24):
		for sgn: int in [1, -1]:
			var y: float = floorf(s.y / 8.0) * 8.0 + 4.0 + dy * sgn * 8.0
			for dx: int in range(-12, 12):
				var x: float = floorf(s.x / 8.0) * 8.0 + 4.0 + dx * 8.0
				if _straight(city, x, y):
					return Vector2(x, y + CitySimState.LANE_OFF[0])
	return s


static func _straight(city: CitySystem, x: float, y: float) -> bool:
	for k: int in STRAIGHT_TILES:
		if city.sim.tile_at(x + k * 8.0, y) != SimConst.T_ROAD_H:
			return false
	return true


static func _free(w: Array[Object]) -> void:
	for k: int in 3:
		w[k].free()
