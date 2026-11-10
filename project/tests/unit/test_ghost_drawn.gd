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
	assert_eq(d._column(host, 0.5, 2), GhostDrawn.STAND_COL)
	assert_eq(d._column(host, 0.5, 2), GhostDrawn.STAND_COL, "no ground walked")


func test_the_column_advances_with_the_ground_walked() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	assert_eq(d._column(host, 0.5, 2), GhostDrawn.STAND_COL)
	host.position.x += 3.0
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5, 2)
	assert_almost_eq(d._phase, 3.0 / 90.0, 0.0001, "one cycle = cycle_cell x the scale")


func test_a_backpedal_runs_the_grid_backward() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5, 2)
	host.position.x -= 3.0  # facing +x
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5, 2)
	assert_almost_eq(d._phase, 1.0 - 3.0 / 90.0, 0.0001)


func test_a_frame_without_a_sim_step_keeps_the_stride_then_he_stands() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5, 2)
	host.position.x += 30.0
	var walking: int = d._column(host, 0.5, 2)
	assert_ne(walking, GhostDrawn.STAND_COL, "30 px is a third of a cycle")
	assert_eq(d._column(host, 0.5, 2), walking, "one still frame holds it")
	for i: int in GhostDrawn.STILL_FRAMES:
		@warning_ignore("return_value_discarded")
		d._column(host, 0.5, 2)
	assert_eq(d._column(host, 0.5, 2), GhostDrawn.STAND_COL)


func test_a_look_resting_on_a_boundary_holds_its_octant() -> void:
	var d: GhostDrawn = _drawn()
	assert_eq(d.octant(0.0), 0)
	assert_eq(d.octant(PI / 8.0 + deg_to_rad(2.0)), 0, "inside the hold")
	assert_eq(d.octant(PI / 8.0 + deg_to_rad(6.0)), 1, "past the hold")
	assert_eq(d.octant(PI / 8.0 - deg_to_rad(2.0)), 1, "and it holds coming back")


func test_every_shipped_ghost_grid_divides_into_its_cells() -> void:
	for ghost: String in ["kerf", "dent", "tonnage", "ohm"]:
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
		assert_eq(d._column(host, 0.5, 2), GhostDrawn.STAND_COL, "tick %d" % i)


func test_a_given_look_turns_the_backpedal_test_not_the_host() -> void:
	var d: GhostDrawn = _drawn()
	d._look = PI  # the look points back along the travel; the host itself has rotation 0
	var host: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	d._column(host, 0.5, 2)
	host.global_position.x += 10.0
	var first: int = d._column(host, 0.5, 2)
	assert_eq(first, GhostDrawn.COLS - 1, "a backpedal steps the cycle backward from 0")


func test_a_strike_plays_cut_then_follow_through_then_ends() -> void:
	var d: GhostDrawn = _drawn()
	d.feed(3, -1, 100)
	assert_eq(d.act_col(), -1, "first sight of the counter only arms it")
	d.feed(4, -1, 110)
	assert_eq(d.act_col(), GhostDrawn.CUT_COL)
	d.feed(4, -1, 110 + GhostDrawn.CUT_TICKS)
	assert_eq(d.act_col(), GhostDrawn.FOLLOW_COL)
	d.feed(4, -1, 110 + GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS)
	assert_eq(d.act_col(), -1)


func test_a_hit_flinches_but_a_strike_wins() -> void:
	var d: GhostDrawn = _drawn()
	d.feed(0, 200, 200)
	assert_eq(d.act_col(), GhostDrawn.HIT_COL)
	d.feed(1, 201, 201)
	assert_eq(d.act_col(), GhostDrawn.CUT_COL, "strike wins over the flinch")
	d.feed(1, 201, 201 + GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS + GhostDrawn.HIT_TICKS)
	assert_eq(d.act_col(), -1)


