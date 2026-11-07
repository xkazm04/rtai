extends Scenario
## d9 seams (Call 4): sim traffic and Rivet on foot, on the real World. Rivet stands in a straight
## east-bound lane mid-block; one sim car comes at him from 24 m behind at 12 m/s, 12 s. Arm `n8`
## is the default (CityVehicleWorld.yield_to_rivet off): the car drives through him. Arm `yield`
## turns it on: the car brakes for his ground point like a parked car and never comes within
## CLEAR_M of him (it may pull round him in the oncoming lane, CitySimCarPass). Passes when the
## n8 arm's car comes within THROUGH_M (the scene really sends it through him) and the yield arm's
## closest approach stays over CLEAR_M. Evidence: traffic-yields-rivet.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 53
const TICKS: int = 12 * SimClock.TICK_RATE
const AHEAD_M: float = 32.0
const BACK_M: float = 24.0
const THROUGH_M: float = 1.0
## No contact: the car centre stays past its hull half width (0.95) plus a person (0.4).
## (Measured 2026-11-07: n8 0.10 m, yield 2.44 m: it pulls round him in the next lane.)
const CLEAR_M: float = 1.5


func run(_tree: SceneTree) -> String:
	var summary: Dictionary = {"ticks": TICKS}
	var n8: float = _arm(false)
	var yld: float = _arm(true)
	summary["n8_closest_m"] = n8
	summary["yield_closest_m"] = yld
	var reason: String = ""
	if n8 >= THROUGH_M:
		reason = (
			"the n8 arm's car never reached Rivet (%.2f m): the scene sends nothing through" % n8
		)
	elif yld <= CLEAR_M:
		reason = "traffic still runs into Rivet with the yield on (closest %.2f m)" % yld
	summary["result"] = "pass" if reason == "" else reason
	var err: String = write_evidence("traffic-yields-rivet.json", summary)
	Log.info("scenario", "traffic yields rivet: %s" % JSON.stringify(summary))
	return reason if reason != "" else err


## The closest the lane car comes to Rivet (m) over the run.
static func _arm(on: bool) -> float:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, MASTER_SEED)
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
	return closest
