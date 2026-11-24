extends GutTest


func test_a_walk_sheet_without_a_run_sheet_sprints_on_its_stop_gap() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var dir: String = RivetStrips.DIR + "p70/"
	var own: String = dir + RivetWalk.ARMED + "molotov.png"
	assert_eq(RivetFramesGrids.grid_for(&"molotov"), RivetFramesGrids.BARE)
	assert_true(ResourceLoader.exists(own))
	assert_false(ResourceLoader.exists(dir + RivetWalk.ARMED_RUN + "molotov.png"))
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	assert_eq(RivetWalk.motion_path(rig, "p70", &"molotov"), own, "walks on its own sheet")
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	var run: String = RivetWalk.motion_path(rig, "p70", &"molotov")
	assert_eq(run, dir + RivetWalk.RUN, "sprints on the stop-gap")
	assert_true(RivetWalk.is_run(run))
