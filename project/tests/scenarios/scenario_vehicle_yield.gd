extends Scenario
## Traffic yields to the service cars (set_obstacles) on the real World: a sedan parked in a
## straight east-bound lane with three sim cars behind it in that lane (12 m/s) and civilian
## traffic around (no police: cops ram on purpose), 40 s. Arm
## `yield` is the game; arm `blind` hands the sim no obstacles (the behaviour before). Counts the
## rear-ends (ticks the parked car is shoved from rest) and its hp lost. Passes when the blind arm
## is hit at least once (the scene really sends traffic through) and the yield arm never is.
## Evidence: vehicle-yield.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 53
const TICKS: int = 40 * SimClock.TICK_RATE
const PARK_AHEAD_M: float = 24.0


## The port without the obstacle feed: traffic cannot see the service cars.
class Blind:
	extends CityVehicleWorld

	func set_obstacles(_xy: PackedFloat64Array) -> void:
		pass


func run(_tree: SceneTree) -> String:
	var summary: Dictionary = {"ticks": TICKS}
	for arm: String in ["yield", "blind"]:
		summary[arm] = _arm(arm == "blind")
	var y: Dictionary = summary["yield"]
	var b: Dictionary = summary["blind"]
	var blind_hits: int = b["rear_ends"]
	var hits: int = y["rear_ends"]
	var lost: float = y["hp_lost"]
	var reason: String = ""
	if blind_hits < 1:
		reason = "the blind arm was never hit: the scene sends no traffic past the car"
	elif hits > 0 or lost > 0.0:
		reason = "traffic still rear-ends a parked car: %s" % str(y)
	summary["result"] = "pass" if reason == "" else reason
	var err: String = write_evidence("vehicle-yield.json", summary)
	Log.info("scenario", "vehicle yield: %s" % JSON.stringify(summary))
	return reason if reason != "" else err


static func _arm(blind: bool) -> Dictionary:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, MASTER_SEED)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(30, 40, 0)
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = Blind.new(city) if blind else CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = Drive.call(&"_east_lane", city)
	vw.set_focus(lane + Vector2(0.0, -6.0), false)
	var car: VehicleBody = svc.spawn_parked(
		&"sedan", lane + Vector2(PARK_AHEAD_M, 0), Vector2.RIGHT
	)
	for back: float in [20.0, 34.0, 48.0]:
		var at: Vector2 = car.pos - Vector2(back, 0.0)
		var spec: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, 0, 0, 12.0, at.y, 0]
		@warning_ignore("return_value_discarded")
		city.sim.spawn(PackedFloat64Array(spec))
	var rear_ends: int = 0
	var moving: bool = false
	var near: int = 0
	for _t: int in TICKS:
		world.loop().step()
		near += 1 if not vw.cars_near(car.pos, 14.0).is_empty() else 0
		var now: bool = car.speed() > 0.3
		if now and not moving:
			rear_ends += 1
		moving = now
	var out: Dictionary = {"rear_ends": rear_ends, "hp_lost": car.hp_lost, "ticks_near": near}
	out["at"] = [car.pos.x, car.pos.y]
	out["cars_alive"] = city.sim.get_counters()[SimConst.CN_CARS]
	world.free()
	bus.free()
	data.free()
	return out
