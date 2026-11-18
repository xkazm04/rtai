extends GutTest
## The shipped pit's 2.4 x 0.8 m cover at (4, 13), with combatants placed by each test.

var stage: ArenaStage
var motion: PlayerMotion
var vault: PlayerVault
var body: Fighter


func before_each() -> void:
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	for station: ArenaStation in stations.stations:
		station.spawns.clear()
	stage = ArenaStage.new(ArenaPlan.shipped(), stations)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 19))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	motion = stage.pilot.motion
	vault = motion.vault
	vault.enabled = true
	body = stage.arena.rivet
	body.pos = Vector2(4.0, 11.75)
	motion.mover.velocity = Vector2.DOWN * 8.0


func _tick(k: int) -> void:
	var bits: int = 1 << stage.pilot.actions.bit(&"roll") if k == 0 else 0
	stage.step(k, TickInput.new(bits, 0, TickInput.AXIS_MAX))


func test_continuous_cover_crossing_and_tackle() -> void:
	var person: Fighter = Fighter.make(Fighter.Kind.GUARD, 190, Vector2(4.0, 14.2), 1.0)
	person.brain_owned = true
	stage.arena.hostiles.append(person)
	var steps: PackedFloat64Array = []
	var air: Array[int] = []
	var tackle_speed: float = 0.0
	var push: float = 0.0
	for k: int in vault.ticks:
		var before: Vector2 = body.pos
		var target: Vector2 = person.pos
		_tick(k)
		var moved: float = body.pos.distance_to(before)
		@warning_ignore("return_value_discarded")
		steps.append(snappedf(moved, 0.0001))
		assert_gt(moved, 0.0)
		assert_lte(moved, 2.0 * vault.start.distance_to(vault.hit.landing) / vault.ticks)
		if vault.airborne():
			air.append(k)
		if person.pos.distance_to(target) > 1.0:
			tackle_speed = moved / SimClock.TICK_DT
			push = person.pos.distance_to(target)
	assert_gt(tackle_speed, ArenaBodies.table().run_mps(RivetBody.CLASS))
	assert_eq(body.pos, vault.hit.landing)
	assert_gt(air.size(), 0)
	Log.info(
		"vault",
		(
			"cover_low steps_m %s; airborne %s; contact %.3f m/s, shove %.3f m"
			% [steps, air, tackle_speed, push]
		)
	)
