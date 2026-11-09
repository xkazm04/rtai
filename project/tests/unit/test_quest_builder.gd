extends GutTest
## Direct builder tests: required shapes, defaults and fallbacks without QuestValidator.

var _rules: QuestRules


func before_each() -> void:
	_rules = QuestRules.from_json_text(FileAccess.get_file_as_string(QuestRules.PATH))
	assert_true(_rules.ok(), str(_rules.errors()))
	_rules.tuning["survive_default_s"] = 7.25
	for id: String in ["reach", "wait_here"]:
		var verb: QuestVerb = QuestVerb.new()
		verb.id = id
		verb.handler = QuestRules.Handler.REACH if id == "reach" else QuestRules.Handler.TIMER
		_rules.verbs[id] = verb


func _raw() -> Dictionary:
	var first: Dictionary = {
		"id": "z-first", "speaker": "patch", "text": "Hello", "purpose": ["brief", "warn"]
	}
	var second: Dictionary = {
		"id": "a-second", "speaker": "rivet", "text": "Ready", "purpose": ["reply"]
	}
	second["audio"] = "res://assets/audio/voice/brass-gloria.ogg"
	second["when"] = ["heat:>=2", "kill"]
	var arrive: Dictionary = {"id": "z-arrive", "title": "Reach the bay"}
	arrive["objective"] = {"verb": "reach", "target": "door", "location": "bay"}
	arrive["lineIds"] = ["a-second", "z-first"]
	var wait: Dictionary = {"id": "a-wait", "title": "Wait here", "lineIds": []}
	wait["objective"] = {"verb": "wait_here"}
	return {
		"id": "builder-quest",
		"title": "A builder quest",
		"act": "act2",
		"characters": [{"id": "rivet", "name": "Rivet"}, {"id": "patch", "name": "Patch"}],
		"lines": [first, second],
		"beats": [arrive, wait],
		"reward": {"cash": 12.5, "unlocks": ["giver:patch", "next-quest"]},
		"difficulty": {"heatPeak": 2.9, "timeLimitS": null, "failStates": []},
		"story": {"writes": [{"var": "done", "value": true}, {"var": "visits", "value": 3}]},
	}


func _timed(objective: Dictionary) -> QuestBeat:
	var raw: Dictionary = _raw()
	raw["beats"] = [{"id": "timer", "title": "Hold", "objective": objective, "lineIds": []}]
	return QuestBuilder.build(raw, _rules).beats[0]


func test_package_copies_identity_characters_rewards_and_story_values() -> void:
	var pkg: QuestPackage = QuestBuilder.build(_raw(), _rules)
	assert_eq([pkg.id, pkg.title, pkg.act], [&"builder-quest", "A builder quest", "act2"])
	assert_eq(pkg.characters, {"rivet": "Rivet", "patch": "Patch"} as Dictionary[String, String])
	assert_eq(pkg.reward_cash, 13, "cash rounds instead of truncating")
	assert_eq(pkg.unlocks, ["giver:patch", "next-quest"] as Array[String])
	assert_eq(pkg.story_writes, {"done": true, "visits": 3} as Dictionary[String, Variant])
	assert_eq(pkg.heat_peak, 2, "heat floors instead of rounding")
	assert_eq(pkg.time_limit_ticks, -1, "null leaves the no-limit sentinel")
	assert_true(pkg.fail_codes.is_empty())


