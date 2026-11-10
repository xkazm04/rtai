extends GutTest
## Beats must be playable with the injected rules, world places and package dialogue.
## Fixtures deliberately keep actor, vehicle, marker and encounter tags distinct.

var _rules: QuestRules
var _places: QuestPlaces
var _report: QuestReport
var _validator: QuestBeatValidator
var _lines: Dictionary[String, bool] = {"greeting": true, "reply": true, "unused": true}


func before_each() -> void:
	_rules = QuestRules.new()
	_places = QuestPlaces.new()
	_add_verb("wait", QuestRules.Handler.TIMER)
	_add_verb("drive", QuestRules.Handler.ENTER_VEHICLE, true)
	_add_verb("escort", QuestRules.Handler.ESCORT, true, true)
	_add_verb("battle", QuestRules.Handler.FIGHT, false, true, true)
	_places.actors["ally"] = QuestPlaces.Actor.new()
	_places.vehicles["van"] = Vector2.ZERO
	_places.markers["square"] = QuestPlaces.Marker.new()
	_places.markers["yard"] = QuestPlaces.Marker.new()
	var encounter: QuestPlaces.Encounter = QuestPlaces.Encounter.new()
	encounter.enemies = 7
	encounter.waves = 3
	_places.encounters["yard"] = encounter


func _add_verb(
	id: String,
	handler: QuestRules.Handler,
	target: bool = false,
	location: bool = false,
	encounter: bool = false
) -> void:
	var verb: QuestVerb = QuestVerb.new()
	verb.id = id
	verb.handler = handler
	verb.needs_target = target
	verb.needs_location = location
	verb.needs_encounter = encounter
	_rules.verbs[id] = verb


func _beat(objective: Dictionary = {"verb": "wait"}) -> Dictionary:
	return {"id": "fixture", "title": "Fixture", "lineIds": [], "objective": objective}


func _check(beats: Array) -> void:
	_report = QuestReport.new()
	_validator = QuestBeatValidator.new(_rules, _places, _report)
	_validator.check_all(beats, _lines)


func _expect_error(message: String, second: String = "") -> void:
	var expected: Array[String] = [message]
	if second != "":
		expected.append(second)
	assert_eq(_report.errors, expected)


func _reject_field(field: String, invalid: Array, message: String) -> void:
	var beat: Dictionary = _beat()
	assert_true(beat.erase(field))
	_check([beat])
	_expect_error(message)
	for bad: Variant in invalid:
		beat[field] = bad
		_check([beat])
		_expect_error(message)


func test_quest_needs_at_least_one_beat_but_duration_and_dialogue_are_optional() -> void:
	_check([_beat()])
	assert_true(_report.ok(), str(_report.errors))
	assert_eq(_validator.used_line_ids.size(), 0)
	_check([])
	_expect_error("beats: a quest needs at least one beat")


func test_non_object_beat_is_reported_and_later_beats_are_checked() -> void:
	_check([null, _beat({"verb": "escort", "target": "ally"})])
	_expect_error("beats[0]: not an object", "beats[1].objective.location: '' is not a marker")


func test_beat_identity_objective_and_dialogue_have_required_types() -> void:
	for field: String in ["id", "title"]:
		_reject_field(field, [null, "", 42], "beats[0]: needs string id and title")
	_reject_field("objective", [null, [], "wait"], "beats[0].objective: missing or not an object")
	_reject_field("lineIds", [null, "greeting", {}], "beats[0].lineIds: missing or not an array")


func test_unknown_or_missing_verb_is_reported_with_handled_verbs() -> void:
	for objective: Dictionary in [{"verb": "invented"}, {}]:
		_check([_beat(objective)])
		assert_eq(_report.errors.size(), 1)
		assert_string_contains(_report.errors[0], "beats[0].objective.verb: unknown verb")
		for id: String in _rules.verbs:
			assert_string_contains(_report.errors[0], id)


