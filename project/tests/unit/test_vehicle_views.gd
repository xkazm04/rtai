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
	var img: Image = TestArt.rgba(load(path) as Texture2D)
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


func test_the_grid_follows_the_atlas_across_a_pitch_swap() -> void:
	var cards: VehicleCards = VehicleCards.new()
	var cell: int = VehicleViews.CELL_PX
	var fine: Texture2D = _tex(cell * VehicleViews.FINE_COLS)
	var five: Texture2D = _tex(cell * VehicleViews.COLS)
	cards.begin(fine)
	assert_eq(cards.cols(), VehicleViews.FINE_COLS, "a p70-like nine-column atlas")
	cards.begin(five)
	assert_eq(cards.cols(), VehicleViews.COLS, "the swap to a five-column atlas")
	cards.begin(fine)
	assert_eq(cards.cols(), VehicleViews.FINE_COLS, "and back")
	cards.free()


func _tex(w: int) -> Texture2D:
	return ImageTexture.create_from_image(Image.create(w, 4, false, Image.FORMAT_RGBA8))


func test_both_atlases_hold_the_bike_row_after_the_sims_nine() -> void:
	var cell: int = VehicleViews.CELL_PX
	for art: String in ["p70", "p55"]:
		var tex: Texture2D = load(VehicleCards.DIR % art) as Texture2D
		var grid: Vector2i = VehicleViews.grid_of(tex, VehicleCards.ROWS)
		assert_eq(grid.y, VehicleViews.BIKE_ART + 1, art)
		var img: Image = TestArt.rgba(tex)
		for col: int in VehicleViews.COLS:  # the five drawn views, each a lone bike
			var r: Rect2i = Rect2i(col * cell, VehicleViews.BIKE_ART * cell, cell, cell)
			assert_gt(_opaque(img, r), 40, "%s view %d" % [art, col])


func test_a_null_atlas_keeps_the_sims_grid() -> void:
	assert_eq(VehicleViews.grid_of(null, VehicleCards.ROWS), Vector2i(5, 9))


func test_both_layers_shaders_read_the_atlas_rows() -> void:
	var cards: VehicleCards = VehicleCards.new()
	var cell: int = VehicleViews.CELL_PX
	var img: Image = Image.create(cell * VehicleViews.COLS, cell * 10, false, Image.FORMAT_L8)
	cards.begin(ImageTexture.create_from_image(img))
	var layers: Array[MultiMeshInstance2D] = [
		cards.get_child(0) as MultiMeshInstance2D, cards.under
	]
	for node: MultiMeshInstance2D in layers:
		var mat: ShaderMaterial = node.material as ShaderMaterial
		var rows: int = mat.get_shader_parameter("rows")
		var cols: int = mat.get_shader_parameter("cols")
		assert_eq(Vector2i(cols, rows), Vector2i(VehicleViews.COLS, 10))
	cards.free()