func test_lines_keep_source_order_fields_and_quest_scoped_keys() -> void:
	var pkg: QuestPackage = QuestBuilder.build(_raw(), _rules)
	assert_eq(pkg.lines.size(), 2)
	assert_eq(pkg.line_order, ["z-first", "a-second"] as Array[String])
	var first: QuestLine = pkg.lines["z-first"]
	assert_eq([first.id, first.speaker, first.text], ["z-first", "patch", "Hello"])
	assert_eq(first.key, &"QUEST__BUILDER_QUEST__LINE__Z_FIRST")
	assert_eq(first.purposes, ["brief", "warn"] as Array[String])
	assert_eq(first.voice_s, 0.0, "omitted audio is silent")
	assert_true(first.conditions.is_empty(), "omitted when is unconditional")
	var second: QuestLine = pkg.lines["a-second"]
	assert_eq([second.speaker, second.text], ["rivet", "Ready"])
	assert_eq(second.key, &"QUEST__BUILDER_QUEST__LINE__A_SECOND")
	assert_eq(second.purposes, ["reply"] as Array[String])
	assert_gt(second.voice_s, 0.0, "a known clip gives the line its length")
	assert_eq(second.conditions.size(), 2)
	var heat: QuestCondition = second.conditions[0]
	assert_eq([heat.kind, heat.op], [QuestCondition.Kind.HEAT, QuestCondition.Op.GE])
	assert_eq([heat.n, heat.error], [2, ""])
	var event: QuestCondition = second.conditions[1]
	assert_eq(event.kind, QuestCondition.Kind.EVENT)
	assert_eq([event.value, event.error], ["actor_killed:by_player", ""])


func test_unknown_audio_is_silent_and_condition_errors_are_retained() -> void:
	var raw: Dictionary = _raw()
	var lines: Array = raw["lines"]
	var row: Dictionary = lines[0]
	row["audio"] = "res://assets/audio/voice/no-such-builder-voice.ogg"
	row["when"] = ["soul:toaster"]
	row["purpose"] = []
	var line: QuestLine = QuestBuilder.build(raw, _rules).lines["z-first"]
	assert_eq(line.voice_s, 0.0)
	assert_true(line.purposes.is_empty())
	assert_eq(line.conditions.size(), 1, "builder does not discard invalid conditions")
	assert_string_contains(line.conditions[0].error, "unknown soul 'toaster'")


func test_beats_keep_order_and_resolve_handler_from_the_supplied_rules() -> void:
	var pkg: QuestPackage = QuestBuilder.build(_raw(), _rules)
	assert_eq(pkg.beats.size(), 2)
	var first: QuestBeat = pkg.beats[0]
	assert_eq([first.id, first.title], ["z-arrive", "Reach the bay"])
	assert_eq(first.title_key, &"QUEST__BUILDER_QUEST__BEAT__Z_ARRIVE")
	assert_eq([first.verb, first.target, first.location], ["reach", "door", "bay"])
	assert_eq(first.handler, QuestRules.Handler.REACH)
	assert_eq(first.line_ids, ["a-second", "z-first"] as Array[String])
	assert_eq(first.length_ticks, 0, "ordinary beats have no timer")
	var second: QuestBeat = pkg.beats[1]
	assert_eq([second.id, second.title], ["a-wait", "Wait here"])
	assert_eq(second.title_key, &"QUEST__BUILDER_QUEST__BEAT__A_WAIT")
	assert_eq([second.verb, second.target, second.location], ["wait_here", "", ""])
	assert_eq(second.handler, QuestRules.Handler.TIMER)
	assert_true(second.line_ids.is_empty())
	assert_eq(second.length_ticks, 435, "default comes from the injected rules")


func test_non_timer_ignores_duration_and_a_legacy_timer_target() -> void:
	var beat: QuestBeat = _timed({"verb": "reach", "target": "12s", "durationS": 2.5})
	assert_eq(beat.handler, QuestRules.Handler.REACH)
	assert_eq(beat.length_ticks, 0)
	assert_eq(beat.target, "12s")


func test_explicit_duration_wins_and_rounds_up_at_tick_boundaries() -> void:
	var cases: Dictionary[float, int] = {0.0: 0, 0.01: 1, 0.5: 30, 0.5001: 31, 1.25: 75}
	for seconds: float in cases:
		var beat: QuestBeat = _timed({"verb": "wait_here", "target": "12s", "durationS": seconds})
		assert_eq(beat.length_ticks, cases[seconds], str(seconds))
		assert_eq(beat.target, "12s", "timing does not rewrite the target")


