extends GutTest
## n27: a weapon whose rivet_motion.json walk_grid.by_weapon row says bare_claw (gloria, until her
## compact-gun grids exist) walks and runs on the bare stride with the held part on the palm, though
## its own long-gun grid files stay in the repo.

var rig: CutRig


func before_each() -> void:
	rig = add_child_autofree(CutRig.new())


func test_gloria_is_held_only_and_the_pistol_keeps_its_grid() -> void:
	assert_true(RivetFramesGrids.held_only(&"gloria", "p70"))
	assert_false(RivetFramesGrids.held_only(&"gloria", "p55"), "p55 keeps her own grids")
	assert_false(RivetFramesGrids.held_only(&"pistol", "p70"))
	assert_eq(RivetFramesGrids.grid_for(&"gloria"), RivetFramesGrids.BARE)


func test_gloria_walks_and_runs_on_the_bare_grids_at_p70() -> void:
	var dir: String = RivetStrips.DIR + "p70/"
	assert_true(ResourceLoader.exists(dir + RivetWalk.ARMED + "gloria.png"), "the long grid stays")
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), dir + RivetWalk.STRIP)
	rig.speed_now = 3.2 * CharacterRigs.PX_PER_M
	assert_eq(RivetWalk.motion_path(rig, "p70", &"gloria"), dir + RivetWalk.RUN)
	assert_eq(RivetWalk.path_of(rig, "p70", &"gloria"), "", "its own grid is withheld")


func test_a_weapon_with_its_own_grid_still_uses_it() -> void:
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	var dir: String = RivetStrips.DIR + "p70/"
	assert_eq(RivetWalk.motion_path(rig, "p70", &"pistol"), dir + RivetWalk.ARMED + "pistol.png")


func test_gloria_at_p55_is_untouched_by_the_p70_row() -> void:
	rig.speed_now = 2.4 * CharacterRigs.PX_PER_M
	var dir: String = RivetStrips.DIR + "p55/"
	assert_false(ResourceLoader.exists(dir + RivetWalk.ARMED + "gloria.png"), "no p55 grid exists")
	assert_eq(RivetWalk.motion_path(rig, "p55", &"gloria"), dir + RivetWalk.STRIP)


func test_held_only_loads_the_table_on_a_cold_start() -> void:
	RivetFramesGrids._grid = {}
	RivetFramesGrids._held_only = {}
	assert_true(RivetFramesGrids.held_only(&"gloria", "p70"))
