extends GutTest
## n11 call t-3 (owner, 2026-11-10): the QuestBeatValidator holes Codex's tests found.

var _rules: QuestRules
var _places: QuestPlaces
var _report: QuestReport
var _validator: QuestBeatValidator
var _lines: Dictionary[String, bool] = {"greeting": true}


func before_each() -> void:
	_rules = QuestRules.new()
	_places = QuestPlaces.new()
	_add_verb("wait", false)
	_add_verb("battle", true)
	_places.markers["yard"] = QuestPlaces.Marker.new()
	var encounter: QuestPlaces.Encounter = QuestPlaces.Encounter.new()
	encounter.enemies = 7
	encounter.waves = 3
	_places.encounters["yard"] = encounter


func _add_verb(id: String, fight: bool) -> void:
	var verb: QuestVerb = QuestVerb.new()
	verb.id = id
	verb.handler = QuestRules.Handler.FIGHT if fight else QuestRules.Handler.TIMER
	verb.needs_location = fight
	verb.needs_encounter = fight
	_rules.verbs[id] = verb


func _beat(objective: Dictionary = {"verb": "wait"}) -> Dictionary:
	return {"id": "fixture", "title": "Fixture", "lineIds": [], "objective": objective}


func _check(beats: Array) -> void:
	_report = QuestReport.new()
	_validator = QuestBeatValidator.new(_rules, _places, _report)
	_validator.check_all(beats, _lines)


func _expect_error(message: String) -> void:
	var expected: Array[String] = [message]
	assert_eq(_report.errors, expected)


func test_an_infinite_duration_fails() -> void:
	for bad: Variant in [INF, -INF, NAN]:
		_check([_beat({"verb": "wait", "durationS": bad})])
		_expect_error(
			"beats[0].objective.durationS: must be a number > 0 (omit it for untimed verbs)"
		)


func test_an_unknown_line_id_is_not_marked_used() -> void:
	var beat: Dictionary = _beat()
	beat["lineIds"] = ["missing", "greeting"]
	_check([beat])
	assert_eq(_validator.used_line_ids, {"greeting": true})


func test_a_beat_with_an_error_adds_no_encounter() -> void:
	var broken: Dictionary = _beat({"verb": "battle", "location": "yard"})
	@warning_ignore("return_value_discarded")
	broken.erase("title")
	_check([broken])
	assert_false(_report.ok())
	assert_eq(_validator.encounter_enemies, 0)
	assert_eq(_validator.encounter_waves, 0)


func test_a_non_string_verb_or_location_is_not_coerced() -> void:
	_rules.verbs["5"] = _rules.verbs["wait"]
	_check([_beat({"verb": 5})])
	assert_false(_report.ok())
	_places.markers["7"] = QuestPlaces.Marker.new()
	_places.encounters["7"] = _places.encounters["yard"]
	_check([_beat({"verb": "battle", "location": 7})])
	assert_false(_report.ok())
	assert_eq(_validator.encounter_enemies, 0)
