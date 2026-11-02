extends GutTest
## quest_rules.json (DAT-01/05): the shipped table loads typed; fail-state words map to codes in
## rule order; bark conditions parse or say why not; a bad table builds nothing.


func test_shipped_table_loads() -> void:
	var rules: QuestRules = QuestRules.shipped()
	assert_true(rules.ok(), str(rules.errors()))
	assert_eq(rules.verbs.size(), 9)
	assert_eq(rules.verbs["steal"].handler, QuestRules.Handler.ENTER_VEHICLE)
	assert_true(rules.verbs["escort"].needs_target and rules.verbs["escort"].needs_location)
	assert_eq(rules.souls[1], "hauler")


func test_fail_words_map_to_codes() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var cases: Dictionary[String, StringName] = {
		"Rivet wasted": &"rivet_wasted",
		"car destroyed": &"car_destroyed",
		"the steward dies": &"escort_dies",
		"target escapes": &"target_escapes",
		"time runs out": &"timer_expired",
		"cartridge destroyed": &"",
		"Rivet answers or arrives while heat is above 0": &"",
		"the van burns": &"car_destroyed",
		"the target gets away": &"target_escapes",
	}
	for word: String in cases:
		assert_eq(rules.fail_code(word), cases[word], word)


func test_a_bad_table_builds_no_rules() -> void:
	var rules: QuestRules = QuestRules.from_json_text('{"schema": "gtai.quest-rules/1"}')
	assert_false(rules.ok())
	assert_eq(rules.verbs.size(), 0)
	assert_false(QuestRules.from_json_text("[1, 2]").ok())


func test_seconds_round_up_to_whole_ticks() -> void:
	var rules: QuestRules = QuestRules.shipped()
	assert_eq(rules.seconds_to_ticks(1.0), 60)
	assert_eq(rules.seconds_to_ticks(1.4), 84)
	assert_eq(rules.seconds_to_ticks(0.01), 1)


func test_conditions_parse_and_hold() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var soul: QuestCondition = QuestCondition.parse("soul:hauler", rules)
	assert_true(soul.holds("hauler", "lucid", 0))
	assert_false(soul.holds("rivet", "lucid", 0))
	var heat: QuestCondition = QuestCondition.parse("heat:>=2", rules)
	assert_eq([heat.holds("rivet", "lucid", 1), heat.holds("rivet", "lucid", 2)], [false, true])
	assert_true(QuestCondition.parse("heat:3", rules).holds("rivet", "lucid", 3))
	assert_true(QuestCondition.parse("heat:<1", rules).holds("rivet", "lucid", 0))
	assert_true(QuestCondition.parse("madness:choir", rules).holds("rivet", "choir", 0))


func test_bad_conditions_say_why() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var cases: Dictionary[String, String] = {
		"wave-start": "no ':'",
		"soul:toaster": "unknown soul",
		"madness:mild": "unknown madness band",
		"heat:lots": "bad heat test",
		"weapon:gloria": "unknown condition 'weapon'",
	}
	for tag: String in cases:
		assert_string_contains(QuestCondition.parse(tag, rules).error, cases[tag], tag)
