extends GutTest


func _tuning() -> ArenaTuning:
	return ArenaTuning.new(PlayerActions.shipped(), CombatTuning.shipped())


func test_shipped_value_reads_the_table() -> void:
	var t: ArenaTuning = _tuning()
	assert_eq(t.shipped("input_actions.move.turn_dps"), 720.0)
	assert_true(is_nan(t.shipped("input_actions.move.no_such_key")))


func test_a_movement_knob_applies_live_and_resets() -> void:
	var t: ArenaTuning = _tuning()
	assert_true(t.set_value("input_actions.move.turn_dps", 360.0))
	assert_eq(t.actions.turn_dps, 360.0)
	assert_true(t.reset("input_actions.move.turn_dps"))
	assert_eq(t.actions.turn_dps, 720.0)
	assert_eq(t.log.size(), 2)


func test_a_weapon_knob_applies_live() -> void:
	var t: ArenaTuning = _tuning()
	assert_true(t.set_value("combat.weapons.gloria.cooldown_s", 0.2))
	assert_eq(t.combat.weapon(&"gloria").cooldown_ticks, 12)
	assert_false(t.set_value("combat.weapons.gloria.no_field", 1.0))


func test_canonical_matches_the_repo_form() -> void:
	for table: String in ["input_actions", "combat", "arena"]:
		var text: String = FileAccess.get_file_as_string("res://data/tables/%s.json" % table)
		var parsed: Variant = JSON.parse_string(text)
		var raw: Dictionary = parsed if parsed is Dictionary else {}
		assert_eq(ArenaTuning.canonical(raw), text, table)
