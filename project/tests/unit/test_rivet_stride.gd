extends GutTest
## n10 world item 4: the drawn walk's row and its play direction follow the walk, not only the aim.


func after_each() -> void:
	RivetStride.enabled = true


func _rig(deg: float, speed: float = 120.0) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.vel_in = Vector2.from_angle(deg_to_rad(deg)) * speed
	return rig


func test_a_walk_along_the_aim_keeps_the_aims_row_and_steps_forward() -> void:
	for o: int in range(8):
		var rig: CutRig = _rig(o * 45.0)
		assert_eq(RivetStride.row(rig, o), o, "octant %d" % o)
		assert_eq(RivetStride.direction(rig, o), 1.0, "octant %d forward" % o)


func test_a_strafe_turns_the_row_one_toward_the_walk_and_no_further() -> void:
	assert_eq(RivetStride.row(_rig(90.0), 0), 1, "strafe toward +: one row")
	assert_eq(RivetStride.row(_rig(-90.0), 0), 7, "strafe toward -: one row")
	assert_eq(RivetStride.row(_rig(40.0), 0), 1, "past the halfway plus the hold")
	assert_eq(RivetStride.row(_rig(20.0), 0), 0, "inside the row: no turn")
	assert_eq(RivetStride.direction(_rig(90.0), 0), 1.0, "a strafe is not a backpedal")


func test_the_row_holds_across_the_halfway_point() -> void:
	var rig: CutRig = _rig(30.0)
	assert_eq(RivetStride.row(rig, 0), 0, "two thirds of a row is not yet past the hold")
	rig.vel_in = Vector2.from_angle(deg_to_rad(40.0)) * 120.0
	assert_eq(RivetStride.row(rig, 0), 1, "past it the row turns")
	rig.t_alive += RivetStride.DWELL_S
	rig.vel_in = Vector2.from_angle(deg_to_rad(20.0)) * 120.0
	assert_eq(RivetStride.row(rig, 0), 1, "and stays turned coming back through halfway")
	rig.vel_in = Vector2.from_angle(deg_to_rad(5.0)) * 120.0
	assert_eq(RivetStride.row(rig, 0), 0, "until the walk is clearly on the aim's row")


func test_a_reversal_cannot_flash_a_row_inside_the_dwell() -> void:
	var rig: CutRig = _rig(90.0)
	assert_eq(RivetStride.row(rig, 0), 1, "the strafe's row")
	rig.vel_in = Vector2.from_angle(deg_to_rad(-90.0)) * 120.0
	rig.t_alive += RivetStride.DWELL_S * 0.5
	assert_eq(RivetStride.row(rig, 0), 1, "inside the dwell the row holds")
	rig.t_alive += RivetStride.DWELL_S * 0.5
	assert_eq(RivetStride.row(rig, 0), 7, "after it the row may turn")


func test_a_stale_row_more_than_a_turn_off_the_aim_is_dropped() -> void:
	var rig: CutRig = _rig(0.0)
	rig.set_meta(RivetStride.META_ROW, 3)
	assert_eq(RivetStride.row(rig, 0), 0, "the held row is three off this aim")


func test_the_row_wraps_round_the_compass() -> void:
	assert_eq(RivetStride.row(_rig(0.0), 7), 0, "row 7 turned + wraps to 0")
	assert_eq(RivetStride.row(_rig(-90.0), 0), 7, "row 0 turned - wraps to 7")


func test_a_backpedal_folds_the_walk_and_plays_the_grid_backwards() -> void:
	assert_eq(RivetStride.direction(_rig(180.0), 0), -1.0, "straight back")
	assert_eq(RivetStride.row(_rig(180.0), 0), 0, "straight back keeps the aim's row")
	assert_eq(RivetStride.row(_rig(140.0), 0), 7, "back and to +: the row turns to -")
	assert_eq(RivetStride.row(_rig(-140.0), 0), 1, "back and to -: the row turns to +")


func test_the_fold_is_latched_across_the_hips_angle() -> void:
	var rig: CutRig = _rig(110.0)
	assert_eq(RivetStride.direction(rig, 0), 1.0, "110 deg from forward is still a sidestep")
	rig.vel_in = Vector2.from_angle(deg_to_rad(130.0)) * 120.0
	assert_eq(RivetStride.direction(rig, 0), -1.0, "past 120 it folds")
	rig.vel_in = Vector2.from_angle(deg_to_rad(100.0)) * 120.0
	assert_eq(RivetStride.direction(rig, 0), -1.0, "back through 105 it stays folded")
	rig.vel_in = Vector2.from_angle(deg_to_rad(85.0)) * 120.0
	assert_eq(RivetStride.direction(rig, 0), 1.0, "under 90 it unfolds")


func test_a_stop_holds_the_last_turn() -> void:
	var rig: CutRig = _rig(90.0)
	assert_eq(RivetStride.row(rig, 0), 1)
	rig.vel_in = Vector2.ZERO
	assert_eq(RivetStride.row(rig, 0), 1, "the reversal's one still tick keeps the row")
	assert_eq(RivetStride.direction(rig, 0), 1.0, "and steps forward")


func test_off_is_the_aims_row_forward() -> void:
	RivetStride.enabled = false
	assert_eq(RivetStride.row(_rig(90.0), 3), 3)
	assert_eq(RivetStride.direction(_rig(180.0), 0), 1.0)


func _rig_with_head(deg: float, aim_deg: float) -> CutRig:
	var rig: CutRig = _rig(deg, 40.0)
	rig.speed_now = 40.0
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	head.global_rotation = deg_to_rad(aim_deg)
	rig.head = head
	return rig


func test_the_grid_phase_runs_backwards_on_a_backpedal() -> void:
	var rig: CutRig = _rig_with_head(180.0, 0.0)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.0, 0.0001, "the first call anchors")
	rig.global_position += Vector2(-7.5, 0.0)  # a quarter of the 30 px cycle
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.75, 0.0001, "a quarter back")


func test_the_grid_phase_runs_forward_on_a_strafe() -> void:
	var rig: CutRig = _rig_with_head(90.0, 0.0)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.0, 0.0001, "the first call anchors")
	rig.global_position += Vector2(0.0, 7.5)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.25, 0.0001, "a quarter forward")


func test_the_cell_drawn_for_a_strafe_is_the_turned_row() -> void:
	var rig: CutRig = _rig_with_head(90.0, 0.0)
	var want: int = RivetFrames.BASE_OCT[1] * 8
	assert_eq(RivetFrames.cell_of(rig, 8, 0.0), Vector2i(want, 0), "aim right, walk down: row 1")
