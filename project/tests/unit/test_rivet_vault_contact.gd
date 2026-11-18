extends GutTest
## A normal movement tick at the narrow gap found by the seeded city approaches.

const START: Vector2 = Vector2(22.548925400, 40.400001526)
const STEP: Vector2 = Vector2(0.009355949, 0.031706274)


func test_second_city_cell_push_would_leave_rivet_in_the_first() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	var events: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(events, data, 19))
	stage.cells = StageCells.shipped()
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.motion.vault.enabled = true
	var body: Fighter = stage.arena.rivet
	body.pos = START
	var probe: VaultProbe = stage.pilot.motion.vault.probe
	probe.city = VaultCity.new(stage.cells)
	assert_true(probe.clear_at(START, body.radius_m))
	assert_true(stage.cells.solid(23, 39))
	assert_true(stage.cells.solid(22, 41))
	var first: Vector2 = stage.cells.push_out(START + STEP, body.radius_m)
	var second: Vector2 = stage.cells.push_out(first, body.radius_m)
	assert_false(probe.clear_at(second, body.radius_m))
	# Reproduce the measured displacement through StagePilot without pressing roll.
	stage.pilot.actions.brake_mps2 = 0.0
	stage.pilot.motion.mover.velocity = STEP / SimClock.TICK_DT
	stage.step(0, TickInput.new())
	assert_eq(body.pos, START)
	assert_true(probe.clear_at(body.pos, body.radius_m))