func test_every_ghost_act_grid_divides_into_its_cells() -> void:
	for ghost: String in ["kerf", "dent", "tonnage", "ohm"]:
		var tex: Texture2D = load(GhostDrawn.path_of(P70, ghost, "act")) as Texture2D
		assert_not_null(tex, ghost)
		var cols: int = GhostDrawn.JAB_COLS.get(ghost + "/" + P70, GhostDrawn.ACT_COLS)
		assert_eq(tex.get_width() % cols, 0, ghost)
		assert_eq(tex.get_height() % GhostDrawn.ROWS, 0, ghost)


func test_a_counter_that_starts_at_minus_one_still_plays_its_first_strike() -> void:
	var d: GhostDrawn = _drawn()
	d.feed(-1, -1, 10)
	d.feed(50, -1, 50)
	assert_eq(d.act_col(), GhostDrawn.CUT_COL, "Tonnage's stomp_tick starts at -1")


func test_a_wind_up_shows_the_wind_up_cell_before_the_strike() -> void:
	var d: GhostDrawn = _drawn()
	d.feed(0, -1, 10, true)
	assert_eq(d.act_col(), GhostDrawn.WINDUP_COL)
	d.feed(1, -1, 40, false)
	assert_eq(d.act_col(), GhostDrawn.CUT_COL, "the strike takes over when the wind-up lands")


func test_a_run_grid_takes_over_above_the_run_speed_and_steps_on_its_longer_cycle() -> void:
	var d: GhostDrawn = GhostDrawn.new("kerf", 1.8, 139.0, 173.0, 388.0)
	d._run = GhostSheet.new(PlaceholderTexture2D.new(), GhostDrawn.COLS)
	var host: Node2D = autofree(Node2D.new())
	host.global_position = Vector2.ZERO
	assert_true(d._column(host, 1.0, 2) >= 0)
	var walk_px: float = 1.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	host.global_position += Vector2.RIGHT * walk_px
	assert_true(d._column(host, 1.0, 2) >= 0)
	assert_false(d._running, "1 m/s is a walk")
	var run_px: float = 12.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	var before: float = d._phase
	host.global_position += Vector2.RIGHT * run_px
	assert_true(d._column(host, 1.0, 2) >= 0)
	assert_true(d._running, "12 m/s is a run")
	assert_almost_eq(d._phase - before, run_px / maxf(388.0, 12.0 * SimConst.PX_PER_M / 3.5), 1e-4)


func test_a_ghost_without_a_run_grid_keeps_walking_at_speed() -> void:
	var d: GhostDrawn = _drawn()
	var host: Node2D = autofree(Node2D.new())
	host.global_position = Vector2.ZERO
	assert_true(d._column(host, 1.0, 2) >= 0)
	host.global_position += Vector2.RIGHT * 12.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	assert_true(d._column(host, 1.0, 2) >= 0)
	assert_false(d._running)


func test_a_run_needs_its_sheet_at_this_pitch_and_a_run_row() -> void:
	var d: GhostDrawn = GhostDrawn.new("dent", 1.8, 163.0, 176.5, 330.0)
	d._art = "p70"
	var host: Node2D = autofree(Node2D.new())
	var run_px: float = 7.0 * SimConst.PX_PER_M * SimClock.TICK_DT
	assert_true(d._column(host, 1.0, 2) >= 0)
	host.global_position += Vector2.RIGHT * run_px
	assert_true(d._column(host, 1.0, 2) >= 0)
	assert_false(d._running, "no run sheet under this art (Dent at 55): he walks")
	d._run = GhostSheet.new(PlaceholderTexture2D.new(), GhostDrawn.COLS)
	host.global_position += Vector2.RIGHT * run_px
	assert_true(d._column(host, 1.0, 2) >= 0)
	assert_true(d._running, "7 m/s runs on the profile row")
	host.global_position += Vector2.RIGHT * run_px
	assert_true(d._column(host, 1.0, 3) >= 0)
	assert_true(d._running, "the 3/4 away row runs since its fourth take (it14)")
