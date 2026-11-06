extends GutTest
## n8 vehicles: a FINE row picks among nine views a half turn (the five drawn + four 22.5-degree
## in-betweens in columns 5-8), and the p70 atlas really holds the in-betweens VehicleViews.FINE
## names (and none for the rows it leaves out).


func test_the_nine_fine_views_and_their_columns() -> void:
	assert_eq(VehicleViews.view_of(90.0, true), Vector3(0, 0, 90))
	assert_eq(VehicleViews.view_of(67.5, true), Vector3(5, 0, 67.5))  # A
	assert_eq(VehicleViews.view_of(45.0, true), Vector3(1, 0, 45))
	assert_eq(VehicleViews.view_of(22.5, true), Vector3(6, 0, 22.5))  # B
	assert_eq(VehicleViews.view_of(0.0, true), Vector3(2, 0, 0))
	assert_eq(VehicleViews.view_of(-22.5, true), Vector3(7, 0, -22.5))  # C
	assert_eq(VehicleViews.view_of(-45.0, true), Vector3(3, 0, -45))
	assert_eq(VehicleViews.view_of(-67.5, true), Vector3(8, 0, -67.5))  # D
	assert_eq(VehicleViews.view_of(-90.0, true), Vector3(4, 0, -90))
	assert_eq(VehicleViews.view_of(112.5, true), Vector3(5, 1, 112.5))  # A mirrored


func test_a_fine_rest_never_passes_half_a_step_and_noses_agree() -> void:
	for d: int in range(-180, 181, 2):
		var pick: Vector3 = VehicleViews.view_of(float(d), true)
		var rest: float = wrapf(float(d) - pick.z, -180.0, 180.0)
		assert_true(absf(rest) <= VehicleViews.FINE_DEG * 0.5 + 0.001, "heading %d" % d)
		if pick.y < 0.5:
			assert_almost_eq(VehicleViews.nose_deg(int(pick.x)), pick.z, 0.001)


func test_the_p70_atlas_holds_the_fine_rows_in_betweens() -> void:
	var path: String = VehicleCards.DIR % "p70"
	var img: Image = (load(path) as Texture2D).get_image()
	var cell: int = VehicleViews.CELL_PX
	assert_eq(img.get_width(), cell * VehicleViews.FINE_COLS)
	var fine: PackedInt32Array = VehicleViews.FINE["p70"]
	for row: int in VehicleCards.ROWS:
		var drawn: bool = _opaque(img, Rect2i(5 * cell, row * cell, cell * 4, cell)) > 4000
		assert_eq(drawn, fine.has(row), "row %d" % row)


func _opaque(img: Image, r: Rect2i) -> int:
	var n: int = 0
	for y: int in range(r.position.y, r.end.y, 4):
		for x: int in range(r.position.x, r.end.x, 4):
			n += 1 if img.get_pixel(x, y).a > 0.5 else 0
	return n


func test_a_five_column_atlas_has_no_fine_rows() -> void:
	assert_eq(VehicleViews.fine_rows(VehicleViews.COLS, "p70").size(), 0)
	assert_eq(VehicleViews.fine_rows(VehicleViews.FINE_COLS, "p55").size(), 0)
	assert_eq(VehicleViews.cols_of(null), VehicleViews.COLS)
