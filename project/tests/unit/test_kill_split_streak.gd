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


func test_plasma_cools_for_forty_ticks_and_replaces_the_flash() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"plasma_sword")
	assert_eq(row.flash_ticks, 0)
	assert_eq(KillPlasmaArt.heat(0), 1.0)
	assert_almost_eq(KillPlasmaArt.heat(20), 0.5, 0.001)
	assert_gt(KillPlasmaArt.heat(39), 0.0)
	assert_eq(KillPlasmaArt.heat(40), 0.0)
	assert_eq(KillPlasmaArt.heat(90), 0.0)


func test_plasma_paints_its_own_blood_without_consuming_replay_drops() -> void:
	var mark: KillMarks.Mark = KillMarks.Mark.new()
	mark.at = Vector2(2.0, 3.0)
	mark.dir = Vector2.RIGHT
	var stain: KillMarks.Mark = KillPlasmaArt.ground_print(mark, Callable())
	assert_eq(stain.drops.size(), KillPlasmaArt.DROPS)
	assert_gt(stain.blot_m, 0.0)
	assert_true(mark.drops.is_empty())
	assert_eq(stain.drops, KillPlasmaArt.ground_print(mark, Callable()).drops)
