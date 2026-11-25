extends GutTest
## n11 hero (the owner's "Rivet jumps too much") and n31 ("the shadow below looks like flying"):
## each grid row aims at one figure height, by a squash/stretch about the feet; a run frame lifts
## only what the stretch cannot carry, capped.

const P70: String = "p70/rivet_run8.png"
const PISTOL: String = "p70/rivet_run8_eq_pistol.png"
const CELL_H: float = 196.0 / RivetWalk.RES  # the p70 run recut's cell in 110-space px


func _grids() -> Dictionary:
	var t: DataTable = DataTable.open(RivetBob.TABLE, RivetBob.SCHEMA)
	return t.object(t.raw, "grids")


## The widest helmet travel left in any row of `key`, 110-space px (heights from the feet).
func _travel(key: String, running: bool) -> float:
	var rows: Array = _grids()[key]
	var worst: float = 0.0
	for r: int in rows.size():
		var row: Array = rows[r]
		var heights: Array[float] = []
		for c: int in row.size():
			var top: int = row[c]
			var f: Vector2 = RivetBob.fit(key, r * row.size() + c, row.size(), running, CELL_H)
			heights.append((CELL_H - float(top)) * f.x + f.y)
		var hi: float = heights.max()
		var lo: float = heights.min()
		worst = maxf(worst, hi - lo)
	return worst


func test_the_table_is_valid_and_measures_the_run_grid() -> void:
	var t: DataTable = DataTable.open(RivetBob.TABLE, RivetBob.SCHEMA)
	assert_true(t.errors().is_empty(), "table valid")
	assert_true(t.object(t.raw, "grids").has(P70), "p70 run grid measured")


func test_the_run_keeps_a_fifth_of_its_helmet_travel() -> void:
	assert_lt(_travel(P70, true), 4.0)  # raw 26 px: the N row
	assert_lt(_travel(PISTOL, true), 5.0)  # raw 29 px: the N row's flight frame


func test_the_walk_keeps_under_a_third() -> void:
	assert_lt(_travel("p70/rivet_walk8.png", false), 4.0)  # raw range 12


func test_no_rubber_man_and_a_capped_lift_on_every_grid_frame() -> void:
	var grids: Dictionary = _grids()
	for key: String in grids:
		var rows: Array = grids[key]
		var first: Array = rows[0]
		var cols: int = first.size()
		for f: int in rows.size() * cols:
			var fit: Vector2 = RivetBob.fit(key, f, cols, "run" in key, CELL_H)
			assert_between(fit.x, 0.9199, 1.1201, "%s frame %d stretch" % [key, f])
			assert_between(fit.y, 0.0, 2.2001, "%s frame %d lift" % [key, f])


func test_a_walk_stays_planted_every_grid_and_frame() -> void:
	var grids: Dictionary = _grids()
	for key: String in grids:
		if "walk" not in key:
			continue
		var rows: Array = grids[key]
		var first: Array = rows[0]
		var cols: int = first.size()
		for f: int in rows.size() * cols:
			assert_eq(RivetBob.fit(key, f, cols, false, CELL_H).y, 0.0, "%s frame %d" % [key, f])


func test_only_the_n_row_flight_frames_leave_the_ground() -> void:
	# p70 pistol run, row 4 (facing N): tops 3..32: the short (flight) columns lift, the tall stand
	var lifted: int = 0
	for c: int in 8:
		lifted += 1 if RivetBob.fit(PISTOL, 32 + c, 8, true, CELL_H).y > 0.0 else 0
	assert_between(lifted, 1, 4, "the short half at most")
	assert_eq(RivetBob.fit(PISTOL, 32, 8, true, CELL_H).y, 0.0, "the tallest frame stands")


func test_unknown_strips_and_the_off_switch_draw_as_cut() -> void:
	assert_eq(RivetBob.fit("p70/not_there.png", 3, 8, true, CELL_H), Vector2(1.0, 0.0))
	RivetBob.enabled = false
	var off: Vector2 = RivetBob.fit(PISTOL, 35, 8, true, CELL_H)
	RivetBob.enabled = true
	assert_eq(off, Vector2(1.0, 0.0))
