extends GutTest
## Quest lines and barks as data (F-12): beat lines queue in order and hold for a time that comes
## from the source text; barks fire once, only while active, the first tick their conditions
## hold, and cut the queue; the subtitle types out through QuestText.

var _bus: EventBus
var _world: StubQuestWorld
var _runner: QuestRunner
var _tick: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_world = StubQuestWorld.new(QuestFixture.places())
	_runner = QuestRunner.new(QuestFixture.package(), _world, _bus, QuestRules.shipped())
	_tick = 0
	_runner.offer()


func test_duration_is_typed_time_plus_hold_clamped() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var line: QuestLine = QuestLine.new()
	line.text = "Hi."
	assert_eq(line.duration_ticks(rules), 132, "2.2 s floor")
	line.text = "x".repeat(900)
	assert_eq(line.duration_ticks(rules), 540, "9 s ceiling")
	line.text = "x".repeat(180)
	assert_eq(line.duration_ticks(rules), 324, "180 / 45 + 1.4 = 5.4 s")


func test_beat_lines_play_in_order_each_for_its_duration() -> void:
	_runner.start()
	_step(1)
	assert_eq(_runner.lines.current.id, "patch-ring-1")
	var first: int = _runner.lines.current.duration_ticks(QuestRules.shipped())
	_step(first)
	assert_eq(_runner.lines.current.id, "rivet-answer-1")
	_step_until_idle()
	assert_eq(_shown_ids(), ["patch-ring-1", "rivet-answer-1", "patch-job-1"] as Array[String])


func test_barks_wait_for_active_and_fire_once() -> void:
	_world.soul = "hauler"
	_step(5)
	assert_eq(_runner.lines.armed_barks(), 2, "offered is not active: no barks")
	_runner.start()
	_step(1)
	assert_eq(_runner.lines.armed_barks(), 1)
	assert_true(_runner.lines.shown[0].bark, "a bark cuts ahead of the beat's queued lines")
	assert_eq(_runner.lines.shown[0].line_id, "hauler-bark-1")
	_world.soul = "rivet"
	_step(1)
	_world.soul = "hauler"
	_step_until_idle()
	assert_eq(_shown_ids().count("hauler-bark-1"), 1)


func test_bark_never_interrupts_the_line_on_screen() -> void:
	_runner.start()
	_step(10)
	_world.wanted = 3
	_step(1)
	assert_eq(_runner.lines.current.id, "patch-ring-1", "the bark waits for the line to end")
	assert_eq(_world.wanted, 2, "clamped to heatPeak, and heat:>=2 still holds")
	_step_until_idle()
	assert_eq(_shown_ids().slice(0, 2), ["patch-ring-1", "patch-heat-1"] as Array[String])


func test_subtitle_types_out_with_the_speaker_name() -> void:
	_runner.start()
	_step(1)
	var text: QuestText = QuestText.new()
	assert_eq(_runner.lines.subtitle(text), PackedStringArray(["Patch", ""]))
	_step(60)
	var sub: PackedStringArray = _runner.lines.subtitle(text)
	var want: String = "Patch. You picked up on the ninth ring, a rec"
	assert_eq(sub[1], want, "60 ticks at 45 chars/s = 45 chars")
	assert_false(_runner.lines.fully_typed())


func _shown_ids() -> Array[String]:
	var ids: Array[String] = []
	for s: QuestLinePlayer.Shown in _runner.lines.shown:
		ids.append(s.line_id)
	return ids


func _step(ticks: int) -> void:
	for i: int in ticks:
		_runner.step(_tick)
		_tick += 1


func _step_until_idle() -> void:
	_step(1)
	while _runner.lines.busy() and _tick < 10000:
		_step(1)
