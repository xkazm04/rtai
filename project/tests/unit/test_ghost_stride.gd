extends GutTest

const EVEN: PackedFloat32Array = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0]


func test_no_steps_is_the_even_cycle() -> void:
	for i: int in 16:
		var phase: float = i / 16.0
		assert_eq(GhostStride.col_of(phase, PackedFloat32Array()), int(phase * 8.0))


func test_even_steps_are_the_even_cycle() -> void:
	assert_eq(GhostStride.col_of(0.0, EVEN), 0)
	assert_eq(GhostStride.col_of(3.0 / 8.0 + 0.01, EVEN), 3)
	assert_eq(GhostStride.col_of(0.999, EVEN), 7)


func test_a_frame_shows_while_the_ground_moves_its_drawn_step() -> void:
	# frame 2 -> 3 is drawn as a long step (60 of 130): frames 2 and 3 hold longer than the rest
	var steps: PackedFloat32Array = [10.0, 10.0, 60.0, 10.0, 10.0, 10.0, 10.0, 10.0]
	var shown: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	shown.resize(8)
	for i: int in 1300:
		shown[GhostStride.col_of(i / 1300.0, steps)] += 1
	assert_gt(shown[2], shown[0] * 3, "a long step holds its frame longer")
	assert_gt(shown[3], shown[5] * 2)
	assert_eq(shown[2], 350, "(10 + 60) / 2 of 130 is 350 of 1300 samples")


func test_a_still_frame_keeps_a_floor() -> void:
	var steps: PackedFloat32Array = [47.0, 14.0, 58.5, 29.4, 25.0, 31.5, 29.4, 0.5]
	var seen: Dictionary[int, bool] = {}
	for i: int in 400:
		seen[GhostStride.col_of(i / 400.0, steps)] = true
	assert_eq(seen.size(), 8, "every drawn frame shows")


func test_tables_are_keyed_by_ghost_and_art() -> void:
	assert_eq(GhostStride.table_of("tonnage", "p70").size(), GhostDrawn.COLS)
	assert_eq(GhostStride.table_of("ohm", "p70").size(), GhostDrawn.COLS)
	assert_eq(GhostStride.table_of("ohm", "p55").size(), 0, "a pitch without a table walks even")
	assert_eq(GhostStride.table_of("nobody", "p70").size(), 0)


func test_every_table_is_one_drawn_cycle_and_shows_every_frame() -> void:
	for key: String in GhostStride.TABLES:
		var row: Array = GhostStride.TABLES[key]
		var steps: PackedFloat32Array = PackedFloat32Array(row)
		assert_eq(steps.size(), GhostDrawn.COLS, key)
		var seen: Dictionary[int, bool] = {}
		for i: int in 800:
			seen[GhostStride.col_of(i / 800.0, steps)] = true
		assert_eq(seen.size(), GhostDrawn.COLS, "%s: every drawn frame shows" % key)


func test_a_galloping_run_row_walks_instead() -> void:
	assert_false(GhostStride.runs("dent", "p70", 3), "Dent's 3/4 away run gallops")
	assert_true(GhostStride.runs("dent", "p70", 2), "his profile run alternates legs")
	assert_true(GhostStride.runs("dent", "p55", 3), "a pitch without an entry runs on every row")
	assert_true(GhostStride.runs("kerf", "p70", 3))
