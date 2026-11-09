extends GutTest
## Fail rows require array groups; matching is AND across groups and OR within each group.
## Pin ASCII token boundaries and the loader's permissive keyword conversion as they are.


func test_from_row_preserves_code_group_order_and_alternatives() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row(
		{"id": "car_destroyed", "groups": [["car", "van"], ["destroyed", "burns"]]}
	)
	assert_not_null(rule)
	assert_eq(rule.code, &"car_destroyed")
	assert_eq(rule.groups, [["car", "van"], ["destroyed", "burns"]])


func test_from_row_rejects_non_dictionary_values() -> void:
	var rows: Array[Variant] = [null, false, 1, 1.0, "rule", [], PackedStringArray()]
	for row: Variant in rows:
		assert_null(QuestFailRule.from_row(row), str(row))


func test_from_row_requires_a_string_id_and_array_groups() -> void:
	var rows: Array[Dictionary] = [
		{},
		{"groups": [["car"]]},
		{"id": null, "groups": [["car"]]},
		{"id": 1, "groups": [["car"]]},
		{"id": &"car", "groups": [["car"]]},
		{"id": "car"},
		{"id": "car", "groups": null},
		{"id": "car", "groups": "car"},
		{"id": "car", "groups": {}},
		{"id": "car", "groups": PackedStringArray(["car"])},
	]
	for row: Dictionary in rows:
		assert_null(QuestFailRule.from_row(row), str(row))


func test_from_row_rejects_no_groups_and_a_bad_group_after_a_valid_one() -> void:
	assert_null(QuestFailRule.from_row({"id": "car", "groups": []}))
	var bad_groups: Array[Variant] = [null, 7, "car", {}, PackedStringArray(["car"])]
	for group: Variant in bad_groups:
		assert_null(QuestFailRule.from_row({"id": "car", "groups": [group]}), str(group))
		assert_null(QuestFailRule.from_row({"id": "car", "groups": [["car"], group]}))


func test_from_row_accepts_empty_id_and_ignores_extra_fields() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row(
		{"id": "", "groups": [["car"]], "extra": false}
	)
	assert_not_null(rule)
	assert_eq(rule.code, &"")
	assert_true(rule.matches("car"))


func test_from_row_converts_keywords_to_strings_without_normalizing_them() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row(
		{"id": "mixed", "groups": [[7, true, null, "CAR", " car "]]}
	)
	assert_eq(rule.groups, [["7", "true", "<null>", "CAR", " car "]])
	assert_true(rule.matches("7"))
	assert_true(rule.matches("TRUE"))
	assert_false(rule.matches("car"), "keyword case and whitespace are preserved")


func test_from_row_copies_groups_instead_of_retaining_input_arrays() -> void:
	var keywords: Array[String] = ["car"]
	var groups: Array = [keywords]
	var rule: QuestFailRule = QuestFailRule.from_row({"id": "car", "groups": groups})
	keywords[0] = "van"
	groups.append(["burns"])
	assert_eq(rule.groups, [["car"]])
	assert_true(rule.matches("car"))
	assert_false(rule.matches("van"))


func test_matching_requires_every_group_but_only_one_alternative_per_group() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row(
		{"id": "car_destroyed", "groups": [["car", "van"], ["destroyed", "burns"]]}
	)
	for text: String in ["car destroyed", "van destroyed", "car burns", "van burns"]:
		assert_true(rule.matches(text), text)
	for text: String in ["", "car", "van", "destroyed", "burns", "boat sinks"]:
		assert_false(rule.matches(text), text)
	assert_true(rule.matches("BURNS! The VAN."), "group order and adjacency do not matter")
	assert_false(rule.matches("car"), "a previous match must not leave a group satisfied")


func test_matching_requires_whole_words_at_both_edges() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row({"id": "car", "groups": [["car"]]})
	for text: String in ["car", "car!", "!car", "a car b", "CAR", "car-car"]:
		assert_true(rule.matches(text), text)
	for text: String in ["cartridge", "scar", "scars", "car0", "0car", "carz", "acar"]:
		assert_false(rule.matches(text), text)


func test_multiword_keyword_uses_adjacent_normalized_words() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row({"id": "escape", "groups": [["gets away"]]})
	assert_true(rule.matches("GETS,\t\nAWAY!"))
	for text: String in ["gets far away", "away gets", "getsaway", "gets awayward"]:
		assert_false(rule.matches(text), text)


func test_matching_does_not_normalize_keyword_case_spacing_or_punctuation() -> void:
	for keyword: String in ["CAR", " car", "car ", "car!", "gets  away", "gets-away"]:
		var rule: QuestFailRule = QuestFailRule.from_row({"id": "raw", "groups": [[keyword]]})
		assert_false(rule.matches("CAR! gets-away"), keyword)


func test_empty_group_is_accepted_but_can_never_match() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row({"id": "empty", "groups": [[]]})
	assert_not_null(rule)
	assert_eq(rule.groups, [[]])
	assert_false(rule.matches(""))
	assert_false(rule.matches("car"))
	var mixed: QuestFailRule = QuestFailRule.from_row({"id": "mixed", "groups": [["car"], []]})
	assert_false(mixed.matches("car"))


func test_words_of_includes_ascii_range_endpoints_and_flushes_the_final_word() -> void:
	assert_eq(QuestFailRule.words_of("AZaz09"), ["azaz09"] as Array[String])
	assert_eq(QuestFailRule.words_of("@AZ[ /09: `az{"), ["az", "09", "az"] as Array[String])
	assert_eq(QuestFailRule.words_of("last"), ["last"] as Array[String])


func test_words_of_separates_punctuation_whitespace_and_non_ascii_characters() -> void:
	assert_eq(
		QuestFailRule.words_of("  Car__VAN-2\tcan't\r\nstop... café—雪9!  "),
		["car", "van", "2", "can", "t", "stop", "caf", "9"] as Array[String]
	)
	assert_eq(QuestFailRule.words_of(""), [] as Array[String])
	assert_eq(QuestFailRule.words_of(" \t\n_!?é雪"), [] as Array[String])


func test_a_rule_with_no_groups_matches_nothing() -> void:
	var rule: QuestFailRule = QuestFailRule.new()
	assert_false(rule.matches(""))
	assert_false(rule.matches("anything"))


func test_an_empty_keyword_never_matches() -> void:
	var rule: QuestFailRule = QuestFailRule.from_row({"id": "empty", "groups": [[""]]})
	assert_false(rule.matches(""))
	assert_false(rule.matches("!? "))
	assert_false(rule.matches("car"))
