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


class ProbeHook:
	extends ArenaHook
	var got: Dictionary[String, float] = {}

	func tune(key: String, value: float) -> bool:
		if not key.begins_with("rivet_melee."):
			return false
		got[key] = value
		return true


func test_array_rows_are_addressed_by_index() -> void:
	var raw: Dictionary = {"claw": {"hits": [{"windup_ticks": 6}, {"windup_ticks": 8}]}}
	var path: PackedStringArray = ["claw", "hits", "1", "windup_ticks"]
	var found: Variant = ArenaTuning._walk(raw, path)
	var missing: Variant = ArenaTuning._walk(raw, ["claw", "hits", "2", "windup_ticks"])
	var eight: bool = found is int and found == 8
	var none: bool = missing == null
	assert_true(eight)
	assert_true(none)


func test_a_knob_the_arena_does_not_know_goes_to_the_lane_hooks() -> void:
	var t: ArenaTuning = _tuning()
	var hook: ProbeHook = ProbeHook.new()
	t.hooks.append(hook)
	assert_true(t.set_value("rivet_melee.claw.hits.0.windup_ticks", 5.0))
	var got: float = hook.got.get("rivet_melee.claw.hits.0.windup_ticks", -1.0)
	assert_eq(got, 5.0)
	assert_false(t.set_value("ghost_powers.hauler.stomp_m", 3.0))
