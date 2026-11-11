extends GutTest
## n16 kills-polish item 3 (asset lane A6): the hand cannon's blowback carries a drawn exit wound
## in the thrown body's chest; a street victim's dries over DRY_TICKS, a cop's keeps its navy flaps.


func test_only_the_hand_cannon_row_has_an_exit_wound() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_gt(table.for_weapon(&"hand_cannon").wound_m, 0.1)
	for w: StringName in table.weapons():
		var row: SignatureKill = table.for_weapon(w)
		if row.style != &"blowback":
			assert_eq(row.wound_m, 0.0, String(w))


func test_the_sheet_holds_three_cells() -> void:
	assert_eq(KillExitWound.ART.get_width(), KillExitWound.ART.get_height() * 3)


func test_a_street_wound_dries_and_a_cop_wound_stays_navy() -> void:
	var w: KillExitWound = KillExitWound.new()
	assert_eq(w.frames(0), Vector3(KillExitWound.FRESH, KillExitWound.DRIED, 0.0))
	assert_eq(w.frames(KillExitWound.DRY_TICKS * 2).z, 1.0, "dried")
	w.cop = true
	assert_eq(w.frames(KillExitWound.DRY_TICKS).x, float(KillExitWound.FRESH_COP))
	assert_eq(w.frames(KillExitWound.DRY_TICKS).z, 0.0)
	w.free()


func test_no_rig_no_wound() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"hand_cannon")
	var body: Node2D = Node2D.new()
	assert_null(KillExitWound.attach(body, null, row, Vector2.RIGHT, 32.0))
	assert_eq(body.get_child_count(), 0)
	body.free()


func test_the_wound_is_on_by_default() -> void:
	assert_false(KillExitWound.off())
