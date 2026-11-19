extends GutTest


func test_p55_new_octants_cross_each_page_and_window_at_the_measured_phase() -> void:
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p55")
	var sheet: GhostSheet = GhostSheet.walk_of(GhostDrawn.path_of("p55", "tonnage"), steps)
	_check_walk(sheet, steps, [6, 8, 8, 8, 6, 6, 6, 4], [1, 2, 3, 5, 6, 7])


func test_p70_straight_rows_cross_both_atlas_pages() -> void:
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p70")
	var sheet: GhostSheet = GhostSheet.walk_of(GhostDrawn.path_of("p70", "tonnage"), steps)
	_check_walk(sheet, steps, [4, 6, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2, 2], [2, 6])


func _check_walk(
	sheet: GhostSheet, steps: PackedFloat32Array, divisions: Array[int], octants: Array[int]
) -> void:
	var bank: GhostWalkPages = sheet._intervals[octants[0]]
	var spr: Sprite2D = autofree(Sprite2D.new())
	var dwell: PackedFloat32Array = GhostStride.dwell_of(steps)
	var total: float = 0.0
	for weight: float in dwell:
		total += weight
	var elapsed: float = 0.0
	var index: int = 0
	for i: int in steps.size():
		var start: float = (elapsed + dwell[i] / 2.0) / total
		var span: float = (dwell[i] + dwell[(i + 1) % steps.size()]) / (2.0 * total)
		for j: int in range(1, divisions[i]):
			var w: Vector2 = bank.windows[index]
			var lo: float = start + span * (j - 0.5) / divisions[i]
			var hi: float = start + span * (j + 0.5) / divisions[i]
			assert_almost_eq(w, Vector2(lo, hi), Vector2.ONE * 0.000001)
			assert_eq(bank.col_at(fposmod(w.x, 1.0)), index)
			assert_eq(bank.col_at(fposmod(w.y, 1.0)), index + 1 if j + 1 < divisions[i] else -1)
			for oct: int in octants:
				sheet.show(spr, oct, i, fposmod((w.x + w.y) / 2.0, 1.0))
				_check_cell(spr, bank, index, oct)
			index += 1
		elapsed += dwell[i]
	assert_eq(index, bank.windows.size())


func _check_cell(spr: Sprite2D, bank: GhostWalkPages, index: int, oct: int) -> void:
	var width: int = bank.pages[0].cols
	@warning_ignore("integer_division")
	var page: GhostSheet = bank.pages[index / width]
	var left: bool = GhostSheet.LEFT_ROW[oct] >= 0
	assert_eq(spr.texture, page.left if left else page.tex)
	assert_eq(spr.frame_coords.x, index % width)
	assert_eq(GhostSheet.oct_of(spr), oct)
	assert_false(spr.flip_h)
