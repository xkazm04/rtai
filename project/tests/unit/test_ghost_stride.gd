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
	assert_eq(GhostStride.table_of("tonnage", "p70").size(), 16, "his walk16 (it14)")
	assert_eq(GhostStride.table_of("tonnage", "p55").size(), GhostDrawn.COLS)
	assert_eq(GhostStride.table_of("ohm", "p70").size(), GhostDrawn.COLS)
	assert_eq(GhostStride.table_of("ohm", "p55").size(), 0, "a pitch without a table walks even")
	assert_eq(GhostStride.table_of("nobody", "p70").size(), 0)


func test_every_table_is_one_drawn_cycle_and_shows_every_frame() -> void:
	for key: String in GhostStride.TABLES:
		var row: Array = GhostStride.TABLES[key]
		var steps: PackedFloat32Array = PackedFloat32Array(row)
		var cols: int = GhostStride.cols_of(steps)
		assert_eq(steps.size(), cols, key)
		var seen: Dictionary[int, bool] = {}
		for i: int in 1600:
			seen[GhostStride.col_of(i / 1600.0, steps)] = true
		assert_eq(seen.size(), cols, "%s: every drawn frame shows" % key)
		var parts: PackedStringArray = key.split("/")
		var tex: Texture2D = load(GhostDrawn.path_of(parts[1], parts[0])) as Texture2D
		assert_not_null(tex, "%s: its sheet exists" % key)
		assert_eq(int(tex.get_width()) % cols, 0, "%s: the sheet divides into its columns" % key)


func test_a_sheet_has_as_many_walk_columns_as_its_table() -> void:
	assert_eq(GhostStride.cols_of(PackedFloat32Array()), 8, "no table: a walk8")
	var sixteen: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	sixteen.resize(16)
	sixteen.fill(1.0)
	assert_eq(GhostStride.cols_of(sixteen), 16)


func test_a_galloping_run_row_walks_instead() -> void:
	var off: Dictionary = {"dent/p70": [3]}
	assert_false(GhostStride.runs("dent", "p70", 3, off), "a listed row walks")
	assert_true(GhostStride.runs("dent", "p70", 2, off), "the other rows run")
	assert_true(
		GhostStride.runs("dent", "p55", 3, off), "a pitch without an entry runs on every row"
	)
	assert_true(GhostStride.runs("kerf", "p70", 3, off))


func test_dent_runs_on_every_facing_since_his_fourth_take() -> void:
	for row: int in 5:
		assert_true(GhostStride.runs("dent", "p70", row), "row %d" % row)


func test_a_run16_grid_shows_each_of_its_16_frames() -> void:
	assert_eq(GhostStride.run_table_of("kerf", "p55").size(), 0, "no entry: the run8")
	for key: String in GhostStride.RUN_TABLES:
		var parts: PackedStringArray = key.split("/")
		var steps: PackedFloat32Array = GhostStride.run_table_of(parts[0], parts[1])
		var cols: int = GhostStride.cols_of(steps)
		assert_eq(cols, 16, key)
		var seen: Dictionary = {}
		for i: int in 1600:
			seen[GhostStride.col_of(i / 1600.0, steps)] = true
		assert_eq(seen.size(), cols, "%s: every drawn frame shows" % key)
		for side: String in ["", "_left"]:
			var sheet: String = "run%d%s" % [cols, side]
			var tex: Texture2D = load(GhostDrawn.path_of(parts[1], parts[0], sheet)) as Texture2D
			assert_not_null(tex, "%s %s exists" % [key, sheet])
			if tex != null:
				assert_eq(int(tex.get_width()) % cols, 0, "%s %s divides" % [key, sheet])


func test_cap_preserves_cycle_total_and_uncapped_step_ratios() -> void:
	# 100 / 5 = 20. Capping 60 at 30 pushes 25 over the cap too.
	var steps: PackedFloat32Array = [5.0, 60.0, 0.0, 25.0, 10.0]
	var capped: PackedFloat32Array = GhostStride.capped_steps(steps, 1.5)
	var total: float = 0.0
	for step: float in capped:
		total += step
		assert_lte(step, 30.0)
	assert_almost_eq(total, 100.0, 0.00001)
	assert_eq(capped[1], 30.0)
	assert_eq(capped[3], 30.0)
	assert_eq(capped[2], 0.0)
	assert_almost_eq(capped[4], 2.0 * capped[0], 0.00001)
	assert_eq(steps[1], 60.0, "input contacts stay available")


func test_cap_off_and_loose_cap_reproduce_the_input() -> void:
	var steps: PackedFloat32Array = [5.0, 0.0, 25.0]
	for share: float in [0.0, INF, 4.0]:
		assert_eq(GhostStride.capped_steps(steps, share), steps)
	assert_eq(GhostStride.capped_steps(PackedFloat32Array(), 1.0), PackedFloat32Array())


func test_even_cap_and_redistribution_to_zero_weight_frames() -> void:
	var steps: PackedFloat32Array = [0.0, 12.0, 0.0]
	assert_eq(GhostStride.capped_steps(steps, 1.0), PackedFloat32Array([4.0, 4.0, 4.0]))
	assert_eq(GhostStride.capped_steps(steps, 1.5), PackedFloat32Array([3.0, 6.0, 3.0]))


func test_fractional_steps_keep_their_proportions_at_any_scale() -> void:
	var steps: PackedFloat32Array = [0.125, 0.375, 2.5]
	assert_eq(GhostStride.capped_steps(steps, 2.0), PackedFloat32Array([0.25, 0.75, 2.0]))
	# The tightest feasible cap is the mean.
	assert_eq(GhostStride.capped_steps(steps, 0.5), PackedFloat32Array([1.0, 1.0, 1.0]))


func test_shipped_walk_timing_uses_the_filmed_cap_for_each_pitch() -> void:
	assert_eq(GhostStride.MAX_STEP_SHARE["tonnage/p70"], 2.0)
	assert_eq(GhostStride.MAX_STEP_SHARE["tonnage/p55"], 0.0)
	var p70: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p70"])
	assert_eq(GhostStride.table_of("tonnage", "p70"), GhostStride.capped_steps(p70, 2.0))
	var p55: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p55"])
	assert_eq(GhostStride.table_of("tonnage", "p55"), p55)
	var ohm: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["ohm/p70"])
	assert_eq(GhostStride.table_of("ohm", "p70"), ohm)
