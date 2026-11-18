extends GutTest


func after_each() -> void:
	GhostHand.enabled = true
	GhostHand.note("ohm", "p70", null, 0, false)


func test_no_strike_no_hand() -> void:
	var spr: Sprite2D = Sprite2D.new()
	add_child_autofree(spr)
	GhostHand.note("ohm", "p70", spr, 0, false)
	assert_eq(GhostHand.local_to("ohm", spr), Vector2.INF)


func test_a_striking_cell_notes_its_rows_fingertips() -> void:
	var spr: Sprite2D = Sprite2D.new()
	add_child_autofree(spr)
	GhostHand.note("ohm", "p70", spr, 0, true)
	var cell: Vector2 = GhostHand.CELLS["ohm/p70"][RigHeadCard.OCT_FRAME[0]]
	if RigHeadCard.OCT_FLIP[0] == 1:
		cell.x = -cell.x
	assert_almost_eq(GhostHand.local_to("ohm", spr), cell, Vector2(0.01, 0.01))


func test_a_screen_left_octant_mirrors_x() -> void:
	var spr: Sprite2D = Sprite2D.new()
	add_child_autofree(spr)
	var left: int = RigHeadCard.OCT_FLIP.find(1)
	GhostHand.note("ohm", "p70", spr, left, true)
	var cell: Vector2 = GhostHand.CELLS["ohm/p70"][RigHeadCard.OCT_FRAME[left]]
	assert_almost_eq(GhostHand.local_to("ohm", spr).x, -cell.x, 0.01)


func test_off_or_unmeasured_forgets() -> void:
	var spr: Sprite2D = Sprite2D.new()
	add_child_autofree(spr)
	GhostHand.enabled = false
	GhostHand.note("ohm", "p70", spr, 0, true)
	assert_eq(GhostHand.local_to("ohm", spr), Vector2.INF)
	GhostHand.enabled = true
	GhostHand.note("kerf", "p70", spr, 0, true)
	assert_eq(GhostHand.local_to("kerf", spr), Vector2.INF)


func test_the_bolt_follows_the_raised_profile_prongs_on_both_sheets() -> void:
	var sheet: GhostSheet = GhostSheet.act_of(GhostDrawn.path_of("p70", "ohm", "act"), "ohm/p70")
	var spr: Sprite2D = add_child_autofree(Sprite2D.new())
	for oct: int in [0, 4]:
		sheet.show(spr, oct, GhostDrawn.WINDUP_COL)
		GhostHand.note("ohm", "p70", spr, oct, true)
		var expected: Vector2 = Vector2(-78, -152) if oct == 0 else Vector2(84, -134)
		assert_almost_eq(GhostHand.local_to("ohm", spr), expected, Vector2(0.01, 0.01))
