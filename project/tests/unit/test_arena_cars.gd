extends GutTest

const CARS: String = """{"schema": "gtai.arena-station/1", "doc": "t", "lane": "probe",
"stations": [{"id": "car_line", "name": "Cars", "area": "pad", "spawns": [
{"id": "c1", "kind": "car", "at": [-34, 20], "motion": "static", "speed_mps": 0, "span_m": 0},
{"id": "c2", "kind": "car", "at": [-28, 20], "motion": "static", "speed_mps": 0, "span_m": 0}
]}]}"""


func test_car_spawns_park_real_vehicles() -> void:
	var stations: ArenaStations = ArenaStations.shipped()
	assert_false(ArenaCars.wanted(stations), "the shipped arena brings no cars")
	stations.add_text(CARS, "zz-cars.json")
	assert_eq(stations.errors.size(), 0)
	assert_true(ArenaCars.wanted(stations))
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var world: World = World.new()
	world.start(bus, data, 7)
	var plan: ArenaPlan = ArenaPlan.shipped()
	var stage: ArenaStage = ArenaStage.new(plan, stations)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	world.add_system(stage)
	var cars: ArenaCars = ArenaCars.attach(world, stage)
	for i: int in 30:
		world.loop().step()
	assert_eq(stage.cars().size(), 2)
	assert_eq(stage.cars()[0].pos, plan.base + Vector2(-34, 20), "parked cars stay put")
	assert_ne(stage.cars()[0].art, stage.cars()[1].art, "the parked cars vary their art")
	assert_eq(cars.service.driving, null, "on-foot entry is off in the arena")
	cars.service.soul_hijack(stage.cars()[1].id)
	var counts: Dictionary = stage.car_counts()
	var hijacked: int = counts["hijacked"]
	assert_eq(hijacked, 1)
	var tel: Dictionary = stage.telemetry_dict()["cars"]
	var total: int = tel["total"]
	assert_eq(total, 2)
	world.free()
	bus.free()
	data.free()


func test_no_car_spawn_no_cars() -> void:
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.shipped())
	assert_eq(stage.cars().size(), 0)
	assert_false(stage.telemetry_dict().has("cars"))


func test_enemies_outside_the_pit_are_moving_dummies() -> void:
	var stations: ArenaStations = ArenaStations.shipped()
	var before: int = _dummies(stations)
	var pad: String = """{"schema": "gtai.arena-station/1", "doc": "t", "lane": "probe",
"stations": [{"id": "bots", "name": "Bots", "area": "pad", "spawns": [
{"id": "b1", "kind": "enemy", "at": [-18, 21], "motion": "approach", "speed_mps": 1.6,
"span_m": 8}]}, {"id": "pit_bots", "name": "Pit", "area": "pit", "spawns": [
{"id": "p1", "kind": "enemy", "at": [20, 30], "motion": "static", "speed_mps": 0,
"span_m": 0}]}]}"""
	stations.add_text(pad, "zz-pad.json")
	assert_eq(stations.errors.size(), 0)
	assert_eq(_dummies(stations), before + 1, "the pad's enemy is a dummy, the pit's is not")


func _dummies(stations: ArenaStations) -> int:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var world: World = World.new()
	world.start(bus, data, 7)
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	world.add_system(stage)
	var n: int = stage.targets.targets.size()
	world.free()
	bus.free()
	data.free()
	return n
