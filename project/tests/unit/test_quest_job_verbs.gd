extends GutTest
## The job verbs added for quest 1 (evade, answer, meet, fight, sabotage), the cue barks scoped
## to their beat, and the collect-call package loading clean against its places table.

const H: Dictionary = {
	"evade": QuestRules.Handler.EVADE,
	"answer": QuestRules.Handler.ANSWER,
	"meet": QuestRules.Handler.MEET,
	"fight": QuestRules.Handler.FIGHT,
	"sabotage": QuestRules.Handler.SABOTAGE,
}

var _bus: EventBus
var _world: JobStubWorld
var _tick: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = JobStubWorld.new(JobStubWorld.collect_call_places())
	_tick = 0


func test_collect_call_loads_with_no_errors() -> void:
	var loaded: QuestLoader.Result = JobStubWorld.collect_call()
	assert_eq(loaded.report.errors, [] as Array[String])
	var pkg: QuestPackage = loaded.package
	assert_not_null(pkg)
	var handlers: Array = []
	for beat: QuestBeat in pkg.beats:
		handlers.append(beat.handler)
	var want: Array = [H.evade, H.answer, H.meet, H.fight, H.sabotage, H.evade]
	assert_eq(handlers, want)
	assert_eq(pkg.lines.size(), 23)
	assert_eq([pkg.beats[0].then_answer, pkg.beats[5].then_answer], [false, true])
	assert_eq(pkg.beats[2].targets, ["Juno", "Brass", "Dr. Kilohm", "Don Fax"] as Array[String])
	assert_eq(pkg.heat_peak, 3)
	assert_eq(pkg.reward_cash, 1500)


func test_evade_then_answer_rings_at_heat_zero_and_talks_before_it_ends() -> void:
	var runner: QuestRunner = _active_at(5)
	_world.wanted = 2
	_step(runner, 3)
	assert_eq(_world.asks, [] as Array[String], "hot: no ring asked yet")
	assert_false(runner.lines.busy(), "the call's lines wait for the call")
	_world.wanted = 0
	_step(runner, 1)
	assert_eq(_world.asks, ["RING_PHONE Harbor Road"] as Array[String])
	_world.reach(QuestWorld.Goal.PHONE_CONNECTED, "Harbor Road")
	_step(runner, 1)
	assert_eq(runner.lines.current.id, "fax-confirm-receipt", "connected: Don speaks")
	assert_eq(runner.state, QuestRunner.State.ACTIVE, "the beat waits for the call")
	_step_until_done(runner)
	assert_eq(runner.state, QuestRunner.State.SUCCEEDED)
	assert_eq(_world.cash, 1500)
	assert_true(_ids(runner).has("rivet-i-have-a-job"))


func test_meet_plays_each_ally_when_met_and_never_while_hot() -> void:
	var runner: QuestRunner = _active_at(2)
	assert_false(runner.lines.busy(), "nobody talks before they are met")
	var juno: Vector2 = _world.places().actors["Juno"].at
	_world.rivet = juno
	_world.wanted = 1
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.objective.met, [] as Array[String], "hot: the door stays shut")
	_world.wanted = 0
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.objective.met, ["Juno"] as Array[String])
	assert_eq(runner.lines.current.id, "juno-load-bearing")
	for tag: String in ["Brass", "Dr. Kilohm", "Don Fax"]:
		_world.rivet = _world.places().actors[tag].at
		_world.interact = true
		_step(runner, 1)
	assert_eq(runner.beat_index, 2, "the beat waits for the conversation")
	_step_until(runner, func() -> bool: return runner.beat_index == 3)
	var last_line: String = _ids(runner)[-1]
	var last_ask: String = _world.asks[-1]
	assert_eq(last_line, "fax-dock-brief")
	assert_eq(last_ask, "START_ENCOUNTER Dock 9 bonded storage")


func test_cue_barks_fire_only_in_the_beat_that_lists_them() -> void:
	_world.wanted = 2
	var runner: QuestRunner = _active_at(0)
	_world.cues["static-whisper-burst"] = true
	_step(runner, 1)
	assert_true(runner.lines.armed_barks() > 0)
	_step_until(runner, func() -> bool: return not runner.lines.busy())
	var ids: Array[String] = _ids(runner)
	assert_true(ids.has("rivet-my-hands"), "b1's whisper bark")
	assert_false(ids.has("rivet-buildings-talk"), "b3's whisper bark waits for b3")


func test_sabotage_starts_its_encounter_on_arrival() -> void:
	var runner: QuestRunner = _active_at(4)
	_step(runner, 2)
	assert_eq(_world.asks, [] as Array[String])
	_world.rivet = _world.places().markers["Dock 9 vault cage"].at
	_step(runner, 1)
	assert_eq(_world.asks, ["START_ENCOUNTER Dock 9 vault cage"] as Array[String])
	_world.reach(QuestWorld.Goal.ENCOUNTER_CLEARED, "Dock 9 vault cage")
	_step(runner, 2)
	assert_eq(runner.beat_index, 4, "Mertz down is not enough: the crates must burn")
	_world.reach(QuestWorld.Goal.SABOTAGED, "Dock 9 vault cage")
	_step(runner, 1)
	assert_eq(runner.beat_index, 5)


## A started runner moved straight to beat `i` (earlier beats skipped by marking them done).
func _active_at(i: int) -> QuestRunner:
	var runner: QuestRunner = QuestRunner.new(
		JobStubWorld.collect_call().package, _world, _bus, QuestRules.shipped()
	)
	runner.offer()
	runner.start()
	if i > 0:
		runner.lines = QuestLinePlayer.new(runner.pkg, QuestRules.shipped())
		runner.call("_begin_beat", i)
	_world.asks.clear()
	return runner


func _step(runner: QuestRunner, n: int) -> void:
	for _i: int in n:
		runner.step(_tick)
		_tick += 1


func _step_until(runner: QuestRunner, done: Callable) -> void:
	var guard: int = 0
	while not done.call() and guard < 60 * 120:
		_step(runner, 1)
		guard += 1


func _step_until_done(runner: QuestRunner) -> void:
	_step_until(runner, func() -> bool: return runner.state != QuestRunner.State.ACTIVE)


func _ids(runner: QuestRunner) -> Array[String]:
	var out: Array[String] = []
	for s: QuestLinePlayer.Shown in runner.lines.shown:
		out.append(s.line_id)
	return out
