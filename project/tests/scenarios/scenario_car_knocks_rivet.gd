extends Scenario
## n9 (the owner's s-4 C): a car at speed knocks Rivet down, on the real World. One sim car runs
## east down a straight lane at 12 m/s; Rivet waits on the kerb side LATERAL_M off its line and
## runs across (RUN_MPS) when the car's centre is START_M behind him: too late for the car's
## people brake. Passes when exactly one Events.rivet_knocked arrives (a second contact while he
## lies is ignored), its speed is at or over the bodies.json car_hit threshold, its heading is the
## car's (east), and he slides SLIDE_MIN_M or more along it. The creeping car (it brakes for him
## and touches at a crawl: no knock) is scenario_traffic_yields_rivet's n8 arm.
## Evidence: car-knocks-rivet.json.

const Drive: GDScript = preload("res://tests/scenarios/scenario_vehicle_drive.gd")
const MASTER_SEED: int = 53
const TICKS: int = 8 * SimClock.TICK_RATE
const AHEAD_M: float = 40.0
const BACK_M: float = 30.0
const LATERAL_M: float = 2.5
const RUN_MPS: float = 6.0
const START_M: float = 6.0
const SLIDE_MIN_M: float = 1.0


func run(_tree: SceneTree) -> String:
	var out: Dictionary = _arm()
	var reason: String = ""
	var threshold: float = BodyTable.load_default().car_hit.x
	if threshold <= 0.0:
		reason = "bodies.json car_hit.speed_mps is 0: cars never knock Rivet down"
	elif out["knocks"] != 1:
		reason = "expected one knock-down, got %d" % out["knocks"]
	elif out["speed"] < threshold or out["heading_x"] < 0.9:
		reason = "the knock is not the car's: %s" % str(out)
	elif out["slide_m"] < SLIDE_MIN_M:
		reason = "he did not slide along the car (%.2f m)" % out["slide_m"]
	out["threshold_mps"] = threshold
	out["result"] = "pass" if reason == "" else reason
	var err: String = write_evidence("car-knocks-rivet.json", out)
	Log.info("scenario", "car knocks rivet: %s" % JSON.stringify(out))
	return reason if reason != "" else err


static func _arm() -> Dictionary:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, MASTER_SEED)
	var hits: Array = []  # a reference type: the lambda appends to the same array
	var on_knock: Callable = func(h: Vector2, v: float, d: float) -> void: hits.append([h, v, d])
	assert(bus.rivet_knocked.connect(on_knock) == OK)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(0, 0, 0)  # an empty street: only the test car
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = Drive.call(&"_east_lane", city)
	var cross_x: float = lane.x + AHEAD_M
	var rivet: Vector2 = Vector2(cross_x, lane.y - LATERAL_M)
	var at: Vector2 = Vector2(cross_x - BACK_M, lane.y)
	var spec: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, 0, 0, 12.0, at.y, 0]
	var slot: int = city.sim.spawn(PackedFloat64Array(spec))
	var out: Dictionary = {"knocks": 0, "speed": 0.0, "heading_x": 0.0, "slide_m": 0.0}
	var hit_at: Vector2 = _cross(world, vw, [slot, rivet, lane.y], hits, out)
	if hit_at != Vector2.INF:
		out["slide_m"] = city.body.pos.distance_to(hit_at)
	if not hits.is_empty():
		out["speed"] = hits[0][1]
		var heading: Vector2 = hits[0][0]
		out["heading_x"] = heading.x
		out["damage"] = hits[0][2]
	out["knocks"] = hits.size()
	world.free()
	bus.free()
	data.free()
	return out


## Runs the scene: Rivet crosses once the car is START_M behind, then lies where the knock left him.
## `scene` = [car slot, Rivet's start, the lane's y]. Returns where he was hit (INF: never).
static func _cross(
	world: World, vw: CityVehicleWorld, scene: Array, hits: Array, out: Dictionary
) -> Vector2:
	var slot: int = scene[0]
	var rivet: Vector2 = scene[1]
	var lane_y: float = scene[2]
	var cross_x: float = rivet.x
	var running: bool = false
	var hit_at: Vector2 = Vector2.INF
	for t: int in TICKS:
		if hits.is_empty():
			var car_x: float = _car_x(vw, slot, rivet)
			running = running or (car_x > -INF and cross_x - car_x <= START_M)
			if running:
				rivet.y = minf(lane_y, rivet.y + RUN_MPS * SimClock.TICK_DT)
			vw.set_focus(rivet, false)
		elif hit_at == Vector2.INF:
			hit_at = vw.player_pos()
			out["hit_tick"] = t
		world.loop().step()
	return hit_at


## The test car's x, or -INF while it is not within 30 m of Rivet.
static func _car_x(vw: CityVehicleWorld, slot: int, rivet: Vector2) -> float:
	var near: PackedFloat64Array = vw.cars_near(rivet, 30.0)
	for r: int in range(0, near.size(), 8):
		if int(near[r]) == slot:
			return near[r + 2]
	return -INF
