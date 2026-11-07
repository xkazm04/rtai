extends GutTest
## d9 rivet (Call 2): the drawn stride grid is picked by octant and stride phase, bare-claw only.


func after_each() -> void:
	RivetWalk.enabled = true


func test_the_frame_follows_the_octant_row_and_the_stride_phase() -> void:
	var oct: PackedInt32Array = RivetFrames.BASE_OCT
	assert_eq(RivetWalk.frame_of(0, 0.0), oct[0] * 4, "screen right: profile row, contact")
	assert_eq(RivetWalk.frame_of(0, 0.3), oct[0] * 4 + 1, "passing")
	assert_eq(RivetWalk.frame_of(2, 0.6), oct[2] * 4 + 2, "toward the camera, other foot")
	assert_eq(RivetWalk.frame_of(5, 1.99), oct[5] * 4 + 3, "a drawn left row, wraps")
	assert_eq(RivetWalk.frame_of(4, -0.1), oct[4] * 4 + 3, "negative phase wraps")


func test_no_grid_with_a_weapon_out_standing_or_with_the_bob_flag() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.speed_now = RivetFrames.MOVING + 10.0
	assert_eq(RivetWalk.path_of(rig, "p70", &"pistol"), "", "a weapon out keeps its strip")
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


func test_each_art_key_ships_a_grid_of_four_frames_by_eight_rows() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/" + RivetWalk.STRIP
		assert_true(ResourceLoader.exists(path), "%s has the drawn stride (it22)" % art)
		var tex: Texture2D = load(path) as Texture2D
		assert_eq(tex.get_width() % RivetWalk.FRAMES, 0, "%s: whole cells across" % art)
		assert_eq(tex.get_height() % RivetWalk.ROWS, 0, "%s: whole cells down" % art)
		var cell_h: float = tex.get_height() / float(RivetWalk.ROWS)
		assert_gt(cell_h, RivetFrames.FIG_PX, "%s: a cell holds the 110 px figure" % art)
		var rig: CutRig = add_child_autofree(CutRig.new())
		rig.speed_now = RivetFrames.MOVING + 10.0
		assert_eq(RivetWalk.path_of(rig, art, &""), path, "%s: walking bare-claw takes it" % art)
