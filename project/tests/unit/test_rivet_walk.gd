extends GutTest
## d9 rivet (Call 2): the drawn stride grid is picked by octant and stride phase, bare-claw only.


func after_each() -> void:
	RivetWalk.enabled = true
	RivetWalk.frames = 8
	RivetWalk.armed = true
	RivetWalk.run = true


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


func test_bare_claw_runs_on_the_drawn_run_above_the_run_speed() -> void:
	# n9 it4: the library's run8 at p70 (55 not yet: row 4 missing), walk8 below RUN_FROM_MPS
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetWalk.RUN_FROM_MPS * CharacterRigs.PX_PER_M + 10.0
	var run: String = RivetStrips.DIR + "p70/" + RivetWalk.RUN
	assert_eq(RivetWalk.path_of(rig, "p70", &""), run, "fast: the run")
	assert_eq(RivetWalk.cols_of(run), 8, "8 frames")
	RivetWalk.run = false
	assert_true(RivetWalk.path_of(rig, "p70", &"").ends_with(RivetWalk.STRIP), "--rivet-walk=walk8")
	RivetWalk.run = true
	rig.speed_now = RivetWalk.RUN_FROM_MPS * CharacterRigs.PX_PER_M - 10.0
	assert_true(RivetWalk.path_of(rig, "p70", &"").ends_with(RivetWalk.STRIP), "slow: the walk")


func test_the_run_cycle_is_the_drawn_stance_travel_per_frame_step() -> void:
	# n9 it5: the profile rows' stance foot moves 62-67 cell px over two frame steps (contact to
	# push-off), so one frame step is ~32 cell px of ground; the run (6.75 m/s) plants under the cap
	var step_cell: float = RivetWalk.RUN_CYCLE_CELL["p70"] / 8.0
	assert_between(step_cell, 31.0, 34.0)
	var cycle_m: float = RivetWalk.RUN_CYCLE_CELL["p70"] / RivetFrames.FIG_PX * RivetFrames.HEIGHT_M
	assert_lt(6.75 / cycle_m, RivetWalk.MAX_RUN_CYCLES_S, "the run's cadence is under the cap")


func test_every_run_strip_has_a_measured_cycle() -> void:
	# n9 it6: the p55 run (row 4 served): its profile stance foot moves ~53 cell px over two steps
	for art: String in ["p70", "p55"]:
		assert_true(ResourceLoader.exists(RivetStrips.DIR + art + "/" + RivetWalk.RUN), art)
		var cycle: float = RivetWalk.RUN_CYCLE_CELL.get(art, 0.0)
		assert_gt(cycle, 0.0, art + ": a run cycle")
	assert_between(RivetWalk.RUN_CYCLE_CELL["p55"] / 8.0, 25.0, 28.0)


func test_an_armed_grid_steps_on_its_own_measured_cycle() -> void:
	# n9 it6: the armed grids' strides are 66-81 cell px a cycle, walk8's 60
	var card: Sprite2D = autofree(Sprite2D.new())
	card.vframes = RivetWalk.ROWS
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetWalk.ARMED + "pistol.png")
	assert_eq(RivetWalk.cycle_cell(card, "p70", false), RivetWalk.ARMED_CYCLE_CELL["p70/pistol"])
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetWalk.ARMED + "flamethrower.png")
	assert_eq(
		RivetWalk.cycle_cell(card, "p70", false), RivetWalk.CYCLE_CELL["p70"], "no measure: walk8's"
	)
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetWalk.STRIP)
	assert_eq(RivetWalk.cycle_cell(card, "p70", false), RivetWalk.CYCLE_CELL["p70"], "bare claw")
	assert_eq(RivetWalk.cycle_cell(card, "p55", true), RivetWalk.RUN_CYCLE_CELL["p55"], "the run")


func test_a_weapon_out_runs_on_its_drawn_armed_run_above_the_run_speed() -> void:
	# n9 it7: the library's armed runs (one-hand pistol, two-hand rifle at p70): run8's legs
	# it8: the blade run (the katana), the heavy run (the gatling)
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetWalk.RUN_FROM_MPS * CharacterRigs.PX_PER_M + 10.0
	for w: StringName in [&"pistol", &"plasma_rifle", &"katana", &"gatling", &"flamethrower"]:
		var path: String = RivetStrips.DIR + "p70/" + RivetWalk.ARMED_RUN + String(w) + ".png"
		assert_eq(RivetWalk.path_of(rig, "p70", w), path, "%s runs drawn" % w)
		assert_eq(RivetWalk.cols_of(path), 8)
		assert_true(RivetWalk.is_run(path), "steps on the run cycle")
		var tex: Texture2D = load(path) as Texture2D
		assert_eq(tex.get_width() % 8 + tex.get_height() % RivetWalk.ROWS, 0, "whole cells")
	# it8-it10: every library 55 armed run (pistol it8; rifle, katana, gatling it9; flamer it10)
	for w: StringName in [&"pistol", &"plasma_rifle", &"katana", &"gatling", &"flamethrower"]:
		var p55: String = RivetStrips.DIR + "p55/" + RivetWalk.ARMED_RUN + String(w) + ".png"
		assert_eq(RivetWalk.path_of(rig, "p55", w), p55, "%s runs drawn at 55" % w)
		var tex55: Texture2D = load(p55) as Texture2D
		assert_eq(tex55.get_width() % 8 + tex55.get_height() % RivetWalk.ROWS, 0, "whole cells")
	var cannon: String = RivetWalk.path_of(rig, "p70", &"hand_cannon")
	assert_false(cannon.get_file().begins_with(RivetWalk.ARMED_RUN), "no drawn armed run")
	RivetWalk.run = false
	assert_true(RivetWalk.path_of(rig, "p70", &"pistol").get_file().begins_with(RivetWalk.ARMED))
	rig.set_meta(RivetFrames.FIRE, true)
	RivetWalk.run = true
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), "", "a shot latches the fire cell")


func test_a_short_drawn_run_row_steps_on_its_own_stride() -> void:
	# n9 it8: the heavy run's left profile travels 59 cell px, run8's 63: its cycle shrinks
	var rig: CutRig = add_child_autofree(CutRig.new())
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	rig.head = head
	var card: Sprite2D = autofree(Sprite2D.new())
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetWalk.ARMED_RUN + "gatling.png")
	head.rotation = PI
	assert_eq(RivetWalk.row_k(card, "p70", rig), RivetWalk.RUN_ROW_K["p70/gatling/4"])
	assert_between(RivetWalk.row_k(card, "p70", rig), 0.9, 0.97)
	head.rotation = 0.0
	assert_eq(RivetWalk.row_k(card, "p70", rig), 1.0, "the right profile is run8's stride")
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetWalk.RUN)
	head.rotation = PI
	assert_eq(RivetWalk.row_k(card, "p70", rig), 1.0, "the bare run")
