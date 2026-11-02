extends GutTest
## quest_rules.json (DAT-01/05): the shipped table loads typed; fail-state words map to codes in
## rule order; bark conditions parse or say why not; a bad table builds nothing.


func test_shipped_table_loads() -> void:
	var rules: QuestRules = QuestRules.shipped()
	assert_true(rules.ok(), str(rules.errors()))
	assert_eq(rules.verbs.size(), 14)
	assert_eq(rules.verbs["steal"].handler, QuestRules.Handler.ENTER_VEHICLE)
	assert_true(rules.verbs["escort"].needs_target and rules.verbs["escort"].needs_location)
	assert_eq(rules.souls[1], "hauler")
	assert_eq(rules.weapons, ["gloria", "assault-rifle", "none"] as Array[String])


func test_collect_call_verbs_have_their_handlers() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var want: Dictionary[String, QuestRules.Handler] = {
		"evade": QuestRules.Handler.EVADE,
		"answer": QuestRules.Handler.ANSWER,
		"meet": QuestRules.Handler.MEET,
		"fight": QuestRules.Handler.FIGHT,
		"sabotage": QuestRules.Handler.SABOTAGE,
	}
	for verb: String in want:
		assert_eq(rules.verbs[verb].handler, want[verb], verb)
		assert_true(rules.verbs[verb].needs_location, verb)
		assert_false(rules.verbs[verb].needs_target, "%s: its target is prose" % verb)
	assert_true(rules.verbs["fight"].needs_encounter and rules.verbs["sabotage"].needs_encounter)
	assert_true(rules.verbs["meet"].waits_for_lines)


func test_fail_words_map_to_codes() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var cases: Dictionary[String, StringName] = {
		"Rivet wasted": &"rivet_wasted",
		"car destroyed": &"car_destroyed",
		"the steward dies": &"escort_dies",
		"target escapes": &"target_escapes",
		"time runs out": &"timer_expired",
		"cartridge destroyed": &"",
		"the van burns": &"car_destroyed",
		"the target gets away": &"target_escapes",
		"Rivet answers or arrives while heat is above 0: Patch drops the call": &"arrived_hot",
		"Rivet is destroyed: respawn at the Toner Room": &"rivet_wasted",
	}
	for word: String in cases:
		assert_eq(rules.fail_code(word), cases[word], word)


func test_a_bad_table_builds_no_rules() -> void:
	var rules: QuestRules = QuestRules.from_json_text('{"schema": "gtai.quest-rules/2"}')
	assert_false(rules.ok())
	assert_eq(rules.verbs.size(), 0)
	assert_false(QuestRules.from_json_text("[1, 2]").ok())


func test_seconds_round_up_to_whole_ticks() -> void:
	var rules: QuestRules = QuestRules.shipped()
	assert_eq(rules.seconds_to_ticks(1.0), 60)
	assert_eq(rules.seconds_to_ticks(1.4), 84)
	assert_eq(rules.seconds_to_ticks(0.01), 1)


func test_state_conditions_parse_and_hold() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var facts: QuestFacts = QuestFacts.new(120)
	facts.soul = "hauler"
	assert_true(QuestCondition.parse("soul:hauler", rules).holds(facts))
	facts.soul = "rivet"
	assert_false(QuestCondition.parse("soul:hauler", rules).holds(facts))
	var heat: QuestCondition = QuestCondition.parse("heat:>=2", rules)
	assert_eq([heat.compare(1), heat.compare(2)], [false, true])
	assert_true(QuestCondition.parse("heat:3", rules).compare(3))
	assert_true(QuestCondition.parse("heat:<1", rules).compare(0))
	facts.madness = "choir"
	assert_true(QuestCondition.parse("madness:choir", rules).holds(facts))
	facts.weapon = "gloria"
	assert_true(QuestCondition.parse("weapon:gloria", rules).holds(facts))
	facts.weapon = "assault-rifle"
	assert_false(QuestCondition.parse("weapon:gloria", rules).holds(facts))


func test_every_event_tag_parses_to_its_fact() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var want: Dictionary[String, String] = {
		"kill": "actor_killed:by_player",
		"heat-dropping": "wanted_changed:falling",
		"wave-start": "wave_started",
		"boss-intro": "boss_engaged",
		"robo-tazer-charge": "attack_telegraphed:robo-tazer",
		"robo-tazer-hit": "player_hit:robo-tazer",
		"static-whisper-burst": "whispers_spiked",
		"crates-burning": "quest:sabotage_done",
	}
	assert_eq(rules.event_tags, want)
	for tag: String in want:
		var c: QuestCondition = QuestCondition.parse(tag, rules)
		assert_eq([c.error, c.kind, c.value], ["", QuestCondition.Kind.EVENT, want[tag]], tag)


func test_bad_conditions_say_why() -> void:
	var rules: QuestRules = QuestRules.shipped()
	var cases: Dictionary[String, String] = {
		"wave-end": "unknown event tag 'wave-end'",
		"soul:toaster": "unknown soul",
		"madness:mild": "unknown madness band",
		"weapon:spoon": "unknown weapon",
		"heat:lots": "bad heat test",
		"mood:sad": "unknown condition 'mood'",
	}
	for tag: String in cases:
		assert_string_contains(QuestCondition.parse(tag, rules).error, cases[tag], tag)


func test_an_event_tag_without_an_events_source_is_rejected() -> void:
	var text: String = FileAccess.get_file_as_string(QuestRules.PATH)
	var raw: Dictionary = QuestJson.parse_object(text)
	var tags: Array = raw["event_tags"]
	tags.append({"id": "moon-rise", "fact": "moon_rose", "doc": "x"})
	var rules: QuestRules = QuestRules.from_json_text(JSON.stringify(raw))
	assert_false(rules.ok())
	assert_string_contains(rules.errors()[0], "no Events source for 'moon_rose'")
