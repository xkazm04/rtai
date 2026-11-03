extends Scenario
## Vehicles carnage on the real World: Rivet hijacks a stopped taxi (its driver thrown out), then
## rams a stopped sedan 40 m down the lane, backs off and rams again. Asserts the hijack event,
## damage on both cars, the sedan disabled at D2 or worse (it leaves traffic as a service body),
## and that the run records and replays identically. Evidence: vehicle-carnage.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 47
const TICKS: int = 11 * SimClock.TICK_RATE


class RamInput:
	extends InputSource
	const A: int = TickInput.AXIS_MAX
	## [until tick, buttons, move_y]: hijack at 30, ram, back off, ram, back off, ram.
	const PLAN: Array[Array] = [
		[30, 0, 0],
		[31, 1 << VehicleService.BIT_USE, 0],
		[200, 0, -A],
		[300, 0, A],
		[400, 0, -A],
		[500, 0, A],
		[620, 0, -A],
		[1 << 30, 0, 0],
	]

	func sample(tick: int) -> TickInput:
		for row: Array in PLAN:
			var until: int = row[0]
			var buttons: int = row[1]
			var my: int = row[2]
			if tick < until:
				return TickInput.new(buttons, 0, my)
		return TickInput.new()


func run(_tree: SceneTree) -> String:
	var w: Array[Object] = _world(MASTER_SEED)
	var world: World = w[0]
	var bus: EventBus = w[1]
	var svc: VehicleService = w[3]
	var hijacks: Array[StringName] = []
	@warning_ignore("return_value_discarded")
	bus.vehicle_hijacked.connect(func(k: StringName) -> void: hijacks.append(k))
	world.loop().set_input(RamInput.new())
	world.loop().start_recording()
	for t: int in TICKS:
		world.loop().step()
	var log: ReplayLog = world.loop().finish_recording()
	var states: Array[int] = []
	for b: VehicleBody in svc.cars:
		states.append(b.state)
	var reason: String = _judge(svc, hijacks)
	var summary: Dictionary = {"hijacked": hijacks, "states": states}
	summary["player_hp_lost"] = svc.cars[0].hp_lost if not svc.cars.is_empty() else -1.0
	_free(w)
	if reason == "":
		var again: Array[Object] = _world(MASTER_SEED)
		reason = (again[0] as World).verify_replay(log)
		reason = "" if reason == "" else "replay diverged: %s" % reason
		_free(again)
	summary["result"] = "pass" if reason == "" else reason
	var err: String = write_evidence("vehicle-carnage.json", summary)
	Log.info("scenario", "vehicle carnage: %s" % JSON.stringify(summary))
	return reason if reason != "" else err


static func _judge(svc: VehicleService, hijacks: Array[StringName]) -> String:
	if hijacks.size() != 1 or hijacks[0] != &"taxi":
		return "expected one taxi hijack, got %s" % str(hijacks)
	if svc.cars.size() < 2:
		return "no rammed car left traffic as a disabled body"
	var mine: VehicleBody = svc.cars[0]
	var rammed: VehicleBody = svc.cars[1]
	if mine.hp_lost <= 0.0:
		return "the rammer took no damage"
	if rammed.state < VehicleBody.State.D2 or rammed.state == VehicleBody.State.HIJACKED:
		return "the rammed sedan is %d, not D2 or a wreck" % rammed.state
	return ""


## [World, EventBus, DataStore, VehicleService, CitySystem]: no traffic but the scene's cars.
static func _world(master_seed: int) -> Array[Object]:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, master_seed)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(60, 6, 1)
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = Drive.call(&"_east_lane", city)
	vw.set_focus(lane + Vector2(0.5, -2.2), false)
	for c: Vector2 in [Vector2(0, 3), Vector2(40, 0)]:
		var at: Vector2 = lane + Vector2(c.x, 0)
		var spec: Array = [SimConst.K_CAR, at.x, at.y, 1, 0, c.y, 0, 0.0, at.y, 0]
		@warning_ignore("return_value_discarded")
		city.sim.spawn(PackedFloat64Array(spec))
	return [world, bus, data, svc, city]


static func _free(w: Array[Object]) -> void:
	for k: int in 3:
		w[k].free()
