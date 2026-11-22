extends GutTest


func test_shipped_short_circuit_times_are_in_ticks() -> void:
	var table: MoveTable = MoveTable.shipped()
	assert_eq(table.errors, [])
	var row: MoveTable.ShortCircuit = table.ohm_short_circuit
	assert_true(row.enabled)
	assert_eq(row.stun_ticks, 120)
	assert_eq(row.boss_stun_ticks, 36)
	assert_eq(row.immune_ticks, 240)


func test_each_field_comes_from_the_row_and_invalid_rows_stay_disabled() -> void:
	var source: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var block: Dictionary = source.object(source.raw, "moves")
	var row: Dictionary = source.object(block, "ohm_short_circuit")
	row.merge({"enabled": false, "stun_s": 1.5, "boss_stun_s": 0.25, "immune_s": 3}, true)
	var table: MoveTable = MoveTable.from_table(source)
	assert_eq(table.errors, [])
	assert_false(table.ohm_short_circuit.enabled)
	assert_eq(table.ohm_short_circuit.stun_ticks, 90)
	assert_eq(table.ohm_short_circuit.boss_stun_ticks, 15)
	assert_eq(table.ohm_short_circuit.immune_ticks, 180)
	row["enabled"] = "yes"
	table = MoveTable.from_table(source)
	assert_false(table.errors.is_empty())
	assert_false(table.ohm_short_circuit.enabled)
