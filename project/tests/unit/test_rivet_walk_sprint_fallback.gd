extends GutTest

## The molotov has its own run sheet since n30: the file cache is told it is missing, so the molotov
## stands in for any weapon with a walk sheet and no run sheet.
const DIR: String = RivetStrips.DIR + "p70/"
const RUN8: String = DIR + RivetWalk.ARMED_RUN + "molotov.png"


func after_each() -> void:
	@warning_ignore("return_value_discarded")
	RivetStrips._exists.erase(RUN8)


func test_a_walk_sheet_without_a_run_sheet_sprints_on_its_stop_gap() -> void:
	RivetStrips._exists[RUN8] = false
	var rig: CutRig = add_child_autofree(CutRig.new())
	var own: String = DIR + RivetWalk.ARMED + "molotov.png"
	assert_eq(RivetFramesGrids.grid_for(&"molotov"), RivetFramesGrids.BARE)
	assert_true(ResourceLoader.exists(own))
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	assert_eq(RivetWalk.motion_path(rig, "p70", &"molotov"), own, "walks on its own sheet")
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	var run: String = RivetWalk.motion_path(rig, "p70", &"molotov")
	assert_eq(run, DIR + RivetWalk.RUN, "sprints on the stop-gap")
	assert_true(RivetWalk.is_run(run))


func test_the_molotov_sprints_on_its_own_run_sheet() -> void:
	var rig: CutRig = add_child_autofree(CutRig.new())
	assert_true(ResourceLoader.exists(RUN8))
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	assert_eq(RivetWalk.motion_path(rig, "p70", &"molotov"), RUN8)
