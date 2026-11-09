extends GutTest
## n11 hero: a ghost's drawn walk steps by the ground walked, and runs backward on a backpedal.

const P70: String = "p70"


func _drawn() -> GhostDrawn:
	return GhostDrawn.new("kerf", 1.8, 180.0, 173.0)


func test_kerfs_grid_ships_and_divides_into_its_cells() -> void:
	var tex: Texture2D = load(GhostDrawn.path_of(P70, "kerf")) as Texture2D
	assert_not_null(tex)
	assert_eq(tex.get_width() % GhostDrawn.COLS, 0)
	assert_eq(tex.get_height() % GhostDrawn.ROWS, 0)


func test_standing_still_shows_the_standing_cell() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	assert_eq(d._column(host, 0.5), GhostDrawn.STAND_COL)
	assert_eq(d._column(host, 0.5), GhostDrawn.STAND_COL, "no ground walked")


func test_the_column_advances_with_the_ground_walked() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	assert_eq(d._column(host, 0.5), GhostDrawn.STAND_COL)
	host.position.x += 3.0
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5)
	assert_almost_eq(d._phase, 3.0 / 90.0, 0.0001, "one cycle = cycle_cell x the scale")


func test_a_backpedal_runs_the_grid_backward() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5)
	host.position.x -= 3.0  # facing +x
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5)
	assert_almost_eq(d._phase, 1.0 - 3.0 / 90.0, 0.0001)


func test_a_frame_without_a_sim_step_keeps_the_stride_then_he_stands() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5)
	host.position.x += 30.0
	var walking: int = d._column(host, 0.5)
	assert_ne(walking, GhostDrawn.STAND_COL, "30 px is a third of a cycle")
	assert_eq(d._column(host, 0.5), walking, "one still frame holds it")
	for i: int in GhostDrawn.STILL_FRAMES:
		@warning_ignore("return_value_discarded")
		d._column(host, 0.5)
	assert_eq(d._column(host, 0.5), GhostDrawn.STAND_COL)


func test_a_look_resting_on_a_boundary_holds_its_octant() -> void:
	var d: GhostDrawn = _drawn()
	assert_eq(d.octant(0.0), 0)
	assert_eq(d.octant(PI / 8.0 + deg_to_rad(2.0)), 0, "inside the hold")
	assert_eq(d.octant(PI / 8.0 + deg_to_rad(6.0)), 1, "past the hold")
	assert_eq(d.octant(PI / 8.0 - deg_to_rad(2.0)), 1, "and it holds coming back")


func test_every_shipped_ghost_grid_divides_into_its_cells() -> void:
	for ghost: String in ["kerf", "dent", "tonnage"]:
		var tex: Texture2D = load(GhostDrawn.path_of(P70, ghost)) as Texture2D
		assert_not_null(tex, ghost)
		assert_eq(tex.get_width() % GhostDrawn.COLS, 0, ghost)
		assert_eq(tex.get_height() % GhostDrawn.ROWS, 0, ghost)


func test_a_form_carried_by_something_else_stands() -> void:
	var d: GhostDrawn = _drawn()
	d.still = true
	var host: Node2D = add_child_autofree(Node2D.new())
	for i: int in 6:
		host.global_position.x += 10.0
		assert_eq(d._column(host, 0.5), GhostDrawn.STAND_COL, "tick %d" % i)


func test_a_given_look_turns_the_backpedal_test_not_the_host() -> void:
	var d: GhostDrawn = _drawn()
	d._look = PI  # the look points back along the travel; the host itself has rotation 0
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5)
	host.global_position.x += 10.0
	var first: int = d._column(host, 0.5)
	assert_eq(first, GhostDrawn.COLS - 1, "a backpedal steps the cycle backward from 0")
