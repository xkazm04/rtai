extends GutTest
## n11 hero (the owner's "Rivet jumps too much"): the drawn helmet's travel per stride is damped.

const P70: String = "p70/rivet_run8.png"


func _range_after(key: String, cols: int, running: bool) -> float:
	var t: DataTable = DataTable.open(RivetBob.TABLE, RivetBob.SCHEMA)
	var grids: Dictionary = t.object(t.raw, "grids")
	var rows: Array = grids[key]
	var worst: float = 0.0
	for r: int in rows.size():
		var steady: Array[float] = []
		for c: int in cols:
			var cell: Array = rows[r]
			var top: float = cell[c]
			steady.append(top - RivetBob.taken_cell(key, r * cols + c, cols, running))
		var hi: float = steady.max()
		var lo: float = steady.min()
		worst = maxf(worst, hi - lo)
	return worst


func test_the_run_grid_table_is_measured() -> void:
	var t: DataTable = DataTable.open(RivetBob.TABLE, RivetBob.SCHEMA)
	assert_true(t.errors().is_empty(), "table valid")
	assert_true(t.object(t.raw, "grids").has(P70), "p70 run grid measured")


func test_the_run_keeps_under_a_third_of_its_helmet_travel() -> void:
	assert_lt(_range_after(P70, 8, true), 7.5)  # raw range 26-29 px


func test_the_walk_keeps_under_half() -> void:
	assert_lt(_range_after("p70/rivet_walk8.png", 8, false), 4.0)  # raw range 12


func test_no_lift_for_an_unknown_strip() -> void:
	assert_eq(RivetBob.lift_cell("p70/not_there.png", 3, 8, true), 0.0)
	assert_eq(RivetBob.stretch_cell("p70/not_there.png", 3, 8, true), 0.0)


func test_a_walk_stays_planted_every_grid_and_frame() -> void:
	var t: DataTable = DataTable.open(RivetBob.TABLE, RivetBob.SCHEMA)
	var grids: Dictionary = t.object(t.raw, "grids")
	for key: String in grids:
		if "walk" not in key:
			continue
		var rows: Array = grids[key]
		var first: Array = rows[0]
		var cols: int = first.size()
		for f: int in rows.size() * cols:
			assert_eq(RivetBob.lift_cell(key, f, cols, false), 0.0, "%s frame %d" % [key, f])


func test_only_the_run_flight_frames_leave_the_ground() -> void:
	# p70 run8, row 0: helmet tops 10..29: the low-head (flight) columns lift, the stance ones do not
	var lifted: int = 0
	for c: int in 8:
		lifted += 1 if RivetBob.lift_cell(P70, c, 8, true) > 0.0 else 0
	assert_between(lifted, 1, 4, "the flight frames only")
