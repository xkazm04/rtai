extends GutTest
## d9 rivet (Call 2): the drawn stride grid is picked by octant and stride phase, bare-claw only.


func after_each() -> void:
	RivetWalk.enabled = true
	RivetWalk.frames = 8
	RivetWalk.armed = true


func test_the_frame_follows_the_octant_row_and_the_stride_phase() -> void:
	var oct: PackedInt32Array = RivetFrames.BASE_OCT
	assert_eq(RivetWalk.frame_of(0, 0.0, 4), oct[0] * 4, "screen right: profile row, contact")
	assert_eq(RivetWalk.frame_of(0, 0.3, 4), oct[0] * 4 + 1, "passing")
	assert_eq(RivetWalk.frame_of(2, 0.6, 4), oct[2] * 4 + 2, "toward the camera, other foot")
	assert_eq(RivetWalk.frame_of(5, 1.99, 4), oct[5] * 4 + 3, "a drawn left row, wraps")
	assert_eq(RivetWalk.frame_of(4, -0.1, 4), oct[4] * 4 + 3, "negative phase wraps")


func test_no_grid_standing_or_with_the_bob_flag() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = 0.0
	assert_eq(RivetWalk.path_of(rig, "p70", &""), "", "standing keeps the facing")
	rig.speed_now = RivetFrames.MOVING + 10.0
	RivetWalk.enabled = false
	assert_eq(RivetWalk.path_of(rig, "p70", &""), "", "--rivet-walk=bob")
	RivetWalk.enabled = true
	var want: String = RivetStrips.DIR + "p70/" + RivetWalk.STRIP
	var got: String = RivetWalk.path_of(rig, "p70", &"")
	assert_eq(
		got, want if ResourceLoader.exists(want) else "", "the grid only when the art has one"
	)


func test_each_art_key_ships_grids_of_eight_and_four_frames_by_eight_rows() -> void:
	for art: String in ["p70", "p55"]:
		_check_grid(art, RivetWalk.STRIP, 8)
		_check_grid(art, RivetWalk.STRIP4, 4)


func _check_grid(art: String, strip: String, n: int) -> void:
	RivetWalk.frames = n
	var path: String = RivetStrips.DIR + art + "/" + strip
	assert_true(ResourceLoader.exists(path), "%s has the drawn stride %s" % [art, strip])
	var tex: Texture2D = load(path) as Texture2D
	assert_eq(tex.get_width() % n, 0, "%s: whole cells across" % art)
	assert_eq(tex.get_height() % RivetWalk.ROWS, 0, "%s: whole cells down" % art)
	var cell_h: float = tex.get_height() / float(RivetWalk.ROWS)
	assert_gt(cell_h, RivetFrames.FIG_PX, "%s: a cell holds the 110 px figure" % art)
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetFrames.MOVING + 10.0
	assert_eq(RivetWalk.path_of(rig, art, &""), path, "%s: walking bare-claw takes it" % art)


func test_the_eight_frame_walk_steps_by_the_ground_walked() -> void:
	# n9: one drawn cycle = CYCLE_CELL cell px x the card scale while the cadence is readable
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = 40.0  # slow: the measured cycle rules
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.0, 0.0001, "the first call anchors")
	rig.global_position += Vector2(15.0, 0.0)  # half of the 30 px cycle (60 cell px x 0.5)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.5, 0.0001, "half a cycle")
	rig.speed_now = 240.0  # fast: the cadence holds at MAX_CYCLES_S (cycle 120 px)
	rig.global_position += Vector2(30.0, 0.0)
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.75, 0.0001, "capped cadence")
	rig.phase = 0.4
	RivetWalk.frames = 4
	assert_almost_eq(RivetWalk.phase_of(rig, "p70", 0.5), 0.4, 0.0001, "d9 grid: gait phase")


func test_a_weapon_out_walks_its_drawn_armed_grid_until_it_fires() -> void:
	# n9 it4: the library's armed walks, one per weapon each draws; 4 frames x 8 rows
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetFrames.MOVING + 10.0
	for art: String in ["p70", "p55"]:
		for w: StringName in [&"pistol", &"plasma_rifle", &"katana", &"gatling", &"flamethrower"]:
			var path: String = RivetStrips.DIR + art + "/" + RivetWalk.ARMED + String(w) + ".png"
			assert_eq(RivetWalk.path_of(rig, art, w), path, "%s %s walks drawn" % [art, w])
			assert_eq(RivetWalk.cols_of(path), 4, "%s %s: 4 frames" % [art, w])
			var tex: Texture2D = load(path) as Texture2D
			assert_eq(tex.get_width() % 4 + tex.get_height() % RivetWalk.ROWS, 0, "whole cells")
	assert_eq(RivetWalk.path_of(rig, "p70", &"chainsaw"), "", "no drawn walk: the facing card")
	rig.set_meta(RivetFrames.FIRE, true)
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), "", "a shot latches the fire cell")
	rig.set_meta(RivetFrames.FIRE, false)
	RivetWalk.armed = false
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), "", "--rivet-walk-armed=off")


func test_the_grid_columns_by_strip_name() -> void:
	assert_eq(RivetWalk.cols_of(RivetStrips.DIR + "p70/" + RivetWalk.STRIP), 8)
	assert_eq(RivetWalk.cols_of(RivetStrips.DIR + "p70/" + RivetWalk.STRIP4), 4)
	assert_eq(RivetWalk.cols_of(RivetStrips.DIR + "p70/rivet_eq_pistol.png"), 0)
	assert_eq(RivetWalk.cols_of(RivetStrips.DIR + "p70/" + RivetStrips.BASE), 0)
