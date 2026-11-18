extends GutTest
## n18 police item 2: heat in the streamed city (CityHeat). A sim cop sees Rivet within sight_m
## with a clear line on the cell map; a kill while seen raises heat; unseen, heat drains and a kill
## does not raise it. Map: CityWallMap (wall x 300..302).

const COP: Vector2 = Vector2(296.5, 290.5)

var _bus: EventBus
var _city: CitySystem
var _heat: CityHeat


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_city = CitySystem.new(false)
	_city.sim = CityWallMap.walled(true)
	assert_gte(CityWallMap.spawn_cop(_city.sim, COP), 0)
	_city.sim.step(SimClock.TICK_DT, COP.x, COP.y, COP.x, COP.y)
	_heat = CityHeat.new(_city)
	var ctx: WorldContext = WorldContext.new(_bus, null, null, RngRegistry.new(1))
	_heat.setup(ctx)
	_heat.patrol.want = 0  # one hand-placed cop; the patrol has its own test


func test_a_cop_sees_near_and_in_the_clear_only() -> void:
	var r: float = _heat.meter.sight_m
	assert_true(CityHeat.cop_sees(_city.sim, COP + Vector2(0, 3), r), "3 m, open sidewalk")
	assert_false(CityHeat.cop_sees(_city.sim, COP + Vector2(0, r + 2.0), r), "beyond sight_m")
	assert_false(CityHeat.cop_sees(_city.sim, Vector2(304.5, 290.5), r), "8 m, wall between")


func test_a_kill_in_sight_raises_heat_and_marks_the_last_seen_point() -> void:
	_city.target = COP + Vector2(0, 4)
	_bus.pedestrian_struck.emit(3, true)
	_heat.step(0, TickInput.new())
	assert_eq(_heat.meter.level, 1, "a witnessed kill: heat 1")
	assert_true(_heat.ever_seen)
	assert_eq(_heat.last_seen, _city.target)
	assert_eq(_city.sim.heat_level(), 1, "the level went into the sim (set_heat)")


func test_a_kill_behind_the_wall_raises_nothing_and_heat_drains_unseen() -> void:
	_city.target = Vector2(304.5, 290.5)
	_bus.pedestrian_struck.emit(3, true)
	_heat.step(0, TickInput.new())
	assert_eq(_heat.meter.level, 0, "nobody saw it")
	_heat.meter.set_level(2)
	for t: int in _heat.meter.drain_ticks:
		_heat.step(t, TickInput.new())
	assert_eq(_heat.meter.level, 1, "a level drains per drain_s_per_level out of sight")
	assert_false(_heat.ever_seen)


func test_a_struck_survivor_is_not_a_kill() -> void:
	_city.target = COP + Vector2(0, 4)
	_bus.pedestrian_struck.emit(3, false)
	_heat.step(0, TickInput.new())
	assert_eq(_heat.meter.level, 0)


func test_set_heat_is_clamped_and_reset_by_init() -> void:
	var sim: CitySimRef = CityWallMap.walled(true)
	assert_eq(sim.heat_level(), -1, "default: the pre-n18 police")
	sim.set_heat(7, 1.0, 2.0)
	assert_eq(sim.heat_level(), 3)
	sim.init(7)
	assert_eq(sim.heat_level(), -1)


func test_the_native_backend_takes_the_same_heat_command() -> void:
	if not CitySimNative.available():
		pending("no native library in this build")
		return
	var sim: CitySimBackend = CitySimNative.new()
	sim.init(7)
	assert_eq(sim.heat_level(), -1, "default: the pre-n18 police")
	sim.set_heat(7, 1.0, 2.0)
	assert_eq(sim.heat_level(), 3, "clamped as the reference clamps")
	sim.init(7)
	assert_eq(sim.heat_level(), -1, "init resets it")


## n18 item 3: the heat table's city block reaches the meter and the sim's ladder.
func test_the_city_block_tunes_the_drain_and_the_sim_ladder() -> void:
	var t: CityHeatTune = _heat.tune
	assert_true(t.living, "living police on by default")
	assert_eq(_heat.meter.drain_ticks, t.drain_ticks, "the city drains on its own clock")
	assert_eq(t.drain_ticks, 1500, "25 s per level")
	assert_eq(t.sim_tune.size(), SimConst.PT_LEN)
	assert_eq(t.sim_tune[SimConst.PT_FOOT1], 3.0, "heat 1: three foot cops investigate")
	assert_eq(t.sim_tune[SimConst.PT_FOOT3], 6.0)


## n18 item 3: the patrol keeps city.patrol_cops foot cops on sidewalk cells of the bubble.
func test_the_patrol_fills_the_bubble_with_foot_cops_on_sidewalks() -> void:
	var sim: CitySimRef = CityWallMap.walled(true)
	var patrol: CityPatrol = CityPatrol.new(RngRegistry.new(1).stream(CityPatrol.STREAM), 10)
	var made: int = patrol.tick(sim, Vector2(320.0, 320.0))
	assert_eq(made, 10, "the first tick fills the bubble")
	assert_eq(sim.get_counters()[SimConst.CN_COPS], 0, "counted after the next step")
	sim.step(SimClock.TICK_DT, 320.0, 320.0, 320.0, 320.0)
	assert_eq(sim.get_counters()[SimConst.CN_COPS], 10)
	assert_eq(patrol.tick(sim, Vector2(320.0, 320.0)), 0, "full: nothing more")
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		assert_eq(sim.cell_at(snap[r + 4], snap[r + 5]), SimConst.C_WALK, "on a sidewalk")


## n18 item 6: on quest 1 the stage's own meter drives the sim (CityHeat.quest_meter): the level
## follows the stage's, the last-seen point starts where Rivet starts and moves when the stage
## sees him, and the city's own kill rule and drain do not touch the stage's meter.
func test_quest_mode_forwards_the_stage_meter_to_the_sim() -> void:
	var stage_meter: HeatMeter = HeatMeter.new(_bus)
	stage_meter.set_level(2)
	_city.target = Vector2(280.5, 280.5)
	var q: CityHeat = CityHeat.new(_city)
	q.quest_meter = stage_meter
	q.setup(WorldContext.new(_bus, null, null, RngRegistry.new(1)))
	q.patrol.want = 0
	assert_eq(q.last_seen, Vector2(280.5, 280.5), "the alarm point: where Rivet starts")
	_city.target = Vector2(304.5, 290.5)  # behind the wall: no sim cop sees him
	q.stage_seen = true  # a stage patrol does
	_bus.pedestrian_struck.emit(3, true)
	q.step(0, TickInput.new())
	assert_eq(_city.sim.heat_level(), 2, "the sim answers the stage's level")
	assert_eq(q.last_seen, Vector2(304.5, 290.5), "the stage's sighting moves the point")
	assert_eq(stage_meter.level, 2, "the city's kill rule leaves the stage's meter alone")
	q.stage_seen = false
	for t: int in _heat.meter.drain_ticks + 1:
		q.step(t + 1, TickInput.new())
	assert_eq(stage_meter.level, 2, "the city's drain leaves it alone too (the stage steps it)")
	stage_meter.set_level(0)
	q.step(9999, TickInput.new())
	assert_eq(_city.sim.heat_level(), 0)
