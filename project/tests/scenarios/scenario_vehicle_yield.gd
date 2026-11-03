extends Scenario
## Traffic yields to the service cars (set_obstacles) on the real World: a sedan parked in a
## straight east-bound lane with three sim cars behind it in that lane (12 m/s) and civilian
## traffic around (no police: cops ram on purpose), 40 s. Arm
## `yield` is the game; arm `blind` hands the sim no obstacles (the behaviour before). Counts the
## rear-ends (ticks the parked car is shoved from rest) and its hp lost, the queued time (seconds
## the three lane cars stand behind it, summed) and how many of them got past it (CitySimCarPass:
## out into the oncoming lane after PASS_WAIT_S). Passes when the blind arm is hit at least once
## (the scene really sends traffic through), the yield arm never is, and at least two of the three
## cars pass it. Evidence: vehicle-yield.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 53
const TICKS: int = 40 * SimClock.TICK_RATE
const PARK_AHEAD_M: float = 32.0  # int-day: 24 m left the queue in the junction (decisions.md)
const MIN_PASSED: int = 2


## The three lane cars (cars_near records of 8 floats): ticks one stands within 30 m behind the
## parked car (queued), and the slots seen 8 m past it (passed, first_pass tick).
class LaneWatch:
	extends RefCounted
	var queued: int = 0
	var passed: Array[int] = []
	var first_pass: int = -1
	var _slots: Array[int]

	func _init(slots: Array[int]) -> void:
		_slots = slots

	func watch(near: PackedFloat64Array, at: Vector2, t: int) -> void:
		for r: int in range(0, near.size(), 8):
			var slot: int = int(near[r])
			if not _slots.has(slot):
				continue
			var dx: float = near[r + 2] - at.x
			if dx < 0.0 and dx > -30.0 and near[r + 6] < 0.3:
				queued += 1
			if dx > 8.0 and not passed.has(slot):
				passed.append(slot)
				if first_pass < 0:
					first_pass = t

	func report(out: Dictionary, at: Vector2, cues: VehicleCues) -> void:
		out["at"] = [at.x, at.y]
		out["horns"] = cues.fired.get(&"horn", 0)
		out["queued_s"] = float(queued) / SimClock.TICK_RATE
		out["passed"] = passed.size()
		out["first_pass_s"] = float(first_pass) / SimClock.TICK_RATE


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
	var passed: int = y["passed"]
	var reason: String = ""
	if blind_hits < 1:
		reason = "the blind arm was never hit: the scene sends no traffic past the car"
	elif hits > 0 or lost > 0.0:
		reason = "traffic still rear-ends a parked car: %s" % str(y)
	elif passed < MIN_PASSED:
		reason = "traffic queues behind a parked car instead of passing it: %s" % str(y)
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
	var rear_ends: int = 0
	var moving: bool = false
	var near: int = 0
	var lane_m: LaneWatch = LaneWatch.new(_lane_cars(city, car.pos))
	for t: int in TICKS:
		world.loop().step()
		near += 1 if not vw.cars_near(car.pos, 14.0).is_empty() else 0
		lane_m.watch(vw.cars_near(car.pos, 40.0), car.pos, t)
		var now: bool = car.speed() > 0.3
		if now and not moving:
			rear_ends += 1
		moving = now
	var out: Dictionary = {"rear_ends": rear_ends, "hp_lost": car.hp_lost, "ticks_near": near}
	lane_m.report(out, car.pos, svc.cues)
	out["cars_alive"] = city.sim.get_counters()[SimConst.CN_CARS]
	world.free()
	bus.free()
	data.free()
	return out


## Three sim cars in the parked car's lane, 20 / 34 / 48 m behind it at 12 m/s: their slots.
static func _lane_cars(city: CitySystem, parked: Vector2) -> Array[int]:
	var slots: Array[int] = []
	for back: float in [20.0, 34.0, 48.0]:
		var at: Vector2 = parked - Vector2(back, 0.0)
		var spec: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, 0, 0, 12.0, at.y, 0]
		slots.append(city.sim.spawn(PackedFloat64Array(spec)))
	return slots
