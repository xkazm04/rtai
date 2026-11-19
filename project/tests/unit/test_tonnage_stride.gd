extends GutTest


func test_tonnage_p70_drawn_steps_measure_both_sides_of_each_redrawn_frame() -> void:
	var steps: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p70"])
	# Column 2 carries one pad. Column 6 lands the front pad while the rear is still down.
	assert_eq(steps[1], 124.5 - 99.5)
	assert_eq(steps[2], 99.5 - 79.5)
	assert_eq(steps[5], 62.0 - 17.5)
	assert_eq(steps[6], 144.0 - 140.0)


func test_tonnage_midpoints_use_each_profiles_own_drawing_while_walking() -> void:
	var saved: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var rig: TonnageRig = autofree(TonnageRig.new())
	var host: Node2D = add_child_autofree(Node2D.new())
	var drawn: GhostDrawn = rig.drawn
	var mid: String = GhostDrawn.path_of("p70", "tonnage", "walk8_mid")
	var seen: Dictionary[int, bool] = {}
	for i: int in 160:
		host.position.x += 1.0
		assert_true(drawn.step(host, [], 32.0, 1.0, 0.0))
		if drawn._spr.texture.resource_path == mid:
			var atlas_col: int = drawn._spr.frame_coords.x
			seen[atlas_col] = true
			drawn._show_cell(drawn._walk, 4, drawn._col)
			assert_eq(
				drawn._spr.texture.resource_path,
				GhostDrawn.path_of("p70", "tonnage", "walk8_mid_left")
			)
			assert_eq(drawn._spr.frame_coords, Vector2i(atlas_col, 1))
			assert_false(drawn._spr.flip_h)
			drawn._show_cell(drawn._act, 0, GhostDrawn.HIT_COL)
			assert_eq(drawn._spr.texture.resource_path, GhostDrawn.path_of("p70", "tonnage", "act"))
	assert_eq(seen.size(), 10)
	drawn._phase = 0.33  # stopping during the C5-to-C6 window should show the standing key
	for i: int in GhostDrawn.STILL_FRAMES + 1:
		assert_true(drawn.step(host, [], 32.0, 1.0, 0.0))
	assert_eq(drawn._spr.texture.resource_path, GhostDrawn.path_of("p70", "tonnage"))
	assert_eq(drawn._spr.frame_coords, Vector2i(4, 2))
	ViewMode._shared = saved


func _check_mid_edges(sheet: GhostSheet, spr: Sprite2D, oct: int, key: int, index: int) -> void:
	var w: Vector2 = sheet._mid_windows[index]
	var left: bool = oct == 4
	var path: String = GhostDrawn.path_of("p70", "tonnage", "walk8_left" if left else "walk8")
	var mid: String = GhostDrawn.path_of(
		"p70", "tonnage", "walk8_mid_left" if left else "walk8_mid"
	)
	for col: int in [key, key + 1]:
		sheet.show(spr, oct, col, w.x - 0.000001)
		assert_eq(spr.texture.resource_path, path)
		sheet.show(spr, oct, col, w.x)
		assert_eq(spr.texture.resource_path, mid)
		assert_eq(spr.frame_coords, Vector2i(index, 1 if left else 2))
		assert_eq(spr.offset, Vector2(-81.5, -213.0 if left else -228.0))
		assert_false(spr.flip_h)
		sheet.show(spr, oct, col, w.y - 0.000001)
		assert_eq(spr.texture.resource_path, mid)
		sheet.show(spr, oct, col, w.y)
		assert_eq(spr.texture.resource_path, path)
	sheet.show(spr, oct, posmod(key - 1, 16), w.x)
	assert_eq(spr.texture.resource_path, path)


func test_each_filmed_midpoint_enters_and_exits_at_its_two_neighbours() -> void:
	var expected: Array[Vector2] = [
		Vector2(0.41336418, 0.45897461),
		Vector2(0.02125453, 0.06408207),
		Vector2(0.10969352, 0.15529278),
		Vector2(0.20085933, 0.24645859),
		Vector2(0.32216594, 0.36776520),
		Vector2(0.55525040, 0.59146157),
		Vector2(0.62209652, 0.64704200),
		Vector2(0.67830032, 0.72363135),
		Vector2(0.76924733, 0.81484658),
		Vector2(0.86042561, 0.90602487),
	]
	var starts: Array[int] = [5, 0, 1, 2, 4, 8, 9, 10, 11, 12]
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p70")
	var sheet: GhostSheet = _tonnage_sheet("p70")
	var spr: Sprite2D = autofree(Sprite2D.new())
	var windows: Array[Vector2] = GhostStride.tonnage_windows(steps)
	assert_eq(windows.size(), expected.size())
	for i: int in expected.size():
		assert_almost_eq(windows[i], expected[i], Vector2.ONE * 0.000001)
		for oct: int in [0, 4]:
			_check_mid_edges(sheet, spr, oct, starts[i], i)


