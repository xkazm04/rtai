extends GutTest
## The city street fight's 14 m north wall is centred at base + (12, 7).
## Keep Rivet still and the guard's trigger on cooldown to measure only the approach.

const LIMIT: int = 900
const BASE: Vector2 = Vector2(524, 524)


func _stage() -> ArenaStage:
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(BASE), stations)
	stage.cells = StageCells.shipped()
	var world: World = autofree(World.new())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	world.start(bus, data, 20261109)
	world.add_system(stage)
	stage.arena.hostiles.clear()
	return stage


func _guard(stage: ArenaStage, start: Vector2, told: bool) -> Fighter:
	var guard: Fighter = stage.arena.spawn_guard(start)
	guard.pos = start
	guard.cooldown = ArenaTargets.NEVER
	if told:
		stage.arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())
	return guard


func test_both_guard_brains_round_the_shipped_north_wall() -> void:
	for told: bool in [false, true]:
		var stage: ArenaStage = _stage()
		var guard: Fighter = _guard(stage, BASE + Vector2(12, 4), told)
		var target: Vector2 = BASE + Vector2(12, 11)
		stage.arena.rivet.pos = target
		assert_true(stage.walls.blocks(guard.pos, target))
		var crossed: int = -1
		var clipped: int = 0
		for t: int in range(1, LIMIT + 1):
			var before: Vector2 = guard.pos
			stage.arena.step(t)
			stage._collide_hostiles()
			if stage.walls.blocks(before, guard.pos):
				clipped += 1
			if guard.pos.y >= BASE.y + 7.3 and not stage.walls.blocks(guard.pos, target):
				crossed = t
				break
		gut.p("street wall told=%s crossed=%d final=%s" % [told, crossed, guard.pos])
		assert_gt(crossed, 0, "round the wall inside %d ticks" % LIMIT)
		assert_eq(clipped, 0, "never cross the solid segment")


func test_clear_street_keeps_walk_speed_and_rifle_standoff() -> void:
	for told: bool in [false, true]:
		var stage: ArenaStage = _stage()
		var guard: Fighter = _guard(stage, BASE, told)
		stage.arena.rivet.pos = BASE + Vector2(20, 0)
		var still: int = -1
		for t: int in range(1, LIMIT + 1):
			var before: Vector2 = guard.pos
			stage.arena.step(t)
			stage._collide_hostiles()
			if t == 60:
				assert_almost_eq(guard.pos.x - BASE.x, 3.0, 0.01)
			if guard.pos == before:
				still = t
				break
		gut.p("clear street told=%s first stationary=%d final=%s" % [told, still, guard.pos])
		assert_between(still, 160, 162)
		assert_eq(guard.pos.y, BASE.y)
		assert_almost_eq(guard.pos.distance_to(stage.arena.rivet.pos), 12.0, 0.06)
