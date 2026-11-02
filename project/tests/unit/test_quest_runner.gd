extends GutTest
## The objective state machine (F-12): offer -> answer -> beats -> succeeded/failed, on ticks,
## against the stub world; contract_started/completed go out through the injected bus.

var _bus: EventBus
var _world: StubQuestWorld
var _tick: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(QuestFixture.places())
	_tick = 0
	watch_signals(_bus)


func test_offer_rings_at_the_first_location_and_parks_the_job_car() -> void:
	var runner: QuestRunner = _runner(QuestFixture.package())
	runner.offer()
	assert_eq(runner.state, QuestRunner.State.OFFERED)
	assert_eq(runner.phone, Vector2(11.0, 10.5), "loading-bay-3's phone")
	assert_eq(_world.vehicle_at["valet-sedan"], Vector2(5.0, 21.8))
	assert_signal_not_emitted(_bus, "contract_started")


func test_answering_needs_range_foot_and_interact() -> void:
	var runner: QuestRunner = _runner(QuestFixture.package())
	runner.offer()
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.state, QuestRunner.State.OFFERED, "too far from the phone")
	_world.interact = false
	_world.rivet = runner.phone + Vector2(1.0, 0.0)
	_step(runner, 1)
	assert_eq(runner.state, QuestRunner.State.OFFERED, "no press")
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.state, QuestRunner.State.ACTIVE)
	assert_signal_emitted_with_parameters(_bus, "contract_started", [&"_selftest"])
	assert_eq(runner.current_beat().id, "the-bay")


func test_the_fixture_plays_to_success_and_pays_once() -> void:
	var runner: QuestRunner = _started(QuestFixture.package())
	_world.rivet = Vector2(4.5, 8.8)
	_step(runner, 1)
	assert_eq(runner.current_beat().id, "the-sedan")
	_world.rivet = _world.vehicle_at["valet-sedan"]
	assert_true(_world.enter("valet-sedan"))
	_step(runner, 1)
	assert_eq(runner.current_beat().id, "the-gate")
	_world.vehicle_at["valet-sedan"] = Vector2(36.0, 12.5)
	_step(runner, 3)
	assert_eq(runner.state, QuestRunner.State.SUCCEEDED)
	assert_eq([_world.cash, runner.granted_unlocks], [500, ["giver:the-valet"] as Array[String]])
	assert_signal_emit_count(_bus, "contract_completed", 1)
	assert_signal_emitted_with_parameters(_bus, "contract_completed", [&"_selftest"])


func test_heat_is_capped_at_the_peak_while_active() -> void:
	var runner: QuestRunner = _started(QuestFixture.package())
	_world.wanted = 4
	_step(runner, 1)
	assert_eq([_world.wanted, runner.heat_clamps], [2, 1])
	_step(runner, 5)
	assert_eq(runner.heat_clamps, 1, "no clamp once within the peak")


func test_mapped_fail_states_end_the_contract() -> void:
	var runner: QuestRunner = _started(QuestFixture.package())
	_world.wrecked["valet-sedan"] = true
	_step(runner, 1)
	assert_eq([runner.state, runner.fail_reason], [QuestRunner.State.FAILED, &"car_destroyed"])
	runner = _started(QuestFixture.package())
	_world.wrecked.clear()
	_world.dead = true
	_step(runner, 1)
	assert_eq(runner.fail_reason, &"rivet_wasted")
	assert_signal_emit_count(_bus, "contract_completed", 0)


func test_unmapped_fail_states_never_fire() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.difficulty(p)["failStates"] = ["car destroyed"]
	var runner: QuestRunner = _started(QuestFixture.load_raw(p).package)
	_world.dead = true
	_step(runner, 10)
	assert_eq(runner.state, QuestRunner.State.ACTIVE)


func test_timer_beat_and_time_limit_count_ticks() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.objective(p, 0)["verb"] = "survive"
	QuestFixture.objective(p, 0)["durationS"] = 2
	QuestFixture.difficulty(p)["timeLimitS"] = 3
	QuestFixture.difficulty(p)["failStates"] = ["time runs out"]
	var runner: QuestRunner = _started(QuestFixture.load_raw(p).package)
	_step(runner, 119)
	assert_eq(runner.beat_index, 0)
	_step(runner, 1)
	assert_eq(runner.beat_index, 1, "survive 2 s = 120 ticks")
	_step(runner, 60)
	assert_eq(runner.state, QuestRunner.State.ACTIVE, "180 ticks is still inside a 3 s limit")
	_step(runner, 1)
	assert_eq([runner.state, runner.fail_reason], [QuestRunner.State.FAILED, &"timer_expired"])
	assert_eq(runner.active_ticks, 181, "fails on the first tick past 180")


func _runner(pkg: QuestPackage) -> QuestRunner:
	return QuestRunner.new(pkg, _world, _bus, QuestRules.shipped())


func _started(pkg: QuestPackage) -> QuestRunner:
	var runner: QuestRunner = _runner(pkg)
	runner.offer()
	runner.start()
	return runner


func _step(runner: QuestRunner, ticks: int) -> void:
	for i: int in ticks:
		runner.step(_tick)
		_tick += 1