func test_unmatched_grids_keep_the_original_key() -> void:
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p55")
	for path: String in [GhostDrawn.path_of("p70", "tonnage"), GhostDrawn.path_of("p55", "ohm")]:
		assert_true(GhostSheet.walk_of(path, steps)._intervals.is_empty())


func test_left_midpoints_require_drawn_left_profile_art() -> void:
	var sheet: GhostSheet = _tonnage_sheet("p70")
	var spr: Sprite2D = autofree(Sprite2D.new())
	var phase: float = sheet._mid_windows[0].x
	for oct: int in [2, 6]:
		sheet.show(spr, oct, 5, phase)
		assert_ne(spr.texture, sheet._profile_mid.tex)
	sheet._profile_mid.left = null
	sheet.show(spr, 4, 5, phase)
	assert_eq(spr.texture, sheet.left)


func _check_intervals(bank: GhostWalkPages, centres: Array[float], parts: Array[int]) -> void:
	var index: int = 0
	for i: int in parts.size():
		var start: float = centres[i]
		var end: float = centres[i + 1] if i + 1 < centres.size() else centres[0] + 1.0
		for j: int in range(1, parts[i]):
			var w: Vector2 = bank.windows[index]
			var left: float = lerpf(start, end, (j - 0.5) / parts[i])
			var right: float = lerpf(start, end, (j + 0.5) / parts[i])
			assert_almost_eq(w, Vector2(left, right), Vector2.ONE * 0.000001)
			assert_eq(bank.col_at(fposmod(w.x - 0.000001, 1.0)), index - 1 if j > 1 else -1)
			assert_eq(bank.col_at(fposmod(w.x, 1.0)), index)
			assert_eq(bank.col_at(fposmod(w.y - 0.000001, 1.0)), index)
			assert_eq(bank.col_at(fposmod(w.y, 1.0)), index + 1 if j + 1 < parts[i] else -1)
			index += 1
	assert_eq(bank.windows.size(), index)
	assert_eq(bank.col_at(0.0), index - 1)
	assert_eq(bank.col_at(-1.0), -1)


func test_each_diagonal_subdivision_uses_its_filmed_window_and_own_drawn_row() -> void:
	var sheet: GhostSheet = _tonnage_sheet("p70")
	var centres: Array[float] = [
		0.01748951,
		0.07895263,
		0.17814311,
		0.26271737,
		0.31331201,
		0.38164601,
		0.46397161,
		0.51129322,
		0.54837097,
		0.60396262,
		0.66580052,
		0.73763242,
		0.83032681,
		0.91702479,
		0.96372177,
		0.98790726,
	]
	_check_intervals(sheet._intervals[1], centres, [4, 6, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2, 2])
	_check_detail_rows(sheet, [1, 3, 5, 7], [1, 0, 2, 3], -85.5)


func test_p55_quarters_and_midpoints_enter_and_exit_on_both_profiles() -> void:
	var sheet: GhostSheet = _tonnage_sheet("p55")
	var centres: Array[float] = [
		0.05245536,
		0.17131696,
		0.30970982,
		0.46986607,
		0.61662946,
		0.73828125,
		0.86830357,
		0.96763393,
	]
	_check_intervals(sheet._intervals[0], centres, [4, 4, 4, 4, 4, 4, 2, 2])
	_check_detail_rows(sheet, [0, 4], [2, 1], -89.0)


func _check_detail_rows(
	sheet: GhostSheet, octants: Array[int], rows: Array[int], offset: float
) -> void:
	var spr: Sprite2D = autofree(Sprite2D.new())
	var bank: GhostWalkPages = sheet._intervals[octants[0]]
	for i: int in bank.windows.size():
		var w: Vector2 = bank.windows[i]
		for j: int in octants.size():
			var oct: int = octants[j]
			sheet.show(spr, oct, 0, fposmod((w.x + w.y) * 0.5, 1.0))
			var left: bool = sheet.drawn_left(oct, 0)
			assert_eq(spr.texture, bank.pages[0].left if left else bank.pages[0].tex)
			assert_eq(spr.frame_coords, Vector2i(i, rows[j]))
			assert_false(spr.flip_h)
			assert_eq(spr.offset.x, offset)
	bank.pages[0].left = null
	for oct: int in octants:
		if sheet.drawn_left(oct, 0):
			sheet.show(spr, oct, 0, bank.windows[0].x)
			assert_eq(spr.texture, sheet.left)


func _tonnage_sheet(art: String) -> GhostSheet:
	return GhostSheet.walk_of(
		GhostDrawn.path_of(art, "tonnage"), GhostStride.table_of("tonnage", art)
	)
