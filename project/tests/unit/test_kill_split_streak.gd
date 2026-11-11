extends GutTest
## n16 kills-polish (owner n15 verdict): the blade kill's slash streak is shorter and thinner.


func test_blade_rows_draw_a_shorter_thinner_streak() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.problems.size(), 0, str(table.problems))
	for weapon: StringName in [&"katana", &"plasma_sword"]:
		var row: SignatureKill = table.for_weapon(weapon)
		assert_not_null(row, String(weapon))
		assert_lt(row.streak_m, KillSlashStreak.LENGTH_M, "%s streak shorter" % weapon)
		assert_lt(row.streak_w_m, KillSlashStreak.WIDTH_M, "%s streak thinner" % weapon)
		assert_gt(row.streak_w_m, 0.0, "%s streak still drawn" % weapon)


func test_a_row_without_streak_keys_keeps_the_default() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"kerf_slice")
	assert_not_null(row)
	assert_eq(row.streak_m, KillSlashStreak.LENGTH_M)
	assert_eq(row.streak_w_m, KillSlashStreak.WIDTH_M)
