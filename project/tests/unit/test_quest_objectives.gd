extends GutTest
## Kill and escort objectives (the handlers the fixture does not walk) and QuestSystem on the
## real SimLoop: it steps on the fixed tick and its state hashes the same on a second run.

var _bus: EventBus
var _world: StubQuestWorld


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(QuestFixture.places())


func test_kill_completes_on_death_and_fails_when_the_target_escapes() -> void:
	var runner: QuestRunner = _started(_with_first({"verb": "kill", "target": "bowler-suit"}, []))
	assert_eq(_world.calls, ["spawn bowler-suit"] as Array[String])
	_world.killed["bowler-suit"] = true
	runner.step(0)
	assert_eq(runner.beat_index, 1)
	_world = StubQuestWorld.new(QuestFixture.places())
	runner = _started(_with_first({"verb": "kill", "target": "bowler-suit"}, ["target escapes"]))
	_world.rivet = Vector2(24.0 + 46.0, 13.3)
	runner.step(0)
	assert_eq(runner.fail_reason, &"target_escapes")


func test_escort_follows_rivet_to_the_marker_and_can_die() -> void:
	var o: Dictionary = {"verb": "escort", "target": "union-steward", "location": "yard-centre"}
	var runner: QuestRunner = _started(_with_first(o, ["the steward dies"]))
	_world.rivet = Vector2(22.0, 12.5)
	var tick: int = 0
	while runner.beat_index == 0 and tick < 600:
		runner.step(tick)
		tick += 1
	assert_eq(runner.beat_index, 1, "the steward walked to yard-centre behind Rivet")
	_world = StubQuestWorld.new(QuestFixture.places())
	runner = _started(_with_first(o, ["the steward dies"]))
	_world.killed["union-steward"] = true
	runner.step(0)
	assert_eq(runner.fail_reason, &"escort_dies")


func test_system_steps_on_the_sim_loop_and_hashes_deterministically() -> void:
	assert_eq(_run_system_hash(), _run_system_hash())
	var world: World = autofree(World.new())
	var data: DataStore = autofree(DataStore.new())
	world.start(_bus, data, 7)
	var system: QuestSystem = QuestSystem.new(_world)
	world.add_system(system)
	assert_true(system.offer(QuestFixture.package()))
	assert_false(system.offer(QuestFixture.package()), "one contract at a time")
	system.runner.start()
	_world.rivet = Vector2(4.5, 8.8)
	world.loop().step()
	assert_eq(system.runner.beat_index, 1)


func _run_system_hash() -> String:
	var world: World = autofree(World.new())
	var data: DataStore = autofree(DataStore.new())
	world.start(_bus, data, 7)
	var stub: StubQuestWorld = StubQuestWorld.new(QuestFixture.places())
	var system: QuestSystem = QuestSystem.new(stub)
	world.add_system(system)
	assert_true(system.offer(QuestFixture.package()))
	system.runner.start()
	for i: int in 90:
		stub.move_toward(Vector2(4.5, 8.8))
		world.loop().step()
	return world.loop().state_hash()


## The fixture with beat 0's objective replaced and the given fail states.
func _with_first(objective: Dictionary, fails: Array) -> QuestPackage:
	var p: Dictionary = QuestFixture.raw()
	var beats: Array = p["beats"]
	var first: Dictionary = beats[0]
	first["objective"] = objective
	QuestFixture.difficulty(p)["failStates"] = fails if not fails.is_empty() else ["Rivet wasted"]
	var result: QuestLoader.Result = QuestFixture.load_raw(p)
	assert_eq(result.report.errors, [] as Array[String])
	return result.package


func _started(pkg: QuestPackage) -> QuestRunner:
	var runner: QuestRunner = QuestRunner.new(pkg, _world, _bus, QuestRules.shipped())
	runner.offer()
	runner.start()
	return runner
