extends GutTest
## Quest 1's job beats on the merged runtime (F-12b vocabulary, q1 behaviour), against the
## stage's own places table: the package loads clean there, a call holds its lines until the
## router connects it and the beat ends when the call does, a meet plays each ally's lines when
## Rivet meets them (never while hot), and a bark listed in a later beat is not armed early.

const H: Dictionary = {
	"evade": QuestRules.Handler.EVADE,
	"answer": QuestRules.Handler.ANSWER,
	"meet": QuestRules.Handler.MEET,
	"fight": QuestRules.Handler.FIGHT,
	"sabotage": QuestRules.Handler.SABOTAGE,
}

var _bus: EventBus
var _world: StubQuestWorld
var _tick: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(_places())
	_tick = 0


func test_collect_call_loads_clean_against_the_stage_places() -> void:
	var loaded: QuestLoader.Result = _load()
	assert_eq(loaded.report.errors, [] as Array[String])
	assert_eq(loaded.report.warnings, [] as Array[String], "encounters add up to 49 / 6")
	var handlers: Array = []
	for beat: QuestBeat in loaded.package.beats:
		handlers.append(beat.handler)
	assert_eq(handlers, [H.evade, H.answer, H.meet, H.fight, H.sabotage, H.evade])
	assert_eq(loaded.package.lines.size(), 23)


func test_the_meet_allies_are_the_actors_voicing_the_beat() -> void:
	var runner: QuestRunner = _active_at(2)
	var want: Array[String] = ["Brass", "Don Fax", "Dr. Kilohm", "Juno"]
	assert_eq(runner.objective.meet_tags, want)
	assert_eq(_world.actor_at.size(), 4, "each ally is spawned at their place")
	assert_false(runner.lines.busy(), "nobody talks before they are met")


func test_a_call_holds_its_lines_until_it_connects_and_ends_with_them() -> void:
	var runner: QuestRunner = _active_at(5)
	assert_true(runner.objective.is_call(), "an evade at a payphone place")
	_world.wanted = 2
	_step(runner, 3)
	assert_false(_world.calls.has("ring Harbor Road"), "hot: no call on the phone yet")
	assert_false(runner.lines.busy(), "the call's lines wait for the call")
	_world.wanted = 0
	_step(runner, 1)
	assert_true(_world.calls.has("ring Harbor Road"))
	_world.rivet = _places().markers["Harbor Road"].phone
	_world.interact = true
	_step(runner, 1)
	assert_eq(runner.lines.current.id, "fax-confirm-receipt", "connected: Don speaks")
	assert_eq(runner.state, QuestRunner.State.ACTIVE, "the beat waits for the call")
	_step_until(runner, func() -> bool: return runner.state != QuestRunner.State.ACTIVE)
	assert_eq(runner.state, QuestRunner.State.SUCCEEDED)
	assert_eq(_world.cash, 1500)
	assert_true(_ids(runner).has("rivet-i-have-a-job"))


func test_meet_plays_each_ally_when_met_and_never_while_hot() -> void:
	var runner: QuestRunner = _active_at(2)
	_world.rivet = _places().actors["Juno"].at
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
		_world.rivet = _places().actors[tag].at
		_world.interact = true
		_step(runner, 1)
	assert_eq(runner.beat_index, 2, "the beat waits for the conversation")
	_step_until(runner, func() -> bool: return runner.beat_index == 3)
	assert_eq(_ids(runner)[-1], "fax-dock-brief")
	assert_true(_world.calls.has("encounter Dock 9 bonded storage"))


## F-12b's rule, on q1's case of one tag in two beats: b3's whisper bark is armed only from b3.
func test_a_later_beats_bark_is_not_armed_early() -> void:
	_world.wanted = 2
	var runner: QuestRunner = _active_at(0)
	_bus.whispers_spiked.emit()
	_step(runner, 1)
	_step_until(runner, func() -> bool: return not runner.lines.busy())
	var ids: Array[String] = _ids(runner)
	assert_true(ids.has("rivet-my-hands"), "b1's whisper bark")
	assert_false(ids.has("rivet-buildings-talk"), "b3's whisper bark waits for b3")


func _places() -> QuestPlaces:
	return QuestFixture.stage_places()


func _load() -> QuestLoader.Result:
	return QuestFixture.stage_load()


## A started runner moved straight to beat `i`, with nothing left queued from earlier beats.
func _active_at(i: int) -> QuestRunner:
	var runner: QuestRunner = QuestRunner.new(_load().package, _world, _bus, QuestRules.shipped())
	runner.offer()
	if i > 0:
		runner.lines = QuestLinePlayer.new(runner.pkg, QuestRules.shipped())
		runner.call("_begin_beat", i)
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


func _ids(runner: QuestRunner) -> Array[String]:
	var out: Array[String] = []
	for s: QuestLinePlayer.Shown in runner.lines.shown:
		out.append(s.line_id)
	return out