func test_present_non_numeric_duration_becomes_zero_instead_of_using_target_or_default() -> void:
	for value: Variant in [null, "3", true]:
		var beat: QuestBeat = _timed({"verb": "wait_here", "target": "12s", "durationS": value})
		assert_eq(beat.length_ticks, 0, str(value))


func test_legacy_timer_requires_both_lowercase_suffix_and_numeric_prefix() -> void:
	var cases: Dictionary[String, int] = {
		"0s": 0, "0.01s": 1, "0.5s": 30, "0.5001s": 31, "12s": 720
	}
	for target: String in cases:
		var beat: QuestBeat = _timed({"verb": "wait_here", "target": target})
		assert_eq(beat.length_ticks, cases[target], target)
	for target: String in ["", "12", "12S", "s", "nans", "12ss"]:
		assert_eq(_timed({"verb": "wait_here", "target": target}).length_ticks, 435, target)


func test_cash_and_heat_round_at_boundaries_and_use_zero_for_non_numbers() -> void:
	var raw: Dictionary = _raw()
	var reward: Dictionary = raw["reward"]
	var difficulty: Dictionary = raw["difficulty"]
	var cash_cases: Dictionary[Variant, int] = {
		0.0: 0, 12.49: 12, 12.5: 13, 12.51: 13, null: 0, "12": 0, true: 0
	}
	for cash: Variant in cash_cases:
		reward["cash"] = cash
		assert_eq(QuestBuilder.build(raw, _rules).reward_cash, cash_cases[cash], str(cash))
	var heat_cases: Dictionary[Variant, int] = {
		0.0: 0, 1.999: 1, 2.0: 2, 2.001: 2, null: 0, "12": 0, true: 0
	}
	for heat: Variant in heat_cases:
		difficulty["heatPeak"] = heat
		assert_eq(QuestBuilder.build(raw, _rules).heat_peak, heat_cases[heat], str(heat))


func test_time_limit_distinguishes_null_zero_and_fractional_seconds() -> void:
	var raw: Dictionary = _raw()
	var difficulty: Dictionary = raw["difficulty"]
	var limits: Array[Variant] = [null, 0, 0.01, 0.5, 0.5001, "bad"]
	var ticks: Array[int] = [-1, 0, 1, 30, 31, 0]
	for i: int in limits.size():
		difficulty["timeLimitS"] = limits[i]
		assert_eq(QuestBuilder.build(raw, _rules).time_limit_ticks, ticks[i], str(limits[i]))


func test_failure_phrases_keep_original_keys_and_omit_unmapped_codes() -> void:
	var raw: Dictionary = _raw()
	var difficulty: Dictionary = raw["difficulty"]
	difficulty["failStates"] = ["Rivet wasted", "the Valet sulks", "car destroyed"]
	var pkg: QuestPackage = QuestBuilder.build(raw, _rules)
	var expected: Dictionary[String, StringName] = {
		"Rivet wasted": &"rivet_wasted", "car destroyed": &"car_destroyed"
	}
	assert_eq(pkg.fail_codes, expected)


func test_empty_collections_build_empty_typed_outputs() -> void:
	var raw: Dictionary = _raw()
	for key: String in ["characters", "lines", "beats"]:
		raw[key] = []
	raw["story"] = {"writes": []}
	raw["reward"] = {"cash": 0, "unlocks": []}
	var pkg: QuestPackage = QuestBuilder.build(raw, _rules)
	assert_eq([pkg.lines.size(), pkg.line_order.size(), pkg.beats.size()], [0, 0, 0])
	assert_eq([pkg.characters.size(), pkg.story_writes.size(), pkg.unlocks.size()], [0, 0, 0])
