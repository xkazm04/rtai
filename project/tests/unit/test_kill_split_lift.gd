extends GutTest
## n16 kills-polish: a blade split's cut line runs the row's cut_up_m above the body's ground point
## (through the drawn torso, shoulder to hip). At 0 the line passed through the feet and, in the
## upright view, one "half" held the whole standing cop while the other held his feet.

const BLADES: Array[StringName] = [&"katana", &"plasma_sword", &"chainsaw", &"kerf_slice"]


func test_every_blade_row_lifts_its_cut_into_the_torso() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	for weapon: StringName in BLADES:
		var row: SignatureKill = table.for_weapon(weapon)
		assert_not_null(row, String(weapon))
		if row != null:
			assert_between(row.cut_up_m, 0.5, 1.2, String(weapon))


func test_the_lift_is_screen_up_and_scales_with_the_zoom() -> void:
	var row: SignatureKill = SignatureKill.new()
	row.cut_up_m = 0.8
	assert_almost_eq(KillSplitFx.lift(row, 64.0), Vector2(0.0, -51.2), Vector2.ONE * 0.001)
	assert_almost_eq(KillSplitFx.lift(row, 1.0), Vector2(0.0, -0.8), Vector2.ONE * 0.001)


func test_no_lift_is_the_before() -> void:
	assert_eq(KillSplitFx.lift(SignatureKill.new(), 64.0), Vector2.ZERO)


func test_the_edge_runs_along_the_raised_line_styled_by_its_row() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"plasma_sword")
	var mid: Vector2 = Vector2(10.0, -40.0)
	var e: KillCutEdge = autofree(KillCutEdge.along(mid, Vector2.RIGHT, 20.0, Vector2.UP, row))
	assert_eq((e.a + e.b) * 0.5, mid)
	assert_eq(e.b - e.a, Vector2(40.0, 0.0))
	assert_true(e.hot, "the plasma sword cauterises")
	assert_false(e.soul)