func test_targets_resolve_only_in_the_namespace_required_by_the_handler() -> void:
	for id: String in ["drive", "escort"]:
		var valid: String = "van" if id == "drive" else "ally"
		_check([_beat({"verb": id, "target": valid, "location": "square"})])
		assert_true(_report.ok(), str(_report.errors))
		var wrong_kind: String = "ally" if id == "drive" else "van"
		var kind: String = "a vehicle" if id == "drive" else "an actor"
		for bad: String in [wrong_kind, "absent"]:
			_check([_beat({"verb": id, "target": bad, "location": "square"})])
			_expect_error(
				"beats[0].objective.target: '%s' is not %s in the places table" % [bad, kind]
			)
		for bad: Variant in [null, "", 9]:
			_check([_beat({"verb": id, "target": bad, "location": "square"})])
			_expect_error("beats[0].objective.target: '%s' needs a target tag" % id)
		_check([_beat({"verb": id, "location": "square"})])
		_expect_error("beats[0].objective.target: '%s' needs a target tag" % id)


func test_required_location_must_name_a_world_marker() -> void:
	for location: String in ["absent", "van", "ally", ""]:
		_check([_beat({"verb": "escort", "target": "ally", "location": location})])
		assert_eq(_report.errors, ["beats[0].objective.location: '%s' is not a marker" % location])


func test_requirements_come_from_the_injected_verb_flags() -> void:
	var verb: QuestVerb = _rules.verbs["escort"]
	verb.needs_target = false
	verb.needs_location = false
	_check([_beat({"verb": "escort"})])
	assert_true(_report.ok(), "disabled requirements allow a beat without target or location")
	verb.needs_target = true
	_check([_beat({"verb": "escort"})])
	_expect_error("beats[0].objective.target: 'escort' needs a target tag")


func test_encounters_are_required_and_totals_count_each_battle_but_not_visits() -> void:
	_check([_beat({"verb": "battle", "location": "square"})])
	_expect_error("beats[0].objective.location: 'square' holds no encounter for 'battle'")
	assert_eq(_validator.encounter_enemies, 0)
	assert_eq(_validator.encounter_waves, 0)

	var second: QuestPlaces.Encounter = QuestPlaces.Encounter.new()
	second.enemies = 2
	second.waves = 5
	_places.encounters["square"] = second
	_check(
		[
			_beat({"verb": "battle", "location": "yard"}),
			_beat({"verb": "battle", "location": "square"}),
			_beat({"verb": "battle", "location": "yard"}),
			_beat({"verb": "escort", "target": "ally", "location": "yard"}),
		]
	)
	assert_true(_report.ok(), str(_report.errors))
	var first: QuestPlaces.Encounter = _places.encounters["yard"]
	assert_eq(_validator.encounter_enemies, 2 * first.enemies + second.enemies)
	assert_eq(_validator.encounter_waves, 2 * first.waves + second.waves)


func test_duration_when_present_must_be_a_strictly_positive_number() -> void:
	for bad: Variant in [0, 0.0, -1, -0.5, "2", true, null]:
		_check([_beat({"verb": "wait", "durationS": bad})])
		_expect_error(
			"beats[0].objective.durationS: must be a number > 0 (omit it for untimed verbs)"
		)
	for duration: Variant in [1, 0.25]:
		_check([_beat({"verb": "wait", "durationS": duration})])
		assert_true(_report.ok(), str(_report.errors))


func test_dialogue_references_are_collected_and_missing_lines_are_reported_per_beat() -> void:
	var first: Dictionary = _beat()
	first["lineIds"] = ["greeting", "reply", "greeting"]
	var second: Dictionary = _beat()
	second["lineIds"] = ["reply"]
	_check([first, second])
	assert_true(_report.ok(), str(_report.errors))
	assert_eq(_validator.used_line_ids, {"greeting": true, "reply": true})
	assert_eq(_lines.size(), 3, "validation does not consume package dialogue")

	var beat: Dictionary = _beat()
	beat["lineIds"] = ["missing", "greeting", "also_missing"]
	_check([_beat(), beat])
	_expect_error(
		"beats[1].lineIds: 'missing' is not in lines",
		"beats[1].lineIds: 'also_missing' is not in lines"
	)


func test_independent_errors_in_a_beat_are_collected_together() -> void:
	var beat: Dictionary = _beat({"verb": "escort", "durationS": 0})
	beat["id"] = ""
	beat["lineIds"] = ["missing"]
	_check([beat])
	assert_eq(_report.errors.size(), 5, str(_report.errors))
	for field: String in ["beats[0]:", "target:", "location:", "durationS:", "lineIds:"]:
		assert_string_contains(str(_report.errors), field)
