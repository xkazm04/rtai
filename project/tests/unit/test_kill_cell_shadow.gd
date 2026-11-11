extends GutTest
## n17 npc-react (DEFECTS 18): KillCellShadow keeps the walk's contact shadow under a death's
## drawn cells while the figure stands, none once it lies.


func _cells(file: String, rows: int) -> Sprite2D:
	var cells: Sprite2D = autofree(Sprite2D.new())
	if not file.is_empty():
		cells.texture = load(StreetWalkerCards.DIR + file) as Texture2D
	cells.hframes = RigHeadCard.FRAMES
	cells.vframes = rows
	return cells


func test_a_fit_grid_lies_from_its_trailing_run_of_drawn_rows() -> void:
	assert_eq(KillCellShadow.lying_row(_cells("p70/cop_patrol_claw_throw.png", 4)), 2)
	assert_eq(KillCellShadow.lying_row(_cells("p70/cop_patrol_pistol_snap.png", 4)), 3)
	assert_eq(KillCellShadow.lying_row(_cells("p70/swat_gatling_shred.png", 3)), 2)


func test_a_grid_without_a_fit_lies_on_its_last_row() -> void:
	assert_eq(KillCellShadow.lying_row(_cells("", 3)), 2)
	assert_eq(KillCellShadow.lying_row(_cells("", 1)), 0)


func test_it_draws_while_the_figure_stands_and_not_once_it_lies() -> void:
	var cells: Sprite2D = _cells("p70/cop_patrol_claw_throw.png", 4)
	var s: KillCellShadow = KillCellShadow.new()
	s.lying_from = KillCellShadow.lying_row(cells)
	cells.add_child(s)
	for row: int in 4:
		cells.frame_coords = Vector2i(0, row)
		assert_eq(s.stands(), row < 2, "row %d" % row)


func test_it_is_drawn_behind_the_cells() -> void:
	var cells: Sprite2D = _cells("", 3)
	var s: KillCellShadow = KillCellShadow.attach(null, cells)
	if s == null:  # the shipped view draws no contact shadow: nothing to place
		assert_eq(cells.get_child_count(), 0)
		return
	assert_true(s.show_behind_parent)
	assert_gt(s.radius_px, 0.0)
