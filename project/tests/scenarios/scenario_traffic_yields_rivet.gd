extends Scenario
## d9 seams (Call 4), n9 (the owner's s-4 C): sim traffic and Rivet on foot, on the real World.
## Rivet stands in a straight east-bound lane mid-block; one sim car comes at him from 24 m behind
## at 12 m/s, 12 s. Arm `n8` is the default (CityVehicleWorld.yield_to_rivet off): the car brakes
## for a person in its lane and creeps into him (d9 drove through him at a crawl, 0.10 m); n9 makes
## his body solid to cars, so it stops at his body (closest over THROUGH_M, within TOUCH_M) and,
## under the car_hit threshold, never knocks him down. Arm `yield` turns the yield on: the car
## brakes for his ground point like a parked car and never comes within CLEAR_M of him (it may
## pull round him in the oncoming lane, CitySimCarPass). The car at speed that does knock him down
## is scenario_car_knocks_rivet. Evidence: traffic-yields-rivet.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 53
const TICKS: int = 12 * SimClock.TICK_RATE
const AHEAD_M: float = 32.0
const BACK_M: float = 24.0
const THROUGH_M: float = 1.0
## Touching: the car's half length (2.3) plus his radius, with a margin. (Measured n9: 2.33 m.)
const TOUCH_M: float = 3.0
## No contact: the car centre stays past its hull half width (0.95) plus a person (0.4).
## (Measured 2026-11-07: n8 0.10 m, yield 2.44 m: it pulls round him in the next lane.)
const CLEAR_M: float = 1.5


func run(_tree: SceneTree) -> String:
	var summary: Dictionary = {"ticks": TICKS}
	var n8: Vector2 = _arm(false)
	var yld: Vector2 = _arm(true)
	summary["n8_closest_m"] = n8.x
	summary["n8_knocks"] = n8.y
	summary["yield_closest_m"] = yld.x
	summary["yield_knocks"] = yld.y
	var reason: String = ""
	if n8.x > TOUCH_M:
		reason = "the n8 arm's car never reached Rivet (%.2f m): the scene sends nothing" % n8.x
	elif n8.x <= THROUGH_M:
		reason = "the creeping car drove through Rivet (%.2f m)" % n8.x
	elif n8.y > 0.0:
		reason = "a creeping car knocked Rivet down (%d times)" % int(n8.y)
	elif yld.x <= CLEAR_M or yld.y > 0.0:
		reason = "traffic still runs into Rivet with the yield on (closest %.2f m)" % yld.x
	summary["result"] = "pass" if reason == "" else reason
	var err: String = write_evidence("traffic-yields-rivet.json", summary)
	Log.info("scenario", "traffic yields rivet: %s" % JSON.stringify(summary))
	return reason if reason != "" else err


## The closest the lane car comes to Rivet (m) over the run, and how often he was knocked down.
static func _arm(on: bool) -> Vector2:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, MASTER_SEED)
	var knocks: Array[int] = [0]  # a reference type: the lambda writes the same array
	var on_knock: Callable = func(_h: Vector2, _v: float, _d: float) -> void: knocks[0] += 1
	assert(bus.rivet_knocked.connect(on_knock) == OK)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(30, 40, 0)
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = CityVehicleWorld.new(city)
	vw.yield_to_rivet = on
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = Drive.call(&"_east_lane", city)
	var rivet: Vector2 = lane + Vector2(AHEAD_M, 0.0)
	vw.set_focus(rivet, false)
	var at: Vector2 = rivet - Vector2(BACK_M, 0.0)
	var spec: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, 0, 0, 12.0, at.y, 0]
	var slot: int = city.sim.spawn(PackedFloat64Array(spec))
	var closest: float = INF
	for t: int in TICKS:
		vw.set_focus(rivet, false)  # he stands still: the city steers its target by input
		world.loop().step()
		var near: PackedFloat64Array = vw.cars_near(rivet, 30.0)
		for r: int in range(0, near.size(), 8):
			if int(near[r]) == slot:
				closest = minf(closest, Vector2(near[r + 2], near[r + 3]).distance_to(rivet))
	world.free()
	bus.free()
	data.free()
	return Vector2(closest, float(knocks[0]))
