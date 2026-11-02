extends GutTest
## collect-call's verbs, one handler each (F-12b): evade (with and without a payphone), answer
## and meet gated by arrived_hot, meet waiting for its lines, fight and sabotage on the world's
## encounters; and a contract whose first place has no payphone begins on offer. A call (answer,
## or evade at a payphone place) holds its lines until it connects and ends when they have played
## (quest 1's behaviour, int-q1).

var _bus: EventBus
var _world: StubQuestWorld
var _tick: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(QuestFixture.cc_places())
	_tick = 0
	watch_signals(_bus)


func test_the_shipped_package_loads_with_no_errors_or_warnings() -> void:
	var result: QuestLoader.Result = QuestFixture.cc_load()
	assert_eq(result.report.errors, [] as Array[String])
	assert_eq(result.report.warnings, [] as Array[String])
	assert_eq(result.package.beats.size(), 6)
	assert_true(
		result.package.has_fail(&"arrived_hot") and result.package.has_fail(&"rivet_wasted")
	)


func test_no_payphone_at_the_first_place_begins_on_offer() -> void:
	var runner: QuestRunner = _runner()
	runner.offer()
	assert_eq(runner.state, QuestRunner.State.ACTIVE)
	assert_signal_emitted_with_parameters(_bus, "contract_started", [&"collect-call"])


func test_evade_without_a_phone_is_done_at_heat_zero() -> void:
	var runner: QuestRunner = _at_beat(0)
	_world.wanted = 1
	_step(runner, 5)
	assert_eq(runner.beat_index, 0)
	_world.wanted = 0
	_step(runner, 1)
	assert_eq(runner.beat_index, 1)


func test_answer_rings_only_when_cold() -> void:
	var runner: QuestRunner = _at_beat(1)
	_world.rivet = Vector2(24.0, 1.0)
	_world.wanted = 1
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.beat_index, 1, "Patch drops a hot caller")
	assert_true(runner.objective.refused_hot)
	_world.wanted = 0
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.beat_index, 1, "connected: the call's four lines play first")
	assert_true(runner.timeline.any(func(l: String) -> bool: return l.ends_with("call connected")))
	assert_true(
		runner.timeline.any(func(l: String) -> bool: return l.ends_with("payphone ringing"))
	)
	_step_until_idle(runner)
	assert_eq(runner.beat_index, 2)


func test_meet_needs_cold_arrival_and_waits_for_the_conversation() -> void:
	var runner: QuestRunner = _at_beat(2)
	_world.rivet = Vector2(60.0, 20.0)
	_world.wanted = 1
	_step(runner, 1)
	assert_eq(runner.beat_index, 2)
	_world.wanted = 0
	_step(runner, 1)
	assert_eq(runner.beat_index, 2, "8 lines to hear first")
	while runner.lines.busy() and _tick < 20000:
		_step(runner, 1)
	_step(runner, 1)
	assert_eq(runner.beat_index, 3)


func test_fight_runs_the_places_encounter_until_cleared() -> void:
	var runner: QuestRunner = _at_beat(3)
	assert_eq(_world.encounters_started, ["Dock 9 bonded storage"] as Array[String])
	_step(runner, 10)
	assert_eq(runner.beat_index, 3)
	_world.cleared["Dock 9 bonded storage"] = true
	_step(runner, 1)
	assert_eq(runner.beat_index, 4)


func test_sabotage_needs_the_encounter_cleared_then_an_interact_at_the_marker() -> void:
	var runner: QuestRunner = _at_beat(4)
	_world.rivet = Vector2(156.0, 20.0)
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.beat_index, 4, "Mertz still stands")
	_world.cleared["Dock 9 vault cage"] = true
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.beat_index, 5)
	assert_true(runner.facts.recent("quest:sabotage_done"))


func test_evade_at_a_payphone_place_ends_with_the_answer() -> void:
	var runner: QuestRunner = _at_beat(5)
	_world.wanted = 0
	_step(runner, 1)
	assert_true(runner.objective.ringing)
	_world.rivet = Vector2(120.0, -28.0)
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.state, QuestRunner.State.ACTIVE, "the call's lines first")
	_step_until_idle(runner)
	assert_eq(runner.state, QuestRunner.State.SUCCEEDED)
	assert_eq(_world.cash, 1500)


func test_validator_needs_an_encounter_for_fight() -> void:
	var raw: Dictionary = QuestJson.parse_object(
		FileAccess.get_file_as_string("res://quests/collect-call/quest.json")
	)
	var beats: Array = raw["beats"]
	var dock: Dictionary = beats[3]
	var o: Dictionary = dock["objective"]
	o["location"] = "The Toner Room"
	var result: QuestLoader.Result = QuestLoader.from_dict(
		raw, QuestFixture.CC_ID, QuestRules.shipped(), QuestFixture.cc_places()
	)
	assert_true(
		result.report.errors.has(
			"beats[3].objective.location: 'The Toner Room' holds no encounter for 'fight'"
		)
	)
	o["location"] = "Dock 9 bonded storage"
	var difficulty: Dictionary = raw["difficulty"]
	difficulty["enemyCount"] = 50
	result = QuestLoader.from_dict(
		raw, QuestFixture.CC_ID, QuestRules.shipped(), QuestFixture.cc_places()
	)
	assert_string_contains(str(result.report.warnings), "enemyCount 50 / enemyWaves 6")


## A runner already on beat `i` (earlier beats skipped by jumping the objective).
func _at_beat(i: int) -> QuestRunner:
	var runner: QuestRunner = _runner()
	runner.offer()
	while runner.beat_index < i:
		runner._begin_beat(runner.beat_index + 1)
	return runner


func _runner() -> QuestRunner:
	return QuestRunner.new(QuestFixture.cc_load().package, _world, _bus, QuestRules.shipped())


func _step_until_idle(runner: QuestRunner) -> void:
	while runner.lines.busy() and _tick < 20000:
		_step(runner, 1)
	_step(runner, 1)


func _step(runner: QuestRunner, ticks: int) -> void:
	for n: int in ticks:
		runner.step(_tick)
		_tick += 1
